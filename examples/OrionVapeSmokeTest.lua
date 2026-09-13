-- Orion API smoke test rendered by Vape UI.
-- Safe: creates controls and notifications only; does not modify gameplay.

local VAPE_LOADER = 'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/NewMainScript.lua'
local ORION_LOADER = 'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/OrionLoader.lua'


-- If another Vape build is already running, reload the fork that includes Orion support.
if not shared.OrionLib then
	if shared.vape then
		pcall(function() shared.vape:Uninject() end)
		task.wait(0.2)
	end
	loadstring(game:HttpGet(VAPE_LOADER, true))()
end

local OrionLib = shared.OrionLib
	 or loadstring(game:HttpGet(ORION_LOADER, true))()

local Window = OrionLib:MakeWindow({
	Name = 'Vape × Orion compatibility test',
	SaveConfig = false,
	SearchBar = true,
	Openkey = 'RightShift'
})

local Main = Window:MakeTab({Name = 'Smoke test'})
local Controls = Main:AddSection({Name = 'Controls'})
local Players = Main:AddSection({Name = 'Players'})
local Feedback = Main:AddSection({Name = 'Feedback'})
local Legacy = Main:AddSection()

Controls:AddLabel('Orion controls rendered by Vape UI')
Controls:AddParagraph('Status', 'This test only changes UI state and prints callbacks.', 'Left')

Controls:AddToggle({
	Name = 'Demo toggle',
	Default = false,
	Flag = 'DemoToggle',
	Save = false,
	Callback = function(value)
		print('[OrionVapeTest] toggle:', value)
	end
})

Controls:AddSlider({
	Name = 'Demo slider',
	Min = 0,
	Max = 100,
	Default = 25,
	Increment = 5,
	ValueName = '%',
	Flag = 'DemoSlider',
	Callback = function(value)
		print('[OrionVapeTest] slider:', value)
	end
})


Controls:AddDropdown({
	Name = 'Single choice',
	Options = {'Normal', 'Fast', 'Safe'},
	Default = 'Normal',
	Searchable = true,
	Callback = function(value)
		print('[OrionVapeTest] choice:', value)
	end
})

local Multi = Controls:AddDropdown({
	Name = 'Multiple choice',
	Options = {'Alpha', 'Beta', 'Gamma', 'Delta'},
	Default = {'Alpha'},
	Multi = true,
	Searchable = true,
	Callback = function(values)
		print('[OrionVapeTest] multi:', table.concat(values, ', '))
	end
})

-- Legacy Orion call forms used by existing scripts.
Multi:Set('Beta', true)
Multi:Set('Alpha', false)
Multi:Refresh({'Alpha', 'Beta', 'Gamma'}, true)

Legacy:AddPbind({
	Name = 'Position',
	DefaultX = '1',
	DefaultY = '2',
	DefaultZ = '3',
	Callback = function(x, y, z)
		print('[OrionVapeTest] pbind:', x, y, z)
	end
}):toggle()

Players:AddPlayerDropdown({
	Name = 'Player selector',
	Multi = true,
	Callback = function(usernames)
		print('[OrionVapeTest] players:', table.concat(usernames, ', '))
	end
})

Players:AddBind({
	Name = 'Test bind',
	Default = Enum.KeyCode.K,
	Callback = function()
		OrionLib:MakeNotification({Name = 'Bind', Content = 'Bind acionado.', Time = 2})
	end
})

Feedback:AddTextbox({
	Name = 'Test textbox',
	Default = 'hello',
	BackGrountText = 'Digite algo',
	Callback = function(value)
		print('[OrionVapeTest] textbox:', value)
	end
})

Feedback:AddColorpicker({
	Name = 'Test color',
	Default = Color3.fromRGB(255, 80, 80),
	Callback = function(value)
		print('[OrionVapeTest] color:', value)
	end
})

Feedback:AddButton({
	Name = 'Send notification',
	Callback = function()
		OrionLib:MakeNotification({
			Name = 'Vape × Orion',
			Content = 'Compatibilidade funcionando.',
			Time = 3
		})
	end
})

Feedback:AddSmartTheme()
local Config = Window:MakeTab({Name = 'Config'})
Config:AddSection():AddUiBind()
OrionLib:MakeNotification({Name = 'Smoke test', Content = 'UI carregada com sucesso.', Time = 3})
OrionLib:Init()

return Window
