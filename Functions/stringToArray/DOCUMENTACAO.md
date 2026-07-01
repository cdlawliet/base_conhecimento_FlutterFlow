# String To Array Function

Custom Function para converter uma string separada por virgulas em uma lista de strings.

## Assinatura

```dart
List<String> stringToArray(String? valor)
```

## Parametros

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `valor` | `String?` | Texto contendo itens separados por virgulas. |

## Retorno

Retorna uma `List<String>` com espacos extras removidos e itens vazios descartados.

## Exemplos

| Entrada | Saida |
|---------|-------|
| `01,02,03` | `['01', '02', '03']` |
| ` A, , B ` | `['A', 'B']` |
| `null` | `[]` |

## Observacoes

- A separacao e feita apenas por virgula.
- Ideal para transformar parametros salvos como texto em listas reutilizaveis no FlutterFlow.
