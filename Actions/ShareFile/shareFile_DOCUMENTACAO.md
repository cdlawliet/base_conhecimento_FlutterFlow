# 🔗 Share File Action

Ação focada de compartilhamento assíncrono universal multiplataforma, baseada na biblioteca `share_plus`. Desenvolvida para garantir que o compartilhamento funcione tanto na Web quanto em dispositivos nativos sem erros de sistema de arquivos.

## 📦 Dependências
Adicione no FlutterFlow:
- `share_plus`
- `path_provider`

## 🛠️ Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `file` | `FFUploadedFile` | Os bytes brutos do arquivo (PDF, Imagem, etc.) a serem compartilhados. |
| `fileName` | `String` | Nome sugerido para o arquivo (ex: "Pedido_123"). **Nota:** A extensão `.pdf` é adicionada automaticamente no código atual. |

## 🌐 Lógica multiplataforma

Esta action resolve a diferença drástica entre como a Web e o Mobile lidam com arquivos:

- **Web (Chrome/Safari/Edge):** Utiliza `kIsWeb` para converter os bytes diretamente em um `XFile.fromData`. Isso abre a gaveta de compartilhamento do navegador ou inicia o download sem tentar salvar no disco rígido do usuário, evitando erros de permissão.
- **Nativo (Android/iOS):** Utiliza o `path_provider` para salvar temporariamente o arquivo no diretório de cache do aplicativo (`getTemporaryDirectory`) e então compartilha o caminho (path) desse arquivo. Isso garante máxima compatibilidade com apps como WhatsApp e E-mail.

> [!IMPORTANT]
> O código atual força a extensão `.pdf`. Se precisar compartilhar outros tipos de arquivo, a linha `final fullFileName = '${fileName}.pdf';` deve ser ajustada para aceitar a extensão dinamicamente ou detectar o mimetype.

## 🚀 Como Usar
Basta chamar a action passando o `FFUploadedFile` capturado ou gerado anteriormente e definir um nome para o arquivo. A action cuidará do resto, garantindo que o usuário veja a interface de compartilhamento nativa do sistema operacional dele.
