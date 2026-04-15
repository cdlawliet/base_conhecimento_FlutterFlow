# Image Cropper Widget

Widget de edição de imagem com recorte, anotações e exportação em múltiplos formatos. Foi pensado para fluxos em que o usuário precisa ajustar enquadramento, desenhar por cima da imagem e receber um `FFUploadedFile` final já processado.

## Dependências

Adicione no FlutterFlow:
- `flutter_image_compress`

## Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `width` | `double?` | Largura do widget. |
| `height` | `double?` | Altura do widget. |
| `imageFile` | `FFUploadedFile` | Imagem de entrada, obrigatoriamente com `bytes`. |
| `cropShape` | `String` | Formato da máscara: `circle` ou `rectangle`. |
| `aspectRatio` | `double?` | Proporção do recorte em modo retangular. |
| `minZoom` | `double?` | Mantido por compatibilidade, sem efeito prático no zoom atual. |
| `maxZoom` | `double?` | Mantido por compatibilidade, sem efeito prático no zoom atual. |
| `backgroundMaskOpacity` | `double?` | Opacidade da área externa à máscara, de `0.0` a `0.95`. |
| `confirmButtonColor` | `Color` | Cor do cabeçalho e do botão principal. |
| `cropImageOnSave` | `bool` | Se `true`, exporta a imagem já recortada para o enquadramento selecionado. |
| `onConfirm` | `Future Function(...)` | Callback executado ao confirmar ou cancelar. |

## Ferramentas disponíveis

- Modo mover com pan e zoom livre
- Modo anotação com desenho livre, retângulo, círculo e borracha
- Desfazer última anotação
- Limpar todas as anotações
- Resetar enquadramento inicial
- Escolher cor do traço
- Ajustar espessura do pincel
- Escolher formato de saída entre `PNG`, `JPG` e `WEBP`
- Ajustar qualidade de compressão

## Callback `onConfirm`

O callback recebe 5 argumentos nesta ordem:

1. `editedImage` (`FFUploadedFile`)
2. `focusX` (`double`)
3. `focusY` (`double`)
4. `didConfirm` (`bool`)
5. `formatFile` (`String`)

## Comportamento importante

- Se `cropImageOnSave` for `false` e o usuário não fizer nenhuma anotação, o widget devolve o arquivo original para preservar qualidade.
- Mesmo quando o arquivo original é devolvido, `focusX` e `focusY` continuam sendo calculados com base no enquadramento.
- Ao cancelar, o callback retorna o arquivo original, `focusX = 0.0`, `focusY = 0.0` e `didConfirm = false`.
- O formato retornado em `formatFile` reflete a seleção atual da UI, mesmo que o arquivo original tenha sido mantido sem reconversão.

## Observações

- Se `imageFile.bytes` estiver vazio, o widget exibe erro em tela.
- O recorte circular aplica clip oval apenas quando `cropImageOnSave` está ativo.
- A exportação usa `flutter_image_compress` após renderizar a imagem em memória.
