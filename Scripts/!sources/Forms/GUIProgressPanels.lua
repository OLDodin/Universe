Global("PROGRESS_PANELS_LIMIT", 10)

Global("ACTION_PROGRESS", 2)
Global("BUFF_PROGRESS", 3)

local m_template = getChild(mainForm, "Template")
local m_defaultPanelHeight = 40
local m_panelWidth = 0

local function InitProgressPanel(aPanelName)
	local progressPanel = getChild(mainForm, aPanelName)
	local topPanel = getChild(progressPanel, "MoveModePanel")
	
	setText(getChild(topPanel, "PanelNameText"), getLocale()[aPanelName], "ColorWhite", "center", 16, true, true)
	DnD.HideWdg(progressPanel)
	DnD.Init(progressPanel, topPanel, true, false)
	
	return progressPanel
end

function InitProgressActionPanel()
	return InitProgressPanel("ProgressActionPanel")
end

function InitProgressBuffPanel()
	return InitProgressPanel("ProgressBuffPanel")
end

function CreateProgressCastPanel(aParentPanel, aY)
	setTemplateWidget("bar")
	local profile = GetCurrentProfile()
	local panelWidth = tonumber(profile.castFormSettings.panelWidthText)
	local panelHeight = tonumber(profile.castFormSettings.panelHeightText)
	m_panelWidth = panelWidth
	
	local posY = aY*(panelHeight+1)
	
	local progressBar = {}
	progressBar.wdg = createWidget(aParentPanel, "ProgressBar"..tostring(aY), "ProgressBar", nil, nil, panelWidth, panelHeight, 0, posY)
	progressBar.barWdg = getChild(progressBar.wdg, "TimeBar")
	progressBar.backgroundWdg = getChild(progressBar.wdg, "BackgroundBar")
	progressBar.iconWdg = getChild(progressBar.wdg, "ProgressIcon")
	progressBar.nameMobWdg = getChild(progressBar.wdg, "NameMobText")
	progressBar.nameTargetWdg = getChild(progressBar.wdg, "NameTargetText")
	progressBar.nameProgressWdg = getChild(progressBar.wdg, "NameProgressText")
	progressBar.fontScale = panelHeight / m_defaultPanelHeight
	
	resize(progressBar.barWdg, panelWidth, panelHeight)
	resize(progressBar.iconWdg, panelHeight-10, panelHeight-10)
	
	setBackgroundColor(progressBar.backgroundWdg, {r = 0; g = 0; b = 0; a = 0.6 })
	updatePlacementPlain(progressBar.nameMobWdg, nil, nil, panelHeight, 2, panelWidth-panelHeight, 16*progressBar.fontScale)
	updatePlacementPlain(progressBar.nameTargetWdg, nil, nil, 0, 2, panelWidth, 16*progressBar.fontScale)
	updatePlacementPlain(progressBar.nameProgressWdg, nil, nil, panelHeight, 0, panelWidth-panelHeight, 20*progressBar.fontScale)
		
	setTextViewText(progressBar.nameMobWdg, g_tagTextValue, nil, nil, nil, 14*progressBar.fontScale)
	setTextViewText(progressBar.nameTargetWdg, g_tagTextValue, nil, nil, nil, 14*progressBar.fontScale)
	setTextViewText(progressBar.nameProgressWdg, g_tagTextValue, nil, nil, nil, 18*progressBar.fontScale)

	return progressBar
end

function CheckCorrectInfo(aInfo)
	if aInfo.buffInfo and aInfo.buffInfo.remainingMs - (g_cachedTimestamp - aInfo.queueTimestamp_h) > 0 and aInfo.buffInfo.durationMs > 0 then
		return true
	end
	if aInfo.spellId and (aInfo.duration - aInfo.progress) - (g_cachedTimestamp - aInfo.queueTimestamp_h) > 0 then
		return true
	end

	return false
end

function SetBaseInfoProgressCastPanel(aBar, aInfo, aType, aBuffInfo)
	aBar.playerID = aInfo.objectId or aInfo.id 
	aBar.actionType = aType
	aBar.isUsed = true
	aBar.buffID = aInfo.buffId
	aBar.castedByMe = false
	

	local fromPlacement = aBar.barWdg:GetPlacementPlain()
	fromPlacement.sizeX = m_panelWidth
	local toPlacement = copyTable(fromPlacement)
	toPlacement.sizeX = 0
	
	aBar.nameProgressWdg:SetVal(g_tagTextValue, aInfo.buffName or aInfo.name)
	if object.IsExist(aBar.playerID) then
		aBar.nameMobWdg:SetVal(g_tagTextValue, object.GetName(aBar.playerID))
	else
		aBar.nameMobWdg:SetVal(g_tagTextValue, "")
	end

	aBar.nameTargetWdg:SetVal(g_tagTextValue, "")
	
	if aBuffInfo then
		local buffCreatorID = aBuffInfo.producer and aBuffInfo.producer.casterId or nil
		aBar.castedByMe = g_myAvatarID == buffCreatorID
		if aBuffInfo.texture then
			setBackgroundTexture(aBar.iconWdg, aBuffInfo.texture)
			show(aBar.iconWdg)
		else
			hide(aBar.iconWdg)
		end
		local remainingMs = aBuffInfo.remainingMs - (g_cachedTimestamp - aInfo.queueTimestamp_h)
		resize(aBar.barWdg, fromPlacement.sizeX * (remainingMs / aBuffInfo.durationMs))
		fromPlacement = aBar.barWdg:GetPlacementPlain()
		aBar.barWdg:FinishResizeEffect()
		aBar.barWdg:PlayResizeEffect( fromPlacement, toPlacement, remainingMs, EA_MONOTONOUS_INCREASE )
		setBackgroundColor(aBar.barWdg, { r = 0.8; g = 0.8; b = 0; a = 0.8 }) 
		if buffCreatorID then 
			aBar.nameTargetWdg:SetVal(g_tagTextValue, object.GetName(buffCreatorID))
		end
	end
	
	if aInfo.spellId then
		local texture = getSpellTextureFromCache(aInfo.spellId)
		if texture then
			setBackgroundTexture(aBar.iconWdg, texture)
			show(aBar.iconWdg)
		else
			hide(aBar.iconWdg)
		end
		local remainingMs = (aInfo.duration - aInfo.progress) - (g_cachedTimestamp - aInfo.queueTimestamp_h)
		resize(aBar.barWdg, fromPlacement.sizeX * (remainingMs / aInfo.duration))
		fromPlacement = aBar.barWdg:GetPlacementPlain()
		aBar.barWdg:FinishResizeEffect()
		aBar.barWdg:PlayResizeEffect( fromPlacement, toPlacement, remainingMs, EA_MONOTONOUS_INCREASE )
		setBackgroundColor(aBar.barWdg, { r = 1.0; g = 0; b = 0; a = 0.8 })
		if object.IsExist(aBar.playerID) then
			local targetID = unit.GetTarget(aBar.playerID)
			local myAvatarTargetID = avatar.GetTarget()
			if myAvatarTargetID and targetID and myAvatarTargetID == aBar.playerID then
				aBar.nameTargetWdg:SetVal(g_tagTextValue, object.GetName(targetID))
			end
		end
	end

	show(aBar.wdg)
end


function GetProgressActionType(aParams)
	local actionType = nil
	if aParams.id then
		actionType = ACTION_PROGRESS
	end
	if aParams.objectId then
		actionType = BUFF_PROGRESS
	end
	return actionType
end

function ClearProgressCastPanel(aBar)
	aBar.actionType = nil
	aBar.playerID = nil
	aBar.isUsed = false
	aBar.buffID = nil
	aBar.castedByMe = false
	hide(aBar.wdg)
	aBar.barWdg:FinishResizeEffect()
end

local function GetProgressCastPanelCastedByMe(aPanelList)
	local profile = GetCurrentProfile()
	local panelHeight = tonumber(profile.castFormSettings.panelHeightText)
	
	for _, progressPanel in ipairs(aPanelList) do
		if progressPanel.isUsed and progressPanel.castedByMe then
			return progressPanel
		end
	end
end

function UpdatePositionProgressCastPanels(aPanelList)
	local profile = GetCurrentProfile()
	local panelHeight = tonumber(profile.castFormSettings.panelHeightText)
	
	local cnt = 0
	local panelCastedByMe = GetProgressCastPanelCastedByMe(aPanelList)
	if panelCastedByMe then
		move(panelCastedByMe.wdg, 0, 40)
		cnt = 1
	end
	for _, progressPanel in ipairs(aPanelList) do
		if progressPanel.isUsed and not progressPanel.castedByMe then
			local posY = 40 + cnt*(panelHeight+1)
			move(progressPanel.wdg, 0, posY)
			cnt = cnt + 1
		end
	end
end

function ShowProgressBuffForTarget(aTargetID, aPanelList, aProgressQueue)
	local profile = GetCurrentProfile()
	if not profile.castFormSettings.showOnlyMyTarget then
		return
	end
	
	--освобождаем панели, но в очереди (aProgressQueue) оставляем
	for _, progressPanel in ipairs(aPanelList) do
		if progressPanel.isUsed then
			if progressPanel.playerID then
				aProgressQueue[progressPanel.playerID].isShowedInGuiSlot = false
			end
			ClearProgressCastPanel(progressPanel)
		end
	end
	UpdatePositionProgressCastPanels(aPanelList)
	if aTargetID then
		TryShowProgressFromQueue(aPanelList, aProgressQueue)
	end
end

function RemoveProgressForNotExistObj(anUnitList, aPanelList, aProgressQueue)
	local reallyExist = false
	
	for _, panel in ipairs( aPanelList ) do
		if panel.isUsed then
			reallyExist = false
			for _, existObjID in pairs(anUnitList) do
				if existObjID == panel.playerID then
					reallyExist = true
					break
				end
			end
			if not reallyExist then
				StopShowProgressForPanel(panel, aPanelList, aProgressQueue)
			end
		end
	end
	
	local despawnList = {}
	for objID, _ in pairs( aProgressQueue ) do
		reallyExist = false
		for _, existObjID in pairs(anUnitList) do
			if existObjID == objID then
				reallyExist = true
				break
			end
		end
		if not reallyExist then
			table.insert(despawnList, objID)
		end
	end
	
	for _, objID in ipairs( despawnList ) do
		aProgressQueue[objID] = nil
	end
end