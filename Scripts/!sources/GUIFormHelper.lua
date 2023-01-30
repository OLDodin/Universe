local m_reactions={}
local m_template = getChild(mainForm, "Template")

function AddReaction(aName, aFunc)
	if not m_reactions then
		m_reactions = {} 
	end
	m_reactions[aName] = aFunc
end

local function RunReaction(anWidget)
	local name=getName(anWidget)
	if name == "GetModeBtn" then
		name=getName(getParent(anWidget))
	end
	if not name or not m_reactions or not m_reactions[name] then return end
	m_reactions[name](anWidget)
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




function GetIndexForWidget(anWidget)
	local parent = getParent(anWidget)
	local container = getParent(getParent(getParent(parent)))
	if not parent or not container then 
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

local function GenerateWidgetForTable(aTable, aContainer, anIndex)
	setTemplateWidget(m_template)	
	local panel=createWidget(aContainer, nil, "Panel", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 30, nil, nil, true)
	setBackgroundColor(panel, {r=1, g=1, b=1, a=0.5})
	setText(createWidget(panel, "Id", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_CENTER, 30, 20, 10), anIndex)
	local containerParentName = getName(getParent(aContainer))
	
	if aTable.name then
		local editLineWidth = 150
		if containerParentName == "configProfilesForm" then
			editLineWidth = 290
		elseif containerParentName == "configGroupBuffsForm" then
			editLineWidth = 250
		elseif containerParentName == "raidSettingsForm" then
			editLineWidth = 200
		elseif containerParentName == "targeterSettingsForm" then
			editLineWidth = 160
		elseif containerParentName == "buffSettingsForm" then
			editLineWidth = 380
		elseif containerParentName == "castSettingsForm" then
			editLineWidth = 200
		end
		
		local nameWidget=createWidget(panel, "Name"..tostring(anIndex), "EditLineTransparent", WIDGET_ALIGN_LOW, WIDGET_ALIGN_CENTER, editLineWidth, 20, 35)
		setText(nameWidget, aTable.name)
	end
	
	if containerParentName == "configProfilesForm" then
		setText(createWidget(panel, "exportProfileButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 50, 15, 140), "Export") 
		if anIndex ~= GetCurrentProfileInd() then 
			setText(createWidget(panel, "loadProfileButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 50, 15, 30), "Load") 
		else
			setText(createWidget(panel, "saveProfileButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 50, 15, 85), "Save") 
		end
	elseif containerParentName == "configGroupBuffsForm" then
		if aTable.isBuff==nil then aTable.isBuff=true end
		if aTable.castByMe==nil then aTable.castByMe=false end
		if aTable.isSpell==nil then aTable.isSpell=false end

		setCheckBox(createWidget(panel, "isBuff"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 140), aTable.isBuff)
		setCheckBox(createWidget(panel, "castByMe"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 90), aTable.castByMe)
		setCheckBox(createWidget(panel, "isSpell"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 40), aTable.isSpell)
		
		setLocaleText(createWidget(panel, "setHighlightColorButton"..containerParentName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 30, 25, 190))
	elseif containerParentName == "raidSettingsForm" then
		setLocaleText(createWidget(panel, "setHighlightColorButton"..containerParentName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 30, 25, 30))
	elseif containerParentName == "targeterSettingsForm" then
		setLocaleText(createWidget(panel, "setHighlightColorButton"..containerParentName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 30, 25, 30))
	elseif containerParentName == "buffSettingsForm" then
		setText(createWidget(panel, "editButton"..containerParentName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 15, 15, 30), "e")
		--вечный пункт для над головой
		if anIndex ~= 1 then
			setText(createWidget(panel, "deleteButton"..containerParentName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 15, 15, 10), "x")
		end
		return panel
	end
	
	setText(createWidget(panel, "deleteButton"..containerParentName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 15, 15, 10), "x")

	return panel
end

function ShowValuesFromTable(aTable, aForm, aContainer)
	local container = aContainer
	if not aContainer then 
		container = getChild(aForm, "container") 
	end
	if not aTable or not container then 
		return nil 
	end
	if container.RemoveItems then 
		container:RemoveItems() 
	end
	for i, element in ipairs(aTable) do
		if container.PushBack then
			local widget=GenerateWidgetForTable(element, container, i)
			if widget then 
				container:PushBack(widget) 
			end
		end
	end
end

function DeleteContainer(aTable, anWidget, aForm)
	local parent = getParent(anWidget)
	local container = getParent(getParent(getParent(parent)))
	local index = GetIndexForWidget(anWidget)
	if container and index and aTable then
		container:RemoveAt(index)
		table.remove(aTable, index+1)
	end
	ShowValuesFromTable(aTable, aForm, container)
end

function UpdateTableValuesFromContainer(aTable, aForm, aContainer)
	local container = aContainer
	if not aContainer then 
		container = getChild(aForm, "container") 
	end
	if not container or not aTable then 
		return nil 
	end
	for i, j in ipairs(aTable) do
		j.name = getText(getChild(container, "Name"..tostring(i), true))
		j.nameLowerStr = toLowerString(j.name)
	end
end

function AddElementFromFormWithText(aTable, aForm, aText, aContainer)
	local text = aText
	local textLowerStr = toLowerString(text)
	if not aTable or not text or common.IsEmptyWString(text) then 
		return false 
	end
	table.insert(aTable, { name=text, nameLowerStr=textLowerStr } )
	ShowValuesFromTable(aTable, aForm, aContainer)
	return true
end

function AddElementFromForm(aTable, aForm, aTextedit, aContainer)
	if not aTextedit then aTextedit="EditLine1" end
	local text = getText(getChild(aForm, aTextedit))
	local res = AddElementFromFormWithText(aTable, aForm, text, aContainer)
	setText(getChild(aForm, aTextedit), "")
	return res
end