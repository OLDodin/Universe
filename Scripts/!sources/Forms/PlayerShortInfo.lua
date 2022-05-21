local m_nameWdg = nil
local m_classImgWdg = nil
local m_infoWdg = nil
local m_guildWdg = nil
local m_factionWdg = nil
local m_titulWdg = nil
local m_form = nil
local m_emptyWStr = common.GetEmptyWString()
local m_shardBeginWStr = userMods.ToWString("[")
local m_shardEndWStr = userMods.ToWString("]")
local m_commaWStr = userMods.ToWString(", ")
local m_spaceWStr = userMods.ToWString(" ")
local m_bracketBeginWStr = userMods.ToWString("(")
local m_bracketEndWStr = userMods.ToWString(")")

function CreatePlayerShortInfoForm()
	local form=createWidget(nil, "playerShortInfoForm", "Form", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_HIGH, 350, 130, 100, 120)
	priority(form, 5500)
	hide(form)
	local panel=createWidget(form, nil, "Panel")

	m_nameWdg = createWidget(form, "name", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 286, 20, 50, 10)
	m_classImgWdg = createWidget(form, "classImg", "ImageBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 30, 30, 15, 10)
	m_infoWdg = createWidget(form, "info", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 20, 15, 40)
	m_guildWdg = createWidget(form, "guild", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 20, 15, 60)
	m_factionWdg = createWidget(form, "faction", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 20, 15, 80)
	m_titulWdg = createWidget(form, "titul", "TextView",  WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 20, 15, 100)
	
	m_form = form
	return form
end

function InitPlayerShortInfoForm(aPlayerID)
	if not isExist(aPlayerID) then
		return
	end
	local infoStr = ""
	local isPlayer = unit.IsPlayer(aPlayerID)
	
	local isEnemy = object.IsEnemy(aPlayerID)
	local isFriend = object.IsFriend(aPlayerID)
	local nameColor = (isEnemy and "ColorRed") or (isFriend and "ColorGreen") or "ColorYellow"
	local nameStr
	local shardName = m_emptyWStr
	if isPlayer then
		shardName = unit.GetPlayerShardName(aPlayerID)
		shardName = shardName and common.GetShortString(shardName) or m_emptyWStr
		nameStr = ConcatWString(m_shardBeginWStr, shardName, m_shardEndWStr, object.GetName(aPlayerID))
	else
		nameStr = object.GetName(aPlayerID)
	end
	
	setText(m_nameWdg, nameStr, nameColor, "left", 16)
	local playerClass = unit.GetClass(aPlayerID)
	
	local textureIndexForIcon = playerClass and playerClass.className or "UNKNOWN"
	setBackgroundTexture(m_classImgWdg, g_texIcons[textureIndexForIcon])

	local factionID = unit.GetFactionId(aPlayerID)
	local factionStr = factionID and factionID:GetInfo().name or m_emptyWStr
	local guildStr = m_emptyWStr
	local title = nil
	local soulLvl = nil
	if isPlayer then
		if not isPvpZoneNow() then
			soulLvl = unit.GetPlayerSoulLevel(aPlayerID)
		end
		local guildInfo = unit.GetGuildInfo(aPlayerID)
		guildStr = guildInfo and guildInfo.name or m_emptyWStr		
		title = unit.GetPlayerTitle(aPlayerID)
	
		local sex = unit.GetSex(aPlayerID)
		if sex then
			infoStr = ConcatWString(sex.raceSexName, m_commaWStr)
		end
		if playerClass then
			if unit.IsGreat(aPlayerID) then
				infoStr = ConcatWString(infoStr, m_spaceWStr, playerClass.greatName)
				
			else
				infoStr = ConcatWString(infoStr, m_spaceWStr, playerClass.raceClassName)
			end
		end
	else
		if unit.IsPet(aPlayerID) then
			local masterID = unit.GetFollowerMaster(aPlayerID)
			if isExist(masterID) then
				guildStr = ConcatWString(getLocale()["petOwner"], object.GetName(masterID))
			end
		end
		local race = unit.GetRace(aPlayerID)
		if race then
			infoStr = ConcatWString(getLocale()[race.sysCreatureRace], m_commaWStr)
		end
		title = {}
		title.name = unit.GetTitle(aPlayerID)
	end
	
	local titulStr = title and title.name or m_emptyWStr

	local lvl = unit.GetLevel(aPlayerID)
	if lvl then
		infoStr = ConcatWString(infoStr, m_spaceWStr, toWString(lvl))
	end
	if soulLvl then 
		infoStr = ConcatWString(infoStr, m_bracketBeginWStr, toWString(soulLvl), m_bracketEndWStr)
	end
	
	setText(m_infoWdg, infoStr)
	
	setText(m_factionWdg, factionStr)
	setText(m_guildWdg, guildStr, "ColorYellow")
	setText(m_titulWdg, titulStr, "ColorYellow")
	
	local additionalLines = {}
	additionalLines[0] = { wdg=m_guildWdg, wdgStr=guildStr }
	additionalLines[1] = { wdg=m_factionWdg, wdgStr=factionStr }
	additionalLines[2] = { wdg=m_titulWdg, wdgStr=titulStr }
	
	local cnt = 0
	for i = 0, 2 do
		if not common.IsEmptyWString(additionalLines[i].wdgStr) then
			move(additionalLines[i].wdg, nil, 60+cnt*20)
			cnt = cnt + 1
		end
	end
	resize(m_form, nil, 70+cnt*20)
end