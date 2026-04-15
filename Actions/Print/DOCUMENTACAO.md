# Print PDF Action

Custom Action para abrir o diálogo nativo de impressão a partir dos bytes de um PDF armazenado em `FFUploadedFile`.

## Dependências

Adicione no FlutterFlow:
- `printing`
- `pdf`

## Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `pdfFile` | `FFUploadedFile?` | Arquivo PDF que deve conter `bytes` válidos. |

## Como funciona

- Se `pdfFile` for nulo ou não tiver bytes, a action retorna uma mensagem de erro.
- Quando os bytes são válidos, ela chama `Printing.layoutPdf` e entrega o conteúdo diretamente ao sistema de impressão.

## Retorno

Retorna `String?`:

- `null` quando o diálogo de impressão é aberto com sucesso
- uma mensagem de erro quando o arquivo é inválido ou a impressão falha

## Observações

- A action não reconstrói o PDF; ela apenas envia os bytes recebidos para impressão.
- O sucesso depende do suporte à impressão no dispositivo e da disponibilidade do serviço nativo.
