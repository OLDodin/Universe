local m_template = nil
local m_currentFormSettings = nil


function CreateTargeterSettingsForm()
	local form=createWidget(mainForm, "targeterSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 1000, 700, 200, 100)
	hide(form)
	priority(form, 505)
	
	local settingsContainer = createWidget(form, "settingsContainer", "ScrollableContainer", nil, nil, 350, 610, 5, 40)

	local group1 = createWidget(form, "group1", "Panel")
	align(group1, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group1, 315, 241)
	
	local group2 = createWidget(form, "group2", "Panel")
	align(group2, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group2, 315, 151)
	
	local group3 = createWidget(form, "group3", "Panel")
	align(group3, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group3, 315, 121)
	
	local group4 = createWidget(form, "group4", "Panel")
	align(group4, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group4, 315, 188)
	
	local group5 = createWidget(form, "group5", "Panel")
	align(group5, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group5, 335, 121)
	move(group5, 355, 47)
	
	local group6 = createWidget(form, "group6", "Panel")
	align(group6, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group6, 335, 475)
	move(group6, 355, 167)
	
	local group7 = createWidget(form, "group7", "Panel")
	align(group7, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group7, 295, 595)
	move(group7, 695, 47)	

	--colors
	local group8 = createWidget(form, "group8", "Panel")
	align(group8, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group8, 315, 151)
	
	local group9 = createWidget(form, "group9", "Panel")
	align(group9, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group9, 315, 151)
	
	local group10 = createWidget(form, "group10", "Panel")
	align(group10, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group10, 315, 151)
	
	local group11 = createWidget(form, "group11", "Panel")
	align(group11, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group11, 315, 151)

	
	setLocaleText(createWidget(form, "targeterSettingsFormHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 200, 20, nil, 16))
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")
		
	createWidget(group1, "showServerNameButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 3)
	createWidget(group1, "classColorModeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 33)
	createWidget(group1, "showClassIconButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 63)
	createWidget(group1, "showProcentButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 93)
	createWidget(group1, "showShieldButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 123)
	createWidget(group1, "showProcentShieldButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 153)
	createWidget(group1, "woundsShowButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 183)
	createWidget(group1, "showManaButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 213)
	
	createWidget(group2, "gorisontalModeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 3)
	createWidget(group2, "showRollOverInfoButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 33)
	createWidget(group2, "hideUnselectableButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 63)
	createWidget(group2, "separateBuffDebuff", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 93)
	createWidget(group2, "twoColumnMode", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 123)
	
	createWidget(group3, "sortByName", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 3)
	createWidget(group3, "sortByHP", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 33)
	createWidget(group3, "sortByClass", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 63)
	createWidget(group3, "sortByDead", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 93)
	
	setLocaleText(createWidget(group4, "targetLimitText", "TextView", nil, nil, 200, 25, 5, 8))
	setLocaleText(createWidget(group4, "raidWidthText", "TextView", nil, nil, 200, 25, 5, 38))
	setLocaleText(createWidget(group4, "raidHeightText", "TextView", nil, nil, 200, 25, 5, 68))
	setLocaleText(createWidget(group4, "buffSizeText", "TextView", nil, nil, 200, 25, 5, 98))
	setLocaleText(createWidget(group4, "buffsOpacityText", "TextView", nil, nil, 220, 25, 5, 128))
	createWidget(group4, "targetLimitEdit", "EditLine", nil, nil, 70, 25, 235, 8)
	createWidget(group4, "targeterWidthEdit", "EditLine", nil, nil, 70, 25, 235, 38)
	createWidget(group4, "targeterHeightEdit", "EditLine", nil, nil, 70, 25, 235, 68)
	createWidget(group4, "buffSizeEdit", "EditLine", nil, nil, 70, 25, 235, 98)
	createWidget(group4, "buffsOpacityEdit", "EditLine", nil, nil, 70, 25, 235, 128)
	createWidget(group4, "showBuffTimeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 158)

	
	settingsContainer:PushBack(group1)
	settingsContainer:PushBack(group2)
	settingsContainer:PushBack(group3)
	settingsContainer:PushBack(group4)
	settingsContainer:PushBack(group8)
	settingsContainer:PushBack(group9)
	settingsContainer:PushBack(group10)
	settingsContainer:PushBack(group11)

	
	setLocaleText(createWidget(group5, "raidBuffsButton", "TextView", nil, nil, 200, 25, 75, 3))
	createWidget(group5, "checkEnemyCleanable", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 33)
	createWidget(group5, "checkControlsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 63)
	createWidget(group5, "checkMovementsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 93)
	
	setLocaleText(createWidget(group6, "raidBuffsList", "TextView", nil, nil, 200, 25, 75, 3))
	setLocaleText(createWidget(group6, "configGroupBuffsId", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 30, 25, 15, 18))
	setLocaleText(createWidget(group6, "configGroupBuffsName", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 220, 25, 45, 18))
	setLocaleText(createWidget(group6, "castByMe", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 50, 25, 205, 18))
	createWidget(group6, "targetBuffContainer", "ScrollableContainer", nil, nil, 320, 410, 5, 23)
	setLocaleText(createWidget(group6, "addTargeterBuffButton", "Button", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_HIGH, nil, 25, 15, 5))
	
	setLocaleText(createWidget(group7, "myTargetsButton", "TextView", nil, nil, 200, 25, 75, 3))
	createWidget(group7, "myTargetsContainer", "ScrollableContainer", nil, nil, 280, 530, 5, 23)
	setLocaleText(createWidget(group7, "addTargetButton", "Button", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_HIGH, nil, 25, 15, 5))
	
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	DnD.Init(form, form, true)
		
	return form
end

function SaveTargeterFormSettings(aForm)
	local settingsContainer = getChild(aForm, "settingsContainer")
	local group1 = settingsContainer:At(0)
	local group2 = settingsContainer:At(1)
	local group3 = settingsContainer:At(2)
	local group4 = settingsContainer:At(3)
	local group5 = getChild(aForm, "group5")
	local group6 = getChild(aForm, "group6")
	local group7 = getChild(aForm, "group7")
	local group8 = settingsContainer:At(4)
	local group9 = settingsContainer:At(5)
	local group10 = settingsContainer:At(6)
	local group11 = settingsContainer:At(7)
	
	m_currentFormSettings.classColorModeButton = getCheckBoxState(getChild(group1, "classColorModeButton"))
	m_currentFormSettings.showServerNameButton = getCheckBoxState(getChild(group1, "showServerNameButton"))
	m_currentFormSettings.showManaButton = getCheckBoxState(getChild(group1, "showManaButton"))
	m_currentFormSettings.showEnergyButton = false
	m_currentFormSettings.showShieldButton = getCheckBoxState(getChild(group1, "showShieldButton"))
	m_currentFormSettings.showProcentShieldButton = getCheckBoxState(getChild(group1, "showProcentShieldButton"))
	m_currentFormSettings.showClassIconButton = getCheckBoxState(getChild(group1, "showClassIconButton"))
	m_currentFormSettings.showProcentButton = getCheckBoxState(getChild(group1, "showProcentButton"))
	m_currentFormSettings.woundsShowButton = getCheckBoxState(getChild(group1, "woundsShowButton"))
	
	m_currentFormSettings.gorisontalModeButton = getCheckBoxState(getChild(group2, "gorisontalModeButton"))
	m_currentFormSettings.showRollOverInfo = getCheckBoxState(getChild(group2, "showRollOverInfoButton"))
	m_currentFormSettings.hideUnselectableButton = getCheckBoxState(getChild(group2, "hideUnselectableButton"))
	m_currentFormSettings.separateBuffDebuff = getCheckBoxState(getChild(group2, "separateBuffDebuff"))
	m_currentFormSettings.twoColumnMode = getCheckBoxState(getChild(group2, "twoColumnMode"))
	
	m_currentFormSettings.sortByName = getCheckBoxState(getChild(group3, "sortByName"))
	m_currentFormSettings.sortByHP = getCheckBoxState(getChild(group3, "sortByHP"))
	m_currentFormSettings.sortByClass = getCheckBoxState(getChild(group3, "sortByClass"))
	m_currentFormSettings.sortByDead = getCheckBoxState(getChild(group3, "sortByDead"))
	
	m_currentFormSettings.raidWidthText = getTextString(getChild(group4, "targeterWidthEdit"))
	m_currentFormSettings.raidHeightText = getTextString(getChild(group4, "targeterHeightEdit"))
	m_currentFormSettings.buffSize = getTextString(getChild(group4, "buffSizeEdit"))
	
	local buffsOpacityEdit = getChild(group4, "buffsOpacityEdit")
	m_currentFormSettings.buffsOpacityText = CheckEditVal(tonumber(getTextString(buffsOpacityEdit)), 1.0, 0.1, 1.0, buffsOpacityEdit)
	local targetLimitEdit = getChild(group4, "targetLimitEdit")
	m_currentFormSettings.targetLimit = tostring(CheckEditVal(tonumber(getTextString(targetLimitEdit)), 12, 1, 30, targetLimitEdit))

	m_currentFormSettings.showBuffTimeButton = getCheckBoxState(getChild(group4, "showBuffTimeButton"))

	m_currentFormSettings.raidBuffs.checkEnemyCleanable = getCheckBoxState(getChild(group5, "checkEnemyCleanable"))
	m_currentFormSettings.raidBuffs.checkControlsButton = getCheckBoxState(getChild(group5, "checkControlsButton"))
	m_currentFormSettings.raidBuffs.checkMovementsButton = getCheckBoxState(getChild(group5, "checkMovementsButton"))
	
	local container = getChild(group6, "targetBuffContainer")
	if container and m_currentFormSettings.raidBuffs.customBuffs then
		for i, j in ipairs(m_currentFormSettings.raidBuffs.customBuffs) do
			j.name = getText(getChild(container, "Name"..tostring(i), true))
			j.castByMe = getCheckBoxState(getChild(container, "castByMe"..tostring(i), true))
		end
	end

	UpdateTableValuesFromContainer(m_currentFormSettings.myTargets, aForm, getChild(group7, "myTargetsContainer"))
	
	
	m_currentFormSettings.friendColor = getChild(getChild(group8, "colorSettingsForm"), "colorPreview"):GetBackgroundColor()
	m_currentFormSettings.neitralColor = getChild(getChild(group9, "colorSettingsForm"), "colorPreview"):GetBackgroundColor()
	m_currentFormSettings.enemyColor = getChild(getChild(group10, "colorSettingsForm"), "colorPreview"):GetBackgroundColor()
	m_currentFormSettings.selectionColor = getChild(getChild(group11, "colorSettingsForm"), "colorPreview"):GetBackgroundColor()

	return m_currentFormSettings
end

function LoadTargeterFormSettings(aForm)
	local settingsContainer = getChild(aForm, "settingsContainer")
	local group1 = settingsContainer:At(0)
	local group2 = settingsContainer:At(1)
	local group3 = settingsContainer:At(2)
	local group4 = settingsContainer:At(3)
	local group5 = getChild(aForm, "group5")
	local group6 = getChild(aForm, "group6")
	local group7 = getChild(aForm, "group7")
	local group8 = settingsContainer:At(4)
	local group9 = settingsContainer:At(5)
	local group10 = settingsContainer:At(6)
	local group11 = settingsContainer:At(7)
	
	local profile = GetCurrentProfile()
	m_currentFormSettings = deepCopyTable(profile.targeterFormSettings)
	
	if m_currentFormSettings.separateBuffDebuff == nil then m_currentFormSettings.separateBuffDebuff = false end
	if m_currentFormSettings.twoColumnMode == nil then m_currentFormSettings.twoColumnMode = false end
	if m_currentFormSettings.sortByName == nil then m_currentFormSettings.sortByName = true end
	if m_currentFormSettings.sortByHP == nil then m_currentFormSettings.sortByHP = false end
	if m_currentFormSettings.sortByClass == nil then m_currentFormSettings.sortByClass = false end
	if m_currentFormSettings.sortByDead == nil then m_currentFormSettings.sortByDead = false end
	if m_currentFormSettings.targetLimit == nil then m_currentFormSettings.targetLimit = "12" end
	
	setLocaleText(getChild(group1, "classColorModeButton"), m_currentFormSettings.classColorModeButton)
	setLocaleText(getChild(group1, "showServerNameButton"), m_currentFormSettings.showServerNameButton)
	setLocaleText(getChild(group1, "showManaButton"), m_currentFormSettings.showManaButton)
	setLocaleText(getChild(group1, "showShieldButton"), m_currentFormSettings.showShieldButton)
	setLocaleText(getChild(group1, "showClassIconButton"), m_currentFormSettings.showClassIconButton)
	setLocaleText(getChild(group1, "showProcentButton"), m_currentFormSettings.showProcentButton)
	setLocaleText(getChild(group1, "woundsShowButton"), m_currentFormSettings.woundsShowButton)
	setLocaleText(getChild(group1, "showProcentShieldButton"), m_currentFormSettings.showProcentShieldButton)
	
	setLocaleText(getChild(group2, "gorisontalModeButton"), m_currentFormSettings.gorisontalModeButton)
	setLocaleText(getChild(group2, "showRollOverInfoButton"), m_currentFormSettings.showRollOverInfo)
	setLocaleText(getChild(group2, "hideUnselectableButton"), m_currentFormSettings.hideUnselectableButton)
	setLocaleText(getChild(group2, "separateBuffDebuff"), m_currentFormSettings.separateBuffDebuff)
	setLocaleText(getChild(group2, "twoColumnMode"), m_currentFormSettings.twoColumnMode)
	
	setLocaleText(getChild(group3, "sortByName"), m_currentFormSettings.sortByName)
	setLocaleText(getChild(group3, "sortByHP"), m_currentFormSettings.sortByHP)
	setLocaleText(getChild(group3, "sortByClass"), m_currentFormSettings.sortByClass)
	setLocaleText(getChild(group3, "sortByDead"), m_currentFormSettings.sortByDead)
	
	setText(getChild(group4, "targeterWidthEdit"), m_currentFormSettings.raidWidthText)
	setText(getChild(group4, "targeterHeightEdit"), m_currentFormSettings.raidHeightText)
	setText(getChild(group4, "buffSizeEdit"), m_currentFormSettings.buffSize)
	setText(getChild(group4, "targetLimitEdit"), m_currentFormSettings.targetLimit)
	if m_currentFormSettings.buffsOpacityText == 1 then
		setText(getChild(group4, "buffsOpacityEdit"), "1.0")
	else
		setText(getChild(group4, "buffsOpacityEdit"), m_currentFormSettings.buffsOpacityText)
	end
	setLocaleText(getChild(group4, "showBuffTimeButton"), m_currentFormSettings.showBuffTimeButton)
	
	setLocaleText(getChild(group5, "checkEnemyCleanable"), m_currentFormSettings.raidBuffs.checkEnemyCleanable)
	setLocaleText(getChild(group5, "checkControlsButton"), m_currentFormSettings.raidBuffs.checkControlsButton)
	setLocaleText(getChild(group5, "checkMovementsButton"), m_currentFormSettings.raidBuffs.checkMovementsButton)

	ShowValuesFromTable(m_currentFormSettings.raidBuffs.customBuffs, aForm, getChild(group6, "targetBuffContainer"))
	ShowValuesFromTable(m_currentFormSettings.myTargets, aForm, getChild(group7, "myTargetsContainer"))
	
	destroy(getChild(group8, "colorSettingsForm"))
	destroy(getChild(group9, "colorSettingsForm"))
	destroy(getChild(group10, "colorSettingsForm"))
	destroy(getChild(group11, "colorSettingsForm"))
	
	CreateSimpleColorSettingsForm(group8, m_currentFormSettings.friendColor, "friendColorHeader")
	CreateSimpleColorSettingsForm(group9, m_currentFormSettings.neitralColor, "neitralColorHeader")
	CreateSimpleColorSettingsForm(group10, m_currentFormSettings.enemyColor, "enemyColorHeader")
	CreateSimpleColorSettingsForm(group11, m_currentFormSettings.selectionColor, "selectionColorHeader")
end

function AddTargetBuffToSroller(aForm)
	local group6 = getChild(aForm, "group6")
	AddElementFromForm(m_currentFormSettings.raidBuffs.customBuffs, aForm, getChild(group6, "targetBuffContainer")) 
end

function AddMyTargetsToSroller(aForm)
	local group7 = getChild(aForm, "group7")
	AddElementFromForm(m_currentFormSettings.myTargets, aForm, getChild(group7, "myTargetsContainer")) 
end

function DeleteTargetBuffFromSroller(aForm, aDeletingWdg)
	local container = getChild(getChild(aForm, "group6"), "targetBuffContainer")
	local panelOfElement = container:At(GetIndexForWidget(aDeletingWdg))
	local colorForm = getChild(panelOfElement, "colorSettingsForm")
	if colorForm then
		destroy(colorForm)
		resize(panelOfElement, nil, 30)
		container:ForceReposition()
	else
		DeleteContainer(m_currentFormSettings.raidBuffs.customBuffs, aDeletingWdg, aForm)
	end
end

function DeleteMyTargetsFromSroller(aForm, aDeletingWdg)
	DeleteContainer(m_currentFormSettings.myTargets, aDeletingWdg, aForm)
end

function CreateColorSettingsForTargetBuffScroller(aForm, anIndex)
	local container = getChild(getChild(aForm, "group6"), "targetBuffContainer")
	local panelOfElement = container:At(anIndex)
	
	local colorForm = getChild(panelOfElement, "colorSettingsForm")
	if colorForm then
		destroy(colorForm)
		resize(panelOfElement, nil, 30)		
	else
		colorForm = CreateColorSettingsForm(panelOfElement, m_currentFormSettings.raidBuffs.customBuffs[anIndex+1])
		resize(panelOfElement, nil, GetColorSettingsHeight())
	end
	container:ForceReposition()
end

function UpdateColorSettingsForTargetBuffScroller(aForm, anIndex)
	local container = getChild(getChild(aForm, "group6"), "targetBuffContainer")
	local panelOfElement = container:At(anIndex)

	local colorForm = getChild(panelOfElement, "colorSettingsForm")
	SaveBuffColorHighlight(colorForm, m_currentFormSettings.raidBuffs.customBuffs[anIndex+1])
	destroy(colorForm)
	resize(panelOfElement, nil, 30)
	container:ForceReposition()
end

function UpdateLastTargetType(aType)
	m_currentFormSettings.lastTargetType = aType
end

function UpdateLastTargetWasActive(aParam)
	m_currentFormSettings.lastTargetWasActive = aParam
end