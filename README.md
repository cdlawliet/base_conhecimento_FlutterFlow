# Base de Conhecimento FlutterFlow

Bem-vindo à minha base de conhecimento de componentes e ações customizadas para **FlutterFlow**. Este repositório reúne widgets e actions reutilizáveis, com documentação prática para acelerar integrações, visualização de arquivos e fluxos de edição.

---

## O que há dentro?

### Custom Actions
- **[API Response Document](Actions/apiResponseDocument/DOCUMENTACAO.md)**: Converte uma resposta binaria recebida como `String` em `FFUploadedFile`, mantendo o nome de arquivo informado.
- **[Base64 To Document](Actions/base64ToDocument/DOCUMENTACAO.md)**: Converte uma string Base64 em `FFUploadedFile`, pronta para salvar, compartilhar, imprimir ou exibir.
- **[Color Picker](Actions/ColorPicker/DOCUMENTACAO.md)**: Seletor de cores híbrido com atualização em tempo real e suporte a roda de cores.
- **[Force App Refresh](Actions/ForceAppRefresh/DOCUMENTACAO.md)**: Limpa caches em runtime e forca recarregamento no Web, com limpeza complementar no Android/iOS.
- **[Gera Recibo](Actions/geraRecibo/DOCUMENTACAO.md)**: Gera um recibo de pagamento em PDF profissional no formato A5 em paisagem, com marca d'água de logo, formatação monetária e valor por extenso automáticos.
- **[Relatorio PDF](Actions/relatorio_pdf/DOCUMENTACAO.md)**: Gera um PDF tabular dinamico a partir de um JSON e retorna `FFUploadedFile`.
- **[Share File](Actions/ShareFile/shareFile_DOCUMENTACAO.md)**: Compartilhamento multiplataforma de PDFs a partir de `FFUploadedFile`.
- **[Print PDF](Actions/Print/DOCUMENTACAO.md)**: Aciona o diálogo nativo de impressão a partir dos bytes de um PDF.

### Custom Widgets
- **[Leitor de PDF (Syncfusion)](Widgets/Leitor PDF/DOCUMENTACAO.md)**: Visualizador de PDF com zoom, paginação e ações opcionais de download, impressão e compartilhamento.
- **[Image Cropper](Widgets/imageCropper/DOCUMENTACAO.md)**: Editor de imagem com recorte, anotações, exportação em múltiplos formatos e retorno de foco.

### Custom Functions
- **[Array To String](Functions/arrayToString/DOCUMENTACAO.md)**: Converte uma lista de strings (`List<String>`) em uma única string unida por vírgulas.
- **[Conversoes String](Functions/conversoesString/DOCUMENTACAO.md)**: Remove caracteres não alfanuméricos e aplica máscaras dinâmicas de CEP, Telefone e Placa em strings.
- **[String To Array](Functions/stringToArray/DOCUMENTACAO.md)**: Converte uma string separada por vírgulas em uma lista de strings (`List<String>`), removendo espaços extras.

---

## Configuração rápida

Cada diretório possui seu próprio arquivo de documentação contendo:
- Dependências necessárias no FlutterFlow.
- Tabela de parâmetros e callbacks.
- Observações de uso e limitações atuais.

---

## Contribuições

Este é um repositório pessoal, mas sinta-se à vontade para fazer um fork ou abrir uma issue se encontrar algum bug ou tiver sugestões de melhoria.

---

## Licença

Este projeto é de uso livre para a comunidade FlutterFlow.
