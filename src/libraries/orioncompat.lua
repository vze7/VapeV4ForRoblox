return function(vape)
	local players = game:GetService('Players')
	local compat = {Flags = {}, Windows = {}}
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
		local module = tab.Category:CreateModule({
			Name = nextName(tab.Name, name),
			Tooltip = name,
			Function = function() end
		})
		local section = {Name = name, Module = module}

		function section:AddSection(config)
			module:CreateDivider({Text = type(config) == 'table' and config.Name or tostring(config)})
			return self
		end

		function section:AddLabel(text)
			return module:CreateLabel({Name = nextName(tab.Name, 'Label'), Text = tostring(text)})
		end

		function section:ColorLabel(text, labelColor, alignment)
			return module:CreateLabel({
				Name = nextName(tab.Name, 'ColorLabel'), Text = tostring(text), Color = labelColor,
				Alignment = Enum.TextXAlignment[alignment or 'Left'] or Enum.TextXAlignment.Left
			})
		end

		function section:AddParagraph(title, content, alignment)
			return module:CreateLabel({
				Name = nextName(tab.Name, title), Text = string.format('<b>%s</b>\n%s', title, content), RichText = true,
				Alignment = Enum.TextXAlignment[alignment or 'Left'] or Enum.TextXAlignment.Left
			})
		end

		function section:AddLog(text)
			return self:AddParagraph('Log', text)
		end

		function section:AddButton(config)
			module:CreateButton({Name = config.Name or 'Button', Function = config.Callback})
			return {Set = function() end}
		end

		function section:AddToggle(config)
			local native
			native = module:CreateToggle({
				Name = config.Name or 'Toggle', Default = config.Default,
				Function = function(value)
					if native then native.Value = value end
					if config.Callback then config.Callback(value) end
				end,
				Tooltip = config.Tooltip
			})
			function native:Set(value) if self.Enabled ~= not not value then self:Toggle() end end
			native.Value = native.Enabled
			return bindFlag(config, native)
		end

		function section:AddSlider(config)
			local decimal = config.Increment and config.Increment > 0 and (1 / config.Increment) or 1
			local native = module:CreateSlider({
				Name = config.Name or 'Slider', Min = config.Min or 0,
				Max = config.Max == math.huge and 1000000 or config.Max or 100,
				Default = config.Default, Decimal = decimal,
				Suffix = config.ValueName, Function = config.Callback
			})
			native.Set = native.SetValue
			function native:SetMax(value) self.Max = value end
			function native:SetMin() end
			function native:SetName() end
			return bindFlag(config, native)
		end

		function section:AddDropdown(config)
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
			config.Players = true
			config.Searchable = config.Searchable ~= false
			return self:AddDropdown(config)
		end

		function section:AddBind(config)
			local callback = config.Callback or function() end
			local native = module:CreateBind({
				Name = config.Name or 'Bind', Default = {keyName(config.Default)}, Hold = config.Hold,
				Function = callback
			})
			native.Triggered:Connect(callback)
			function native:Set(value) self:SetBind({keyName(value)}) end
			native.Value = config.Default
			return bindFlag(config, native)
		end

		function section:AddTextbox(config)
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
			local h, s, v = (config.Default or Color3.new(1, 1, 1)):ToHSV()
			local native = module:CreateColorSlider({
				Name = config.Name or 'Colorpicker', DefaultHue = h, DefaultSat = s, DefaultValue = v,
				Function = function(hue, sat, value) if config.Callback then config.Callback(Color3.fromHSV(hue, sat, value)) end end
			})
			function native:Set(value) self:SetValue(value:ToHSV()) end
			return bindFlag(config, native)
		end

		function section:AddPbind(config)
			local values = {config.DefaultX or '0', config.DefaultY or '0', config.DefaultZ or '0'}
			for index, axis in {'X', 'Y', 'Z'} do
				local native
				native = module:CreateTextBox({
					Name = (config.Name or 'Position')..' '..axis, Default = values[index],
					Function = function()
						if native then values[index] = native.Value end
						if config.Callback then config.Callback(unpack(values)) end
					end
				})
			end
		end

		function section:AddSmartTheme()
			return self:AddColorpicker({
				Name = 'Theme color', Default = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value),
				Callback = function(value)
					vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value = value:ToHSV()
					vape:UpdateGUI()
				end
			})
		end

		section.FreeMouseDrp = function() end
		return section
	end

	function compat:MakeWindow(config)
		local window = {Name = config.Name or 'Vape', Tabs = {}, Config = config}
		function window:MakeTab(tabConfig)
			local name = tabConfig.Name or 'Tab'
			local tab = {Name = name, Sections = {}}
			tab.Category = vape.Categories[name] or vape:CreateCategory({
				Name = name,
				Icon = tabConfig.Icon or 'rbxasset://textures/ui/GuiImagePlaceholder.png',
				Size = UDim2.fromOffset(16, 16)
			})
			function tab:AddSection(sectionConfig)
				local section = makeSection(self, type(sectionConfig) == 'table' and sectionConfig.Name or tostring(sectionConfig))
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
		function window:SetName(...) self.NameParts = {...} end
		function window:ChangeIcon(icon) self.Icon = icon end
		function window:Destroy() compat:Destroy() end
		table.insert(self.Windows, window)
		return window
	end

	function compat:MakeNotification(config)
		vape:CreateNotification(config.Name or 'Vape', config.Content or '', config.Time or 5, config.Type)
	end

	function compat:Init() return self end
	function compat:IsRunning() return vape.Loaded ~= nil end
	function compat:Destroy() vape:Uninject() end
	compat.DestroyLib = compat.Destroy
	compat.SaveCfg = function() vape:Save() end

	return compat
end
