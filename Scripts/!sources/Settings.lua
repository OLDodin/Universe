Global("BUFF_GROUP_WDG_NAME_PREFIX", "BuffGroup")

local m_currentProfile = nil
local m_currentProfileInd = nil

local function GetMyUserInd()
	local userID = avatar.GetServerId() or ""
	local buildID = avatar.GetActiveBuild() or ""
	
	return userID.."_"..buildID
end

local function LoadCurrentProfileInd()
	local lastUsedProfiles = userMods.GetGlobalConfigSection("TR_LastProfileArr")
	local currentInd = lastUsedProfiles[GetMyUserInd()]
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
	correctAboveHeadSettings.w = 5
	correctAboveHeadSettings.h = 1
	correctAboveHeadSettings.size = 50
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

function InitializeDefaultSetting()
	local allProfiles = userMods.GetGlobalConfigSection("TR_ProfilesArr")
	if allProfiles then
		return
	end
	
	allProfiles = {}
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
	raidFormSettings.showArrowButton = true
	raidFormSettings.gorisontalModeButton = false
	raidFormSettings.woundsShowButton = false
	raidFormSettings.showServerNameButton = true
	raidFormSettings.highlightSelectedButton = true
	raidFormSettings.showRollOverInfo = true
	raidFormSettings.raidWidthText = "160"
	raidFormSettings.raidHeightText = "50"
	raidFormSettings.distanceText = "0"
	raidFormSettings.buffSize = "20"
	raidFormSettings.raidBuffs = {}
	raidFormSettings.raidBuffs.autoDebuffModeButton = false
	raidFormSettings.raidBuffs.showImportantButton = true
	raidFormSettings.raidBuffs.checkControlsButton = false
	raidFormSettings.raidBuffs.checkMovementsButton = false
	raidFormSettings.raidBuffs.colorDebuffButton = true
	raidFormSettings.raidBuffs.checkFriendCleanableButton = true
	raidFormSettings.raidBuffs.customBuffs = {}
	
	local targeterFormSettings = {}
	targeterFormSettings.classColorModeButton = false
	targeterFormSettings.showManaButton = false
	targeterFormSettings.showShieldButton = true
	targeterFormSettings.showClassIconButton = true
	targeterFormSettings.showProcentButton = false
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
	targeterFormSettings.sortByName = true
	targeterFormSettings.sortByHP = false
	targeterFormSettings.sortByClass = false
	targeterFormSettings.sortByDead = false
	targeterFormSettings.raidBuffs = {}
	targeterFormSettings.raidBuffs.checkEnemyCleanable = false
	targeterFormSettings.raidBuffs.checkControlsButton = false
	targeterFormSettings.raidBuffs.checkMovementsButton = false
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

function SaveProfiles(aProfileList)
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
	return 2.7;
end
