# Conversoes String Functions

Conjunto de Custom Functions para limpar e formatar strings usadas em formularios, filtros e parametros de API.

## Funcoes Disponiveis

### alphaNumeric

Remove todos os caracteres que nao sejam letras ou numeros.

```dart
String? alphaNumeric(String? inputString)
```

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `inputString` | `String?` | Texto original com ou sem mascara. |

Exemplos:

| Entrada | Saida |
|---------|-------|
| `123.456.789-00` | `12345678900` |
| `(11) 91234-5678` | `11912345678` |
| `AB-123 CD` | `AB123CD` |

### applyMask

Aplica mascaras conhecidas para CEP, telefone e placa.

```dart
String applyMask(
  String? data,
  String? type,
)
```

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `data` | `String?` | Texto original, com ou sem mascara. |
| `type` | `String?` | Tipo de mascara: `cep`, `telefone` ou `placa`. |

Formatos suportados:

| Tipo | Entrada esperada | Saida |
|------|------------------|-------|
| `cep` | 8 digitos numericos | `00.000-000` |
| `telefone` | 10 ou 11 digitos numericos | `(00) 0000-0000` ou `(00) 0 0000-0000` |
| `placa` | 7 caracteres alfanumericos | `AAA-0000` ou `AAA-0A00` |

## Observacoes

- Quando o valor nao atende ao formato esperado, a funcao retorna o texto original.
- `applyMask` remove mascaras anteriores antes de aplicar a nova formatacao.
- `alphaNumeric` retorna string vazia quando a entrada e nula ou vazia.
