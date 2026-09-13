# UI: estrutura, componentes e criação de módulos

> Migrando um script Orion? Consulte [Compatibilidade Orion](ORION_COMPATIBILITY.md).

## Árvore principal

`src/guis/new/init.lua` cria:

```text
ScreenGui
└── ScaledGui
    ├── ClickGui
    │   ├── Main
    │   ├── Combat
    │   ├── Blatant
    │   ├── Render
    │   ├── Utility
    │   ├── World
    │   ├── Inventory
    │   ├── Friends
    │   ├── Profiles
    │   └── Targets
    ├── Notifications
    ├── Tooltip
    ├── LegitWindow
    └── Overlays
```

`UIScale` aplica escala global. Categorias comuns são janelas arrastáveis com `ScrollingFrame`. `UIListLayout` determina ordem vertical. `LegitWindow` usa grid separado.

## Interação

- bind padrão da UI: `RightShift`;
- clique esquerdo no módulo: ativa/desativa;
- clique direito ou botão de pontos: abre opções;
- arrastar cabeçalho: move categoria;
- botão lápis: edita visibilidade/ordem;
- busca: filtra módulos por nome;
- mobile: botão abre UI e long press configura bind móvel.

## Criar módulo universal

Crie arquivo na categoria desejada, por exemplo:

```text
src/games/universal - base/Utility/Bomb.lua
```

Conteúdo mínimo:

```luau
local Bomb

Bomb = vape.Categories.Utility:CreateModule({
	Name = 'Bomb',
	Tooltip = 'Descrição curta para tooltip',
	Function = function(enabled)
		if enabled then
			Bomb:Clean(runService.Heartbeat:Connect(function(deltaTime)
				-- trabalho enquanto ligado
			end))
		end
	end
})
```

Não precisa editar `init.lua`. Bundler encontra arquivo na pasta e injeta no pacote universal. `Name` deve ser único; `CreateModule` remove versão anterior com mesmo nome.

## Criar módulo específico de jogo

Escolha pasta do jogo/PlaceId e categoria:

```text
src/games/Meu Jogo/123456789 - main/Utility/Bomb.lua
```

Se adaptação ainda não existe, crie `base.lua` com serviços, bibliotecas e estado necessários. Arquivo final será publicado como `games/123456789.lua`.

Módulo específico deve usar remotes e objetos conhecidos pelo jogo. No seu próprio jogo, mantenha ações importantes no servidor e valide argumentos recebidos.

## Opções disponíveis

### Toggle

```luau
local EnabledOption = Bomb:CreateToggle({
	Name = 'Enabled option',
	Default = true,
	Function = function(value)
		print(value)
	end
})
```

Valor: `EnabledOption.Enabled`.

### Slider

```luau
local Speed = Bomb:CreateSlider({
	Name = 'Speed',
	Min = 1,
	Max = 100,
	Default = 25,
	Suffix = 'studs/s',
	Function = function(value)
		print(value)
	end
})
```

Valor: `Speed.Value`.

### TwoSlider

```luau
local Range = Bomb:CreateTwoSlider({
	Name = 'Range',
	Min = 1,
	Max = 100,
	DefaultMin = 10,
	DefaultMax = 40
})
```

Use para intervalo mínimo/máximo.

### Dropdown

```luau
local Mode = Bomb:CreateDropdown({
	Name = 'Mode',
	List = {'Nearest', 'Mouse', 'Manual'},
	Default = 'Nearest'
})
```

Valor: `Mode.Value`.

### TextBox

```luau
local Name = Bomb:CreateTextBox({
	Name = 'Target name',
	Placeholder = 'username',
	Function = function(value)
		print(value)
	end
})
```

### Targets

```luau
local Targets = Bomb:CreateTargets({
	Players = true,
	NPCs = false,
	Walls = true
})
```

Fornece filtros padronizados usados com biblioteca `entity`.

### ColorSlider

```luau
local Color = Bomb:CreateColorSlider({
	Name = 'Color',
	Function = function(hue, saturation, value)
		local result = Color3.fromHSV(hue, saturation, value)
	end
})
```

### Bind

```luau
local ActionBind = Bomb:CreateBind({
	Name = 'Action bind',
	Default = {'F'}
})

Bomb:Clean(ActionBind.Triggered:Connect(function(isDown)
	print(isDown)
end))
```

## Opções condicionais

Guarde referência e altere `Object.Visible`:

```luau
local AdvancedSpeed

local Advanced = Bomb:CreateToggle({
	Name = 'Advanced',
	Function = function(enabled)
		AdvancedSpeed.Object.Visible = enabled
	end
})

AdvancedSpeed = Bomb:CreateSlider({
	Name = 'Advanced speed',
	Min = 1,
	Max = 200,
	Default = 50,
	Visible = false
})
```

## Limpeza correta

Aceitos por `Clean`:

- `RBXScriptConnection`;
- `Instance`;
- thread criada por `task.spawn`;
- função de cleanup;
- objeto com método `Disconnect`.

Exemplo:

```luau
Bomb:Clean(workspace.ChildAdded:Connect(function(child)
	-- evento
end))

local folder = Instance.new('Folder')
folder.Parent = workspace
Bomb:Clean(folder)

Bomb:Clean(function()
	-- restaurar propriedade alterada
end)
```

Nunca deixe `RenderStepped`, `Heartbeat` ou `InputBegan` fora de `Clean` quando duração depende do toggle.

## Categorias novas

Categoria visual nova é criada em `src/guis/new/init.lua`:

```luau
vape:CreateCategory({
	Name = 'Automation',
	Icon = getvapeasset('newvape/assets/new/automation.png'),
	Size = UDim2.fromOffset(14, 14)
})
```

Depois módulos usam:

```luau
vape.Categories.Automation:CreateModule({...})
```

Adicionar categoria exige:

1. novo ícone no mapa de assets;
2. entrada na ordem de `Sort GUI`;
3. comportamento responsivo/mobile;
4. documentação do propósito da categoria.

Evite criar categoria para poucos módulos. Muitas janelas pioram busca e telas pequenas.

## Overlays

`vape:CreateOverlay` cria widget independente, como `Text GUI` e `Target Info`. Overlay deve:

- possuir toggle próprio;
- salvar posição e opções;
- respeitar escala/safe area;
- atualizar somente quando visível;
- limpar conexões ao desligar.

## Tema

Tokens básicos ficam em `uipallet.lua`. `Color()` de cada componente recebe HSV atual e estado rainbow. Novo componente deve implementar `Color` somente quando realmente tiver propriedades dependentes do tema.

Evite atualizar árvore inteira por frame. Registre somente objetos que mudam com tema. Rainbow deve parar quando nenhum consumidor estiver visível.

## UI recomendada para próxima versão

```text
Topbar: busca, perfil, status
Sidebar: categorias
Centro: lista virtualizada de módulos
Direita: opções do módulo selecionado
Rodapé: versão, carregamento e erros
```

Desktop usa três painéis. Mobile usa página única com navegação e botão voltar. Gamepad usa `Activated`, seleção explícita e foco visual. Respeite safe areas e alvos de toque grandes.
