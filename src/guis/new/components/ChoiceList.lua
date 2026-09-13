local component = {
	Type = 'ChoiceList',
	Value = props.Multi and {} or nil,
	List = {},
	Options = {},
	Multi = props.Multi == true,
	Searchable = props.Searchable == true,
	Toggled = false,
	Expanded = false
}

props.Function = props.Function or function() end

local function normalize(list)
	local result = {}
	for group, values in list or {} do
		if type(group) == 'string' and type(values) == 'table' and values.text == nil then
			for _, value in values do
				local item = type(value) == 'table' and table.clone(value) or {text = tostring(value), value = value}
				item.group = group
				table.insert(result, item)
			end
		else
			local value = values
			local item = type(value) == 'table' and table.clone(value) or {text = tostring(value), value = value}
			item.text = item.text or tostring(item.value)
			item.value = item.value == nil and item.text or item.value
			table.insert(result, item)
		end
	end
	return result
end

local root = Instance.new('Frame')
root.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
root.BorderSizePixel = 0
root.Size = UDim2.new(1, 0, 0, 40)
root.Visible = props.Visible == nil or props.Visible
root.Parent = children
component.Object = root

local button = Instance.new('TextButton')
button.AutoButtonColor = false
button.BackgroundColor3 = uipallet.Main
button.Position = UDim2.fromOffset(10, 4)
button.Size = UDim2.new(1, -20, 0, 29)
button.Text = ''
button.Parent = root
addCorner(button, UDim.new(0, 6))

local title = Instance.new('TextLabel')
title.BackgroundTransparency = 1
title.FontFace = uipallet.Font
title.Position = UDim2.fromOffset(9, 0)
title.Size = UDim2.new(1, -30, 1, 0)
title.TextColor3 = color.Dark(uipallet.Text, 0.16)
title.TextSize = 13
title.TextTruncate = Enum.TextTruncate.AtEnd
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = button

local arrow = Instance.new('ImageLabel')
arrow.BackgroundTransparency = 1
arrow.Image = getvapeasset('newvape/assets/new/expandarrow.png')
arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
arrow.Position = UDim2.new(1, -17, 0, 11)
arrow.Rotation = 90
arrow.Size = UDim2.fromOffset(4, 8)
arrow.Parent = button

local panel = Instance.new('Frame')
panel.BackgroundTransparency = 1
panel.Position = UDim2.fromOffset(10, 37)
panel.Size = UDim2.new(1, -20, 0, 0)
panel.Visible = false
panel.Parent = root

local search
if props.Searchable then
	search = Instance.new('TextBox')
	search.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
	search.ClearTextOnFocus = false
	search.FontFace = uipallet.Font
	search.PlaceholderText = 'Search...'
	search.Size = UDim2.new(1, 0, 0, 27)
	search.Text = ''
	search.TextColor3 = uipallet.Text
	search.TextSize = 12
	search.Parent = panel
	addCorner(search, UDim.new(0, 5))
end

local entries = Instance.new('Frame')
entries.BackgroundTransparency = 1
entries.Position = UDim2.fromOffset(0, search and 31 or 0)
entries.Size = UDim2.new(1, 0, 0, 0)
entries.Parent = panel

local layout = Instance.new('UIListLayout')
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = entries

local function contains(value)
	return props.Multi and table.find(component.Value, value) ~= nil or component.Value == value
end

local function updateTitle()
	local value
	if props.Multi then
		local names = {}
		for _, selected in component.Value do
			for _, item in component.List do
				if item.value == selected then
					table.insert(names, item.text)
					break
				end
			end
		end
		value = #names > 0 and table.concat(names, ', ') or 'None'
	else
		value = 'None'
		for _, item in component.List do
			if item.value == component.Value then
				value = item.text
				break
			end
		end
	end
	title.Text = props.Name..' - '..value
end

local function updateSize()
	local visible = 0
	for _, child in entries:GetChildren() do
		if child:IsA('GuiObject') and child.Visible then visible += 1 end
	end
	local height = (search and 31 or 0) + (visible * 27)
	panel.Size = UDim2.new(1, -20, 0, height)
	root.Size = UDim2.new(1, 0, 0, component.Expanded and 40 + height or 40)
end

local function render(filter)
	entries:ClearAllChildren()
	layout = Instance.new('UIListLayout')
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = entries
	filter = string.lower(filter or '')
	local lastGroup
	for _, item in component.List do
		if filter ~= '' and not string.find(string.lower(item.text), filter, 1, true) then continue end
		if item.group and item.group ~= lastGroup then
			lastGroup = item.group
			local group = Instance.new('TextLabel')
			group.BackgroundTransparency = 1
			group.FontFace = uipallet.FontSemiBold
			group.Size = UDim2.new(1, 0, 0, 22)
			group.Text = item.group:upper()
			group.TextColor3 = color.Dark(uipallet.Text, 0.43)
			group.TextSize = 9
			group.TextXAlignment = Enum.TextXAlignment.Left
			group.Parent = entries
		end

		local entry = Instance.new('TextButton')
		entry.AutoButtonColor = false
		entry.BackgroundColor3 = contains(item.value) and color.Light(uipallet.Main, 0.08) or uipallet.Main
		entry.FontFace = uipallet.Font
		entry.Size = UDim2.new(1, 0, 0, 27)
		entry.Text = (item.icon and '      ' or '  ')..item.text
		entry.TextColor3 = contains(item.value) and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or color.Dark(uipallet.Text, 0.16)
		entry.TextSize = 12
		entry.TextXAlignment = Enum.TextXAlignment.Left
		entry.Parent = entries

		if item.icon then
			local icon = Instance.new('ImageLabel')
			icon.BackgroundTransparency = 1
			icon.Image = item.icon
			icon.Position = UDim2.fromOffset(5, 4)
			icon.Size = UDim2.fromOffset(19, 19)
			icon.Parent = entry
		end

		entry.MouseButton1Click:Connect(function()
			if props.Multi then
				local index = table.find(component.Value, item.value)
				if index then table.remove(component.Value, index) else table.insert(component.Value, item.value) end
			else
				component.Value = item.value
				component.Expanded = false
				component.Toggled = false
				panel.Visible = false
				arrow.Rotation = 90
			end
			updateTitle()
			props.Function(props.Multi and table.clone(component.Value) or component.Value)
			render(search and search.Text or '')
		end)
	end
	updateSize()
end

function component:Set(value, enabled)
	if props.Multi then
		local values = type(value) == 'table' and value or {value}
		if enabled == nil and type(value) == 'table' then
			self.Value = table.clone(value)
		else
			for _, entry in values do
				local index = table.find(self.Value, entry)
				if enabled == true and not index then
					table.insert(self.Value, entry)
				elseif enabled == false and index then
					table.remove(self.Value, index)
				elseif enabled == nil then
					if index then table.remove(self.Value, index) else table.insert(self.Value, entry) end
				end
			end
		end
	else
		self.Value = value
	end
	updateTitle()
	render(search and search.Text or '')
	props.Function(props.Multi and table.clone(self.Value) or self.Value)
end

component.SetValue = component.Set

function component:Refresh(list, replace)
	self.List = normalize(list)
	self.Options = {}
	for _, item in self.List do
		table.insert(self.Options, item.value)
	end
	if replace then self.Value = props.Multi and {} or nil end
	updateTitle()
	render(search and search.Text or '')
end

component.Change = component.Refresh
function component:Get()
	return props.Multi and table.clone(self.Value) or self.Value
end

function component:Has(value)
	return props.Multi and table.find(self.Value, value) ~= nil or self.Value == value
end

function component:UpdSel()
	updateTitle()
	render(search and search.Text or '')
end

function component:UpdVis()
	if self.Toggled ~= nil then self.Expanded = self.Toggled end
	panel.Visible = self.Expanded
	updateSize()
end

function component:Load(data)
	self:Set(data.Value)
end

function component:Save(data)
	data[props.Name] = {Value = self.Value}
end

button.MouseButton1Click:Connect(function()
	component.Expanded = not component.Expanded
	component.Toggled = component.Expanded
	panel.Visible = component.Expanded
	arrow.Rotation = component.Expanded and 270 or 90
	if not component.Expanded and search then search:ReleaseFocus(); search.Text = '' end
	render(search and search.Text or '')
end)

if search then
	search:GetPropertyChangedSignal('Text'):Connect(function()
		render(search.Text)
	end)
end

component.List = normalize(props.List)
for _, item in component.List do
	table.insert(component.Options, item.value)
end
component.Value = props.Multi and table.clone(props.Default or {}) or props.Default or (component.List[1] and component.List[1].value)
updateTitle()
render()
api.Options[props.Name] = component

return component
