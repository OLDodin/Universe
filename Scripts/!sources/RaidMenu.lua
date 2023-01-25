
--------------------------------------------------------------------------------
-- Raid move
--------------------------------------------------------------------------------
local function CheckHelper(aUniqueID)
	local raidHelpers = raid.GetLeaderHelpers()
	if not raidHelpers then
		return false
	end
	
	for _, uniqueID in pairs(raidHelpers) do
		if uniqueID:IsEqual(aUniqueID) then	
			return true
		end
	end
	return false
end

function CanMovePlayers(aMyUniqueID)
	if isRaid() then
		local iamHelper = CheckHelper(aMyUniqueID)
		if raid.IsLeader() or iamHelper then
			return true
		end
	end
	return false
end

function MoveTo(aPartyNum, anUniqueID, aMyUniqueID)
	if CanMovePlayers(aMyUniqueID) and anUniqueID then
		if aPartyNum < 4 then
			local currGroupSize = getGroupSizeFromPersId(anUniqueID)
			local currGroupNum = getGroupFromPersId(anUniqueID)
			if currGroupNum and aPartyNum < currGroupNum or currGroupSize and currGroupSize > 1 then
				local emptyParty = getFirstEmptyPartyInRaid()
				if aPartyNum < emptyParty  then
					raid.MoveMemberToGroup(anUniqueID, aPartyNum)
				else
					raid.IsolateMember(anUniqueID)
				end
			end
		end
	end
end

function SwapPlayers(anUniqueID1, anUniqueID2, aMyUniqueID)
	if CanMovePlayers(aMyUniqueID) then
		if anUniqueID1 and anUniqueID2 then 
			raid.SwapMembers(anUniqueID1, anUniqueID2) 
		end
	end
end


--------------------------------------------------------------------------------
-- Menu
--------------------------------------------------------------------------------
local m_menu = nil
local m_menuWidth = 210
local m_menuInfos = {}
local m_whisperMode = false
local m_template = getChild(mainForm, "Template")

local function CloseMenu()
	if m_menu then
		destroy(m_menu)
		m_menu=nil
	end
end

local function AddToMenu(aName, aFunc)
	table.insert(m_menuInfos, aName)
	AddReaction(aName, aFunc)
end

function GenerateMenuInfos(aPlayerBar, aMyUniqueID)
	local uniqueID = aPlayerBar.uniqueID
	local playerID = aPlayerBar.playerID
	local iamHelper = CheckHelper(aMyUniqueID)
	m_menuInfos = {}
	local name = aPlayerBar.optimizeInfo.name
	local isAvatar = avatar.GetId()==playerID
	local canWhisper = isExist(playerID) and unit.IsPlayer(playerID) and isFriend(playerID) and not isAvatar
	local canInvite = canWhisper and not raid.IsAutomatic() and not group.IsAutomatic()
	local isLeader = aPlayerBar.optimizeInfo.isLeader

	
	if isAvatar and (isRaid() or isGroup()) then
		local lootScheme=loot.GetLootScheme()
		if lootScheme then
			if lootScheme==LOOT_SCHEME_TYPE_FREE_FOR_ALL 	then AddToMenu("freeLootMenuButton", function () if isLeader then loot.SetLootScheme(LOOT_SCHEME_TYPE_MASTER) CloseMenu() end end) end
			if lootScheme==LOOT_SCHEME_TYPE_MASTER 			then AddToMenu("masterLootMenuButton", function () if isLeader then loot.SetLootScheme(LOOT_SCHEME_TYPE_GROUP) CloseMenu() end end) end
			if lootScheme==LOOT_SCHEME_TYPE_GROUP 			then AddToMenu("groupLootMenuButton", function () if isLeader then loot.SetLootScheme(LOOT_SCHEME_TYPE_FREE_FOR_ALL) CloseMenu() end end) end
		end
		local quality=loot.GetMinItemQualityForLootScheme()
		if quality then
			if quality==ITEM_QUALITY_JUNK			 	then AddToMenu("junkLootMenuButton", function () if isLeader then loot.SetMinItemQualityForLootScheme(ITEM_QUALITY_GOODS) CloseMenu() end end) end
			if quality==ITEM_QUALITY_GOODS	 			then AddToMenu("goodsLootMenuButton", function () if isLeader then loot.SetMinItemQualityForLootScheme(ITEM_QUALITY_COMMON) CloseMenu() end end) end
			if quality==ITEM_QUALITY_COMMON	 			then AddToMenu("commonLootMenuButton", function () if isLeader then loot.SetMinItemQualityForLootScheme(ITEM_QUALITY_UNCOMMON) CloseMenu() end end) end
			if quality==ITEM_QUALITY_UNCOMMON			then AddToMenu("uncommonLootMenuButton", function () if isLeader then loot.SetMinItemQualityForLootScheme(ITEM_QUALITY_RARE) CloseMenu() end end) end
			if quality==ITEM_QUALITY_RARE	 			then AddToMenu("rareLootMenuButton", function () if isLeader then loot.SetMinItemQualityForLootScheme(ITEM_QUALITY_EPIC) CloseMenu() end end) end
			if quality==ITEM_QUALITY_EPIC	 			then AddToMenu("epicLootMenuButton", function () if isLeader then loot.SetMinItemQualityForLootScheme(ITEM_QUALITY_LEGENDARY) CloseMenu() end end) end
			if quality==ITEM_QUALITY_LEGENDARY	 		then AddToMenu("legendaryLootMenuButton", function () if isLeader then loot.SetMinItemQualityForLootScheme(ITEM_QUALITY_RELIC) CloseMenu() end end) end
			if quality==ITEM_QUALITY_RELIC	 			then AddToMenu("relicLootMenuButton", function () if isLeader then loot.SetMinItemQualityForLootScheme(ITEM_QUALITY_JUNK) CloseMenu() end end) end
		end
	end
--[[
	if not isAvatar and playerID ~= nil then
		AddToMenu("inspectButton", function () if avatar.IsInspectAllowed() then avatar.StartInspect(playerID) end CloseMenu() end)
	end
]]
	if canWhisper then
		AddToMenu("whisperMenuButton", function ()
			local chat=stateMainForm:GetChildUnchecked("ChatInput", false)
			chat=getChild(chat, "ChatInput")
			m_whisperMode = true
			show(chat)
			getChild(chat, "Input", true):SetFocus(true)
			mission.SetChatInputText(ConcatWString(toWString("/whisper "), name, toWString(" ")), 0)
			CloseMenu() end)
	end

	if isRaid() then
		local rights = raid.GetMemberRights(uniqueID)
		local isHelper = rights and (rights[0] and rights[0]==RAID_MEMBER_RIGHT_LEADER_HELPER or rights[1] and rights[1]==RAID_MEMBER_RIGHT_LEADER_HELPER)
		if raid.IsPlayerInAvatarsRaidById(uniqueID) then
			local isMaster = rights and (rights[0] and rights[0]==RAID_MEMBER_RIGHT_LOOT_MASTER or rights[1] and rights[1]==RAID_MEMBER_RIGHT_LOOT_MASTER)
			if isAvatar 		then AddToMenu("raidLeaveMenuButton", function () raid.Leave() CloseMenu() end) end
			if raid.IsLeader() 			then
				if not isAvatar and playerID ~= nil 	then
					AddToMenu("leaderMenuButton", function () raid.ChangeLeader(uniqueID) CloseMenu() end)
					if not isHelper then AddToMenu("addLeaderHelperMenuButton", function () raid.AddRight(uniqueID, RAID_MEMBER_RIGHT_LEADER_HELPER) CloseMenu() end)
					else 				 AddToMenu("deleteLeaderHelperMenuButton", function () raid.RemoveRight(uniqueID, RAID_MEMBER_RIGHT_LEADER_HELPER) CloseMenu() end) end
					if not isMaster then AddToMenu("addMasterLootMenuButton", function () raid.AddRight(uniqueID, RAID_MEMBER_RIGHT_LOOT_MASTER) CloseMenu() end)
					else 				 AddToMenu("deleteMasterLootMenuButton", function () raid.RemoveRight(uniqueID, RAID_MEMBER_RIGHT_LOOT_MASTER) CloseMenu() end) end
				end
				if not raid.IsAutomatic() then
					if not isAvatar 	then AddToMenu("kickMenuButton", function () raid.Kick(uniqueID) CloseMenu() end) end
					AddToMenu("disbandMenuButton", function () raid.Disband() CloseMenu() end)
				end
				AddToMenu("moveMenuButton", function () StartMove(uniqueID) CloseMenu() end)

			elseif iamHelper then
				AddToMenu("disbandMenuButton", function () raid.Disband() CloseMenu() end)
				AddToMenu("moveMenuButton", function () StartMove(uniqueID) CloseMenu() end)
			end
		else
			if canInvite and (isHelper or raid.IsLeader()) then AddToMenu("inviteMenuButton", function () raid.Invite(playerID) CloseMenu() end) end
		end
	elseif isGroup() then
		local memberInfo = group.GetMemberInfoById(uniqueID)
		if memberInfo or group.IsCreatureInGroup(playerID) then
			if isAvatar 		then
				AddToMenu("leaveMenuButton", function () group.Leave() CloseMenu() end)
				if group.IsLeader() and not group.IsAutomatic() then
					AddToMenu("createRaidMenuButton", function () raid.Create() CloseMenu() end)
					AddToMenu("createSmallRaidMenuButton", function () raid.CreateSmall() CloseMenu() end)
				end
			else
				if group.CanKickMember() 	then AddToMenu("kickMenuButton", function () group.KickMember(name) CloseMenu() end) end
				if group.IsLeader() and playerID ~= nil 		then AddToMenu("leaderMenuButton", function () group.SetLeader(uniqueID) CloseMenu() end) end
			end
		else
			if canInvite and group.CanInvite()	then AddToMenu("inviteMenuButton", function () group.Invite(playerID) CloseMenu() end) end
		end
	else
		if canInvite 					then AddToMenu("inviteMenuButton", function () group.Invite(playerID) CloseMenu() end) end
	end

	AddToMenu("closeMenuButton", function () CloseMenu() end)
end

function ShowMenu(aPlayerBar, aParams, aRaidPanelWdg, aRaidPanelSize, aMyUniqueID)
	CloseMenu()
	GenerateMenuInfos(aPlayerBar, aMyUniqueID)
	if not m_menuInfos then return end
	
	setTemplateWidget(m_template)
	local menuHeight=(table.maxn(m_menuInfos)+1)*20+8
	local menuX = aParams.x
	local menuY = aParams.y
	local raidPlacement = aRaidPanelWdg:GetPlacementPlain()
	
	if aParams.x > raidPlacement.posX + aRaidPanelSize.w - m_menuWidth then
		menuX = menuX - m_menuWidth
		menuX = menuX < 0 and 0 or menuX
	end
	if aParams.y > raidPlacement.posY + aRaidPanelSize.h/2 then
		menuY = menuY - menuHeight - 20
		menuY = menuY < 0 and 0 or menuY
	end
	
	m_menu = createWidget(mainForm, "Menu", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, m_menuWidth, menuHeight, menuX, menuY)
	priority(m_menu, 5600)

	local name = aPlayerBar.optimizeInfo.name
	setText(createWidget(m_menu, "Name", "TextView",  WIDGET_ALIGN_CENTER, WIDGET_ALIGN_LOW, m_menuWidth-8, 20, nil, 4), name, "LogColorYellow", "center")
	for i,j in ipairs(m_menuInfos) do
		setLocaleText(createWidget(m_menu, j, "Button",  WIDGET_ALIGN_CENTER, WIDGET_ALIGN_LOW, m_menuWidth-8, 20, nil, 4+(i)*20))
	end
end