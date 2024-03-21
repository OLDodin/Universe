Global( "BuffCondition", {} )



function BuffCondition:Init(aSettings)
	self.settings = aSettings
	self.showShopAndFood = false
	--для работы подсветки для автообнаруженных бафов (при дублировании их в списке бафов)
	self.needCheckAllBuffsByList = false
	for _, element in pairs(self.settings.customBuffs) do
		if element.name and element.useHighlightBuff then
			self.needCheckAllBuffsByList = true
			break
		end
	end
	
	self.avlCustomTree  = GetAVLWStrTree()
	for _, element in pairs(self.settings.customBuffs) do
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
		if common.IsWString(shopName) then
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
		for _, groupName in pairs(aBuffInfo.groups) do
			if 	groupName == "buffsofinterest" then
				return true
			end
		end		
	end
	return false
end

function BuffCondition:CheckShop(aBuffInfo)
	for _, groupName in pairs(aBuffInfo.groups) do
		if 	groupName == "Food"
		then
			return true
		end
	end	

	if self.treeShopCreated then
		if self.avlShopTree:get(aBuffInfo) ~= nil then
			return true
		end
	end
	
	return false
end

function BuffCondition:Check(aBuffInfo)
	--[[for _, groupName in pairs(aBuffInfo.groups) do
		if not g_groupsTypes[groupName] then
			g_groupsTypes[groupName] = true
			LogInfo("found aBuffInfo = ", aBuffInfo.name, "  groupName = ", groupName)
		end
	end]]
	--[[
	LogInfo("found aBuffInfo b = ", aBuffInfo.name)
	for _, groupName in pairs(aBuffInfo.groups) do
			LogInfo("found aBuffInfo = ", aBuffInfo.name, "  groupName = ", groupName, " aBuffInfo.isPositive = ", aBuffInfo.isPositive)
	end
	LogInfo("found aBuffInfo e")
	]]
	local searchRes = nil
	--[[
	-- test show all buffs
	if aBuffInfo.isNeedVisualize then
		return true, self.avlCustomTree.value, true
	end]]
	aBuffInfo.name = removeHtmlFromWString(aBuffInfo.name)
	if aBuffInfo.isNeedVisualize then
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
		or (self.settings.autoDebuffModeButtonUnk and aBuffInfo.ownerId and object.IsExist(aBuffInfo.ownerId) and object.IsFriend(aBuffInfo.ownerId))) 
		then
			local isCleanable = false
			
			for _, groupName in pairs(aBuffInfo.groups) do
				if 	groupName == "magics" or
					groupName == "stackablemagics"
				then
					isCleanable = true
					break
				end
			end		
			if self.settings.autoDebuffModeButton or isCleanable then
				return true, searchRes, isCleanable
			end
		end
		
		if aBuffInfo.isPositive and 
		(self.settings.checkEnemyCleanable or (self.settings.checkEnemyCleanableUnk and aBuffInfo.ownerId and object.IsExist(aBuffInfo.ownerId) and not object.IsFriend(aBuffInfo.ownerId))) 
		then
			for _, groupName in pairs(aBuffInfo.groups) do
				if 	groupName == "magics" or 
					groupName == "stackablemagics"
				then
					return true, searchRes, true
				end
			end					
		end

		if self.settings.checkControlsButton then
			for _, groupName in pairs(aBuffInfo.groups) do
				if 	groupName == "controls" or 
					groupName == "stuns" or
					groupName == "Disarms" or
					groupName == "fears"
				then
					return true, searchRes
				end
			end					
		end
		
		if self.settings.checkMovementsButton and not aBuffInfo.isPositive then
			for _, groupName in pairs(aBuffInfo.groups) do
				if 	groupName == "movementimpairing"
				then
					return true, searchRes
				end
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
	m_raidCondition:Init(profile.raidFormSettings.raidBuffs)
	m_raidCondition:InitShopShow()
	m_targeterCondition = copyTable(BuffCondition)
	m_targeterCondition:Init(profile.targeterFormSettings.raidBuffs)
	
	
	for i, buffPlateSettings in ipairs(profile.buffFormSettings.buffGroups) do
		buffPlateSettings.customBuffs = {}
		if buffPlateSettings.buffs then
			for ind, settingsBuffInfo in pairs(buffPlateSettings.buffs) do
				if settingsBuffInfo.isBuff then
					settingsBuffInfo.ind = ind
					table.insert(buffPlateSettings.customBuffs, settingsBuffInfo)
				end
			end
			m_buffPlateConditionArr[i] = copyTable(BuffCondition)
			m_buffPlateConditionArr[i]:Init(buffPlateSettings)
			
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