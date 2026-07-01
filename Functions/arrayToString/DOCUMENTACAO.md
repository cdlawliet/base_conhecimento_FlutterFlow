# Array To String Function

Custom Function para converter uma lista de strings em uma unica string separada por virgulas.

## Assinatura

```dart
String arrayToString(List<String>? valores)
```

## Parametros

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `valores` | `List<String>?` | Lista de textos que sera normalizada e unida. |

## Retorno

Retorna uma `String` com os itens separados por virgula. Itens vazios sao descartados e espacos extras nas extremidades sao removidos.

## Exemplos

| Entrada | Saida |
|---------|-------|
| `['01', '02', '03']` | `01,02,03` |
| `[' A ', '', 'B']` | `A,B` |
| `null` | string vazia |

## Observacoes

- A funcao nao adiciona espaco depois da virgula.
- Ideal para salvar selecoes multiplas em campos de texto ou preparar parametros simples para API.
