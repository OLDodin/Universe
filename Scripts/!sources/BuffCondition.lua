Global( "BuffCondition", {} )



function BuffCondition:Init(aSettings)
	self.settings = aSettings
	self.showShopAndFood = false
	self.avlCustomTree  = GetAVLWStrTree()
	self.treeCustomCreated = GetTableSize(self.settings.customBuffs)~=0
	for _, element in pairs(self.settings.customBuffs) do
		if element.name then
			self.avlCustomTree:add(element)
		end
	end

end

function BuffCondition:InitShopShow()
	local m_locale = getLocale()
	self.avlShopTree  = GetAVLWStrTree()
	self.treeShopCreated = GetTableSize(m_locale["allShop"])~=0
	for _, element in pairs(m_locale["allShop"]) do
		self.avlShopTree:add({name = userMods.ToWString(element)})
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

	if self.showShopAndFood then
		if self:CheckShop(aBuffInfo) then
			return true
		end
	end
	
	if not aBuffInfo.isPositive and 
	(self.settings.autoDebuffModeButton or (self.settings.autoDebuffModeButtonUnk and aBuffInfo.ownerId and object.IsExist(aBuffInfo.ownerId) and object.IsFriend(aBuffInfo.ownerId))) 
	then
		for _, groupName in pairs(aBuffInfo.groups) do
			if 	groupName == "magics" or
				groupName == "diseases" or
				groupName == "poisons" or 
				groupName == "stackablemagics"
			then
				return true, nil, true
			end
		end		
	end
	
	if aBuffInfo.isPositive and 
	(self.settings.checkEnemyCleanable or (self.settings.checkEnemyCleanableUnk and aBuffInfo.ownerId and object.IsExist(aBuffInfo.ownerId) and object.IsEnemy(aBuffInfo.ownerId))) 
	then
		for _, groupName in pairs(aBuffInfo.groups) do
			if 	groupName == "magics" or 
				groupName == "stackablemagics"
			then
				return true, nil, true
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
				return true
			end
		end					
	end
	
	if self.settings.checkMovementsButton and not aBuffInfo.isPositive then
		for _, groupName in pairs(aBuffInfo.groups) do
			if 	groupName == "movementimpairing"
			then
				return true
			end
		end					
	end
	
	if self.treeCustomCreated then
		local searchRes = self.avlCustomTree:get(aBuffInfo)

		if searchRes ~= nil then
			if searchRes.castByMe then 
				if aBuffInfo.producer and g_myAvatarID == aBuffInfo.producer.casterId then
					return true, searchRes
				end
				return false
			end
			return true, searchRes
		end
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
		local buffGroup = {}
		buffGroup = buffPlateSettings
		buffGroup.customBuffs = {}
		if buffPlateSettings.buffs then
			for ind, settingsBuffInfo in pairs(buffPlateSettings.buffs) do
				if settingsBuffInfo.isBuff then
					settingsBuffInfo.ind = ind
					table.insert(buffGroup.customBuffs, settingsBuffInfo)
				end
			end
			m_buffPlateConditionArr[i] = copyTable(BuffCondition)
			m_buffPlateConditionArr[i]:Init(buffGroup)
			
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