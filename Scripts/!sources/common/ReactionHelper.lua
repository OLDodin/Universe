local m_reactions={}
local m_rightClickReactions={}
local m_defaultMessage = getLocale()["enterName"]
local m_generateFunc = nil
local m_getNameEditWdgFunc = nil
local m_getIndexForWidgetFunc = nil

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
	if DnD.IsDragging() then
		return
	end
	RunReaction(aParams.widget)
end

function CheckBoxChangedOn(aParams)
	changeCheckBox(aParams.widget)
	ButtonPressed(aParams)
end

function CheckBoxChangedOff(aParams)
	changeCheckBox(aParams.widget)
	ButtonPressed(aParams)
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

function HideDropDownSelectPanel(anWidget)
	if anWidget:IsVisible() then
		local dropDownPanel = getParent(anWidget)
		dropDownPanel:SetPriority(dropDownPanel:GetPriority() - 1000)
		hide(anWidget)
	end
end

function GenerateBtnForDropDown(anWidget, aTextArr, aDefaultIndex, aColor)
	local selectPanel = getChild(anWidget, "DropDownSelectPanel")
	setTemplateWidget("common")
	if not aColor then
		aColor = "ColorWhite"
	end
	local cnt = 0
	for i, txt in ipairs(aTextArr) do
		local btn = createWidget(selectPanel, "modeBtn"..tostring(i), "DropDownSelectButton", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 25, 0, 24*(i-1)+2)
		setText(btn, txt, aColor)
		show(btn)
		cnt = cnt + 1
	end
	
	if not aDefaultIndex then
		aDefaultIndex = 1
	end
	setText(getChild(getChild(anWidget, "DropDownHeaderPanel"), "ModeNameTextView"), aTextArr[aDefaultIndex], "Neutral", "left", 11)
	
	resize(anWidget, nil, 24*(cnt+1))
	
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


function SetGenerateWidgetForContainerFunc(aFunc)
	m_generateFunc = aFunc
end

function SetGetNameEditWdgFromContainerFunc(aFunc)
	m_getNameEditWdgFunc = aFunc
end

function SetGetIndexForWidgetInContainerFunc(aFunc)
	m_getIndexForWidgetFunc = aFunc
end

local function GetContainerFromParent(anWidget)
	local parentWdg = getParent(anWidget)
	while parentWdg do
		if apitype(parentWdg) == "Widget_ScrollableContainerSafe" then
			return parentWdg
		end
		parentWdg = getParent(parentWdg)
	end
end

function GetIndexForWidget(anWidget)
	if not m_getIndexForWidgetFunc then
		return nil
	end
	return m_getIndexForWidgetFunc(anWidget)
end

function ShowValuesFromTable(aTable, aForm, aContainer)
	if not aTable or not aContainer then 
		return nil 
	end

	local containerArr = {}
	for i = 0, aContainer:GetElementCount() - 1 do
		table.insert(containerArr, aContainer:At(i))
	end
	
	aContainer:RemoveItems()
	
	for _, containerWdg in ipairs(containerArr) do
		containerWdg:DestroyWidget()
	end
	
	if not m_generateFunc then
		return
	end

	local lastWdg = nil
	for i, element in ipairs(aTable) do
		lastWdg = m_generateFunc(element, aContainer, i)
		if lastWdg then 
			aContainer:PushBack(lastWdg) 
		end
	end
end

function DeleteContainer(aTable, anWidget, aForm)
	local container = GetContainerFromParent(anWidget)
	local index = GetIndexForWidget(anWidget)
	if not container or not aTable or not index then
		return
	end
	--update names
	UpdateTableValuesFromContainer(aTable, aForm, container)

	local deletingWdg = container:At(index)
	container:RemoveAt(index)
	table.remove(aTable, index+1)

	container:ForceReposition()
	deletingWdg:DestroyWidget()
	
	local offset = container:GetContainerOffset()
	--update index 
	ShowValuesFromTable(aTable, aForm, container)
	
	container:SetContainerOffset(offset)
end

function UpdateTableValuesFromContainer(aTable, aForm, aContainer)
	if not aContainer or not aTable or not m_getNameEditWdgFunc then 
		return nil 
	end
	if GetTableSize(aTable) ~= aContainer:GetElementCount() then
		return nil 
	end
	local containerName = getName(aContainer)
	
	for i = 0, aContainer:GetElementCount() - 1 do
		local editLine = m_getNameEditWdgFunc(aContainer:At(i), i+1)
		editLine:SetFocus(false)
		local tableElement = aTable[i+1]
		tableElement.name = getText(editLine)
		if containerName == "myTargetsContainer" then
			tableElement.nameLowerStr = toLowerString(tableElement.name)
		else
			tableElement.nameLowerStr = nil
		end
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

	if not m_generateFunc then
		return
	end
	local wdg = m_generateFunc({ name=text, nameLowerStr=textLowerStr }, aContainer, GetTableSize(aTable))
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

	local newElement = { name=m_defaultMessage, nameLowerStr=toLowerString(m_defaultMessage) }
	table.insert(aTable, newElement )
	
	if not m_generateFunc then
		return
	end
	
	local index = GetTableSize(aTable)
	local wdg, editNameWdg = m_generateFunc(newElement, aContainer, index)
	if wdg then 
		aContainer:PushBack(wdg) 
		aContainer:ForceReposition()
		aContainer:EnsureVisible(wdg)
		editNameWdg:SetFocus(true)
	end
	
	return true
end

function AddElementFromFormWithEditLine(aTable, aForm, aEditLine, aContainer)
	local text = getText(aEditLine)
	if not text or text:IsEmpty() then
		setText(aEditLine, m_defaultMessage)
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

function CheckEditVal(aVal, aDefaultVal, aMinVal, aMaxVal, aWdg)
	if not aVal or aVal < aMinVal or aVal > aMaxVal then
		aVal = aDefaultVal
		setText(aWdg, aVal)
	end
	return aVal
end