# Base64 To Document Action

Converte uma string em Base64 para um `FFUploadedFile`, permitindo reutilizar o resultado em uploads, visualizadores de PDF, impressão ou compartilhamento dentro do FlutterFlow.

## Dependências

Nenhuma dependência extra além das imports padrão do FlutterFlow.

## Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `base64Data` | `String` | Conteúdo Base64 puro ou no formato Data URI, como `data:application/pdf;base64,...`. |
| `fileName` | `String` | Nome que será atribuído ao `FFUploadedFile` retornado. |

## Como funciona

A action faz dois passos simples:

1. Remove automaticamente o prefixo antes da vírgula caso a entrada venha como Data URI.
2. Decodifica os bytes e monta um `FFUploadedFile` com o nome informado.

## Retorno

Retorna um `FFUploadedFile` com:

- `name`: valor recebido em `fileName`
- `bytes`: conteúdo binário decodificado do Base64

## Observações

- A action não valida se o conteúdo representa PDF, imagem ou outro tipo de arquivo.
- A extensão do arquivo depende do valor passado em `fileName`.
- Se o Base64 estiver inválido, a decodificação lançará exceção.
