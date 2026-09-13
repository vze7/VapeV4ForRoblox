return function(vape)
	local players = game:GetService('Players')
	local compat = {
		__VapeOrionCompat = true,
		elmnts = {},
		ThemeObjects = {},
		Connections = {},
		Flags = {},
		Windows = {},
		Toggles = {},
		Dropdowns = {},
		Folder = nil,
		UMouseMode = 'FreeMouse',
		maxds = 300,
		minds = 10,
		SelectedTheme = 'Default',
		CurrentTheme = 'Default',
		Themes = {}
	}
	local serial = 0

	local function nextName(tab, name)
		serial += 1
		return string.format('%s · %s [%d]', tab, name, serial)
	end

	local function bindFlag(config, object)
		if config.Flag then compat.Flags[config.Flag] = object end
		return object
	end

	local function keyName(value)
		if typeof(value) == 'EnumItem' then return value.Name end
		return tostring(value or '')
	end

	local function playerItems()
		local list = {}
		for _, player in players:GetPlayers() do
			table.insert(list, {
				text = string.format('%s (@%s)', player.DisplayName, player.Name),
				value = player.Name,
				icon = string.format('rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48', player.UserId)
			})
		end
		table.sort(list, function(a, b) return a.text:lower() < b.text:lower() end)
		return list
	end

	local function makeSection(tab, name)
		name = name or 'General'
		local module = tab.Category:CreateModule({
			Name = nextName(tab.Name, name),
			Tooltip = name,
			Function = function() end
		})
		local section = {Name = name, Module = module}

		function section:AddSection(config)
			module:CreateDivider({Text = type(config) == 'table' and config.Name or tostring(config or '')})
			return self
		end

		function section:AddLabel(text)
			return module:CreateLabel({Name = nextName(tab.Name, 'Label'), Text = tostring(text or '')})
		end

		function section:ColorLabel(text, labelColor, alignment)
			return module:CreateLabel({
				Name = nextName(tab.Name, 'ColorLabel'), Text = tostring(text or ''), Color = labelColor,
				Alignment = Enum.TextXAlignment[alignment or 'Left'] or Enum.TextXAlignment.Left
			})
		end

		function section:AddParagraph(title, content, alignment)
			title, content = tostring(title or ''), tostring(content or '')
			return module:CreateLabel({
				Name = nextName(tab.Name, title), Text = string.format('<b>%s</b>\n%s', title, content), RichText = true,
				Alignment = Enum.TextXAlignment[alignment or 'Left'] or Enum.TextXAlignment.Left
			})
		end

		function section:AddLog(text)
			return self:AddParagraph('Log', text)
		end

		function section:AddButton(config)
			config = config or {}
			return module:CreateButton({Name = config.Name or 'Button', Function = config.Callback})
		end

		function section:AddToggle(config)
			config = config or {}
			local native
			native = module:CreateToggle({
				Name = config.Name or 'Toggle', Default = config.Default,
				Function = function(value)
					if native then native.Value = value end
					if config.Callback then config.Callback(value) end
				end,
				Tooltip = config.Tooltip
			})
			function native:Set(value)
				value = not not value
				if self.Enabled ~= value then
					self:Toggle()
				else
					self.Value = value
				end
			end
			native.Value = native.Enabled
			return bindFlag(config, native)
		end

		function section:AddSlider(config)
			config = config or {}
			local decimal = config.Increment and config.Increment > 0 and (1 / config.Increment) or 1
			local sliderProps = {
				Name = config.Name or 'Slider', Min = config.Min or 0,
				Max = config.Max == math.huge and 1000000 or config.Max or 100,
				Default = config.Default, Decimal = decimal,
				Suffix = config.ValueName, Function = config.Callback
			}
			local native = module:CreateSlider(sliderProps)
			native.Set = native.SetValue
			native.Min = sliderProps.Min
			native.Max = sliderProps.Max
			function native:SetMax(value)
				sliderProps.Max = value == math.huge and 1000000 or value
				self.Max = sliderProps.Max
			end
			function native:SetMin(value)
				sliderProps.Min = value
				self.Min = value
			end
			function native:SetName() end
			if type(config.Block) == 'table' and type(config.varFunc) == 'function' then
				local alive = true
				module:Clean(function() alive = false end)
				task.spawn(function()
					while alive and native.Object and native.Object.Parent do
						local blocked = false
						local ok, values = pcall(config.varFunc, config.Block[1])
						if ok and type(values) == 'table' then
							blocked = values[config.Block[2]] == true
						end
						native.Object.Active = not blocked
						task.wait(0.1)
					end
				end)
			end
			return bindFlag(config, native)
		end

		function section:AddDropdown(config)
			config = config or {}
			local isPlayers = config.Players or config.PlayerList
			local native = module:CreateChoiceList({
				Name = config.Name or 'Dropdown', List = isPlayers and playerItems() or config.Options or {},
				Default = config.Default, Multi = config.Multi, Searchable = config.Searchable,
				Function = config.Callback
			})
			if isPlayers then
				local function refresh() native:Refresh(playerItems(), false) end
				module:Clean(players.PlayerAdded:Connect(refresh))
				module:Clean(players.PlayerRemoving:Connect(function(leaving)
					if config.Multi then
						local index = table.find(native.Value, leaving.Name)
						if index then table.remove(native.Value, index) end
					elseif native.Value == leaving.Name then native.Value = nil end
					refresh()
				end))
			end
			return bindFlag(config, native)
		end

		function section:AddPlayerDropdown(config)
			config = config or {}
			config.Players = true
			config.Searchable = config.Searchable ~= false
			return self:AddDropdown(config)
		end

		function section:AddBind(config)
			config = config or {}
			local callback = config.Callback or function() end
			local default = config.Default or Enum.KeyCode.Unknown
			local native = module:CreateBind({
				Name = config.Name or 'Bind', Default = {keyName(default)}, Hold = config.Hold,
				Function = callback
			})
			native.Triggered:Connect(callback)
			function native:Set(value)
				value = value or Enum.KeyCode.Unknown
				self:SetBind({keyName(value)})
				self.Value = value
			end
			native.Value = default
			return bindFlag(config, native)
		end

		function section:AddUiBind()
			local openKey = tab.Window.Config.Openkey
				or (vape.GUIBind and vape.GUIBind.Keys[1])
				or Enum.KeyCode.RightShift
			local native = self:AddBind({
				Name = 'Orion Bind',
				Default = openKey,
				Callback = function() end
			})
			local setBind = native.Set
			function native:Set(value)
				setBind(self, value)
				if vape.GUIBind then
					vape.GUIBind:SetBind({keyName(value)})
				end
				tab.Window.Config.Openkey = value
			end
			return native
		end

		function section:AddTextbox(config)
			config = config or {}
			local native
			native = module:CreateTextBox({
				Name = config.Name or 'Textbox', Default = config.Default,
				Placeholder = config.BackGrountText,
				Function = function() if native and config.Callback then config.Callback(native.Value) end end
			})
			native.Set = native.SetValue
			return bindFlag(config, native)
		end

		function section:AddColorpicker(config)
			config = config or {}
			local h, s, v = (config.Default or Color3.new(1, 1, 1)):ToHSV()
			local native = module:CreateColorSlider({
				Name = config.Name or 'Colorpicker', DefaultHue = h, DefaultSat = s, DefaultValue = v,
				Function = function(hue, sat, value) if config.Callback then config.Callback(Color3.fromHSV(hue, sat, value)) end end
			})
			function native:Set(value) self:SetValue(value:ToHSV()) end
			return bindFlag(config, native)
		end

		function section:AddPbind(config)
			config = config or {}
			local values = {config.DefaultX or '0', config.DefaultY or '0', config.DefaultZ or '0'}
			local fields = {}
			local pbind = {
				Values = values,
				ValueX = values[1], ValueY = values[2], ValueZ = values[3],
				Enabled = false,
				Type = 'PBind'
			}
			function pbind:toggle()
				self.Enabled = not self.Enabled
			end
			pbind.Toggle = pbind.toggle
			for index, axis in {'X', 'Y', 'Z'} do
				local native
				native = module:CreateTextBox({
					Name = (config.Name or 'Position')..' '..axis, Default = tostring(values[index]),
					Function = function()
						if native then
							values[index] = native.Value
							pbind['Value'..axis] = native.Value
						end
						if config.Callback then config.Callback(unpack(values)) end
					end
				})
				fields[index] = native
			end
			function pbind:Set(x, y, z)
				for index, value in {x, y, z} do
					if value ~= nil then
						local text = tostring(value)
						values[index] = text
						pbind['Value'..({'X', 'Y', 'Z'})[index]] = text
						fields[index].SetValue(fields[index], text)
					end
				end
			end
			return pbind
		end

		function section:AddSmartTheme()
			local theme = compat.Themes[compat.SelectedTheme] or compat.Themes.Default
			local picker = self:AddColorpicker({
				Name = 'Base Color', Default = theme.Main,
				Callback = function(value)
					compat.Themes.Custom = compat:GenTheme(value)
					compat.SelectedTheme = 'Custom'
					compat:SetTheme()
				end
			})
			local reset = self:AddButton({
				Name = 'Reset Theme',
				Callback = function()
					compat.SelectedTheme = 'Default'
					compat:SetTheme()
				end
			})
			compat.SelectedTheme = 'Default'
			compat:SetTheme()
			return picker, reset
		end

		function section:FreeMouseDrp()
			return self:AddDropdown({
				Name = 'Unlock Mouse Mode',
				Options = {'ThirdPerson', 'FreeMouse'},
				Default = compat.UMouseMode,
				Callback = function(value) compat.UMouseMode = value end
			})
		end
		return section
	end

	function compat:MakeWindow(config)
		config = config or {}
		self.Folder = config.ConfigFolder or config.Name or 'Vape'
		self.SaveConfig = config.SaveConfig == true
		local window = {Name = config.Name or 'Vape', Tabs = {}, Config = config}
		function window:MakeTab(tabConfig)
			tabConfig = tabConfig or {}
			local name = tabConfig.Name or 'Tab'
			local tab = {Name = name, Sections = {}, Window = window}
			tab.Category = vape.Categories[name] or vape:CreateCategory({
				Name = name,
				Icon = tabConfig.Icon or 'rbxasset://textures/ui/GuiImagePlaceholder.png',
				Size = UDim2.fromOffset(16, 16)
			})
			tab.Category.Object.Visible = true
			tab.Category.Button.Object.Visible = true
			local panelIndex = #window.Tabs
			tab.Category.Object.Position = UDim2.fromOffset(
				236 + ((panelIndex % 4) * 230),
				60 + (math.floor(panelIndex / 4) * 360)
			)
			function tab:AddSection(sectionConfig)
				local sectionName = type(sectionConfig) == 'table' and sectionConfig.Name or sectionConfig
				local section = makeSection(self, sectionName)
				table.insert(self.Sections, section)
				return section
			end
			setmetatable(tab, {__index = function(self, method)
				local section = self.Sections[#self.Sections] or self:AddSection({Name = 'General'})
				return section[method]
			end})
			table.insert(self.Tabs, tab)
			return tab
		end
		function window:SetName(parts)
			self.NameParts = parts
			if type(parts) == 'table' then self.Name = parts[1] or self.Name end
		end
		function window:ChangeIcon(icon) self.Icon = icon end
		function window:Destroy()
			if type(window.Config.CloseCallback) == 'function' then
				pcall(window.Config.CloseCallback)
			end
			compat:Destroy()
		end
		table.insert(self.Windows, window)
		return window
	end

	function compat:MakeNotification(config)
		config = config or {}
		vape:CreateNotification(config.Name or 'Vape', config.Content or '', config.Time or 5, config.Type)
	end

	function compat:GenTheme(mainColor)
		mainColor = mainColor or Color3.fromRGB(31, 20, 37)
		local r, g, b = mainColor.R * 255, mainColor.G * 255, mainColor.B * 255
		local dark = (0.299 * r + 0.587 * g + 0.114 * b) < 128
		local theme = {Main = mainColor}
		if dark then
			theme.Second = Color3.fromRGB(math.clamp(r * 1.12, 0, 255), math.clamp(g * 1.12, 0, 255), math.clamp(b * 1.12, 0, 255))
			theme.Stroke = Color3.fromRGB(math.clamp(r * 1.45, 0, 255), math.clamp(g * 1.45, 0, 255), math.clamp(b * 1.45, 0, 255))
			theme.Divider = Color3.fromRGB(math.clamp(r * 1.28, 0, 255), math.clamp(g * 1.28, 0, 255), math.clamp(b * 1.28, 0, 255))
			theme.Text, theme.TextDark = Color3.fromRGB(240, 240, 242), Color3.fromRGB(155, 155, 160)
			theme.Accent = Color3.fromRGB(math.clamp(r * 1.85, 0, 255), math.clamp(g * 1.85, 0, 255), math.clamp(b * 1.85, 0, 255))
		else
			theme.Second = Color3.fromRGB(math.clamp(r * 0.94, 0, 255), math.clamp(g * 0.94, 0, 255), math.clamp(b * 0.94, 0, 255))
			theme.Stroke = Color3.fromRGB(math.clamp(r * 0.75, 0, 255), math.clamp(g * 0.75, 0, 255), math.clamp(b * 0.75, 0, 255))
			theme.Divider = Color3.fromRGB(math.clamp(r * 0.85, 0, 255), math.clamp(g * 0.85, 0, 255), math.clamp(b * 0.85, 0, 255))
			theme.Text, theme.TextDark = Color3.fromRGB(35, 35, 38), Color3.fromRGB(110, 110, 115)
			theme.Accent = Color3.fromRGB(math.clamp(r * 0.72, 0, 255), math.clamp(g * 0.72, 0, 255), math.clamp(b * 0.72, 0, 255))
		end
		return theme
	end
	compat.Themes.Default = compat:GenTheme(Color3.fromRGB(31, 20, 37))
	compat.CurrentTheme = compat.Themes.Default
	function compat:SetTheme(theme)
		theme = theme or self.SelectedTheme
		if type(theme) == 'string' then theme = self.Themes[theme] end
		if type(theme) ~= 'table' then return end
		self.CurrentTheme = theme
		local accent = theme.Accent
		if typeof(accent) == 'Color3' then
			vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value = accent:ToHSV()
			vape:UpdateGUI()
		end
	end

	function compat:Init() return self end
	function compat:IsRunning() return vape.Loaded ~= nil end
	function compat:Destroy() vape:Uninject() end
	compat.DestroyLib = compat.Destroy
	compat.SaveCfg = function() vape:Save() end

	return compat
end
