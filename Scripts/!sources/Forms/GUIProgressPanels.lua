Global("PROGRESS_PANELS_LIMIT", 15)

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
	progressBar.wdg = createWidget(aParentPanel, nil, "ProgressBar", nil, nil, panelWidth, panelHeight, 0, posY)
	progressBar.barWdg = getChild(progressBar.wdg, "TimeBar")
	progressBar.backgroundWdg = getChild(progressBar.wdg, "BackgroundBar")
	progressBar.iconWdg = getChild(progressBar.wdg, "ProgressIcon")
	progressBar.nameMobWdg = getChild(progressBar.wdg, "NameMobText")
	progressBar.nameTargetWdg = getChild(progressBar.wdg, "NameTargetText")
	progressBar.nameProgressWdg = getChild(progressBar.wdg, "NameProgressText")
	progressBar.fontScale = panelHeight / m_defaultPanelHeight
	
	resize(progressBar.barWdg, panelWidth, panelHeight)
	resize(progressBar.backgroundWdg, panelWidth, panelHeight)
	
	setBackgroundColor(progressBar.backgroundWdg, {r = 0; g = 0; b = 0; a = 0.6 })
	resize(progressBar.iconWdg, panelHeight-10, panelHeight-10)
	move(progressBar.iconWdg, 5, nil)
	resize(progressBar.nameMobWdg, panelWidth-panelHeight, 16*progressBar.fontScale)
	resize(progressBar.nameTargetWdg, panelWidth, 16*progressBar.fontScale)
	resize(progressBar.nameProgressWdg, panelWidth-panelHeight, 20*progressBar.fontScale)
	move(progressBar.nameMobWdg, panelHeight, 2)
	move(progressBar.nameTargetWdg, 0, 2)
	move(progressBar.nameProgressWdg, panelHeight, 0)
	
	hide(progressBar.wdg)
	
	return progressBar
end

function SetBaseInfoProgressCastPanel(aBar, aInfo, aType)
	local correctInfo = false
	local buffInfo = aInfo.buffId and object.GetBuffInfo(aInfo.buffId)
	if buffInfo and buffInfo.remainingMs > 0 then
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
	
	setText(aBar.nameProgressWdg, aInfo.buffName or aInfo.name, "ColorWhite", "left", 18*aBar.fontScale)
	if object.IsExist(aBar.playerID) then
		setText(aBar.nameMobWdg, object.GetName(aBar.playerID), "ColorWhite", "left", 14*aBar.fontScale)
	else
		setText(aBar.nameMobWdg, "", "ColorWhite", "left", 14*aBar.fontScale)
	end

	setText(aBar.nameTargetWdg, "", "LogColorOrange", "right", 14*aBar.fontScale)
	
	if buffInfo then
		local buffCreatorID = buffInfo.producer and buffInfo.producer.casterId or nil
		aBar.castedByMe = g_myAvatarID == buffCreatorID
		setBackgroundTexture(aBar.iconWdg, buffInfo.texture)
		resize(aBar.barWdg, fromPlacement.sizeX * (buffInfo.remainingMs / buffInfo.durationMs))
		fromPlacement = aBar.barWdg:GetPlacementPlain()
		aBar.barWdg:FinishResizeEffect()
		aBar.barWdg:PlayResizeEffect( fromPlacement, toPlacement, buffInfo.remainingMs, EA_MONOTONOUS_INCREASE )
		setBackgroundColor(aBar.barWdg, { r = 0.8; g = 0.8; b = 0; a = 0.8 }) 
		if buffCreatorID then 
			setText(aBar.nameTargetWdg, object.GetName(buffCreatorID), "LogColorOrange", "right", 14*aBar.fontScale)
		end
	end
	
	if aInfo.spellId then
		setBackgroundTexture(aBar.iconWdg, getSpellTextureFromCache(aInfo.spellId))
		resize(aBar.barWdg, fromPlacement.sizeX * ((aInfo.duration - aInfo.progress) / aInfo.duration))
		fromPlacement = aBar.barWdg:GetPlacementPlain()
		aBar.barWdg:FinishResizeEffect()
		aBar.barWdg:PlayResizeEffect( fromPlacement, toPlacement, aInfo.duration - aInfo.progress, EA_MONOTONOUS_INCREASE )
		setBackgroundColor(aBar.barWdg, { r = 1.0; g = 0; b = 0; a = 0.8 })
		if object.IsExist(aBar.playerID) then
			local targetID = unit.GetTarget(aBar.playerID)
			local myAvatarTargetID = avatar.GetTarget()
			if myAvatarTargetID and targetID and myAvatarTargetID == aBar.playerID then
				setText(aBar.nameTargetWdg, object.GetName(targetID), "LogColorOrange", "right", 14*aBar.fontScale)
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