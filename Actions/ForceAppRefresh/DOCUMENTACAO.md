# Force App Refresh

Custom Action para limpar caches em runtime e forcar um recarregamento do app com foco em atualizacao de versao, principalmente no Flutter Web.

## Dependencias

Adicione no FlutterFlow:
- `path_provider`
- `universal_html`

## Parametros

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `clearTemporaryFiles` | `bool` | No Android/iOS, remove arquivos da pasta temporaria do app. Recomendo `true`. |
| `clearWebStorage` | `bool` | No Web, tambem limpa `localStorage` e `sessionStorage`. Use com cuidado, pois isso pode encerrar sessao e apagar dados persistidos no navegador. |

## Como funciona

### Web

A action:

1. Limpa o cache de imagens em memoria do Flutter.
2. Tenta remover todos os `service workers` registrados.
3. Tenta apagar todas as entradas de `CacheStorage`.
4. Opcionalmente limpa `localStorage` e `sessionStorage`.
5. Recarrega a URL atual adicionando um query param unico para evitar reaproveitamento agressivo de cache.

Esse e o comportamento mais proximo de um "hard refresh" que conseguimos fazer dentro do app Flutter Web.

### Android e iOS

A action:

1. Limpa o cache de imagens em memoria do Flutter.
2. Remove arquivos da pasta temporaria do app.

Importante: em app nativo isso **nao baixa uma nova versao binaria** da Play Store/App Store. Para "forcar atualizacao" de verdade no mobile, o fluxo correto e:

- consultar a versao minima suportada em backend/Remote Config;
- bloquear o app se a versao instalada estiver desatualizada;
- abrir a loja para o usuario atualizar.

## Retorno

Retorna `String?`.

- `null`: limpeza executada com sucesso.
- `String`: mensagem de erro ao limpar cache temporario no mobile.

## Uso recomendado

Para Web:
- chame essa action no `App Start`, em splash ou logo apos detectar que a versao publicada mudou.
- use `clearWebStorage = false` por padrao.
- use `clearWebStorage = true` somente se voce realmente quiser invalidar sessao e dados persistidos.

Para Android/iOS:
- use essa action como complemento de limpeza local.
- combine com uma logica separada de verificacao de versao para obrigar update pela loja.

## Observacoes

- Se o seu app web usa `service worker`, a primeira carga apos publicar uma nova versao pode depender desse refresh para buscar os assets novos.
- Limpar `localStorage` no Web pode apagar estado salvo pelo proprio FlutterFlow.
- Em iOS nao existe um mecanismo publico para o app "se autoatualizar" fora do fluxo da App Store.
