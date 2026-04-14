# 📄 Leitor de PDF (Syncfusion) Widget

Implementação premium baseada no pacote `syncfusion_flutter_pdfviewer`. Este widget resolve limitações de visualização de PDFs grandes e complexos, oferecendo uma experiência nativa e fluida tanto no Mobile quanto na Web.

## 📦 Dependências
Adicione no FlutterFlow:
- `syncfusion_flutter_pdfviewer`

## 🛠️ Parâmetros e Configurações

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `width` / `height` | `double?` | Dimensões do widget. Recomenda-se usar `double.infinity` para preencher o container pai. |
| `pdfURL` | `String?` | Link direto para o PDF (URL pública ou do Supabase/Firebase). |
| `documentoPDF` | `FFUploadedFile?` | Arquivo PDF em formato de bytes (Local State ou Upload direto). |
| `corHex` | `String?` | Cor do cabeçalho superior em formato HEX (ex: `#4B39EF`). |
| `showTopBar` | `bool` | **Novo:** Liga/Desliga a barra superior que contém o título e o botão de fechar. |
| `showDownloadIcon` | `bool` | Habilita o ícone de download no painel lateral. |
| `showPrintIcon` | `bool` | Habilita o ícone de impressão no painel lateral. |
| `showShareIcon` | `bool` | Habilita o ícone de compartilhamento no painel lateral. |

## ⚡ Actions (Callbacks)

| Action | Descrição |
|--------|-----------|
| `onClose` | Disparada ao clicar no "X" da barra superior. Geralmente usada para `Navigator.pop`. |
| `download` | Disparada ao clicar no ícone de download. Implemente a lógica de salvamento aqui. |
| `print` | Disparada ao clicar no ícone de impressão. |
| `share` | Disparada ao clicar no ícone de compartilhamento (conecte com a Action `ShareFile`). |

## 🚀 Funcionalidades Inclusas
- **Zoom Dinâmico:** Controles de Zoom In, Zoom Out e Fit Screen (Ajustar à tela).
- **Paginação:** Indicador de página atual e total de páginas no rodapé.
- **Visibilidade:** Botão "Olho" para ocultar/mostrar todas as ferramentas laterais de uma vez, limpando a visão do documento.
- **Suporte Híbrido:** Carrega automaticamente via URL ou Bytes dependendo de qual parâmetro for enviado.

> [!IMPORTANT]
> **Suporte Web:** Para garantir que o PDF carregue corretamente em navegadores (evitando erros de CORS ou renderização), certifique-se de que o arquivo `funcionar_web.js` (presente na pasta) esteja configurado se você estiver utilizando scripts customizados de carregamento.

## 🎨 Personalização
A cor da barra superior (Toolbar) respeita a `corHex` informada ou utiliza a `Primary Color` do seu tema FlutterFlow como fallback automático.
