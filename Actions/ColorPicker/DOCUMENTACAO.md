# 🎨 Color Picker Custom Action

Uma Custom Action híbrida e premium que abre uma interface rica de seleção de cores baseada no ecossistema `flex_color_picker`. Projetada para oferecer uma experiência de usuário (UX) fluida com atualizações em tempo real.

## 📦 Dependências
Para funcionar, adicione no FlutterFlow:
- `flex_color_picker`

## 🛠️ Parâmetros e Inputs

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `context` | `BuildContext` | Contexto do app (automático no FF). |
| `rebuilpage` | `Future Function()` | **Crucial:** Callback invocado a cada micro-mudança na cor para atualizar a UI do app em tempo real. |
| `textheading` | `String?` | Título principal do seletor (ex: "Escolha a Cor"). |
| `textSubHeading` | `String?` | Subtítulo descritivo. |
| `width` / `height` | `double?` | Dimensões de cada "box" de cor. |
| `borderRadius` | `double?` | Arredondamento dos boxes de cor. |
| `spacing` / `runSpacing` | `double?` | Espaçamento entre os itens da grade de cores. |
| `wheelDiameter` | `double?` | Diâmetro da roda de cores (Livre). |
| `wheelWidth` | `double?` | Espessura da borda da roda de cores. |
| `enableprimary` | `bool?` | Habilita aba de cores principais (Material). |
| `enableaccent` | `bool?` | Habilita aba de cores de destaque. |
| `enablebw` | `bool?` | Habilita aba de tons de cinza (Preto e Branco). |
| `enablecustom` | `bool?` | Habilita cores customizadas. |
| `enablewheel` | `bool?` | Habilita a roda de cores livre. |
| `initialColor` | `Color?` | Cor inicial ao abrir. Em caso de *Cancel*, o sistema reverte para esta cor. |
| `isBottomSheet` | `bool?` | **Modo Visual:** <br>• `true`: Abre como gaveta inferior (Mobile friendly).<br>• `false`: Abre como Dialog central suspenso. |
| `designColor` | `Color?` | Cor temática aplicada aos botões de ação e barras de ajuste. |

## 🚀 Como Funciona
A ação utiliza um `await` para aguardar a decisão do usuário. Enquanto o modal está aberto, cada movimento no seletor dispara o `rebuilpage()`, permitindo que você veja o impacto da cor em outros elementos da tela instantaneamente.

> [!TIP]
> Use o `rebuilpage` para atualizar uma variável de Local State e vincular essa cor a componentes de fundo ou botões, criando um efeito de customização extremamente elegante.

## 📥 Retorno
Retorna um objeto `Color?`. Se o usuário clicar em **Confirmar**, retorna a cor selecionada. Se clicar em **Cancelar** ou fechar sem confirmar, retorna a `initialColor` original para manter a integridade do estado.
