-- Fire Hub API surface test on native Vape UI.
-- Safe: UI controls, callbacks and notifications only. No gameplay/remotes.

local VAPE_LOADER = 'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/NewMainScript.lua'
local ORION_LOADER = 'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/OrionLoader.lua'

if not shared.OrionLib then
	loadstring(game:HttpGet(VAPE_LOADER, true))()
end

local OrionLib = shared.OrionLib or loadstring(game:HttpGet(ORION_LOADER, true))()
OrionLib.UMouseMode = 'ThirdPerson'

local Window = OrionLib:MakeWindow({
	Name = 'Fire Hub × Vape compatibility test',
	SearchBar = true,
	SaveConfig = false,
	FreeMouse = true,
	ShowIcon = true
})

local function notify(name, content)
	OrionLib:MakeNotification({Name = name, Content = content, Time = 2})
end

local function playerOptions()
	local result = {}
	for _, player in game:GetService('Players'):GetPlayers() do
		table.insert(result, string.format('%s (%s)', player.DisplayName, player.Name))
	end
	return result
end

local Grab = Window:MakeTab({Name = 'Grab'})
local Anti = Window:MakeTab({Name = 'Anti'})
local Auras = Window:MakeTab({Name = 'Auras'})
local Loop = Window:MakeTab({Name = 'Loop'})
local Blob = Window:MakeTab({Name = 'Blob'})
local Bind = Window:MakeTab({Name = 'Bind'})
local ESP = Window:MakeTab({Name = 'ESP'})
local Config = Window:MakeTab({Name = 'Config'})

Grab:ColorLabel('Grab tab', nil, 'Center')
Grab:AddSection()
local label = Grab:AddLabel('Labels render in native Vape modules.')
label:Set('Updated label')
local paragraph = Grab:AddParagraph('Status', 'Safe compatibility test: no gameplay changes.', 'Left')
paragraph:Set('Status', 'Paragraph Set works.', 'Center')
local button = Grab:AddButton({Name = 'Notification', Callback = function() notify('Fire Hub', 'Button works') end})
button:Set('Notification updated')

Anti:AddSection({Name = 'Controls'})
Anti:AddToggle({Name = 'Toggle', Default = false, Callback = function(value) print('toggle', value) end})
Anti:AddSlider({Name = 'Slider', Min = 0, Max = 100, Default = 25, Increment = 5, ValueName = '%'})
Anti:AddDropdown({Name = 'Single dropdown', Options = {'Normal', 'Fast', 'Safe'}, Searchable = true})
local multi = Anti:AddDropdown({Name = 'Multi dropdown', Options = {'Alpha', 'Beta', 'Gamma'}, Multi = true, Searchable = true})
multi:Set('Beta', true)
multi:Refresh({'Alpha', 'Beta', 'Gamma', 'Delta'}, false)
assert(multi:Has('Beta') and multi:Get()[1] ~= nil, 'multi dropdown methods failed')
multi:UpdSel()
multi:UpdVis()

Auras:AddSection()
Auras:AddPlayerDropdown({Name = 'Player selector', Multi = true, Callback = function(values) print('players', table.concat(values, ', ')) end})
local pbind = Auras:AddPbind({Name = 'Position', DefaultX = '1', DefaultY = '2', DefaultZ = '3'})
pbind:Set(4, 5, 6)
pbind:toggle()

Loop:AddSection()
Loop:AddTextbox({Name = 'Text', Default = 'hello', BackGrountText = 'Type here'})
Loop:AddColorpicker({Name = 'Color', Default = Color3.fromRGB(255, 80, 80)})
Loop:AddSmartTheme()

Blob:AddSection()
Blob:AddToggle({Name = 'Safe switch', Callback = function() end})

Bind:AddSection()
local bind = Bind:AddBind({Name = 'Test bind', Default = Enum.KeyCode.K, Callback = function() notify('Bind', 'Bind works') end})
bind:Set(Enum.UserInputType.MouseButton3)
Bind:AddDropdown({Name = 'Location', Default = 'Void', Options = {'Spawn', 'Void', 'Sky'}})

ESP:AddSection()
ESP:AddDropdown({Name = 'Select player', Default = '', Options = playerOptions(), Searchable = true})
ESP:AddToggle({Name = 'ESP player', Callback = function() end})
ESP:AddColorpicker({Name = 'ESP color', Default = Color3.new(1, 0, 0)})

Config:AddSection()
Config:FreeMouseDrp()
Config:AddUiBind()
Config:AddTextbox({Name = 'Window Name', Default = 'Fire Hub × Vape'})
Config:AddSmartTheme()
Window:SetName({'Fire Hub × Vape', '#FFFFFF'})
Window:ChangeIcon('rbxassetid://114143041236784')
OrionLib:SetTheme()

notify('Compatibility', 'All Fire Hub Orion controls loaded')
OrionLib:Init()

return Window
