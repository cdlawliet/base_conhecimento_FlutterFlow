# Gera Recibo Action

Custom Action para gerar um recibo de pagamento em PDF profissional, no formato A5 em paisagem (Landscape), retornando o arquivo pronto como `FFUploadedFile`.

O recibo conta com um design moderno e elegante (paleta Slate/Teal), badge destacado com o valor formatado, texto principal com partes em negrito (utilizando `RichText` do pacote `pdf`), representação do valor por extenso em português do Brasil, e marca d'água de logotipo opaca opcional.

## Dependências

Adicione no FlutterFlow em **Custom Code > Custom Actions > Dependencies**:

- `pdf`
- `http`

## Assinatura

```dart
Future<FFUploadedFile> geraRecibo(
  String logo,
  String cliente,
  double valor,
  String motivo,
  String? assinatura,
)
```

## Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `logo` | `String` | URL da logomarca da empresa. Ficará centralizada ao fundo como marca d'água com 10% de opacidade. Se falhar no carregamento ou for vazia, o recibo é gerado normalmente sem a logo. |
| `cliente` | `String` | Nome completo do cliente que realizou o pagamento. |
| `valor` | `double` | Valor do recebimento. A action formata em Reais (`R$ 1.234,56`) e insere o valor por extenso automaticamente. |
| `motivo` | `String` | Descrição do pagamento (ex: `Mensalidade Escolar`, `Serviços de Desenvolvimento`). |
| `assinatura` | `String` | String Base64 contendo a imagem da assinatura. Se nula ou vazia, o recibo é gerado sem a imagem da assinatura. |

## Retorno

Retorna um `FFUploadedFile` com os seguintes atributos:

| Campo | Valor |
|-------|-------|
| `name` | `recibo_pagamento.pdf` |
| `bytes` | Bytes do PDF gerado (prontos para impressão, compartilhamento ou upload) |

## Texto Gerado (Formatado)

O texto do recibo é construído usando formatação rica (`RichText`), onde os dados principais ficam em negrito:

> "Confirmamos o recebimento da importância de **R$ 1.500,00 (mil e quinhentos reais)**, paga por **[Nome do Cliente]**, referente a **[Motivo do Pagamento]**, pelo que damos plena, geral e irrevogável quitação."

## Como Configurar no FlutterFlow

1. No menu lateral, acesse **Custom Code** e clique em **Add > Custom Action**.
2. Defina o nome da action como `geraRecibo`.
3. Configure os **Define Arguments** exatamente como abaixo:
   - `logo` -> Tipo: `String` (nullable/não-obrigatório se desejar, mas o parâmetro deve ser passado)
   - `cliente` -> Tipo: `String`
   - `valor` -> Tipo: `Double`
   - `motivo` -> Tipo: `String`
   - `assinatura` -> Tipo: `String` (nullable/não-obrigatório)
4. Configure o **Action Return Value**:
   - Marque **Has Return Value** -> Ativo.
   - Selecione **Type** -> `Uploaded File (Bytes)`.
5. Em **dependencies**, adicione os pacotes `pdf` e `http`.
6. Copie o código de [geraRecibo.dart](file:///d:/OneDrive/Documentos/Projetos%20FlutterFlow/Actions/geraRecibo/geraRecibo.dart) e cole no editor do FlutterFlow.
7. Clique em **Save Action** e compile o código para validar.

## Detalhes Visuais e de Design

- **Layout e Margens**: Formato A5 em Paisagem com 20pt de margem, perfeito para visualização móvel ou impressão compacta.
- **Identidade Visual**: Barra superior em Teal (`#0D9488`), bordas arredondadas e textos estruturados em tons de Slate para máxima sofisticação.
- **Segurança ao Carregar a Logo**: A imagem da logomarca é carregada assincronamente através de requisição HTTP e convertida para bytes. Caso ocorra erro de CORS, rede ou formato incompatível, a exceção é capturada internamente e o documento é gerado perfeitamente sem a marca d'água, prevenindo quebras em produção.
