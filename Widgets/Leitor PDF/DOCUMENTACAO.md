# Leitor de PDF (Syncfusion)

Widget de visualização de PDF baseado em `syncfusion_flutter_pdfviewer`, com toolbar opcional, paginação, zoom e ações laterais configuráveis.

## Dependências

Adicione no FlutterFlow:
- `syncfusion_flutter_pdfviewer`

## Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `width` | `double?` | Largura do widget. |
| `height` | `double?` | Altura do widget. |
| `pdfURL` | `String?` | URL pública do PDF para carregamento remoto. |
| `documentoPDF` | `FFUploadedFile?` | PDF em bytes para carregamento local. |
| `corHex` | `String?` | Cor da toolbar em HEX, por exemplo `#1565C0`. |
| `onClose` | `Future Function()?` | Callback ao clicar em fechar. Se não for informado, o widget executa `Navigator.pop(context)`. |
| `download` | `Future Function()?` | Callback do botão de download. |
| `print` | `Future Function()?` | Callback do botão de impressão. |
| `share` | `Future Function()?` | Callback do botão de compartilhamento. |
| `showDownloadIcon` | `bool` | Exibe ou oculta o botão de download. |
| `showPrintIcon` | `bool` | Exibe ou oculta o botão de impressão. |
| `showShareIcon` | `bool` | Exibe ou oculta o botão de compartilhamento. |
| `showTopBar` | `bool` | Exibe ou oculta a barra superior. |

## Fonte do documento

O widget segue esta prioridade:

1. Usa `documentoPDF.bytes` quando houver conteúdo local.
2. Caso contrário, usa `pdfURL` se estiver preenchida.
3. Se nenhum dos dois estiver disponível, mostra a mensagem `Nenhum PDF selecionado`.

## Recursos incluídos

- Controles de zoom in, zoom out e reset para `zoomLevel = 1.0`
- Rodapé com página atual e total de páginas
- Painel lateral recolhível com ações visuais e callbacks
- Toolbar superior opcional com botão de fechar

## Observações

- O botão `fit_screen` do código atual redefine o zoom para `1.0`; ele não executa um ajuste inteligente automático ao viewport.
- `corHex` usa a cor primária do tema como fallback se a string vier vazia ou inválida.
- Os callbacks `download`, `print` e `share` apenas disparam ações externas; a lógica dessas ações deve ser implementada no FlutterFlow.
