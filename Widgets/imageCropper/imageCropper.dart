import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCropper extends StatefulWidget {
  const ImageCropper({
    super.key,
    this.width,
    this.height,
    required this.imageFile,
    required this.cropShape,
    this.aspectRatio,
    this.minZoom,
    this.maxZoom,
    this.backgroundMaskOpacity,
    required this.confirmButtonColor, // ✅ NOVO
    this.cropImageOnSave = false, // ✅ NOVO
    required this.onConfirm,
  });

  final double? width;
  final double? height;
  final FFUploadedFile imageFile;

  /// "circle" ou "rectangle"
  final String cropShape;

  /// Apenas no modo retângulo (w/h). Ex: 1.0, 4/3, 16/9
  final double? aspectRatio;

  /// (mantidos por compatibilidade, mas no modo "livre" não limitamos min/max)
  final double? minZoom;
  final double? maxZoom;

  /// 0..1
  final double? backgroundMaskOpacity;

  /// ✅ Cor do botão Confirmar
  final Color confirmButtonColor;

  /// Se true, recorta a imagem antes de salvar de acordo com o enquadramento.
  final bool cropImageOnSave;

  final Future Function(
    FFUploadedFile editedImage,
    double focusX,
    double focusY,
    bool didConfirm,
    String formatFile,
  ) onConfirm;

  @override
  State<ImageCropper> createState() => _ImageCropperState();
}

enum _EditMode { move, annotate }

enum _Tool { pen, rect, oval, eraser }

enum _OutFormat { png, jpeg, webp }

abstract class _Annotation {
  void paint(Canvas canvas);
}

class _Freehand extends _Annotation {
  _Freehand({
    required this.points,
    required this.paintStyle,
  });

  final List<Offset> points; // coords da imagem (px)
  final Paint paintStyle;

  @override
  void paint(Canvas canvas) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paintStyle);
  }
}

class _ShapeBox extends _Annotation {
  _ShapeBox({
    required this.rect,
    required this.paintStyle,
    required this.isOval,
  });

  final Rect rect; // coords da imagem
  final Paint paintStyle;
  final bool isOval;

  @override
  void paint(Canvas canvas) {
    if (isOval) {
      canvas.drawOval(rect, paintStyle);
    } else {
      canvas.drawRect(rect, paintStyle);
    }
  }
}

class _ImageCropperState extends State<ImageCropper> {
  ui.Image? _img;
  String? _error;

  final TransformationController _tc = TransformationController();

  _EditMode _mode = _EditMode.move;
  _Tool _tool = _Tool.pen;

  // Brush controls
  Color _color = Colors.redAccent;
  double _strokeWidth = 6.0;

  // Output controls
  _OutFormat _format = _OutFormat.png;
  int _quality = 92; // 0..100 (mais útil para JPG)

  // Annotations
  final List<_Annotation> _annotations = [];
  _Freehand? _currentFreehand;
  Rect? _currentShapeRect; // coords da imagem
  Offset? _shapeStartImg;

  // Frame (viewport)
  Rect? _cropRectViewport;

  // Base transform (para reset)
  bool _didInitTransform = false;
  Size? _lastViewportSize;
  Rect? _lastCropRect;

  bool get _isCircle => widget.cropShape.toLowerCase().trim() == 'circle';

  double get _aspectRatio {
    if (_isCircle) return 1.0;
    final ar = widget.aspectRatio;
    if (ar == null || ar.isNaN || ar <= 0) return 1.0;
    return ar;
  }

  double get _maskOpacity =>
      (widget.backgroundMaskOpacity ?? 0.65).clamp(0.0, 0.95);

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  Future<void> _decodeImage() async {
    try {
      final bytes = widget.imageFile.bytes;
      if (bytes == null || bytes.isEmpty) {
        setState(() =>
            _error = 'imageFile.bytes vazio. Use Uploaded Local File (Bytes).');
        return;
      }
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _img = frame.image;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Falha ao decodificar imagem: $e');
    }
  }

  // ---------------------------
  // Geometry helpers
  // ---------------------------

  Rect _computeCropRect(Size viewportSize) {
    const padding = 16.0;
    final usableW = viewportSize.width - padding * 2;
    final usableH = viewportSize.height - padding * 2;

    final maxSide = math.min(usableW, usableH) * 0.95;

    double w, h;
    if (_isCircle) {
      w = maxSide;
      h = maxSide;
    } else {
      final ar = _aspectRatio; // w/h
      if (ar >= 1) {
        w = maxSide;
        h = w / ar;
        if (h > usableH) {
          h = usableH * 0.82;
          w = h * ar;
        }
      } else {
        h = maxSide;
        w = h * ar;
        if (w > usableW) {
          w = usableW * 0.95;
          h = w / ar;
        }
      }
    }

    final left = (viewportSize.width - w) / 2.0;
    final top = (viewportSize.height - h) / 2.0;

    return Rect.fromLTWH(left, top, w, h);
  }

  /// Inicializa a matriz para que a imagem comece cobrindo o frame (melhor UX)
  void _initTransformToCoverCrop(Size viewportSize, Rect cropRect) {
    final img = _img;
    if (img == null) return;

    final iw = img.width.toDouble();
    final ih = img.height.toDouble();

    final coverScale = math.max(
      cropRect.width / iw,
      cropRect.height / ih,
    );

    final dx = cropRect.center.dx - (iw * coverScale) / 2.0;
    final dy = cropRect.center.dy - (ih * coverScale) / 2.0;

    _tc.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(coverScale);

    _didInitTransform = true;
  }

  void _resetView() {
    final vs = _lastViewportSize;
    final cr = _lastCropRect;
    if (vs == null || cr == null) return;
    setState(() => _initTransformToCoverCrop(vs, cr));
  }

  /// viewport -> imagem (px)
  Offset _viewportToImage(Offset viewportPoint) {
    return _tc.toScene(viewportPoint);
  }

  /// calcula foco -1..1 (Alignment)
  (double, double) _computeFocus(Rect cropRect) {
    final img = _img!;
    final centerV = cropRect.center;
    final pImg = _viewportToImage(centerV);

    final iw = img.width.toDouble();
    final ih = img.height.toDouble();

    final nx = (pImg.dx / iw).clamp(0.0, 1.0);
    final ny = (pImg.dy / ih).clamp(0.0, 1.0);

    final fx = (nx * 2.0) - 1.0;
    final fy = (ny * 2.0) - 1.0;

    return (fx.clamp(-1.0, 1.0), fy.clamp(-1.0, 1.0));
  }

  bool _insideFrame(Offset viewportPos) {
    final crop = _cropRectViewport;
    if (crop == null) return false;
    if (!_isCircle) return crop.contains(viewportPos);

    final c = crop.center;
    final rx = crop.width / 2.0;
    final ry = crop.height / 2.0;
    final dx = (viewportPos.dx - c.dx) / rx;
    final dy = (viewportPos.dy - c.dy) / ry;
    return (dx * dx + dy * dy) <= 1.0;
  }

  Paint _makePaintForTool() {
    final isEraser = _tool == _Tool.eraser;
    return Paint()
      ..color = isEraser ? Colors.transparent : _color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..blendMode = isEraser ? BlendMode.clear : BlendMode.srcOver;
  }

  // ---------------------------
  // Gesture handling (annotation)
  // ---------------------------

  void _onPanStart(DragStartDetails d) {
    if (_mode != _EditMode.annotate) return;
    if (!_insideFrame(d.localPosition)) return;

    final pImg = _viewportToImage(d.localPosition);

    if (_tool == _Tool.pen || _tool == _Tool.eraser) {
      setState(() {
        _currentFreehand =
            _Freehand(points: [pImg], paintStyle: _makePaintForTool());
      });
    } else {
      setState(() {
        _shapeStartImg = pImg;
        _currentShapeRect = Rect.fromPoints(pImg, pImg);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_mode != _EditMode.annotate) return;
    if (!_insideFrame(d.localPosition)) return;

    final pImg = _viewportToImage(d.localPosition);

    if (_tool == _Tool.pen || _tool == _Tool.eraser) {
      final cur = _currentFreehand;
      if (cur == null) return;
      setState(() {
        cur.points.add(pImg);
      });
    } else {
      final start = _shapeStartImg;
      if (start == null) return;
      setState(() {
        _currentShapeRect = Rect.fromPoints(start, pImg);
      });
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (_mode != _EditMode.annotate) return;

    if (_tool == _Tool.pen || _tool == _Tool.eraser) {
      final cur = _currentFreehand;
      if (cur == null) return;
      setState(() {
        _annotations.add(cur);
        _currentFreehand = null;
      });
    } else {
      final rect = _currentShapeRect;
      if (rect == null) return;

      final paint = _makePaintForTool();
      final isOval = _tool == _Tool.oval;

      setState(() {
        _annotations
            .add(_ShapeBox(rect: rect, paintStyle: paint, isOval: isOval));
        _currentShapeRect = null;
        _shapeStartImg = null;
      });
    }
  }

  void _undo() {
    if (_annotations.isEmpty) return;
    setState(() => _annotations.removeLast());
  }

  void _clearAll() {
    setState(() {
      _annotations.clear();
      _currentFreehand = null;
      _currentShapeRect = null;
      _shapeStartImg = null;
    });
  }

  // ---------------------------
  // Export pipeline
  // ---------------------------

  Path _framePath(Rect cropRect) {
    final p = Path();
    if (_isCircle) {
      p.addOval(Rect.fromLTWH(0, 0, cropRect.width, cropRect.height));
    } else {
      p.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
        const Radius.circular(16),
      ));
    }
    return p;
  }

  void _paintAllAnnotations(Canvas canvas) {
    canvas.saveLayer(null, Paint());
    for (final a in _annotations) {
      a.paint(canvas);
    }
    _currentFreehand?.paint(canvas);
    if (_currentShapeRect != null &&
        (_tool == _Tool.rect || _tool == _Tool.oval)) {
      _ShapeBox(
        rect: _currentShapeRect!,
        paintStyle: _makePaintForTool(),
        isOval: _tool == _Tool.oval,
      ).paint(canvas);
    }
    canvas.restore();
  }

  Future<ui.Image?> _renderOutputImage(Rect cropRectView) async {
    final img = _img;
    if (img == null) return null;

    final crop = widget.cropImageOnSave;

    int outW = img.width;
    int outH = img.height;
    Rect? cropRectImg;
    double scaleFactor = 1.0;

    if (crop) {
      final tl = _viewportToImage(cropRectView.topLeft);
      final br = _viewportToImage(cropRectView.bottomRight);
      cropRectImg = Rect.fromPoints(tl, br);
      
      outW = cropRectImg.width.round();
      outH = cropRectImg.height.round();
      if (outW <= 0 || outH <= 0) return null;

      final maxDim = math.max(outW, outH);
      final imgMaxDim = math.max(img.width, img.height);
      final limit = math.max(imgMaxDim, 2048).toDouble();
      
      if (maxDim > limit) {
        scaleFactor = limit / maxDim;
        outW = (outW * scaleFactor).round();
        outH = (outH * scaleFactor).round();
      }
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (crop && cropRectImg != null) {
      canvas.scale(scaleFactor);
      canvas.translate(-cropRectImg.left, -cropRectImg.top);
      if (_isCircle) {
        final p = Path()..addOval(cropRectImg);
        canvas.clipPath(p);
      }
    }

    // Desenha a imagem inteira sem nenhum corte ou transformação (o crop já altera a visão)
    canvas.drawImage(img, Offset.zero, Paint());
    
    // Pinta qualquer anotação livre sobre as coordenadas originais da imagem
    _paintAllAnnotations(canvas);

    final picture = recorder.endRecording();
    return picture.toImage(outW, outH);
  }

  Future<FFUploadedFile?> _exportFullImage(Rect cropRectView) async {
    final img = _img;
    if (img == null) return null;

    final outImg = await _renderOutputImage(cropRectView);
    if (outImg == null) return null;

    final outW = outImg.width;
    final outH = outImg.height;

    final pngBd = await outImg.toByteData(format: ui.ImageByteFormat.png);
    if (pngBd == null) return null;
    final pngBytes = pngBd.buffer.asUint8List();

    final fmt = _format == _OutFormat.jpeg
        ? CompressFormat.jpeg
        : _format == _OutFormat.webp
            ? CompressFormat.webp
            : CompressFormat.png;

    final compressed = await FlutterImageCompress.compressWithList(
      pngBytes,
      quality: _quality,
      format: fmt,
      minWidth: outW,
      minHeight: outH,
    );

    final ext = _format == _OutFormat.jpeg
        ? 'jpg'
        : _format == _OutFormat.webp
            ? 'webp'
            : 'png';
            
    return FFUploadedFile(
      name: 'edited_${DateTime.now().millisecondsSinceEpoch}.$ext',
      bytes: compressed,
      width: outW.toDouble(),
      height: outH.toDouble(),
    );
  }

  String get _currentFormatExt => _format == _OutFormat.jpeg
      ? 'jpg'
      : _format == _OutFormat.webp
          ? 'webp'
          : 'png';

  Future<void> _confirm(Rect cropRect) async {
    final img = _img;
    if (img == null) return;

    // Apenas extraímos os eixos Fx e Fy para retorno
    final (fx, fy) = _computeFocus(cropRect);
    
    // Se o usuário APENAS selecionou o foco sem desenhar ou apagar nada, e não o forçamos a recortar,
    // Devolvemos O ARQUIVO ORIGINAL INTOCADO para não perder qualidade nenhuma!
    if (!widget.cropImageOnSave && _annotations.isEmpty && _currentFreehand == null && _currentShapeRect == null) {
      await widget.onConfirm(widget.imageFile, fx, fy, true, _currentFormatExt);
      return;
    }

    // Se o usuário de fato precisou salvar anotações ou selecionou o recorte, processamos a foto original
    final out = await _exportFullImage(cropRect);
    if (out == null) return;

    await widget.onConfirm(out, fx, fy, true, _currentFormatExt);
  }

  Future<void> _cancel() async {
    await widget.onConfirm(widget.imageFile, 0.0, 0.0, false, _currentFormatExt);
  }

  // ---------------------------
  // UI helpers
  // ---------------------------

  Widget _toolButton(_Tool t, IconData icon, String label) {
    final selected = _tool == t;
    return InkWell(
      onTap: () => setState(() => _tool = t),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? Colors.white70 : Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: autoTextColor),
            const SizedBox(width: 6),
            Text(label.toUpperCase(),
                style: TextStyle(
                    color: autoTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color c) {
    final selected = _color.value == c.value;
    return GestureDetector(
      onTap: () => setState(() => _color = c),
      child: Container(
        width: 22,
        height: 22,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(
              color: selected ? Colors.white : Colors.black26,
              width: selected ? 2 : 1),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
      ),
    );
  }

  bool isColorDark(Color c) {
    return c.computeLuminance() < 0.5;
  }

  Color get autoTextColor {
    return isColorDark(widget.confirmButtonColor) ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? double.infinity;

    return SizedBox(
      width: w,
      height: h,
      child: Column(
        children: [
          // Header / Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: widget.confirmButtonColor,
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: _cancel,
                      child: Text('Cancelar',
                          style: TextStyle(
                              color: autoTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6)),
                    ),
                    const Spacer(),

                    // ✅ RESET
                    IconButton(
                      tooltip: 'Resetar enquadramento',
                      onPressed: _resetView,
                      icon: Icon(Icons.refresh, color: autoTextColor),
                    ),

                    IconButton(
                      tooltip: _mode == _EditMode.annotate
                          ? 'Mover (pan/zoom)'
                          : 'Anotar',
                      onPressed: () => setState(() {
                        _mode = _mode == _EditMode.annotate
                            ? _EditMode.move
                            : _EditMode.annotate;
                      }),
                      icon: Icon(
                        _mode == _EditMode.annotate
                            ? Icons.open_with
                            : Icons.edit,
                        color: autoTextColor,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Desfazer',
                      onPressed: _undo,
                      icon: Icon(Icons.undo, color: autoTextColor),
                    ),
                    IconButton(
                      tooltip: 'Limpar tudo',
                      onPressed: _clearAll,
                      icon: Icon(Icons.delete_outline, color: autoTextColor),
                    ),
                  ],
                ),

                // Tools row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _toolButton(_Tool.pen, Icons.brush, 'Livre'),
                      const SizedBox(width: 8),
                      _toolButton(_Tool.rect, Icons.crop_square, 'Retângulo'),
                      const SizedBox(width: 8),
                      _toolButton(_Tool.oval, Icons.circle_outlined, 'Círculo'),
                      const SizedBox(width: 8),
                      _toolButton(_Tool.eraser, Icons.auto_fix_off, 'Borracha'),
                      const SizedBox(width: 14),
                      _colorDot(Colors.redAccent),
                      _colorDot(Colors.greenAccent),
                      _colorDot(Colors.blueAccent),
                      _colorDot(Colors.purpleAccent),
                      _colorDot(Colors.deepPurpleAccent),
                      _colorDot(Colors.yellowAccent),
                      const SizedBox(width: 14),
                      Text('Pincel',
                          style: TextStyle(
                              color: autoTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6)),
                      SizedBox(
                        width: 120,
                        child: Slider(
                          value: _strokeWidth.clamp(1.0, 30.0),
                          min: 1,
                          max: 30,
                          onChanged: (v) => setState(() => _strokeWidth = v),
                        ),
                      ),
                    ],
                  ),
                ),

                // Output controls
                Row(
                  children: [
                    Text('Formato',
                        style: TextStyle(
                            color: autoTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6)),
                    const SizedBox(width: 8),
                    DropdownButton<_OutFormat>(
                      value: _format,
                      dropdownColor: Colors.black,
                      items: [
                        DropdownMenuItem(
                            value: _OutFormat.png,
                            child: Text('PNG',
                                style: TextStyle(color: autoTextColor))),
                        DropdownMenuItem(
                            value: _OutFormat.jpeg,
                            child: Text('JPG',
                                style: TextStyle(color: autoTextColor))),
                        DropdownMenuItem(
                            value: _OutFormat.webp,
                            child: Text('WEBP',
                                style: TextStyle(color: autoTextColor))),
                      ],
                      onChanged: (v) =>
                          setState(() => _format = v ?? _OutFormat.png),
                    ),
                    const SizedBox(width: 14),
                    Text('Qualidade: $_quality',
                        style: TextStyle(
                            color: autoTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6)),
                    Expanded(
                      child: Slider(
                        value: _quality.toDouble(),
                        min: 40,
                        max: 100,
                        divisions: 60,
                        onChanged: (v) => setState(() => _quality = v.round()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _error != null
                ? Center(child: Text(_error!, textAlign: TextAlign.center))
                : (_img == null
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final viewportSize =
                              Size(constraints.maxWidth, constraints.maxHeight);
                          final cropRect = _computeCropRect(viewportSize);
                          _cropRectViewport = cropRect;

                          // salvar para reset
                          _lastViewportSize = viewportSize;
                          _lastCropRect = cropRect;

                          // init uma vez
                          if (!_didInitTransform) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && !_didInitTransform) {
                                setState(() => _initTransformToCoverCrop(
                                    viewportSize, cropRect));
                              }
                            });
                          }

                          return Stack(
                            children: [
                              // ✅ fundo branco para aparecer quando "sair" da imagem
                              Positioned.fill(
                                  child: Container(color: Colors.white)),

                              Positioned.fill(
                                child: ClipRect(
                                  child: InteractiveViewer(
                                    transformationController: _tc,

                                    constrained: false,

                                    // ✅ sem limites de borda (movimento 100% livre)
                                    // A doc recomenda EdgeInsets infinito para remover boundaries [1](https://api.flutter.dev/flutter/widgets/InteractiveViewer/boundaryMargin.html)
                                    boundaryMargin:
                                        const EdgeInsets.all(double.infinity),

                                    // ✅ zoom livre
                                    minScale: 0.0001,
                                    maxScale: 100.0,

                                    panEnabled: _mode == _EditMode.move,
                                    scaleEnabled: true,

                                    child: SizedBox(
                                      width: _img!.width.toDouble(),
                                      height: _img!.height.toDouble(),
                                      child: CustomPaint(
                                        painter: _LivePainter(
                                          img: _img!,
                                          annotations: _annotations,
                                          currentFreehand: _currentFreehand,
                                          currentShapeRect: _currentShapeRect,
                                          currentTool: _tool,
                                          currentPaint: _makePaintForTool(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Gesture overlay (só no modo anotação)
                              if (_mode == _EditMode.annotate)
                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onPanStart: _onPanStart,
                                    onPanUpdate: _onPanUpdate,
                                    onPanEnd: _onPanEnd,
                                  ),
                                ),

                              // Crop mask
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _CropMaskPainter(
                                      cropRect: cropRect,
                                      isCircle: _isCircle,
                                      opacity: _maskOpacity,
                                    ),
                                  ),
                                ),
                              ),

                              // Confirm button
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: SafeArea(
                                  top: false,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _confirm(cropRect),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Confirmar edição'),
                                    style: ElevatedButton.styleFrom(
                                      // ✅ cor via parâmetro (fallback para tema)
                                      backgroundColor:
                                          widget.confirmButtonColor,
                                      foregroundColor: autoTextColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}

class _LivePainter extends CustomPainter {
  _LivePainter({
    required this.img,
    required this.annotations,
    required this.currentFreehand,
    required this.currentShapeRect,
    required this.currentTool,
    required this.currentPaint,
  });

  final ui.Image img;
  final List<_Annotation> annotations;
  final _Freehand? currentFreehand;
  final Rect? currentShapeRect;
  final _Tool currentTool;
  final Paint currentPaint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(img, Offset.zero, Paint());

    canvas.saveLayer(null, Paint());
    for (final a in annotations) {
      a.paint(canvas);
    }
    currentFreehand?.paint(canvas);

    if (currentShapeRect != null &&
        (currentTool == _Tool.rect || currentTool == _Tool.oval)) {
      final isOval = currentTool == _Tool.oval;
      _ShapeBox(
              rect: currentShapeRect!, paintStyle: currentPaint, isOval: isOval)
          .paint(canvas);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LivePainter oldDelegate) {
    return oldDelegate.annotations != annotations ||
        oldDelegate.currentFreehand != currentFreehand ||
        oldDelegate.currentShapeRect != currentShapeRect ||
        oldDelegate.currentTool != currentTool;
  }
}

class _CropMaskPainter extends CustomPainter {
  _CropMaskPainter({
    required this.cropRect,
    required this.isCircle,
    required this.opacity,
  });

  final Rect cropRect;
  final bool isCircle;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final holePath = Path();
    if (isCircle) {
      holePath.addOval(cropRect);
    } else {
      holePath.addRRect(
          RRect.fromRectAndRadius(cropRect, const Radius.circular(16)));
    }

    final full = Path()..addRect(Offset.zero & size);
    final mask = Path.combine(PathOperation.difference, full, holePath);

    canvas.drawPath(mask, overlayPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true;

    if (isCircle) {
      canvas.drawOval(cropRect, borderPaint);
    } else {
      canvas.drawRRect(
          RRect.fromRectAndRadius(cropRect, const Radius.circular(16)),
          borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropMaskPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.isCircle != isCircle ||
        oldDelegate.opacity != opacity;
  }
}
