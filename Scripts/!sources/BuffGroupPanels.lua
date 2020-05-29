local m_groupBuffPanels = {}
local m_lastTargetID = nil
local m_minGroupPanelWidth = 220

local function GetTextSizeByBuffSize(aSize)
	return math.floor(aSize/2.5)
end

local function FindBufSlot(aGroupBuffBar, aBuffID)
	for i, buffSlot in pairs(aGroupBuffBar.buffList) do
		if buffSlot.buffID == aBuffID then
			return buffSlot, i
		end
	end
end

local function PlayerAddBuff(aBuffInfo, aGroupBuffBar, anInfoObj)
	local posInPlateIndex = anInfoObj and anInfoObj.ind or nil
--LogInfo("PlayerAddBuff = ", aBuffInfo.name, " ind ", posInPlateIndex)
	
	
	if not aBuffInfo.texture then
		return
	end
	local buffSlot = FindBufSlot(aGroupBuffBar, aBuffInfo.id)
	if aGroupBuffBar.fixedInsidePanel then
		if not posInPlateIndex then
			posInPlateIndex = 1
		end
		buffSlot = aGroupBuffBar.buffList[posInPlateIndex]
		if buffSlot then
			if not buffSlot.buffWdg:IsVisible() then
				buffSlot.buffWdg:Show(true)
				buffSlot.info.buffIcon:SetBackgroundTexture(aBuffInfo.texture)
			end
		end
	else
		if not buffSlot then
			local newCnt = aGroupBuffBar.usedBuffSlotCnt + 1
			buffSlot = aGroupBuffBar.buffList[newCnt]	
			--LogInfo("PlayerAddBuff 1 = ", newCnt)
			if buffSlot then
			--LogInfo("PlayerAddBuff 2")
				aGroupBuffBar.usedBuffSlotCnt = newCnt
				
				buffSlot.buffWdg:Show(true)
				buffSlot.info.buffIcon:SetBackgroundTexture(aBuffInfo.texture)
				
				resize(aGroupBuffBar.panelWdg, math.max(buffSlot.info.buffSize*math.min(aGroupBuffBar.panelWidthBuffCnt, aGroupBuffBar.usedBuffSlotCnt), m_minGroupPanelWidth), buffSlot.info.buffSize*math.min(aGroupBuffBar.panelHeightBuffCnt, math.ceil(aGroupBuffBar.usedBuffSlotCnt/aGroupBuffBar.panelWidthBuffCnt))+30)
			end
		end
	end
	if not buffSlot then
		return
	end
	
	buffSlot.buffID = aBuffInfo.id
	buffSlot.buffFinishedTime_h = aBuffInfo.remainingMs + g_cachedTimestamp
	setFade(buffSlot.info.buffIcon, 1.0)
	
	if aBuffInfo.stackCount <= 1 then 
		hide(buffSlot.info.buffStackCntWdg)
	else
		show(buffSlot.info.buffStackCntWdg)
		setText(buffSlot.info.buffStackCntWdg, aBuffInfo.stackCount, nil, "right", GetTextSizeByBuffSize(buffSlot.info.buffSize))
	end
	
	if aBuffInfo.remainingMs > 0 then
		local buffTimeStr = getTimeString(aBuffInfo.remainingMs)
		setText(buffSlot.info.buffTimerWdg, buffTimeStr, "ColorWhite", "center", math.floor(buffSlot.info.buffSize/2.5), 1, 1)
		buffSlot.info.buffTimeStr = buffTimeStr
		show(buffSlot.info.buffTimerWdg)
	else
		hide(buffSlot.info.buffTimerWdg)
	end
	
	if anInfoObj and anInfoObj.useHighlightBuff then 
		show(buffSlot.info.buffHighlight)
		setBackgroundColor(buffSlot.info.buffHighlight, anInfoObj.highlightColor)
		if anInfoObj.blinkHighlight then
			startLoopBlink(buffSlot.info.buffHighlight, 0.5)
		end
	else
		hide(buffSlot.info.buffHighlight)
		stopLoopBlink(buffSlot.info.buffHighlight)
	end
	
	return buffSlot
end

local function PlayerRemoveBuff(aBuffID, aGroupBuffBar)
	local buffSlot, removeIndex  = FindBufSlot(aGroupBuffBar, aBuffID)
	if buffSlot then
		if aGroupBuffBar.fixedInsidePanel then	
			hide(buffSlot.buffWdg)
			stopLoopBlink(buffSlot.info.buffHighlight)
		else
			hide(buffSlot.buffWdg)
			stopLoopBlink(buffSlot.info.buffHighlight)
			if removeIndex ~= GetTableSize(aGroupBuffBar.buffList) then
				for i = removeIndex, aGroupBuffBar.usedBuffSlotCnt do
					aGroupBuffBar.buffList[i] = aGroupBuffBar.buffList[i+1]
				end
				aGroupBuffBar.buffList[aGroupBuffBar.usedBuffSlotCnt] = buffSlot
				for i = removeIndex, aGroupBuffBar.usedBuffSlotCnt do
					local x = ((i-1)%aGroupBuffBar.panelWidthBuffCnt)*buffSlot.info.buffSize
					local y = math.floor((i-1)/aGroupBuffBar.panelWidthBuffCnt)*buffSlot.info.buffSize
					move(aGroupBuffBar.buffList[i].buffWdg, x, y+30)
				end
			end
			aGroupBuffBar.usedBuffSlotCnt = aGroupBuffBar.usedBuffSlotCnt - 1
			if aGroupBuffBar.usedBuffSlotCnt < 0 then
				aGroupBuffBar.usedBuffSlotCnt = 0
			end
			
			resize(aGroupBuffBar.panelWdg, math.max(buffSlot.info.buffSize*math.min(aGroupBuffBar.panelWidthBuffCnt, aGroupBuffBar.usedBuffSlotCnt), m_minGroupPanelWidth), buffSlot.info.buffSize*math.min(aGroupBuffBar.panelHeightBuffCnt, math.ceil(aGroupBuffBar.usedBuffSlotCnt/aGroupBuffBar.panelWidthBuffCnt))+30)
		end
	end
end

local function UpdateTick(aGroupBuffBar)
	for _, buffSlot in pairs(aGroupBuffBar.buffList) do
		if buffSlot.info.buffTimerWdg:IsVisible() then
			local remainingMs = buffSlot.buffFinishedTime_h - g_cachedTimestamp
			if remainingMs > 0 then
				local buffTimeStr = getTimeString(remainingMs)
				if buffSlot.info.buffTimeStr ~= buffTimeStr then 
					setText(buffSlot.info.buffTimerWdg, buffTimeStr, "ColorWhite", "center", math.floor(buffSlot.info.buffSize/2.5), 1, 1)
					buffSlot.info.buffTimeStr = buffTimeStr
				end
			else
				buffSlot.info.buffTimerWdg:Show(false)
			end
		end
	end
end

local function SpellChanged(aSpellInfo, aGroupBuffBar, anInfoObj)
	local spellCooldown = spellLib.GetCooldown(aSpellInfo.spellID)
	if spellCooldown then
		aSpellInfo.remainingMs = spellCooldown.remainingMs
	else
		aSpellInfo.remainingMs = 0
	end
	aSpellInfo.stackCount = 0
	aSpellInfo.texture = getSpellTextureFromCache(aSpellInfo.spellID)
	aSpellInfo.id = aSpellInfo.objectId
	
	local buffSlot = PlayerAddBuff(aSpellInfo, aGroupBuffBar, anInfoObj)
	if buffSlot and aSpellInfo.remainingMs > 0 then
		setFade(buffSlot.info.buffIcon, 0.4)
	end
end

function DestroyGroupBuffPanels()
	for _, groupBuffPanel in pairs(m_groupBuffPanels) do
		if groupBuffPanel.panelWdg then
			if groupBuffPanel.panelWdg.IsValid and groupBuffPanel.panelWdg:IsValid() then DnD.Remove(groupBuffPanel.panelWdg) end
			hide(groupBuffPanel.panelWdg)
			destroy(groupBuffPanel.panelWdg)
		end
	end
	m_groupBuffPanels = {}
	
	m_lastTargetID = nil
end

function CreateGroupsParentForm()
	return createWidget(nil, "BuffForm", "Buff")
end

function CreateGroupBuffPanel(aForm, aSettings, anIsAboveHead, aPosInPlateIndex)
	local groupBuffPanel = {}
	groupBuffPanel.listenerChangeBuffNegative = PlayerAddBuff
	groupBuffPanel.listenerRemoveBuffNegative = PlayerRemoveBuff
	groupBuffPanel.listenerChangeImportantBuff = PlayerAddBuff
	groupBuffPanel.listenerUpdateTick = UpdateTick
	groupBuffPanel.listenerSpellChanged = SpellChanged
	groupBuffPanel.buffList = {}
	groupBuffPanel.fixedInsidePanel = aSettings.fixedInsidePanel
	groupBuffPanel.usedBuffSlotCnt = 0
	groupBuffPanel.panelWidthBuffCnt = aSettings.w
	groupBuffPanel.panelHeightBuffCnt = aSettings.h
	groupBuffPanel.index = aPosInPlateIndex
	groupBuffPanel.abovehead = anIsAboveHead
	
	local h = round(aSettings.h)
	local w = round(aSettings.w)
	local size = round(aSettings.size)
	if h and w and size and aSettings.buffs and (anIsAboveHead or not aSettings.aboveHeadButton) then
		local num = math.min(w*h, table.getn(aSettings.buffs))
		if num == 0 then num = w*h end
		setTemplateWidget(aForm)
		if anIsAboveHead then
			groupBuffPanel.panelWdg = createWidget(mainForm, "BuffGroup"..tostring(aPosInPlateIndex), "BuffGroup")			
		else
			groupBuffPanel.panelWdg = createWidget(aForm, "BuffGroup"..tostring(aPosInPlateIndex), "BuffGroup")
		end
		resize(groupBuffPanel.panelWdg, math.max(size*math.min(w, num), m_minGroupPanelWidth), size*math.min(h, math.ceil(num/w))+30)

		local groupBuffTopPanel = getChild(groupBuffPanel.panelWdg, "MoveModePanel", true)
		if aSettings.fixed or anIsAboveHead then
			hide(groupBuffTopPanel)
		else
			show(groupBuffTopPanel)
			setText(getChild(groupBuffTopPanel, "PanelNameText"), aSettings.name, "ColorWhite", "center", 17, true, true)
		end
		setFade(groupBuffTopPanel, 0.7)
		
		local buffAlign = WIDGET_ALIGN_LOW
		if aSettings.flipBuffsButton then
			buffAlign = WIDGET_ALIGN_HIGH
			align(groupBuffTopPanel, WIDGET_ALIGN_HIGH)
			align(groupBuffPanel.panelWdg, WIDGET_ALIGN_HIGH)
		end
		if anIsAboveHead then
			--buffAlign = WIDGET_ALIGN_CENTER
		else
			DnD.Init(groupBuffPanel.panelWdg, groupBuffTopPanel, true, false)
		end
			
		setTemplateWidget(getChild(aForm, "BuffGroup"))
		for j=1, num do
			local x = ((j-1)%w)*size
			local y = math.floor((j-1)/w)*size
			
			local currBuff = {}
			currBuff.buffFinishedTime_h = 0
			currBuff.info = {}
			currBuff.buffWdg = createWidget(groupBuffPanel.panelWdg, nil, "Buff", buffAlign, nil, nil, nil, x, 30+y)
			hide(currBuff.buffWdg)
			resize(currBuff.buffWdg, size, size)
			resize(getChild(currBuff.buffWdg, "DotText"), size, round(size/2.4))
			resize(getChild(currBuff.buffWdg, "DotStackText"), size, GetTextSizeByBuffSize(size))
						
			currBuff.info.buffIcon = getChild(currBuff.buffWdg, "DotIcon")
			currBuff.info.buffHighlight = getChild(currBuff.buffWdg, "DotHighlight")
			currBuff.info.buffTimerWdg = getChild(currBuff.buffWdg, "DotText")
			currBuff.info.buffStackCntWdg = getChild(currBuff.buffWdg, "DotStackText")
			currBuff.info.buffSize = size
			
			groupBuffPanel.buffList[j] = currBuff
		end		
	end
	return groupBuffPanel
end

function CreateGroupBuffPanels(aForm)
	hide(getChild(aForm, "BuffGroup"))
	
	local profile = GetCurrentProfile()
	for i, group in ipairs(profile.buffFormSettings.buffGroups) do
		if not group.aboveHeadButton then
			m_groupBuffPanels[i] = CreateGroupBuffPanel(aForm, group, false, i)
		end
	end
	
end

function ResetPanelPos(aInd)
	DnD.Remove(m_groupBuffPanels[aInd].panelWdg)
	SetConfig("DnD:"..DnD.GetWidgetTreePath(m_groupBuffPanels[aInd].panelWdg), {posX = 500, posY = 400, highPosX = 0, highPosY = 0})
	DnD.Init(m_groupBuffPanels[aInd].panelWdg, getChild(m_groupBuffPanels[aInd].panelWdg, "MoveModePanel"), true, false)
	
end

local function FindIndexByWdg(aWdg)
	for _, panel in pairs(m_groupBuffPanels) do
		if panel.panelWdg:IsEqual(aWdg) then
			return panel.index
		end
	end
end

function SetPanelFixed(aFromWdg)
	local settingIndex = FindIndexByWdg(aFromWdg)
	if settingIndex then
		local profile = GetCurrentProfile()
		profile.buffFormSettings.buffGroups[settingIndex].fixed = true
	end
end

function SetGroupBuffPanelsInfoForMe()
	local myID = avatar.GetId()
	local profile = GetCurrentProfile()
	local panelList = {}
	for i, groupSettings in pairs(profile.buffFormSettings.buffGroups) do
		if groupSettings.buffOnMe and not groupSettings.aboveHeadButton then 
			panelList[i] = m_groupBuffPanels[i]
		end
	end
	FabricMakeGroupBuffPlayerInfo(myID, panelList, true)
end

function SetGroupBuffPanelsInfoForTarget(aTargetID)
	if aTargetID == m_lastTargetID then
		return
	end
	
	local profile = GetCurrentProfile()
	local panelList = {}
	
	for i, groupSettings in ipairs(profile.buffFormSettings.buffGroups) do
		if groupSettings.buffOnTarget and not groupSettings.aboveHeadButton then 
			panelList[i] = m_groupBuffPanels[i]
			HideItemsAboveHead(panelList[i])
		end
	end

	if m_lastTargetID then
		UnsubscribeGroupBuffListeners(m_lastTargetID)
	end
	
	if aTargetID == avatar.GetId() then
		m_lastTargetID = nil
		FabricDestroyUnused()
		return
	end
	
	ChangedTargetForAboveHead(aTargetID)
	m_lastTargetID = aTargetID
	
	if not aTargetID then
		FabricDestroyUnused()
		return
	end
	
	FabricMakeGroupBuffPlayerInfo(aTargetID, panelList, false)
	
	FabricDestroyUnused()
end

function GetAboveHeadSettings()
	local profile = GetCurrentProfile()
	for i, groupSettings in ipairs(profile.buffFormSettings.buffGroups) do
		if groupSettings.aboveHeadButton then 
			return groupSettings
		end
	end
end

local function CheckEnemy(anEnemyButton, anObjID)
	return anEnemyButton and not object.IsFriend(anObjID)
end

function UnitsChangedForAboveHead(aSpawnedUnitList, aDespawnedUnitList)
	local profile = GetCurrentProfile()
	local aboveHeadPanel = nil
	local priority = NORMAL_PRIORITY_PANELS
	local myID = avatar.GetId()
	local aboveHeadSettings = GetAboveHeadSettings()
	if not aboveHeadSettings then
		return
	end
	
	for _, objID in pairs(aDespawnedUnitList) do
		if objID then
			RemovePanelAboveHead(objID)
			UnsubscribeAboveHeadListeners(objID)
		end
	end
	FabricDestroyUnused()
	
	for _, objID in pairs(aSpawnedUnitList) do
		if objID and unit.IsPlayer(objID) then
			if not aboveHeadSettings.isEnemyButton or CheckEnemy(aboveHeadSettings.isEnemyButton, objID) then
				priority = NORMAL_PRIORITY_PANELS
				if objID == myID then
					priority = HIGH_PRIORITY_PANELS
				end
				aboveHeadPanel = GetAboveHeadPanel(objID, priority)
				if aboveHeadPanel then
					FabricMakeAboveHeadPlayerInfo(objID, aboveHeadPanel)
				end
			end
		end
	end
end

function RelationChangedForAboveHead(anUnitID)
	local profile = GetCurrentProfile()
	local aboveHeadPanel = nil
	local aboveHeadSettings = GetAboveHeadSettings()
	if not aboveHeadSettings then
		return
	end
	
	local reallyExist = false
	local unitList = avatar.GetUnitList()
	for _, objID in pairs(unitList) do
		if objID == anUnitID then
			reallyExist = true
			break
		end
	end
	
	if anUnitID and reallyExist and unit.IsPlayer(anUnitID) then
		if not aboveHeadSettings.isEnemyButton or CheckEnemy(aboveHeadSettings.isEnemyButton, anUnitID) then
			if not IsExistAboveHeadPanel(anUnitID) then
				aboveHeadPanel = GetAboveHeadPanel(anUnitID, NORMAL_PRIORITY_PANELS)
				if aboveHeadPanel then
					FabricMakeAboveHeadPlayerInfo(anUnitID, aboveHeadPanel)
				end
			end
		elseif aboveHeadSettings.isEnemyButton and object.IsFriend(anUnitID) then
			RemovePanelAboveHead(anUnitID)
			UnsubscribeAboveHeadListeners(anUnitID)
		end
	end
	
	FabricDestroyUnused()
end

function ChangedTargetForAboveHead(aTargetID)
	local aboveHeadSettings = GetAboveHeadSettings()
	if not aboveHeadSettings or not aTargetID then
		return
	end
	if not unit.IsPlayer(aTargetID) then
		return
	end
	if not aboveHeadSettings.isEnemyButton or CheckEnemy(aboveHeadSettings.isEnemyButton, aTargetID) then
		SetPriorityAboveHeadPanel(m_lastTargetID, NORMAL_PRIORITY_PANELS)
		if  not IsExistAboveHeadPanel(aTargetID) then
			local aboveHeadPanel = GetAboveHeadPanel(aTargetID, HIGH_PRIORITY_PANELS)
			if aboveHeadPanel then
				FabricMakeAboveHeadPlayerInfo(aTargetID, aboveHeadPanel)
			end
		end
	end
	FabricDestroyUnused()
end