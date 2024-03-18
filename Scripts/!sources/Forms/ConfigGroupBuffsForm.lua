local m_currentFormSettings = nil
local m_totalGroupsSettings = nil

local m_loadedWndInd = 0
local m_commaWStr = userMods.ToWString("\"")
local m_group1 = nil
local m_group2 = nil
local m_group3 = nil
local m_group4 = nil
local m_group6 = nil
local m_group7 = nil

function CreateConfigGroupBuffsForm()
	local form=createWidget(mainForm, "configGroupBuffsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 945, 700, 550, 130)
	priority(form, 507)
	hide(form)
	
	createWidget(form, "buffGroupNameHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 420, 20, nil, 16)
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")
	
	setLocaleText(createWidget(form, "configBuffsHeader", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 20, 10, 50))
	--createWidget(form, "groupBuffSelector", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 280, 50)
	setLocaleText(createWidget(form, "addGroupBuffsButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 740, 50))
	setLocaleText(createWidget(form, "deleteGroupBuffsButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 150, 25, 550, 50))
	
	setLocaleText(createWidget(form, "changeGroupBuffName", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 20, 10, 80))
	setLocaleText(createWidget(form, "currentGroupBuffName", "EditLine",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 280, 80))
	
	m_group1 = createWidget(form, "group1", "Panel")
	align(m_group1, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(m_group1, 335, 128)
	
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
	move(group5, 378, 147)
	
	m_group6 = createWidget(form, "group6", "Panel")
	align(m_group6, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(m_group6, 335, 151)
	
	m_group7 = createWidget(form, "group7", "Panel")
	align(m_group7, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(m_group7, 335, 31)
	
	local settingsContainer = createWidget(form, "settingsContainer", "ScrollableContainer", nil, nil, 370, 505, 5, 140)
	
	

	setLocaleText(createWidget(m_group1, "widthBuffCntText", "TextView", nil, nil, 200, 25, 5, 8))
	setLocaleText(createWidget(m_group1, "heightBuffCntText", "TextView", nil, nil, 200, 25, 5, 38))
	setLocaleText(createWidget(m_group1, "sizeBuffGroupText", "TextView", nil, nil, 200, 25, 5, 68))
	setLocaleText(createWidget(m_group1, "buffsOpacityText", "TextView", nil, nil, 220, 25, 5, 98))
	createWidget(m_group1, "widthBuffCntEdit", "EditLine", nil, nil, 70, 25, 260, 8)
	createWidget(m_group1, "heightBuffCntEdit", "EditLine", nil, nil, 70, 25, 260, 38)
	createWidget(m_group1, "sizeBuffGroupEdit", "EditLine", nil, nil, 70, 25, 260, 68)
	createWidget(m_group1, "buffsOpacityEdit", "EditLine", nil, nil, 70, 25, 260, 98)
	
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

function SaveConfigGroupBuffsForm(aForm, aClose)
	local group5 = getChild(aForm, "group5")

	if m_loadedWndInd == 0 then
		return m_totalGroupsSettings
	end
	
	m_currentFormSettings.name = getText(getChild(aForm, "currentGroupBuffName"))
	
	m_currentFormSettings.w = tonumber(getTextString(getChild(m_group1, "widthBuffCntEdit")))
	m_currentFormSettings.h = tonumber(getTextString(getChild(m_group1, "heightBuffCntEdit")))
	m_currentFormSettings.size = tonumber(getTextString(getChild(m_group1, "sizeBuffGroupEdit")))
	local buffsOpacityEdit = getChild(m_group1, "buffsOpacityEdit")
	m_currentFormSettings.buffsOpacity = CheckEditVal(tonumber(getTextString(buffsOpacityEdit)), 1.0, 0.1, 1.0, buffsOpacityEdit)
	
	m_currentFormSettings.buffOnMe = getCheckBoxState(getChild(m_group2, "buffOnMe"))
	m_currentFormSettings.buffOnTarget = getCheckBoxState(getChild(m_group2, "buffOnTarget"))
	
	if not m_currentFormSettings.aboveHeadButton then
		m_currentFormSettings.fixed = not getCheckBoxState(getChild(m_group7, "buffsFixButton"))
	end
	
	m_currentFormSettings.fixedInsidePanel = getCheckBoxState(getChild(m_group3, "buffsFixInsidePanelButton"))
	if m_currentFormSettings.flipBuffsButton ~= getCheckBoxState(getChild(m_group3, "flipBuffsButton")) then
		m_currentFormSettings.fixed = false
		ResetPanelPos(m_loadedWndInd)
	end
	m_currentFormSettings.flipBuffsButton = getCheckBoxState(getChild(m_group3, "flipBuffsButton"))
	
	if m_currentFormSettings.aboveHeadButton then
		m_currentFormSettings.aboveHeadFriendPlayersButton = getCheckBoxState(getChild(m_group6, "aboveHeadFriendPlayersButton"))
		m_currentFormSettings.aboveHeadNotFriendPlayersButton = getCheckBoxState(getChild(m_group6, "aboveHeadNotFriendPlayersButton"))
		m_currentFormSettings.aboveHeadFriendMobsButton = getCheckBoxState(getChild(m_group6, "aboveHeadFriendMobsButton"))
		m_currentFormSettings.aboveHeadNotFriendMobsButton = getCheckBoxState(getChild(m_group6, "aboveHeadNotFriendMobsButton"))
	end
	
	m_currentFormSettings.autoDebuffModeButtonUnk = getCheckBoxState(getChild(m_group4, "autoDebuffModeButtonUnk"))
	m_currentFormSettings.checkEnemyCleanableUnk = getCheckBoxState(getChild(m_group4, "checkEnemyCleanableUnk"))
	m_currentFormSettings.showImportantButton = getCheckBoxState(getChild(m_group4, "showImportantButton"))
	m_currentFormSettings.checkControlsButton = getCheckBoxState(getChild(m_group4, "checkControlsButton"))
	m_currentFormSettings.checkMovementsButton = getCheckBoxState(getChild(m_group4, "checkMovementsButton"))

	local container = getChild(group5, "groupBuffContainer")
	if container and m_currentFormSettings.buffs then
		for i, j in ipairs(m_currentFormSettings.buffs) do
			j.name = getText(getChild(container, "Name"..tostring(i), true))
			j.isBuff = getCheckBoxState(getChild(container, "isBuff"..tostring(i), true))
			j.castByMe = getCheckBoxState(getChild(container, "castByMe"..tostring(i), true))
			j.isSpell = getCheckBoxState(getChild(container, "isSpell"..tostring(i), true))
		end
	end
	
	m_totalGroupsSettings.buffGroups[m_loadedWndInd] = m_currentFormSettings
	
	if aClose then
		m_loadedWndInd = 0
		DnD.HideWdg(aForm)
	end

	return m_totalGroupsSettings
end

function LoadConfigGroupBuffsForm(aForm, anIndex, aInitLoad)
	local profile = GetCurrentProfile()
	if aInitLoad then
		m_totalGroupsSettings = deepCopyTable(profile.buffFormSettings)
	end
	local settingsContainer = getChild(aForm, "settingsContainer")
	local group5 = getChild(aForm, "group5")
	
	
	m_loadedWndInd = anIndex
	m_currentFormSettings = m_totalGroupsSettings.buffGroups[m_loadedWndInd]
	--deepCopyTable(profile.buffFormSettings.buffGroups[m_loadedWndInd])
	
	setText(getChild(m_group1, "widthBuffCntEdit"), m_currentFormSettings.w or 5)
	setText(getChild(m_group1, "heightBuffCntEdit"), m_currentFormSettings.h or 1)
	setText(getChild(m_group1, "sizeBuffGroupEdit"), m_currentFormSettings.size or 50)
	if m_currentFormSettings.buffsOpacity == 1 then
		setText(getChild(m_group1, "buffsOpacityEdit"), "1.0")
	else
		setText(getChild(m_group1, "buffsOpacityEdit"), m_currentFormSettings.buffsOpacity or "1.0")
	end

	if m_currentFormSettings.buffOnMe == nil then 
		m_currentFormSettings.buffOnMe = true
	end
	if m_currentFormSettings.buffOnTarget == nil then 
		m_currentFormSettings.buffOnTarget = false
	end
	if m_currentFormSettings.fixed == nil then 
		m_currentFormSettings.fixed = false
	end
	if m_currentFormSettings.fixedInsidePanel == nil then 
		m_currentFormSettings.fixedInsidePanel = false
	end
	if m_currentFormSettings.flipBuffsButton == nil then 
		m_currentFormSettings.flipBuffsButton = false
	end
	if m_currentFormSettings.aboveHeadButton == nil then 
		m_currentFormSettings.aboveHeadButton = false
	end
	if m_currentFormSettings.aboveHeadFriendPlayersButton == nil then 
		m_currentFormSettings.aboveHeadFriendPlayersButton = false
	end
	if m_currentFormSettings.aboveHeadNotFriendPlayersButton == nil then 
		m_currentFormSettings.aboveHeadNotFriendPlayersButton = false
	end
	if m_currentFormSettings.aboveHeadFriendMobsButton == nil then 
		m_currentFormSettings.aboveHeadFriendMobsButton = false
	end
	if m_currentFormSettings.aboveHeadNotFriendMobsButton == nil then 
		m_currentFormSettings.aboveHeadNotFriendMobsButton = false
	end
	if m_currentFormSettings.autoDebuffModeButtonUnk == nil then 
		m_currentFormSettings.autoDebuffModeButtonUnk = false
	end
	if m_currentFormSettings.checkEnemyCleanableUnk == nil then 
		m_currentFormSettings.checkEnemyCleanableUnk = false
	end
	if m_currentFormSettings.showImportantButton == nil then 
		m_currentFormSettings.showImportantButton = false
	end
	if m_currentFormSettings.checkControlsButton == nil then 
		m_currentFormSettings.checkControlsButton = false
	end
	if m_currentFormSettings.checkMovementsButton == nil then 
		m_currentFormSettings.checkMovementsButton = false
	end
	
	local textArr = {}
	for i, element in ipairs(m_totalGroupsSettings.buffGroups) do
		table.insert(textArr, element.name)
	end
	local groupBuffSelector = getChild(aForm, "groupBuffSelector")
	if groupBuffSelector then
		hide(groupBuffSelector)
		destroy(groupBuffSelector)
	end
	setTemplateWidget(getChild(mainForm, "Template"))
	groupBuffSelector = createWidget(aForm, "groupBuffSelector", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 280, 50)
	GenerateBtnForDropDown(groupBuffSelector, textArr)
	setText(getChild(getChild(groupBuffSelector, "DropDownHeaderPanel"), "ModeNameTextView"), m_currentFormSettings.name, "Neutral", "left", 11)
	
	setText(getChild(aForm, "buffGroupNameHeader"), ConcatWString(getLocale()["configGroupBuffsHeader"], m_commaWStr, m_currentFormSettings.name, m_commaWStr))
	setText(getChild(aForm, "currentGroupBuffName"), m_currentFormSettings.name)
	
	if anIndex == 1 then
		hide(getChild(aForm, "deleteGroupBuffsButton"))
	else
		show(getChild(aForm, "deleteGroupBuffsButton"))
	end
	
	setCheckBox(getChild(m_group2, "buffOnMe"), m_currentFormSettings.buffOnMe)
	setCheckBox(getChild(m_group2, "buffOnTarget"), m_currentFormSettings.buffOnTarget)
	
	if not m_currentFormSettings.aboveHeadButton then
		setCheckBox(getChild(m_group7, "buffsFixButton"), not m_currentFormSettings.fixed)
	end
	
	setCheckBox(getChild(m_group3, "buffsFixInsidePanelButton"), m_currentFormSettings.fixedInsidePanel)
	setCheckBox(getChild(m_group3, "flipBuffsButton"), m_currentFormSettings.flipBuffsButton)
	
	if m_currentFormSettings.aboveHeadButton then
		setCheckBox(getChild(m_group6, "aboveHeadFriendPlayersButton"), m_currentFormSettings.aboveHeadFriendPlayersButton)
		setCheckBox(getChild(m_group6, "aboveHeadNotFriendPlayersButton"), m_currentFormSettings.aboveHeadNotFriendPlayersButton)
		setCheckBox(getChild(m_group6, "aboveHeadFriendMobsButton"), m_currentFormSettings.aboveHeadFriendMobsButton)
		setCheckBox(getChild(m_group6, "aboveHeadNotFriendMobsButton"), m_currentFormSettings.aboveHeadNotFriendMobsButton)
	end
	
	setCheckBox(getChild(m_group4, "autoDebuffModeButtonUnk"), m_currentFormSettings.autoDebuffModeButtonUnk)
	setCheckBox(getChild(m_group4, "checkEnemyCleanableUnk"), m_currentFormSettings.checkEnemyCleanableUnk)
	setCheckBox(getChild(m_group4, "showImportantButton"), m_currentFormSettings.showImportantButton)
	setCheckBox(getChild(m_group4, "checkControlsButton"), m_currentFormSettings.checkControlsButton)
	setCheckBox(getChild(m_group4, "checkMovementsButton"), m_currentFormSettings.checkMovementsButton)

	if not m_currentFormSettings.buffs then
		m_currentFormSettings.buffs = {}
	end

	ShowValuesFromTable(m_currentFormSettings.buffs, aForm, getChild(group5, "groupBuffContainer"))

	if m_currentFormSettings.aboveHeadButton then
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

function ConfigGroupBuffsBuffOnMeChecked(aForm)
	if getCheckBoxState(getChild(m_group2, "buffOnMe")) then
		setCheckBox(getChild(m_group2, "buffOnTarget"), false)
	else
		setCheckBox(getChild(m_group2, "buffOnTarget"), true)
	end
end

function ConfigGroupBuffsBuffOnTargetChecked(aForm)
	if getCheckBoxState(getChild(m_group2, "buffOnTarget")) then
		setCheckBox(getChild(m_group2, "buffOnMe"), false)
	else
		setCheckBox(getChild(m_group2, "buffOnMe"), true)
	end
end

function AddBuffsInsideGroupToSroller(aForm)
	local group5 = getChild(aForm, "group5")
	AddElementFromForm(m_currentFormSettings.buffs, aForm, getChild(group5, "groupBuffContainer")) 
end

function DeleteBuffsInsideGroupFromSroller(aForm, aDeletingWdg)
	local groupBuffContainer = getChild(getChild(aForm, "group5"), "groupBuffContainer")
	local panelOfElement = groupBuffContainer:At(GetIndexForWidget(aDeletingWdg))
	local colorForm = getChild(panelOfElement, "colorSettingsForm")
	if colorForm then
		destroy(colorForm)
		resize(panelOfElement, nil, 30)	
		groupBuffContainer:ForceReposition()
	else
		DeleteContainer(m_currentFormSettings.buffs, aDeletingWdg, aForm)
	end
end

function AddBuffsGroup(aForm)
	table.insert(m_totalGroupsSettings.buffGroups, { name = Locales["enterName"] })
	local buffGroupCnt = GetTableSize(m_totalGroupsSettings.buffGroups)
	m_totalGroupsSettings.buffGroupsUnicCnt = m_totalGroupsSettings.buffGroupsUnicCnt + 1
	m_totalGroupsSettings.buffGroups[buffGroupCnt].buffGroupWdgName = BUFF_GROUP_WDG_NAME_PREFIX..tostring(m_totalGroupsSettings.buffGroupsUnicCnt)
	return buffGroupCnt
end

function DeleteCurrentBuffsGroup(aForm)
	if m_loadedWndInd == 1 then
		return
	end
	table.remove(m_totalGroupsSettings.buffGroups, m_loadedWndInd)
	m_loadedWndInd = 1
end

function UpdateConfigGroupBuffsFormPanelFixed(anIndex)
	m_totalGroupsSettings.buffGroups[anIndex].fixed = true
	if anIndex == m_loadedWndInd then
		if not m_currentFormSettings.aboveHeadButton then
			setCheckBox(getChild(m_group7, "buffsFixButton"), not m_currentFormSettings.fixed)
		end	
	end
end

function UpdateVisibleForPanelFixed()
	UpdateVisibleForGroupBuffTopPanel(m_totalGroupsSettings)
end

function CreateColorSettingsForBuffsGroupScroller(aForm, anIndex)
	local group5 = getChild(aForm, "group5")
	local groupBuffContainer = getChild(group5, "groupBuffContainer")
	local panelOfElement = groupBuffContainer:At(anIndex)
	
	local colorForm = getChild(panelOfElement, "colorSettingsForm")
	if colorForm then
		destroy(colorForm)
		resize(panelOfElement, nil, 30)		
	else
		colorForm = CreateColorSettingsForm(m_currentFormSettings.buffs[anIndex+1])
		resize(panelOfElement, nil, GetColorSettingsHeight())
		panelOfElement:AddChild(colorForm)
	end
	groupBuffContainer:ForceReposition()
end

function UpdateColorSettingsForBuffsGroupScroller(aForm, anIndex)
	local group5 = getChild(aForm, "group5")
	local groupBuffContainer = getChild(group5, "groupBuffContainer")
	local panelOfElement = groupBuffContainer:At(anIndex)
	local colorForm = getChild(panelOfElement, "colorSettingsForm")
	SaveBuffColorHighlight(colorForm, m_currentFormSettings.buffs[anIndex+1])
	destroy(colorForm)
	resize(panelOfElement, nil, 30)
	groupBuffContainer:ForceReposition()
end