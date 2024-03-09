function CreateBuffSettingsForm()
	local form = createWidget(mainForm, "buffSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 550, 420, 350, 130)
	priority(form, 506)
	hide(form)
	
	setLocaleText(createWidget(form, "configBuffsHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 250, 20, nil, 20))
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(form, "addGroupBuffsButton", "Button", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 25, 50, 320))

	createWidget(form, "buffPanelSettingsContainer", "ScrollableContainer", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 270, 20, 50)

	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	DnD.Init(form, form, true)

	return form
end

function SaveBuffFormSettings(aForm)
	local mySettings = {}
	
	local profile = GetCurrentProfile()
	mySettings = profile.buffFormSettings
		
	UpdateTableValuesFromContainer(mySettings.buffGroups, aForm, getChild(aForm, "buffPanelSettingsContainer"))
	for i, _ in pairs(mySettings.buffGroups) do
		if not mySettings.buffGroups[i].buffs then
			mySettings.buffGroups[i].buffs = {}
		end
	end
	return mySettings
end

function LoadBuffFormSettings(aForm)
	local profile = GetCurrentProfile()
	local mySettings = profile.buffFormSettings
	
	ShowValuesFromTable(profile.buffFormSettings.buffGroups, aForm, getChild(aForm, "buffPanelSettingsContainer"))
end


local m_loadedWndInd = 0
local m_commaWStr = userMods.ToWString("\"")
local m_group1 = nil
local m_group2 = nil
local m_group3 = nil
local m_group4 = nil
local m_group6 = nil
local m_group7 = nil

function CreateConfigGroupBuffsForm()
	local form=createWidget(mainForm, "configGroupBuffsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 945, 600, 550, 130)
	priority(form, 507)
	hide(form)
	
	m_group1 = createWidget(form, "group1", "Panel")
	align(m_group1, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(m_group1, 335, 98)
	
	m_group2 = createWidget(form, "group2", "Panel")
	align(m_group2, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(m_group2, 335, 61)
		
	m_group3 = createWidget(form, "group3", "Panel")
	align(m_group3, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(m_group3, 335, 61)
		
	m_group4 = createWidget(form, "group4", "Panel")
	align(m_group4, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(m_group4, 335, 181)
		
	local group5 = createWidget(form, "group5", "Panel")
	align(group5, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group5, 555, 498)
	move(group5, 378, 47)
	
	m_group6 = createWidget(form, "group6", "Panel")
	align(m_group6, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(m_group6, 335, 151)
	
	m_group7 = createWidget(form, "group7", "Panel")
	align(m_group7, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(m_group7, 335, 31)
	
	local settingsContainer = createWidget(form, "settingsContainer", "ScrollableContainer", nil, nil, 370, 505, 5, 40)
	
	createWidget(form, "buffGroupNameHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 420, 20, nil, 16)
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(m_group1, "widthBuffCntText", "TextView", nil, nil, 200, 25, 5, 8))
	setLocaleText(createWidget(m_group1, "heightBuffCntText", "TextView", nil, nil, 200, 25, 5, 38))
	setLocaleText(createWidget(m_group1, "sizeBuffGroupText", "TextView", nil, nil, 200, 25, 5, 68))
	createWidget(m_group1, "widthBuffCntEdit", "EditLine", nil, nil, 70, 25, 260, 8)
	createWidget(m_group1, "heightBuffCntEdit", "EditLine", nil, nil, 70, 25, 260, 38)
	createWidget(m_group1, "sizeBuffGroupEdit", "EditLine", nil, nil, 70, 25, 260, 68)
	
	setLocaleText(createWidget(m_group2, "buffOnMe", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 3), true)
	setLocaleText(createWidget(m_group2, "buffOnTarget", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 33), true)
	
	setLocaleTextEx(createWidget(m_group6, "aboveHeadTxt", "TextView", nil, nil, 320, 25, 5, 3), nil, "ColorWhite", "center")
	setLocaleText(createWidget(m_group6, "aboveHeadFriendPlayersButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 33), true)
	setLocaleText(createWidget(m_group6, "aboveHeadNotFriendPlayersButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 63), true)
	setLocaleText(createWidget(m_group6, "aboveHeadFriendMobsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 93), true)
	setLocaleText(createWidget(m_group6, "aboveHeadNotFriendMobsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 123), true)
	
	setLocaleText(createWidget(m_group7, "buffsFixButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 3), true)
	
	setLocaleText(createWidget(m_group3, "buffsFixInsidePanelButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 3), true)
	setLocaleText(createWidget(m_group3, "flipBuffsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 33), true)
	
	setLocaleTextEx(createWidget(m_group4, "raidBuffsButton", "TextView", nil, nil, 320, 25, 5, 3), nil, "ColorWhite", "center")
	setLocaleText(createWidget(m_group4, "autoDebuffModeButtonUnk", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 33), true)
	setLocaleText(createWidget(m_group4, "checkEnemyCleanableUnk", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 63), true)
	setLocaleText(createWidget(m_group4, "showImportantButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 93), true)
	setLocaleText(createWidget(m_group4, "checkControlsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 123), true)
	setLocaleText(createWidget(m_group4, "checkMovementsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 5, 153), true)
	
	settingsContainer:PushBack(m_group7)
	settingsContainer:PushBack(m_group1)
	settingsContainer:PushBack(m_group2)
	settingsContainer:PushBack(m_group3)
	settingsContainer:PushBack(m_group4)
	settingsContainer:PushBack(m_group6)
	
	setLocaleText(createWidget(group5, "configGroupBuffsId", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 30, 25, 516, 3))
	setLocaleText(createWidget(group5, "configGroupBuffsName", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 220, 25, 296, 3))
	setLocaleText(createWidget(group5, "configGroupBuffsBuff", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 50, 25, 156, 3))
	setLocaleText(createWidget(group5, "castByMe", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 50, 25, 106, 3))
	setLocaleText(createWidget(group5, "isSpell", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 100, 25, 3, 3))
	setLocaleText(createWidget(group5, "addBuffsButton", "Button", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_HIGH, nil, 25, 50, 5))
	createWidget(group5, "groupBuffContainer", "ScrollableContainer", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 545, 450, 5, 10)
	
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 15))
	setLocaleText(createWidget(form, "resetPanelBuffPosButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 200, 30, 15, 15))

	DnD.Init(form, form, true)
	return form
end

function GetConfigGroupBuffsActiveNum()
	return m_loadedWndInd
end

function ResetConfigGroupBuffsActiveNum()
	m_loadedWndInd = 0
end

function SaveConfigGroupBuffsForm(aForm, aClose)
	local group5 = getChild(aForm, "group5")
	
	local mySettings = {}
	
	local profile = GetCurrentProfile()
	mySettings = profile.buffFormSettings
	
	if m_loadedWndInd == 0 then
		return mySettings
	end
	mySettings.buffGroups[m_loadedWndInd].w = tonumber(getTextString(getChild(m_group1, "widthBuffCntEdit")))
	mySettings.buffGroups[m_loadedWndInd].h = tonumber(getTextString(getChild(m_group1, "heightBuffCntEdit")))
	mySettings.buffGroups[m_loadedWndInd].size = tonumber(getTextString(getChild(m_group1, "sizeBuffGroupEdit")))
	
	mySettings.buffGroups[m_loadedWndInd].buffOnMe = getCheckBoxState(getChild(m_group2, "buffOnMe"))
	mySettings.buffGroups[m_loadedWndInd].buffOnTarget = getCheckBoxState(getChild(m_group2, "buffOnTarget"))
	
	if not mySettings.buffGroups[m_loadedWndInd].aboveHeadButton then
		mySettings.buffGroups[m_loadedWndInd].fixed = not getCheckBoxState(getChild(m_group7, "buffsFixButton"))
	end
	
	mySettings.buffGroups[m_loadedWndInd].fixedInsidePanel = getCheckBoxState(getChild(m_group3, "buffsFixInsidePanelButton"))
	if mySettings.buffGroups[m_loadedWndInd].flipBuffsButton ~= getCheckBoxState(getChild(m_group3, "flipBuffsButton")) then
		mySettings.buffGroups[m_loadedWndInd].fixed = false
		ResetPanelPos(m_loadedWndInd)
	end
	mySettings.buffGroups[m_loadedWndInd].flipBuffsButton = getCheckBoxState(getChild(m_group3, "flipBuffsButton"))
	
	if mySettings.buffGroups[m_loadedWndInd].aboveHeadButton then
		mySettings.buffGroups[m_loadedWndInd].aboveHeadFriendPlayersButton = getCheckBoxState(getChild(m_group6, "aboveHeadFriendPlayersButton"))
		mySettings.buffGroups[m_loadedWndInd].aboveHeadNotFriendPlayersButton = getCheckBoxState(getChild(m_group6, "aboveHeadNotFriendPlayersButton"))
		mySettings.buffGroups[m_loadedWndInd].aboveHeadFriendMobsButton = getCheckBoxState(getChild(m_group6, "aboveHeadFriendMobsButton"))
		mySettings.buffGroups[m_loadedWndInd].aboveHeadNotFriendMobsButton = getCheckBoxState(getChild(m_group6, "aboveHeadNotFriendMobsButton"))
	end
	
	mySettings.buffGroups[m_loadedWndInd].autoDebuffModeButtonUnk = getCheckBoxState(getChild(m_group4, "autoDebuffModeButtonUnk"))
	mySettings.buffGroups[m_loadedWndInd].checkEnemyCleanableUnk = getCheckBoxState(getChild(m_group4, "checkEnemyCleanableUnk"))
	mySettings.buffGroups[m_loadedWndInd].showImportantButton = getCheckBoxState(getChild(m_group4, "showImportantButton"))
	mySettings.buffGroups[m_loadedWndInd].checkControlsButton = getCheckBoxState(getChild(m_group4, "checkControlsButton"))
	mySettings.buffGroups[m_loadedWndInd].checkMovementsButton = getCheckBoxState(getChild(m_group4, "checkMovementsButton"))

	local container = getChild(group5, "groupBuffContainer")
	if container and mySettings.buffGroups[m_loadedWndInd].buffs then
		for i, j in ipairs(mySettings.buffGroups[m_loadedWndInd].buffs) do
			j.name = getText(getChild(container, "Name"..tostring(i), true))
			j.isBuff = getCheckBoxState(getChild(container, "isBuff"..tostring(i), true))
			j.castByMe = getCheckBoxState(getChild(container, "castByMe"..tostring(i), true))
			j.isSpell = getCheckBoxState(getChild(container, "isSpell"..tostring(i), true))
		end
	end
	if aClose then
		m_loadedWndInd = 0
	end
	return mySettings
end

function LoadConfigGroupBuffsForm(aForm, anIndex)
	local settingsContainer = getChild(aForm, "settingsContainer")
	local group5 = getChild(aForm, "group5")
	
	local profile = GetCurrentProfile()
	local mySettings = profile.buffFormSettings
	local info = profile.buffFormSettings.buffGroups[anIndex]
	m_loadedWndInd = anIndex
	setText(getChild(m_group1, "widthBuffCntEdit"), info.w or 5)
	setText(getChild(m_group1, "heightBuffCntEdit"), info.h or 1)
	setText(getChild(m_group1, "sizeBuffGroupEdit"), info.size or 50)
	if info.buffOnMe == nil then 
		info.buffOnMe = true
	end
	if info.buffOnTarget == nil then 
		info.buffOnTarget = false
	end
	if info.fixed == nil then 
		info.fixed = false
	end
	if info.fixedInsidePanel == nil then 
		info.fixedInsidePanel = false
	end
	if info.flipBuffsButton == nil then 
		info.flipBuffsButton = false
	end
	if info.aboveHeadButton == nil then 
		info.aboveHeadButton = false
	end
	if info.aboveHeadFriendPlayersButton == nil then 
		info.aboveHeadFriendPlayersButton = false
	end
	if info.aboveHeadNotFriendPlayersButton == nil then 
		info.aboveHeadNotFriendPlayersButton = false
	end
	if info.aboveHeadFriendMobsButton == nil then 
		info.aboveHeadFriendMobsButton = false
	end
	if info.aboveHeadNotFriendMobsButton == nil then 
		info.aboveHeadNotFriendMobsButton = false
	end
	if info.autoDebuffModeButtonUnk == nil then 
		info.autoDebuffModeButtonUnk = false
	end
	if info.checkEnemyCleanableUnk == nil then 
		info.checkEnemyCleanableUnk = false
	end
	if info.showImportantButton == nil then 
		info.showImportantButton = false
	end
	if info.checkControlsButton == nil then 
		info.checkControlsButton = false
	end
	if info.checkMovementsButton == nil then 
		info.checkMovementsButton = false
	end
	
	
	setText(getChild(aForm, "buffGroupNameHeader"), ConcatWString(getLocale()["configGroupBuffsHeader"], m_commaWStr, info.name, m_commaWStr))
	
	setCheckBox(getChild(m_group2, "buffOnMe"), info.buffOnMe)
	setCheckBox(getChild(m_group2, "buffOnTarget"), info.buffOnTarget)
	
	if not info.aboveHeadButton then
		setCheckBox(getChild(m_group7, "buffsFixButton"), not info.fixed)
	end
	
	setCheckBox(getChild(m_group3, "buffsFixInsidePanelButton"), info.fixedInsidePanel)
	setCheckBox(getChild(m_group3, "flipBuffsButton"), info.flipBuffsButton)
	
	if info.aboveHeadButton then
		setCheckBox(getChild(m_group6, "aboveHeadFriendPlayersButton"), info.aboveHeadFriendPlayersButton)
		setCheckBox(getChild(m_group6, "aboveHeadNotFriendPlayersButton"), info.aboveHeadNotFriendPlayersButton)
		setCheckBox(getChild(m_group6, "aboveHeadFriendMobsButton"), info.aboveHeadFriendMobsButton)
		setCheckBox(getChild(m_group6, "aboveHeadNotFriendMobsButton"), info.aboveHeadNotFriendMobsButton)
	end
	
	setCheckBox(getChild(m_group4, "autoDebuffModeButtonUnk"), info.autoDebuffModeButtonUnk)
	setCheckBox(getChild(m_group4, "checkEnemyCleanableUnk"), info.checkEnemyCleanableUnk)
	setCheckBox(getChild(m_group4, "showImportantButton"), info.showImportantButton)
	setCheckBox(getChild(m_group4, "checkControlsButton"), info.checkControlsButton)
	setCheckBox(getChild(m_group4, "checkMovementsButton"), info.checkMovementsButton)

	if not profile.buffFormSettings.buffGroups[anIndex].buffs then
		profile.buffFormSettings.buffGroups[anIndex].buffs = {}
	end

	ShowValuesFromTable(profile.buffFormSettings.buffGroups[anIndex].buffs, aForm, getChild(group5, "groupBuffContainer"))

	if info.aboveHeadButton then
		settingsContainer:RemoveItems()
		settingsContainer:PushBack(m_group1)
		settingsContainer:PushBack(m_group6)
		settingsContainer:PushBack(m_group3)
		settingsContainer:PushBack(m_group4)
		
		hide(getChild(aForm, "resetPanelBuffPosButton"))
	else
		settingsContainer:RemoveItems()
		settingsContainer:PushBack(m_group7)
		settingsContainer:PushBack(m_group1)
		settingsContainer:PushBack(m_group2)
		settingsContainer:PushBack(m_group3)
		settingsContainer:PushBack(m_group4)
		
		show(getChild(aForm, "resetPanelBuffPosButton"))
	end
end

function ConfigGroupBuffsBuffOnMeCheckedOn(aForm)
	if getCheckBoxState(getChild(m_group2, "buffOnTarget")) then
		changeCheckBox(getChild(m_group2, "buffOnTarget"))
	end
end

function ConfigGroupBuffsBuffOnTargetCheckedOn(aForm)
	if getCheckBoxState(getChild(m_group2, "buffOnMe")) then
		changeCheckBox(getChild(m_group2, "buffOnMe"))
	end
end