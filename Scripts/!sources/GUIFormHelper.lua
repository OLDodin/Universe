local m_reactions={}
local m_rightClickReactions={}
local m_template = getChild(mainForm, "Template")

function AddReaction(aName, aFunc)
	if not m_reactions then
		m_reactions = {} 
	end
	m_reactions[aName] = aFunc
end

function AddRightClickReaction(aName, aFunc)
	if not m_rightClickReactions then
		m_rightClickReactions = {} 
	end
	m_rightClickReactions[aName] = aFunc
end

local function RunRightClickReaction(anWidget)
	local name=getName(anWidget)
	if not name or not m_rightClickReactions or not m_rightClickReactions[name] then return end
	m_rightClickReactions[name](anWidget)
end

local function RunReaction(anWidget, aParams)
	local name=getName(anWidget)
	if not name or not m_reactions or not m_reactions[name] then return end
	m_reactions[name](anWidget, aParams)
end

function ButtonPressed(aParams)
	RunReaction(aParams.widget)
end

function CheckBoxChangedOn(aParams)
	changeCheckBox(aParams.widget)
	ButtonPressed(aParams)
end

function CheckBoxChangedOff(aParams)
	changeCheckBox(aParams.widget)
end

function DropDownBtnPressed(aParams)
	local dropDownPanel = getParent(getParent(aParams.widget))
	if aParams.widget:GetVariant() == 1 then
		return
	end
	local selectPanel = getChild(dropDownPanel, "DropDownSelectPanel")
	if selectPanel:IsVisible() then
		dropDownPanel:SetPriority(dropDownPanel:GetPriority() - 1000)
	else
		dropDownPanel:SetPriority(dropDownPanel:GetPriority() + 1000)
	end
	swap(selectPanel)
end

function DropDownBtnRightClick(aParams)
	local dropDownPanel = getParent(getParent(aParams.widget))
	RunRightClickReaction(dropDownPanel)
end

function SelectDropDownBtnPressed(aParams)
	local pressedWdgName = getName(aParams.widget)
	local prefixStr = "modeBtn"
	local indexStr = pressedWdgName:sub(prefixStr:len()+1, pressedWdgName:len())
	local pressedIndex = tonumber(indexStr)
	
	local dropDownPanel = getParent(getParent(aParams.widget))
	HideDropDownSelectPanel(getChild(dropDownPanel, "DropDownSelectPanel"))
	setText(getChild(getChild(dropDownPanel, "DropDownHeaderPanel"), "ModeNameTextView"), aParams.widget:GetWString(), "Neutral", "left", 11)
	
	RunReaction(dropDownPanel, pressedIndex)
end





local defaultMessage = Locales["enterName"]

function HideDropDownSelectPanel(anWidget)
	if anWidget:IsVisible() then
		local dropDownPanel = getParent(anWidget)
		dropDownPanel:SetPriority(dropDownPanel:GetPriority() - 1000)
		hide(anWidget)
	end
end

function GenerateBtnForDropDown(anWidget, aTextArr, aDefaultIndex, aColor)
	local selectPanel = getChild(anWidget, "DropDownSelectPanel")
	setTemplateWidget(selectPanel)
	if not aColor then
		aColor = { a = 1, r = 1, g = 1, b = 1 }
	end
	local cnt = 0
	for i, txt in ipairs(aTextArr) do
		local btn = createWidget(selectPanel, "modeBtn"..tostring(i), "SelectButton", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 25, 0, 24*(i-1)+2)
		setText(btn, txt)
		btn:SetTextColor(nil, aColor)
		show(btn)
		cnt = cnt + 1
	end
	
	if not aDefaultIndex then
		aDefaultIndex = 1
	end
	setText(getChild(getChild(anWidget, "DropDownHeaderPanel"), "ModeNameTextView"), aTextArr[aDefaultIndex], "Neutral", "left", 11)
	
	resize(anWidget, nil, 24*(cnt+1))
	setTemplateWidget(m_template)
	
	return anWidget
end

function CheckDropDownOrientation(anWidget)
	local wdgParent = getParent(anWidget)
	local selectPanel = getChild(anWidget, "DropDownSelectPanel")
	local dropDownHeaderPanel = getChild(anWidget, "DropDownHeaderPanel")
	
	local parentPlacement = wdgParent:GetPlacementPlain()
	local dropDownPanelPlacement = anWidget:GetPlacementPlain()
	local selectPanelPlacement = selectPanel:GetPlacementPlain()
	
	if dropDownPanelPlacement.posY + dropDownPanelPlacement.sizeY > parentPlacement.sizeY then
		if dropDownPanelPlacement.posY > dropDownPanelPlacement.sizeY then
			align(selectPanel, nil, WIDGET_ALIGN_LOW)
			resize(selectPanel, nil, dropDownPanelPlacement.sizeY - 24)
			move(selectPanel, nil, 0)
			move(anWidget, nil, dropDownPanelPlacement.posY - dropDownPanelPlacement.sizeY + 24)
			align(dropDownHeaderPanel, nil, WIDGET_ALIGN_HIGH)
		end
	end
end

function GetIndexForWidget(anWidget)
	local container = getParent(anWidget, 5)
	if not container then 
		return nil
	end
	local index = nil
	for i=0, container:GetElementCount() do
		if equals(anWidget, getChild(container:At(i), getName(anWidget), true)) then 
			return i 
		end
	end
	return index
end

local function GenerateWidgetForContainer(anElement, aContainer, anIndex)
	setTemplateWidget(m_template)	
	local ownerPanel=createWidget(nil, "containerMainPanel"..tostring(anIndex), "Panel", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 30, nil, nil, true)
	setBackgroundColor(ownerPanel, {r=1, g=1, b=1, a=0.5})
	local panel=createWidget(ownerPanel, "containerPanel", "PanelTransparent", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 30, 0, 0)
	setText(createWidget(panel, "Id", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_CENTER, 30, 20, 10), anIndex)
	local containerName = getName(aContainer)
	
	if anElement.name then
		local editLineWidth = 150
		if containerName == "configProfilesContainer" then
			editLineWidth = 290
		elseif containerName == "groupBuffContainer" then
			editLineWidth = 250
		elseif containerName == "raidBuffContainer" then
			editLineWidth = 200
		elseif containerName == "myTargetsContainer" then
			editLineWidth = 170
		elseif containerName == "targetBuffContainer" then
			editLineWidth = 170
		elseif containerName == "ignoreListContainer" then
			editLineWidth = 200
		end
		
		local nameWidget=createWidget(panel, "Name"..tostring(anIndex), "EditLineTransparent", WIDGET_ALIGN_LOW, WIDGET_ALIGN_CENTER, editLineWidth, 20, 35)
		setText(nameWidget, anElement.name)
	end
	
	if containerName == "configProfilesContainer" then
		setText(createWidget(panel, "exportProfileButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 50, 15, 140), "Export") 
		if anIndex ~= GetCurrentProfileInd() then 
			setText(createWidget(panel, "loadProfileButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 50, 15, 30), "Load") 
		else
			setText(createWidget(panel, "saveProfileButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 50, 15, 85), "Save") 
		end
	elseif containerName == "groupBuffContainer" then
		if anElement.isBuff==nil then anElement.isBuff=true end
		if anElement.castByMe==nil then anElement.castByMe=false end
		if anElement.isSpell==nil then anElement.isSpell=false end

		setCheckBox(createWidget(panel, "isBuff"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 140), anElement.isBuff)
		setCheckBox(createWidget(panel, "castByMe"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 90), anElement.castByMe)
		setCheckBox(createWidget(panel, "isSpell"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 40), anElement.isSpell)
		
		setLocaleText(createWidget(panel, "setHighlightColorButton"..containerName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 30, 25, 190))
	elseif containerName == "raidBuffContainer" then
		setLocaleText(createWidget(panel, "setHighlightColorButton"..containerName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 30, 25, 30))
	elseif containerName == "targetBuffContainer" then
		if anElement.castByMe==nil then anElement.castByMe=false end
		setCheckBox(createWidget(panel, "castByMe"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 60), anElement.castByMe)
		setLocaleText(createWidget(panel, "setHighlightColorButton"..containerName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 30, 25, 30))
	end
	
	setText(createWidget(panel, "deleteButton"..containerName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 15, 15, 10), "x")

	return ownerPanel
end

function ShowValuesFromTable(aTable, aForm, aContainer)
	if not aTable or not aContainer then 
		return nil 
	end
	if aContainer.RemoveItems then 
		aContainer:RemoveItems()
	end
	local lastWdg = nil
	for i, element in ipairs(aTable) do
		lastWdg = GenerateWidgetForContainer(element, aContainer, i)
		if lastWdg then 
			aContainer:PushBack(lastWdg) 
		end
	end
end

function DeleteContainer(aTable, anWidget, aForm)
	local container = getParent(anWidget, 5)
	local index = GetIndexForWidget(anWidget)
	if not container or not aTable or not index then
		return
	end
	--update names
	UpdateTableValuesFromContainer(aTable, aForm, container)

	container:RemoveAt(index)
	table.remove(aTable, index+1)

	container:ForceReposition()
	local offset = container:GetContainerOffset()
	--update index 
	ShowValuesFromTable(aTable, aForm, container)
	
	container:SetContainerOffset(offset)
end

function UpdateTableValuesFromContainer(aTable, aForm, aContainer)
	if not aContainer or not aTable then 
		return nil 
	end
	for i, j in ipairs(aTable) do
		j.name = getText(getChild(aContainer, "Name"..tostring(i), true))
		j.nameLowerStr = toLowerString(j.name)
	end
end

function AddElementFromFormWithText(aTable, aForm, aText, aContainer)
	local text = aText
	local textLowerStr = toLowerString(text)
	if not aTable or not text or text:IsEmpty() then 
		return false 
	end
	if not aContainer then 
		return false 
	end
	table.insert(aTable, { name=text, nameLowerStr=textLowerStr } )

	local wdg = GenerateWidgetForContainer({ name=text, nameLowerStr=textLowerStr }, aContainer, GetTableSize(aTable))
	if wdg then 
		aContainer:PushBack(wdg) 
		aContainer:ForceReposition()
		aContainer:EnsureVisible(wdg)
	end
	return true
end

function AddElementFromForm(aTable, aForm, aContainer)
	if not aTable then 
		return false 
	end

	local newElement = { name=defaultMessage, nameLowerStr=toLowerString(defaultMessage) }
	table.insert(aTable, newElement )
	
	local index = GetTableSize(aTable)
	local wdg = GenerateWidgetForContainer(newElement, aContainer, index)
	if wdg then 
		aContainer:PushBack(wdg) 
		aContainer:ForceReposition()
		aContainer:EnsureVisible(wdg)
		getChild(wdg, "Name"..tostring(index), true):SetFocus(true)
	end
	
	return true
end

function AddElementFromFormWithEditLine(aTable, aForm, aEditLine, aContainer)
	local text = getText(aEditLine)
	if not text or text:IsEmpty() then
		setText(aEditLine, defaultMessage)
		aEditLine:SetFocus(true)
		return false 
	end
	local res = AddElementFromFormWithText(aTable, aForm, text, aContainer)
	setText(aEditLine, "")
	return res
end

function FindWdgInContainer(aContainer, aWdgName)
	for i = 0, aContainer:GetElementCount() - 1 do
		local wdg = aContainer:At(i)
		if getName(wdg) == aWdgName then
			return wdg
		end
	end
end