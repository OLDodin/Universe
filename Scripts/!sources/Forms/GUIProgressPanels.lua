Global("PROGRESS_PANELS_LIMIT", 12)

Global("ACTION_PROGRESS", 2)
Global("BUFF_PROGRESS", 3)

local m_template = getChild(mainForm, "Template")
local m_defaultPanelHeight = 40
local m_panelWidth = 0

local function CreateProgressPanel(aPanelName)
	setTemplateWidget(mainForm)
	local progressPanel = getChild(mainForm, aPanelName)
	local topPanel = getChild(progressPanel, "MoveModePanel")
	
	setText(getChild(topPanel, "PanelNameText"), getLocale()[aPanelName], "ColorWhite", "center", 16, true, true)
	DnD.HideWdg(progressPanel)
	DnD.Init(progressPanel, topPanel, true, false)
	
	return progressPanel
end

function CreateProgressActionPanel()
	return CreateProgressPanel("ProgressActionPanel")
end

function CreateProgressBuffPanel()
	return CreateProgressPanel("ProgressBuffPanel")
end

function CreateProgressCastPanel(aParentPanel, aY)
	setTemplateWidget(aParentPanel)
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

function SetBaseInfoProgressCastPanel(aBar, aInfo, aType)
	local correctInfo = false
	local buffInfo = aInfo.buffId and object.GetBuffInfo(aInfo.buffId)
	if buffInfo and buffInfo.remainingMs > 0 and buffInfo.durationMs > 0 then
		correctInfo = true
	end
	if aInfo.spellId and aInfo.duration - aInfo.progress > 0 then
		correctInfo = true
	end
	
	if not correctInfo then
		return
	end
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
	
	if buffInfo then
		local buffCreatorID = buffInfo.producer and buffInfo.producer.casterId or nil
		aBar.castedByMe = g_myAvatarID == buffCreatorID
		if buffInfo.texture then
			setBackgroundTexture(aBar.iconWdg, buffInfo.texture)
			show(aBar.iconWdg)
		else
			hide(aBar.iconWdg)
		end
		resize(aBar.barWdg, fromPlacement.sizeX * (buffInfo.remainingMs / buffInfo.durationMs))
		fromPlacement = aBar.barWdg:GetPlacementPlain()
		aBar.barWdg:FinishResizeEffect()
		aBar.barWdg:PlayResizeEffect( fromPlacement, toPlacement, buffInfo.remainingMs, EA_MONOTONOUS_INCREASE )
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
		resize(aBar.barWdg, fromPlacement.sizeX * ((aInfo.duration - aInfo.progress) / aInfo.duration))
		fromPlacement = aBar.barWdg:GetPlacementPlain()
		aBar.barWdg:FinishResizeEffect()
		aBar.barWdg:PlayResizeEffect( fromPlacement, toPlacement, aInfo.duration - aInfo.progress, EA_MONOTONOUS_INCREASE )
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

function IsProgressCastPanelVisible(aBar)
	return aBar.wdg:IsVisible()
end

function SetProgressCastPanelVisible(aBar, aVisible)
	if aVisible then
		show(aBar.wdg)
	else
		hide(aBar.wdg)
	end
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