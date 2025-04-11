local m_groupBuffPanels = {}
local m_lastTargetID = nil

local function GetTextSizeByBuffSize(aSize)
	return math.floor(aSize/2.5)
end

local function PlayerAddSomeBuff(aBuffInfo, aGroupBuffBar, anInfoObj, aCleanableBuff)
	return PlayerAddBuff(aBuffInfo, aGroupBuffBar, aGroupBuffBar.guiBuffList, anInfoObj, aCleanableBuff)
end

local function PlayerChangeSomeBuff(aBuffID, aBuffDynamicInfo, aGroupBuffBar)
	PlayerChangeBuff(aBuffID, aBuffDynamicInfo, aGroupBuffBar, aGroupBuffBar.guiBuffList)
end

local function PlayerRemoveSomeBuff(aBuffID, aGroupBuffBar)
	local wasRemoved, buffSlot = PlayerRemoveBuff(aBuffID, aGroupBuffBar, aGroupBuffBar.guiBuffList)
	if wasRemoved then	
		TryShowBuffFromQueue(aGroupBuffBar)
	end
end

local function UpdateTick(aGroupBuffBar)
	UpdateTimeForBuffArray(aGroupBuffBar.guiBuffList, true)
end

local function SpellChanged(aSpellInfo, aGroupBuffBar, anInfoObj)
	aSpellInfo.stackCount = 0
	aSpellInfo.texture = getSpellTextureFromCache(aSpellInfo.spellID)
	aSpellInfo.id = aSpellInfo.objectId

	local buffSlot = PlayerAddSomeBuff(aSpellInfo, aGroupBuffBar, anInfoObj)
	if buffSlot then
		if aSpellInfo.remainingMs > 0 then
			setFade(buffSlot.buffIcon, 0.4)
		else
			setFade(buffSlot.buffIcon, 1)
		end
	end
end

local function SpellRemoved(anID, aGroupBuffBar)
	PlayerRemoveSomeBuff(anID, aGroupBuffBar)
end

function DestroyGroupBuffPanels()
	for _, groupBuffPanel in pairs(m_groupBuffPanels) do
		if groupBuffPanel.panelWdg then
			local groupBuffTopPanel = getChild(groupBuffPanel.panelWdg, "MoveModePanel")
			if groupBuffTopPanel then
				DnD.Remove(groupBuffTopPanel)
				DnD.HideWdg(groupBuffTopPanel)
			end
			HideBuffsOnPanel(groupBuffPanel)
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
	groupBuffPanel.listenerAddBuffNegative = PlayerAddSomeBuff
	groupBuffPanel.listenerChangeBuff = PlayerChangeSomeBuff
	groupBuffPanel.listenerRemoveBuffNegative = PlayerRemoveSomeBuff
	groupBuffPanel.listenerChangeImportantBuff = PlayerAddSomeBuff
	groupBuffPanel.listenerUpdateTick = UpdateTick
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
			move(groupBuffPanel.panelWdg, 200, math.min(100+aPosInPlateIndex*10, 350))

			DnD.Init(groupBuffPanel.panelWdg, groupBuffTopPanel, true, false)
		end		
		setTemplateWidget("common")
		local fontSize = GetTextSizeByBuffSize(size)
		for i=1, w*h do
			local x = ((i-1)%w)*size
			local y = math.floor((i-1)/w)*size + 30
			
			table.insert(groupBuffPanel.guiBuffList, CreateBuffSlot(groupBuffPanel.panelWdg, "bs"..tostring(i), buffAlign, WIDGET_ALIGN_LOW, x, y, size, fontSize, fontSize, aSettings.buffsOpacity, true, false))
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
	
	for _, objID in ipairs(aSpawnedUnitList) do
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
	
	for _, objID in ipairs(aDespawnedUnitList) do
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