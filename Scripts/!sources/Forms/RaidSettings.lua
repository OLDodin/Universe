function CreateRaidSettingsForm()
	local form=createWidget(mainForm, "raidSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 730, 620, 200, 100)
	hide(form)
	priority(form, 505)
	
	local settingsContainer = createWidget(form, "settingsContainer", "ScrollableContainer", nil, nil, 350, 525, 5, 40)
	
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
	resize(group7, 365, 304)
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
	createWidget(group7, "raidBuffContainer", "ScrollableContainer", nil, nil, 350, 245, 5, 23)
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
	
	local mySettings = {}
	local profile = GetCurrentProfile()
	mySettings = profile.raidFormSettings
	
	mySettings.showStandartRaidButton = getCheckBoxState(getChild(group1, "showStandartRaidButton"))
	mySettings.gorisontalModeButton = getCheckBoxState(getChild(group2, "gorisontalModeButton"))
	mySettings.showRollOverInfo = getCheckBoxState(getChild(group2, "showRollOverInfoButton"))
	mySettings.classColorModeButton = getCheckBoxState(getChild(group3, "classColorModeButton"))
	mySettings.showServerNameButton = getCheckBoxState(getChild(group3, "showServerNameButton"))
	mySettings.showManaButton = getCheckBoxState(getChild(group3, "showManaButton"))
	mySettings.showShieldButton = getCheckBoxState(getChild(group3, "showShieldButton"))
	mySettings.showClassIconButton = getCheckBoxState(getChild(group3, "showClassIconButton"))
	mySettings.showDistanceButton = getCheckBoxState(getChild(group3, "showDistanceButton"))
	mySettings.showProcentButton = getCheckBoxState(getChild(group3, "showProcentButton"))
	mySettings.showArrowButton = getCheckBoxState(getChild(group3, "showArrowButton"))
	mySettings.woundsShowButton = getCheckBoxState(getChild(group3, "woundsShowButton"))
	
	mySettings.raidWidthText = getTextString(getChild(group4, "raidWidthEdit"))
	mySettings.raidHeightText = getTextString(getChild(group4, "raidHeightEdit"))
	mySettings.buffSize = getTextString(getChild(group4, "buffSizeEdit"))
	
	mySettings.distanceText = getTextString(getChild(group5, "distanceEdit"))
	mySettings.showGrayOnDistanceButton = getCheckBoxState(getChild(group5, "showGrayOnDistanceButton"))
	mySettings.showFrameStripOnDistanceButton = getCheckBoxState(getChild(group5, "showFrameStripOnDistanceButton"))

	mySettings.raidBuffs.autoDebuffModeButton = getCheckBoxState(getChild(group6, "autoDebuffModeButton"))
	mySettings.raidBuffs.checkFriendCleanableButton = getCheckBoxState(getChild(group6, "checkFriendCleanableButton"))
	mySettings.raidBuffs.showImportantButton = getCheckBoxState(getChild(group6, "showImportantButton"))
	mySettings.raidBuffs.checkControlsButton = getCheckBoxState(getChild(group6, "checkControlsButton"))
	mySettings.raidBuffs.checkMovementsButton = getCheckBoxState(getChild(group6, "checkMovementsButton"))
	mySettings.raidBuffs.colorDebuffButton = getCheckBoxState(getChild(group6, "colorDebuffButton"))

	
	UpdateTableValuesFromContainer(mySettings.raidBuffs.customBuffs, aForm, getChild(group7, "raidBuffContainer"))
		
	return mySettings
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
	local mySettings = profile.raidFormSettings
	if mySettings.raidBuffs.colorDebuffButton == nil then mySettings.raidBuffs.colorDebuffButton = false end
	if mySettings.raidBuffs.checkFriendCleanableButton == nil then mySettings.raidBuffs.checkFriendCleanableButton = false end
	
	setLocaleText(getChild(group1, "showStandartRaidButton"), mySettings.showStandartRaidButton)
	setLocaleText(getChild(group2, "gorisontalModeButton"), mySettings.gorisontalModeButton)
	setLocaleText(getChild(group2, "showRollOverInfoButton"), mySettings.showRollOverInfo)
	setLocaleText(getChild(group3, "classColorModeButton"), mySettings.classColorModeButton)
	setLocaleText(getChild(group3, "showServerNameButton"), mySettings.showServerNameButton)
	setLocaleText(getChild(group3, "showManaButton"), mySettings.showManaButton)
	setLocaleText(getChild(group3, "showShieldButton"), mySettings.showShieldButton)
	setLocaleText(getChild(group3, "showClassIconButton"), mySettings.showClassIconButton)
	setLocaleText(getChild(group3, "showDistanceButton"), mySettings.showDistanceButton)
	setLocaleText(getChild(group3, "showProcentButton"), mySettings.showProcentButton)
	setLocaleText(getChild(group3, "showArrowButton"), mySettings.showArrowButton)
	setLocaleText(getChild(group3, "woundsShowButton"), mySettings.woundsShowButton)
	
	setText(getChild(group4, "raidWidthEdit"), mySettings.raidWidthText)
	setText(getChild(group4, "raidHeightEdit"), mySettings.raidHeightText)
	setText(getChild(group4, "buffSizeEdit"), mySettings.buffSize)
	
	setText(getChild(group5, "distanceEdit"), mySettings.distanceText)
	setLocaleText(getChild(group5, "showGrayOnDistanceButton"), mySettings.showGrayOnDistanceButton)
	setLocaleText(getChild(group5, "showFrameStripOnDistanceButton"), mySettings.showFrameStripOnDistanceButton)
	
	setLocaleText(getChild(group6, "autoDebuffModeButton"), mySettings.raidBuffs.autoDebuffModeButton)
	setLocaleText(getChild(group6, "checkFriendCleanableButton"), mySettings.raidBuffs.checkFriendCleanableButton)
	setLocaleText(getChild(group6, "colorDebuffButton"), mySettings.raidBuffs.colorDebuffButton)
	setLocaleText(getChild(group6, "showImportantButton"), mySettings.raidBuffs.showImportantButton)
	setLocaleText(getChild(group6, "checkControlsButton"), mySettings.raidBuffs.checkControlsButton)
	setLocaleText(getChild(group6, "checkMovementsButton"), mySettings.raidBuffs.checkMovementsButton)
	
	ShowValuesFromTable(mySettings.raidBuffs.customBuffs, aForm, getChild(group7, "raidBuffContainer"))
end