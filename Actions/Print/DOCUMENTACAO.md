# 🖨️ Print PDF Action

Uma Custom Action essencial para envio de documentos PDF diretamente para a fila de impressão nativa do sistema operacional (Android, iOS, Web, macOS, Windows).

## 📦 Dependências
Adicione no FlutterFlow:
- `printing`
- `pdf`

## 🛠️ Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `pdfFile` | `FFUploadedFile?` | O arquivo do PDF a ser impresso. Deve conter o array de bytes (`bytes`). |

## 🚀 Como Funciona
A ação tenta ler os bytes contidos na variável `FFUploadedFile`. Caso os bytes sejam válidos, ela aciona o pacote `printing`, que evoca a tela de spooler/diálogo de impressão nativo do dispositivo.

## 📥 Retorno
Retorna uma `String?` contendo a mensagem de erro em caso de falha, ou `null` se a impressão for chamada com sucesso.

> [!TIP]
> Caso você passe essa action em um fluxo, você pode checar se o retorno da Action possui algum valor (is set and not empty). Se houver, você pode exibir num SnackBar para o usuário informando que ocorreu uma falha de impressão!
