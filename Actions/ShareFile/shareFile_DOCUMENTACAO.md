# Share File Action

Action de compartilhamento multiplataforma baseada em `share_plus`, preparada para trabalhar com `FFUploadedFile` no FlutterFlow.

## Dependências

Adicione no FlutterFlow:
- `share_plus`
- `path_provider`

## Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `file` | `FFUploadedFile` | Arquivo contendo os bytes que serão compartilhados. |
| `fileName` | `String` | Nome base do arquivo. O código atual adiciona `.pdf` automaticamente. |

## Como funciona

- Se `file.bytes` estiver vazio ou nulo, a action lança exceção.
- Na Web, o compartilhamento é feito com `XFile.fromData`, sem gravar arquivo em disco.
- Em Android, iOS e desktop, o arquivo é salvo temporariamente em cache antes do compartilhamento.

## Comportamento atual

O código está fixado para PDF:

- o nome final sempre vira `${fileName}.pdf`
- o MIME type sempre é `application/pdf`
- o texto compartilhado é `Pedido CD Tecnologia`
- o assunto é `Compartilhando pedido`

## Retorno

A action é assíncrona e não retorna valor útil. Em caso de erro, faz `rethrow` após registrar a falha no log.

## Observações

- Para compartilhar outros tipos de arquivo, o código precisa ser ajustado para receber extensão, MIME type, texto e assunto de forma dinâmica.
- Como o arquivo temporário é criado no cache, o sistema operacional pode removê-lo depois.
