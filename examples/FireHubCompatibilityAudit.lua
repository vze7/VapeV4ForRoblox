-- Runtime audit for Firemax Orion compatibility.
-- Safe: builds UI controls and reports results; no gameplay/remotes.

local VAPE = 'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/NewMainScript.lua'
local LOADER = 'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/OrionLoader.lua'

if not shared.OrionLib or not shared.OrionLib.__VapeOrionCompat then
	loadstring(game:HttpGet(VAPE, true))()
end
local OrionLib = loadstring(game:HttpGet(LOADER, true))()

local passed, failed = 0, 0
local function check(name, callback)
	local ok, err = pcall(callback)
	if ok then
		passed += 1
		print('[Firemax/Vape PASS] '..name)
	else
		failed += 1
		warn('[Firemax/Vape FAIL] '..name..': '..tostring(err))
	end
	return ok
end

local Window
check('MakeWindow', function()
	Window = OrionLib:MakeWindow({Name = 'Firemax compatibility audit', SaveConfig = false, SearchBar = true})
	assert(Window and type(Window.MakeTab) == 'function')
end)

local Tab = Window:MakeTab({Name = 'Audit'})
local Section = Tab:AddSection()

for _, name in {'AddLog', 'AddLabel', 'ColorLabel', 'AddParagraph', 'AddButton', 'AddToggle', 'AddPbind', 'AddSlider', 'AddDropdown', 'FreeMouseDrp', 'AddBind', 'AddTextbox', 'AddColorpicker', 'AddUiBind', 'AddSmartTheme', 'AddSection'} do
	check('Section:'..name, function() assert(type(Section[name]) == 'function') end)
end

local toggle = Section:AddToggle({Name = 'Toggle', Default = false})
check('Toggle:Set', function() toggle:Set(true); toggle:Set(false) end)

local slider = Section:AddSlider({Name = 'Slider', Min = 0, Max = 100, Default = 25, Increment = 5})
check('Slider methods', function()
	slider:Set(50)
	slider:SetMax(120)
	slider:SetMin(1)
	slider:SetName('Slider renamed')
end)

local dropdown = Section:AddDropdown({Name = 'Dropdown', Options = {'A', 'B'}, Multi = true, Searchable = true})
check('Dropdown methods', function()
	dropdown:Set('A', true)
	assert(dropdown:Has('A'))
	assert(type(dropdown:Get()) == 'table')
	dropdown:UpdSel()
	dropdown:UpdVis()
	dropdown:Refresh({'A', 'B', 'C'}, false)
end)

local pbind = Section:AddPbind({Name = 'PBind', DefaultX = '1', DefaultY = '2', DefaultZ = '3'})
check('Pbind methods', function() pbind:Set(4, 5, 6); pbind:toggle(); pbind:toggle() end)

check('remaining controls', function()
	Section:AddLog('audit')
	Section:AddTextbox({Name = 'Textbox', Default = 'ok'})
	Section:AddColorpicker({Name = 'Color', Default = Color3.new(1, 0, 0)})
	Section:FreeMouseDrp()
	Section:AddBind({Name = 'Mouse bind', Default = Enum.UserInputType.MouseButton3})
	Section:AddUiBind()
	Section:AddSmartTheme()
	OrionLib:SetTheme()
end)

local tabs = {'Grab', 'Anti', 'Auras', 'Loop', 'Blob', 'Bind', 'ESP', 'Config'}
for _, name in tabs do
	check('Tab:'..name, function()
		local tab = Window:MakeTab({Name = name})
		tab:AddSection({Name = 'Smoke'})
	end)
end

OrionLib:MakeNotification({
	Name = failed == 0 and 'Firemax audit PASS' or 'Firemax audit FAIL',
	Content = string.format('%d passed, %d failed', passed, failed),
	Time = 6
})
print(string.format('[Firemax/Vape] audit complete: %d passed, %d failed', passed, failed))

return failed == 0
