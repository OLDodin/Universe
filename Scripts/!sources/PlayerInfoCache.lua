local cachedIsValidBuff = object.IsValidBuff
local m_players = {}

local function CreatePlayerSubInfo(anID, aSubClass)
	local playerSubClassInfo = copyTable(aSubClass)
	playerSubClassInfo:Init(anID)

	return playerSubClassInfo
end

local function FabricMakePlayerInfoForGroupBuff(anID, aListeners, aNeedSpells)
	if not isExist(anID) then
		return
	end
	local player = m_players[anID] or {}

	if not player.buffs then
		player.buffs = CreatePlayerSubInfo(anID, PlayerBuffs)
	end
	player.buffs:SubscribeBuffPlateGui(aListeners)
	
	if aNeedSpells then
		if not player.spells then
			player.spells = CreatePlayerSubInfo(anID, PlayerSpells)
		end
		player.spells:SubscribeBuffPlateGui(aListeners)
	end
	
	m_players[anID] = player
end

local function FabricMakePlayerInfoForAboveHead(anID, aListener)
	if not isExist(anID) then
		return
	end
	local player = m_players[anID] or {}
	
	if not player.buffs then
		player.buffs = CreatePlayerSubInfo(anID, PlayerBuffs)
	end
	player.buffs:SubscribeAboveHeadGui(aListener)
	
	m_players[anID] = player
end

local function FabricMakePlayerInfo(anID, aListener, anIsRaidInfo)
	if not isExist(anID) then
		return
	end
	local player = m_players[anID] or {}
	local profile = GetCurrentProfile()
	
	local settings = profile.raidFormSettings
	if not anIsRaidInfo then
		settings = profile.targeterFormSettings
	end
	
	if not player.hp then
		player.hp = CreatePlayerSubInfo(anID, PlayerHP)	
	end
	if anIsRaidInfo then
		player.hp:SubscribeRaidGui(aListener)
	else
		player.hp:SubscribeTargetGui(aListener)
	end
	--[[
	--15.0 unit.GetRelativeWoundsComplexity removed
	if settings.woundsShowButton and unit.GetRelativeWoundsComplexity then
		if not player.wounds then
			player.wounds = CreatePlayerSubInfo(anID, PlayerWounds)
		end
		if anIsRaidInfo then
			player.wounds:SubscribeRaidGui(aListener)
		else
			player.wounds:SubscribeTargetGui(aListener)
		end
	end]]
	if anIsRaidInfo then
		if not player.afk then
			player.afk = CreatePlayerSubInfo(anID, PlayerAFK)	
		end
		if anIsRaidInfo then
			player.afk:SubscribeRaidGui(aListener)
		else
			--player.afk:SubscribeTargetGui(aListener)
		end
	end
	if not player.dead then
		player.dead = CreatePlayerSubInfo(anID, PlayerDead)	
	end
	if anIsRaidInfo then
		player.dead:SubscribeRaidGui(aListener)
	else
		player.dead:SubscribeTargetGui(aListener)
	end
	
	if not player.canSelect then
		player.canSelect = CreatePlayerSubInfo(anID, PlayerCanSelect)	
	end
	if anIsRaidInfo then
		player.canSelect:SubscribeRaidGui(aListener)
	else
		player.canSelect:SubscribeTargetGui(aListener)
	end
	
	if settings.showManaButton then
		if not player.mana then
			player.mana = CreatePlayerSubInfo(anID, PlayerMana)
		end
		if anIsRaidInfo then
			player.mana:SubscribeRaidGui(aListener)
		else
			player.mana:SubscribeTargetGui(aListener)
		end		
	end
		
	if anIsRaidInfo then
		if (settings.showDistanceButton or settings.showArrowButton or settings.distanceText ~= "0") and anID ~= g_myAvatarID then
			if not player.distance then
				player.distance = CreatePlayerSubInfo(anID, PlayerDistance)
			end
			player.distance:SubscribeRaidGui(aListener)
		end
	end
	
	if not player.buffs then
		player.buffs = CreatePlayerSubInfo(anID, PlayerBuffs)
	end
	if anIsRaidInfo then
		player.buffs:SubscribeRaidGui(aListener)
	else
		player.buffs:SubscribeTargetGui(aListener)
	end
	
	m_players[anID] = player
end

function FabricMakeRaidPlayerInfo(anID, aListener)
	FabricMakePlayerInfo(anID, aListener, true)
end

function FabricMakeTargetPlayerInfo(anID, aListener)
	FabricMakePlayerInfo(anID, aListener, false)
end

function FabricMakeAboveHeadPlayerInfo(anID, aListener)
	FabricMakePlayerInfoForAboveHead(anID, aListener)
end

function FabricMakeGroupBuffPlayerInfo(anID, aListeners, aNeedSpells)
	FabricMakePlayerInfoForGroupBuff(anID, aListeners, aNeedSpells)
end

function FabricClearAll()
	UnsubscribeRaidListeners()
	UnsubscribeTargetListener()
	UnsubscribeGroupBuffListeners()
	UnsubscribeAboveHeadListeners()
	FabricDestroyUnused()
end

function UnsubscribeAboveHeadListeners(anID)
	for playerID, player in pairs(m_players) do
		if not anID or playerID == anID then
			for _, playerInfo in pairs(player) do
				if playerInfo.UnsubscribeAboveHeadGui then
					playerInfo:UnsubscribeAboveHeadGui()
				end
			end
		end
	end
end

function UnsubscribeGroupBuffListeners(anID)
	for playerID, player in pairs(m_players) do
		if not anID or playerID == anID then
			for _, playerInfo in pairs(player) do
				if playerInfo.UnsubscribeBuffPlateGui then
					playerInfo:UnsubscribeBuffPlateGui()
				end
			end
		end
	end
end

function UnsubscribeRaidListeners(anID)
	for playerID, player in pairs(m_players) do
		if not anID or playerID == anID then
			for _, playerInfo in pairs(player) do
				playerInfo:UnsubscribeRaidGui()
			end
		end
	end
end

function UnsubscribeTargetListener(anID)
	for playerID, player in pairs(m_players) do
		if not anID or playerID == anID then
			for _, playerInfo in pairs(player) do
				playerInfo:UnsubscribeTargetGui()
			end
		end
	end
end

function FabricDestroyUnused()
	for playerID, player in pairs(m_players) do
		local playerObjAlive = false
		
		for playerInfoIndex, playerInfo in pairs(player) do
			if playerInfo:TryDestroy() then
				player[playerInfoIndex] = nil
			else
				playerObjAlive = true
			end
		end
		
		if not playerObjAlive then 
			m_players[playerID] = nil
		end
		
	end
end

function UpdateFabric()
	for playerID, player in pairs(m_players) do
		if isExist(playerID) then
			for _, playerInfo in pairs(player) do
				playerInfo:UpdateValueIfNeeded()
			end
		end
	end
end

local tick = 0
function FabicLogInfo()
	if not g_debugSubsrb then
		return
	end
	if tick == 20 then 
		LogInfo("FabicLogInfo begin")
		for n, v in pairs(g_regCnt) do
			LogInfo("FabicLogInfo n = ", n, "  cnt = ", v, "  s = ", GetTableSize(m_players))
		end
		LogInfo("FabicLogInfo end")	
		tick = 0
	end
	tick = tick + 1
end

function BuffsChanged(aParams)
	for objId, buffs in pairs( aParams.objects ) do
		local playerInfo = m_players[objId]
		if playerInfo then
			for buffID, _ in pairs( buffs ) do
				if cachedIsValidBuff(buffID) then
					playerInfo.buffs.changeEventFunc(buffID)
				else
					playerInfo.buffs.delEventFunc( { buffId = buffID } )
				end
			end
		end
	end 
end

function AfkChanged(aParams)
	if aParams.id then
		local playerInfo = m_players[aParams.id]
		if playerInfo and playerInfo.afk then
			playerInfo.afk.eventFunc(aParams)
		end
	end
end

function UnitDead(aParams)
	if aParams.unitId then
		local playerInfo = m_players[aParams.unitId]
		if playerInfo and playerInfo.dead then
			playerInfo.dead.eventFunc(aParams)
		end
		if playerInfo and playerInfo.hp then
			playerInfo.hp.eventFunc(aParams)
		end
	end
end

function WoundsChanged(aParams)
	if aParams.unitId then
		local playerInfo = m_players[aParams.unitId]
		if playerInfo and playerInfo.wounds then
			playerInfo.wounds.eventFunc(aParams)
		end
	end
end

function SelectableChanged(aParams)
	if aParams.objectId then
		local playerInfo = m_players[aParams.objectId]
		if playerInfo and playerInfo.canSelect then
			playerInfo.canSelect.eventFunc(aParams)
		end
	end
end

function AvatarClassFormChanged()
	local playerClass = unit.GetClass(g_myAvatarID)
	if playerClass and playerClass.className == "WARLOCK" then
		local playerInfo = m_players[g_myAvatarID]
		if playerInfo and playerInfo.spells then
			playerInfo.spells.avatarClassFormChangedEventFunc()
		end
	end
end