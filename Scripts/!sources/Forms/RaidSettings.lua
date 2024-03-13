local m_currentFormSettings = nil

function CreateRaidSettingsForm()
	local form=createWidget(mainForm, "raidSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 730, 660, 200, 100)
	hide(form)
	priority(form, 505)
	
	local settingsContainer = createWidget(form, "settingsContainer", "ScrollableContainer", nil, nil, 350, 545, 5, 40)
	
	local group1 = createWidget(form, "group1", "Panel")
	align(group1, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group1, 315, 31)
	
	local group2 = createWidget(form, "group2", "Panel")
	align(group2, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group2, 315, 61)
	
	local group3 = createWidget(form, "group3", "Panel")
	align(group3, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group3, 315, 271)

	local group4 = createWidget(form, "group4", "Panel")
	align(group4, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group4, 315, 101)
	
	local group5 = createWidget(form, "group5", "Panel")
	align(group5, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group5, 315, 131)
	
	local group6 = createWidget(form, "group6", "Panel")
	align(group6, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group6, 365, 211)
	move(group6, 355, 47)
	
	local group7 = createWidget(form, "group7", "Panel")
	align(group7, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group7, 365, 344)
	move(group7, 355, 257)
	
	setLocaleText(createWidget(form, "raidSettingsFormHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 150, 20, nil, 16))
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")
	
	createWidget(group1, "showStandartRaidButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 3)
	
	createWidget(group2, "gorisontalModeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 3)
	createWidget(group2, "showRollOverInfoButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 33)
	
	createWidget(group3, "showServerNameButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 3)
	createWidget(group3, "classColorModeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 33)
	createWidget(group3, "showClassIconButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 63)
	createWidget(group3, "showProcentButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 93)
	createWidget(group3, "showShieldButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 123)
	createWidget(group3, "woundsShowButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 153)
	createWidget(group3, "showManaButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 183)
	createWidget(group3, "showDistanceButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 213)
	createWidget(group3, "showArrowButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 243)
		
	setLocaleText(createWidget(group4, "raidWidthText", "TextView", nil, nil, 200, 25, 5, 8))
	setLocaleText(createWidget(group4, "raidHeightText", "TextView", nil, nil, 200, 25, 5, 38))
	setLocaleText(createWidget(group4, "buffSizeText", "TextView", nil, nil, 200, 25, 5, 68))
	createWidget(group4, "raidWidthEdit", "EditLine", nil, nil, 70, 25, 235, 8)
	createWidget(group4, "raidHeightEdit", "EditLine", nil, nil, 70, 25, 235, 38)
	createWidget(group4, "buffSizeEdit", "EditLine", nil, nil, 70, 25, 235, 68)
	
	setLocaleText(createWidget(group5, "distanceSettingsFormHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 250, 20, nil, 3))
	setLocaleText(createWidget(group5, "distanceText", "TextView", nil, nil, 200, 25, 5, 38))
	createWidget(group5, "distanceEdit", "EditLine", nil, nil, 70, 25, 235, 38)
	createWidget(group5, "showGrayOnDistanceButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 68)
	createWidget(group5, "showFrameStripOnDistanceButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 98)
	
	
	settingsContainer:PushBack(group1)
	settingsContainer:PushBack(group2)
	settingsContainer:PushBack(group3)
	settingsContainer:PushBack(group4)
	settingsContainer:PushBack(group5)
	
	
	setLocaleText(createWidget(group6, "raidBuffsButton", "TextView", nil, nil, 200, 25, 75, 3))
	createWidget(group6, "autoDebuffModeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 5, 33)
	createWidget(group6, "checkFriendCleanableButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 5, 63)
	createWidget(group6, "colorDebuffButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 5, 93)
	createWidget(group6, "showImportantButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 5, 123)
	createWidget(group6, "checkControlsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 5, 153)
	createWidget(group6, "checkMovementsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 5, 183)
	
	setLocaleText(createWidget(group7, "raidBuffsList", "TextView", nil, nil, 200, 25, 75, 3))
	createWidget(group7, "raidBuffContainer", "ScrollableContainer", nil, nil, 350, 285, 5, 23)
	setLocaleText(createWidget(group7, "addRaidBuffButton", "Button", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_HIGH, nil, 25, 25, 5))
	
	
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	DnD.Init(form, form, true)
		
	return form
end

function RaidSettingsСolorDebuffButtonCheckedOn(aForm)
	local group6 = getChild(aForm, "group6")
	if getCheckBoxState(getChild(group6, "colorDebuffButton")) then
		setCheckBox(getChild(group6, "checkFriendCleanableButton"), true)
	end
end

function SaveRaidFormSettings(aForm)
	local settingsContainer = getChild(aForm, "settingsContainer")
	local group1 = settingsContainer:At(0)
	local group2 = settingsContainer:At(1)
	local group3 = settingsContainer:At(2)
	local group4 = settingsContainer:At(3)
	local group5 = settingsContainer:At(4)
	local group6 = getChild(aForm, "group6")
	local group7 = getChild(aForm, "group7")
	

	m_currentFormSettings.showStandartRaidButton = getCheckBoxState(getChild(group1, "showStandartRaidButton"))
	m_currentFormSettings.gorisontalModeButton = getCheckBoxState(getChild(group2, "gorisontalModeButton"))
	m_currentFormSettings.showRollOverInfo = getCheckBoxState(getChild(group2, "showRollOverInfoButton"))
	m_currentFormSettings.classColorModeButton = getCheckBoxState(getChild(group3, "classColorModeButton"))
	m_currentFormSettings.showServerNameButton = getCheckBoxState(getChild(group3, "showServerNameButton"))
	m_currentFormSettings.showManaButton = getCheckBoxState(getChild(group3, "showManaButton"))
	m_currentFormSettings.showShieldButton = getCheckBoxState(getChild(group3, "showShieldButton"))
	m_currentFormSettings.showClassIconButton = getCheckBoxState(getChild(group3, "showClassIconButton"))
	m_currentFormSettings.showDistanceButton = getCheckBoxState(getChild(group3, "showDistanceButton"))
	m_currentFormSettings.showProcentButton = getCheckBoxState(getChild(group3, "showProcentButton"))
	m_currentFormSettings.showArrowButton = getCheckBoxState(getChild(group3, "showArrowButton"))
	m_currentFormSettings.woundsShowButton = getCheckBoxState(getChild(group3, "woundsShowButton"))
	
	m_currentFormSettings.raidWidthText = getTextString(getChild(group4, "raidWidthEdit"))
	m_currentFormSettings.raidHeightText = getTextString(getChild(group4, "raidHeightEdit"))
	m_currentFormSettings.buffSize = getTextString(getChild(group4, "buffSizeEdit"))
	
	m_currentFormSettings.distanceText = getTextString(getChild(group5, "distanceEdit"))
	m_currentFormSettings.showGrayOnDistanceButton = getCheckBoxState(getChild(group5, "showGrayOnDistanceButton"))
	m_currentFormSettings.showFrameStripOnDistanceButton = getCheckBoxState(getChild(group5, "showFrameStripOnDistanceButton"))

	m_currentFormSettings.raidBuffs.autoDebuffModeButton = getCheckBoxState(getChild(group6, "autoDebuffModeButton"))
	m_currentFormSettings.raidBuffs.checkFriendCleanableButton = getCheckBoxState(getChild(group6, "checkFriendCleanableButton"))
	m_currentFormSettings.raidBuffs.showImportantButton = getCheckBoxState(getChild(group6, "showImportantButton"))
	m_currentFormSettings.raidBuffs.checkControlsButton = getCheckBoxState(getChild(group6, "checkControlsButton"))
	m_currentFormSettings.raidBuffs.checkMovementsButton = getCheckBoxState(getChild(group6, "checkMovementsButton"))
	m_currentFormSettings.raidBuffs.colorDebuffButton = getCheckBoxState(getChild(group6, "colorDebuffButton"))

	
	UpdateTableValuesFromContainer(m_currentFormSettings.raidBuffs.customBuffs, aForm, getChild(group7, "raidBuffContainer"))
		
	return m_currentFormSettings
end

function LoadRaidFormSettings(aForm)
	local settingsContainer = getChild(aForm, "settingsContainer")
	local group1 = settingsContainer:At(0)
	local group2 = settingsContainer:At(1)
	local group3 = settingsContainer:At(2)
	local group4 = settingsContainer:At(3)
	local group5 = settingsContainer:At(4)
	local group6 = getChild(aForm, "group6")
	local group7 = getChild(aForm, "group7")
	
	local profile = GetCurrentProfile()
	m_currentFormSettings = deepCopyTable(profile.raidFormSettings)
	if m_currentFormSettings.raidBuffs.colorDebuffButton == nil then m_currentFormSettings.raidBuffs.colorDebuffButton = false end
	if m_currentFormSettings.raidBuffs.checkFriendCleanableButton == nil then m_currentFormSettings.raidBuffs.checkFriendCleanableButton = false end
	
	setLocaleText(getChild(group1, "showStandartRaidButton"), m_currentFormSettings.showStandartRaidButton)
	setLocaleText(getChild(group2, "gorisontalModeButton"), m_currentFormSettings.gorisontalModeButton)
	setLocaleText(getChild(group2, "showRollOverInfoButton"), m_currentFormSettings.showRollOverInfo)
	setLocaleText(getChild(group3, "classColorModeButton"), m_currentFormSettings.classColorModeButton)
	setLocaleText(getChild(group3, "showServerNameButton"), m_currentFormSettings.showServerNameButton)
	setLocaleText(getChild(group3, "showManaButton"), m_currentFormSettings.showManaButton)
	setLocaleText(getChild(group3, "showShieldButton"), m_currentFormSettings.showShieldButton)
	setLocaleText(getChild(group3, "showClassIconButton"), m_currentFormSettings.showClassIconButton)
	setLocaleText(getChild(group3, "showDistanceButton"), m_currentFormSettings.showDistanceButton)
	setLocaleText(getChild(group3, "showProcentButton"), m_currentFormSettings.showProcentButton)
	setLocaleText(getChild(group3, "showArrowButton"), m_currentFormSettings.showArrowButton)
	setLocaleText(getChild(group3, "woundsShowButton"), m_currentFormSettings.woundsShowButton)
	
	setText(getChild(group4, "raidWidthEdit"), m_currentFormSettings.raidWidthText)
	setText(getChild(group4, "raidHeightEdit"), m_currentFormSettings.raidHeightText)
	setText(getChild(group4, "buffSizeEdit"), m_currentFormSettings.buffSize)
	
	setText(getChild(group5, "distanceEdit"), m_currentFormSettings.distanceText)
	setLocaleText(getChild(group5, "showGrayOnDistanceButton"), m_currentFormSettings.showGrayOnDistanceButton)
	setLocaleText(getChild(group5, "showFrameStripOnDistanceButton"), m_currentFormSettings.showFrameStripOnDistanceButton)
	
	setLocaleText(getChild(group6, "autoDebuffModeButton"), m_currentFormSettings.raidBuffs.autoDebuffModeButton)
	setLocaleText(getChild(group6, "checkFriendCleanableButton"), m_currentFormSettings.raidBuffs.checkFriendCleanableButton)
	setLocaleText(getChild(group6, "colorDebuffButton"), m_currentFormSettings.raidBuffs.colorDebuffButton)
	setLocaleText(getChild(group6, "showImportantButton"), m_currentFormSettings.raidBuffs.showImportantButton)
	setLocaleText(getChild(group6, "checkControlsButton"), m_currentFormSettings.raidBuffs.checkControlsButton)
	setLocaleText(getChild(group6, "checkMovementsButton"), m_currentFormSettings.raidBuffs.checkMovementsButton)
	
	ShowValuesFromTable(m_currentFormSettings.raidBuffs.customBuffs, aForm, getChild(group7, "raidBuffContainer"))
end

function AddRaidBuffToSroller(aForm)
	local group7 = getChild(aForm, "group7")
	AddElementFromForm(m_currentFormSettings.raidBuffs.customBuffs, aForm, getChild(group7, "raidBuffContainer")) 
end

function DeleteRaidBuffFromSroller(aForm, aDeletingWdg)
	DeleteContainer(m_currentFormSettings.raidBuffs.customBuffs, aDeletingWdg, aForm)
end

function CreateColorSettingsForRaidBuffScroller(aForm, anIndex)
	local raidBuffContainer = getChild(getChild(aForm, "group7"), "raidBuffContainer")
	local panelOfElement = raidBuffContainer:At(anIndex)
	
	local colorForm = getChild(panelOfElement, "colorSettingsForm")
	if colorForm then
		destroy(colorForm)
		resize(panelOfElement, nil, 30)		
	else
		colorForm = CreateColorSettingsForm(m_currentFormSettings.raidBuffs.customBuffs[anIndex+1])
		resize(panelOfElement, nil, GetColorSettingsHeight())
		panelOfElement:AddChild(colorForm)
	end
	raidBuffContainer:ForceReposition()
end

function UpdateColorSettingsForRaidBuffScroller(aForm, anIndex)
	local raidBuffContainer = getChild(getChild(aForm, "group7"), "raidBuffContainer")
	local panelOfElement = raidBuffContainer:At(anIndex)

	local colorForm = getChild(panelOfElement, "colorSettingsForm")
	SaveBuffColorHighlight(colorForm, m_currentFormSettings.raidBuffs.customBuffs[anIndex+1])
	destroy(colorForm)
	resize(panelOfElement, nil, 30)
	raidBuffContainer:ForceReposition()
end