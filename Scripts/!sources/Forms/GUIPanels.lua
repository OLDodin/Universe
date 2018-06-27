local m_template = createWidget(nil, "Template", "Template")

local m_texIcons = {}
local m_texCheckState = {}
local m_texParty = {} 
function InitClassIconsTexture()
	m_texIcons["DRUID"] = common.GetAddonRelatedTexture("DruidIcon")
	m_texIcons["MAGE"] = common.GetAddonRelatedTexture("MageIcon")
	m_texIcons["PALADIN"] = common.GetAddonRelatedTexture("PaladinIcon")
	m_texIcons["PRIEST"] = common.GetAddonRelatedTexture("PriestIcon")
	m_texIcons["PSIONIC"] = common.GetAddonRelatedTexture("PsionicIcon")
	m_texIcons["STALKER"] = common.GetAddonRelatedTexture("StalkerIcon")
	m_texIcons["WARRIOR"] = common.GetAddonRelatedTexture("WarriorIcon")
	m_texIcons["NECROMANCER"] = common.GetAddonRelatedTexture("NecromancerIcon")
	m_texIcons["ENGINEER"] = common.GetAddonRelatedTexture("EngineerIcon")
	m_texIcons["BARD"] = common.GetAddonRelatedTexture("BardIcon")
	m_texIcons["WARLOCK"] = common.GetAddonRelatedTexture("WarlockIcon")
	m_texIcons["UNKNOWN"] = common.GetAddonRelatedTexture("UnknownIcon")
end

function InitButtonTextures()
	m_texParty[1] = common.GetAddonRelatedTexture("Party1")
	m_texParty[2] = common.GetAddonRelatedTexture("Party2")
	m_texParty[3] = common.GetAddonRelatedTexture("Party3")
	m_texParty[4] = common.GetAddonRelatedTexture("Party4")
end

function InitCheckTextures()
	m_texCheckState[READY_CHECK_READY_STATE_UNKNOWN] = common.GetAddonRelatedTexture("Unknown")
	m_texCheckState[READY_CHECK_READY_STATE_READY] = common.GetAddonRelatedTexture("True")
	m_texCheckState[READY_CHECK_READY_STATE_NOT_READY] = common.GetAddonRelatedTexture("False")
end

local m_classColors={
	["WARRIOR"]		= { r = 143/255; g = 119/255; b = 075/255; a = 1 },
	["PALADIN"]		= { r = 207/255; g = 220/255; b = 155/255; a = 1 },
	["MAGE"]		= { r = 126/255; g = 159/255; b = 255/255; a = 1 },
	["DRUID"]		= { r = 255/255; g = 118/255; b = 060/255; a = 1 },
	["PSIONIC"]		= { r = 221/255; g = 123/255; b = 245/255; a = 1 },
	["STALKER"]		= { r = 150/255; g = 204/255; b = 086/255; a = 1 },
	["PRIEST"]		= { r = 255/255; g = 207/255; b = 123/255; a = 1 },
	["NECROMANCER"]	= { r = 208/255; g = 069/255; b = 075/255; a = 1 },
	["ENGINEER"]    = { r = 127/255; g = 128/255; b = 178/255; a = 1 },
	["BARD"]		= { r = 51/255;  g = 230/255; b = 230/255; a = 1 },
	["WARLOCK"] 	= { r = 125/255; g = 101/255; b = 219/255; a = 1 }, 
	["UNKNOWN"]		= { r = 127/255; g = 127/255; b = 127/255; a = 0 }
}

local m_manaColor = { r=0, g=0.3, b=1, a=1 }
local m_energyColor =	{ r=1, g=0.3, b=0, a=1 }
local m_emptyWStr = common.GetEmptyWString()
local m_leaderWStr = userMods.ToWString("(*)")
local m_afkWStr = userMods.ToWString("[AFK]")
local m_offWStr = userMods.ToWString("[Off]")
local m_deadWStr = userMods.ToWString("[Dead]")
local AFK_STATE = 0
local OFF_STATE = 2
local DEAD_STATE = 3
local NORMAL_STATE = 4

local function SetArrowAngle(anArrowIcon, anAngle)
	if anAngle and anArrowIcon then
		local curAngle = anArrowIcon:GetRotation()
		if curAngle ~= anAngle then
			anArrowIcon:PlayRotationEffect(curAngle, anAngle, 200, EA_MONOTONOUS_INCREASE)
		end
	end
end

local function ChangeSelectable(anInfo, aPlayerBar)
	local barColor = copyTable(aPlayerBar.optimizeInfo.barColor)
	if anInfo then
		barColor.a = 1
		hide(aPlayerBar.farBarBackgroundWdg)
	else
		barColor.a = 0.8
		show(aPlayerBar.farBarBackgroundWdg)
	end
	
	if not compareColor(aPlayerBar.optimizeInfo.barColor, barColor) then
		aPlayerBar.optimizeInfo.barColor = barColor
		setBackgroundColor(aPlayerBar.barWdg, barColor)
	end
	
end

local function PlayerHPChanged(anInfo, aPlayerBar)
	if aPlayerBar.optimizeInfo.currHP == anInfo then
		return
	end

	aPlayerBar.optimizeInfo.currHP = anInfo
	local d = anInfo/100
	local newPanelW = aPlayerBar.formSettings.raidWidthText * d-4
	newPanelW = math.max(newPanelW, 1)
	resize(aPlayerBar.barWdg, newPanelW)
	if aPlayerBar.formSettings.raidBuffs.colorDebuffButton then
		resize(aPlayerBar.clearBarWdg, newPanelW)
	end
	if aPlayerBar.formSettings.showProcentButton then
		setText(aPlayerBar.procTextWdg, tostring(anInfo).."%", "LogColorYellow")
	end
end

local function PlayerShieldChanged(anInfo, aPlayerBar)
	if aPlayerBar.optimizeInfo.currShield == anInfo then
		return
	end
	aPlayerBar.optimizeInfo.currShield = anInfo
	local shieldWidth = anInfo/100 * aPlayerBar.formSettings.raidWidthText - 5
	resize(aPlayerBar.shieldBarWdg, shieldWidth)
end

local function PlayerManaChanged(anInfo, aPlayerBar)
	if aPlayerBar.optimizeInfo.currMana == anInfo then
		return
	end

	aPlayerBar.optimizeInfo.currMana = anInfo
	local manaBarWidth = anInfo/100 * aPlayerBar.formSettings.raidWidthText - 5
	resize(aPlayerBar.manaBarWdg, manaBarWidth)	
end

local function PlayerWoundsChanged(anInfo, aPlayerBar)
	if aPlayerBar.optimizeInfo.currWounds == anInfo then
		return
	end

	aPlayerBar.optimizeInfo.currWounds = anInfo
	setText(aPlayerBar.woundsTextWdg, "-"..tostring(math.floor(anInfo)).."%", "ColorGreen", "left")
end

local function PlayerDistanceChanged(anInfo, aPlayerBar)
	if anInfo.visibleChanged then
		if anInfo.needShow then
			show(aPlayerBar.distTextWdg)
			if aPlayerBar.formSettings.showArrowButton then
				show(aPlayerBar.arrowIconWdg)
			end
		else
			hide(aPlayerBar.distTextWdg)
			if aPlayerBar.formSettings.showArrowButton then
				hide(aPlayerBar.arrowIconWdg)
			end
		end
	end
	if not anInfo.needShow then
		return
	end
	
	if aPlayerBar.optimizeInfo.currDist ~= anInfo.dist then
		if aPlayerBar.formSettings.showDistanceButton then
			setText(aPlayerBar.distTextWdg, anInfo.dist, "LogColorYellow")
		end
		if aPlayerBar.formSettings.distanceText ~= "0" then
			local limitDist = tonumber(aPlayerBar.formSettings.distanceText)
			if aPlayerBar.optimizeInfo.canSelect then
				if anInfo.dist > limitDist then
					aPlayerBar.optimizeInfo.canSelectByDist = false
					ChangeSelectable(false, aPlayerBar)
				else
					aPlayerBar.optimizeInfo.canSelectByDist = true
					ChangeSelectable(true, aPlayerBar)
				end
			end
		end
		aPlayerBar.optimizeInfo.currDist = anInfo.dist
	end
	--LogInfo("anInfo.angle ", anInfo.angle)
	if aPlayerBar.formSettings.showArrowButton and aPlayerBar.optimizeInfo.currAngle ~= anInfo.angle then
		SetArrowAngle(aPlayerBar.arrowIconWdg, anInfo.angle)
		aPlayerBar.optimizeInfo.currAngle = anInfo.angle
	end
end

local function PlayerAfkChanged(anInfo, aPlayerBar)
	local userState = NORMAL_STATE
	if anInfo then
		userState = AFK_STATE
	end
	if aPlayerBar.optimizeInfo.userState ~= userState and aPlayerBar.optimizeInfo.userState ~= DEAD_STATE and aPlayerBar.optimizeInfo.userState ~= OFF_STATE  then
		aPlayerBar.optimizeInfo.userState = userState
		if userState == AFK_STATE then
			aPlayerBar.textWdg:SetVal("Afk-off", m_afkWStr)
		else
			aPlayerBar.textWdg:SetVal("Afk-off", m_emptyWStr)
		end
	end
end

local function PlayerDeadChanged(anInfo, aPlayerBar)
	local userState = NORMAL_STATE
	if anInfo then
		userState = DEAD_STATE
	end
	
	if aPlayerBar.optimizeInfo.userState ~= userState and aPlayerBar.optimizeInfo.userState ~= OFF_STATE then
		if userState == DEAD_STATE then
			aPlayerBar.textWdg:SetVal("Afk-off", m_deadWStr)
			PlayerHPChanged(0, aPlayerBar)
		else
			if aPlayerBar.optimizeInfo.userState == AFK_STATE then
				return
			end
			aPlayerBar.textWdg:SetVal("Afk-off", m_emptyWStr)
		end
		
		aPlayerBar.optimizeInfo.userState = userState
	end
end

local function PlayerCanSelectChanged(anInfo, aPlayerBar)
	aPlayerBar.optimizeInfo.canSelect = anInfo
	if not aPlayerBar.optimizeInfo.canSelectByDist and anInfo then
		return
	end
	ChangeSelectable(anInfo, aPlayerBar)
end

function PlayerTargetsHighlightChanged(anInfo, aPlayerBar)
	local barColor = nil
	if anInfo then
		barColor = { r=1; g=0; b=0.6; a=1 }
	else
		barColor = { r=1; g=1; b=1; a=1 }
	end
	aPlayerBar.highlight = anInfo
	
	if not compareColor(aPlayerBar.optimizeInfo.barBackgroundColor, barColor) then
		aPlayerBar.optimizeInfo.barBackgroundColor = barColor
		setBackgroundColor(aPlayerBar.barBackgroundWdg, barColor)
	end
end

local function FindBuffSlot(aPlayerBar, aBuffID, aBuffID2, aCnt, anArray)
	for i=1, aCnt do
		if anArray[i].buffID == aBuffID then
			return anArray[i], i
		end
	end
	return nil, nil
end

local function PlayerRemoveBuff(aBuffID, aPlayerBar, aCnt, anArray)
	local buffSlot, removeIndex = FindBuffSlot(aPlayerBar, aBuffID, nil, aCnt, anArray)
	if buffSlot then
		hide(buffSlot.buffWdg)
		if removeIndex ~= GetTableSize(anArray) then
			for i = removeIndex, aCnt do
				anArray[i] = anArray[i+1]
			end
			anArray[aCnt] = buffSlot
			for i = removeIndex, aCnt do
				move(anArray[i].buffWdg, 2+(i-1)*tonumber(aPlayerBar.formSettings.buffSize), 3)
			end
		end
		return true
	end
	return false
end

local function PlayerRemoveBuffPositive(aBuffID, aPlayerBar)
	if PlayerRemoveBuff(aBuffID, aPlayerBar, aPlayerBar.usedBuffSlotCnt, aPlayerBar.buffSlots) then
		aPlayerBar.usedBuffSlotCnt = aPlayerBar.usedBuffSlotCnt - 1
		if aPlayerBar.usedBuffSlotCnt < 0 then
			aPlayerBar.usedBuffSlotCnt = 0
		end
	end
end

local function PlayerRemoveBuffNegative(aBuffID, aPlayerBar)
	if PlayerRemoveBuff(aBuffID, aPlayerBar, aPlayerBar.usedBuffSlotNegCnt, aPlayerBar.buffSlotsNeg) then
		aPlayerBar.usedBuffSlotNegCnt = aPlayerBar.usedBuffSlotNegCnt - 1
		if aPlayerBar.usedBuffSlotNegCnt < 0 then
			aPlayerBar.usedBuffSlotNegCnt = 0
		end
		if aPlayerBar.usedBuffSlotNegCnt == 0 and aPlayerBar.formSettings.raidBuffs.colorDebuffButton then
			hide(aPlayerBar.clearBarWdg)
		end
	end
end

local function GetTextSizeByBuffSize(aSize)
	return math.floor(aSize/1.6)
end

local function PlayerAddBuff(aBuffInfo, aPlayerBar, anArray, aCnt)
	if not aBuffInfo.texture then
		return false
	end
	local buffSlot = FindBuffSlot(aPlayerBar, aBuffInfo.id, aBuffInfo.buffId, aCnt, anArray)
	local res = false
	if not buffSlot then
		local newCnt = aCnt + 1
		if newCnt > GetTableSize(anArray) then
			return res
		end
		
		buffSlot = anArray[newCnt]
		buffSlot.buffID = aBuffInfo.id
		buffSlot.buffWdg:Show(true)
		buffSlot.buffIcon:SetBackgroundTexture(aBuffInfo.texture)
		res = true
	end	
	if aBuffInfo.stackCount <= 1 then 
		hide(buffSlot.buffStackCnt)
	else
		show(buffSlot.buffStackCnt)
		setText(buffSlot.buffStackCnt, aBuffInfo.stackCount, nil, "right", GetTextSizeByBuffSize(tonumber(aPlayerBar.formSettings.buffSize)))
	end
	
	return res
end

local function PlayerAddBuffNegative(aBuffInfo, aPlayerBar)
	if PlayerAddBuff(aBuffInfo, aPlayerBar, aPlayerBar.buffSlotsNeg, aPlayerBar.usedBuffSlotNegCnt) then
		aPlayerBar.usedBuffSlotNegCnt = aPlayerBar.usedBuffSlotNegCnt + 1
		
		if aPlayerBar.usedBuffSlotNegCnt == 1 and aPlayerBar.formSettings.raidBuffs.colorDebuffButton then
			show(aPlayerBar.clearBarWdg)
		end
	end
end

local function PlayerAddBuffPositive(aBuffInfo, aPlayerBar)
	if PlayerAddBuff(aBuffInfo, aPlayerBar, aPlayerBar.buffSlots, aPlayerBar.usedBuffSlotCnt) then
		aPlayerBar.usedBuffSlotCnt = aPlayerBar.usedBuffSlotCnt + 1
	end
end

local function PlayerAddImportantBuff(aBuffInfo, aPlayerBar)
	if aBuffInfo.texture then
		show(aPlayerBar.importantBuff.buffWdg)
		aPlayerBar.importantBuff.buffID = aBuffInfo.id
		aPlayerBar.importantBuff.buffIcon:SetBackgroundTexture(aBuffInfo.texture)
	end
end

local function PlayerRemoveImportantBuff(aBuffID, aPlayerBar)
	if aPlayerBar.importantBuff.buffID == aBuffID then
		hide(aPlayerBar.importantBuff.buffWdg)
	end
end

function SetBaseInfoPlayerPanel(aPlayerBar, aPlayerInfo, anIsLeader, aFormSettings)
	aPlayerBar.isUsed = true
	aPlayerBar.playerID = aPlayerInfo.id
	aPlayerBar.uniqueID = aPlayerInfo.uniqueId
	aPlayerBar.formSettings = aFormSettings
	aPlayerBar.optimizeInfo.canSelect = true
	aPlayerBar.optimizeInfo.canSelectByDist = true
	
	aPlayerBar.usedBuffSlotCnt = 0
	for i = 1, GetTableSize(aPlayerBar.buffSlots) do 
		hide(aPlayerBar.buffSlots[i].buffWdg)
		aPlayerBar.buffSlots[i].buffID = nil
	end
	
	aPlayerBar.usedBuffSlotNegCnt = 0
	for i = 1, GetTableSize(aPlayerBar.buffSlotsNeg) do 
		hide(aPlayerBar.buffSlotsNeg[i].buffWdg)
		aPlayerBar.buffSlotsNeg[i].buffID = nil
	end
	hide(aPlayerBar.importantBuff.buffWdg)
	aPlayerBar.importantBuff.buffID = nil
	
	hide(aPlayerBar.clearBarWdg)
	
	local barColor = { r = 0.1; g = 0.8; b = 0; a = 1.0 }
	local isPlayerExist = isExist(aPlayerInfo.id)
	if isPlayerExist and (aFormSettings.showManaButton or aFormSettings.classColorModeButton) then
		local playerClass = unit.GetClass(aPlayerInfo.id)
		if playerClass and playerClass.className then 	
			aPlayerInfo.className = playerClass.className
			if aFormSettings.showManaButton and aPlayerBar.optimizeInfo.className ~= playerClass.className then
				aPlayerBar.optimizeInfo.className = playerClass.className
				if playerClass.manaType == MANA_TYPE_MANA then
					setBackgroundColor(aPlayerBar.manaBarWdg, m_manaColor)
					show(aPlayerBar.manaBarWdg)
				elseif playerClass.manaType == MANA_TYPE_ENERGY then			
					setBackgroundColor(aPlayerBar.manaBarWdg, m_energyColor)
					show(aPlayerBar.manaBarWdg)
				else
					hide(aPlayerBar.manaBarWdg)
				end
			end
			if aFormSettings.classColorModeButton then
				local color = m_classColors[playerClass.className]
				if not color then
					color = m_classColors["UNKNOWN"]
				end
				barColor = copyTable(color)
			end
		end
	end

	if aPlayerInfo.state == RAID_MEMBER_STATE_OFFLINE or aPlayerInfo.state == RAID_MEMBER_STATE_FAR 
	or aPlayerInfo.state == GROUP_MEMBER_STATE_OFFLINE or aPlayerInfo.state == GROUP_MEMBER_STATE_FAR  
	or (aPlayerInfo.state == GROUP_MEMBER_STATE_MERC and aPlayerInfo.id==nil) then
		barColor.a = 0.8
		show(aPlayerBar.farBarBackgroundWdg)
	else
		hide(aPlayerBar.farBarBackgroundWdg)
	end
	
	local leaderWStr = anIsLeader and m_leaderWStr or m_emptyWStr
	local userState = (aPlayerInfo.state == GROUP_MEMBER_STATE_OFFLINE or aPlayerInfo.state == RAID_MEMBER_STATE_OFFLINE) and OFF_STATE 
	or (aPlayerInfo.state == GROUP_MEMBER_STATE_AFK or aPlayerInfo.state == RAID_MEMBER_STATE_AFK) and AFK_STATE
	or (isPlayerExist and object.IsDead(aPlayerInfo.id)) and DEAD_STATE
	or NORMAL_STATE
	
	local offAfkWStr = userState == OFF_STATE and m_offWStr 
	or userState == AFK_STATE and m_afkWStr
	or userState == DEAD_STATE and m_deadWStr
	or m_emptyWStr
	if userState == DEAD_STATE then
		PlayerHPChanged(0, aPlayerBar)
	end

	if aFormSettings.showServerNameButton then
		local shardName = m_emptyWStr
		if --[[cartographer.IsOnCommon() and ]]aPlayerInfo.id and isPlayerExist and object.IsUnit(aPlayerInfo.id) and unit.IsPlayer(aPlayerInfo.id) then
			shardName = unit.GetPlayerShardName(aPlayerInfo.id)
			if shardName then 
				shardName = common.GetShortString(shardName)
			end
		end
		if not shardName then
			shardName = m_emptyWStr
		end
		
		if common.CompareWString(aPlayerBar.optimizeInfo.shardName, shardName)~=0 then
			aPlayerBar.optimizeInfo.shardName = shardName
			if not common.IsEmptyWString(shardName) then
				shardName = "["..toString(shardName).."] "
			end
			aPlayerBar.textWdg:SetVal("Server", shardName)
		end
	end
	
	if aPlayerBar.optimizeInfo.isLeader ~= anIsLeader then
		aPlayerBar.optimizeInfo.isLeader = anIsLeader
		aPlayerBar.textWdg:SetVal("Leader", leaderWStr)
	end
	if aPlayerBar.optimizeInfo.userState ~= userState then
		aPlayerBar.optimizeInfo.userState = userState
		aPlayerBar.textWdg:SetVal("Afk-off", offAfkWStr)
	end

	if common.CompareWString(aPlayerBar.optimizeInfo.name, aPlayerInfo.name)~=0 then
		aPlayerBar.optimizeInfo.name = aPlayerInfo.name
		aPlayerBar.textWdg:SetVal("Name", aPlayerInfo.name)
	end

	if aFormSettings.showClassIconButton then
		if isPlayerExist and not aPlayerInfo.className then
			local playerClass = unit.GetClass(aPlayerInfo.id)
			if playerClass and playerClass.className then 	
				aPlayerInfo.className = playerClass.className
			end
		end
		local textureIndexForIcon = aPlayerInfo.className or "UNKNOWN"
		if aPlayerBar.optimizeInfo.textureIndexForIcon ~= textureIndexForIcon then
			aPlayerBar.optimizeInfo.textureIndexForIcon = textureIndexForIcon
			setBackgroundTexture(aPlayerBar.classIconWdg, m_texIcons[textureIndexForIcon])
		end
	end

	if not compareColor(aPlayerBar.optimizeInfo.barColor, barColor) then
		aPlayerBar.optimizeInfo.barColor = barColor
		setBackgroundColor(aPlayerBar.barWdg, barColor)
	end
	
	show(aPlayerBar.wdg)
end

function ResetPlayerPanelPosition(aPlayerBar, aX, aY, aFormSettings)
	local panelWidth = tonumber(aFormSettings.raidWidthText)
	local panelHeight = tonumber(aFormSettings.raidHeightText)
	local mod1 = aFormSettings.gorisontalModeButton and aY or aX
	local mod2 = aFormSettings.gorisontalModeButton and aX or aY
	local posX = mod1*panelWidth
	local posY = mod2*panelHeight+30
	
	if aPlayerBar.optimizeInfo.posX ~= posX or aPlayerBar.optimizeInfo.posY ~= posY then
		aPlayerBar.optimizeInfo.posX = posX
		aPlayerBar.optimizeInfo.posY = posY
		move(aPlayerBar.wdg, posX, posY)
	end
end

function CreatePlayerPanel(aParentPanel, aX, aY, aRaidMode, aFormSettings)
	setTemplateWidget(aParentPanel)
	local barColor = { r = 0.8; g = 0.8; b = 0; a = 1.0 }
	local panelWidth = tonumber(aFormSettings.raidWidthText)
	local panelHeight = tonumber(aFormSettings.raidHeightText)
	local buffSize = tonumber(aFormSettings.buffSize)
	local mod1 = aFormSettings.gorisontalModeButton and aY or aX
	local mod2 = aFormSettings.gorisontalModeButton and aX or aY
	local posX = mod1*panelWidth
	local posY = mod2*panelHeight+30

	local playerBar = {}
	if aRaidMode then
		local raidMoveBar = createWidget(aParentPanel, nil, "AddBar", nil, nil, panelWidth, panelHeight, posX, posY)
		resize(getChild(raidMoveBar, "HealthBarBackground"), panelWidth, panelHeight)
		setBackgroundTexture(raidMoveBar, nil)
		local addBarColor = {r=0.8, g=1, b=0.5, a=0.8}
		setBackgroundColor(raidMoveBar, addBarColor)
		hide(raidMoveBar)
		playerBar.raidMoveWdg = raidMoveBar
	end
	playerBar.wdg = createWidget(aParentPanel, nil, "PlayerBar", nil, nil, panelWidth, panelHeight, posX, posY)
	playerBar.barWdg = getChild(playerBar.wdg, "HealthBar")
	playerBar.manaBarWdg = getChild(playerBar.wdg, "ManaBar")
	playerBar.shieldBarWdg = getChild(playerBar.wdg, "ShieldBar")
	playerBar.barBackgroundWdg = getChild(playerBar.wdg, "HealthBarBackground")
	playerBar.classIconWdg = getChild(playerBar.wdg, "ClassIcon")
	playerBar.textWdg = getChild(playerBar.wdg, "PlayerNameText")
	playerBar.distTextWdg = getChild(playerBar.wdg, "PlayerDistText")
	playerBar.woundsTextWdg = getChild(playerBar.wdg, "WoundsText")
	playerBar.procTextWdg = getChild(playerBar.wdg, "PlayerProcText")
	playerBar.arrowIconWdg = getChild(playerBar.wdg, "ArrowIcon")
	playerBar.checkIconWdg = getChild(playerBar.wdg, "CheckIcon")
	playerBar.buffPanelWdg = getChild(playerBar.wdg, "BuffPanel")
	playerBar.buffPanelNegativeWdg = getChild(playerBar.wdg, "BuffPanelNegative")
	playerBar.buffPanelImportantWdg = getChild(playerBar.wdg, "BuffPanelImportant")
	playerBar.farBarBackgroundWdg = getChild(playerBar.wdg, "FarBarBackground")
	playerBar.clearBarWdg = getChild(playerBar.wdg, "ClearBar")
	playerBar.optimizeInfo = {}
	playerBar.optimizeInfo.name = m_emptyWStr
	playerBar.optimizeInfo.shardName = m_emptyWStr
	playerBar.optimizeInfo.barColor = copyTable(barColor)
	playerBar.optimizeInfo.posX = posX
	playerBar.optimizeInfo.posY = posY
	playerBar.optimizeInfo.canSelect = true
	playerBar.optimizeInfo.canSelectByDist = true
	playerBar.isUsed = false
	playerBar.wasVisible = false
	
	if aFormSettings.showClassIconButton then
		move(playerBar.textWdg, 24, 0)
		resize(playerBar.textWdg, panelWidth-24)
	else
		move(playerBar.textWdg, 6, 0)
		resize(playerBar.textWdg, panelWidth-6)
	end
	
	playerBar.textWdg:SetEllipsis(true)
	
	hide(playerBar.manaBarWdg)
	resize(playerBar.shieldBarWdg, 0)
	resize(playerBar.distTextWdg, 35)
		
	hide(playerBar.checkIconWdg)
	move(playerBar.checkIconWdg, 2, 10)
	resize(playerBar.barBackgroundWdg, panelWidth, panelHeight)
	resize(playerBar.farBarBackgroundWdg, panelWidth-4, panelHeight-6)
	resize(playerBar.barWdg, panelWidth-4, panelHeight-6)
	resize(playerBar.clearBarWdg, panelWidth-4, panelHeight-6)
	resize(playerBar.buffPanelWdg, panelWidth, panelHeight)
	resize(playerBar.buffPanelNegativeWdg, panelWidth, panelHeight)

	move(playerBar.barWdg, 2, 3)
	local shieldBarColor = { r=1, g=1, b=1, a=0.8 }
	setBackgroundColor(playerBar.shieldBarWdg, shieldBarColor)
	
	setBackgroundColor(playerBar.barWdg, barColor) 
	
	hide(playerBar.distTextWdg)
	hide(playerBar.arrowIconWdg)
	
	align(playerBar.procTextWdg, WIDGET_ALIGN_CENTER, WIDGET_ALIGN_LOW)
	move(playerBar.arrowIconWdg, 6)
	align(playerBar.distTextWdg, WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW)
	move(playerBar.distTextWdg, 0)
	align(playerBar.textWdg, WIDGET_ALIGN_LOW)
		
	show(playerBar.woundsTextWdg)
	
	align(playerBar.farBarBackgroundWdg, WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH)
	move(playerBar.farBarBackgroundWdg, 2, 3)
	hide(playerBar.farBarBackgroundWdg)
	
	barColor = { r = 0; g = 0; b = 0; a = 1.0 }
	setBackgroundColor(playerBar.clearBarWdg, barColor) 
	hide(playerBar.clearBarWdg)
	
	hide(playerBar.wdg)
	
	
	local buffSlotCnt = math.floor((panelWidth)*0.85 / buffSize)
	
	playerBar.buffSlots = {}
	playerBar.usedBuffSlotCnt = 0
	
	playerBar.buffSlotsNeg = {}
	playerBar.usedBuffSlotNegCnt = 0
	setTemplateWidget(m_template)
	
	for i = 1, buffSlotCnt do
		CreateBuffSlot(playerBar.buffPanelWdg, buffSize, playerBar.buffSlots, i, WIDGET_ALIGN_LOW)
		CreateBuffSlot(playerBar.buffPanelNegativeWdg, buffSize, playerBar.buffSlotsNeg, i, WIDGET_ALIGN_HIGH)
	end
	
	local importantSize = panelHeight-16
	resize(playerBar.buffPanelImportantWdg, panelWidth, panelHeight)
	playerBar.importantBuff = CreateBuffSlot(playerBar.buffPanelImportantWdg, importantSize, nil, 0, WIDGET_ALIGN_CENTER)
	move(playerBar.importantBuff.buffWdg, 0, 0)
	align(playerBar.buffPanelImportantWdg, WIDGET_ALIGN_CENTER, WIDGET_ALIGN_CENTER)
	hide(playerBar.importantBuff.buffWdg)
	
	playerBar.listenerHP = PlayerHPChanged
	playerBar.listenerShield = PlayerShieldChanged
	playerBar.listenerMana = PlayerManaChanged
	playerBar.listenerWounds = PlayerWoundsChanged
	playerBar.listenerDistance = PlayerDistanceChanged
	playerBar.listenerAfk = PlayerAfkChanged
	playerBar.listenerDead = PlayerDeadChanged
	playerBar.listenerCanSelect = PlayerCanSelectChanged
	playerBar.listenerChangeBuff = PlayerAddBuffPositive
	playerBar.listenerChangeBuffNegative = PlayerAddBuffNegative
	playerBar.listenerRemoveBuff = PlayerRemoveBuffPositive
	playerBar.listenerRemoveBuffNegative = PlayerRemoveBuffNegative
	playerBar.listenerChangeImportantBuff = PlayerAddImportantBuff
	playerBar.listenerRemoveImportantBuff = PlayerRemoveImportantBuff
	return playerBar
end

function CreateBuffSlot(aParent, aBuffSize, anResArray, anIndex, anAlign)
	local buffSlot = {}
	buffSlot.buffWdg = createWidget(aParent, "mybuff"..anIndex, "BuffTemplate", anAlign, anAlign, aBuffSize, aBuffSize, 2+(anIndex-1)*aBuffSize, 3)
	buffSlot.buffIcon = getChild(buffSlot.buffWdg, "DotIcon")
	buffSlot.buffStackCnt = getChild(buffSlot.buffWdg, "DotStackText")
	align(buffSlot.buffStackCnt, WIDGET_ALIGN_HIGH, WIDGET_ALIGN_HIGH)
	resize(buffSlot.buffStackCnt, aBuffSize, GetTextSizeByBuffSize(aBuffSize))
	resize(buffSlot.buffIcon, aBuffSize, aBuffSize)
	show(buffSlot.buffIcon)
	if anResArray then
		table.insert(anResArray, buffSlot)	
	end
	return buffSlot
end

function HideReadyStateInGUI(aPlayerBar)
	if aPlayerBar.optimizeInfo.readyCheckShowed then
		aPlayerBar.optimizeInfo.readyCheckShowed = false
		aPlayerBar.checkIconWdg:Show(false)
	end
end

function ShowReadyStateInGUI(aPlayerBar, aPlayerReadyState)
	if not aPlayerReadyState then
		return
	end
	
	if not aPlayerBar.optimizeInfo.readyCheckShowed then
		aPlayerBar.checkIconWdg:Show(true)
	end
	aPlayerBar.optimizeInfo.readyCheckShowed = true 
	if aPlayerBar.optimizeInfo.readyCheckState ~= aPlayerReadyState then
		setBackgroundTexture(aPlayerBar.checkIconWdg, m_texCheckState[aPlayerReadyState])
		aPlayerBar.optimizeInfo.readyCheckState = aPlayerReadyState
	end
end

function CreateRaidPanel()
	setTemplateWidget(m_template)
	local raidPanel = common.AddonCreateChildForm("RaidPanel")
	local wtTopPanel = getChild(raidPanel, "TopPanel")
	DnD:Init(raidPanel, wtTopPanel, true)
	
	resize(wtTopPanel, 200, nil)
	hide(raidPanel)
	
	hide(getChild(wtTopPanel, "PartyButton"))
	return raidPanel
end

function CreateRaidPartyBtn(aRaidPanel)
	local raidPartyButtons = {}
	local wtTopPanel = getChild(aRaidPanel, "TopPanel")
	setTemplateWidget(wtTopPanel)
	for i = 1, 4 do
		raidPartyButtons[i] = {}
		raidPartyButtons[i].wdg = createWidget(wtTopPanel, nil, "PartyButton", nil, nil, nil, nil, (i-1)*20+37, nil, nil, nil)
		raidPartyButtons[i].active = true
		raidPartyButtons[i].showed = false
		setBackgroundTexture(raidPartyButtons[i].wdg, m_texParty[i])
		hide(raidPartyButtons[i].wdg) 
	end
	
	return raidPartyButtons
end

local m_locale = getLocale()
local m_modeBtn = nil
local m_lockBtn = nil
local m_targetModeName = nil

Global("ALL_TARGETS", 0)
Global("ENEMY_TARGETS", 1)
Global("FRIEND_TARGETS", 2)
Global("ENEMY_PLAYERS_TARGETS", 3)
Global("FRIEND_PLAYERS_TARGETS", 4)
Global("NEITRAL_PLAYERS_TARGETS", 5)
Global("ENEMY_MOBS_TARGETS", 6)
Global("FRIEND_MOBS_TARGETS", 7)
Global("NEITRAL_MOBS_TARGETS", 8)
Global("ENEMY_PETS_TARGETS", 9)
Global("FRIEND_PETS_TARGETS", 10)
Global("MY_SETTINGS_TARGETS", 11)
Global("TARGETS_DISABLE", 12)
Global("ALL_TARGETS_IN_COMBAT", 13)
Global("ENEMY_TARGETS_IN_COMBAT", 14)
Global("FRIEND_TARGETS_IN_COMBAT", 15)
Global("ENEMY_PLAYERS_TARGETS_IN_COMBAT", 16)
Global("FRIEND_PLAYERS_TARGETS_IN_COMBAT", 17)
Global("NEITRAL_PLAYERS_TARGETS_IN_COMBAT", 18)
Global("ENEMY_MOBS_TARGETS_IN_COMBAT", 19)
Global("FRIEND_MOBS_TARGETS_IN_COMBAT", 20)
Global("NEITRAL_MOBS_TARGETS_IN_COMBAT", 21)
Global("ENEMY_PETS_TARGETS_IN_COMBAT", 22)
Global("FRIEND_PETS_TARGETS_IN_COMBAT", 23)
Global("MY_SETTINGS_TARGETS_IN_COMBAT", 24)

local m_targetSwitchArr = {}
m_targetSwitchArr[ALL_TARGETS] = m_locale["ALL_TARGETS"]
m_targetSwitchArr[ENEMY_TARGETS] = m_locale["ENEMY_TARGETS"]
m_targetSwitchArr[FRIEND_TARGETS] = m_locale["FRIEND_TARGETS"]
m_targetSwitchArr[ENEMY_PLAYERS_TARGETS] = m_locale["ENEMY_PLAYERS_TARGETS"]
m_targetSwitchArr[FRIEND_PLAYERS_TARGETS] = m_locale["FRIEND_PLAYERS_TARGETS"]
m_targetSwitchArr[ENEMY_MOBS_TARGETS] = m_locale["ENEMY_MOBS_TARGETS"]
m_targetSwitchArr[FRIEND_MOBS_TARGETS] = m_locale["FRIEND_MOBS_TARGETS"]
m_targetSwitchArr[ENEMY_PETS_TARGETS] = m_locale["ENEMY_PETS_TARGETS"]
m_targetSwitchArr[FRIEND_PETS_TARGETS] = m_locale["FRIEND_PETS_TARGETS"]
m_targetSwitchArr[MY_SETTINGS_TARGETS] = m_locale["MY_SETTINGS_TARGETS"]
m_targetSwitchArr[TARGETS_DISABLE] = m_locale["TARGETS_DISABLE"]
m_targetSwitchArr[NEITRAL_PLAYERS_TARGETS] = m_locale["NEITRAL_PLAYERS_TARGETS"]
m_targetSwitchArr[NEITRAL_MOBS_TARGETS] = m_locale["NEITRAL_MOBS_TARGETS"]

function SwitchTargetsBtn(aNewTargetInd)
	m_targetModeName:SetVal("Name", m_targetSwitchArr[aNewTargetInd])
end

function TargetLockBtn(aTopPanelForm)
	local activeNum = m_lockBtn:GetVariant() == 1 and 0 or 1
	m_lockBtn:SetVariant(activeNum)
	m_modeBtn:SetVariant(activeNum)
	
	local wtTopPanel = getChild(aTopPanelForm, "TopTargeterPanel")
	DnD:Enable(wtTopPanel, activeNum==0)
end

function ApplyTargetSettingsToGUI(aTopPanelForm)
	local profile = GetCurrentProfile()
	local wtTopPanel = getChild(aTopPanelForm, "TopTargeterPanel")
	if profile.targeterFormSettings.twoColumnMode then
		align(wtTopPanel, WIDGET_ALIGN_HIGH)
	else
		align(wtTopPanel, WIDGET_ALIGN_LOW)
	end
end

function CreateTargeterPanel()
	setTemplateWidget(m_template)
	local targeterPanel = common.AddonCreateChildForm("TargetPanel")
	move(targeterPanel, 500, 380)
	local wtTopPanel = getChild(targeterPanel, "TopTargeterPanel")
	DnD:Init(targeterPanel, wtTopPanel, true)
	resize(wtTopPanel, 200, nil)
	
	

	local modePanel = getChild(wtTopPanel, "ModePanel")
	m_targetModeName = getChild(modePanel, "ModeNameTextView")
	m_lockBtn = getChild(wtTopPanel, "ButtonLocker")
	move(modePanel, 25, 3)
	resize(modePanel, 130, 20)
	m_modeBtn = getChild(modePanel, "GetModeBtn")
	
	TargetLockBtn(targeterPanel)
	hide(targeterPanel)
	return targeterPanel
end