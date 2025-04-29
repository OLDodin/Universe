Global( "BuffCondition", {} )

local cachedIsExist = object.IsExist
local cachedIsFriend = object.IsFriend

function BuffCondition:Init(aSettings, aCustomBuffs)
	self.settings = aSettings
	self.showShopAndFood = false
	--для работы подсветки для автообнаруженных бафов (при дублировании их в списке бафов)
	self.needCheckAllBuffsByList = false
	for _, element in pairs(aCustomBuffs) do
		if element.name and element.useHighlightBuff then
			self.needCheckAllBuffsByList = true
			break
		end
	end
	
	self.avlCustomTree  = GetAVLWStrTree()
	for _, element in pairs(aCustomBuffs) do
		if element.name and not element.name:IsEmpty() then
			self.avlCustomTree:add(element)
		end
	end

end

function BuffCondition:InitShopShow()
	local locale = getLocale()
	self.avlShopTree  = GetAVLWStrTree()
	local shopsNames = {}
	for i = 1, 100 do
		local shopName = locale["allShop"..i]
		if apitype(shopName) == "WString" then
			table.insert(shopsNames, shopName)
		end
	end
	self.treeShopCreated = GetTableSize(shopsNames)~=0
	for _, element in pairs(shopsNames) do
		self.avlShopTree:add({name = element})
	end
end

function BuffCondition:SwitchShowShop()
	self.showShopAndFood = not self.showShopAndFood
end

Global("g_groupsTypes", {})

function BuffCondition:IsImportant(aBuffInfo)
	if self.settings.showImportantButton then
		if aBuffInfo.groups["buffsofinterest"] then
			return true
		end		
	end
	return false
end

function BuffCondition:CheckShop(aBuffInfo)
	if aBuffInfo.groups["Food"] then
		return true
	end	

	if self.treeShopCreated then
		if self.avlShopTree:get(aBuffInfo) ~= nil then
			return true
		end
	end
	
	return false
end

function BuffCondition:Check(aBuffInfo)
	--[[for groupName, _ in pairs(aBuffInfo.groups) do
		if not g_groupsTypes[groupName] then
			g_groupsTypes[groupName] = true
			LogInfo("found aBuffInfo = ", aBuffInfo.name, "  groupName = ", groupName)
		end
	end]]
	--LogTable(aBuffInfo)
	--LogInfo("=========================================")
	local searchRes = nil
	--[[
	-- test show all buffs
	if aBuffInfo.isNeedVisualize then
		return true, self.avlCustomTree.value, true
	end]]
	aBuffInfo.name = removeHtmlFromWString(aBuffInfo.name)
	if aBuffInfo.isNeedVisualize or self.settings.systemBuffButton then
		if self.needCheckAllBuffsByList then
			searchRes = self.avlCustomTree:find(aBuffInfo)

			if searchRes ~= nil and searchRes.castByMe then
				if not (aBuffInfo.producer and g_myAvatarID == aBuffInfo.producer.casterId) then
					searchRes = nil
				end
			end
		end
		
		if self.showShopAndFood then
			if self:CheckShop(aBuffInfo) then
				return true, searchRes
			end
		end
	
		if not aBuffInfo.isPositive and 
		(self.settings.autoDebuffModeButton 
		or self.settings.checkFriendCleanableButton  
		or (self.settings.autoDebuffModeButtonUnk and self.settings.checkEnemyCleanableDebuffUnk)
		or (self.settings.autoDebuffModeButtonUnk and aBuffInfo.ownerId and cachedIsExist(aBuffInfo.ownerId) and cachedIsFriend(aBuffInfo.ownerId))
		or (self.settings.checkEnemyCleanableDebuffUnk and aBuffInfo.ownerId and cachedIsExist(aBuffInfo.ownerId) and not cachedIsFriend(aBuffInfo.ownerId))
		) 
		then
			local isCleanable = false
			
			if aBuffInfo.groups["magics"] or aBuffInfo.groups["stackablemagics"] then
				isCleanable = true
			end
			
			if self.settings.autoDebuffModeButton or isCleanable then
				return true, searchRes, isCleanable
			end
		end
		
		if aBuffInfo.isPositive and 
		(
		self.settings.checkEnemyCleanable 
		or (self.settings.checkEnemyCleanableUnk and self.settings.checkFriendCleanableUnk)
		or (self.settings.checkEnemyCleanableUnk and aBuffInfo.ownerId and cachedIsExist(aBuffInfo.ownerId) and not cachedIsFriend(aBuffInfo.ownerId))
		or (self.settings.checkFriendCleanableUnk and aBuffInfo.ownerId and cachedIsExist(aBuffInfo.ownerId) and cachedIsFriend(aBuffInfo.ownerId))
		) 
		then
			if aBuffInfo.groups["magics"] or aBuffInfo.groups["stackablemagics"] then
				return true, searchRes, true
			end	
		end

		if self.settings.checkControlsButton then
			if aBuffInfo.groups["controls"] or aBuffInfo.groups["stuns"] or aBuffInfo.groups["Disarms"] or aBuffInfo.groups["fears"] then
				return true, searchRes
			end					
		end
		
		if self.settings.checkMovementsButton and not aBuffInfo.isPositive then
			if aBuffInfo.groups["movementimpairing"] then
				return true, searchRes
			end					
		end
	end

	if not self.needCheckAllBuffsByList then
		local searchRes = self.avlCustomTree:find(aBuffInfo)

		if searchRes ~= nil then
			if searchRes.castByMe then 
				if aBuffInfo.producer and g_myAvatarID == aBuffInfo.producer.casterId then
					return true, searchRes
				end
				return false
			end
			return true, searchRes
		end
	else
		return searchRes~=nil, searchRes
	end

	return false
end


local m_raidCondition = nil
local m_targeterCondition = nil
local m_buffPlateConditionArr = {}
local m_aboveHeadCondition = nil

function InitBuffConditionMgr()
	local profile = GetCurrentProfile()
	m_raidCondition = copyTable(BuffCondition)
	m_raidCondition:Init(profile.raidFormSettings.raidBuffs, profile.raidFormSettings.raidBuffs.customBuffs)
	m_raidCondition:InitShopShow()
	m_targeterCondition = copyTable(BuffCondition)
	m_targeterCondition:Init(profile.targeterFormSettings.raidBuffs, profile.targeterFormSettings.raidBuffs.customBuffs)
	
	
	for i, buffPlateSettings in ipairs(profile.buffFormSettings.buffGroups) do
		local customBuffs = {}
		if buffPlateSettings.buffs then
			for ind, settingsBuffInfo in pairs(buffPlateSettings.buffs) do
				if settingsBuffInfo.isBuff then
					settingsBuffInfo.ind = ind
					table.insert(customBuffs, settingsBuffInfo)
				end
			end
			m_buffPlateConditionArr[i] = copyTable(BuffCondition)
			m_buffPlateConditionArr[i]:Init(buffPlateSettings, customBuffs)
			
			if buffPlateSettings.aboveHeadButton then
				m_aboveHeadCondition = m_buffPlateConditionArr[i]
			end
		end
	end
end

function GetBuffConditionForRaid()
	return m_raidCondition
end

function GetBuffConditionForTargeter()
	return m_targeterCondition
end

function GetBuffConditionForBuffPlate(anPlateIndex)
	return m_buffPlateConditionArr[anPlateIndex]
end

function GetBuffConditionForAboveHead()
	return m_aboveHeadCondition
end