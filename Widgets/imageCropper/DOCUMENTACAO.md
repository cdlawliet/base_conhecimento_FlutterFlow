# Image Cropper Widget

Widget de edição de imagem com recorte, anotações e exportação em múltiplos formatos. Suporta três modos de máscara — círculo, retângulo e corte livre por retângulo interativo — e um conjunto completo de ferramentas de anotação sobre a imagem.

## Dependências

Adicione no FlutterFlow:
- `flutter_image_compress`

---

## Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|:-----------:|-----------|
| `width` | `double?` | — | Largura do widget. |
| `height` | `double?` | — | Altura do widget. |
| `imageFile` | `FFUploadedFile` | ✅ | Imagem de entrada — deve conter `bytes`. Use *Uploaded Local File (Bytes)*. |
| `cropShape` | `String` | ✅ | Formato do corte: `"circle"`, `"rectangle"` ou `"freeform"`. |
| `aspectRatio` | `double?` | — | Proporção `w/h` do recorte em modo `rectangle`. Ex: `1.0`, `1.3333` (4:3), `1.7778` (16:9). Ignorado nos outros modos. |
| `minZoom` | `double?` | — | Mantido por compatibilidade. Sem efeito prático. |
| `maxZoom` | `double?` | — | Mantido por compatibilidade. Sem efeito prático. |
| `backgroundMaskOpacity` | `double?` | — | Opacidade da área externa à máscara, de `0.0` a `0.95`. Padrão: `0.65`. |
| `confirmButtonColor` | `Color` | ✅ | Cor do cabeçalho e do botão Confirmar. Determina automaticamente a cor do texto (auto-contraste). |
| `cropImageOnSave` | `bool` | — | Se `true`, exporta a imagem já recortada para o enquadramento da moldura. **Ignorado no modo `freeform`** — o recorte é definido pelo retângulo interativo. Padrão: `false`. |
| `onConfirm` | `Future Function(...)` | ✅ | Callback executado ao confirmar ou cancelar. Ver seção abaixo. |

---

## Modos de corte (`cropShape`)

### `"circle"`
Exibe uma moldura circular fixa sobre a imagem. O usuário pode movimentar e fazer zoom para enquadrar o conteúdo dentro do círculo. Ao exportar com `cropImageOnSave = true`, aplica clip oval.

### `"rectangle"`
Exibe uma moldura retangular com canto arredondado. O `aspectRatio` controla a proporção. Ao exportar com `cropImageOnSave = true`, recorta para o retângulo.

### `"freeform"` — Corte livre (Retângulo Interativo)
Exibe uma moldura retangular com alças (handles) nos cantos e laterais para ajuste de corte livre (sem proporção fixa).

**Comportamento específico:**
- **Zoom desabilitado** neste modo.
- **Ferramenta de corte** é ativada/desativada via ícone de crop (`Icons.crop` / `Icons.crop_free`) na barra superior (cabeçalho).
- Quando **Ajustando corte** (ícone `Icons.crop_free` destacado com fundo contrastante):
  - Exibe as alças de arraste nos cantos (L-shaped) e nas laterais da moldura.
  - O usuário pode arrastar os cantos e bordas para redimensionar o retângulo de corte, ou arrastar a área interna para mover a caixa de seleção.
  - O pan da imagem de fundo fica bloqueado.
  - Exibe o botão **"Aplicar corte"** (`Icons.check_circle_outline`) também em estado destacado.
- **Aplicar corte** (in-memory):
  - Recorta a imagem imediatamente em memória.
  - Desativa a ferramenta de corte automaticamente e muda o modo para **Anotação**.
  - Reposiciona e centraliza a imagem resultante na tela.
  - Desloca automaticamente quaisquer anotações que o usuário já tenha desenhado para manter o alinhamento correto.
- Quando **Navegando/Anotando** (ferramenta de corte desativada):
  - Oculta as alças de arraste da moldura.
  - O usuário pode alternar entre mover a imagem de fundo (modo pan) ou desenhar sobre a imagem usando todas as ferramentas de marcação.
- A máscara escurece a área **fora** do retângulo de seleção em tempo real (visível apenas enquanto ajusta o corte).
- **Resetar**: refaz o enquadramento inicial e recria a seleção de corte quando a ferramenta de corte está ativa. Após **Aplicar corte**, a imagem em memória passa a ser a versão recortada.
- **Exportação**: salva a imagem recortada exatamente na área de seleção, sem bordas transparentes ou fundos extras.
- `cropImageOnSave` é ignorado neste modo (o corte é sempre aplicado).
- `focusX` e `focusY` retornam `0.0` neste modo.

---

## Ferramentas de anotação

Disponíveis em todos os modos (`circle`, `rectangle` e `freeform` — após aplicar o corte ou desativar o ajuste).

| Ferramenta | Descrição |
|------------|-----------|
| **Livre** | Desenho à mão livre seguindo o toque. |
| **Retângulo** | Arraste para definir um retângulo. |
| **Círculo** | Arraste para definir uma elipse. |
| **Seta** | Arraste do ponto de origem ao destino. Desenha linha + cabeça de seta preenchida proporcional ao tamanho do pincel. |
| **Borracha** | Apaga pixels das anotações anteriores com `BlendMode.clear`. |

**Controles adicionais:**
- **Cor do traço** — 6 opções de cor rápida.
- **Paleta vibrante** — vermelho, verde, azul, magenta, violeta e amarelo com contorno automático para manter contraste no cabeçalho.
- **Espessura do pincel** — slider de 1 a 30 px.
- **Desfazer** — remove a última anotação adicionada.
- **Limpar tudo** — apaga todas as anotações.
- **Resetar** — reposiciona a imagem para o enquadramento inicial (cobrindo a moldura).
- **Toggle Mover / Anotar** — alterna entre modo pan/zoom e modo de desenho.
- Os ícones ativos da barra superior usam fundo contrastante para continuar visíveis em cores claras, como amarelo.

---

## Controles de saída

Disponíveis em todos os modos.

| Controle | Opções | Padrão |
|----------|--------|--------|
| Formato | `PNG`, `JPG`, `WEBP` | `PNG` |
| Qualidade | 40–100 | 92 |

---

## Callback `onConfirm`

O callback recebe 5 argumentos nesta ordem:

| # | Nome | Tipo | Descrição |
|---|------|------|-----------|
| 1 | `editedImage` | `FFUploadedFile` | Arquivo resultante (processado ou original). |
| 2 | `focusX` | `double` | Alinhamento horizontal do enquadramento, de `-1.0` a `1.0`. `0.0` em `freeform`. |
| 3 | `focusY` | `double` | Alinhamento vertical do enquadramento, de `-1.0` a `1.0`. `0.0` em `freeform`. |
| 4 | `didConfirm` | `bool` | `true` ao confirmar, `false` ao cancelar. |
| 5 | `formatFile` | `String` | Extensão do formato selecionado: `"png"`, `"jpg"` ou `"webp"`. |

---

## Comportamentos importantes

- Se `cropImageOnSave = false` e o usuário não fizer nenhuma anotação (em `circle`/`rectangle`), o widget devolve o **arquivo original intocado** para preservar a qualidade máxima.
- Mesmo quando o arquivo original é devolvido, `focusX` e `focusY` são calculados corretamente.
- Ao **cancelar**, o callback retorna o arquivo original, `focusX = 0.0`, `focusY = 0.0` e `didConfirm = false`.
- `formatFile` reflete a seleção da UI, mesmo quando o arquivo original foi mantido sem reconversão.
- No modo `freeform`, confirmar enquanto a ferramenta de corte está ativa exporta a área atual do retângulo interativo. Se o corte já tiver sido aplicado, exporta a imagem recortada com as anotações.

---

## Observações

- Se `imageFile.bytes` estiver vazio, o widget exibe mensagem de erro na tela.
- A exportação usa `flutter_image_compress` após renderização em memória via `ui.PictureRecorder`.
- O limite de dimensão exportada é `4096 px` no maior lado em `freeform`, e `max(larguraOriginal, 2048)` nos outros modos — reduzido proporcionalmente se ultrapassado.
- A cabeça da seta escala proporcionalmente ao `strokeWidth` (mínimo 14 px, máximo 48 px).
