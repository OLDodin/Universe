local m_template = nil



function CreateTargeterSettingsForm()
	local form=createWidget(mainForm, "targeterSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 1000, 700, 200, 100)
	hide(form)
	priority(form, 505)
	
	local settingsContainer = createWidget(form, "settingsContainer", "ScrollableContainer", nil, nil, 350, 610, 5, 40)

	local group1 = createWidget(form, "group1", "Panel")
	align(group1, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group1, 315, 211)
	
	local group2 = createWidget(form, "group2", "Panel")
	align(group2, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group2, 315, 121)
	
	local group3 = createWidget(form, "group3", "Panel")
	align(group3, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group3, 315, 121)
	
	local group4 = createWidget(form, "group4", "Panel")
	align(group4, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group4, 315, 128)
	
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

	setLocaleText(createWidget(form, "targeterSettingsFormHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 200, 20, nil, 16))
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")
		
	createWidget(group1, "showServerNameButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 3)
	createWidget(group1, "classColorModeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 33)
	createWidget(group1, "showClassIconButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 63)
	createWidget(group1, "showProcentButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 93)
	createWidget(group1, "showShieldButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 123)
	createWidget(group1, "woundsShowButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 153)
	createWidget(group1, "showManaButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 5, 183)
	
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
	createWidget(group4, "targetLimitEdit", "EditLine", nil, nil, 70, 25, 235, 8)
	createWidget(group4, "targeterWidthEdit", "EditLine", nil, nil, 70, 25, 235, 38)
	createWidget(group4, "targeterHeightEdit", "EditLine", nil, nil, 70, 25, 235, 68)
	createWidget(group4, "buffSizeEdit", "EditLine", nil, nil, 70, 25, 235, 98)
	
	settingsContainer:PushBack(group1)
	settingsContainer:PushBack(group2)
	settingsContainer:PushBack(group3)
	settingsContainer:PushBack(group4)
	
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
	
	local mySettings = {}
	local profile = GetCurrentProfile()
	mySettings = profile.targeterFormSettings
	
	mySettings.classColorModeButton = getCheckBoxState(getChild(group1, "classColorModeButton"))
	mySettings.showServerNameButton = getCheckBoxState(getChild(group1, "showServerNameButton"))
	mySettings.showManaButton = getCheckBoxState(getChild(group1, "showManaButton"))
	mySettings.showEnergyButton = false
	mySettings.showShieldButton = getCheckBoxState(getChild(group1, "showShieldButton"))
	mySettings.showClassIconButton = getCheckBoxState(getChild(group1, "showClassIconButton"))
	mySettings.showProcentButton = getCheckBoxState(getChild(group1, "showProcentButton"))
	mySettings.woundsShowButton = getCheckBoxState(getChild(group1, "woundsShowButton"))
	
	mySettings.gorisontalModeButton = getCheckBoxState(getChild(group2, "gorisontalModeButton"))
	mySettings.showRollOverInfo = getCheckBoxState(getChild(group2, "showRollOverInfoButton"))
	mySettings.hideUnselectableButton = getCheckBoxState(getChild(group2, "hideUnselectableButton"))
	mySettings.separateBuffDebuff = getCheckBoxState(getChild(group2, "separateBuffDebuff"))
	mySettings.twoColumnMode = getCheckBoxState(getChild(group2, "twoColumnMode"))
	
	mySettings.sortByName = getCheckBoxState(getChild(group3, "sortByName"))
	mySettings.sortByHP = getCheckBoxState(getChild(group3, "sortByHP"))
	mySettings.sortByClass = getCheckBoxState(getChild(group3, "sortByClass"))
	mySettings.sortByDead = getCheckBoxState(getChild(group3, "sortByDead"))
	
	mySettings.raidWidthText = getTextString(getChild(group4, "targeterWidthEdit"))
	mySettings.raidHeightText = getTextString(getChild(group4, "targeterHeightEdit"))
	mySettings.buffSize = getTextString(getChild(group4, "buffSizeEdit"))
	mySettings.targetLimit = getTextString(getChild(group4, "targetLimitEdit"))
	local limit = tonumber(mySettings.targetLimit)
	if limit > 30 then
		mySettings.targetLimit = "30"
	end
	if limit < 1 then
		mySettings.targetLimit = "1"
	end
	setText(getChild(group4, "targetLimitEdit"), mySettings.targetLimit)

	mySettings.raidBuffs.checkEnemyCleanable = getCheckBoxState(getChild(group5, "checkEnemyCleanable"))
	mySettings.raidBuffs.checkControlsButton = getCheckBoxState(getChild(group5, "checkControlsButton"))
	mySettings.raidBuffs.checkMovementsButton = getCheckBoxState(getChild(group5, "checkMovementsButton"))
	
	local container = getChild(group6, "targetBuffContainer")
	if container and mySettings.raidBuffs.customBuffs then
		for i, j in ipairs(mySettings.raidBuffs.customBuffs) do
			j.name = getText(getChild(container, "Name"..tostring(i), true))
			j.castByMe = getCheckBoxState(getChild(container, "castByMe"..tostring(i), true))
		end
	end

	UpdateTableValuesFromContainer(mySettings.myTargets, aForm, getChild(group7, "myTargetsContainer"))

	return mySettings
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
	
	local profile = GetCurrentProfile()
	local mySettings = profile.targeterFormSettings
	if mySettings.separateBuffDebuff == nil then mySettings.separateBuffDebuff = false end
	if mySettings.twoColumnMode == nil then mySettings.twoColumnMode = false end
	if mySettings.sortByName == nil then mySettings.sortByName = true end
	if mySettings.sortByHP == nil then mySettings.sortByHP = false end
	if mySettings.sortByClass == nil then mySettings.sortByClass = false end
	if mySettings.sortByDead == nil then mySettings.sortByDead = false end
	if mySettings.targetLimit == nil then mySettings.targetLimit = "12" end
	
	setLocaleText(getChild(group1, "classColorModeButton"), mySettings.classColorModeButton)
	setLocaleText(getChild(group1, "showServerNameButton"), mySettings.showServerNameButton)
	setLocaleText(getChild(group1, "showManaButton"), mySettings.showManaButton)
	setLocaleText(getChild(group1, "showShieldButton"), mySettings.showShieldButton)
	setLocaleText(getChild(group1, "showClassIconButton"), mySettings.showClassIconButton)
	setLocaleText(getChild(group1, "showProcentButton"), mySettings.showProcentButton)
	setLocaleText(getChild(group1, "woundsShowButton"), mySettings.woundsShowButton)
	
	setLocaleText(getChild(group2, "gorisontalModeButton"), mySettings.gorisontalModeButton)
	setLocaleText(getChild(group2, "showRollOverInfoButton"), mySettings.showRollOverInfo)
	setLocaleText(getChild(group2, "hideUnselectableButton"), mySettings.hideUnselectableButton)
	setLocaleText(getChild(group2, "separateBuffDebuff"), mySettings.separateBuffDebuff)
	setLocaleText(getChild(group2, "twoColumnMode"), mySettings.twoColumnMode)
	
	setLocaleText(getChild(group3, "sortByName"), mySettings.sortByName)
	setLocaleText(getChild(group3, "sortByHP"), mySettings.sortByHP)
	setLocaleText(getChild(group3, "sortByClass"), mySettings.sortByClass)
	setLocaleText(getChild(group3, "sortByDead"), mySettings.sortByDead)
	
	setText(getChild(group4, "targeterWidthEdit"), mySettings.raidWidthText)
	setText(getChild(group4, "targeterHeightEdit"), mySettings.raidHeightText)
	setText(getChild(group4, "buffSizeEdit"), mySettings.buffSize)
	setText(getChild(group4, "targetLimitEdit"), mySettings.targetLimit)
	
	setLocaleText(getChild(group5, "checkEnemyCleanable"), mySettings.raidBuffs.checkEnemyCleanable)
	setLocaleText(getChild(group5, "checkControlsButton"), mySettings.raidBuffs.checkControlsButton)
	setLocaleText(getChild(group5, "checkMovementsButton"), mySettings.raidBuffs.checkMovementsButton)

	ShowValuesFromTable(profile.targeterFormSettings.raidBuffs.customBuffs, aForm, getChild(group6, "targetBuffContainer"))
	ShowValuesFromTable(profile.targeterFormSettings.myTargets, aForm, getChild(group7, "myTargetsContainer"))
end