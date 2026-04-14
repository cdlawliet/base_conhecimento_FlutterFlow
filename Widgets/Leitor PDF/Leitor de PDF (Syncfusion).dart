// ----------------------------------------------------
// NOVO PACOTE SUBSTITUTO: syncfusion_flutter_pdfviewer
// ----------------------------------------------------
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class LeitorPDF extends StatefulWidget {
  const LeitorPDF({
    super.key,
    this.width,
    this.height,
    this.pdfURL,
    this.documentoPDF,
    this.corHex,
    this.onClose,
    this.download,
    this.print,
    this.share,
    required this.showDownloadIcon,
    required this.showPrintIcon,
    required this.showShareIcon,
    required this.showTopBar,
  });

  final double? width;
  final double? height;
  final String? pdfURL;
  final FFUploadedFile? documentoPDF;
  final String? corHex;
  final Future Function()? onClose;
  final Future Function()? download;
  final Future Function()? print;
  final Future Function()? share;
  final bool showDownloadIcon;
  final bool showPrintIcon;
  final bool showShareIcon;
  final bool showTopBar;

  @override
  State<LeitorPDF> createState() => _LeitorPDFState();
}

class _LeitorPDFState extends State<LeitorPDF> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _paginaAtual = 1;
  int _totalPaginas = 1;
  bool _mostrarFerramentas = true; // Controladora do painel laterial

  Color get corPrimaria {
    if (widget.corHex != null && widget.corHex!.isNotEmpty) {
      // Tenta recuperar a cor HEX de forma segura
      try {
        return Color(int.parse(widget.corHex!.replaceAll('#', '0xFF')));
      } catch (e) {
        return FlutterFlowTheme.of(context).primary;
      }
    }
    return FlutterFlowTheme.of(context).primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          if (widget.showTopBar) _buildToolbar(),
          Expanded(
            child: Stack(
              children: [
                _buildSource(),

                // 🔍 Controles visuais + Ações Avançadas e Botão de Ocultar/Mostrar
                Positioned(
                  right: 12,
                  bottom: 80,
                  child: Column(
                    children: [
                      if (_mostrarFerramentas) ...[
                        // 🔍 Zoom In
                        _botao(Icons.zoom_in, () {
                          _pdfViewerController.zoomLevel =
                              _pdfViewerController.zoomLevel + 0.5;
                        }),
                        const SizedBox(height: 8),

                        // 🔍 Zoom Out
                        _botao(Icons.zoom_out, () {
                          if (_pdfViewerController.zoomLevel > 1.0) {
                            _pdfViewerController.zoomLevel =
                                _pdfViewerController.zoomLevel - 0.5;
                          }
                        }),
                        const SizedBox(height: 8),

                        // 💡 Fit Screen
                        _botao(Icons.fit_screen, () {
                          _pdfViewerController.zoomLevel = 1.0;
                        }),
                        const SizedBox(height: 8),

                        // 📥 Download
                        if (widget.showDownloadIcon) ...[
                          _botao(Icons.download, () async {
                            if (widget.download != null) await widget.download!();
                          }),
                          const SizedBox(height: 8),
                        ],

                        // 🖨️ Imprimir
                        if (widget.showPrintIcon) ...[
                          _botao(Icons.print, () async {
                            if (widget.print != null) await widget.print!();
                          }),
                          const SizedBox(height: 8),
                        ],

                        // 🔗 Compartilhar
                        if (widget.showShareIcon) ...[
                          _botao(Icons.share, () async {
                            if (widget.share != null) await widget.share!();
                          }),
                          const SizedBox(height: 8),
                        ],
                      ],

                      // 👁️ Botão de Mostrar/Ocultar as ferramentas (Sempre visível para reabrir)
                      _botao(
                        _mostrarFerramentas ? Icons.visibility_off : Icons.visibility,
                        () {
                          setState(() {
                            _mostrarFerramentas = !_mostrarFerramentas;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                 // Dica de zoom removida
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // 🔝 HEADER
  Widget _buildToolbar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: corPrimaria,
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Visualizador PDF',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          // ❌ Botão fechar
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              if (widget.onClose != null) {
                await widget.onClose!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  // 🔽 FOOTER
  Widget _buildFooter() {
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.black),
      child: Text(
        'Página $_paginaAtual de $_totalPaginas',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  // 🔘 Botões visuais (Agora com VoidCallback)
  Widget _botao(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  // 📄 PDF SOURCE INTEGRADO COM SYNCFUSION
  Widget _buildSource() {
    if (widget.documentoPDF != null &&
        widget.documentoPDF!.bytes != null &&
        widget.documentoPDF!.bytes!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SfPdfViewer.memory(
          widget.documentoPDF!.bytes!,
          controller: _pdfViewerController,
          canShowScrollHead: false, // Esconde barra customizada para ficar clean
          pageSpacing: 4,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            setState(() {
              _totalPaginas = details.document.pages.count;
            });
          },
          onPageChanged: (PdfPageChangedDetails details) {
            setState(() => _paginaAtual = details.newPageNumber);
          },
        ),
      );
    } else if (widget.pdfURL != null && widget.pdfURL!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SfPdfViewer.network(
          widget.pdfURL!,
          controller: _pdfViewerController,
          canShowScrollHead: false, 
          pageSpacing: 4,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            setState(() {
              _totalPaginas = details.document.pages.count;
            });
          },
          onPageChanged: (PdfPageChangedDetails details) {
            setState(() => _paginaAtual = details.newPageNumber);
          },
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Nenhum PDF selecionado',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
