# Leitor de PDF (Syncfusion)

Widget de visualizacao de PDF baseado em `syncfusion_flutter_pdfviewer`, com toolbar opcional, paginacao, zoom e acoes laterais configuraveis.

## Dependencias

Adicione no FlutterFlow:
- `syncfusion_flutter_pdfviewer`

## Configuracao para Web

Para o leitor funcionar corretamente no navegador, adicione tambem o script do `pdf.js` nos headers do build web do FlutterFlow.

Caminho no FlutterFlow:
- `App Settings > Web Deployment > Custom Headers`

Cole este conteudo no campo `Custom Headers`:

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.11.338/pdf.min.js"></script>
<script type="text/javascript">
  var pdfjsLib = window['pdfjs-dist/build/pdf'];
  pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.11.338/pdf.worker.min.js';
</script>
```

Esse mesmo conteudo esta salvo em [funcionar_web.js](/d:/OneDrive/Documentos/Projetos%20Flutter/Widgets/Leitor%20PDF/funcionar_web.js).

Sem essa configuracao, o visualizador pode funcionar no mobile, mas apresentar falhas de carregamento no Web.

## Parametros

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `width` | `double?` | Largura do widget. |
| `height` | `double?` | Altura do widget. |
| `pdfURL` | `String?` | URL publica do PDF para carregamento remoto. |
| `documentoPDF` | `FFUploadedFile?` | PDF em bytes para carregamento local. |
| `corHex` | `String?` | Cor da toolbar em HEX, por exemplo `#1565C0`. |
| `onClose` | `Future Function()?` | Callback ao clicar em fechar. Se nao for informado, o widget executa `Navigator.pop(context)`. |
| `download` | `Future Function()?` | Callback do botao de download. |
| `print` | `Future Function()?` | Callback do botao de impressao. |
| `share` | `Future Function()?` | Callback do botao de compartilhamento. |
| `showDownloadIcon` | `bool` | Exibe ou oculta o botao de download. |
| `showPrintIcon` | `bool` | Exibe ou oculta o botao de impressao. |
| `showShareIcon` | `bool` | Exibe ou oculta o botao de compartilhamento. |
| `showTopBar` | `bool` | Exibe ou oculta a barra superior. |

## Fonte do documento

O widget segue esta prioridade:

1. Usa `documentoPDF.bytes` quando houver conteudo local.
2. Caso contrario, usa `pdfURL` se estiver preenchida.
3. Se nenhum dos dois estiver disponivel, mostra a mensagem `Nenhum PDF selecionado`.

## Recursos incluidos

- Controles de zoom in, zoom out e reset para `zoomLevel = 1.0`
- Rodape com pagina atual e total de paginas
- Painel lateral recolhivel com acoes visuais e callbacks
- Toolbar superior opcional com botao de fechar

## Observacoes

- O botao `fit_screen` do codigo atual redefine o zoom para `1.0`; ele nao executa um ajuste inteligente automatico ao viewport.
- `corHex` usa a cor primaria do tema como fallback se a string vier vazia ou invalida.
- Os callbacks `download`, `print` e `share` apenas disparam acoes externas; a logica dessas acoes deve ser implementada no FlutterFlow.
