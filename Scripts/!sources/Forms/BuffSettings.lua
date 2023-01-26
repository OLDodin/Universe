function CreateBuffSettingsForm()
	local form = createWidget(mainForm, "buffSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 550, 420, 350, 130)
	priority(form, 506)
	hide(form)
	
	setLocaleText(createWidget(form, "configBuffsHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 250, 20, nil, 20))
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(form, "addGroupBuffsButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 160, 25, 360, 320))
	createWidget(form, "EditLine1", "EditLine", nil, nil, 330, 25, 20, 320)

	createWidget(form, "container", "ScrollableContainer", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 270, 20, 50)

	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	DnD.Init(form, form, true)

	return form
end

function SaveBuffFormSettings(aForm)
	local mySettings = {}
	
	local profile = GetCurrentProfile()
	mySettings = profile.buffFormSettings
		
	UpdateTableValuesFromContainer(mySettings.buffGroups, aForm, getChild(aForm, "container"))
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
	
	ShowValuesFromTable(profile.buffFormSettings.buffGroups, aForm, getChild(aForm, "container"))
end


local m_loadedWndInd = 0
local m_commaWStr = userMods.ToWString("\"")

function CreateConfigGroupBuffsForm()
	local form=createWidget(mainForm, "configGroupBuffsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 1000, 600, 550, 130)
	priority(form, 507)
	hide(form)
	
	local group1 = createWidget(form, "group1", "Panel")
	align(group1, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group1, 415, 121)
	move(group1, 15, 137)
	
	local group2 = createWidget(form, "group2", "Panel")
	align(group2, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group2, 415, 91)
	move(group2, 15, 257)
	
	local group3 = createWidget(form, "group3", "Panel")
	align(group3, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group3, 415, 181)
	move(group3, 15, 357)
	
	local group4 = createWidget(form, "group4", "Panel")
	align(group4, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(group4, 555, 498)
	move(group4, 428, 47)
	
	--setLocaleText(createWidget(form, "configGroupBuffsHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 250, 20, nil, 16))
	createWidget(form, "buffGroupNameHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 400, 20, nil, 16)
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(form, "widthBuffCntText", "TextView", nil, nil, 200, 25, 20, 50))
	setLocaleText(createWidget(form, "heightBuffCntText", "TextView", nil, nil, 200, 25, 20, 80))
	setLocaleText(createWidget(form, "sizeBuffGroupText", "TextView", nil, nil, 200, 25, 20, 110))
	

	createWidget(form, "EditLine1", "EditLine", nil, nil, 200, 25, 220, 50)
	createWidget(form, "EditLine2", "EditLine", nil, nil, 200, 25, 220, 80)
	createWidget(form, "EditLine3", "EditLine", nil, nil, 200, 25, 220, 110)
	
	setLocaleText(createWidget(form, "buffOnMe", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 140), true)
	setLocaleText(createWidget(form, "buffOnTarget", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 170), true)
	
	setLocaleText(createWidget(form, "aboveHeadTxt", "TextView", nil, nil, 400, 25, 20, 140))
	setLocaleText(createWidget(form, "aboveHeadFriendPlayersButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 170), true)
	setLocaleText(createWidget(form, "aboveHeadNotFriendPlayersButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 200), true)
	setLocaleText(createWidget(form, "aboveHeadFriendMobsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 230), true)
	setLocaleText(createWidget(form, "aboveHeadNotFriendMobsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 260), true)
	
	setLocaleText(createWidget(form, "buffsFixButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 260), true)
	setLocaleText(createWidget(form, "buffsFixInsidePanelButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 290), true)
	setLocaleText(createWidget(form, "flipBuffsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 320), true)
	
	
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	setLocaleText(createWidget(form, "resetPanelBuffPosButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 200, 30, 15, 20))
	
	setLocaleText(createWidget(form, "raidBuffsButton", "TextView", nil, nil, 400, 25, 20, 360))
	setLocaleText(createWidget(form, "autoDebuffModeButtonUnk", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 390), true)
	setLocaleText(createWidget(form, "checkEnemyCleanableUnk", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 420), true)
	setLocaleText(createWidget(form, "showImportantButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 450), true)
	setLocaleText(createWidget(form, "checkControlsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 480), true)
	setLocaleText(createWidget(form, "checkMovementsButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 25, 20, 510), true)
	
	

	setLocaleText(createWidget(form, "addBuffsButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 130, 25, 843, 60))
	createWidget(form, "EditLine5", "EditLine", WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 390, 25, 433, 60)

	setLocaleText(createWidget(form, "configGroupBuffsId", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 30, 25, 533, 50))
	setLocaleText(createWidget(form, "configGroupBuffsName", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 220, 25, 313, 50))
	
	setLocaleText(createWidget(form, "configGroupBuffsBuff", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 50, 25, 173, 50))
	setLocaleText(createWidget(form, "castByMe", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 50, 25, 123, 50))
	setLocaleText(createWidget(form, "isSpell", "TextView",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 100, 25, 20, 50))

	createWidget(form, "container", "ScrollableContainer", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_HIGH, 545, 450, 25, 85)

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
	local mySettings = {}
	
	local profile = GetCurrentProfile()
	mySettings = profile.buffFormSettings
	
	if m_loadedWndInd == 0 then
		return mySettings
	end
	mySettings.buffGroups[m_loadedWndInd].w = tonumber(getTextString(getChild(aForm, "EditLine1")))
	mySettings.buffGroups[m_loadedWndInd].h = tonumber(getTextString(getChild(aForm, "EditLine2")))
	mySettings.buffGroups[m_loadedWndInd].size = tonumber(getTextString(getChild(aForm, "EditLine3")))
	mySettings.buffGroups[m_loadedWndInd].buffOnMe = getCheckBoxState(getChild(aForm, "buffOnMe"))
	mySettings.buffGroups[m_loadedWndInd].buffOnTarget = getCheckBoxState(getChild(aForm, "buffOnTarget"))
	mySettings.buffGroups[m_loadedWndInd].fixed = not getCheckBoxState(getChild(aForm, "buffsFixButton"))
	mySettings.buffGroups[m_loadedWndInd].fixedInsidePanel = getCheckBoxState(getChild(aForm, "buffsFixInsidePanelButton"))
	if mySettings.buffGroups[m_loadedWndInd].flipBuffsButton ~= getCheckBoxState(getChild(aForm, "flipBuffsButton")) then
		mySettings.buffGroups[m_loadedWndInd].fixed = false
	end
	mySettings.buffGroups[m_loadedWndInd].flipBuffsButton = getCheckBoxState(getChild(aForm, "flipBuffsButton"))
	mySettings.buffGroups[m_loadedWndInd].aboveHeadFriendPlayersButton = getCheckBoxState(getChild(aForm, "aboveHeadFriendPlayersButton"))
	mySettings.buffGroups[m_loadedWndInd].aboveHeadNotFriendPlayersButton = getCheckBoxState(getChild(aForm, "aboveHeadNotFriendPlayersButton"))
	mySettings.buffGroups[m_loadedWndInd].aboveHeadFriendMobsButton = getCheckBoxState(getChild(aForm, "aboveHeadFriendMobsButton"))
	mySettings.buffGroups[m_loadedWndInd].aboveHeadNotFriendMobsButton = getCheckBoxState(getChild(aForm, "aboveHeadNotFriendMobsButton"))
	mySettings.buffGroups[m_loadedWndInd].autoDebuffModeButtonUnk = getCheckBoxState(getChild(aForm, "autoDebuffModeButtonUnk"))
	mySettings.buffGroups[m_loadedWndInd].checkEnemyCleanableUnk = getCheckBoxState(getChild(aForm, "checkEnemyCleanableUnk"))
	mySettings.buffGroups[m_loadedWndInd].showImportantButton = getCheckBoxState(getChild(aForm, "showImportantButton"))
	mySettings.buffGroups[m_loadedWndInd].checkControlsButton = getCheckBoxState(getChild(aForm, "checkControlsButton"))
	mySettings.buffGroups[m_loadedWndInd].checkMovementsButton = getCheckBoxState(getChild(aForm, "checkMovementsButton"))

	local container = getChild(aForm, "container")
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
	local profile = GetCurrentProfile()
	local mySettings = profile.buffFormSettings
	local info = profile.buffFormSettings.buffGroups[anIndex]
	m_loadedWndInd = anIndex
	setText(getChild(aForm, "EditLine1"), info.w or 5)
	setText(getChild(aForm, "EditLine2"), info.h or 1)
	setText(getChild(aForm, "EditLine3"), info.size or 50)
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
	
	setCheckBox(getChild(aForm, "buffOnMe"), info.buffOnMe)
	setCheckBox(getChild(aForm, "buffOnTarget"), info.buffOnTarget)
	setCheckBox(getChild(aForm, "buffsFixButton"), not info.fixed)
	setCheckBox(getChild(aForm, "buffsFixInsidePanelButton"), info.fixedInsidePanel)
	setCheckBox(getChild(aForm, "flipBuffsButton"), info.flipBuffsButton)
	setCheckBox(getChild(aForm, "aboveHeadFriendPlayersButton"), info.aboveHeadFriendPlayersButton)
	setCheckBox(getChild(aForm, "aboveHeadNotFriendPlayersButton"), info.aboveHeadNotFriendPlayersButton)
	setCheckBox(getChild(aForm, "aboveHeadFriendMobsButton"), info.aboveHeadFriendMobsButton)
	setCheckBox(getChild(aForm, "aboveHeadNotFriendMobsButton"), info.aboveHeadNotFriendMobsButton)
	setCheckBox(getChild(aForm, "autoDebuffModeButtonUnk"), info.autoDebuffModeButtonUnk)
	setCheckBox(getChild(aForm, "checkEnemyCleanableUnk"), info.checkEnemyCleanableUnk)
	setCheckBox(getChild(aForm, "showImportantButton"), info.showImportantButton)
	setCheckBox(getChild(aForm, "checkControlsButton"), info.checkControlsButton)
	setCheckBox(getChild(aForm, "checkMovementsButton"), info.checkMovementsButton)

	if not profile.buffFormSettings.buffGroups[anIndex].buffs then
		profile.buffFormSettings.buffGroups[anIndex].buffs = {}
	end

	ShowValuesFromTable(profile.buffFormSettings.buffGroups[anIndex].buffs, aForm)

	if info.aboveHeadButton then
		hide(getChild(aForm, "buffOnMe"))
		hide(getChild(aForm, "buffOnTarget"))
		hide(getChild(aForm, "buffsFixButton"))
		show(getChild(aForm, "aboveHeadFriendPlayersButton"))
		show(getChild(aForm, "aboveHeadNotFriendPlayersButton"))
		show(getChild(aForm, "aboveHeadFriendMobsButton"))
		show(getChild(aForm, "aboveHeadNotFriendMobsButton"))
		show(getChild(aForm, "aboveHeadTxt"))
		
		resize(getChild(aForm, "group1"), 415, 151)
		resize(getChild(aForm, "group2"), 415, 61)
		move(getChild(aForm, "group2"), 15, 287)
		
		hide(getChild(aForm, "resetPanelBuffPosButton"))
	else
		show(getChild(aForm, "buffOnMe"))
		show(getChild(aForm, "buffOnTarget"))
		show(getChild(aForm, "buffsFixButton"))
		hide(getChild(aForm, "aboveHeadFriendPlayersButton"))
		hide(getChild(aForm, "aboveHeadNotFriendPlayersButton"))
		hide(getChild(aForm, "aboveHeadFriendMobsButton"))
		hide(getChild(aForm, "aboveHeadNotFriendMobsButton"))
		hide(getChild(aForm, "aboveHeadTxt"))
		
		resize(getChild(aForm, "group1"), 415, 61)
		resize(getChild(aForm, "group2"), 415, 91)
		move(getChild(aForm, "group2"), 15, 257)
		
		show(getChild(aForm, "resetPanelBuffPosButton"))
	end
end

function ConfigGroupBuffsBuffOnMeCheckedOn(aForm)
	if getCheckBoxState(getChild(aForm, "buffOnTarget")) then
		changeCheckBox(getChild(aForm, "buffOnTarget"))
	end
end

function ConfigGroupBuffsBuffOnTargetCheckedOn(aForm)
	if getCheckBoxState(getChild(aForm, "buffOnMe")) then
		changeCheckBox(getChild(aForm, "buffOnMe"))
	end
end