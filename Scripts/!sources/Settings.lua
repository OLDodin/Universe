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

local function GetAboveHeadBuffSettings(aBuffName)
	return {
		name = aBuffName, 
		isSpell = false,
		isBuff = true,
		castByMe = false	
	}
end

local function GetRaidBuffSettings(aBuffName)
	return {
		name = aBuffName
	}
end

local function GetTargeterBuffSettings(aBuffName)
	return {
		name = aBuffName,
		castByMe = false
	}
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
	correctAboveHeadSettings.checkControlsButton = true
	correctAboveHeadSettings.checkMovementsButton = true

	correctAboveHeadSettings.aboveHeadFriendPlayersButton = false
	correctAboveHeadSettings.aboveHeadNotFriendPlayersButton = true
	correctAboveHeadSettings.aboveHeadFriendMobsButton = false
	correctAboveHeadSettings.aboveHeadNotFriendMobsButton = false
	
	correctAboveHeadSettings.buffs = {}
	
	local locale = getLocale()
	--"Аспект Защиты"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff1"]))
	--"Аспект Нападения"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff2"]))
	--"Аспект Поддержки"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff3"]))
	--"Аспект Исцеления"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff4"]))
	--"Аугментация «Оппортунист»"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff5"]))
	--"Мощь"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff6"]))
	--"Доблесть"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff7"]))
	--"Прилив храбрости"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff8"]))
	--"Прилив здоровья"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff9"]))
	--"Защита"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff10"]))
	--"Раны"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff11"]))
	--"Уязвимость"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff12"]))
	--"Слабость"
	table.insert(correctAboveHeadSettings.buffs, GetAboveHeadBuffSettings(locale["defaultBuff13"]))

	
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
	raidFormSettings.invulnerableColor = table.sclone(g_invulnerableColor)
	raidFormSettings.invulnerableColor.a = 0
	raidFormSettings.raidBuffs.customBuffs = {}
	
	local locale = getLocale()
	--"Аспект Защиты"
	table.insert(raidFormSettings.raidBuffs.customBuffs, GetRaidBuffSettings(locale["defaultBuff1"]))
	--"Аспект Нападения"
	table.insert(raidFormSettings.raidBuffs.customBuffs, GetRaidBuffSettings(locale["defaultBuff2"]))
	--"Аспект Поддержки"
	table.insert(raidFormSettings.raidBuffs.customBuffs, GetRaidBuffSettings(locale["defaultBuff3"]))
	--"Аспект Исцеления"
	table.insert(raidFormSettings.raidBuffs.customBuffs, GetRaidBuffSettings(locale["defaultBuff4"]))
	--"Защита"
	table.insert(raidFormSettings.raidBuffs.customBuffs, GetRaidBuffSettings(locale["defaultBuff10"]))
	--"Раны"
	table.insert(raidFormSettings.raidBuffs.customBuffs, GetRaidBuffSettings(locale["defaultBuff11"]))
	--"Уязвимость"
	table.insert(raidFormSettings.raidBuffs.customBuffs, GetRaidBuffSettings(locale["defaultBuff12"]))
	--"Выбит из седла"
	table.insert(raidFormSettings.raidBuffs.customBuffs, GetRaidBuffSettings(locale["defaultBuff14"]))
	
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
	targeterFormSettings.invulnerableColor = table.sclone(g_invulnerableColor)
	targeterFormSettings.raidBuffs.customBuffs = {}
	targeterFormSettings.myTargets = {}
	

	--"Аспект Защиты"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff1"]))
	--"Аспект Нападения"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff2"]))
	--"Аспект Поддержки"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff3"]))
	--"Аспект Исцеления"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff4"]))
	--"Защита"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff10"]))
	--"Раны"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff11"]))
	--"Уязвимость"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff12"]))
	--"Выбит из седла"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff14"]))
	--"Наводчик"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff15"]))
	--"Лидерство"
	table.insert(targeterFormSettings.raidBuffs.customBuffs, GetTargeterBuffSettings(locale["defaultBuff16"]))

	
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

function IsProfileIndexChanged()
	return m_currentProfileInd ~= LoadCurrentProfileInd()
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
			if not buffSettings.name then
				buffSettings.name = common.GetEmptyWString()
			end
			buffSettings.name = removeHtmlFromWString(buffSettings.name)
		end
		
		for _, buffSettings in ipairs(m_currentProfile.targeterFormSettings.raidBuffs.customBuffs) do
			if not buffSettings.name then
				buffSettings.name = common.GetEmptyWString()
			end
			buffSettings.name = removeHtmlFromWString(buffSettings.name)
		end
		
		for _, buffGroupSettings in ipairs(m_currentProfile.buffFormSettings.buffGroups) do
			for _, buffSettings in ipairs(buffGroupSettings.buffs or {}) do
				if not buffSettings.name then
					buffSettings.name = common.GetEmptyWString()
				end
				buffSettings.name = removeHtmlFromWString(buffSettings.name)
			end
		end
	end
	
	if m_currentProfile.version < 3.2 or m_currentProfile.version == nil then
		if m_currentProfile.targeterFormSettings.classColorModeButton then
			m_currentProfile.targeterFormSettings.enemyColor = copyTable(m_currentProfile.targeterFormSettings.friendColor)
			m_currentProfile.targeterFormSettings.neitralColor = copyTable(m_currentProfile.targeterFormSettings.friendColor)
		end
	end
	
	if m_currentProfile.version < 3.3 or m_currentProfile.version == nil then
		for _, buffGroupSettings in ipairs(m_currentProfile.buffFormSettings.buffGroups) do
			buffGroupSettings.customBuffs = nil
			for _, buffSettings in ipairs(buffGroupSettings.buffs or {}) do
				buffSettings.time = nil
				buffSettings.isCD = nil
				buffSettings.nameLowerStr = nil
				buffSettings.ind = nil
			end
		end
		
		for _, buffSettings in ipairs(m_currentProfile.targeterFormSettings.raidBuffs.customBuffs) do
			buffSettings.isCastName = nil
		end
		
		m_currentProfile.raidFormSettings.invulnerableColor = table.sclone(g_invulnerableColor)
		m_currentProfile.raidFormSettings.invulnerableColor.a = 0
		m_currentProfile.targeterFormSettings.invulnerableColor = table.sclone(g_invulnerableColor)
		
		if m_currentProfile.targeterFormSettings.lastTargetType and m_currentProfile.targeterFormSettings.lastTargetType > 12 then
			m_currentProfile.targeterFormSettings.lastTargetType = m_currentProfile.targeterFormSettings.lastTargetType + 1
		end
	end
	
	if m_currentProfile.version < 3.32 or m_currentProfile.version == nil then
		--вынес старые проверки из окон настроек
		if m_currentProfile.raidFormSettings.raidBuffs.colorDebuffButton == nil then
			m_currentProfile.raidFormSettings.raidBuffs.colorDebuffButton = false 
		end
		if m_currentProfile.raidFormSettings.raidBuffs.checkFriendCleanableButton == nil then
			m_currentProfile.raidFormSettings.raidBuffs.checkFriendCleanableButton = false
		end
		if m_currentProfile.targeterFormSettings.separateBuffDebuff == nil then
			m_currentProfile.targeterFormSettings.separateBuffDebuff = false 
		end
		if m_currentProfile.targeterFormSettings.twoColumnMode == nil then 
			m_currentProfile.targeterFormSettings.twoColumnMode = false 
		end
		if m_currentProfile.targeterFormSettings.sortByName == nil then
			m_currentProfile.targeterFormSettings.sortByName = true
		end
		if m_currentProfile.targeterFormSettings.sortByHP == nil then
			m_currentProfile.targeterFormSettings.sortByHP = false
		end
		if m_currentProfile.targeterFormSettings.sortByClass == nil then
			m_currentProfile.targeterFormSettings.sortByClass = false
		end
		if m_currentProfile.targeterFormSettings.sortByDead == nil then
			m_currentProfile.targeterFormSettings.sortByDead = false 
		end
		if m_currentProfile.targeterFormSettings.targetLimit == nil then
			m_currentProfile.targeterFormSettings.targetLimit = "12" 
		end
		
		for _, buffSettings in ipairs(m_currentProfile.targeterFormSettings.raidBuffs.customBuffs) do
			if buffSettings.castByMe == nil then
				buffSettings.castByMe = false
			end
		end
		
		for _, buffGroupSettings in ipairs(m_currentProfile.buffFormSettings.buffGroups) do
			if buffGroupSettings.buffOnMe == nil then 
				buffGroupSettings.buffOnMe = true
			end
			if buffGroupSettings.buffOnTarget == nil then 
				buffGroupSettings.buffOnTarget = false
			end
			if buffGroupSettings.fixed == nil then 
				buffGroupSettings.fixed = false
			end
			if buffGroupSettings.fixedInsidePanel == nil then 
				buffGroupSettings.fixedInsidePanel = false
			end
			if buffGroupSettings.flipBuffsButton == nil then 
				buffGroupSettings.flipBuffsButton = false
			end
			if buffGroupSettings.aboveHeadButton == nil then 
				buffGroupSettings.aboveHeadButton = false
			end
			if buffGroupSettings.aboveHeadFriendPlayersButton == nil then 
				buffGroupSettings.aboveHeadFriendPlayersButton = false
			end
			if buffGroupSettings.aboveHeadNotFriendPlayersButton == nil then 
				buffGroupSettings.aboveHeadNotFriendPlayersButton = false
			end
			if buffGroupSettings.aboveHeadFriendMobsButton == nil then 
				buffGroupSettings.aboveHeadFriendMobsButton = false
			end
			if buffGroupSettings.aboveHeadNotFriendMobsButton == nil then 
				buffGroupSettings.aboveHeadNotFriendMobsButton = false
			end
			if buffGroupSettings.autoDebuffModeButtonUnk == nil then 
				buffGroupSettings.autoDebuffModeButtonUnk = false
			end
			if buffGroupSettings.checkEnemyCleanableUnk == nil then 
				buffGroupSettings.checkEnemyCleanableUnk = false
			end
			if buffGroupSettings.showImportantButton == nil then 
				buffGroupSettings.showImportantButton = false
			end
			if buffGroupSettings.checkControlsButton == nil then 
				buffGroupSettings.checkControlsButton = false
			end
			if buffGroupSettings.checkMovementsButton == nil then 
				buffGroupSettings.checkMovementsButton = false
			end
			if buffGroupSettings.buffs then
				for _, buffSettings in ipairs(buffGroupSettings.buffs) do
					if buffSettings.isBuff==nil then 
						buffSettings.isBuff=true
					end
					if buffSettings.castByMe==nil then
						buffSettings.castByMe=false
					end
					if buffSettings.isSpell==nil then
						buffSettings.isSpell=false
					end
				end
			end
		end
		
		if m_currentProfile.castFormSettings.showOnlyMyTarget == nil then
			m_currentProfile.castFormSettings.showOnlyMyTarget = false
		end
		
		if m_currentProfile.mainFormSettings.useCastSubSystem == nil then 
			m_currentProfile.mainFormSettings.useCastSubSystem = false 
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
	return 3.32;
end
