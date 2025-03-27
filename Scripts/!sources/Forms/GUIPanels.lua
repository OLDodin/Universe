Global("g_classPriority", {
	["WARRIOR"]		= 10,
	["PALADIN"]		= 9,
	["MAGE"]		= 8,
	["DRUID"]		= 1,
	["PSIONIC"]		= 6,
	["STALKER"]		= 7,
	["PRIEST"]		= 2,
	["NECROMANCER"]	= 3,
	["ENGINEER"]    = 5,
	["BARD"]		= 4,
	["WARLOCK"] 	= 11, 
	["UNKNOWN"]		= 12
})

local cachedIsPlayer = unit.IsPlayer
local cachedGetClass = unit.GetClass
local cachedIsDead = object.IsDead
local cachedGetPlayerShardName = unit.GetPlayerShardName
local cachedGetQuality = unit.GetQuality
local cachedTableSClone = table.sclone

local m_manaColor = { r=0, g=0.3, b=1, a=1 }
local m_energyColor =	{ r=1, g=0.3, b=0, a=1 }
local m_emptyWStr = common.GetEmptyWString()
local m_leaderWStr = userMods.ToWString("(*)")
local m_afkWStr = userMods.ToWString("[AFK]")
local m_offWStr = userMods.ToWString("[Off]")
local m_deadWStr = userMods.ToWString("[Dead]")
local m_shardBeginWStr = userMods.ToWString("[")
local m_shardEndWStr = userMods.ToWString("] ")
local AFK_STATE = 0
local OFF_STATE = 2
local DEAD_STATE = 3
local NORMAL_STATE = 4
local m_raidLockBtn = nil

local function SetArrowAngle(anArrowIcon, anAngle)
	if anAngle and anArrowIcon then
		local curAngle = anArrowIcon:GetRotation()
		if curAngle ~= anAngle then
			anArrowIcon:PlayRotationEffect(curAngle, anAngle, 200, EA_MONOTONOUS_INCREASE)
		end
	end
end

local function ChangeSelectable(anInfo, aPlayerBar)
	local barColor = cachedTableSClone(aPlayerBar.optimizeInfo.barColor)
	if anInfo then
		barColor.a = 1
		hide(aPlayerBar.farBarBackgroundWdg)
		hide(aPlayerBar.farColoredBarWdg)
	else
		barColor.a = 0.8
		if aPlayerBar.formSettings.showFrameStripOnDistanceButton then
			show(aPlayerBar.farBarBackgroundWdg)
		end
		if aPlayerBar.formSettings.showGrayOnDistanceButton then
			show(aPlayerBar.farColoredBarWdg)
		end
		--targeter
		if aPlayerBar.formSettings.showFrameStripOnDistanceButton == nil then
			show(aPlayerBar.farBarBackgroundWdg)
			show(aPlayerBar.farColoredBarWdg)
		end
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
	local newPanelW = tonumber(aPlayerBar.formSettings.raidWidthText) * d-4
	newPanelW = math.max(newPanelW, 1)
	resize(aPlayerBar.barWdg, newPanelW)
	if aPlayerBar.formSettings.raidBuffs.colorDebuffButton then
		--чтобы лучше видно было хп убавим на 2 пикселя
		resize(aPlayerBar.clearBarWdg, math.max(newPanelW - 2, 1))
	end
	if aPlayerBar.formSettings.showProcentButton then
		aPlayerBar.procTextWdg:SetVal(g_tagTextValue, tostring(anInfo).."%")
	end
end

local function PlayerShieldChanged(anInfo, aPlayerBar)
	if aPlayerBar.optimizeInfo.currShield == anInfo then
		return
	end
	aPlayerBar.optimizeInfo.currShield = anInfo
	local shieldWidth = anInfo/100 * tonumber(aPlayerBar.formSettings.raidWidthText)
	if shieldWidth > 0 then
		resize(aPlayerBar.shieldLineWdg, shieldWidth)
		if aPlayerBar.formSettings.showProcentShieldButton then
			aPlayerBar.shieldTextWdg:SetVal(g_tagTextValue, tostring(anInfo).."%")
		end
		show(aPlayerBar.shieldBarWdg)
	else
		hide(aPlayerBar.shieldBarWdg)
		if aPlayerBar.formSettings.showProcentShieldButton then
			aPlayerBar.shieldTextWdg:SetVal(g_tagTextValue, "")
		end
	end
end

local function PlayerInvulnerableChanged(anInfo, aPlayerBar)
	if anInfo then
		show(aPlayerBar.invulnerableWdg)
	else
		hide(aPlayerBar.invulnerableWdg)
	end
	
end

local function PlayerManaChanged(anInfo, aPlayerBar)
	if aPlayerBar.optimizeInfo.currMana == anInfo then
		return
	end

	aPlayerBar.optimizeInfo.currMana = anInfo
	local manaBarWidth = anInfo/100 * tonumber(aPlayerBar.formSettings.raidWidthText) - 5
	if manaBarWidth > 0 then
		resize(aPlayerBar.manaBarWdg, manaBarWidth)	
		show(aPlayerBar.manaBarWdg)
	else
		hide(aPlayerBar.manaBarWdg)
	end
end

local function PlayerWoundsChanged(anInfo, aPlayerBar)
	if aPlayerBar.optimizeInfo.currWounds == anInfo then
		return
	end

	aPlayerBar.optimizeInfo.currWounds = anInfo
	aPlayerBar.woundsTextWdg:SetVal(g_tagTextValue, "-"..tostring(math.floor(anInfo)).."%")
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
			aPlayerBar.distTextWdg:SetVal(g_tagTextValue, tostring(anInfo.dist))
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
		barColor = aPlayerBar.formSettings.selectionColor
	else
		barColor = { r=1; g=1; b=1; a=1 }
	end
	aPlayerBar.highlight = anInfo
	aPlayerBar.highlightWdg:Show(anInfo)
	if not compareColor(aPlayerBar.optimizeInfo.barBackgroundColor, barColor) then
		aPlayerBar.optimizeInfo.barBackgroundColor = cachedTableSClone(barColor)
		setBackgroundColor(aPlayerBar.barBackgroundWdg, barColor)
	end
end


local function GetTextSizeByBuffSize(aSize)
	return math.floor(aSize/1.6)
end

local function GetTimeTextSizeByBuffSize(aSize)
	return math.floor(aSize/2.0)
end

local function PlayerRemoveBuffPositive(aBuffID, aPlayerBar)
	local wasRemoved, buffSlot = PlayerRemoveBuff(aBuffID, aPlayerBar, aPlayerBar.buffSlots)
	if wasRemoved then	
		TryShowBuffFromQueue(aPlayerBar, true)
	end
end

local function PlayerRemoveBuffNegative(aBuffID, aPlayerBar)
	local wasRemoved, buffSlot = PlayerRemoveBuff(aBuffID, aPlayerBar, aPlayerBar.buffSlotsNeg)
	if wasRemoved then	
		TryShowBuffFromQueue(aPlayerBar, false)
	end
	if aPlayerBar.formSettings.raidBuffs.colorDebuffButton and not HasCleanableBuff(aPlayerBar) then
		hide(aPlayerBar.clearBarWdg)
		if not compareColor(aPlayerBar.optimizeInfo.shieldContainerColor, g_shieldContainerNormalColor) then
			setBackgroundColor(aPlayerBar.shieldContainerWdg, g_shieldContainerNormalColor)
			aPlayerBar.optimizeInfo.shieldContainerColor = g_shieldContainerNormalColor
		end
	end
end

local function PlayerAddBuffNegative(aBuffInfo, aPlayerBar, anInfoObj, aCleanableBuff)
	PlayerAddBuff(aBuffInfo, aPlayerBar, aPlayerBar.buffSlotsNeg, anInfoObj, aCleanableBuff)

	if aPlayerBar.formSettings.raidBuffs.colorDebuffButton and HasCleanableBuff(aPlayerBar) then
		show(aPlayerBar.clearBarWdg)
		if not compareColor(aPlayerBar.optimizeInfo.shieldContainerColor, g_shieldContainerCleanableColor) then
			setBackgroundColor(aPlayerBar.shieldContainerWdg, g_shieldContainerCleanableColor)
			aPlayerBar.optimizeInfo.shieldContainerColor = g_shieldContainerCleanableColor
		end
	end
end

local function PlayerAddBuffPositive(aBuffInfo, aPlayerBar, anInfoObj, aCleanableBuff)
	PlayerAddBuff(aBuffInfo, aPlayerBar, aPlayerBar.buffSlots, anInfoObj, aCleanableBuff)
end

local function PlayerAddImportantBuff(aBuffInfo, aPlayerBar)
	if aBuffInfo.texture then
		local buffSlot = aPlayerBar.importantBuff
		show(buffSlot.buffWdg)
		buffSlot.buffID = aBuffInfo.id
		buffSlot.buffIcon:SetBackgroundTexture(aBuffInfo.texture)
		
		if aBuffInfo.stackCount <= 1 then 
			hide(buffSlot.buffStackCnt)
		else
			show(buffSlot.buffStackCnt)
			buffSlot.buffStackCnt:SetVal(g_tagTextValue, tostring(aBuffInfo.stackCount))
		end
	end
end

local function PlayerChangeImportantBuff(aBuffID, aBuffDynamicInfo, aPlayerBar)
	if aPlayerBar.importantBuff.buffID == aBuffID then
		local buffSlot = aPlayerBar.importantBuff
		if aBuffDynamicInfo.stackCount <= 1 then 
			hide(buffSlot.buffStackCnt)
		else
			show(buffSlot.buffStackCnt)
			buffSlot.buffStackCnt:SetVal(g_tagTextValue, tostring(aBuffDynamicInfo.stackCount))
		end
	end
end

local function PlayerRemoveImportantBuff(aBuffID, aPlayerBar)
	if aPlayerBar.importantBuff.buffID == aBuffID then
		hide(aPlayerBar.importantBuff.buffWdg)
		aPlayerBar.importantBuff.buffID = nil
	end
end

local function PlayerChangeSomeBuff(aBuffID, aBuffDynamicInfo, aPlayerBar)
	PlayerChangeImportantBuff(aBuffID, aBuffDynamicInfo, aPlayerBar)
	-- в  guipanel важные баффы отдельно и не всегда попадает в список отображаемых обыным способом
	if aPlayerBar.buffsQueue[aBuffID] then
		PlayerChangeBuff(aBuffID, aBuffDynamicInfo, aPlayerBar, aPlayerBar.buffSlots)
		PlayerChangeBuff(aBuffID, aBuffDynamicInfo, aPlayerBar, aPlayerBar.buffSlotsNeg)
	end
end

local function UpdateTick(aPlayerBar)
	if aPlayerBar.isUsed and aPlayerBar.formSettings.showBuffTimeButton then
		UpdateTimeForBuffArray(aPlayerBar.buffSlots, false)
		UpdateTimeForBuffArray(aPlayerBar.buffSlotsNeg, false)
	end
end

function HidePlayerBar(aPlayerBar)
	DnD.HideWdg(aPlayerBar.wdg)
	hide(aPlayerBar.rollOverHighlightWdg)
				
	for _, buffSlot in ipairs(aPlayerBar.buffSlots) do
		stopLoopBlink(buffSlot.buffHighlight)
	end
	for _, buffSlot in ipairs(aPlayerBar.buffSlotsNeg) do
		stopLoopBlink(buffSlot.buffHighlight)
	end
end

function CloneBaseInfoPlayerPanel(aPlayerBar, aNewPlayerBar)
	aNewPlayerBar.farBarBackgroundWdg:Show(aPlayerBar.farBarBackgroundWdg:IsVisible())
	aNewPlayerBar.farColoredBarWdg:Show(aPlayerBar.farColoredBarWdg:IsVisible())
	aNewPlayerBar.textWdg:SetValuedText(aPlayerBar.textWdg:GetValuedText())
	aNewPlayerBar.barWdg:SetBackgroundColor(aPlayerBar.barWdg:GetBackgroundColor())
end

function SetBaseInfoPlayerPanel(aPlayerBar, aPlayerInfo, anIsLeader, aFormSettings, aRelationType)
	aPlayerBar.isUsed = true
	aPlayerBar.playerID = aPlayerInfo.id
	aPlayerBar.uniqueID = aPlayerInfo.uniqueId
	aPlayerBar.formSettings = aFormSettings
	aPlayerBar.optimizeInfo.canSelect = true
	aPlayerBar.optimizeInfo.canSelectByDist = true
	aPlayerBar.optimizeInfo.currDist = -1
	aPlayerBar.panelColorType = aRelationType
	aPlayerBar.optimizeInfo.shieldContainerColor = cachedTableSClone(g_shieldContainerNormalColor)
	
	local isUnitExist = isExist(aPlayerInfo.id)
	aPlayerBar.isPlayerExist = isUnitExist
	
	local isPlayer = isUnitExist and cachedIsPlayer(aPlayerInfo.id) or false
	
	aPlayerBar.buffsQueue = {}
	ClearAllBuffSlot(aPlayerBar.buffSlots)
	ClearAllBuffSlot(aPlayerBar.buffSlotsNeg)
	
	hide(aPlayerBar.importantBuff.buffWdg)
	aPlayerBar.importantBuff.buffID = nil
	
	hide(aPlayerBar.clearBarWdg)
	hide(aPlayerBar.invulnerableWdg)
	
	setBackgroundColor(aPlayerBar.shieldContainerWdg, aPlayerBar.optimizeInfo.shieldContainerColor)
	
	local barColor = cachedTableSClone(aFormSettings.friendColor)
	if isUnitExist and (aFormSettings.showManaButton or aFormSettings.classColorModeButton) then
		local playerClass = cachedGetClass(aPlayerInfo.id)
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
				local color = g_classColors[playerClass.className]
				if not color then
					color = g_classColors["UNKNOWN"]
				end
				barColor = cachedTableSClone(color)
			end
		end
	end
	
	if isUnitExist then
		if not aFormSettings.classColorModeButton or (aFormSettings.classColorModeButton and not cachedIsPlayer(aPlayerInfo.id)) then
			if aPlayerBar.panelColorType == FRIEND_PANEL then
				barColor = cachedTableSClone(aFormSettings.friendColor)
			elseif aPlayerBar.panelColorType == NEITRAL_PANEL then
				barColor = cachedTableSClone(aFormSettings.neitralColor)
			elseif aPlayerBar.panelColorType == ENEMY_PANEL then
				barColor = cachedTableSClone(aFormSettings.enemyColor)
			end
		end
	end

	if aPlayerInfo.state == RAID_MEMBER_STATE_OFFLINE or aPlayerInfo.state == RAID_MEMBER_STATE_FAR 
	or aPlayerInfo.state == GROUP_MEMBER_STATE_OFFLINE or aPlayerInfo.state == GROUP_MEMBER_STATE_FAR  
	or (aPlayerInfo.state == GROUP_MEMBER_STATE_MERC and aPlayerInfo.id==nil) then
		barColor.a = 0.8
		show(aPlayerBar.farBarBackgroundWdg)
		show(aPlayerBar.farColoredBarWdg)
	else
		hide(aPlayerBar.farBarBackgroundWdg)
		hide(aPlayerBar.farColoredBarWdg)
	end
	
	local leaderWStr = anIsLeader and m_leaderWStr or m_emptyWStr
	local userState = (aPlayerInfo.state == GROUP_MEMBER_STATE_OFFLINE or aPlayerInfo.state == RAID_MEMBER_STATE_OFFLINE) and OFF_STATE 
	or (aPlayerInfo.state == GROUP_MEMBER_STATE_AFK or aPlayerInfo.state == RAID_MEMBER_STATE_AFK) and AFK_STATE
	or (isUnitExist and cachedIsDead(aPlayerInfo.id)) and DEAD_STATE
	or NORMAL_STATE
	
	local offAfkWStr = userState == OFF_STATE and m_offWStr 
	or userState == AFK_STATE and m_afkWStr
	or userState == DEAD_STATE and m_deadWStr
	or m_emptyWStr
	
	if userState == OFF_STATE or not isUnitExist then
		PlayerHPChanged(100, aPlayerBar)
	end
	
	hide(aPlayerBar.shieldBarWdg)
	if aPlayerBar.formSettings.showProcentShieldButton then
		aPlayerBar.shieldTextWdg:SetVal(g_tagTextValue, "")
	end

	if aFormSettings.showServerNameButton then
		local shardName = m_emptyWStr
		if --[[cartographer.IsOnCommon() and ]]aPlayerInfo.id and isUnitExist and cachedIsPlayer(aPlayerInfo.id) then
			shardName = cachedGetPlayerShardName(aPlayerInfo.id)
			if shardName then 
				shardName = shardName:ToAbbr()
			end
		end
		if not shardName then
			shardName = m_emptyWStr
		end
		
		if aPlayerBar.optimizeInfo.shardName ~= shardName then
			aPlayerBar.optimizeInfo.shardName = shardName
			if not shardName:IsEmpty() then
				shardName = m_shardBeginWStr..shardName..m_shardEndWStr
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

	if aPlayerBar.optimizeInfo.name ~= aPlayerInfo.name then
		aPlayerBar.optimizeInfo.name = aPlayerInfo.name
		aPlayerBar.textWdg:SetVal("Name", aPlayerInfo.name)
	end

	if aFormSettings.showClassIconButton then
		local mobQuality = nil
		if isPlayer then 
			if not aPlayerInfo.className then
				local playerClass = cachedGetClass(aPlayerInfo.id)
				if playerClass and playerClass.className then 	
					aPlayerInfo.className = playerClass.className
				end
			end
		elseif isUnitExist then
			mobQuality = cachedGetQuality(aPlayerInfo.id)
		end
		local textureIndexForIcon = aPlayerInfo.className or mobQuality or "UNKNOWN"
		
		if aPlayerBar.optimizeInfo.textureIndexForIcon ~= textureIndexForIcon then
			aPlayerBar.optimizeInfo.textureIndexForIcon = textureIndexForIcon
			setBackgroundTexture(aPlayerBar.classIconWdg, g_texIcons[textureIndexForIcon])
			show(aPlayerBar.classIconWdg)
		end
	end

	if not compareColor(aPlayerBar.optimizeInfo.barColor, barColor) then
		aPlayerBar.optimizeInfo.barColor = cachedTableSClone(barColor)
		setBackgroundColor(aPlayerBar.barWdg, barColor)
	end
	
	HideReadyStateInGUI(aPlayerBar)
	
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

function CreatePlayerPanel(aParentPanel, aX, aY, aRaidMode, aFormSettings, aNum)
	setTemplateWidget("bar")
	local barColor = aFormSettings.friendColor
	
	local panelWidth = tonumber(aFormSettings.raidWidthText)
	local panelHeight = tonumber(aFormSettings.raidHeightText)
	local mod1 = aFormSettings.gorisontalModeButton and aY or aX
	local mod2 = aFormSettings.gorisontalModeButton and aX or aY
	local posX = mod1*panelWidth
	local posY = mod2*panelHeight+30

	local playerBar = {}
	if aRaidMode then
		local raidMoveBar = createWidget(aParentPanel, "raidPanelAddBar", "AddBar", nil, nil, panelWidth, panelHeight, posX, posY)
		DnD.Init(raidMoveBar, raidMoveBar, false)
		playerBar.raidMoveWdg = raidMoveBar
		playerBar.raidMoveHighlightWdg = getChild(raidMoveBar, "Highlight")
	end
	playerBar.wdg = createWidget(aParentPanel, "PlayerBar"..tostring(aNum)..tostring(aRaidMode), "PlayerBar", nil, nil, panelWidth, panelHeight, posX, posY)
	playerBar.barWdg = getChild(playerBar.wdg, "HealthBar")
	playerBar.manaBarWdg = getChild(playerBar.wdg, "ManaBar")
	playerBar.shieldBarWdg = getChild(playerBar.wdg, "ShieldBar")
	playerBar.shieldContainerWdg = getChild(playerBar.shieldBarWdg, "ShieldContainer")
	playerBar.shieldLineWdg = getChild(playerBar.shieldContainerWdg, "ShieldLine")
	playerBar.shieldTextWdg = getChild(playerBar.shieldBarWdg, "ShieldText")
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
	playerBar.farColoredBarWdg = getChild(playerBar.wdg, "FarColored")
	playerBar.rollOverHighlightWdg = getChild(playerBar.wdg, "RolloverHighlight")
	playerBar.highlightWdg = getChild(playerBar.wdg, "Highlight")
	playerBar.invulnerableWdg = getChild(playerBar.wdg, "Invulnerable")
	
	playerBar.optimizeInfo = {}
	playerBar.optimizeInfo.name = m_emptyWStr
	playerBar.optimizeInfo.shardName = m_emptyWStr
	playerBar.optimizeInfo.barColor = cachedTableSClone(barColor)
	playerBar.optimizeInfo.shieldContainerColor = cachedTableSClone(g_shieldContainerNormalColor)
	playerBar.optimizeInfo.posX = posX
	playerBar.optimizeInfo.posY = posY
	playerBar.optimizeInfo.canSelect = true
	playerBar.optimizeInfo.canSelectByDist = true
	playerBar.isUsed = false
	playerBar.wasVisible = false
	playerBar.panelColorType = FRIEND_PANEL
	playerBar.buffSize = tonumber(aFormSettings.buffSize)
	
	local shieldTextFontSize = 10
	if panelHeight > 59 then
		shieldTextFontSize = 12
	end
	
	setTextViewText(playerBar.shieldTextWdg, g_tagTextValue, nil, nil, nil, shieldTextFontSize)
	
	if aFormSettings.showClassIconButton then
		updatePlacementPlain(playerBar.textWdg, WIDGET_ALIGN_LOW, nil, 24, 0, panelWidth-24, nil)
	else
		updatePlacementPlain(playerBar.textWdg, WIDGET_ALIGN_LOW, nil, 6, 0, panelWidth-6, nil)
	end

	show(playerBar.woundsTextWdg)
	resize(playerBar.barWdg, panelWidth-4, panelHeight-4)
	setBackgroundColor(playerBar.barWdg, barColor)
	setBackgroundColor(playerBar.highlightWdg, aFormSettings.selectionColor) 
	
	setBackgroundColor(playerBar.shieldContainerWdg, playerBar.optimizeInfo.shieldContainerColor)
	
	setBackgroundColor(playerBar.invulnerableWdg, aFormSettings.invulnerableColor)
	
	local shieldBarHeight = 10
	if panelHeight > 69 then
		shieldBarHeight = 12
	elseif panelHeight > 59 then
		shieldBarHeight = 11
	end
	resize(playerBar.shieldBarWdg, nil, shieldBarHeight)
	
	setBackgroundColor(playerBar.farColoredBarWdg, aFormSettings.farColor or g_farColor) 
	setBackgroundColor(playerBar.clearBarWdg, aFormSettings.clearColor or g_needClearColor)
	resize(playerBar.clearBarWdg, panelWidth-6, panelHeight-4)
		
	local buffSlotCnt = math.floor((panelWidth)*0.85 / playerBar.buffSize)
	
	playerBar.buffsQueue = {}
	playerBar.buffSlots = {}
	playerBar.buffSlotsNeg = {}
	
	local stackBuffSize = GetTextSizeByBuffSize(playerBar.buffSize)
	local timeBuffSize = GetTimeTextSizeByBuffSize(playerBar.buffSize)
	setTemplateWidget("common")
	for i = 1, buffSlotCnt do
		table.insert(playerBar.buffSlots, CreateBuffSlot(playerBar.buffPanelWdg, "b"..tostring(i), WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 2+(i-1)*playerBar.buffSize, 4, playerBar.buffSize, stackBuffSize, timeBuffSize, aFormSettings.buffsOpacityText, aFormSettings.showBuffTimeButton, true))
		table.insert(playerBar.buffSlotsNeg, CreateBuffSlot(playerBar.buffPanelNegativeWdg, "bn"..tostring(i), WIDGET_ALIGN_HIGH, WIDGET_ALIGN_HIGH, 2+(i-1)*playerBar.buffSize, 4, playerBar.buffSize, stackBuffSize, timeBuffSize, aFormSettings.buffsOpacityText, aFormSettings.showBuffTimeButton, true))
	end
	
	local importantSize = panelHeight-16
	playerBar.importantBuff = CreateBuffSlot(playerBar.buffPanelImportantWdg, "bi", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_CENTER, 0, 0, importantSize, GetTextSizeByBuffSize(importantSize)-1, timeBuffSize, 1.0, false, true)
	updatePlacementPlain(playerBar.importantBuff.buffStackCnt, WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 1, 1)
	
	playerBar.listenerHP = PlayerHPChanged
	playerBar.listenerShield = PlayerShieldChanged
	playerBar.listenerInvulnerable = PlayerInvulnerableChanged
	playerBar.listenerMana = PlayerManaChanged
	playerBar.listenerWounds = PlayerWoundsChanged
	playerBar.listenerDistance = PlayerDistanceChanged
	playerBar.listenerAfk = PlayerAfkChanged
	playerBar.listenerDead = PlayerDeadChanged
	playerBar.listenerCanSelect = PlayerCanSelectChanged
	playerBar.listenerAddBuff = PlayerAddBuffPositive
	playerBar.listenerAddBuffNegative = PlayerAddBuffNegative
	playerBar.listenerChangeBuff = PlayerChangeSomeBuff
	playerBar.listenerRemoveBuff = PlayerRemoveBuffPositive
	playerBar.listenerRemoveBuffNegative = PlayerRemoveBuffNegative
	playerBar.listenerChangeImportantBuff = PlayerAddImportantBuff
	playerBar.listenerRemoveImportantBuff = PlayerRemoveImportantBuff
	playerBar.listenerUpdateTick = UpdateTick
	return playerBar
end

function DestroyPlayerPanel(aPlayerBar)
	if aPlayerBar.raidMoveWdg then
		DnD.Remove(aPlayerBar.raidMoveWdg)
		DnD.HideWdg(aPlayerBar.raidMoveWdg)
		destroy(aPlayerBar.raidMoveWdg)
	end
	
	DnD.Remove(aPlayerBar.wdg)
	HidePlayerBar(aPlayerBar)
	destroy(aPlayerBar.wdg)
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
		setBackgroundTexture(aPlayerBar.checkIconWdg, g_texCheckState[aPlayerReadyState])
		aPlayerBar.optimizeInfo.readyCheckState = aPlayerReadyState
	end
end

function RaidLockBtn(aTopPanelForm)
	local activeNum = m_raidLockBtn:GetVariant() == 1 and 0 or 1
	m_raidLockBtn:SetVariant(activeNum)
	
	local wtTopPanel = getChild(aTopPanelForm, "TopPanel")
	DnD.Enable(wtTopPanel, activeNum==0)
end

function ApplyRaidSettingsToGUI(aTopPanelForm)
	local activeNum = m_raidLockBtn:GetVariant() == 1 and 1 or 0
	local wtTopPanel = getChild(aTopPanelForm, "TopPanel")
	DnD.Enable(wtTopPanel, activeNum==0)
end

function InitRaidPanel()
	local raidPanel = getChild(mainForm, "RaidPanel")
	local wtTopPanel = getChild(raidPanel, "TopPanel")
	DnD.Init(raidPanel, wtTopPanel, true)
	
	resize(wtTopPanel, 200, nil)
	DnD.HideWdg(raidPanel)
	
	m_raidLockBtn = getChild(wtTopPanel, "ButtonLocker")
	RaidLockBtn(raidPanel)
	
	hide(getChild(wtTopPanel, "PartyButton"))
	
	return raidPanel
end

function CreateRaidPartyBtn(aRaidPanel)
	local raidPartyButtons = {}
	local wtTopPanel = getChild(aRaidPanel, "TopPanel")
	setTemplateWidget("bar")
	for i = 1, 4 do
		local raidPartyButton = {}
		raidPartyButton.wdg = createWidget(wtTopPanel, "PartyButton"..tostring(i), "PartyButton", nil, nil, nil, nil, (i-1)*20+37, nil, nil, nil)
		raidPartyButton.active = true
		raidPartyButton.showed = false
		setBackgroundTexture(raidPartyButton.wdg, g_texParty[i])
		hide(raidPartyButton.wdg) 
		raidPartyButtons[i] = raidPartyButton
	end
	
	return raidPartyButtons
end

local m_locale = getLocale()
local m_modeBtn = nil
local m_targetLockBtn = nil
local m_targetModeName = nil
local m_modeSelectPanel = nil
local m_currTargetInd = nil

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
Global("NOT_FRIENDS_TARGETS", 11)
Global("NOT_FRIENDS_PLAYERS_TARGETS", 12)
Global("ENEMY_WITHOUT_PETS_TARGETS", 13)
Global("MY_SETTINGS_TARGETS", 14)
Global("TARGETS_DISABLE", 15)




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
m_targetSwitchArr[NOT_FRIENDS_TARGETS] = m_locale["NOT_FRIENDS_TARGETS"]
m_targetSwitchArr[NOT_FRIENDS_PLAYERS_TARGETS] = m_locale["NOT_FRIENDS_PLAYERS_TARGETS"]
m_targetSwitchArr[ENEMY_WITHOUT_PETS_TARGETS] = m_locale["ENEMY_WITHOUT_PETS_TARGETS"]

function HideTargetDropDownSelectPanel()
	HideDropDownSelectPanel(m_modeSelectPanel)
end

function SwitchTargetsBtn(aNewTargetInd)
	setText(m_targetModeName, m_targetSwitchArr[aNewTargetInd], "Neutral", "left", 11)
	m_currTargetInd = aNewTargetInd
end

local function ApplyTargetSettingsToGUIInternal(aTopPanelForm, anActiveNum)
	m_targetLockBtn:SetVariant(anActiveNum)
	if m_currTargetInd == TARGETS_DISABLE then
		m_modeBtn:SetVariant(1)
	else
		m_modeBtn:SetVariant(anActiveNum)
	end
	
	local wtTopPanel = getChild(aTopPanelForm, "TopTargeterPanel")
	DnD.Enable(wtTopPanel, anActiveNum==0)
	HideTargetDropDownSelectPanel()
end

function TargetLockBtn(aTopPanelForm)
	local activeNum = m_targetLockBtn:GetVariant() == 1 and 0 or 1
	ApplyTargetSettingsToGUIInternal(aTopPanelForm, activeNum)
end

function ApplyTargetSettingsToGUI(aTopPanelForm)
	local activeNum = m_targetLockBtn:GetVariant() == 1 and 1 or 0
	ApplyTargetSettingsToGUIInternal(aTopPanelForm, activeNum)
end

function InitTargeterPanel()
	local targeterPanel = getChild(mainForm, "TargetPanel")
	move(targeterPanel, 500, 380)
	local wtTopPanel = getChild(targeterPanel, "TopTargeterPanel")
	DnD.Init(targeterPanel, wtTopPanel, true, true, {0,-50,-50,0})
	resize(wtTopPanel, 200, nil)
	
	setTemplateWidget("common")
	local modePanel = createWidget(targeterPanel, "targeterDropDown", "DropDownPanel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 170, 20, 20, 240)
	m_targetModeName = getChild(getChild(modePanel, "DropDownHeaderPanel"), "ModeNameTextView")
	m_targetLockBtn = getChild(wtTopPanel, "ButtonLocker")
	move(modePanel, 25, 3)
	
	m_modeBtn = getChild(getChild(modePanel, "DropDownHeaderPanel"), "GetModeBtn")
	m_modeBtn:SetName("targeterModeBtn")
	
	local textArr = {}
	for i = ALL_TARGETS, MY_SETTINGS_TARGETS do
		table.insert(textArr, m_targetSwitchArr[i])
	end
	GenerateBtnForDropDown(modePanel, textArr)
	
	m_modeSelectPanel = getChild(modePanel, "DropDownSelectPanel")	

	local headerPanel = getChild(modePanel, "DropDownHeaderPanel")
	align(headerPanel, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW)
	resize(headerPanel, 130, 20)
	
	TargetLockBtn(targeterPanel)
	DnD.HideWdg(targeterPanel)
	
	return targeterPanel
end

function CreateTargeterInfoForm()
	setTemplateWidget("common")
	local form=createWidget(mainForm, "targeterInfoForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 70, 0, 0)
	priority(form, 508)
	hide(form)

	createWidget(form, "closeShortInfo", "Cross",  WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 15, 15, 6, 6)
	local hintWdg = createWidget(form, "targeterInfoTxt", "TextView",  WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 50, 15, 10)
	hintWdg:SetMultiline(true)
	setLocaleText(hintWdg)
	
	return form
end
