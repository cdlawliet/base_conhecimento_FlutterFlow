# Color Picker Custom Action

Custom Action híbrida baseada em `flex_color_picker` para seleção de cores com preview em tempo real. Pode abrir como bottom sheet ou dialog central, dependendo do fluxo da tela.

## Dependências

Adicione no FlutterFlow:
- `flex_color_picker`

## Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `context` | `BuildContext` | Contexto atual da página. |
| `rebuilpage` | `Future Function()` | Callback disparado sempre que a cor muda e também quando a action precisa restaurar a cor inicial após cancelamento. |
| `textheading` | `String?` | Título principal exibido no seletor. |
| `textSubHeading` | `String?` | Texto auxiliar exibido abaixo do título. |
| `width` | `double?` | Largura das amostras de cor. |
| `height` | `double?` | Altura das amostras de cor. |
| `borderRadius` | `double?` | Arredondamento das amostras. |
| `spacing` | `double?` | Espaçamento horizontal entre cores. |
| `runSpacing` | `double?` | Espaçamento vertical entre linhas. |
| `wheelDiameter` | `double?` | Diâmetro da roda de cor. |
| `wheelWidth` | `double?` | Espessura da roda de cor. |
| `enableprimary` | `bool?` | Exibe a aba de cores principais. |
| `enableaccent` | `bool?` | Exibe a aba de cores accent. |
| `enablebw` | `bool?` | Exibe a aba de preto e branco. |
| `enablecustom` | `bool?` | Exibe a aba de cores customizadas. |
| `enablewheel` | `bool?` | Exibe a roda de cor livre. |
| `initialColor` | `Color?` | Cor inicial e também fallback em caso de cancelamento. |
| `isBottomSheet` | `bool?` | Se `true`, abre como bottom sheet; caso contrário, abre como dialog. |
| `designColor` | `Color?` | Cor aplicada aos botões e detalhes visuais do componente. |

## Comportamento

- Enquanto o usuário interage, `rebuilpage()` é chamado para refletir a cor em tempo real na UI.
- No modo `dialog`, existem ações explícitas de `Cancelar` e `Confirmar`.
- No modo `bottom sheet`, a confirmação ocorre pelo botão `Confirmar`; se o modal for fechado sem confirmar, a cor é restaurada.
- Quando `initialColor` é nula, o fallback usado é `Color(0xFF4B39EF)`.

## Retorno

Retorna `Color?` com a cor final escolhida.

- Se o usuário confirmar, retorna a cor selecionada.
- Se cancelar ou fechar o seletor sem confirmar, retorna a `initialColor` ou o fallback padrão.
