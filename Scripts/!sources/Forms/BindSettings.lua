local m_template = nil
local m_locale = getLocale()
local m_currentFormSettings = nil

Global("DISABLE_CLICK", 0)
Global("SELECT_CLICK", 1)
Global("MENU_CLICK", 2)
Global("TARGET_CLICK", 3)
Global("RESSURECT_CLICK", 4)
Global("AUTOCAST_CLICK", 5)


local m_actionSwitch = {}
m_actionSwitch[DISABLE_CLICK] = m_locale["DISABLE_CLICK"]
m_actionSwitch[SELECT_CLICK] = m_locale["SELECT_CLICK"]
m_actionSwitch[MENU_CLICK] = m_locale["MENU_CLICK"]
m_actionSwitch[TARGET_CLICK] = m_locale["TARGET_CLICK"]
m_actionSwitch[RESSURECT_CLICK] = m_locale["RESSURECT_CLICK"]
m_actionSwitch[AUTOCAST_CLICK] = m_locale["AUTOCAST_CLICK"]

function CreateBindSettingsForm()
	local form=createWidget(mainForm, "bindSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 1280, 620, 200, 100)
	hide(form)
	priority(form, 505)

	local group1 = createWidget(form, "group1", "Panel")
	align(group1, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group1, 415, 515)
	move(group1, 10, 47)
	
	local group2 = createWidget(form, "group2", "Panel")
	align(group2, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group2, 415, 515)
	move(group2, 430, 47)
	
	local group3 = createWidget(form, "group3", "Panel")
	align(group3, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group3, 415, 515)
	move(group3, 850, 47)

	setLocaleText(createWidget(form, "bindSettingsFormHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 150, 20, nil, 16))
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(group1, "bindForRaidHeader", "TextView",  WIDGET_ALIGN_LOW, nil, 150, 20, 170, 5))
	setLocaleText(createWidget(group1, "spellHeader", "TextView",  WIDGET_ALIGN_LOW, nil, 150, 20, 300, 35))
	
	setLocaleText(createWidget(group2, "bindForTargetHeader", "TextView",  WIDGET_ALIGN_LOW, nil, 150, 20, 150, 5))
	setLocaleText(createWidget(group2, "spellHeader", "TextView",  WIDGET_ALIGN_LOW, nil, 150, 20, 300, 35))
	
	setLocaleText(createWidget(group3, "bindForCastHeader", "TextView",  WIDGET_ALIGN_LOW, nil, 200, 20, 120, 5))
	setLocaleText(createWidget(group3, "spellHeader", "TextView",  WIDGET_ALIGN_LOW, nil, 150, 20, 300, 35))
	
	setLocaleText(createWidget(group1, "raidBindSimpleButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 65))
	setLocaleText(createWidget(group1, "raidBindShiftButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 185))
	setLocaleText(createWidget(group1, "raidBindAltButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 305))
	setLocaleText(createWidget(group1, "raidBindCtrlButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 425))
	
	setLocaleText(createWidget(group2, "targetBindSimpleButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 65))
	setLocaleText(createWidget(group2, "targetBindShiftButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 185))
	setLocaleText(createWidget(group2, "targetBindAltButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 305))
	setLocaleText(createWidget(group2, "targetBindCtrlButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 425))
	
	setLocaleText(createWidget(group3, "targetBindSimpleButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 65))
	setLocaleText(createWidget(group3, "targetBindShiftButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 185))
	setLocaleText(createWidget(group3, "targetBindAltButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 305))
	setLocaleText(createWidget(group3, "targetBindCtrlButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 55, 425))
	
	setLocaleText(createWidget(group1, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 95))
	setLocaleText(createWidget(group1, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 215))
	setLocaleText(createWidget(group1, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 335))
	setLocaleText(createWidget(group1, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 455))
	
	setLocaleText(createWidget(group1, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 125))
	setLocaleText(createWidget(group1, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 245))
	setLocaleText(createWidget(group1, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 365))
	setLocaleText(createWidget(group1, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 485))
	
	setLocaleText(createWidget(group2, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 95))
	setLocaleText(createWidget(group2, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 215))
	setLocaleText(createWidget(group2, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 335))
	setLocaleText(createWidget(group2, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 455))
	
	setLocaleText(createWidget(group2, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 125))
	setLocaleText(createWidget(group2, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 245))
	setLocaleText(createWidget(group2, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 365))
	setLocaleText(createWidget(group2, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 485))
	
	setLocaleText(createWidget(group3, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 95))
	setLocaleText(createWidget(group3, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 215))
	setLocaleText(createWidget(group3, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 335))
	setLocaleText(createWidget(group3, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 455))
	
	setLocaleText(createWidget(group3, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 125))
	setLocaleText(createWidget(group3, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 245))
	setLocaleText(createWidget(group3, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 365))
	setLocaleText(createWidget(group3, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 5, 485))
	
	local textArr = {}
	for i = DISABLE_CLICK, AUTOCAST_CLICK do
		table.insert(textArr, m_actionSwitch[i])
	end
	
	GenerateBtnForDropDown(createWidget(group1, "actionLeftSwitchRaidSimple", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 95), textArr)
	GenerateBtnForDropDown(createWidget(group1, "actionLeftSwitchRaidShift", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 215), textArr)
	GenerateBtnForDropDown(createWidget(group1, "actionLeftSwitchRaidAlt", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 335), textArr)
	CheckDropDownOrientation(GenerateBtnForDropDown(createWidget(group1, "actionLeftSwitchRaidCtrl", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 455), textArr))
	
	GenerateBtnForDropDown(createWidget(group1, "actionRightSwitchRaidSimple", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 125), textArr)
	GenerateBtnForDropDown(createWidget(group1, "actionRightSwitchRaidShift", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 245), textArr)
	CheckDropDownOrientation(GenerateBtnForDropDown(createWidget(group1, "actionRightSwitchRaidAlt", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 365), textArr))
	CheckDropDownOrientation(GenerateBtnForDropDown(createWidget(group1, "actionRightSwitchRaidCtrl", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 485), textArr))
	
	GenerateBtnForDropDown(createWidget(group2, "actionLeftSwitchTargetSimple", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 95), textArr)
	GenerateBtnForDropDown(createWidget(group2, "actionLeftSwitchTargetShift", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 215), textArr)
	GenerateBtnForDropDown(createWidget(group2, "actionLeftSwitchTargetAlt", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 335), textArr)
	CheckDropDownOrientation(GenerateBtnForDropDown(createWidget(group2, "actionLeftSwitchTargetCtrl", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 455), textArr))

	GenerateBtnForDropDown(createWidget(group2, "actionRightSwitchTargetSimple", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 125), textArr)
	GenerateBtnForDropDown(createWidget(group2, "actionRightSwitchTargetShift", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 245), textArr)
	CheckDropDownOrientation(GenerateBtnForDropDown(createWidget(group2, "actionRightSwitchTargetAlt", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 365), textArr))
	CheckDropDownOrientation(GenerateBtnForDropDown(createWidget(group2, "actionRightSwitchTargetCtrl", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 485), textArr))
	
	GenerateBtnForDropDown(createWidget(group3, "actionLeftSwitchProgressCastSimple", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 95), textArr)
	GenerateBtnForDropDown(createWidget(group3, "actionLeftSwitchProgressCastShift", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 215), textArr)
	GenerateBtnForDropDown(createWidget(group3, "actionLeftSwitchProgressCastAlt", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 335), textArr)
	CheckDropDownOrientation(GenerateBtnForDropDown(createWidget(group3, "actionLeftSwitchProgressCastCtrl", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 455), textArr))

	GenerateBtnForDropDown(createWidget(group3, "actionRightSwitchProgressCastSimple", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 125), textArr)
	GenerateBtnForDropDown(createWidget(group3, "actionRightSwitchProgressCastShift", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 245), textArr)
	CheckDropDownOrientation(GenerateBtnForDropDown(createWidget(group3, "actionRightSwitchProgressCastAlt", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 365), textArr))
	CheckDropDownOrientation(GenerateBtnForDropDown(createWidget(group3, "actionRightSwitchProgressCastCtrl", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 485), textArr))
	
	
	createWidget(group1, "actionLeftRaidSimpleBind", "EditLine", nil, nil, 180, 25, 225, 95, nil, nil)
	createWidget(group1, "actionLeftRaidShiftBind", "EditLine", nil, nil, 180, 25, 225, 215, nil, nil)
	createWidget(group1, "actionLeftRaidAltBind", "EditLine", nil, nil, 180, 25, 225, 335, nil, nil)
	createWidget(group1, "actionLeftRaidCtrlBind", "EditLine", nil, nil, 180, 25, 225, 455, nil, nil)
	createWidget(group1, "actionRightRaidSimpleBind", "EditLine", nil, nil, 180, 25, 225, 125, nil, nil)
	createWidget(group1, "actionRightRaidShiftBind", "EditLine", nil, nil, 180, 25, 225, 245, nil, nil)
	createWidget(group1, "actionRightRaidAltBind", "EditLine", nil, nil, 180, 25, 225, 365, nil, nil)
	createWidget(group1, "actionRightRaidCtrlBind", "EditLine", nil, nil, 180, 25, 225, 485, nil, nil)

	createWidget(group2, "actionLeftTargetSimpleBind", "EditLine", nil, nil, 180, 25, 225, 95, nil, nil)
	createWidget(group2, "actionLeftTargetShiftBind", "EditLine", nil, nil, 180, 25, 225, 215, nil, nil)
	createWidget(group2, "actionLeftTargetAltBind", "EditLine", nil, nil, 180, 25, 225, 335, nil, nil)
	createWidget(group2, "actionLeftTargetCtrlBind", "EditLine", nil, nil, 180, 25, 225, 455, nil, nil)
	createWidget(group2, "actionRightTargetSimpleBind", "EditLine", nil, nil, 180, 25, 225, 125, nil, nil)
	createWidget(group2, "actionRightTargetShiftBind", "EditLine", nil, nil, 180, 25, 225, 245, nil, nil)
	createWidget(group2, "actionRightTargetAltBind", "EditLine", nil, nil, 180, 25, 225, 365, nil, nil)
	createWidget(group2, "actionRightTargetCtrlBind", "EditLine", nil, nil, 180, 25, 225, 485, nil, nil)
	
	createWidget(group3, "actionLeftProgressCastSimpleBind", "EditLine", nil, nil, 180, 25, 225, 95, nil, nil)
	createWidget(group3, "actionLeftProgressCastShiftBind", "EditLine", nil, nil, 180, 25, 225, 215, nil, nil)
	createWidget(group3, "actionLeftProgressCastAltBind", "EditLine", nil, nil, 180, 25, 225, 335, nil, nil)
	createWidget(group3, "actionLeftProgressCastCtrlBind", "EditLine", nil, nil, 180, 25, 225, 455, nil, nil)
	createWidget(group3, "actionRightProgressCastSimpleBind", "EditLine", nil, nil, 180, 25, 225, 125, nil, nil)
	createWidget(group3, "actionRightProgressCastShiftBind", "EditLine", nil, nil, 180, 25, 225, 245, nil, nil)
	createWidget(group3, "actionRightProgressCastAltBind", "EditLine", nil, nil, 180, 25, 225, 365, nil, nil)
	createWidget(group3, "actionRightProgressCastCtrlBind", "EditLine", nil, nil, 180, 25, 225, 485, nil, nil)
	
	local bindCastNotifyWdg = createWidget(form, "bindCastNotify", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_HIGH, 415, 40, 10, 20)
	bindCastNotifyWdg:SetMultiline(true)
	setLocaleTextEx(bindCastNotifyWdg, nil, "ColorGray", "left")
	
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	DnD.Init(form, form, true)
		
	return form
end

function SaveBindFormSettings(aForm)
	local group1 = getChild(aForm, "group1")
	local group2 = getChild(aForm, "group2")
	local group3 = getChild(aForm, "group3")
	m_currentFormSettings.actionLeftSwitchRaidSimple = GetCurrentSwitchIndex(getChild(group1, "actionLeftSwitchRaidSimple"))
	m_currentFormSettings.actionLeftSwitchRaidShift = GetCurrentSwitchIndex(getChild(group1, "actionLeftSwitchRaidShift"))
	m_currentFormSettings.actionLeftSwitchRaidAlt = GetCurrentSwitchIndex(getChild(group1, "actionLeftSwitchRaidAlt"))
	m_currentFormSettings.actionLeftSwitchRaidCtrl = GetCurrentSwitchIndex(getChild(group1, "actionLeftSwitchRaidCtrl"))
	m_currentFormSettings.actionRightSwitchRaidSimple = GetCurrentSwitchIndex(getChild(group1, "actionRightSwitchRaidSimple"))
	m_currentFormSettings.actionRightSwitchRaidShift = GetCurrentSwitchIndex(getChild(group1, "actionRightSwitchRaidShift"))
	m_currentFormSettings.actionRightSwitchRaidAlt = GetCurrentSwitchIndex(getChild(group1, "actionRightSwitchRaidAlt"))
	m_currentFormSettings.actionRightSwitchRaidCtrl = GetCurrentSwitchIndex(getChild(group1, "actionRightSwitchRaidCtrl"))
	
	m_currentFormSettings.actionLeftSwitchTargetSimple = GetCurrentSwitchIndex(getChild(group2, "actionLeftSwitchTargetSimple"))
	m_currentFormSettings.actionLeftSwitchTargetShift = GetCurrentSwitchIndex(getChild(group2, "actionLeftSwitchTargetShift"))
	m_currentFormSettings.actionLeftSwitchTargetAlt = GetCurrentSwitchIndex(getChild(group2, "actionLeftSwitchTargetAlt"))
	m_currentFormSettings.actionLeftSwitchTargetCtrl = GetCurrentSwitchIndex(getChild(group2, "actionLeftSwitchTargetCtrl"))
	m_currentFormSettings.actionRightSwitchTargetSimple = GetCurrentSwitchIndex(getChild(group2, "actionRightSwitchTargetSimple"))
	m_currentFormSettings.actionRightSwitchTargetShift = GetCurrentSwitchIndex(getChild(group2, "actionRightSwitchTargetShift"))
	m_currentFormSettings.actionRightSwitchTargetAlt = GetCurrentSwitchIndex(getChild(group2, "actionRightSwitchTargetAlt"))
	m_currentFormSettings.actionRightSwitchTargetCtrl = GetCurrentSwitchIndex(getChild(group2, "actionRightSwitchTargetCtrl"))
	
	m_currentFormSettings.actionLeftSwitchProgressCastSimple = GetCurrentSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastSimple"))
	m_currentFormSettings.actionLeftSwitchProgressCastShift = GetCurrentSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastShift"))
	m_currentFormSettings.actionLeftSwitchProgressCastAlt = GetCurrentSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastAlt"))
	m_currentFormSettings.actionLeftSwitchProgressCastCtrl = GetCurrentSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastCtrl"))
	m_currentFormSettings.actionRightSwitchProgressCastSimple = GetCurrentSwitchIndex(getChild(group3, "actionRightSwitchProgressCastSimple"))
	m_currentFormSettings.actionRightSwitchProgressCastShift = GetCurrentSwitchIndex(getChild(group3, "actionRightSwitchProgressCastShift"))
	m_currentFormSettings.actionRightSwitchProgressCastAlt = GetCurrentSwitchIndex(getChild(group3, "actionRightSwitchProgressCastAlt"))
	m_currentFormSettings.actionRightSwitchProgressCastCtrl = GetCurrentSwitchIndex(getChild(group3, "actionRightSwitchProgressCastCtrl"))

	
	m_currentFormSettings.actionLeftRaidSimpleBind = getText(getChild(group1, "actionLeftRaidSimpleBind"))
	m_currentFormSettings.actionLeftRaidShiftBind = getText(getChild(group1, "actionLeftRaidShiftBind"))
	m_currentFormSettings.actionLeftRaidAltBind = getText(getChild(group1, "actionLeftRaidAltBind"))
	m_currentFormSettings.actionLeftRaidCtrlBind = getText(getChild(group1, "actionLeftRaidCtrlBind"))
	m_currentFormSettings.actionRightRaidSimpleBind = getText(getChild(group1, "actionRightRaidSimpleBind"))
	m_currentFormSettings.actionRightRaidShiftBind = getText(getChild(group1, "actionRightRaidShiftBind"))
	m_currentFormSettings.actionRightRaidAltBind = getText(getChild(group1, "actionRightRaidAltBind"))
	m_currentFormSettings.actionRightRaidCtrlBind = getText(getChild(group1, "actionRightRaidCtrlBind"))
	
	m_currentFormSettings.actionLeftTargetSimpleBind = getText(getChild(group2, "actionLeftTargetSimpleBind"))
	m_currentFormSettings.actionLeftTargetShiftBind = getText(getChild(group2, "actionLeftTargetShiftBind"))
	m_currentFormSettings.actionLeftTargetAltBind = getText(getChild(group2, "actionLeftTargetAltBind"))
	m_currentFormSettings.actionLeftTargetCtrlBind = getText(getChild(group2, "actionLeftTargetCtrlBind"))
	m_currentFormSettings.actionRightTargetSimpleBind = getText(getChild(group2, "actionRightTargetSimpleBind"))
	m_currentFormSettings.actionRightTargetShiftBind = getText(getChild(group2, "actionRightTargetShiftBind"))
	m_currentFormSettings.actionRightTargetAltBind = getText(getChild(group2, "actionRightTargetAltBind"))
	m_currentFormSettings.actionRightTargetCtrlBind = getText(getChild(group2, "actionRightTargetCtrlBind"))
	
	m_currentFormSettings.actionLeftProgressCastSimpleBind = getText(getChild(group3, "actionLeftProgressCastSimpleBind"))
	m_currentFormSettings.actionLeftProgressCastShiftBind = getText(getChild(group3, "actionLeftProgressCastShiftBind"))
	m_currentFormSettings.actionLeftProgressCastAltBind = getText(getChild(group3, "actionLeftProgressCastAltBind"))
	m_currentFormSettings.actionLeftProgressCastCtrlBind = getText(getChild(group3, "actionLeftProgressCastCtrlBind"))
	m_currentFormSettings.actionRightProgressCastSimpleBind = getText(getChild(group3, "actionRightProgressCastSimpleBind"))
	m_currentFormSettings.actionRightProgressCastShiftBind = getText(getChild(group3, "actionRightProgressCastShiftBind"))
	m_currentFormSettings.actionRightProgressCastAltBind = getText(getChild(group3, "actionRightProgressCastAltBind"))
	m_currentFormSettings.actionRightProgressCastCtrlBind = getText(getChild(group3, "actionRightProgressCastCtrlBind"))
	
	return m_currentFormSettings
end

function LoadBindFormSettings(aForm)
	local profile = GetCurrentProfile()
	m_currentFormSettings = deepCopyTable(profile.bindFormSettings)
	
	local group1 = getChild(aForm, "group1")
	local group2 = getChild(aForm, "group2")
	local group3 = getChild(aForm, "group3")
	SetSwitchIndex(getChild(group1, "actionLeftSwitchRaidSimple"), m_currentFormSettings.actionLeftSwitchRaidSimple)
	SetSwitchIndex(getChild(group1, "actionLeftSwitchRaidShift"), m_currentFormSettings.actionLeftSwitchRaidShift)
	SetSwitchIndex(getChild(group1, "actionLeftSwitchRaidAlt"), m_currentFormSettings.actionLeftSwitchRaidAlt)
	SetSwitchIndex(getChild(group1, "actionLeftSwitchRaidCtrl"), m_currentFormSettings.actionLeftSwitchRaidCtrl)
	SetSwitchIndex(getChild(group1, "actionRightSwitchRaidSimple"), m_currentFormSettings.actionRightSwitchRaidSimple)
	SetSwitchIndex(getChild(group1, "actionRightSwitchRaidShift"), m_currentFormSettings.actionRightSwitchRaidShift)
	SetSwitchIndex(getChild(group1, "actionRightSwitchRaidAlt"), m_currentFormSettings.actionRightSwitchRaidAlt)
	SetSwitchIndex(getChild(group1, "actionRightSwitchRaidCtrl"), m_currentFormSettings.actionRightSwitchRaidCtrl)
	
	SetSwitchIndex(getChild(group2, "actionLeftSwitchTargetSimple"), m_currentFormSettings.actionLeftSwitchTargetSimple)
	SetSwitchIndex(getChild(group2, "actionLeftSwitchTargetShift"), m_currentFormSettings.actionLeftSwitchTargetShift)
	SetSwitchIndex(getChild(group2, "actionLeftSwitchTargetAlt"), m_currentFormSettings.actionLeftSwitchTargetAlt)
	SetSwitchIndex(getChild(group2, "actionLeftSwitchTargetCtrl"), m_currentFormSettings.actionLeftSwitchTargetCtrl)
	SetSwitchIndex(getChild(group2, "actionRightSwitchTargetSimple"), m_currentFormSettings.actionRightSwitchTargetSimple)
	SetSwitchIndex(getChild(group2, "actionRightSwitchTargetShift"), m_currentFormSettings.actionRightSwitchTargetShift)
	SetSwitchIndex(getChild(group2, "actionRightSwitchTargetAlt"), m_currentFormSettings.actionRightSwitchTargetAlt)
	SetSwitchIndex(getChild(group2, "actionRightSwitchTargetCtrl"), m_currentFormSettings.actionRightSwitchTargetCtrl)
	
	SetSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastSimple"), m_currentFormSettings.actionLeftSwitchProgressCastSimple)
	SetSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastShift"), m_currentFormSettings.actionLeftSwitchProgressCastShift)
	SetSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastAlt"), m_currentFormSettings.actionLeftSwitchProgressCastAlt)
	SetSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastCtrl"), m_currentFormSettings.actionLeftSwitchProgressCastCtrl)
	SetSwitchIndex(getChild(group3, "actionRightSwitchProgressCastSimple"), m_currentFormSettings.actionRightSwitchProgressCastSimple)
	SetSwitchIndex(getChild(group3, "actionRightSwitchProgressCastShift"), m_currentFormSettings.actionRightSwitchProgressCastShift)
	SetSwitchIndex(getChild(group3, "actionRightSwitchProgressCastAlt"), m_currentFormSettings.actionRightSwitchProgressCastAlt)
	SetSwitchIndex(getChild(group3, "actionRightSwitchProgressCastCtrl"), m_currentFormSettings.actionRightSwitchProgressCastCtrl)
	
	
	setText(getChild(group1, "actionLeftRaidSimpleBind"), m_currentFormSettings.actionLeftRaidSimpleBind)
	setText(getChild(group1, "actionLeftRaidShiftBind"), m_currentFormSettings.actionLeftRaidShiftBind)
	setText(getChild(group1, "actionLeftRaidAltBind"), m_currentFormSettings.actionLeftRaidAltBind)
	setText(getChild(group1, "actionLeftRaidCtrlBind"), m_currentFormSettings.actionLeftRaidCtrlBind)
	setText(getChild(group1, "actionRightRaidSimpleBind"), m_currentFormSettings.actionRightRaidSimpleBind)
	setText(getChild(group1, "actionRightRaidShiftBind"), m_currentFormSettings.actionRightRaidShiftBind)
	setText(getChild(group1, "actionRightRaidAltBind"), m_currentFormSettings.actionRightRaidAltBind)
	setText(getChild(group1, "actionRightRaidCtrlBind"), m_currentFormSettings.actionRightRaidCtrlBind)
	
	setText(getChild(group2, "actionLeftTargetSimpleBind"), m_currentFormSettings.actionLeftTargetSimpleBind)
	setText(getChild(group2, "actionLeftTargetShiftBind"), m_currentFormSettings.actionLeftTargetShiftBind)
	setText(getChild(group2, "actionLeftTargetAltBind"), m_currentFormSettings.actionLeftTargetAltBind)
	setText(getChild(group2, "actionLeftTargetCtrlBind"), m_currentFormSettings.actionLeftTargetCtrlBind)
	setText(getChild(group2, "actionRightTargetSimpleBind"), m_currentFormSettings.actionRightTargetSimpleBind)
	setText(getChild(group2, "actionRightTargetShiftBind"), m_currentFormSettings.actionRightTargetShiftBind)
	setText(getChild(group2, "actionRightTargetAltBind"), m_currentFormSettings.actionRightTargetAltBind)
	setText(getChild(group2, "actionRightTargetCtrlBind"), m_currentFormSettings.actionRightTargetCtrlBind)
	
	setText(getChild(group3, "actionLeftProgressCastSimpleBind"), m_currentFormSettings.actionLeftProgressCastSimpleBind)
	setText(getChild(group3, "actionLeftProgressCastShiftBind"), m_currentFormSettings.actionLeftProgressCastShiftBind)
	setText(getChild(group3, "actionLeftProgressCastAltBind"), m_currentFormSettings.actionLeftProgressCastAltBind)
	setText(getChild(group3, "actionLeftProgressCastCtrlBind"), m_currentFormSettings.actionLeftProgressCastCtrlBind)
	setText(getChild(group3, "actionRightProgressCastSimpleBind"), m_currentFormSettings.actionRightProgressCastSimpleBind)
	setText(getChild(group3, "actionRightProgressCastShiftBind"), m_currentFormSettings.actionRightProgressCastShiftBind)
	setText(getChild(group3, "actionRightProgressCastAltBind"), m_currentFormSettings.actionRightProgressCastAltBind)
	setText(getChild(group3, "actionRightProgressCastCtrlBind"), m_currentFormSettings.actionRightProgressCastCtrlBind)
end

function GetSwitchIndexByName(anArr, aName)
	for i, v in pairs(anArr) do
		if compareStrWithConvert(v, aName) then
			return i
		end
	end
	return 0
end

function GetCurrentSwitchIndex(aWdg)
	local txtWdg = getChild(getChild(aWdg, "DropDownHeaderPanel"), "ModeNameTextView")
	local currValue = txtWdg:GetWString()
	return GetSwitchIndexByName(m_actionSwitch, currValue)
end

function SetSwitchIndex(aWdg, anIndex)
	if anIndex == nil then
		anIndex = 0
	end
	
	local txtWdg = getChild(getChild(aWdg, "DropDownHeaderPanel"), "ModeNameTextView")
	setText(txtWdg, m_actionSwitch[anIndex], "Neutral", "left", 11)
end