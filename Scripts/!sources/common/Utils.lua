local cachedToWString = userMods.ToWString
local cachedFromWString = userMods.FromWString
local cachedIsExist = object.IsExist
local cachedIsUnit = object.IsUnit
local cachedCreateValuedText = common.CreateValuedText

local cachedTimeAbbr = {}

--------------------------------------------------------------------------------
-- Integer functions
--------------------------------------------------------------------------------

function round(time)
	if not time then return nil end
	return math.floor(time+0.5)
end

--------------------------------------------------------------------------------
-- String functions
--------------------------------------------------------------------------------

local _lower = string.lower
local _upper = string.upper

function string.lower(s)
    return _lower(s:gsub("([À-ß])",function(c) return string.char(c:byte()+32) end):gsub("¨", "¸"))
end

function string.upper(s)
    return _upper(s:gsub("([à-ÿ])",function(c) return string.char(c:byte()-32) end):gsub("¸", "¨"))
end

function toWString(text)
	if not text then return nil end
	if apitype(text) ~= "WString" then
		text=cachedToWString(tostring(text))
	end
	return text
end

local function toStringUtils(text)
	if not text then return nil end
	if apitype(text) == "WString" then
		text=cachedFromWString(text)
	end
	return tostring(text)
end

function toString(text)
	return cachedFromWString(text)
end

function toLowerString(text)
	text=toString(text)
	if not text then
		return nil
	end
	return string.lower(text)
end

function toLowerWString(text)
	text=toString(text)
	if not text then
		return nil
	end
	text=string.lower(text)
	return toWString(text)
end

function splitString(text, delimeter)
	text=toLowerString(text)
	local regxEverythingExceptDelimeter = '([^'..delimeter..']+)'
	local res = {}
	for x in string.gmatch(text, regxEverythingExceptDelimeter) do
		table.insert(res, x)
	end
	return res
end

function find(text, word)
	text=toStringUtils(text)
	word=toStringUtils(word)
	if text and word and word~="" then
		text=string.lower(text)
		word=string.lower(word)
		return string.find(text, word)
	end
	return false
end

function findSimpleString(text, word)
	if text and word and word~="" then
		return string.find(text, word)
	end
	return false
end

function findWord(text)
	if not text then return {} end
	if string.gmatch then return string.gmatch(toString(text), "([^,]+),*%s*") end
	return pairs({toString(text)})
end

function ConcatWString(...)
	local arg = { ... }
	local wStr = common.GetEmptyWString()
	for _, v in pairs(arg) do
		if type(v) == "number" then
			v = tostring(v)
		end
		wStr = wStr..v
	end
	return wStr
end 


local m_valuedText = cachedCreateValuedText()
m_valuedText:SetFormat(toWString('<header><r name="text_label"/></header>'))
local m_htmlWstr = userMods.ToWString("<html>")

function removeHtmlFromWString(text)
	if text:IsContain(m_htmlWstr) then
		m_valuedText:SetVal("text_label", text)
		return m_valuedText:ToWString()
	end
	return text
end

function LogAllCSSStyle()
	local listCSS = common.GetCSSList()
	for i = 0, GetTableSize(listCSS) do
		if listCSS[i] then 
			LogInfo(listCSS[i])
		end
	end
end

function formatText(text, align, fontSize, shadow, outline, fontName)
	local firstPart = "<body fontname='"..(toStringUtils(fontName) or "AllodsFantasy")
					.."' alignx = '"..(align or "left")
					.."' fontsize='"..(fontSize and tostring(fontSize) or "14")
					.."' shadow='"..(shadow and tostring(shadow) or "0")
					.."' outline='"..(outline and tostring(outline) or "1")
					.."'><rs class='color'>"
	local textMessage = toWString(text) or common.GetEmptyWString()
	local secondPart = "</rs></body>"
	return firstPart..textMessage..secondPart
end
--[[
function toValuedText(text, color, align, fontSize, shadow, outline, fontName)
	local valuedText = cachedCreateValuedText()
	if not valuedText or not text then return nil end
	valuedText:SetFormat(formatText(text, align, fontSize, shadow, outline, fontName))
	
	if color then
		valuedText:SetClassVal( "color", color )
	else
		valuedText:SetClassVal( "color", "LogColorYellow" )
	end
	return valuedText
end
]]
function compareStrWithConvert(aName1, aName2)
	local name1=toWString(aName1)
	local name2=toWString(aName2)
	if not name1 or not name2 then return nil end
	return name1 == name2
end

function compare(name1, name2)
	name1=toWString(name1)
	name2=toWString(name2)
	if not name1 or not name2 then return nil end
	return name1:Compare(name2, true) == 0
end

function initTimeAbbr()	
	table.insert(cachedTimeAbbr, toStringUtils(getLocale()["s"] or "s"))
	table.insert(cachedTimeAbbr, toStringUtils(getLocale()["m"] or "m"))
	table.insert(cachedTimeAbbr, toStringUtils(getLocale()["h"] or "h"))
	table.insert(cachedTimeAbbr, toStringUtils(getLocale()["d"] or "d"))
end

function getTimeString(ms, withoutFraction)
	if		ms<1000 and not withoutFraction	then return "0."..tostring(round(ms/100))..cachedTimeAbbr[1]
	else   	ms=round(ms/1000) end
	if		ms<60	then return tostring(ms)..cachedTimeAbbr[1]
	else    ms=round(ms/60) end
	if		ms<60	then return tostring(ms)..cachedTimeAbbr[2]
	else    ms=round(ms/60) end
	if		ms<24	then return tostring(ms)..cachedTimeAbbr[3]
	else    ms=round(ms/24) end
	return tostring(ms)..cachedTimeAbbr[4]
end

function makeColorMoreGray(aColor)
	local grayedColor = {}
	grayedColor.r = aColor.r - 0.3
	grayedColor.g = aColor.g - 0.3
	grayedColor.b = aColor.b - 0.3
	grayedColor.a = aColor.a
	grayedColor.r = grayedColor.r > 0 and grayedColor.r or 0
	grayedColor.g = grayedColor.g > 0 and grayedColor.g or 0
	grayedColor.b = grayedColor.b > 0 and grayedColor.b or 0
	
	return grayedColor
end

function makeColorMoreTransparent(aColor)
	local grayedColor = {}
	grayedColor.r = aColor.r
	grayedColor.g = aColor.g
	grayedColor.b = aColor.b
	grayedColor.a = aColor.a - 0.4
	grayedColor.a = grayedColor.a > 0 and grayedColor.a or 0
	
	return grayedColor
end

function compareColor(aColor1, aColor2)
	if not aColor1 or not aColor2 then
		return false
	end
	if aColor1.r ~= aColor2.r or aColor1.g ~= aColor2.g or aColor1.b ~= aColor2.b or aColor1.a ~= aColor2.a then
		return false
	end
	return true
end

--------------------------------------------------------------------------------
-- Log functions
--------------------------------------------------------------------------------

function logMemoryUsage()
	common.LogInfo( common.GetAddonName(), "usage "..tostring(gcinfo()).."kb" )
end


--------------------------------------------------------------------------------
-- Widget funtions
--------------------------------------------------------------------------------

function destroy(widget)
	if widget then widget:DestroyWidget() end
end

function isVisible(widget)
	if widget then return widget:IsVisible() end
	return nil
end

function getChild(widget, name, g)
	if g==nil then g=false end
	if not widget or not name then return nil end
	return widget:GetChildUnchecked(name, g)
end

function move(widget, posX, posY)
	if not widget then return end
	local BarPlace = widget:GetPlacementPlain()
	if not BarPlace then return nil end
	if posX then
		BarPlace.posX = posX
		BarPlace.highPosX = posX
	end
	if posY then
		BarPlace.posY = posY
		BarPlace.highPosY = posY
	end
	widget:SetPlacementPlain(BarPlace)
end

function setFade(widget, fade)
	if widget and fade then
		widget:SetFade(fade)
	end
end

function resize(widget, width, height)
	if not widget then return end
	local BarPlace = widget:GetPlacementPlain()
	if not BarPlace then return nil end
	if width then BarPlace.sizeX = width end
	if height then BarPlace.sizeY = height end
	widget:SetPlacementPlain(BarPlace)
end

function align(widget, alignX, alignY)
	if not widget then return end
	local BarPlace = widget:GetPlacementPlain()
	if not BarPlace then return nil end
	if alignX then BarPlace.alignX = alignX end
	if alignY then BarPlace.alignY = alignY end
	widget:SetPlacementPlain(BarPlace)
end

function updatePlacementPlain(widget, alignX, alignY, posX, posY, width, height)
	if not widget then return end
	local BarPlace = widget:GetPlacementPlain()
	if not BarPlace then return nil end
	if alignX then BarPlace.alignX = alignX end
	if alignY then BarPlace.alignY = alignY end
	if posX then
		BarPlace.posX = posX
		BarPlace.highPosX = posX
	end
	if posY then
		BarPlace.posY = posY
		BarPlace.highPosY = posY
	end
	if width then BarPlace.sizeX = width end
	if height then BarPlace.sizeY = height end
	widget:SetPlacementPlain(BarPlace)
end

function priority(widget, priority)
	if not widget or not priority then return nil end
	widget:SetPriority(priority)
end

function show(widget)
	if not widget  then return nil end
	if widget:IsVisible() then return nil end
	widget:Show(true)
end

function hide(widget)
	if not widget  then return nil end
	if not widget:IsVisible()  then return nil end
	widget:Show(false)
end

function setName(widget, name)
	if not widget or not name then return nil end
	widget:SetName(name)
end

function getName(widget)
	return widget and widget:GetName() or nil
end

function getText(widget)
	return widget and widget.GetText and widget:GetText() or nil
end

function getTextString(widget)
	return widget and widget.GetText and toStringUtils(widget:GetText()) or nil
end

local tagFontName = toWString("fontname")
local tagAlignX = toWString("alignx")
local tagFontsize = toWString("fontsize")
local tagShadow = toWString("shadow")
local tagOutline = toWString("outline")
local tagColor = toWString("color")

function setTextViewText(widget, tagTextValue, text, color, align, fontSize, shadow, outline, fontName)
	local attributes = {}
	if fontName then
		attributes[ tagFontName ] = toStringUtils(fontName)
	end	
	if align then
		attributes[ tagAlignX ] = align
	end	
	if fontSize then
		attributes[ tagFontsize ] = tostring(fontSize)
	end	
	if shadow then
		attributes[ tagShadow ] = tostring(shadow)
	end	
	if outline then
		attributes[ tagOutline ] = tostring(outline)
	end	
	if table.nkeys(attributes) > 0 then
		widget:SetTextAttributes(true, tagTextValue, attributes)
	end
			
	if color then
		widget:SetClassVal("color", color)
	end
	if text then
		widget:SetVal(tagTextValue, toWString(text))
	end
end

function setText(widget, text, color, align, fontSize, shadow, outline, fontName)
	if not widget then return nil end
	text=toWString(text or "")
	--textview
	if widget.SetValuedText then 
		widget:SetFormat(formatText(text, align, fontSize, shadow, outline, fontName))
		widget:SetClassVal( "color", color or "ColorWhite" )
	--textedit
	elseif widget.SetText then	
		widget:SetText(text)
	--buttons
	elseif widget.SetVal then
		widget:SetVal("button_label", text) 
		if widget.SetClassVal then widget:SetClassVal( "color", color or "ColorWhite" ) end
	end
end

function setBackgroundTexture(widget, texture)
	if not widget or not widget.SetBackgroundTexture then return nil end
	widget:SetBackgroundTexture(texture)
end

function setBackgroundColor(widget, color)
	if not widget or not widget.SetBackgroundColor then return nil end
	if not color then color={ r = 0; g = 0, b = 0; a = 0 } end
	widget:SetBackgroundColor(color)
end

local templateWidget=nil
local addonRelatedWidgetGroups = {}


function getDesc(name)
	if not templateWidget then
		return nil
	end
	local valueType = type(templateWidget)
	if valueType == "string" then
		local wdgGroup = addonRelatedWidgetGroups[templateWidget]
		if not wdgGroup then
			wdgGroup = common.GetAddonRelatedWidgetGroup(templateWidget)
			addonRelatedWidgetGroups[templateWidget] = wdgGroup
		end
		return wdgGroup:GetWidget(name)
	else
		local widget = templateWidget:GetChildUnchecked(name, false)
		return widget and widget:GetWidgetDesc() or nil
	end
end

function getParent(widget, num)
	if not num or num<1 then num=1 end
	if not widget or not widget.GetParent then return nil end
	local parent=widget:GetParent()
	if num==1 then return parent end
	return getParent(parent, num-1)
end


function createWidget(parent, widgetName, templateName, alignX, alignY, width, height, posX, posY)
	local widget = nil
	local desc = getDesc(templateName)
	if not desc then
		LogInfo("Not found WidgetDesc of ", templateName)
		return
	end
	
	widget = parent:CreateChildByDesc(desc)
	
	if not widget or not widget:IsValid() then
		LogInfo("Fail create widget type of ", templateName)
		return
	end
	setName(widget, widgetName)
	updatePlacementPlain(widget, alignX, alignY, posX, posY, width, height)
	return widget
end

function setTemplateWidget(widget)
	templateWidget=widget
end

function swap(widget)
	if widget and not widget:IsVisible() then
		show(widget)
	else
		hide(widget)
	end
end

function changeCheckBox(widget)
	if not widget or not widget.GetVariantCount then return end
	if not widget.GetVariant or not widget.SetVariant then return end
	if widget:GetVariantCount()<2 then return end
	
	if 0==widget:GetVariant() then 	widget:SetVariant(1)
	else 							widget:SetVariant(0) end
end

function setCheckBox(widget, value)
	if not widget or not widget.SetVariant or not widget.GetVariantCount then return end
	if widget:GetVariantCount()<2 then return end
	if 	value then 	
		widget:SetVariant(1) 
		return 
	end
	widget:SetVariant(0)
end

function getCheckBoxState(widget)
	if not widget or not widget.GetVariant then return end
	return widget:GetVariant()==1 and true or false
end

function getModFromFlags(flags)
	local ctrl=flags>3
	if ctrl then flags=flags-4 end
	local alt=flags>1
	if alt then flags=flags-2 end
	local shift=flags>0
	return ctrl, alt, shift
end

--------------------------------------------------------------------------------
-- Timers functions
--------------------------------------------------------------------------------

local timersInited = false
local timers={}
local m_loopEffects={}

function timerTick(params)
	if not params.effectType == ET_FADE then return end
	local timerForTick = nil
	for _, someTimer in pairs(timers) do
		if params.wtOwner:IsEqual(someTimer.widget) then
			timerForTick = someTimer
			break
		end
	end
	if not timerForTick then return end

	if not timerForTick.one then
		timerForTick.widget:PlayFadeEffect( 1.0, 1.0, timerForTick.speed*1000, EA_MONOTONOUS_INCREASE, true)
	end
	timerForTick.callback()
end

function startTimer(name, callback, speed, one)
	if name and timers[name] then destroy(timers[name].widget) end
	setTemplateWidget("common")
	local timerWidget=createWidget(mainForm, name, "Timer")
	if not timerWidget or not name or not callback then return nil end
	local newTimer = {}
	newTimer.callback=callback
	newTimer.widget=timerWidget
	newTimer.one=one
	newTimer.speed=tonumber(speed) or 1

	if not timersInited then
		common.RegisterEventHandler(timerTick, "EVENT_EFFECT_FINISHED")
		timersInited = true
	end
    timerWidget:PlayFadeEffect(1.0, 1.0, newTimer.speed*1000, EA_MONOTONOUS_INCREASE, true)
	
	timers[name] = newTimer
	return true
end

function stopTimer(name)
	if name and timers[name] then
		timers[name].widget:FinishFadeEffect(false, false)
	end
    --common.UnRegisterEventHandler(timerTick, "EVENT_EFFECT_FINISHED")
end

function setTimeout(name, speed)
	if name and timers[name] and speed then
		timers[name].speed=tonumber(speed) or 1
	end
end

function destroyTimer(name)
	if timers[name] then destroy(timers[name].widget) end
	timers[name]=nil
end

function effectDone(aParams)
	if aParams.effectType ~= ET_FADE then 
		return 
	end

	local findedWdg = nil
	for _, v in pairs(m_loopEffects) do
		if v.widget:IsValid() and aParams.wtOwner:IsEqual(v.widget) then
			findedWdg = v
			break
		end
	end
	if not findedWdg then return end

	if findedWdg.widget then
		findedWdg.widget:PlayFadeEffect( 0.0, 1.0, findedWdg.speed*1000, EA_SYMMETRIC_FLASH, true)
	end
end

function startLoopBlink(aWdg, aSpeed)
	for i, v in pairs(m_loopEffects) do
		if aWdg:IsEqual(v.widget) then
			v.speed = aSpeed
			return
		end
	end

	local obj = {}
	obj.widget = aWdg
	obj.speed = aSpeed
	table.insert(m_loopEffects, obj)
	
	aWdg:PlayFadeEffect( 0.0, 1.0, aSpeed*1000, EA_SYMMETRIC_FLASH, true)
end

function stopLoopBlink(aWdg)
	for i, v in pairs(m_loopEffects) do
		if aWdg:IsEqual(v.widget) then
			table.remove(m_loopEffects, i)
			break
		end
	end
	
	aWdg:FinishFadeEffect()
end


--------------------------------------------------------------------------------
-- Locales functions
--------------------------------------------------------------------------------

function setLocaleTextEx(widget, checked, color, align, fontSize, shadow, outline, fontName)
	local name=getName(widget)
	local text=name and getLocale()[name]
	if not text then
		text = name
	end
	if text then
		if checked~=nil then
			text=formatText(text, align)
			setCheckBox(widget, checked)
		end
		
		setText(widget, text, color, align, fontSize, shadow, outline, fontName)
	end
end

function setLocaleText(widget, checked)
	setLocaleTextEx(widget, checked, "ColorWhite", "left")
end

--------------------------------------------------------------------------------
-- Spell functions
--------------------------------------------------------------------------------

Global("TYPE_SPELL", 0)
Global("TYPE_ITEM", 1)
Global("TYPE_NOT_DEFINED", 2)
Global("NOT_FOUND", 100)

local cacheSpellId=nil

function getSpellIdFromName(aName) 
	if not aName then return nil end
	
	if not cacheSpellId then
		cacheSpellId = GetAVLWStrTree()
		local spellbook = avatar.GetSpellBook()
		if not spellbook then return nil end

		for _, spellId in pairs(spellbook) do
			local spellInfo = spellId and spellLib.GetDescription(spellId)
			if spellInfo then
				cacheSpellId:add({name = spellInfo.name, id = spellId})
			end
		end
	end
	
	local objToFind = {name = aName}
	local searchRes = cacheSpellId:find(objToFind)
	if searchRes ~= nil then
		if type(searchRes.id)=="userdata" then
			if spellLib.CanRunAvatarEx(searchRes.id) then return searchRes.id end
		else
			return nil
		end
	end
	
	return nil
end

local cacheItemId=nil

function getItemIdFromName(aName)
	if not aName then return nil end
	
	if not cacheItemId then
		cacheItemId = GetAVLWStrTree()
		local inventory = avatar.GetInventoryItemIds()
		if not inventory then return nil end

		for i, itemId in pairs(inventory) do
			local itemInfo = itemId and itemLib.GetItemInfo(itemId)
			if itemInfo then
				cacheItemId:add({name = itemInfo.name, id = itemId})
			end
		end
	end
	
	local objToFind = {name = aName}
	local searchRes = cacheItemId:find(objToFind)
	if searchRes ~= nil then
		if type(searchRes.id)=="number" then
			if itemLib.IsItem(searchRes.id) then return searchRes.id end
		else
			return nil
		end
	end

	return nil
end

function clearSpellCache()
	cacheSpellId=nil
end

function clearItemsCache()
	cacheItemId=nil
end


function isExist(targetId)
	if targetId then
		return cachedIsExist(targetId) and cachedIsUnit(targetId)
	end
	return false
end

function selectTarget(targetId)
	--lastTarget=avatar.GetTarget()
	if isExist(targetId) then
		avatar.SelectTarget(targetId)
	else
		avatar.UnselectTarget()
	end
end

function isEnemy(objectId)
	if not isExist(objectId) then return nil end
	local enemy=object.IsEnemy(objectId)
	return enemy
end

function isFriend(objectId)
	if not isExist(objectId) then return nil end
	local friend=object.IsFriend(objectId)
	return friend
end

function isRaid()
	return raid.IsExist()
end

function isGroup()
	return group.IsExist()
end

function isPvpZoneNow()
	if matchMaking.CanUseMatchMaking() and matchMaking.IsEventProgressExist() then
		local battleInfo = matchMaking.GetCurrentBattleInfo()
		if battleInfo and not battleInfo.isPvE  then
			return true
		end
	end
	return false
end

function cast(name, targetId)
	if isPvpZoneNow() then
		return false
	end
	
	local spellId=name and getSpellIdFromName(name)
	if not spellId then return nil end
	if not spellLib.CanRunAvatar(spellId) then
		return false
	end
	
	local duration=spellLib.GetProperties(spellId).launchWhenReady
	local properties=spellLib.GetProperties(spellId)
	local duration=properties.prepareDuration
	local state=spellLib.GetState(spellId)
	if not state.prepared and duration and duration > 1 then selectTarget(targetId) end

	if avatar.RunTargetSpell then
		local targetType=properties.targetType and properties.targetType==SPELL_TYPE_SELF
		if targetId and cachedIsExist(targetId) and not targetType then
			avatar.RunTargetSpell(spellId, targetId)
		else
			avatar.RunSpell(spellId)
		end
	else
		avatar.RunSpell(spellId)
	end
	return true
end

function useItem(name, targetId)
	if matchMaking.CanUseMatchMaking() and matchMaking.IsEventProgressExist() then
		local battleInfo = matchMaking.GetCurrentBattleInfo()
		if battleInfo and not battleInfo.isPvE  then
			return false
		end
	end
	local itemId=name and getItemIdFromName(name)
	if not itemId then return nil end

	if not avatar.CheckCanUseItem( itemId, false ) then
		return false
	end

	if targetId then
		selectTarget(targetId)
	end

	avatar.UseItem(itemId)
	return true
end

function testSpell(name, targetId)
	if not targetId then return nil end

	local spellId=name and getSpellIdFromName(name)
	return spellId and spellLib.CanRunAvatar(spellId)
end

function ressurect(targetId, ressurectName)
	local arrNames = {}
	for i = 1, 4 do
		local defaultName = getLocale()["defaultRessurectNames"..i]
		if defaultName then
			table.insert(arrNames, defaultName)
		end
	end
	for i, v in ipairs(arrNames) do
		local name=v
		if testSpell(name, targetId) then
			selectTarget(targetId)
			cast(name, targetId)
			return true
		end
	end
	return false
end

local cachedObjGetPos = object.GetPos
local cachedAvatarGetPos = avatar.GetPos
local cachedAvatarGetDir = avatar.GetDir

function getDistanceToTarget(targetId)
	local res = object.GetDistance(targetId)
	if not res then return nil end
	res = math.ceil(res)

	return res
end

function getAngleToTarget(targetId)
	local objPos = cachedObjGetPos(targetId)
	if not objPos then return nil end
	local myPos = cachedAvatarGetPos()
	return math.floor(math.atan2(objPos.posY-myPos.posY, objPos.posX-myPos.posX)*100+0.5)/100 - cachedAvatarGetDir()
end


function getGroupFromPersId(pid)
	if not pid or type(pid)~="userdata" then return nil end
	if raid.IsExist() then
		local members = raid.GetMembers()
		if not members then return 1 end
		for i, party in ipairs(members) do
			for _, member in ipairs(party) do
				if member.uniqueId and member.uniqueId:IsEqual(pid) then
					return i
				end
			end
		end
	end
end

function getGroupSizeFromPersId(pid)
	if not pid or type(pid)~="userdata" then return nil end
	if raid.IsExist() then
		local group=nil
		local members = raid.GetMembers()
		if not members then return nil end
		for _, party in ipairs(members) do
			for _, member in ipairs(party) do
				if member.uniqueId and member.uniqueId:IsEqual(pid) then
					return GetTableSize(party)
				end
			end
		end
	end
end

function getFirstEmptyPartyInRaid()
	if raid.IsExist() then
		local members = raid.GetMembers()
		if not members then return nil end
		return GetTableSize(members) + 1
	end
end



function getTimestamp()
	return common.GetLocalDateTimeMs()
end

Global("g_cachedTimestamp", getTimestamp())

function updateCachedTimestamp()
	g_cachedTimestamp = getTimestamp()
end

function copyTable(t)
	return table.sclone(t)
end

function deepCopyTable(t)
	if type( t ) ~= "table" then return t end
	local c = {}
	for i, v in pairs( t ) do c[ i ] = deepCopyTable( v ) end
	return c
end

local m_spellTextureCache = {}
function getSpellTextureFromCache(aSpellID)
	for _, spellTexInfo in pairs(m_spellTextureCache) do
		if spellTexInfo.spellID:IsEqual(aSpellID) then
			return spellTexInfo.texture
		end
	end
	local newSpellTexInfo = {}
	newSpellTexInfo.spellID = aSpellID
	newSpellTexInfo.texture = spellLib.GetIcon(aSpellID)
	table.insert(m_spellTextureCache, newSpellTexInfo)
	
	return newSpellTexInfo.texture
end