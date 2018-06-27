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
	local form=createWidget(nil, "bindSettingsForm", "Form", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 870, 620, 200, 100)
	hide(form)
	priority(form, 5000)

	local panel=createWidget(form, "Panel", "Panel")
	
	local group1 = createWidget(form, "group1", "Panel")
	align(group1, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group1, 415, 515)
	move(group1, 15, 47)
	
	local group2 = createWidget(form, "group2", "Panel")
	align(group2, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group2, 415, 515)
	move(group2, 445, 47)

	setLocaleText(createWidget(form, "bindSettingsFormHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 150, 20, nil, 16))
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(form, "bindForRaidHeader", "TextView",  WIDGET_ALIGN_LOW, nil, 150, 20, 170, 50))
	setLocaleText(createWidget(form, "bindForTargetHeader", "TextView",  WIDGET_ALIGN_LOW, nil, 150, 20, 590, 50))
	
	setLocaleText(createWidget(form, "raidBindSimpleButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 70, 110))
	setLocaleText(createWidget(form, "raidBindShiftButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 70, 230))
	setLocaleText(createWidget(form, "raidBindAltButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 70, 350))
	setLocaleText(createWidget(form, "raidBindCtrlButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 70, 470))
	
	setLocaleText(createWidget(form, "targetBindSimpleButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 500, 110))
	setLocaleText(createWidget(form, "targetBindShiftButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 500, 230))
	setLocaleText(createWidget(form, "targetBindAltButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 500, 350))
	setLocaleText(createWidget(form, "targetBindCtrlButton", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 500, 470))
	
	setLocaleText(createWidget(form, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 20, 140))
	setLocaleText(createWidget(form, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 20, 260))
	setLocaleText(createWidget(form, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 20, 380))
	setLocaleText(createWidget(form, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 20, 500))
	
	setLocaleText(createWidget(form, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 20, 170))
	setLocaleText(createWidget(form, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 20, 290))
	setLocaleText(createWidget(form, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 20, 410))
	setLocaleText(createWidget(form, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 20, 530))
	
	setLocaleText(createWidget(form, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 450, 140))
	setLocaleText(createWidget(form, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 450, 260))
	setLocaleText(createWidget(form, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 450, 380))
	setLocaleText(createWidget(form, "leftClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 450, 500))
	
	setLocaleText(createWidget(form, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 450, 170))
	setLocaleText(createWidget(form, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 450, 290))
	setLocaleText(createWidget(form, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 450, 410))
	setLocaleText(createWidget(form, "rightClick", "TextView", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 450, 530))
	
	createWidget(form, "actionLeftSwitchRaidSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 130, 140)
	createWidget(form, "actionLeftSwitchRaidShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 130, 260)
	createWidget(form, "actionLeftSwitchRaidAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 130, 380)
	createWidget(form, "actionLeftSwitchRaidCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 130, 500)
	
	createWidget(form, "actionRightSwitchRaidSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 130, 170)
	createWidget(form, "actionRightSwitchRaidShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 130, 290)
	createWidget(form, "actionRightSwitchRaidAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 130, 410)
	createWidget(form, "actionRightSwitchRaidCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 130, 530)
	
	createWidget(form, "actionLeftSwitchTargetSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 560, 140)
	createWidget(form, "actionLeftSwitchTargetShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 560, 260)
	createWidget(form, "actionLeftSwitchTargetAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 560, 380)
	createWidget(form, "actionLeftSwitchTargetCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 560, 500)

	createWidget(form, "actionRightSwitchTargetSimple", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 560, 170)
	createWidget(form, "actionRightSwitchTargetShift", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 560, 290)
	createWidget(form, "actionRightSwitchTargetAlt", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 560, 410)
	createWidget(form, "actionRightSwitchTargetCtrl", "ModePanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 100, 25, 560, 530)
	
	createWidget(form, "actionLeftRaidSimpleBind", "EditLine", nil, nil, 180, 25, 240, 140, nil, nil)
	createWidget(form, "actionLeftRaidShiftBind", "EditLine", nil, nil, 180, 25, 240, 260, nil, nil)
	createWidget(form, "actionLeftRaidAltBind", "EditLine", nil, nil, 180, 25, 240, 380, nil, nil)
	createWidget(form, "actionLeftRaidCtrlBind", "EditLine", nil, nil, 180, 25, 240, 500, nil, nil)
	createWidget(form, "actionRightRaidSimpleBind", "EditLine", nil, nil, 180, 25, 240, 170, nil, nil)
	createWidget(form, "actionRightRaidShiftBind", "EditLine", nil, nil, 180, 25, 240, 290, nil, nil)
	createWidget(form, "actionRightRaidAltBind", "EditLine", nil, nil, 180, 25, 240, 410, nil, nil)
	createWidget(form, "actionRightRaidCtrlBind", "EditLine", nil, nil, 180, 25, 240, 530, nil, nil)

	createWidget(form, "actionLeftTargetSimpleBind", "EditLine", nil, nil, 180, 25, 670, 140, nil, nil)
	createWidget(form, "actionLeftTargetShiftBind", "EditLine", nil, nil, 180, 25, 670, 260, nil, nil)
	createWidget(form, "actionLeftTargetAltBind", "EditLine", nil, nil, 180, 25, 670, 380, nil, nil)
	createWidget(form, "actionLeftTargetCtrlBind", "EditLine", nil, nil, 180, 25, 670, 500, nil, nil)
	createWidget(form, "actionRightTargetSimpleBind", "EditLine", nil, nil, 180, 25, 670, 170, nil, nil)
	createWidget(form, "actionRightTargetShiftBind", "EditLine", nil, nil, 180, 25, 670, 290, nil, nil)
	createWidget(form, "actionRightTargetAltBind", "EditLine", nil, nil, 180, 25, 670, 410, nil, nil)
	createWidget(form, "actionRightTargetCtrlBind", "EditLine", nil, nil, 180, 25, 670, 530, nil, nil)
	
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	DnD:Init(form, panel, true)
		
	return form
end

function SaveBindFormSettings(aForm)
	local mySettings = {}

	mySettings.actionLeftSwitchRaidSimple = GetCurrentSwitchIndex(getChild(aForm, "actionLeftSwitchRaidSimple"))
	mySettings.actionLeftSwitchRaidShift = GetCurrentSwitchIndex(getChild(aForm, "actionLeftSwitchRaidShift"))
	mySettings.actionLeftSwitchRaidAlt = GetCurrentSwitchIndex(getChild(aForm, "actionLeftSwitchRaidAlt"))
	mySettings.actionLeftSwitchRaidCtrl = GetCurrentSwitchIndex(getChild(aForm, "actionLeftSwitchRaidCtrl"))
	mySettings.actionRightSwitchRaidSimple = GetCurrentSwitchIndex(getChild(aForm, "actionRightSwitchRaidSimple"))
	mySettings.actionRightSwitchRaidShift = GetCurrentSwitchIndex(getChild(aForm, "actionRightSwitchRaidShift"))
	mySettings.actionRightSwitchRaidAlt = GetCurrentSwitchIndex(getChild(aForm, "actionRightSwitchRaidAlt"))
	mySettings.actionRightSwitchRaidCtrl = GetCurrentSwitchIndex(getChild(aForm, "actionRightSwitchRaidCtrl"))
	
	mySettings.actionLeftSwitchTargetSimple = GetCurrentSwitchIndex(getChild(aForm, "actionLeftSwitchTargetSimple"))
	mySettings.actionLeftSwitchTargetShift = GetCurrentSwitchIndex(getChild(aForm, "actionLeftSwitchTargetShift"))
	mySettings.actionLeftSwitchTargetAlt = GetCurrentSwitchIndex(getChild(aForm, "actionLeftSwitchTargetAlt"))
	mySettings.actionLeftSwitchTargetCtrl = GetCurrentSwitchIndex(getChild(aForm, "actionLeftSwitchTargetCtrl"))
	mySettings.actionRightSwitchTargetSimple = GetCurrentSwitchIndex(getChild(aForm, "actionRightSwitchTargetSimple"))
	mySettings.actionRightSwitchTargetShift = GetCurrentSwitchIndex(getChild(aForm, "actionRightSwitchTargetShift"))
	mySettings.actionRightSwitchTargetAlt = GetCurrentSwitchIndex(getChild(aForm, "actionRightSwitchTargetAlt"))
	mySettings.actionRightSwitchTargetCtrl = GetCurrentSwitchIndex(getChild(aForm, "actionRightSwitchTargetCtrl"))


	mySettings.actionLeftRaidSimpleBind = getText(getChild(aForm, "actionLeftRaidSimpleBind"))
	mySettings.actionLeftRaidShiftBind = getText(getChild(aForm, "actionLeftRaidShiftBind"))
	mySettings.actionLeftRaidAltBind = getText(getChild(aForm, "actionLeftRaidAltBind"))
	mySettings.actionLeftRaidCtrlBind = getText(getChild(aForm, "actionLeftRaidCtrlBind"))
	mySettings.actionRightRaidSimpleBind = getText(getChild(aForm, "actionRightRaidSimpleBind"))
	mySettings.actionRightRaidShiftBind = getText(getChild(aForm, "actionRightRaidShiftBind"))
	mySettings.actionRightRaidAltBind = getText(getChild(aForm, "actionRightRaidAltBind"))
	mySettings.actionRightRaidCtrlBind = getText(getChild(aForm, "actionRightRaidCtrlBind"))
	
	mySettings.actionLeftTargetSimpleBind = getText(getChild(aForm, "actionLeftTargetSimpleBind"))
	mySettings.actionLeftTargetShiftBind = getText(getChild(aForm, "actionLeftTargetShiftBind"))
	mySettings.actionLeftTargetAltBind = getText(getChild(aForm, "actionLeftTargetAltBind"))
	mySettings.actionLeftTargetCtrlBind = getText(getChild(aForm, "actionLeftTargetCtrlBind"))
	mySettings.actionRightTargetSimpleBind = getText(getChild(aForm, "actionRightTargetSimpleBind"))
	mySettings.actionRightTargetShiftBind = getText(getChild(aForm, "actionRightTargetShiftBind"))
	mySettings.actionRightTargetAltBind = getText(getChild(aForm, "actionRightTargetAltBind"))
	mySettings.actionRightTargetCtrlBind = getText(getChild(aForm, "actionRightTargetCtrlBind"))
	
	return mySettings
end

function LoadBindFormSettings(aForm)
	local profile = GetCurrentProfile()
	local mySettings = profile.bindFormSettings

	SetSwitchIndex(getChild(aForm, "actionLeftSwitchRaidSimple"), mySettings.actionLeftSwitchRaidSimple)
	SetSwitchIndex(getChild(aForm, "actionLeftSwitchRaidShift"), mySettings.actionLeftSwitchRaidShift)
	SetSwitchIndex(getChild(aForm, "actionLeftSwitchRaidAlt"), mySettings.actionLeftSwitchRaidAlt)
	SetSwitchIndex(getChild(aForm, "actionLeftSwitchRaidCtrl"), mySettings.actionLeftSwitchRaidCtrl)
	SetSwitchIndex(getChild(aForm, "actionRightSwitchRaidSimple"), mySettings.actionRightSwitchRaidSimple)
	SetSwitchIndex(getChild(aForm, "actionRightSwitchRaidShift"), mySettings.actionRightSwitchRaidShift)
	SetSwitchIndex(getChild(aForm, "actionRightSwitchRaidAlt"), mySettings.actionRightSwitchRaidAlt)
	SetSwitchIndex(getChild(aForm, "actionRightSwitchRaidCtrl"), mySettings.actionRightSwitchRaidCtrl)
	
	SetSwitchIndex(getChild(aForm, "actionLeftSwitchTargetSimple"), mySettings.actionLeftSwitchTargetSimple)
	SetSwitchIndex(getChild(aForm, "actionLeftSwitchTargetShift"), mySettings.actionLeftSwitchTargetShift)
	SetSwitchIndex(getChild(aForm, "actionLeftSwitchTargetAlt"), mySettings.actionLeftSwitchTargetAlt)
	SetSwitchIndex(getChild(aForm, "actionLeftSwitchTargetCtrl"), mySettings.actionLeftSwitchTargetCtrl)
	SetSwitchIndex(getChild(aForm, "actionRightSwitchTargetSimple"), mySettings.actionRightSwitchTargetSimple)
	SetSwitchIndex(getChild(aForm, "actionRightSwitchTargetShift"), mySettings.actionRightSwitchTargetShift)
	SetSwitchIndex(getChild(aForm, "actionRightSwitchTargetAlt"), mySettings.actionRightSwitchTargetAlt)
	SetSwitchIndex(getChild(aForm, "actionRightSwitchTargetCtrl"), mySettings.actionRightSwitchTargetCtrl)
	
	
	setText(getChild(aForm, "actionLeftRaidSimpleBind"), mySettings.actionLeftRaidSimpleBind)
	setText(getChild(aForm, "actionLeftRaidShiftBind"), mySettings.actionLeftRaidShiftBind)
	setText(getChild(aForm, "actionLeftRaidAltBind"), mySettings.actionLeftRaidAltBind)
	setText(getChild(aForm, "actionLeftRaidCtrlBind"), mySettings.actionLeftRaidCtrlBind)
	setText(getChild(aForm, "actionRightRaidSimpleBind"), mySettings.actionRightRaidSimpleBind)
	setText(getChild(aForm, "actionRightRaidShiftBind"), mySettings.actionRightRaidShiftBind)
	setText(getChild(aForm, "actionRightRaidAltBind"), mySettings.actionRightRaidAltBind)
	setText(getChild(aForm, "actionRightRaidCtrlBind"), mySettings.actionRightRaidCtrlBind)
	
	setText(getChild(aForm, "actionLeftTargetSimpleBind"), mySettings.actionLeftTargetSimpleBind)
	setText(getChild(aForm, "actionLeftTargetShiftBind"), mySettings.actionLeftTargetShiftBind)
	setText(getChild(aForm, "actionLeftTargetAltBind"), mySettings.actionLeftTargetAltBind)
	setText(getChild(aForm, "actionLeftTargetCtrlBind"), mySettings.actionLeftTargetCtrlBind)
	setText(getChild(aForm, "actionRightTargetSimpleBind"), mySettings.actionRightTargetSimpleBind)
	setText(getChild(aForm, "actionRightTargetShiftBind"), mySettings.actionRightTargetShiftBind)
	setText(getChild(aForm, "actionRightTargetAltBind"), mySettings.actionRightTargetAltBind)
	setText(getChild(aForm, "actionRightTargetCtrlBind"), mySettings.actionRightTargetCtrlBind)
end

function GetSwitchIndexByName(anArr, aName)
	for i, v in pairs(anArr) do
		if v == aName then
			return i
		end
	end
	return 0
end

function GetCurrentSwitchIndex(aWdg)
	local txtWdg = getChild(aWdg, "ModeNameTextView")
	local currValue = toString(common.ExtractWStringFromValuedText(txtWdg:GetValuedText()))
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