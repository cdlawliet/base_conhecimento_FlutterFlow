# Relatorio PDF Action

Custom Action para gerar um PDF tabular dinamico a partir de um JSON e retornar o arquivo como `FFUploadedFile`.

A action monta um relatorio com tres areas principais:

- `head`: cabecalho com linhas e colunas de texto.
- `body`: tabela principal, com colunas, linhas, grade, zebra e rodape da tabela.
- `footer`: rodape tradicional com linhas e colunas de texto.

## Dependencias

Adicione no FlutterFlow:

- `pdf`

## Assinatura

```dart
Future<FFUploadedFile> relatorios(dynamic dadosRelatorio)
```

## Parametros

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `dadosRelatorio` | `dynamic` / JSON | Objeto com as configuracoes e os dados usados para montar o PDF. |

## Retorno

Retorna um `FFUploadedFile` com:

| Campo | Valor |
|-------|-------|
| `name` | `relatorio.pdf` |
| `bytes` | Bytes do PDF gerado |

Esse retorno pode ser usado em outras actions, por exemplo:

- imprimir o PDF;
- compartilhar o arquivo;
- salvar no storage;
- exibir em um leitor de PDF.

## Formato esperado do JSON

Estrutura geral:

```json
{
  "orientation": "portrait",
  "head": [],
  "body": {},
  "footer": []
}
```

Todos os blocos sao opcionais, mas normalmente o relatorio usa pelo menos o bloco `body`.

Campos gerais aceitos na raiz do JSON:

| Campo | Tipo | Obrigatorio | Padrao | Descricao |
|-------|------|-------------|--------|-----------|
| `orientation` | `String` | Nao | `portrait` | Orientacao da pagina: `portrait` ou `landscape`. |

Tambem e possivel informar a orientacao dentro de `page.orientation`:

```json
{
  "page": {
    "orientation": "landscape"
  },
  "body": {}
}
```

Se `orientation` e `page.orientation` forem enviados ao mesmo tempo, a action usa o valor de `orientation`.

## Orientacao da pagina

Por padrao, o PDF e gerado em A4 retrato:

```json
{
  "orientation": "portrait"
}
```

Para gerar o PDF em A4 paisagem:

```json
{
  "orientation": "landscape"
}
```

Use `landscape` quando o relatorio tiver muitas colunas ou quando os textos das celulas precisarem de mais espaco horizontal.

## Bloco `head`

O `head` representa o cabecalho do relatorio. Ele deve ser uma lista de linhas, e cada linha possui uma lista de colunas.

```json
{
  "orientation": "landscape",
  "head": [
    {
      "columns": [
        {
          "text": "Minha Empresa",
          "alignment": "left",
          "fontSize": 14,
          "fontStyle": "bold"
        },
        {
          "text": "Relatorio de Vendas",
          "alignment": "right",
          "fontSize": 12
        }
      ]
    }
  ]
}
```

Campos aceitos em cada coluna do `head`:

| Campo | Tipo | Obrigatorio | Padrao | Descricao |
|-------|------|-------------|--------|-----------|
| `text` | `String` | Nao | `""` | Texto exibido na coluna. |
| `alignment` | `String` | Nao | `left` | Alinhamento: `left`, `center` ou `right`. |
| `fontSize` | `num` | Nao | `12` | Tamanho da fonte. |
| `fontStyle` | `String` | Nao | normal | Estilo: `bold` ou `italic`. |

Observacao: cada item em `columns` ocupa uma fracao igual da largura disponivel.

## Bloco `body`

O `body` representa a tabela principal do PDF.

```json
{
  "orientation": "portrait",
  "body": {
    "columns": [
      {
        "name": "Produto",
        "alignment": "left"
      },
      {
        "name": "Qtd",
        "alignment": "center"
      },
      {
        "name": "Total",
        "alignment": "right"
      }
    ],
    "rows": [
      {
        "Produto": "Teclado",
        "Qtd": 2,
        "Total": "R$ 180,00"
      },
      {
        "Produto": "Mouse",
        "Qtd": 1,
        "Total": "R$ 90,00"
      }
    ],
    "bodyFooter": [
      "Total geral",
      "3",
      "R$ 270,00"
    ],
    "showGrid": true,
    "zebra": {
      "enabled": true,
      "color": "#EEEEEE"
    }
  }
}
```

Campos aceitos no `body`:

| Campo | Tipo | Obrigatorio | Padrao | Descricao |
|-------|------|-------------|--------|-----------|
| `columns` | `List` | Sim | - | Colunas da tabela. |
| `rows` | `List` | Sim | - | Linhas da tabela. |
| `bodyFooter` | `List` | Nao | - | Linha final em negrito abaixo da tabela principal. |
| `showGrid` | `bool` | Nao | `true` | Define se a tabela tera bordas em todas as celulas. |
| `zebra` | `Object` | Nao | - | Configuracao de linhas alternadas. |

### Colunas do `body`

Cada coluna deve ter este formato:

```json
{
  "name": "Nome da coluna",
  "alignment": "left"
}
```

Campos aceitos em cada coluna:

| Campo | Tipo | Obrigatorio | Padrao | Descricao |
|-------|------|-------------|--------|-----------|
| `name` | `String` | Sim | `""` | Nome exibido no cabecalho da tabela. Tambem e usado como chave quando `rows` for uma lista de objetos. |
| `alignment` | `String` | Nao | `left` | Alinhamento das celulas: `left`, `center` ou `right`. |

Todas as colunas usam a mesma largura.

### Linhas do `body`

O campo `rows` aceita tres formatos.

Formato com objetos:

```json
[
  {
    "Produto": "Teclado",
    "Qtd": 2,
    "Total": "R$ 180,00"
  }
]
```

Nesse formato, as chaves precisam bater com o `name` das colunas.

Formato com listas:

```json
[
  ["Teclado", 2, "R$ 180,00"],
  ["Mouse", 1, "R$ 90,00"]
]
```

Nesse formato, a ordem dos valores deve seguir a ordem de `columns`.

Formato com valor simples:

```json
[
  "Linha unica"
]
```

Esse formato cria uma linha com apenas uma celula preenchida.

### Rodape da tabela `bodyFooter`

O `bodyFooter` e uma lista opcional exibida abaixo da tabela principal em negrito.

```json
{
  "bodyFooter": [
    "Total geral",
    "3",
    "R$ 270,00"
  ]
}
```

Cada item da lista ocupa a coluna correspondente. Se a lista tiver menos itens que `columns`, as colunas restantes ficam vazias.

### Grade `showGrid`

Quando `showGrid` for `true`, a tabela usa bordas em todas as celulas.

```json
{
  "showGrid": true
}
```

Quando `showGrid` for `false`, a tabela fica sem grade e o cabecalho recebe apenas uma linha inferior.

```json
{
  "showGrid": false
}
```

### Zebra

A configuracao `zebra` permite pintar linhas alternadas da tabela.

```json
{
  "zebra": {
    "enabled": true,
    "color": "#F2F2F2"
  }
}
```

Campos aceitos:

| Campo | Tipo | Obrigatorio | Padrao | Descricao |
|-------|------|-------------|--------|-----------|
| `enabled` | `bool` | Nao | `false` | Ativa ou desativa as linhas alternadas. |
| `color` | `String` | Nao | `#EEEEEE` | Cor hexadecimal no formato `#RRGGBB`. |

Importante: a cor precisa estar no formato `#RRGGBB`, por exemplo `#EEEEEE`, `#F8F9FA` ou `#DDEEFF`.

## Bloco `footer`

O `footer` funciona da mesma forma que o `head`: uma lista de linhas, e cada linha contem uma lista de colunas.

```json
{
  "footer": [
    {
      "columns": [
        {
          "text": "Emitido em 25/04/2026",
          "alignment": "left",
          "fontSize": 9
        },
        {
          "text": "Pagina gerada automaticamente",
          "alignment": "right",
          "fontSize": 9,
          "fontStyle": "italic"
        }
      ]
    }
  ]
}
```

Campos aceitos em cada coluna do `footer`:

| Campo | Tipo | Obrigatorio | Padrao | Descricao |
|-------|------|-------------|--------|-----------|
| `text` | `String` | Nao | `""` | Texto exibido na coluna. |
| `alignment` | `String` | Nao | `left` | Alinhamento: `left`, `center` ou `right`. |
| `fontSize` | `num` | Nao | `12` | Tamanho da fonte. |
| `fontStyle` | `String` | Nao | normal | Estilo: `bold` ou `italic`. |

## Exemplo completo

```json
{
  "head": [
    {
      "columns": [
        {
          "text": "ACME LTDA",
          "alignment": "left",
          "fontSize": 14,
          "fontStyle": "bold"
        },
        {
          "text": "Relatorio de Vendas",
          "alignment": "right",
          "fontSize": 12,
          "fontStyle": "bold"
        }
      ]
    },
    {
      "columns": [
        {
          "text": "Periodo: 01/04/2026 a 25/04/2026",
          "alignment": "left",
          "fontSize": 10
        }
      ]
    }
  ],
  "body": {
    "columns": [
      {
        "name": "Produto",
        "alignment": "left"
      },
      {
        "name": "Qtd",
        "alignment": "center"
      },
      {
        "name": "Valor",
        "alignment": "right"
      }
    ],
    "rows": [
      {
        "Produto": "Teclado",
        "Qtd": 2,
        "Valor": "R$ 180,00"
      },
      {
        "Produto": "Mouse",
        "Qtd": 1,
        "Valor": "R$ 90,00"
      },
      {
        "Produto": "Monitor",
        "Qtd": 1,
        "Valor": "R$ 850,00"
      }
    ],
    "bodyFooter": [
      "Total geral",
      "4",
      "R$ 1.120,00"
    ],
    "showGrid": true,
    "zebra": {
      "enabled": true,
      "color": "#F3F4F6"
    }
  },
  "footer": [
    {
      "columns": [
        {
          "text": "Gerado pelo FlutterFlow",
          "alignment": "left",
          "fontSize": 9
        },
        {
          "text": "Documento sem assinatura",
          "alignment": "right",
          "fontSize": 9,
          "fontStyle": "italic"
        }
      ]
    }
  ]
}
```

## Exemplo minimo

```json
{
  "body": {
    "columns": [
      {
        "name": "Nome"
      },
      {
        "name": "Email"
      }
    ],
    "rows": [
      {
        "Nome": "Ana",
        "Email": "ana@email.com"
      },
      {
        "Nome": "Bruno",
        "Email": "bruno@email.com"
      }
    ]
  }
}
```

## Como usar no FlutterFlow

1. Crie uma Custom Action chamada `relatorios`.
2. Configure o retorno como `Uploaded File`.
3. Crie um parametro chamado `dadosRelatorio`.
4. Use o tipo `JSON` ou `dynamic`, conforme a configuracao disponivel no seu projeto.
5. Passe para a action um objeto no formato documentado acima.
6. Use o `FFUploadedFile` retornado para imprimir, compartilhar, salvar ou visualizar o PDF.

## Observacoes importantes

- O arquivo gerado sempre recebe o nome `relatorio.pdf`.
- A orientacao padrao e `portrait`. Para relatorios com muitas colunas, envie `"orientation": "landscape"`.
- A action nao valida se `body.columns` e `body.rows` existem antes de usar. Envie esses campos quando usar o bloco `body`.
- As larguras das colunas sao sempre iguais.
- O `fontStyle` atual aceita `bold` ou `italic`. Se precisar de negrito e italico ao mesmo tempo, sera necessario ajustar o codigo.
- Valores nulos sao convertidos para texto vazio.
- Valores numericos, datas e booleanos sao convertidos para texto usando `.toString()`.
- A action nao aplica formatacao automatica de moeda, data ou numero. Envie os textos ja formatados quando precisar controlar a exibicao.
- A action usa `pw.MultiPage`, entao a tabela pode continuar em novas paginas quando houver muitas linhas.
