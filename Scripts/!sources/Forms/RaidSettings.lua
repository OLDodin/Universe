local m_distanceSettingsForm = nil

function CreateRaidSettingsForm()
	local form=createWidget(mainForm, "raidSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 720, 620, 200, 100)
	hide(form)
	priority(form, 505)
	
	local group1 = createWidget(form, "group1", "Panel")
	align(group1, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group1, 315, 31)
	move(group1, 15, 47)
	
	local group2 = createWidget(form, "group2", "Panel")
	align(group2, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group2, 315, 61)
	move(group2, 15, 77)
	
	local group3 = createWidget(form, "group3", "Panel")
	align(group3, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group3, 315, 271)
	move(group3, 15, 137)

	local group4 = createWidget(form, "group4", "Panel")
	align(group4, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group4, 365, 211)
	move(group4, 335, 47)
	
	local group5 = createWidget(form, "group5", "Panel")
	align(group5, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group5, 365, 304)
	move(group5, 335, 257)
	
	setLocaleText(createWidget(form, "raidSettingsFormHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 150, 20, nil, 16))
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	createWidget(form, "showStandartRaidButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 50)
	
	createWidget(form, "gorisontalModeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 80)
	createWidget(form, "showRollOverInfoButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 110)
	
	createWidget(form, "showServerNameButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 140)
	createWidget(form, "classColorModeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 170)
	createWidget(form, "showClassIconButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 200)
	createWidget(form, "showProcentButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 230)
	createWidget(form, "showShieldButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 260)
	createWidget(form, "woundsShowButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 290)
	createWidget(form, "showManaButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 320)
	createWidget(form, "showDistanceButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 350)
	createWidget(form, "showArrowButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 380)
		
	setLocaleText(createWidget(form, "raidWidthText", "TextView", nil, nil, 200, 25, 20, 440))
	setLocaleText(createWidget(form, "raidHeightText", "TextView", nil, nil, 200, 25, 20, 470))
	setLocaleText(createWidget(form, "buffSizeText", "TextView", nil, nil, 200, 25, 20, 500))
	createWidget(form, "raidWidthEdit", "EditLine", nil, nil, 80, 25, 240, 440, nil, nil)
	createWidget(form, "raidHeightEdit", "EditLine", nil, nil, 80, 25, 240, 470, nil, nil)
	createWidget(form, "buffSizeEdit", "EditLine", nil, nil, 80, 25, 240, 500, nil, nil)
	setLocaleText(createWidget(form, "distanceButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 60, 530))
	
	setLocaleText(createWidget(form, "raidBuffsButton", "TextView", nil, nil, 200, 25, 410, 50))
	createWidget(form, "autoDebuffModeButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 340, 80)
	createWidget(form, "checkFriendCleanableButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 340, 110)
	createWidget(form, "colorDebuffButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 340, 140)
	createWidget(form, "showImportantButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 340, 170)
	createWidget(form, "checkControlsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 340, 200)
	createWidget(form, "checkMovementsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 25, 340, 230)
	setLocaleText(createWidget(form, "raidBuffsList", "TextView", nil, nil, 200, 25, 410, 260))
	createWidget(form, "container", "ScrollableContainer", nil, nil, 350, 245, 340, 280)
	setLocaleText(createWidget(form, "addRaidBuffButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 130, 25, 560, 530))
	createWidget(form, "EditLine1", "EditLine", nil, nil, 210, 25, 340, 530)
	
	
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	DnD.Init(form, form, true)
	
	m_distanceSettingsForm = CreateDistanceSettingsForm()	
	
	return form
end

function DistanceBtnPressed()
	DnD.ShowWdg(m_distanceSettingsForm)
end

function SaveRaidFormSettings(aForm)
	local mySettings = {}
	local profile = GetCurrentProfile()
	mySettings = profile.raidFormSettings
	
	mySettings.classColorModeButton = getCheckBoxState(getChild(aForm, "classColorModeButton"))
	mySettings.showServerNameButton = getCheckBoxState(getChild(aForm, "showServerNameButton"))
	mySettings.showManaButton = getCheckBoxState(getChild(aForm, "showManaButton"))
	mySettings.showShieldButton = getCheckBoxState(getChild(aForm, "showShieldButton"))
	mySettings.showStandartRaidButton = getCheckBoxState(getChild(aForm, "showStandartRaidButton"))
	mySettings.showClassIconButton = getCheckBoxState(getChild(aForm, "showClassIconButton"))
	mySettings.showDistanceButton = getCheckBoxState(getChild(aForm, "showDistanceButton"))
	mySettings.showProcentButton = getCheckBoxState(getChild(aForm, "showProcentButton"))
	mySettings.showArrowButton = getCheckBoxState(getChild(aForm, "showArrowButton"))
	mySettings.gorisontalModeButton = getCheckBoxState(getChild(aForm, "gorisontalModeButton"))
	mySettings.woundsShowButton = getCheckBoxState(getChild(aForm, "woundsShowButton"))
	mySettings.showRollOverInfo = getCheckBoxState(getChild(aForm, "showRollOverInfoButton"))

	
	mySettings.raidWidthText = getTextString(getChild(aForm, "raidWidthEdit"))
	mySettings.raidHeightText = getTextString(getChild(aForm, "raidHeightEdit"))
	mySettings.buffSize = getTextString(getChild(aForm, "buffSizeEdit"))

	mySettings.raidBuffs.autoDebuffModeButton = getCheckBoxState(getChild(aForm, "autoDebuffModeButton"))
	mySettings.raidBuffs.checkFriendCleanableButton = getCheckBoxState(getChild(aForm, "checkFriendCleanableButton"))
	mySettings.raidBuffs.showImportantButton = getCheckBoxState(getChild(aForm, "showImportantButton"))
	mySettings.raidBuffs.checkControlsButton = getCheckBoxState(getChild(aForm, "checkControlsButton"))
	mySettings.raidBuffs.checkMovementsButton = getCheckBoxState(getChild(aForm, "checkMovementsButton"))
	mySettings.raidBuffs.colorDebuffButton = getCheckBoxState(getChild(aForm, "colorDebuffButton"))

	
	UpdateTableValuesFromContainer(mySettings.raidBuffs.customBuffs, aForm)
	
	SaveDistanceFormSettings(m_distanceSettingsForm, mySettings)
	
	return mySettings
end

function LoadRaidFormSettings(aForm)
	local profile = GetCurrentProfile()
	local mySettings = profile.raidFormSettings
	if mySettings.raidBuffs.colorDebuffButton == nil then mySettings.raidBuffs.colorDebuffButton = false end
	if mySettings.raidBuffs.checkFriendCleanableButton == nil then mySettings.raidBuffs.checkFriendCleanableButton = false end
	
	setLocaleText(getChild(aForm, "classColorModeButton"), mySettings.classColorModeButton, true)
	setLocaleText(getChild(aForm, "showServerNameButton"), mySettings.showServerNameButton, true)
	setLocaleText(getChild(aForm, "showManaButton"), mySettings.showManaButton, true)
	setLocaleText(getChild(aForm, "showShieldButton"), mySettings.showShieldButton, true)
	setLocaleText(getChild(aForm, "showStandartRaidButton"), mySettings.showStandartRaidButton, true)
	setLocaleText(getChild(aForm, "showClassIconButton"), mySettings.showClassIconButton, true)
	setLocaleText(getChild(aForm, "showDistanceButton"), mySettings.showDistanceButton, true)
	setLocaleText(getChild(aForm, "showProcentButton"), mySettings.showProcentButton, true)
	setLocaleText(getChild(aForm, "showArrowButton"), mySettings.showArrowButton, true)
	setLocaleText(getChild(aForm, "gorisontalModeButton"), mySettings.gorisontalModeButton, true)
	setLocaleText(getChild(aForm, "woundsShowButton"), mySettings.woundsShowButton, true)
	setLocaleText(getChild(aForm, "showRollOverInfoButton"), mySettings.showRollOverInfo, true)
	
	setText(getChild(aForm, "raidWidthEdit"), mySettings.raidWidthText)
	setText(getChild(aForm, "raidHeightEdit"), mySettings.raidHeightText)
	setText(getChild(aForm, "buffSizeEdit"), mySettings.buffSize)
	
	setLocaleText(getChild(aForm, "autoDebuffModeButton"), mySettings.raidBuffs.autoDebuffModeButton, true)
	setLocaleText(getChild(aForm, "checkFriendCleanableButton"), mySettings.raidBuffs.checkFriendCleanableButton, true)
	setLocaleText(getChild(aForm, "colorDebuffButton"), mySettings.raidBuffs.colorDebuffButton, true)
	setLocaleText(getChild(aForm, "showImportantButton"), mySettings.raidBuffs.showImportantButton, true)
	setLocaleText(getChild(aForm, "checkControlsButton"), mySettings.raidBuffs.checkControlsButton, true)
	setLocaleText(getChild(aForm, "checkMovementsButton"), mySettings.raidBuffs.checkMovementsButton, true)
	
	ShowValuesFromTable(profile.raidFormSettings.raidBuffs.customBuffs, aForm)
	
	LoadDistanceFormSettings(m_distanceSettingsForm)
end