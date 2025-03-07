
local function GenerateWidgetForContainer(anElement, aContainer, anIndex)
	setTemplateWidget("common")
	local editNameWdg = nil
	local ownerPanel = createWidget(mainForm, "containerMainPanel"..tostring(anIndex), "Panel", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 30, nil, nil)
	setBackgroundColor(ownerPanel, {r=1, g=1, b=1, a=0.5})
	local panel = createWidget(ownerPanel, "containerPanel", "PanelTransparent", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 30, 0, 0)
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
		
		editNameWdg = createWidget(panel, "Name"..tostring(anIndex), "EditLineTransparent", WIDGET_ALIGN_LOW, WIDGET_ALIGN_CENTER, editLineWidth, 20, 35)
		setText(editNameWdg, anElement.name)
	end
	
	if containerName == "configProfilesContainer" then
		setText(createWidget(panel, "exportProfileButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 50, 15, 140), "Export") 
		if anIndex ~= GetCurrentProfileInd() then 
			setText(createWidget(panel, "loadProfileButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 50, 15, 30), "Load") 
		else
			setText(createWidget(panel, "saveProfileButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 50, 15, 85), "Save") 
		end
	elseif containerName == "groupBuffContainer" then
		setCheckBox(createWidget(panel, "isBuff"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 140), anElement.isBuff)
		setCheckBox(createWidget(panel, "castByMe"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 90), anElement.castByMe)
		setCheckBox(createWidget(panel, "isSpell"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 40), anElement.isSpell)
		
		setLocaleText(createWidget(panel, "setHighlightColorButton"..containerName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 30, 25, 190))
	elseif containerName == "raidBuffContainer" then
		setLocaleText(createWidget(panel, "setHighlightColorButton"..containerName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 30, 25, 30))
	elseif containerName == "targetBuffContainer" then
		setCheckBox(createWidget(panel, "castByMe"..tostring(anIndex), "CheckBox", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 25, 25, 60), anElement.castByMe)
		setLocaleText(createWidget(panel, "setHighlightColorButton"..containerName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 30, 25, 30))
	elseif containerName == "ignoreListContainer" then		
		resize(ownerPanel, nil, 80)
		setLocaleText(createWidget(ownerPanel, "ignoreListExceptionsHeader", "TextView",  WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 20, 10, 25))
		setText(createWidget(ownerPanel, "exceptionsEdit"..tostring(anIndex), "EditLine", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 22, 10, 50), anElement.exceptionsEditText)
	end
	
	setText(createWidget(panel, "deleteButton"..containerName, "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_CENTER, 15, 15, 10), "x")

	return ownerPanel, editNameWdg
end

local function GetNameEditWdg(aContainerElement, anIndex)
	return getChild(getChild(aContainerElement, "containerPanel"), "Name"..tostring(anIndex))
end

local function GetIndexForWidgetByMainPanel(anWidget)
	local parentWdg = getParent(anWidget)
	
	while parentWdg do 
		local wdgName = getName(parentWdg)
		if findSimpleString(wdgName, "containerMainPanel") then
			local nStr = string.gsub(wdgName, "containerMainPanel", "")
			--container from 0
			return tonumber(nStr) - 1
		end
		parentWdg = getParent(parentWdg)
	end
end

SetGenerateWidgetForContainerFunc(GenerateWidgetForContainer)
SetGetNameEditWdgFromContainerFunc(GetNameEditWdg)
SetGetIndexForWidgetInContainerFunc(GetIndexForWidgetByMainPanel)