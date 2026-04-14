# ✂️ Image Cropper Widget

Um Widget avançado e ultra-responsivo para edição de imagens. Permite visualizar, aplicar zoom dinâmico por gestos, desenhar anotações e realizar o recorte final com suporte a transparência e múltiplos formatos (WebP, PNG, JPG).

## 📦 Dependências
Adicione no FlutterFlow:
- `flutter_image_compress`

## 🛠️ Parâmetros Principais

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `imageFile` | `FFUploadedFile` | O arquivo binário bruto capturado pela câmera ou galeria. |
| `cropShape` | `String` | Define o formato da máscara: `"circle"` (círculo) ou `"rectangle"` (retângulo). |
| `aspectRatio` | `double?` | Proporção do recorte (ex: `1.0` para quadrado, `16/9`, `4/3`). Apenas para o modo retângulo. |
| `backgroundMaskOpacity` | `double?` | Opacidade da área externa ao recorte (0.0 a 1.0). Default: `0.65`. |
| `confirmButtonColor` | `Color` | Cor do botão de confirmação e da barra de ferramentas superior. |
| `cropImageOnSave` | `bool` | Se `true`, a imagem será fisicamente recortada no formato da máscara ao salvar. Se `false`, apenas as coordenadas centrais (Focus X/Y) são retornadas. |

## 🖌️ Ferramentas de Edição (Anotação)
O widget possui uma barra de ferramentas superior que permite alternar entre o modo **Mover** (zoom/pan) e o modo **Anotar**:
- **Livre (Pen):** Desenho à mão livre.
- **Retângulo/Círculo:** Inserir formas geométricas sobre a imagem.
- **Borracha:** Apagar anotações específicas.
- **Cores:** Paleta para mudar a cor do pincel.
- **Pincel:** Slider para ajustar a espessura do traço.

## 💾 Configurações de Output
O usuário pode escolher o formato de saída no momento da edição:
- **PNG:** Mantém transparência (ideal para círculos), porém gera arquivos maiores.
- **JPG:** Alta compressão, ideal para fotos sem necessidade de transparência.
- **WEBP:** O melhor equilíbrio entre qualidade, transparência e tamanho reduzido.

## ⚡ Callback: `onConfirm`
A action retorna 5 argumentos essenciais:
1. `editedImage` (FFUploadedFile): A imagem final processada (com anotações e recortes).
2. `focusX` (double): Coordenada X centralizada (-1 a 1) para enquadramento posterior.
3. `focusY` (double): Coordenada Y centralizada (-1 a 1).
4. `didConfirm` (bool): `true` se o usuário clicou em confirmar, `false` se cancelou.
5. `formatFile` (String): O formato escolhido (`png`, `jpg` ou `webp`).

> [!TIP]
> **Preservação de Qualidade:** Se `cropImageOnSave` for `false` e nenhuma anotação for feita, o widget retorna o arquivo original sem recomprensão, preservando 100% da qualidade original.
