# Compatibilidade Orion no Vape

Esta camada migra scripts da Orion Library Custom sem carregar uma segunda interface. A lógica continua; os controles são renderizados pelo Vape.

## Ativação

Depois do pacote universal carregar:

```luau
local OrionLib = shared.OrionLib
-- equivalente:
local OrionLib = shared.vape.Libraries.orioncompat
```

Entrypoint drop-in publicado:

```lua
local OrionLib = loadstring(game:HttpGet(
    'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/OrionLoader.lua', true
))()
```

Carregue `NewMainScript.lua` antes. A única alteração necessária em um script Orion existente é trocar a URL do loader; a lógica restante permanece intacta.

Não execute o `Loader.lua` Orion junto. Ele criaria outro `ScreenGui`, sistema de input, tema e salvamento.

## Mapeamento

| Orion | Vape |
|---|---|
| `MakeWindow` | contexto lógico da integração |
| `MakeTab` | categoria Vape |
| `AddSection` | módulo/contêiner independente |
| `AddToggle` | `CreateToggle` |
| `AddSlider` | `CreateSlider` |
| `AddDropdown` | `CreateChoiceList` |
| `AddBind` | `CreateBind` |
| `AddTextbox` | `CreateTextBox` |
| `AddColorpicker` | `CreateColorSlider` |
| `AddLabel`, `AddParagraph`, `AddLog` | `CreateLabel` |
| `MakeNotification` | `CreateNotification` |
| `Flags` | referências aos controles |

## Tabs e várias sections

```luau
local OrionLib = shared.OrionLib
local Window = OrionLib:MakeWindow({Name = 'Meu projeto', SaveConfig = true})
local Combat = Window:MakeTab({Name = 'Combat'})
local General = Combat:AddSection({Name = 'General'})
local Targeting = Combat:AddSection({Name = 'Targeting'})
```

Cada section recebe nome interno único. Assim, `General` em duas tabs não causa sobrescrita.

## Dropdown completo

```luau
General:AddDropdown({
	Name = 'Mode',
	Options = {'Normal', 'Fast', 'Safe'},
	Default = 'Normal',
	Searchable = true,
	Callback = function(value) print(value) end
})

General:AddDropdown({
	Name = 'Checks',
	Options = {'Alive', 'Visible', 'Distance'},
	Default = {'Alive'},
	Multi = true,
	Callback = function(values) print(table.concat(values, ', ')) end
})
```

Grupos e ícones:

```luau
General:AddDropdown({
	Name = 'Action', Grouped = true, Icons = true,
	Options = {
		Movement = {
			{text = 'Follow', value = 'follow', icon = 'rbxassetid://123'},
			{text = 'Stop', value = 'stop', icon = 'rbxassetid://456'}
		}
	},
	Callback = function(value) end
})
```

## Seleção de jogadores

```luau
local PlayerSelect = Targeting:AddPlayerDropdown({
	Name = 'Target', Multi = true,
	Callback = function(usernames)
		-- valores são usernames estáveis
	end
})
```

O componente usa `Players:GetPlayers()`, mostra `DisplayName` e `Name`, usa miniatura `rbxthumb://`, reage a `PlayerAdded`/`PlayerRemoving` e limpa conexões com o módulo. Também aceita `AddDropdown({Players = true})`.

## Flags

```luau
General:AddSlider({
	Name = 'Speed', Min = 1, Max = 100, Default = 20,
	Flag = 'SpeedValue', Save = true,
	Callback = function(value) end
})

OrionLib.Flags.SpeedValue:Set(35)
print(OrionLib.Flags.SpeedValue.Value)
```

O perfil nativo do Vape cuida da persistência. `Save = true` é aceito, sem criar um segundo arquivo Orion.

## Diferenças intencionais

- `MakeWindow` não cria outro `ScreenGui`.
- `SetName` e `ChangeIcon` guardam metadados, sem trocar a identidade global.
- `PremiumOnly`, `HidePremium` e `FreeMouse` não criam autorização ou captura paralela.
- `math.huge` recebe teto visual finito.
- callbacks e valores são compatíveis; aparência continua Vape.

Para código novo, prefira a [API nativa](UI_API.md). O adaptador serve para migração.
