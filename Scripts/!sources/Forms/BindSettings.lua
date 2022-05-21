local m_template = nil
local m_locale = getLocale()

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
	local form=createWidget(nil, "bindSettingsForm", "Form", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 1280, 620, 200, 100)
	hide(form)
	priority(form, 5000)

	local panel=createWidget(form, "Panel", "Panel")
	
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
	
	createWidget(group1, "actionLeftSwitchRaidSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 95)
	createWidget(group1, "actionLeftSwitchRaidShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 215)
	createWidget(group1, "actionLeftSwitchRaidAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 335)
	createWidget(group1, "actionLeftSwitchRaidCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 455)
	
	createWidget(group1, "actionRightSwitchRaidSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 125)
	createWidget(group1, "actionRightSwitchRaidShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 245)
	createWidget(group1, "actionRightSwitchRaidAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 365)
	createWidget(group1, "actionRightSwitchRaidCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 485)
	
	createWidget(group2, "actionLeftSwitchTargetSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 95)
	createWidget(group2, "actionLeftSwitchTargetShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 215)
	createWidget(group2, "actionLeftSwitchTargetAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 335)
	createWidget(group2, "actionLeftSwitchTargetCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 455)

	createWidget(group2, "actionRightSwitchTargetSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 125)
	createWidget(group2, "actionRightSwitchTargetShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 245)
	createWidget(group2, "actionRightSwitchTargetAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 365)
	createWidget(group2, "actionRightSwitchTargetCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 485)
	
	createWidget(group3, "actionLeftSwitchProgressCastSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 95)
	createWidget(group3, "actionLeftSwitchProgressCastShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 215)
	createWidget(group3, "actionLeftSwitchProgressCastAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 335)
	createWidget(group3, "actionLeftSwitchProgressCastCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 455)

	createWidget(group3, "actionRightSwitchProgressCastSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 125)
	createWidget(group3, "actionRightSwitchProgressCastShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 245)
	createWidget(group3, "actionRightSwitchProgressCastAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 365)
	createWidget(group3, "actionRightSwitchProgressCastCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 115, 485)
	
	
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
	
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	DnD.Init(form, panel, true)
		
	return form
end

function SaveBindFormSettings(aForm)
	local mySettings = {}

	local group1 = getChild(aForm, "group1")
	local group2 = getChild(aForm, "group2")
	local group3 = getChild(aForm, "group3")
	mySettings.actionLeftSwitchRaidSimple = GetCurrentSwitchIndex(getChild(group1, "actionLeftSwitchRaidSimple"))
	mySettings.actionLeftSwitchRaidShift = GetCurrentSwitchIndex(getChild(group1, "actionLeftSwitchRaidShift"))
	mySettings.actionLeftSwitchRaidAlt = GetCurrentSwitchIndex(getChild(group1, "actionLeftSwitchRaidAlt"))
	mySettings.actionLeftSwitchRaidCtrl = GetCurrentSwitchIndex(getChild(group1, "actionLeftSwitchRaidCtrl"))
	mySettings.actionRightSwitchRaidSimple = GetCurrentSwitchIndex(getChild(group1, "actionRightSwitchRaidSimple"))
	mySettings.actionRightSwitchRaidShift = GetCurrentSwitchIndex(getChild(group1, "actionRightSwitchRaidShift"))
	mySettings.actionRightSwitchRaidAlt = GetCurrentSwitchIndex(getChild(group1, "actionRightSwitchRaidAlt"))
	mySettings.actionRightSwitchRaidCtrl = GetCurrentSwitchIndex(getChild(group1, "actionRightSwitchRaidCtrl"))
	
	mySettings.actionLeftSwitchTargetSimple = GetCurrentSwitchIndex(getChild(group2, "actionLeftSwitchTargetSimple"))
	mySettings.actionLeftSwitchTargetShift = GetCurrentSwitchIndex(getChild(group2, "actionLeftSwitchTargetShift"))
	mySettings.actionLeftSwitchTargetAlt = GetCurrentSwitchIndex(getChild(group2, "actionLeftSwitchTargetAlt"))
	mySettings.actionLeftSwitchTargetCtrl = GetCurrentSwitchIndex(getChild(group2, "actionLeftSwitchTargetCtrl"))
	mySettings.actionRightSwitchTargetSimple = GetCurrentSwitchIndex(getChild(group2, "actionRightSwitchTargetSimple"))
	mySettings.actionRightSwitchTargetShift = GetCurrentSwitchIndex(getChild(group2, "actionRightSwitchTargetShift"))
	mySettings.actionRightSwitchTargetAlt = GetCurrentSwitchIndex(getChild(group2, "actionRightSwitchTargetAlt"))
	mySettings.actionRightSwitchTargetCtrl = GetCurrentSwitchIndex(getChild(group2, "actionRightSwitchTargetCtrl"))
	
	mySettings.actionLeftSwitchProgressCastSimple = GetCurrentSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastSimple"))
	mySettings.actionLeftSwitchProgressCastShift = GetCurrentSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastShift"))
	mySettings.actionLeftSwitchProgressCastAlt = GetCurrentSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastAlt"))
	mySettings.actionLeftSwitchProgressCastCtrl = GetCurrentSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastCtrl"))
	mySettings.actionRightSwitchProgressCastSimple = GetCurrentSwitchIndex(getChild(group3, "actionRightSwitchProgressCastSimple"))
	mySettings.actionRightSwitchProgressCastShift = GetCurrentSwitchIndex(getChild(group3, "actionRightSwitchProgressCastShift"))
	mySettings.actionRightSwitchProgressCastAlt = GetCurrentSwitchIndex(getChild(group3, "actionRightSwitchProgressCastAlt"))
	mySettings.actionRightSwitchProgressCastCtrl = GetCurrentSwitchIndex(getChild(group3, "actionRightSwitchProgressCastCtrl"))

	
	mySettings.actionLeftRaidSimpleBind = getText(getChild(group1, "actionLeftRaidSimpleBind"))
	mySettings.actionLeftRaidShiftBind = getText(getChild(group1, "actionLeftRaidShiftBind"))
	mySettings.actionLeftRaidAltBind = getText(getChild(group1, "actionLeftRaidAltBind"))
	mySettings.actionLeftRaidCtrlBind = getText(getChild(group1, "actionLeftRaidCtrlBind"))
	mySettings.actionRightRaidSimpleBind = getText(getChild(group1, "actionRightRaidSimpleBind"))
	mySettings.actionRightRaidShiftBind = getText(getChild(group1, "actionRightRaidShiftBind"))
	mySettings.actionRightRaidAltBind = getText(getChild(group1, "actionRightRaidAltBind"))
	mySettings.actionRightRaidCtrlBind = getText(getChild(group1, "actionRightRaidCtrlBind"))
	
	mySettings.actionLeftTargetSimpleBind = getText(getChild(group2, "actionLeftTargetSimpleBind"))
	mySettings.actionLeftTargetShiftBind = getText(getChild(group2, "actionLeftTargetShiftBind"))
	mySettings.actionLeftTargetAltBind = getText(getChild(group2, "actionLeftTargetAltBind"))
	mySettings.actionLeftTargetCtrlBind = getText(getChild(group2, "actionLeftTargetCtrlBind"))
	mySettings.actionRightTargetSimpleBind = getText(getChild(group2, "actionRightTargetSimpleBind"))
	mySettings.actionRightTargetShiftBind = getText(getChild(group2, "actionRightTargetShiftBind"))
	mySettings.actionRightTargetAltBind = getText(getChild(group2, "actionRightTargetAltBind"))
	mySettings.actionRightTargetCtrlBind = getText(getChild(group2, "actionRightTargetCtrlBind"))
	
	mySettings.actionLeftProgressCastSimpleBind = getText(getChild(group3, "actionLeftProgressCastSimpleBind"))
	mySettings.actionLeftProgressCastShiftBind = getText(getChild(group3, "actionLeftProgressCastShiftBind"))
	mySettings.actionLeftProgressCastAltBind = getText(getChild(group3, "actionLeftProgressCastAltBind"))
	mySettings.actionLeftProgressCastCtrlBind = getText(getChild(group3, "actionLeftProgressCastCtrlBind"))
	mySettings.actionRightProgressCastSimpleBind = getText(getChild(group3, "actionRightProgressCastSimpleBind"))
	mySettings.actionRightProgressCastShiftBind = getText(getChild(group3, "actionRightProgressCastShiftBind"))
	mySettings.actionRightProgressCastAltBind = getText(getChild(group3, "actionRightProgressCastAltBind"))
	mySettings.actionRightProgressCastCtrlBind = getText(getChild(group3, "actionRightProgressCastCtrlBind"))
	
	return mySettings
end

function LoadBindFormSettings(aForm)
	local profile = GetCurrentProfile()
	local mySettings = profile.bindFormSettings
	
	local group1 = getChild(aForm, "group1")
	local group2 = getChild(aForm, "group2")
	local group3 = getChild(aForm, "group3")
	SetSwitchIndex(getChild(group1, "actionLeftSwitchRaidSimple"), mySettings.actionLeftSwitchRaidSimple)
	SetSwitchIndex(getChild(group1, "actionLeftSwitchRaidShift"), mySettings.actionLeftSwitchRaidShift)
	SetSwitchIndex(getChild(group1, "actionLeftSwitchRaidAlt"), mySettings.actionLeftSwitchRaidAlt)
	SetSwitchIndex(getChild(group1, "actionLeftSwitchRaidCtrl"), mySettings.actionLeftSwitchRaidCtrl)
	SetSwitchIndex(getChild(group1, "actionRightSwitchRaidSimple"), mySettings.actionRightSwitchRaidSimple)
	SetSwitchIndex(getChild(group1, "actionRightSwitchRaidShift"), mySettings.actionRightSwitchRaidShift)
	SetSwitchIndex(getChild(group1, "actionRightSwitchRaidAlt"), mySettings.actionRightSwitchRaidAlt)
	SetSwitchIndex(getChild(group1, "actionRightSwitchRaidCtrl"), mySettings.actionRightSwitchRaidCtrl)
	
	SetSwitchIndex(getChild(group2, "actionLeftSwitchTargetSimple"), mySettings.actionLeftSwitchTargetSimple)
	SetSwitchIndex(getChild(group2, "actionLeftSwitchTargetShift"), mySettings.actionLeftSwitchTargetShift)
	SetSwitchIndex(getChild(group2, "actionLeftSwitchTargetAlt"), mySettings.actionLeftSwitchTargetAlt)
	SetSwitchIndex(getChild(group2, "actionLeftSwitchTargetCtrl"), mySettings.actionLeftSwitchTargetCtrl)
	SetSwitchIndex(getChild(group2, "actionRightSwitchTargetSimple"), mySettings.actionRightSwitchTargetSimple)
	SetSwitchIndex(getChild(group2, "actionRightSwitchTargetShift"), mySettings.actionRightSwitchTargetShift)
	SetSwitchIndex(getChild(group2, "actionRightSwitchTargetAlt"), mySettings.actionRightSwitchTargetAlt)
	SetSwitchIndex(getChild(group2, "actionRightSwitchTargetCtrl"), mySettings.actionRightSwitchTargetCtrl)
	
	SetSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastSimple"), mySettings.actionLeftSwitchProgressCastSimple)
	SetSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastShift"), mySettings.actionLeftSwitchProgressCastShift)
	SetSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastAlt"), mySettings.actionLeftSwitchProgressCastAlt)
	SetSwitchIndex(getChild(group3, "actionLeftSwitchProgressCastCtrl"), mySettings.actionLeftSwitchProgressCastCtrl)
	SetSwitchIndex(getChild(group3, "actionRightSwitchProgressCastSimple"), mySettings.actionRightSwitchProgressCastSimple)
	SetSwitchIndex(getChild(group3, "actionRightSwitchProgressCastShift"), mySettings.actionRightSwitchProgressCastShift)
	SetSwitchIndex(getChild(group3, "actionRightSwitchProgressCastAlt"), mySettings.actionRightSwitchProgressCastAlt)
	SetSwitchIndex(getChild(group3, "actionRightSwitchProgressCastCtrl"), mySettings.actionRightSwitchProgressCastCtrl)
	
	
	setText(getChild(group1, "actionLeftRaidSimpleBind"), mySettings.actionLeftRaidSimpleBind)
	setText(getChild(group1, "actionLeftRaidShiftBind"), mySettings.actionLeftRaidShiftBind)
	setText(getChild(group1, "actionLeftRaidAltBind"), mySettings.actionLeftRaidAltBind)
	setText(getChild(group1, "actionLeftRaidCtrlBind"), mySettings.actionLeftRaidCtrlBind)
	setText(getChild(group1, "actionRightRaidSimpleBind"), mySettings.actionRightRaidSimpleBind)
	setText(getChild(group1, "actionRightRaidShiftBind"), mySettings.actionRightRaidShiftBind)
	setText(getChild(group1, "actionRightRaidAltBind"), mySettings.actionRightRaidAltBind)
	setText(getChild(group1, "actionRightRaidCtrlBind"), mySettings.actionRightRaidCtrlBind)
	
	setText(getChild(group2, "actionLeftTargetSimpleBind"), mySettings.actionLeftTargetSimpleBind)
	setText(getChild(group2, "actionLeftTargetShiftBind"), mySettings.actionLeftTargetShiftBind)
	setText(getChild(group2, "actionLeftTargetAltBind"), mySettings.actionLeftTargetAltBind)
	setText(getChild(group2, "actionLeftTargetCtrlBind"), mySettings.actionLeftTargetCtrlBind)
	setText(getChild(group2, "actionRightTargetSimpleBind"), mySettings.actionRightTargetSimpleBind)
	setText(getChild(group2, "actionRightTargetShiftBind"), mySettings.actionRightTargetShiftBind)
	setText(getChild(group2, "actionRightTargetAltBind"), mySettings.actionRightTargetAltBind)
	setText(getChild(group2, "actionRightTargetCtrlBind"), mySettings.actionRightTargetCtrlBind)
	
	setText(getChild(group3, "actionLeftProgressCastSimpleBind"), mySettings.actionLeftProgressCastSimpleBind)
	setText(getChild(group3, "actionLeftProgressCastShiftBind"), mySettings.actionLeftProgressCastShiftBind)
	setText(getChild(group3, "actionLeftProgressCastAltBind"), mySettings.actionLeftProgressCastAltBind)
	setText(getChild(group3, "actionLeftProgressCastCtrlBind"), mySettings.actionLeftProgressCastCtrlBind)
	setText(getChild(group3, "actionRightProgressCastSimpleBind"), mySettings.actionRightProgressCastSimpleBind)
	setText(getChild(group3, "actionRightProgressCastShiftBind"), mySettings.actionRightProgressCastShiftBind)
	setText(getChild(group3, "actionRightProgressCastAltBind"), mySettings.actionRightProgressCastAltBind)
	setText(getChild(group3, "actionRightProgressCastCtrlBind"), mySettings.actionRightProgressCastCtrlBind)
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
	local txtWdg = getChild(aWdg, "ModeNameTextView")
	local currValue = common.ExtractWStringFromValuedText(txtWdg:GetValuedText())
	return GetSwitchIndexByName(m_actionSwitch, currValue)
end

function SetSwitchIndex(aWdg, anIndex)
	if anIndex == nil then
		anIndex = 0
	end
	
	local txtWdg = getChild(aWdg, "ModeNameTextView")
	txtWdg:SetVal("Name", m_actionSwitch[anIndex])
end

function SwitchActionClickBtn(aWdg)
	local currInd = GetCurrentSwitchIndex(aWdg)
	currInd = currInd + 1
	if currInd > AUTOCAST_CLICK then
		currInd = DISABLE_CLICK
	end
	SetSwitchIndex(aWdg, currInd)
end