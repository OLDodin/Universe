function GetMinGroupPanelSize(anIsAboveHead)
	return anIsAboveHead and 80 or 220
end

function CreateBuffSlot(aParent, aName, anAlignX, anAlignY, aPosX, aPosY, aBuffSize, aStackSize, aTimeSize, aBuffsOpacity, aNeedShowBuffTime, anIsPlayerPanelMode)
	local buffSlot = {}
	buffSlot.buffWdg = createWidget(aParent, aName, "BuffTemplate", anAlignX, anAlignY, aBuffSize, aBuffSize, aPosX, aPosY)
	buffSlot.buffIcon = getChild(buffSlot.buffWdg, "DotIcon")
	buffSlot.buffHighlight = getChild(buffSlot.buffWdg, "DotHighlight")
	buffSlot.buffStackCnt = getChild(buffSlot.buffWdg, "DotStackText")
	buffSlot.buffTime = getChild(buffSlot.buffWdg, "DotText")
	buffSlot.needShowTime = aNeedShowBuffTime
	buffSlot.buffSize = aBuffSize
	buffSlot.buffFinishedTime_h = 0
	buffSlot.buffTimeStr = nil
	buffSlot.isUsed = false
	
	if anIsPlayerPanelMode then
		updatePlacementPlain(buffSlot.buffStackCnt, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 0, 0-math.floor(aBuffSize/10), aBuffSize, aStackSize+1)
	else
		updatePlacementPlain(buffSlot.buffStackCnt, WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 1, 1, aBuffSize, aStackSize+1)
	end
	
	if not aNeedShowBuffTime then
		hide(buffSlot.buffTime)
	else
		if anIsPlayerPanelMode then
			updatePlacementPlain(buffSlot.buffTime, WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 0, 0, aBuffSize, aTimeSize+1)
		else
			updatePlacementPlain(buffSlot.buffTime, WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 1, 0, aBuffSize, aTimeSize+2)
		end
	end
	
	if aBuffsOpacity ~= 1.0 then
		setFade(buffSlot.buffIcon, aBuffsOpacity)
		setFade(buffSlot.buffHighlight, aBuffsOpacity)
	end
	setTextViewText(buffSlot.buffStackCnt, g_tagTextValue, nil, "ColorWhite", "right", aStackSize, anIsPlayerPanelMode and 1 or nil, 1)
	setTextViewText(buffSlot.buffTime, g_tagTextValue, nil, "ColorWhite", "center", aTimeSize, 1, 1)

	return buffSlot
end

local function FindBuffSlot(aBuffID, anArray)
	for i, buffSlot in ipairs(anArray) do
		if buffSlot.isUsed and buffSlot.buffID == aBuffID then
			return buffSlot, i
		end
	end
	return nil, nil
end

local function GetUsedBuffSlotCnt(anArray)
	local cnt = 0
	for _, buffSlot in ipairs(anArray) do
		if buffSlot.isUsed then
			cnt  = cnt + 1
		end
	end
	return cnt
end

local function HasTimeToShow(aBuffInfo)
	return aBuffInfo.durationMs > 0 and aBuffInfo.remainingMs > 0
end

local function ClearBuffSlot(aBuffSlot)
	hide(aBuffSlot.buffWdg)
	aBuffSlot.buffID = nil
	aBuffSlot.buffFinishedTime_h = 0
	aBuffSlot.buffTimeStr = nil
	aBuffSlot.isUsed = false
	stopLoopBlink(aBuffSlot.buffHighlight)
end

function ClearAllBuffSlot(anArray)
	for _, buffSlot in ipairs(anArray) do
		ClearBuffSlot(buffSlot)
	end
end

function PlayerAddBuff(aBuffInfo, aBar, anArray, anInfoObj, aCleanableBuff)
	local isGroupBuffBar = aBar.panelWidthBuffCnt and true or false
	local copyBuffInfo = table.sclone(aBuffInfo)
	copyBuffInfo.cleanableBuff = aCleanableBuff
	copyBuffInfo.additionalInfo = anInfoObj
	local hasTimeToShow = HasTimeToShow(aBuffInfo)
	if hasTimeToShow then
		copyBuffInfo.buffFinishedTime_h = aBuffInfo.remainingMs + g_cachedTimestamp
	end
	aBar.buffsQueue[aBuffInfo.id] = copyBuffInfo
	
	local posInPlateIndex = anInfoObj and anInfoObj.ind or nil
	
	local buffTexture = aBuffInfo.texture or g_texNotFound
	
	local buffSlot = nil
	if aBar.fixedInsidePanel then
		buffSlot = anArray[posInPlateIndex or 1]
		if buffSlot then
			if not buffSlot.buffWdg:IsVisible() then
				buffSlot.buffWdg:Show(true)
				buffSlot.buffIcon:SetBackgroundTexture(buffTexture)
			end
		end
	else
		buffSlot = FindBuffSlot(aBuffInfo.id, anArray)
		if not buffSlot then
			local newCnt = GetUsedBuffSlotCnt(anArray) + 1
			buffSlot = anArray[newCnt]	
			if buffSlot then			
				buffSlot.buffWdg:Show(true)
				buffSlot.buffIcon:SetBackgroundTexture(buffTexture)
				if isGroupBuffBar then
					resize(aBar.panelWdg, math.max(buffSlot.buffSize*math.min(aBar.panelWidthBuffCnt, newCnt), GetMinGroupPanelSize(aBar.abovehead)), buffSlot.buffSize*math.min(aBar.panelHeightBuffCnt, math.ceil(newCnt/aBar.panelWidthBuffCnt))+30)
				end
			end
		end
	end
	if not buffSlot then
		return
	end
	copyBuffInfo.isShowedInGuiSlot = true
	
	buffSlot.isUsed = true
	buffSlot.buffID = aBuffInfo.id
	buffSlot.buffFinishedTime_h = aBuffInfo.remainingMs + g_cachedTimestamp
	

	if aBuffInfo.stackCount <= 1 then 
		hide(buffSlot.buffStackCnt)
	else
		show(buffSlot.buffStackCnt)
		buffSlot.buffStackCnt:SetVal(g_tagTextValue, tostring(aBuffInfo.stackCount))
	end
	
	if buffSlot.needShowTime and hasTimeToShow then
		buffSlot.buffTimeStr = getTimeString(aBuffInfo.remainingMs, not isGroupBuffBar)
		buffSlot.buffTime:SetVal(g_tagTextValue, buffSlot.buffTimeStr)
		show(buffSlot.buffTime)
	else
		buffSlot.buffTimeStr = nil
		hide(buffSlot.buffTime)
	end
	
	if anInfoObj and anInfoObj.useHighlightBuff then 
		show(buffSlot.buffHighlight)
		setBackgroundColor(buffSlot.buffHighlight, anInfoObj.highlightColor)
		if anInfoObj.blinkHighlight then
			startLoopBlink(buffSlot.buffHighlight, 0.5)
		end
	else
		hide(buffSlot.buffHighlight)
		stopLoopBlink(buffSlot.buffHighlight)
	end
	
	return buffSlot
end

function PlayerChangeBuff(aBuffID, aBuffDynamicInfo, aBar, anArray)
	local hasTimeToShow = HasTimeToShow(aBuffDynamicInfo)
	if hasTimeToShow then
		aBar.buffsQueue[aBuffID].buffFinishedTime_h = aBuffDynamicInfo.remainingMs + g_cachedTimestamp
	end
	
	local buffSlot = FindBuffSlot(aBuffID, anArray)
	if not buffSlot then
		return
	end
	
	local isGroupBuffBar = aBar.panelWidthBuffCnt and true or false
	
	buffSlot.buffFinishedTime_h = aBuffDynamicInfo.remainingMs + g_cachedTimestamp
	
	if aBuffDynamicInfo.stackCount <= 1 then 
		hide(buffSlot.buffStackCnt)
	else
		show(buffSlot.buffStackCnt)
		buffSlot.buffStackCnt:SetVal(g_tagTextValue, tostring(aBuffDynamicInfo.stackCount))
	end
	
	if buffSlot.needShowTime and hasTimeToShow then
		buffSlot.buffTimeStr = getTimeString(aBuffDynamicInfo.remainingMs, not isGroupBuffBar)
		buffSlot.buffTime:SetVal(g_tagTextValue, buffSlot.buffTimeStr)
		show(buffSlot.buffTime)
	else
		buffSlot.buffTimeStr = nil
		hide(buffSlot.buffTime)
	end
end

function PlayerRemoveBuff(aBuffID, aBar, anArray)
	aBar.buffsQueue[aBuffID] = nil
	local isGroupBuffBar = aBar.panelWidthBuffCnt and true or false
	local buffSlot, removeIndex = FindBuffSlot(aBuffID, anArray)
	if buffSlot then
		local usedBuffSlotCnt = GetUsedBuffSlotCnt(anArray)
		if not aBar.fixedInsidePanel then
			if removeIndex ~= GetTableSize(anArray) then
				for i = removeIndex, usedBuffSlotCnt do
					anArray[i] = anArray[i+1]
				end
				anArray[usedBuffSlotCnt] = buffSlot
				for i = removeIndex, usedBuffSlotCnt do
					if isGroupBuffBar then
						local x = ((i-1)%aBar.panelWidthBuffCnt)*buffSlot.buffSize
						local y = math.floor((i-1)/aBar.panelWidthBuffCnt)*buffSlot.buffSize + 30
						move(anArray[i].buffWdg, x, y)
					else
						move(anArray[i].buffWdg, 2+(i-1)*aBar.buffSize, 3)
					end
				end
			end
		end
		ClearBuffSlot(buffSlot)
		
		if isGroupBuffBar and not aBar.fixedInsidePanel then
			usedBuffSlotCnt = usedBuffSlotCnt - 1
			resize(aBar.panelWdg, math.max(buffSlot.buffSize*math.min(aBar.panelWidthBuffCnt, usedBuffSlotCnt), GetMinGroupPanelSize(aBar.abovehead)), buffSlot.buffSize*math.min(aBar.panelHeightBuffCnt, math.ceil(usedBuffSlotCnt/aBar.panelWidthBuffCnt))+30)
		end
		
		return true, buffSlot
	end
	return false, nil
end

function UpdateTimeForBuffArray(anArray, anIsGroupBuffBar)
	for _, buffSlot in ipairs(anArray) do	
		if buffSlot.isUsed and buffSlot.buffTimeStr then
			local remainingMs = math.max(buffSlot.buffFinishedTime_h - g_cachedTimestamp, 0)
			local buffTimeStr = getTimeString(remainingMs, not anIsGroupBuffBar)
			if buffSlot.buffTimeStr ~= buffTimeStr then 
				buffSlot.buffTime:SetVal(g_tagTextValue, buffTimeStr)
				buffSlot.buffTimeStr = buffTimeStr
			end
		end
	end
end

function HasCleanableBuff(aBar)
	for _, buffInfo in pairs(aBar.buffsQueue) do
		if not buffInfo.isPositive and buffInfo.cleanableBuff then
			return true
		end
	end
	return false
end

function TryShowBuffFromQueue(aBar, aPositive)
	if aBar.fixedInsidePanel then
		return
	end
	local listener = nil
	for _, buffInfo in pairs(aBar.buffsQueue) do
		if not buffInfo.isShowedInGuiSlot then
			if aPositive == nil then
				listener = aBar.listenerAddBuffNegative
			elseif aPositive and buffInfo.isPositive then
				listener = aBar.listenerAddBuff
			elseif not aPositive and not buffInfo.isPositive then	
				listener = aBar.listenerAddBuffNegative
			end
			if listener then
				if HasTimeToShow(buffInfo) then
					buffInfo.remainingMs = math.max(buffInfo.buffFinishedTime_h - g_cachedTimestamp, 0)
				end
				listener(buffInfo, aBar, buffInfo.additionalInfo, buffInfo.cleanableBuff)
				return
			end
		end
	end
end