local m_groupBuffPanels = {}
local m_lastTargetID = nil

local function GetTextSizeByBuffSize(aSize)
	return math.floor(aSize/2.5)
end

local function FindBufSlot(aGroupBuffBar, aBuffID)
	for i, buffSlot in pairs(aGroupBuffBar.guiBuffList) do
		if buffSlot.buffID == aBuffID then
			return buffSlot, i
		end
	end
end

local function GetMinGroupPanelSize(anIsAboveHead)
	if anIsAboveHead then
		return 80
	end
	return 220
end

local function TryShowBuffFromQueue(aGroupBuffBar)
	for _, buffInfo in pairs(aGroupBuffBar.buffsQueue) do
		if not buffInfo.isShowedInGuiSlot then
			if buffInfo.remainingMs > 0 then
				buffInfo.remainingMs = math.max(buffInfo.buffFinishedTime_h - g_cachedTimestamp, 0)
			end
			aGroupBuffBar.listenerChangeBuffNegative(buffInfo, aGroupBuffBar, buffInfo.additionalInfo)
			return
		end
	end
end

local function PlayerAddBuff(aBuffInfo, aGroupBuffBar, anInfoObj)
	aBuffInfo.additionalInfo = anInfoObj
	if aBuffInfo.remainingMs > 0 then
		aBuffInfo.buffFinishedTime_h = aBuffInfo.remainingMs + g_cachedTimestamp
	end
	aGroupBuffBar.buffsQueue[aBuffInfo.id] = table.sclone(aBuffInfo)
	
	local posInPlateIndex = anInfoObj and anInfoObj.ind or nil
--LogInfo("PlayerAddBuff = ", aBuffInfo.name, " ind ", posInPlateIndex)
	
	local buffTexture = aBuffInfo.texture
	if not buffTexture then
		buffTexture = g_texNotFound
	end
	
	local buffSlot = FindBufSlot(aGroupBuffBar, aBuffInfo.id)
	if aGroupBuffBar.fixedInsidePanel then
		if not posInPlateIndex then
			posInPlateIndex = 1
		end
		buffSlot = aGroupBuffBar.guiBuffList[posInPlateIndex]
		if buffSlot then
			if not buffSlot.buffWdg:IsVisible() then
				buffSlot.buffWdg:Show(true)
				buffSlot.info.buffIcon:SetBackgroundTexture(buffTexture)
			end
		end
	else
		if not buffSlot then
			local newCnt = aGroupBuffBar.usedBuffSlotCnt + 1
			buffSlot = aGroupBuffBar.guiBuffList[newCnt]	
		--	LogInfo("PlayerAddBuff 1 = ", newCnt)
			if buffSlot then
		--	LogInfo("PlayerAddBuff 2")
				aGroupBuffBar.usedBuffSlotCnt = newCnt
				
				buffSlot.buffWdg:Show(true)
				buffSlot.info.buffIcon:SetBackgroundTexture(buffTexture)
				resize(aGroupBuffBar.panelWdg, math.max(buffSlot.info.buffSize*math.min(aGroupBuffBar.panelWidthBuffCnt, aGroupBuffBar.usedBuffSlotCnt), GetMinGroupPanelSize(aGroupBuffBar.abovehead)), buffSlot.info.buffSize*math.min(aGroupBuffBar.panelHeightBuffCnt, math.ceil(aGroupBuffBar.usedBuffSlotCnt/aGroupBuffBar.panelWidthBuffCnt))+30)
			end
		end
	end
	if not buffSlot then
		return
	end
	
	aGroupBuffBar.buffsQueue[aBuffInfo.id].isShowedInGuiSlot = true
	
	buffSlot.buffID = aBuffInfo.id
	buffSlot.buffFinishedTime_h = aBuffInfo.remainingMs + g_cachedTimestamp
	setFade(buffSlot.info.buffIcon, buffSlot.info.settingsOpacity)
	
	if aBuffInfo.stackCount <= 1 then 
		hide(buffSlot.info.buffStackCntWdg)
	else
		show(buffSlot.info.buffStackCntWdg)
		buffSlot.info.buffStackCntWdg:SetVal(g_tagTextValue, tostring(aBuffInfo.stackCount))
	end
	
	if aBuffInfo.remainingMs > 0 then
		local buffTimeStr = getTimeString(aBuffInfo.remainingMs)
		buffSlot.info.buffTimerWdg:SetVal(g_tagTextValue, buffTimeStr)
		buffSlot.info.buffTimeStr = buffTimeStr
		show(buffSlot.info.buffTimerWdg)
	else
		buffSlot.info.buffTimeStr = nil
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
	aGroupBuffBar.buffsQueue[aBuffID] = nil
	local buffSlot, removeIndex  = FindBufSlot(aGroupBuffBar, aBuffID)
	if buffSlot then
		buffSlot.buffID = nil
		if aGroupBuffBar.fixedInsidePanel then	
			hide(buffSlot.buffWdg)
			stopLoopBlink(buffSlot.info.buffHighlight)
		else
			hide(buffSlot.buffWdg)
			stopLoopBlink(buffSlot.info.buffHighlight)
			if removeIndex ~= GetTableSize(aGroupBuffBar.guiBuffList) then
				for i = removeIndex, aGroupBuffBar.usedBuffSlotCnt do
					aGroupBuffBar.guiBuffList[i] = aGroupBuffBar.guiBuffList[i+1]
				end
				aGroupBuffBar.guiBuffList[aGroupBuffBar.usedBuffSlotCnt] = buffSlot
				for i = removeIndex, aGroupBuffBar.usedBuffSlotCnt do
					local x = ((i-1)%aGroupBuffBar.panelWidthBuffCnt)*buffSlot.info.buffSize
					local y = math.floor((i-1)/aGroupBuffBar.panelWidthBuffCnt)*buffSlot.info.buffSize
					move(aGroupBuffBar.guiBuffList[i].buffWdg, x, y+30)
				end
			end
			aGroupBuffBar.usedBuffSlotCnt = math.max(aGroupBuffBar.usedBuffSlotCnt - 1, 0)
			
			resize(aGroupBuffBar.panelWdg, math.max(buffSlot.info.buffSize*math.min(aGroupBuffBar.panelWidthBuffCnt, aGroupBuffBar.usedBuffSlotCnt), GetMinGroupPanelSize(aGroupBuffBar.abovehead)), buffSlot.info.buffSize*math.min(aGroupBuffBar.panelHeightBuffCnt, math.ceil(aGroupBuffBar.usedBuffSlotCnt/aGroupBuffBar.panelWidthBuffCnt))+30)
		end
		TryShowBuffFromQueue(aGroupBuffBar)
	end
end

local function UpdateTick(aGroupBuffBar)
	for _, buffSlot in pairs(aGroupBuffBar.guiBuffList) do
		if buffSlot.buffID and buffSlot.info.buffTimeStr then
			local remainingMs = math.max(buffSlot.buffFinishedTime_h - g_cachedTimestamp, 0)
			if remainingMs > 0 then
				local buffTimeStr = getTimeString(remainingMs)
				if buffSlot.info.buffTimeStr ~= buffTimeStr then 
					buffSlot.info.buffTimerWdg:SetVal(g_tagTextValue, buffTimeStr)
					buffSlot.info.buffTimeStr = buffTimeStr
				end
			else
				buffSlot.info.buffTimeStr = nil
				hide(buffSlot.info.buffTimerWdg)
			end
		end
	end
end

--очень, очень редко не приходит удаление баффа, удаляем сами
local function SecondTick(aGroupBuffBar)
	local removingBuffs = {}
	for _, buffInfo in pairs(aGroupBuffBar.buffsQueue) do
		if buffInfo.durationMs and buffInfo.durationMs > 0 and buffInfo.buffFinishedTime_h - g_cachedTimestamp < -1500 then
			table.insert(removingBuffs, buffInfo)
		end
	end
	for _, buffInfo in ipairs(removingBuffs) do
		aGroupBuffBar.listenerRemoveBuffNegative(buffInfo.id, aGroupBuffBar)
	end
end


local function SpellChanged(aSpellInfo, aGroupBuffBar, anInfoObj)
	aSpellInfo.stackCount = 0
	aSpellInfo.texture = getSpellTextureFromCache(aSpellInfo.spellID)
	aSpellInfo.id = aSpellInfo.objectId

	local buffSlot = PlayerAddBuff(aSpellInfo, aGroupBuffBar, anInfoObj)
	if buffSlot then
		if aSpellInfo.remainingMs > 0 then
			setFade(buffSlot.info.buffIcon, 0.4)
		else
			setFade(buffSlot.info.buffIcon, 1)
		end
	end
end


local function SpellRemoved(anID, aGroupBuffBar)
	PlayerRemoveBuff(anID, aGroupBuffBar)
end

function DestroyGroupBuffPanels()
	for _, groupBuffPanel in pairs(m_groupBuffPanels) do
		if groupBuffPanel.panelWdg then
			local groupBuffTopPanel = getChild(groupBuffPanel.panelWdg, "MoveModePanel")
			if groupBuffTopPanel then
				DnD.Remove(groupBuffTopPanel)
				DnD.HideWdg(groupBuffTopPanel)
			end
			for _, buffSlot in pairs(groupBuffPanel.guiBuffList) do
				stopLoopBlink(buffSlot.info.buffHighlight)
			end
			destroy(groupBuffPanel.panelWdg)
		end
	end
	m_groupBuffPanels = {}
	
	m_lastTargetID = nil
end

function InitGroupsParentForm()
	return getChild(mainForm, "BuffForm")
end

function CreateGroupBuffPanel(aForm, aSettings, anIsAboveHead, aPosInPlateIndex)
	local groupBuffPanel = {}
	groupBuffPanel.listenerChangeBuffNegative = PlayerAddBuff
	groupBuffPanel.listenerRemoveBuffNegative = PlayerRemoveBuff
	groupBuffPanel.listenerChangeImportantBuff = PlayerAddBuff
	groupBuffPanel.listenerUpdateTick = UpdateTick
	groupBuffPanel.listenerSecondTick = SecondTick
	groupBuffPanel.listenerSpellChanged = SpellChanged
	groupBuffPanel.listenerSpellRemoved = SpellRemoved
	groupBuffPanel.guiBuffList = {}
	groupBuffPanel.buffsQueue = {}
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
		setTemplateWidget("common")
		local panelWidth = math.max(size*math.min(w, num), GetMinGroupPanelSize(anIsAboveHead))
		local panelHeight = size*math.min(h, math.ceil(num/w))+30
		if anIsAboveHead then
			groupBuffPanel.panelWdg = createWidget(getChild(mainForm, "AboveHeadCachePanel"), "BuffGroup"..tostring(aPosInPlateIndex), "PanelTransparent", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, panelWidth, panelHeight)			
		else
			groupBuffPanel.panelWdg = createWidget(aForm, aSettings.buffGroupWdgName, "PanelTransparent", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, panelWidth, panelHeight)
		end
		priority(groupBuffPanel.panelWdg, 250)
		
		local buffAlign = WIDGET_ALIGN_LOW
		if aSettings.flipBuffsButton then
			buffAlign = WIDGET_ALIGN_HIGH
			align(groupBuffPanel.panelWdg, WIDGET_ALIGN_HIGH)
		end
		
		if not anIsAboveHead then
			setTemplateWidget("bar")
			local groupBuffTopPanel = createWidget(groupBuffPanel.panelWdg, "MoveModePanel", "MoveModePanel")
			if aSettings.fixed then
				DnD.HideWdg(groupBuffTopPanel)
			else
				DnD.ShowWdg(groupBuffTopPanel)
			end
			setText(getChild(groupBuffTopPanel, "PanelNameText"), aSettings.name, "ColorWhite", "center", 17, true, true)
			setFade(groupBuffTopPanel, 0.7)
		
			if aSettings.flipBuffsButton then
				align(groupBuffTopPanel, WIDGET_ALIGN_HIGH)
			end

			DnD.Init(groupBuffPanel.panelWdg, groupBuffTopPanel, true, false)
		end		
		setTemplateWidget("common")
		for j=1, w*h do
			local x = ((j-1)%w)*size
			local y = math.floor((j-1)/w)*size
			
			local currBuff = {}
			currBuff.buffFinishedTime_h = 0
			currBuff.info = {}
			currBuff.info.buffSize = size
			currBuff.buffWdg = createWidget(groupBuffPanel.panelWdg, "b"..tostring(j), "BuffTemplate", buffAlign, nil, currBuff.info.buffSize, currBuff.info.buffSize, x, 30+y)
			currBuff.info.buffIcon = getChild(currBuff.buffWdg, "DotIcon")
			currBuff.info.buffHighlight = getChild(currBuff.buffWdg, "DotHighlight")
			currBuff.info.buffTimerWdg = getChild(currBuff.buffWdg, "DotText")
			currBuff.info.buffStackCntWdg = getChild(currBuff.buffWdg, "DotStackText")
			currBuff.info.settingsOpacity = aSettings.buffsOpacity
			
			if currBuff.info.settingsOpacity ~= 1 then
				setFade(currBuff.info.buffIcon, aSettings.buffsOpacity)
				setFade(currBuff.info.buffHighlight, aSettings.buffsOpacity)
			end
			
			updatePlacementPlain(currBuff.info.buffTimerWdg, nil, nil, 1, 0, currBuff.info.buffSize, round(currBuff.info.buffSize/2.4)+1)
			updatePlacementPlain(currBuff.info.buffStackCntWdg, WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 1, 1, currBuff.info.buffSize, GetTextSizeByBuffSize(currBuff.info.buffSize)+1)
			
			setTextViewText(currBuff.info.buffStackCntWdg, g_tagTextValue, nil, "ColorWhite", "right", GetTextSizeByBuffSize(currBuff.info.buffSize), nil, 1)
			setTextViewText(currBuff.info.buffTimerWdg, g_tagTextValue, nil, "ColorWhite", "center", GetTextSizeByBuffSize(currBuff.info.buffSize), 1, 1)
						
			groupBuffPanel.guiBuffList[j] = currBuff
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
	if not m_groupBuffPanels[aInd] then
		return
	end
	local groupBuffTopPanel = getChild(m_groupBuffPanels[aInd].panelWdg, "MoveModePanel")
	if not groupBuffTopPanel then
		return
	end
	DnD.Remove(groupBuffTopPanel)
	SetConfig("DnD:"..DnD.GetWidgetTreePath(m_groupBuffPanels[aInd].panelWdg), {posX = 500, posY = 400, highPosX = 500, highPosY = 0})
	DnD.Init(m_groupBuffPanels[aInd].panelWdg, groupBuffTopPanel, true, false)
end

function UpdateVisibleForGroupBuffTopPanel(aSettings)
	for i, groupBuffPanel in pairs(m_groupBuffPanels) do
		if groupBuffPanel.panelWdg then
			local groupBuffTopPanel = getChild(groupBuffPanel.panelWdg, "MoveModePanel")
			if groupBuffTopPanel then
				if aSettings.buffGroups[i].fixed then
					DnD.HideWdg(groupBuffTopPanel)
				else
					DnD.ShowWdg(groupBuffTopPanel)
				end
			end
		end
	end
end

function SetVisibleForGroupBuffTopPanel(aInd, aVisible)
	if not m_groupBuffPanels[aInd] or not m_groupBuffPanels[aInd].panelWdg then
		return
	end
	local groupBuffTopPanel = getChild(m_groupBuffPanels[aInd].panelWdg, "MoveModePanel")
	if groupBuffTopPanel then
		if aVisible then
			DnD.ShowWdg(groupBuffTopPanel)
		else
			DnD.HideWdg(groupBuffTopPanel)
		end
	end
end

local function FindIndexByWdg(aWdg)
	for _, panel in pairs(m_groupBuffPanels) do
		if panel.panelWdg:IsEqual(aWdg) then
			return panel.index
		end
	end
end

function SetGroupBuffPanelFixed(aFromWdg)
	local settingIndex = FindIndexByWdg(aFromWdg)
	if settingIndex then
		UpdateConfigGroupBuffsFormPanelFixed(settingIndex)
	end
end

function SetGroupBuffPanelsInfoForMe()
	local profile = GetCurrentProfile()
	local panelList = {}
	local hasSpell = false
	for i, groupSettings in pairs(profile.buffFormSettings.buffGroups) do
		if groupSettings.buffOnMe and not groupSettings.aboveHeadButton then 
			panelList[i] = m_groupBuffPanels[i]
			local spellCondition = GetSpellConditionForBuffPlate(i)
			if spellCondition and spellCondition:HasCondtion() then
				hasSpell = true
			end
		end
	end
	FabricMakeGroupBuffPlayerInfo(g_myAvatarID, panelList, hasSpell)
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
			HideBuffsOnPanel(panelList[i])
		end
	end

	if m_lastTargetID then
		UnsubscribeGroupBuffListeners(m_lastTargetID)
	end
	
	if aTargetID == g_myAvatarID then
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

local function CheckSettingsCondition(aSettings, anObjID)
	local isPlayer = unit.IsPlayer(anObjID)
	local isFriend = object.IsFriend(anObjID)
	return aSettings.aboveHeadFriendPlayersButton and isPlayer and isFriend 
			or aSettings.aboveHeadNotFriendPlayersButton and isPlayer and not isFriend
			or aSettings.aboveHeadFriendMobsButton and not isPlayer and isFriend
			or aSettings.aboveHeadNotFriendMobsButton and not isPlayer and not isFriend, isPlayer
end

function SpawnedUnitsForAboveHead(aSpawnedUnitList)
	local aboveHeadPanel = nil
	local priority = NORMAL_PRIORITY_PANELS
	local aboveHeadSettings = GetAboveHeadSettings()
	if not aboveHeadSettings then
		return
	end
	
	for _, objID in pairs(aSpawnedUnitList) do
		local needPanel, isPlayer = CheckSettingsCondition(aboveHeadSettings, objID)
		if needPanel then
			priority = NORMAL_PRIORITY_PANELS
			if objID == g_myAvatarID then
				priority = HIGH_PRIORITY_PANELS
			end
			if not isPlayer then
				priority = LOW_PRIORITY_PANELS
			end
			aboveHeadPanel = GetAboveHeadPanel(objID, priority)
			if aboveHeadPanel then
				FabricMakeAboveHeadPlayerInfo(objID, aboveHeadPanel)
			end
		end
	end
end

function DespawnedUnitsForAboveHead(aDespawnedUnitList)
	if not GetAboveHeadSettings() then
		return
	end
	
	for _, objID in pairs(aDespawnedUnitList) do
		if objID then
			RemovePanelAboveHead(objID)
			UnsubscribeAboveHeadListeners(objID)
		end
	end
	FabricDestroyUnused()
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
	local priority = NORMAL_PRIORITY_PANELS
	if anUnitID and reallyExist then
		local needPanel, isPlayer = CheckSettingsCondition(aboveHeadSettings, anUnitID)
		if needPanel then
			if not IsExistAboveHeadPanel(anUnitID) then
				if not isPlayer then
					priority = LOW_PRIORITY_PANELS
				end
				aboveHeadPanel = GetAboveHeadPanel(anUnitID, priority)
				if aboveHeadPanel then
					FabricMakeAboveHeadPlayerInfo(anUnitID, aboveHeadPanel)
				end
			end
		else
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

	local priority = NORMAL_PRIORITY_PANELS
	local needPanel, isPlayer = CheckSettingsCondition(aboveHeadSettings, aTargetID)
	if needPanel then
		if isExist(m_lastTargetID) and not unit.IsPlayer(m_lastTargetID) then
			priority = LOW_PRIORITY_PANELS
		end
		SetPriorityAboveHeadPanel(m_lastTargetID, priority)
		if  not IsExistAboveHeadPanel(aTargetID) then
			local aboveHeadPanel = GetAboveHeadPanel(aTargetID, HIGH_PRIORITY_PANELS)
			if aboveHeadPanel then
				FabricMakeAboveHeadPlayerInfo(aTargetID, aboveHeadPanel)
			end
		end
	end
	FabricDestroyUnused()
end