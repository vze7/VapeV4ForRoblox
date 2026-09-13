local component = {Type = 'Label', Value = props.Text or props.Name or ''}

local label = Instance.new('TextLabel')
label.AutomaticSize = Enum.AutomaticSize.Y
label.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
label.BorderSizePixel = 0
label.FontFace = uipallet.Font
label.RichText = props.RichText == true
label.Size = UDim2.new(1, 0, 0, 30)
label.Text = component.Value
label.TextColor3 = props.Color or color.Dark(uipallet.Text, 0.16)
label.TextSize = props.TextSize or 12
label.TextWrapped = true
label.TextXAlignment = props.Alignment or Enum.TextXAlignment.Left
label.Visible = props.Visible == nil or props.Visible
label.Parent = children
component.Object = label

local padding = Instance.new('UIPadding')
padding.PaddingBottom = UDim.new(0, 7)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 7)
padding.Parent = label

function component:Set(value, newColor, alignment)
	self.Value = tostring(value or '')
	label.Text = self.Value
	if newColor then label.TextColor3 = newColor end
	if alignment then label.TextXAlignment = alignment end
end

component.SetValue = component.Set
api.Options[props.Name or ('Label '..getTableSize(api.Options))] = component
return component
