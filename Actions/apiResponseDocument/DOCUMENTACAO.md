# API Response Document Action

Custom Action para transformar uma resposta binaria recebida como `String` em um arquivo `FFUploadedFile`, mantendo o nome informado para uso posterior no FlutterFlow.

## Dependencias

Esta action usa apenas os imports padrao do FlutterFlow. Nao e necessario adicionar pacotes externos.

## Assinatura

```dart
Future<FFUploadedFile> apiResponseDocument(
  String binaryData,
  String fileName,
)
```

## Parametros

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `binaryData` | `String` | Conteudo binario recebido como string. A action converte os `codeUnits` para bytes. |
| `fileName` | `String` | Nome do arquivo retornado, incluindo a extensao desejada, como `documento.pdf`. |

## Retorno

Retorna um `FFUploadedFile` com:

| Campo | Valor |
|-------|-------|
| `name` | Valor recebido em `fileName` |
| `bytes` | Bytes gerados a partir de `binaryData.codeUnits` |

## Como Configurar no FlutterFlow

1. Acesse **Custom Code > Custom Actions** e crie uma action chamada `apiResponseDocument`.
2. Configure os argumentos:
   - `binaryData` -> Tipo: `String`
   - `fileName` -> Tipo: `String`
3. Configure o **Action Return Value**:
   - Marque **Has Return Value** -> Ativo.
   - Selecione **Type** -> `Uploaded File (Bytes)`.
4. Copie o codigo de [apiResponseDocument.dart](apiResponseDocument.dart) para o editor do FlutterFlow.
5. Salve e compile a action.

## Observacoes

- Use esta action quando a API retornar um conteudo binario preservado como string.
- Para respostas em Base64, prefira a action [Base64 To Document](../base64ToDocument/DOCUMENTACAO.md).
- Em caso de erro na conversao, a action lanca uma excecao com a mensagem original.
