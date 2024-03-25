Global("BUFF_GROUP_WDG_NAME_PREFIX", "BuffGroup")

local m_currentProfile = nil
local m_currentProfileInd = nil

local function GetMyUserInd()
	local userID = avatar.GetServerId() or ""
	local buildID = avatar.GetActiveBuild() or ""
	
	return userID.."_"..buildID
end

local function FindProfileIndForMyUser()
	local userID = avatar.GetServerId() or ""
	local lastUsedProfiles = userMods.GetGlobalConfigSection("TR_LastProfileArr")
	for i = 0, 2 do
		local existInd = lastUsedProfiles[userID.."_"..tostring(i)]
		if existInd ~= nil then
			return existInd
		end
	end
end

local function LoadCurrentProfileInd()
	local lastUsedProfiles = userMods.GetGlobalConfigSection("TR_LastProfileArr")
	local currentInd = lastUsedProfiles[GetMyUserInd()]
	if currentInd == nil then
		currentInd = FindProfileIndForMyUser()
	end
	if currentInd == nil or currentInd == 0 then
		currentInd = 1
	end
	return currentInd
end

local function SetCurrentProfileInd(anInd)
	local lastUsedProfiles = userMods.GetGlobalConfigSection("TR_LastProfileArr")
	lastUsedProfiles[GetMyUserInd()] = anInd
	userMods.SetGlobalConfigSection("TR_LastProfileArr", lastUsedProfiles)
end

local function GenerateAboveHeadGroup()
	local correctAboveHeadSettings = {}
	correctAboveHeadSettings.w = 8
	correctAboveHeadSettings.h = 1
	correctAboveHeadSettings.size = 50
	correctAboveHeadSettings.buffsOpacity = 1
	correctAboveHeadSettings.aboveHeadButton = true
	
	correctAboveHeadSettings.buffOnMe = false
	correctAboveHeadSettings.buffOnTarget = false
	correctAboveHeadSettings.fixed = false
	correctAboveHeadSettings.fixedInsidePanel = false
	correctAboveHeadSettings.flipBuffsButton = false
	correctAboveHeadSettings.autoDebuffModeButtonUnk = false
	correctAboveHeadSettings.checkEnemyCleanableUnk = false
	correctAboveHeadSettings.showImportantButton = false
	correctAboveHeadSettings.checkControlsButton = false
	correctAboveHeadSettings.checkMovementsButton = false

	correctAboveHeadSettings.aboveHeadFriendPlayersButton = false
	correctAboveHeadSettings.aboveHeadNotFriendPlayersButton = false
	correctAboveHeadSettings.aboveHeadFriendMobsButton = false
	correctAboveHeadSettings.aboveHeadNotFriendMobsButton = false
	
	correctAboveHeadSettings.buffs = {}
	
	correctAboveHeadSettings.name = getLocale()["aboveHeadTxt"]
	
	return correctAboveHeadSettings
end

function GetDefaultSettings()
	local defaultProfile = {}
	
	local mainFormSettings = {}
	mainFormSettings.useRaidSubSystem = true
	mainFormSettings.useTargeterSubSystem = true
	mainFormSettings.useBuffMngSubSystem = true
	mainFormSettings.useBindSubSystem = false
	mainFormSettings.useCastSubSystem = true
	
	local raidFormSettings = {}
	raidFormSettings.classColorModeButton = false
	raidFormSettings.showManaButton = false
	raidFormSettings.showShieldButton = true
	raidFormSettings.showStandartRaidButton = false
	raidFormSettings.showClassIconButton = true
	raidFormSettings.showDistanceButton = true
	raidFormSettings.showProcentButton = false
	raidFormSettings.showProcentShieldButton = false
	raidFormSettings.showArrowButton = true
	raidFormSettings.gorisontalModeButton = false
	raidFormSettings.woundsShowButton = false
	raidFormSettings.showServerNameButton = true
	raidFormSettings.highlightSelectedButton = true
	raidFormSettings.showRollOverInfo = true
	raidFormSettings.raidWidthText = "160"
	raidFormSettings.raidHeightText = "50"
	raidFormSettings.distanceText = "0"
	raidFormSettings.showBuffTimeButton = false
	raidFormSettings.showGrayOnDistanceButton = true
	raidFormSettings.showFrameStripOnDistanceButton = true
	raidFormSettings.buffSize = "20"
	raidFormSettings.raidBuffs = {}
	raidFormSettings.raidBuffs.autoDebuffModeButton = false
	raidFormSettings.raidBuffs.showImportantButton = true
	raidFormSettings.raidBuffs.checkControlsButton = false
	raidFormSettings.raidBuffs.checkMovementsButton = false
	raidFormSettings.raidBuffs.colorDebuffButton = true
	raidFormSettings.raidBuffs.checkFriendCleanableButton = true
	raidFormSettings.buffsOpacityText = 1.0
	raidFormSettings.friendColor = g_relationColors[FRIEND_PANEL]
	raidFormSettings.clearColor = g_needClearColor
	raidFormSettings.selectionColor = g_selectionColor
	raidFormSettings.farColor = g_farColor	
	raidFormSettings.raidBuffs.customBuffs = {}
	
	local targeterFormSettings = {}
	targeterFormSettings.classColorModeButton = true
	targeterFormSettings.showManaButton = false
	targeterFormSettings.showShieldButton = true
	targeterFormSettings.showClassIconButton = true
	targeterFormSettings.showProcentButton = false
	targeterFormSettings.showProcentShieldButton = true
	targeterFormSettings.gorisontalModeButton = false
	targeterFormSettings.woundsShowButton = false
	targeterFormSettings.showServerNameButton = true
	targeterFormSettings.highlightSelectedButton = true
	targeterFormSettings.showRollOverInfo = true
	targeterFormSettings.hideUnselectableButton = true
	targeterFormSettings.lastTargetType = ALL_TARGETS
	targeterFormSettings.lastTargetWasActive = true
	targeterFormSettings.separateBuffDebuff = false
	targeterFormSettings.twoColumnMode = false
	targeterFormSettings.raidWidthText = "200"
	targeterFormSettings.raidHeightText = "30"
	targeterFormSettings.buffSize = "16"
	targeterFormSettings.targetLimit = "12"
	targeterFormSettings.showBuffTimeButton = true
	targeterFormSettings.sortByName = true
	targeterFormSettings.sortByHP = false
	targeterFormSettings.sortByClass = false
	targeterFormSettings.sortByDead = true
	targeterFormSettings.raidBuffs = {}
	targeterFormSettings.raidBuffs.checkEnemyCleanable = true
	targeterFormSettings.raidBuffs.checkControlsButton = false
	targeterFormSettings.raidBuffs.checkMovementsButton = false
	targeterFormSettings.buffsOpacityText = 1.0
	targeterFormSettings.friendColor = g_relationColors[FRIEND_PANEL]
	targeterFormSettings.enemyColor = g_relationColors[ENEMY_PANEL]
	targeterFormSettings.neitralColor = g_relationColors[NEITRAL_PANEL]
	targeterFormSettings.selectionColor = g_selectionColor
	targeterFormSettings.raidBuffs.customBuffs = {}
	targeterFormSettings.myTargets = {}
	
	local buffFormSettings = {}
	buffFormSettings.buffGroups = {}
	buffFormSettings.buffGroupsUnicCnt = 0
	table.insert(buffFormSettings.buffGroups, GenerateAboveHeadGroup())
		
	local bindFormSettings = {}
	bindFormSettings.actionLeftSwitchRaidSimple = SELECT_CLICK
	bindFormSettings.actionLeftSwitchRaidShift = DISABLE_CLICK
	bindFormSettings.actionLeftSwitchRaidAlt = DISABLE_CLICK
	bindFormSettings.actionLeftSwitchRaidCtrl = DISABLE_CLICK
	bindFormSettings.actionRightSwitchRaidSimple = MENU_CLICK
	bindFormSettings.actionRightSwitchRaidShift = DISABLE_CLICK
	bindFormSettings.actionRightSwitchRaidAlt = DISABLE_CLICK
	bindFormSettings.actionRightSwitchRaidCtrl = DISABLE_CLICK
	
	bindFormSettings.actionLeftSwitchTargetSimple = SELECT_CLICK
	bindFormSettings.actionLeftSwitchTargetShift = DISABLE_CLICK
	bindFormSettings.actionLeftSwitchTargetAlt = DISABLE_CLICK
	bindFormSettings.actionLeftSwitchTargetCtrl = DISABLE_CLICK
	bindFormSettings.actionRightSwitchTargetSimple = DISABLE_CLICK
	bindFormSettings.actionRightSwitchTargetShift = DISABLE_CLICK
	bindFormSettings.actionRightSwitchTargetAlt = DISABLE_CLICK
	bindFormSettings.actionRightSwitchTargetCtrl = DISABLE_CLICK
	
	bindFormSettings.actionLeftSwitchProgressCastSimple = SELECT_CLICK
	bindFormSettings.actionLeftSwitchProgressCastShift = DISABLE_CLICK
	bindFormSettings.actionLeftSwitchProgressCastAlt = DISABLE_CLICK
	bindFormSettings.actionLeftSwitchProgressCastCtrl = DISABLE_CLICK
	bindFormSettings.actionRightSwitchProgressCastSimple = DISABLE_CLICK
	bindFormSettings.actionRightSwitchProgressCastShift = DISABLE_CLICK
	bindFormSettings.actionRightSwitchProgressCastAlt = DISABLE_CLICK
	bindFormSettings.actionRightSwitchProgressCastCtrl = DISABLE_CLICK
	
	local castFormSettings = {}
	castFormSettings.showImportantCasts = true
	castFormSettings.showImportantBuffs = true
	castFormSettings.panelWidthText = "270"
	castFormSettings.panelHeightText = "40"
	castFormSettings.selectable = false
	castFormSettings.fixed = false
	castFormSettings.showOnlyMyTarget = false
	castFormSettings.ignoreList = {}
	
		
	defaultProfile.name = "default"
	defaultProfile.mainFormSettings = mainFormSettings
	defaultProfile.raidFormSettings = raidFormSettings
	defaultProfile.targeterFormSettings = targeterFormSettings
	defaultProfile.buffFormSettings = buffFormSettings
	defaultProfile.bindFormSettings = bindFormSettings
	defaultProfile.castFormSettings = castFormSettings
	
	defaultProfile.version = GetSettingsVersion()
	
	return defaultProfile
end

function InitializeDefaultSetting()
	local allProfiles = userMods.GetGlobalConfigSection("TR_ProfilesArr")
	if allProfiles then
		return
	end
	
	allProfiles = {}
	local defaultProfile = GetDefaultSettings()
	
	table.insert(allProfiles, defaultProfile)
	userMods.SetGlobalConfigSection("TR_ProfilesArr", allProfiles)	
	userMods.SetGlobalConfigSection("TR_LastProfileArr", {})
	SetCurrentProfileInd(1)
end

function LoadLastUsedSetting()
	LoadSettings(LoadCurrentProfileInd())
end

function LoadSettings(aProfileInd)
	local allProfiles = userMods.GetGlobalConfigSection("TR_ProfilesArr")
	m_currentProfile = allProfiles[aProfileInd]
	m_currentProfileInd = aProfileInd

	SetCurrentProfileInd(aProfileInd)

	if m_currentProfile.version == 1 or m_currentProfile.version == nil then
		local castFormSettings = {}
		castFormSettings.showImportantCasts = true
		castFormSettings.showImportantBuffs = true
		castFormSettings.panelWidthText = "270"
		castFormSettings.panelHeightText = "40"
		castFormSettings.selectable = false
		castFormSettings.fixed = false
		castFormSettings.showOnlyMyTarget = false
		
		m_currentProfile.castFormSettings = castFormSettings
		m_currentProfile.mainFormSettings.useCastSubSystem = true
		
		m_currentProfile.bindFormSettings.actionLeftSwitchProgressCastSimple = SELECT_CLICK
		m_currentProfile.bindFormSettings.actionLeftSwitchProgressCastShift = DISABLE_CLICK
		m_currentProfile.bindFormSettings.actionLeftSwitchProgressCastAlt = DISABLE_CLICK
		m_currentProfile.bindFormSettings.actionLeftSwitchProgressCastCtrl = DISABLE_CLICK
		m_currentProfile.bindFormSettings.actionRightSwitchProgressCastSimple = DISABLE_CLICK
		m_currentProfile.bindFormSettings.actionRightSwitchProgressCastShift = DISABLE_CLICK
		m_currentProfile.bindFormSettings.actionRightSwitchProgressCastAlt = DISABLE_CLICK
		m_currentProfile.bindFormSettings.actionRightSwitchProgressCastCtrl = DISABLE_CLICK
	end
	if m_currentProfile.version < 2.2 or m_currentProfile.version == nil then
		m_currentProfile.raidFormSettings.showRollOverInfo = true
		m_currentProfile.targeterFormSettings.showRollOverInfo = true
		
		m_currentProfile.raidFormSettings.highlightSelectedButton = true
		m_currentProfile.targeterFormSettings.highlightSelectedButton = true
	end
	if m_currentProfile.version < 2.3 or m_currentProfile.version == nil then
		m_currentProfile.castFormSettings.ignoreList = {}
	end
	if m_currentProfile.version < 2.5 or m_currentProfile.version == nil then
		m_currentProfile.raidFormSettings.showGrayOnDistanceButton = true
		m_currentProfile.raidFormSettings.showFrameStripOnDistanceButton = true
	end
	if m_currentProfile.version < 2.6 or m_currentProfile.version == nil then
		m_currentProfile.castFormSettings.fixed = false
		for _, buffGroupSettings in pairs(m_currentProfile.buffFormSettings.buffGroups) do
			buffGroupSettings.fixed = false
		end
	end
	if m_currentProfile.version < 2.7 or m_currentProfile.version == nil then
		-- панель настроек над головой должна быть одна, удаляем повторы причем основные настройки в таком случае с 1й, а бафов с последней (так это работало в таком случае)
		local aboveHeadArr = {}
		for i, buffGroupSettings in ipairs(m_currentProfile.buffFormSettings.buffGroups) do
			if buffGroupSettings.aboveHeadButton then
				table.insert(aboveHeadArr, buffGroupSettings)
			end
		end
		local correctAboveHeadSettings = nil
		if GetTableSize(aboveHeadArr) > 0 then
			correctAboveHeadSettings = copyTable(aboveHeadArr[1])
			correctAboveHeadSettings.buffs = copyTable(aboveHeadArr[GetTableSize(aboveHeadArr)].buffs)
			
			correctAboveHeadSettings.aboveHeadFriendPlayersButton = true
			correctAboveHeadSettings.aboveHeadNotFriendPlayersButton = correctAboveHeadSettings.isEnemyButton
			correctAboveHeadSettings.aboveHeadFriendMobsButton = false
			correctAboveHeadSettings.aboveHeadNotFriendMobsButton = false
			
			if correctAboveHeadSettings.isEnemyButton then
				correctAboveHeadSettings.aboveHeadFriendPlayersButton = false
			end
		else
			correctAboveHeadSettings = GenerateAboveHeadGroup()
		end
		
		local newBuffGroups = {}
		table.insert(newBuffGroups, correctAboveHeadSettings)
		for i, buffGroupSettings in ipairs(m_currentProfile.buffFormSettings.buffGroups) do
			if not buffGroupSettings.aboveHeadButton then
				table.insert(newBuffGroups, buffGroupSettings)
			end
		end
		
		m_currentProfile.buffFormSettings.buffGroups = newBuffGroups
		
		--не могут быть выбраны сразу оба, если выбраны оба сбросим один из флагов
		for i, buffGroupSettings in ipairs(m_currentProfile.buffFormSettings.buffGroups) do
			if buffGroupSettings.buffOnMe and buffGroupSettings.buffOnTarget then
				buffGroupSettings.buffOnMe = false
			end
			--при вынесении панели над головами на 1ю позицию собьются настройки позиций остальных панелей (исправлено далее, будем сохранять и имя виджета)
			buffGroupSettings.fixed = false
			buffGroupSettings.buffGroupWdgName = BUFF_GROUP_WDG_NAME_PREFIX..tostring(i)
		end
		
		m_currentProfile.buffFormSettings.buffGroupsUnicCnt = GetTableSize(m_currentProfile.buffFormSettings.buffGroups) + 1
	end
	
	if m_currentProfile.version < 2.9 or m_currentProfile.version == nil then
		m_currentProfile.raidFormSettings.showBuffTimeButton = false
		m_currentProfile.targeterFormSettings.showBuffTimeButton = true
		
		local wStr = common.GetEmptyWString()
		for _, element in ipairs(m_currentProfile.castFormSettings.ignoreList) do
			element.exceptionsEditText = wStr
		end
		
		m_currentProfile.raidFormSettings.buffsOpacityText = 1.0
		m_currentProfile.raidFormSettings.friendColor = g_relationColors[FRIEND_PANEL]
		m_currentProfile.raidFormSettings.clearColor = g_needClearColor
		m_currentProfile.raidFormSettings.selectionColor = g_selectionColor
		m_currentProfile.raidFormSettings.farColor = g_farColor
		m_currentProfile.raidFormSettings.showProcentShieldButton = false
		
		m_currentProfile.targeterFormSettings.buffsOpacityText = 1.0
		m_currentProfile.targeterFormSettings.friendColor = g_relationColors[FRIEND_PANEL]
		m_currentProfile.targeterFormSettings.enemyColor = g_relationColors[ENEMY_PANEL]
		m_currentProfile.targeterFormSettings.neitralColor = g_relationColors[NEITRAL_PANEL]
		m_currentProfile.targeterFormSettings.selectionColor = g_selectionColor
		m_currentProfile.targeterFormSettings.showProcentShieldButton = true
		
		for i, buffGroupSettings in ipairs(m_currentProfile.buffFormSettings.buffGroups) do
			buffGroupSettings.buffsOpacity = 1.0
		end
	end
	
	if m_currentProfile.version < 2.92 or m_currentProfile.version == nil then
		for _, buffSettings in ipairs(m_currentProfile.raidFormSettings.raidBuffs.customBuffs) do
			buffSettings.name = removeHtmlFromWString(buffSettings.name)
		end
		
		for _, buffSettings in ipairs(m_currentProfile.targeterFormSettings.raidBuffs.customBuffs) do
			buffSettings.name = removeHtmlFromWString(buffSettings.name)
		end
		
		for _, buffGroupSettings in ipairs(m_currentProfile.buffFormSettings.buffGroups) do
			for _, buffSettings in ipairs(buffGroupSettings.buffs or {}) do
				buffSettings.name = removeHtmlFromWString(buffSettings.name)
			end
		end
	end
	
	if m_currentProfile.version < GetSettingsVersion() or m_currentProfile.version == nil then
		m_currentProfile.version = GetSettingsVersion()
		SaveAllSettings(allProfiles)
	end
end

function ProfileWasDeleted(anInd)
	local lastUsedProfiles = userMods.GetGlobalConfigSection("TR_LastProfileArr")
	for i, index in pairs(lastUsedProfiles) do
		if index == anInd then
			lastUsedProfiles[i] = 0
		elseif index > anInd and index > 0 then
			lastUsedProfiles[i] = index - 1 
		end
	end
	userMods.SetGlobalConfigSection("TR_LastProfileArr", lastUsedProfiles)
	LoadLastUsedSetting()
end

function SaveAllSettings(aProfileList)
	userMods.SetGlobalConfigSection("TR_ProfilesArr", aProfileList)
end

function GetCurrentProfile()
	return m_currentProfile
end

function GetCurrentProfileInd()
	return m_currentProfileInd
end

function GetAllProfiles()
	return userMods.GetGlobalConfigSection("TR_ProfilesArr")
end

function ExportProfileByIndex(anInd)
	local allProfiles = userMods.GetGlobalConfigSection("TR_ProfilesArr")
	return StartSerialize(allProfiles[anInd])
end

function GetSettingsVersion()
	return 2.92;
end
