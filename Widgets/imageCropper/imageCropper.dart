// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

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
    required this.confirmButtonColor,
    this.cropImageOnSave = false,
    required this.onConfirm,
  });

  final double? width;
  final double? height;
  final FFUploadedFile imageFile;

  /// "circle", "rectangle" ou "freeform"
  final String cropShape;

  /// Apenas no modo retângulo (w/h). Ex: 1.0, 4/3, 16/9
  final double? aspectRatio;

  /// Mantidos por compatibilidade
  final double? minZoom;
  final double? maxZoom;

  /// 0..1
  final double? backgroundMaskOpacity;

  /// ✅ Cor do botão Confirmar
  final Color confirmButtonColor;

  /// Se true, recorta a imagem antes de salvar de acordo com o enquadramento.
  /// (ignorado no modo freeform — o recorte é sempre o lasso)
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

enum _Tool { pen, rect, oval, eraser, arrow }

enum _OutFormat { png, jpeg, webp }

enum _CropHandle {
  none,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
  inside,
}

abstract class _Annotation {
  void paint(Canvas canvas);
}

class _Freehand extends _Annotation {
  _Freehand({required this.points, required this.paintStyle});

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

class _ArrowAnnotation extends _Annotation {
  _ArrowAnnotation({
    required this.start,
    required this.end,
    required this.paintStyle,
  });

  final Offset start; // coords da imagem
  final Offset end; // coords da imagem
  final Paint paintStyle;

  @override
  void paint(Canvas canvas) {
    if ((end - start).distance < 4) return;

    // Linha principal
    canvas.drawLine(start, end, paintStyle);

    // Cabeça da seta (triângulo preenchido)
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final headLen = (paintStyle.strokeWidth * 4.0).clamp(14.0, 48.0);
    const headAngle = math.pi / 6; // 30°

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - headLen * math.cos(angle - headAngle),
        end.dy - headLen * math.sin(angle - headAngle),
      )
      ..lineTo(
        end.dx - headLen * math.cos(angle + headAngle),
        end.dy - headLen * math.sin(angle + headAngle),
      )
      ..close();

    final fillPaint = Paint()
      ..color = paintStyle.color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..blendMode = paintStyle.blendMode;
    canvas.drawPath(arrowPath, fillPaint);
  }
}

class _ImageCropperState extends State<ImageCropper> {
  ui.Image? _img;
  String? _error;

  final TransformationController _tc = TransformationController();

  _EditMode _mode = _EditMode.move;
  _Tool _tool = _Tool.pen;

  // Brush controls
  Color _color = const Color.fromARGB(255, 255, 0, 0);
  double _strokeWidth = 6.0;

  // Output controls
  _OutFormat _format = _OutFormat.png;
  int _quality = 92;

  // Annotations
  final List<_Annotation> _annotations = [];
  _Freehand? _currentFreehand;
  Rect? _currentShapeRect; // coords da imagem (rect/oval)
  Offset? _shapeStartImg;
  Offset? _currentArrowEnd; // coords da imagem (arrow)

  // Frame (viewport)
  Rect? _cropRectViewport;

  // Base transform (para reset)
  bool _didInitTransform = false;
  Size? _lastViewportSize;
  Rect? _lastCropRect;

  // ──────────────────────────────────────────
  // FREEFORM CROP state
  // ──────────────────────────────────────────
  Rect? _freeformCropRect;
  _CropHandle _activeHandle = _CropHandle.none;
  Offset? _dragStartOffset;
  Rect? _dragStartRect;
  bool _freeformEnabled = true; // Começa ativa por padrão

  // ──────────────────────────────────────────
  // Shape helpers
  // ──────────────────────────────────────────
  bool get _isCircle => widget.cropShape.toLowerCase().trim() == 'circle';
  bool get _isFreeform => widget.cropShape.toLowerCase().trim() == 'freeform';

  double get _aspectRatio {
    if (_isCircle) return 1.0;
    if (_isFreeform) return 1.0;
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
        setState(
          () => _error =
              'imageFile.bytes vazio. Use Uploaded Local File (Bytes).',
        );
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
    // No modo freeform, retornamos o viewport inteiro (sem moldura fixa)
    if (_isFreeform) {
      return Offset.zero & viewportSize;
    }

    const padding = 16.0;
    final usableW = viewportSize.width - padding * 2;
    final usableH = viewportSize.height - padding * 2;

    final maxSide = math.min(usableW, usableH) * 0.95;

    double w, h;
    if (_isCircle) {
      w = maxSide;
      h = maxSide;
    } else {
      final ar = _aspectRatio;
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

  void _initTransformToCoverCrop(Size viewportSize, Rect cropRect) {
    final img = _img;
    if (img == null) return;

    final iw = img.width.toDouble();
    final ih = img.height.toDouble();

    double coverScale;
    double dx, dy;

    if (_isFreeform) {
      // No modo freeform, a imagem cabe inteiramente no viewport (fit)
      coverScale = math.min(viewportSize.width / iw, viewportSize.height / ih);
      dx = (viewportSize.width - iw * coverScale) / 2.0;
      dy = (viewportSize.height - ih * coverScale) / 2.0;
    } else {
      coverScale = math.max(cropRect.width / iw, cropRect.height / ih);
      dx = cropRect.center.dx - (iw * coverScale) / 2.0;
      dy = cropRect.center.dy - (ih * coverScale) / 2.0;
    }

    _tc.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(coverScale);

    _didInitTransform = true;
  }

  void _resetView() {
    final vs = _lastViewportSize;
    final cr = _lastCropRect;
    if (vs == null || cr == null) return;
    if (_isFreeform) {
      setState(() {
        _freeformCropRect = null;
        _initTransformToCoverCrop(vs, cr);
      });
    } else {
      setState(() => _initTransformToCoverCrop(vs, cr));
    }
  }

  /// viewport -> imagem (px)
  Offset _viewportToImage(Offset viewportPoint) {
    return _tc.toScene(viewportPoint);
  }

  /// calcula foco -1..1 (Alignment)
  (double, double) _computeFocus(Rect cropRect) {
    if (_isFreeform) return (0.0, 0.0);

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
    if (_isFreeform) return true; // qualquer ponto é válido no modo livre
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
        _currentFreehand = _Freehand(
          points: [pImg],
          paintStyle: _makePaintForTool(),
        );
      });
    } else if (_tool == _Tool.arrow) {
      setState(() {
        _shapeStartImg = pImg;
        _currentArrowEnd = pImg;
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
    } else if (_tool == _Tool.arrow) {
      if (_shapeStartImg == null) return;
      setState(() {
        _currentArrowEnd = pImg;
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
    } else if (_tool == _Tool.arrow) {
      final start = _shapeStartImg;
      final end = _currentArrowEnd;
      if (start == null || end == null) return;
      setState(() {
        _annotations.add(
          _ArrowAnnotation(
            start: start,
            end: end,
            paintStyle: _makePaintForTool(),
          ),
        );
        _shapeStartImg = null;
        _currentArrowEnd = null;
      });
    } else {
      final rect = _currentShapeRect;
      if (rect == null) return;

      final paint = _makePaintForTool();
      final isOval = _tool == _Tool.oval;

      setState(() {
        _annotations.add(
          _ShapeBox(rect: rect, paintStyle: paint, isOval: isOval),
        );
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
      _currentArrowEnd = null;
    });
  }

  // ---------------------------
  // Freeform drag gesture handlers
  // ---------------------------

  _CropHandle _hitTestCropRect(Offset localPos, Rect rect) {
    const double handleRadius = 24.0;

    // Corners
    if ((localPos - rect.topLeft).distance <= handleRadius)
      return _CropHandle.topLeft;
    if ((localPos - rect.topRight).distance <= handleRadius)
      return _CropHandle.topRight;
    if ((localPos - rect.bottomLeft).distance <= handleRadius)
      return _CropHandle.bottomLeft;
    if ((localPos - rect.bottomRight).distance <= handleRadius)
      return _CropHandle.bottomRight;

    // Sides
    final topCenter = Offset(rect.center.dx, rect.top);
    final bottomCenter = Offset(rect.center.dx, rect.bottom);
    final leftCenter = Offset(rect.left, rect.center.dy);
    final rightCenter = Offset(rect.right, rect.center.dy);

    if ((localPos - topCenter).distance <= handleRadius) return _CropHandle.top;
    if ((localPos - bottomCenter).distance <= handleRadius)
      return _CropHandle.bottom;
    if ((localPos - leftCenter).distance <= handleRadius)
      return _CropHandle.left;
    if ((localPos - rightCenter).distance <= handleRadius)
      return _CropHandle.right;

    // Inside
    if (rect.contains(localPos)) {
      return _CropHandle.inside;
    }

    return _CropHandle.none;
  }

  void _onFreeformStart(DragStartDetails d) {
    if (!_isFreeform || !_freeformEnabled) return;
    final rect = _freeformCropRect;
    if (rect == null) return;

    final hit = _hitTestCropRect(d.localPosition, rect);
    if (hit != _CropHandle.none) {
      setState(() {
        _activeHandle = hit;
        _dragStartOffset = d.localPosition;
        _dragStartRect = rect;
      });
    }
  }

  void _onFreeformUpdate(DragUpdateDetails d) {
    if (!_isFreeform || !_freeformEnabled) return;
    final startRect = _dragStartRect;
    final startOffset = _dragStartOffset;
    if (startRect == null ||
        startOffset == null ||
        _activeHandle == _CropHandle.none) return;

    final delta = d.localPosition - startOffset;

    double left = startRect.left;
    double top = startRect.top;
    double right = startRect.right;
    double bottom = startRect.bottom;

    const double minSize = 50.0;

    switch (_activeHandle) {
      case _CropHandle.topLeft:
        left = math.min(startRect.left + delta.dx, startRect.right - minSize);
        top = math.min(startRect.top + delta.dy, startRect.bottom - minSize);
        break;
      case _CropHandle.topRight:
        right = math.max(startRect.right + delta.dx, startRect.left + minSize);
        top = math.min(startRect.top + delta.dy, startRect.bottom - minSize);
        break;
      case _CropHandle.bottomLeft:
        left = math.min(startRect.left + delta.dx, startRect.right - minSize);
        bottom = math.max(startRect.bottom + delta.dy, startRect.top + minSize);
        break;
      case _CropHandle.bottomRight:
        right = math.max(startRect.right + delta.dx, startRect.left + minSize);
        bottom = math.max(startRect.bottom + delta.dy, startRect.top + minSize);
        break;
      case _CropHandle.top:
        top = math.min(startRect.top + delta.dy, startRect.bottom - minSize);
        break;
      case _CropHandle.bottom:
        bottom = math.max(startRect.bottom + delta.dy, startRect.top + minSize);
        break;
      case _CropHandle.left:
        left = math.min(startRect.left + delta.dx, startRect.right - minSize);
        break;
      case _CropHandle.right:
        right = math.max(startRect.right + delta.dx, startRect.left + minSize);
        break;
      case _CropHandle.inside:
        final vs = _lastViewportSize;
        if (vs != null) {
          double dx = delta.dx;
          double dy = delta.dy;
          if (startRect.left + dx < 0) dx = -startRect.left;
          if (startRect.right + dx > vs.width) dx = vs.width - startRect.right;
          if (startRect.top + dy < 0) dy = -startRect.top;
          if (startRect.bottom + dy > vs.height)
            dy = vs.height - startRect.bottom;
          left = startRect.left + dx;
          top = startRect.top + dy;
          right = startRect.right + dx;
          bottom = startRect.bottom + dy;
        }
        break;
      default:
        break;
    }

    final vs = _lastViewportSize;
    if (vs != null) {
      left = left.clamp(0.0, vs.width);
      right = right.clamp(0.0, vs.width);
      top = top.clamp(0.0, vs.height);
      bottom = bottom.clamp(0.0, vs.height);
    }

    setState(() {
      _freeformCropRect = Rect.fromLTRB(left, top, right, bottom);
    });
  }

  void _onFreeformEnd(DragEndDetails d) {
    setState(() {
      _activeHandle = _CropHandle.none;
      _dragStartOffset = null;
      _dragStartRect = null;
    });
  }

  Future<void> _applyFreeformCrop() async {
    final img = _img;
    final fRect = _freeformCropRect;
    if (img == null || fRect == null) return;

    // Convert viewport selection to image coordinates
    final tl = _viewportToImage(fRect.topLeft);
    final br = _viewportToImage(fRect.bottomRight);
    final cropRectImg = Rect.fromPoints(tl, br);

    final imgRect = Rect.fromLTWH(
      0,
      0,
      img.width.toDouble(),
      img.height.toDouble(),
    );
    final finalCropImg = cropRectImg.intersect(imgRect);

    int outW = finalCropImg.width.round();
    int outH = finalCropImg.height.round();
    if (outW <= 0 || outH <= 0) return;

    // Crop the image
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.translate(-finalCropImg.left, -finalCropImg.top);
    canvas.drawImage(img, Offset.zero, Paint());

    final picture = recorder.endRecording();
    final croppedImage = await picture.toImage(outW, outH);

    // Shift existing annotations
    final shiftOffset = finalCropImg.topLeft;
    final updatedAnnotations = <_Annotation>[];
    for (final a in _annotations) {
      if (a is _Freehand) {
        updatedAnnotations.add(
          _Freehand(
            points: a.points.map((p) => p - shiftOffset).toList(),
            paintStyle: a.paintStyle,
          ),
        );
      } else if (a is _ShapeBox) {
        updatedAnnotations.add(
          _ShapeBox(
            rect: a.rect.shift(-shiftOffset),
            paintStyle: a.paintStyle,
            isOval: a.isOval,
          ),
        );
      } else if (a is _ArrowAnnotation) {
        updatedAnnotations.add(
          _ArrowAnnotation(
            start: a.start - shiftOffset,
            end: a.end - shiftOffset,
            paintStyle: a.paintStyle,
          ),
        );
      }
    }

    setState(() {
      _img = croppedImage;
      _annotations.clear();
      _annotations.addAll(updatedAnnotations);
      _freeformCropRect = null; // resets to new image dimensions in next build
      _freeformEnabled = false;
      _mode = _EditMode.annotate; // Switch to annotation mode
      _didInitTransform = false; // Force re-centering new image
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
      p.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
          const Radius.circular(16),
        ),
      );
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
    if (_tool == _Tool.arrow &&
        _shapeStartImg != null &&
        _currentArrowEnd != null) {
      _ArrowAnnotation(
        start: _shapeStartImg!,
        end: _currentArrowEnd!,
        paintStyle: _makePaintForTool(),
      ).paint(canvas);
    }
    canvas.restore();
  }

  Future<ui.Image?> _renderOutputImage(Rect cropRectView) async {
    final img = _img;
    if (img == null) return null;

    // ──────────────────────────────────────────
    // MODO FREEFORM
    // ──────────────────────────────────────────
    if (_isFreeform) {
      // Se a ferramenta de ajuste de corte não está habilitada, a imagem atual já está cortada.
      // Apenas exportamos ela inteira com as anotações feitas em cima.
      if (!_freeformEnabled) {
        return _renderFullImage(img);
      }

      final fRect = _freeformCropRect;
      if (fRect == null) {
        return _renderFullImage(img);
      }

      final tl = _viewportToImage(fRect.topLeft);
      final br = _viewportToImage(fRect.bottomRight);
      final cropRectImg = Rect.fromPoints(tl, br);

      final imgRect = Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      final finalCropImg = cropRectImg.intersect(imgRect);

      int outW = finalCropImg.width.round();
      int outH = finalCropImg.height.round();
      if (outW <= 0 || outH <= 0) return null;

      double scaleFactor = 1.0;
      final maxDim = math.max(outW, outH);
      const limit = 4096.0;
      if (maxDim > limit) {
        scaleFactor = limit / maxDim;
        outW = (outW * scaleFactor).round();
        outH = (outH * scaleFactor).round();
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.scale(scaleFactor);
      canvas.translate(-finalCropImg.left, -finalCropImg.top);

      canvas.drawImage(img, Offset.zero, Paint());
      _paintAllAnnotations(canvas);

      final picture = recorder.endRecording();
      return picture.toImage(outW, outH);
    }

    // ──────────────────────────────────────────
    // MODO CIRCLE / RECTANGLE (original)
    // ──────────────────────────────────────────
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

    canvas.drawImage(img, Offset.zero, Paint());
    _paintAllAnnotations(canvas);

    final picture = recorder.endRecording();
    return picture.toImage(outW, outH);
  }

  /// Renderiza a imagem completa sem nenhum corte (fallback)
  Future<ui.Image> _renderFullImage(ui.Image img) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(img, Offset.zero, Paint());
    _paintAllAnnotations(canvas);
    final picture = recorder.endRecording();
    return picture.toImage(img.width, img.height);
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

    final (fx, fy) = _computeFocus(cropRect);

    // Freeform sem seleção → devolve original
    if (_isFreeform && _freeformEnabled && _freeformCropRect == null) {
      await widget.onConfirm(widget.imageFile, fx, fy, true, _currentFormatExt);
      return;
    }

    // Sem anotações e sem recorte forçado → devolve original
    if (!_isFreeform &&
        !widget.cropImageOnSave &&
        _annotations.isEmpty &&
        _currentFreehand == null &&
        _currentShapeRect == null) {
      await widget.onConfirm(widget.imageFile, fx, fy, true, _currentFormatExt);
      return;
    }

    final out = await _exportFullImage(cropRect);
    if (out == null) return;

    await widget.onConfirm(out, fx, fy, true, _currentFormatExt);
  }

  Future<void> _cancel() async {
    await widget.onConfirm(
      widget.imageFile,
      0.0,
      0.0,
      false,
      _currentFormatExt,
    );
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
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: autoTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbarIconButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
    bool selected = false,
  }) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: selected
          ? Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: autoTextColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: widget.confirmButtonColor, size: 20),
            )
          : Icon(icon, color: autoTextColor.withOpacity(0.95)),
    );
  }

  Widget _colorDot(Color c) {
    final selected = _color.value == c.value;
    final borderColor = isColorDark(c) ? Colors.white : Colors.black;
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
            color: selected ? borderColor : borderColor.withOpacity(0.65),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
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

  // ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? double.infinity;

    return SizedBox(
      width: w,
      height: h,
      child: Column(
        children: [
          // ──────────────────────────────────────────
          // Header / Toolbar
          // ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: widget.confirmButtonColor,
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: _cancel,
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: autoTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Reset
                    _toolbarIconButton(
                      tooltip: 'Resetar enquadramento',
                      icon: Icons.refresh,
                      onPressed: _resetView,
                    ),

                    // Modo Freeform específico: Botões de Ajustar e Aplicar Corte (apenas ícones)
                    if (_isFreeform) ...[
                      _toolbarIconButton(
                        tooltip: _freeformEnabled
                            ? 'Ajustando corte'
                            : 'Ajustar corte',
                        icon: _freeformEnabled ? Icons.crop_free : Icons.crop,
                        selected: _freeformEnabled,
                        onPressed: () => setState(() {
                          _freeformEnabled = !_freeformEnabled;
                          if (_freeformEnabled) {
                            _mode =
                                _EditMode.move; // Move mode when adjusting crop
                          }
                        }),
                      ),
                      if (_freeformEnabled)
                        _toolbarIconButton(
                          tooltip: 'Aplicar corte na imagem',
                          icon: Icons.check_circle_outline,
                          selected: true,
                          onPressed: _applyFreeformCrop,
                        ),
                    ],

                    // Toggle mover/anotar (disponível em todos os modos se não estiver ajustando o corte)
                    if (!_isFreeform || !_freeformEnabled)
                      _toolbarIconButton(
                        tooltip: _mode == _EditMode.annotate
                            ? 'Mover (pan/zoom)'
                            : 'Anotar',
                        icon: _mode == _EditMode.annotate
                            ? Icons.open_with
                            : Icons.edit,
                        selected: _mode == _EditMode.annotate,
                        onPressed: () => setState(() {
                          _mode = _mode == _EditMode.annotate
                              ? _EditMode.move
                              : _EditMode.annotate;
                        }),
                      ),

                    _toolbarIconButton(
                      tooltip: 'Desfazer',
                      icon: Icons.undo,
                      onPressed: _undo,
                    ),
                    _toolbarIconButton(
                      tooltip: 'Limpar tudo',
                      icon: Icons.delete_outline,
                      onPressed: _clearAll,
                    ),
                  ],
                ),

                // Tools row (visível apenas se estiver no modo anotação e não estiver ajustando corte)
                if (_mode == _EditMode.annotate &&
                    (!_isFreeform || !_freeformEnabled))
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _toolButton(_Tool.pen, Icons.brush, 'Livre'),
                        const SizedBox(width: 8),
                        _toolButton(_Tool.rect, Icons.crop_square, 'Retângulo'),
                        const SizedBox(width: 8),
                        _toolButton(
                          _Tool.oval,
                          Icons.circle_outlined,
                          'Círculo',
                        ),
                        const SizedBox(width: 8),
                        _toolButton(_Tool.arrow, Icons.arrow_forward, 'Seta'),
                        const SizedBox(width: 8),
                        _toolButton(
                          _Tool.eraser,
                          Icons.auto_fix_off,
                          'Borracha',
                        ),
                        const SizedBox(width: 14),
                        _colorDot(const Color.fromARGB(255, 255, 0, 0)),
                        _colorDot(const Color.fromARGB(255, 51, 255, 0)),
                        _colorDot(const Color.fromARGB(255, 0, 38, 255)),
                        _colorDot(const Color.fromARGB(255, 249, 0, 249)),
                        _colorDot(const Color.fromARGB(255, 81, 0, 255)),
                        _colorDot(const Color.fromARGB(255, 229, 255, 0)),
                        const SizedBox(width: 14),
                        Text(
                          'Pincel',
                          style: TextStyle(
                            color: autoTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Formato',
                      style: TextStyle(
                        color: autoTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    DropdownButton<_OutFormat>(
                      value: _format,
                      dropdownColor: Colors.black,
                      items: [
                        DropdownMenuItem(
                          value: _OutFormat.png,
                          child: Text(
                            'PNG',
                            style: TextStyle(color: autoTextColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: _OutFormat.jpeg,
                          child: Text(
                            'JPG',
                            style: TextStyle(color: autoTextColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: _OutFormat.webp,
                          child: Text(
                            'WEBP',
                            style: TextStyle(color: autoTextColor),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _format = v ?? _OutFormat.png),
                    ),
                    Text(
                      'Qualidade: $_quality',
                      style: TextStyle(
                        color: autoTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(
                      width: 150,
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

          // ──────────────────────────────────────────
          // Canvas
          // ──────────────────────────────────────────
          Expanded(
            child: _error != null
                ? Center(child: Text(_error!, textAlign: TextAlign.center))
                : (_img == null
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final viewportSize = Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                          final cropRect = _computeCropRect(viewportSize);
                          _cropRectViewport = cropRect;

                          _lastViewportSize = viewportSize;
                          _lastCropRect = cropRect;

                          if (_isFreeform &&
                              _freeformEnabled &&
                              _freeformCropRect == null) {
                            final w = viewportSize.width * 0.8;
                            final h = viewportSize.height * 0.8;
                            final left = (viewportSize.width - w) / 2;
                            final top = (viewportSize.height - h) / 2;
                            _freeformCropRect = Rect.fromLTWH(
                              left,
                              top,
                              w,
                              h,
                            );
                          }

                          if (!_didInitTransform) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && !_didInitTransform) {
                                setState(
                                  () => _initTransformToCoverCrop(
                                    viewportSize,
                                    cropRect,
                                  ),
                                );
                              }
                            });
                          }

                          // No freeform: ajuste ativo → bloqueia pan;
                          //              ajuste inativo → pan livre da imagem.
                          // Zoom sempre desabilitado no freeform.
                          final bool panEnabled = _isFreeform
                              ? !_freeformEnabled
                              : _mode == _EditMode.move;
                          final bool scaleEnabled = !_isFreeform;

                          return Stack(
                            children: [
                              // Fundo branco
                              Positioned.fill(
                                child: Container(color: Colors.white),
                              ),

                              Positioned.fill(
                                child: ClipRect(
                                  child: InteractiveViewer(
                                    transformationController: _tc,
                                    constrained: false,
                                    boundaryMargin: const EdgeInsets.all(
                                      double.infinity,
                                    ),
                                    minScale: 0.0001,
                                    maxScale: 100.0,
                                    panEnabled: panEnabled,
                                    scaleEnabled: scaleEnabled,
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
                                          currentArrowStart: _shapeStartImg,
                                          currentArrowEnd: _currentArrowEnd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Gesture overlay — anotações (circle/rectangle)
                              if (_mode == _EditMode.annotate &&
                                  (!_isFreeform || !_freeformEnabled))
                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onPanStart: _onPanStart,
                                    onPanUpdate: _onPanUpdate,
                                    onPanEnd: _onPanEnd,
                                  ),
                                ),

                              // Gesture overlay — freeform resizing handles
                              if (_isFreeform && _freeformEnabled)
                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onPanStart: _onFreeformStart,
                                    onPanUpdate: _onFreeformUpdate,
                                    onPanEnd: _onFreeformEnd,
                                  ),
                                ),

                              // Crop mask (circle / rectangle)
                              if (!_isFreeform)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _CropMaskPainter(
                                        cropRect: cropRect,
                                        isCircle: _isCircle,
                                        isFreeform: false,
                                        opacity: _maskOpacity,
                                      ),
                                    ),
                                  ),
                                ),

                              // Crop mask overlay (freeform resizable rect)
                              if (_isFreeform && _freeformEnabled)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _FreeformCropMaskPainter(
                                        cropRect:
                                            _freeformCropRect ?? Rect.zero,
                                        opacity: _maskOpacity,
                                        showHandles: _freeformEnabled,
                                      ),
                                    ),
                                  ),
                                ),

                              // Floating Confirm Button (FAB Style)
                              Positioned(
                                right: 24,
                                bottom: 24,
                                child: SafeArea(
                                  top: false,
                                  child: GestureDetector(
                                    onTap: () => _confirm(cropRect),
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: widget.confirmButtonColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: autoTextColor,
                                        size: 28,
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

// ──────────────────────────────────────────
// Live Painter (anotações sobre a imagem)
// ──────────────────────────────────────────

class _LivePainter extends CustomPainter {
  _LivePainter({
    required this.img,
    required this.annotations,
    required this.currentFreehand,
    required this.currentShapeRect,
    required this.currentTool,
    required this.currentPaint,
    this.currentArrowStart,
    this.currentArrowEnd,
  });

  final ui.Image img;
  final List<_Annotation> annotations;
  final _Freehand? currentFreehand;
  final Rect? currentShapeRect;
  final _Tool currentTool;
  final Paint currentPaint;
  final Offset? currentArrowStart;
  final Offset? currentArrowEnd;

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
        rect: currentShapeRect!,
        paintStyle: currentPaint,
        isOval: isOval,
      ).paint(canvas);
    }
    if (currentTool == _Tool.arrow &&
        currentArrowStart != null &&
        currentArrowEnd != null) {
      _ArrowAnnotation(
        start: currentArrowStart!,
        end: currentArrowEnd!,
        paintStyle: currentPaint,
      ).paint(canvas);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LivePainter oldDelegate) {
    return oldDelegate.annotations != annotations ||
        oldDelegate.currentFreehand != currentFreehand ||
        oldDelegate.currentShapeRect != currentShapeRect ||
        oldDelegate.currentArrowStart != currentArrowStart ||
        oldDelegate.currentArrowEnd != currentArrowEnd ||
        oldDelegate.currentTool != currentTool;
  }
}

// ──────────────────────────────────────────
// Crop Mask Painter (circle / rectangle)
// ──────────────────────────────────────────

class _CropMaskPainter extends CustomPainter {
  _CropMaskPainter({
    required this.cropRect,
    required this.isCircle,
    required this.isFreeform,
    required this.opacity,
  });

  final Rect cropRect;
  final bool isCircle;
  final bool isFreeform;
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
        RRect.fromRectAndRadius(cropRect, const Radius.circular(16)),
      );
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
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CropMaskPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.isCircle != isCircle ||
        oldDelegate.opacity != opacity;
  }
}

// ──────────────────────────────────────────
// Freeform Crop Mask Painter (interactive rect)
// ──────────────────────────────────────────

class _FreeformCropMaskPainter extends CustomPainter {
  _FreeformCropMaskPainter({
    required this.cropRect,
    required this.opacity,
    required this.showHandles,
  });

  final Rect cropRect;
  final double opacity;
  final bool showHandles;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw mask
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()..addRect(cropRect);
    final mask = Path.combine(PathOperation.difference, full, hole);
    canvas.drawPath(mask, overlayPaint);

    // 2. Draw border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;
    canvas.drawRect(cropRect, borderPaint);

    if (showHandles) {
      // 3. Draw L-shaped corner handles and edge handles
      final handlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.square
        ..isAntiAlias = true;

      const double len = 16.0;

      // Top Left Corner
      canvas.drawPath(
        Path()
          ..moveTo(cropRect.left, cropRect.top + len)
          ..lineTo(cropRect.left, cropRect.top)
          ..lineTo(cropRect.left + len, cropRect.top),
        handlePaint,
      );

      // Top Right Corner
      canvas.drawPath(
        Path()
          ..moveTo(cropRect.right - len, cropRect.top)
          ..lineTo(cropRect.right, cropRect.top)
          ..lineTo(cropRect.right, cropRect.top + len),
        handlePaint,
      );

      // Bottom Left Corner
      canvas.drawPath(
        Path()
          ..moveTo(cropRect.left, cropRect.bottom - len)
          ..lineTo(cropRect.left, cropRect.bottom)
          ..lineTo(cropRect.left + len, cropRect.bottom),
        handlePaint,
      );

      // Bottom Right Corner
      canvas.drawPath(
        Path()
          ..moveTo(cropRect.right - len, cropRect.bottom)
          ..lineTo(cropRect.right, cropRect.bottom)
          ..lineTo(cropRect.right, cropRect.bottom - len),
        handlePaint,
      );

      // Edge Center Handles
      final topCenter = Offset(cropRect.center.dx, cropRect.top);
      final bottomCenter = Offset(cropRect.center.dx, cropRect.bottom);
      final leftCenter = Offset(cropRect.left, cropRect.center.dy);
      final rightCenter = Offset(cropRect.right, cropRect.center.dy);

      // Top Center
      canvas.drawLine(
        topCenter - const Offset(len / 2, 0),
        topCenter + const Offset(len / 2, 0),
        handlePaint,
      );
      // Bottom Center
      canvas.drawLine(
        bottomCenter - const Offset(len / 2, 0),
        bottomCenter + const Offset(len / 2, 0),
        handlePaint,
      );
      // Left Center
      canvas.drawLine(
        leftCenter - const Offset(0, len / 2),
        leftCenter + const Offset(0, len / 2),
        handlePaint,
      );
      // Right Center
      canvas.drawLine(
        rightCenter - const Offset(0, len / 2),
        rightCenter + const Offset(0, len / 2),
        handlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FreeformCropMaskPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.opacity != opacity ||
        oldDelegate.showHandles != showHandles;
  }
}
