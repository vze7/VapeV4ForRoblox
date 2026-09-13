# Firemax Orion × Vape — auditoria

Última auditoria: 13/09/2026.

## Resultado

| Verificação | Resultado |
|---|---|
| Métodos definidos pelo `Loader.lua` Firemax | 26 encontrados |
| Métodos presentes na ponte Vape | 26/26 |
| Adapter cria `ScreenGui`, `gethui` ou `CoreGui` próprio | 0 ocorrências |
| UI duplicada Orion | Não |
| Inicialização universal antes dos módulos de jogo | Sim |
| Bind teclado e mouse | Sim |
| Dropdown simples/múltiplo/pesquisa/refresh | Sim |
| Player dropdown com atualização de entrada/saída | Sim |
| Temas `GenTheme`/`SetTheme`/`SmartTheme` | Sim |
| Build publicado | Sim |
| Endpoints públicos testados | HTTP 200 |

## API Firemax coberta

`MakeNotification`, `MakeWindow`, `SetTheme`, `GenTheme`, `ChangeIcon`, `SetName`, `MakeTab`, `Destroy`, `AddLog`, `AddLabel`, `ColorLabel`, `AddParagraph`, `AddButton`, `AddToggle`, `AddPbind`, `AddSlider`, `AddDropdown`, `FreeMouseDrp`, `AddBind`, `AddTextbox`, `AddColorpicker`, `AddUiBind`, `AddSmartTheme` e `AddSection`.

Também há aliases de objeto: `Set`, `SetMax`, `SetMin`, `Refresh`, `Get`, `Has`, `UpdSel`, `UpdVis` e `toggle`.

## Ordem de carregamento

1. `NewMainScript.lua` busca UI, universal e adapter.
2. UI Vape inicia.
3. Adapter é publicado em `shared.OrionLib`.
4. Módulo universal e módulo do jogo executam.
5. Script Firemax obtém `OrionLib` pelo `OrionLoader.lua`.

Assim, adapter não depende de um jogo específico nem cria interface paralela.

## Teste real de UI

Execute depois do Vape:

```lua
loadstring(game:HttpGet(
	'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/examples/FireHubUiCompatibilityTest.lua',
	true
))()
```

O teste cria as tabs `Grab`, `Anti`, `Auras`, `Loop`, `Blob`, `Bind`, `ESP` e `Config`, usando os mesmos métodos do Firemax. Não dispara remotes nem altera gameplay.

## Interpretação da imagem “só Vape”

`NewMainScript.lua` carrega somente o Vape; ele não executa automaticamente o Firemax. Se o script Firemax continuar usando o `Loader.lua` original, ele também não usa a ponte. O loader precisa ser:

```lua
local OrionLib = loadstring(game:HttpGet(
	'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/OrionLoader.lua',
	true
))()
```

`OrionVapeSmokeTest.lua` é teste de controles, não substituto de `OrionLoader.lua`.

## Limite da auditoria

Build, fonte, API e endpoints foram verificados localmente. Callback visual precisa ser executado em Roblox aberto. A lógica de `Module.lua` continua dependente dos remotes e APIs disponíveis no jogo autorizado; a ponte cobre a UI, não reescreve essa lógica.
