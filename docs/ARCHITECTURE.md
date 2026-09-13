# Arquitetura, carregamento e manutenção

Este documento descreve o caminho completo entre executar o bootstrap e ver os módulos funcionando.

## Visão geral

```text
NewMainScript.lua
  -> consulta a versão publicada
  -> valida/invalida o cache
  -> baixa e executa main.lua
      -> baixa UI, universal e script do PlaceId em paralelo
      -> executa a UI
      -> executa os módulos universais
      -> executa a adaptação do jogo
      -> carrega o perfil
      -> inicia autosave e persistência de teleport
```

O repositório atual contém fontes modulares. O `VapeBundler` monta essas fontes e publica o resultado no repositório `VapeCompiled`. Os marcadores `--Libraries`, `--Components` e `--Init` dentro dos arquivos `base.lua` são pontos de inserção do bundler. Um arquivo parcial de `src/` normalmente não deve ser executado sozinho.

## Bootstrap

`NewMainScript.lua` é entrada pública. `src/loader.lua` é fonte equivalente usada no build.

Passos:

1. Define fallbacks para `isfile` e `delfile`.
2. Cria pastas `newvape`, `games`, `profiles`, `assets`, `libraries` e `guis`.
3. Consulta API de commits do GitHub para obter SHA atual de `shared.VapeRepository` (padrão `vze7/VapeCompiled`).
4. Se consulta falhar, usa último SHA válido salvo. Cache funcional não é apagado.
5. Quando GitHub confirma SHA diferente, remove somente arquivos que começam com watermark gerenciado.
6. Mantém arquivos personalizados sem watermark.
7. Baixa arquivos ausentes com três tentativas e backoff curto.
8. Executa `newvape/main.lua`.

### Cache frio e quente

Cache frio não possui arquivos. Loader busca commit e baixa recursos necessários.

Cache quente possui mesma versão. `isfile()` evita download; conteúdo vem do disco.

Atualização confirmada remove somente arquivos gerenciados. Perfis permanecem.

Falha de rede conserva última versão válida. Sem cache anterior, branch `main` vira fallback final.

## Main

`src/main.lua` possui quatro responsabilidades:

- esperar carregamento do DataModel;
- impedir duas instâncias através de `shared.vape`;
- buscar e executar pacotes compilados;
- finalizar perfil, autosave e teleport.

Arquivos independentes de rede são buscados juntos:

- `newvape/guis/new.lua`;
- `newvape/games/universal.lua`;
- `newvape/games/<PlaceId>.lua`.

Execução continua ordenada porque universal depende da UI e script específico depende das bibliotecas universais.

Ausência de arquivo específico para um PlaceId é válida. Falha da UI ou universal é fatal, pois restante não funciona sem eles.

## Assets

`src/guis/new/libraries/getvapeasset.lua` contém mapa de ícones principais para `rbxassetid://`.

Ordem atual:

1. Usar ID Roblox embutido quando disponível.
2. Para asset customizado ou não mapeado, baixar arquivo e usar `getcustomasset` quando suportado.
3. Retornar string vazia se nenhum caminho existir.

Definir `shared.VapeUseLocalAssets = true` antes do loader força assets locais no desktop. Útil para desenvolver temas; pior para tempo de primeira inicialização.

## Estado e perfis

Dois JSONs são mantidos:

- `newvape/profiles/<GameId>.gui.txt`: posição/estado de categorias, perfil atual e preferências globais de UI;
- `newvape/profiles/<Profile><PlaceId>.txt`: módulos, opções, visibilidade e binds daquele lugar.

`vape:Load()` aplica dados aos componentes existentes. `vape:Save()` pergunta a cada componente como serializar seu estado. Escrita ocorre somente quando JSON mudou.

## Ciclo de vida de módulo

1. Bundler insere arquivo dentro do `base.lua` correspondente.
2. Arquivo chama `CreateModule`.
3. Componente registra objeto em `vape.Modules` ou `vape.Legit.Modules`.
4. Perfil chama `module:Load()`.
5. Ativação chama `props.Function(true)`.
6. Módulo registra eventos/threads/objetos com `module:Clean(...)`.
7. Desativação desconecta tudo e chama `props.Function(false)`.
8. `vape:Uninject()` desativa módulos, salva perfil e destrói UI.

Sempre registre recursos de duração do módulo com `Clean`. Conexão criada fora desse ciclo vaza após toggle/reload.

## Estrutura de jogos

`src/games/universal - base/` contém funções compartilhadas. Subpastas viram categorias:

- `Combat`
- `Blatant`
- `Render`
- `Utility`
- `World`
- `Inventory`
- `Legit`

Pastas específicas possuem um `base.lua` e arquivos de módulos. Nome da pasta associa PlaceId e nome legível. Bundler combina base e módulos num único arquivo publicado por PlaceId.

## Build

Workflow `.github/workflows/build.yaml`:

1. clona fontes, destino e bundler;
2. configura Node definido pelo projeto;
3. usa `npm ci` para instalação determinística;
4. executa bundler em modo produção;
5. publica somente quando saída mudou.

Builds antigos da mesma branch são cancelados quando novo push chega.

## Uso dentro de um jogo Roblox próprio

APIs como `readfile`, `writefile`, `loadstring`, `gethui`, `getcustomasset`, `setthreadidentity` e `queue_on_teleport` não pertencem ao ambiente normal de um `LocalScript` no Studio.

Port recomendado:

```text
ReplicatedStorage
└── ClientFramework
    ├── UI
    ├── Components
    ├── Libraries
    └── Features

StarterPlayer
└── StarterPlayerScripts
    └── ClientBootstrap.client.lua
```

Mudanças:

- cada fonte vira `ModuleScript` retornando tabela/função;
- `require()` substitui `loadstring()`;
- módulos e UI são publicados junto com experiência;
- configurações locais ficam em memória; persistência real deve passar por servidor e DataStore;
- imagens usam IDs Roblox;
- código servidor valida toda ação relevante.

Nesse formato, download de código desaparece. Roblox entrega scripts junto com experiência, reduzindo bootstrap e removendo dependência do GitHub durante sessão.

## Próximas otimizações recomendadas

1. Criar UI mínima antes dos módulos.
2. Instanciar opções somente ao abrir módulo.
3. Carregar módulos pesados somente no primeiro toggle.
4. Centralizar loops em scheduler de frequências.
5. Trocar ordenação completa de entidades por seleção de menor distância em passagem única.
6. Atualizar tema somente em componentes visíveis/sujos.
7. Pausar rainbow sem elemento visível.
8. Remover hack que alterna `Visible` de todos os descendentes ao mudar escala.
9. Medir cold start, warm start, memória e tempo por frame antes/depois.
