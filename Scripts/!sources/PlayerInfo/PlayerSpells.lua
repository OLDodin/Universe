Global( "PlayerSpells", {} )

local cachedGetDescription = spellLib.GetDescription
local cachedGetRequirements = spellLib.GetRequirements
local cachedGetCooldown = spellLib.GetCooldown
local cachedRegisterEventHandler = common.RegisterEventHandler
local cachedUnRegisterEventHandler = common.UnRegisterEventHandler

function PlayerSpells:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.ignoreSpellID = {}
	self.spellNameDuplicates = {}
	self.notifiedDuplSpells = {}
	self.ignoredDuplSpells = {}
	
	self.updateCnt = 0
	
	self.changedEventFunc = self:GetChangedEventFunc()
	self.readAllSpellEventFunc = self:GetReadAllSpellEventFunc()
	self.avatarClassFormChangedEventFunc = self:GetAvatarClassFormChangedEventFunc()

	self.base = copyTable(PlayerBase)
	self.base:Init()

	self:RegisterEvent(anID)
end

function PlayerSpells:ClearLastValues()
	self.updateCnt = 0
	self.ignoreSpellID = {}
	self.spellNameDuplicates = {}
	self.notifiedDuplSpells = {}
	self.ignoredDuplSpells = {}
end

function PlayerSpells:SubscribeTargetGui(aLitener)
end

function PlayerSpells:UnsubscribeTargetGui()
end

function PlayerSpells:SubscribeRaidGui(aLitener)
end

function PlayerSpells:UnsubscribeRaidGui()
end

function PlayerSpells:SubscribeAboveHeadGui(aLitener)
end

function PlayerSpells:UnsubscribeAboveHeadGui()
end

function PlayerSpells:SubscribeBuffPlateGui(aLiteners)
	self:ClearLastValues()
	self:BuildSpellDuplicatesList()
	self.base:SubscribeBuffPlateGui(self.playerID, aLiteners, self.readAllSpellEventFunc)
end

function PlayerSpells:UnsubscribeBuffPlateGui()
	self.base:UnsubscribeBuffPlateGui()
end


function PlayerSpells:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerSpells:UpdateValueIfNeeded()
	self.updateCnt = self.updateCnt + 1
	if self.updateCnt == 18000 then
		self:ClearLastValues()
	end
	for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
		buffPlate.listenerUpdateTick(buffPlate)
	end

end

function PlayerSpells:InitIgnorePlatesBuffsList(anIndex)
	if not self.ignoreSpellID[anIndex] then
		self.ignoreSpellID[anIndex] = {}
	end
end

function PlayerSpells:GetConditionForBuffPlate(anIndex)	
	local condition = GetSpellConditionForBuffPlate(anIndex)
	if condition and condition:HasCondtion() then
		return condition
	end
end

function PlayerSpells:FindInIgnore(aSpellID, anIgnoreBuffsList)
	for _, spellID in pairs(anIgnoreBuffsList) do
		if spellID:IsEqual(aSpellID) then
			return true
		end
	end
	return false
end

function PlayerSpells:CallListenerIfNeeded(aSpellID, aRemainingMs, aListener, aCondition, anIgnoreBuffsList, aForceReadCooldawn)
	if aListener and aCondition:HasCondtion() then
		if aSpellID and not self:FindInIgnore(aSpellID, anIgnoreBuffsList) then
			local spellInfo = aSpellID and cachedGetDescription(aSpellID)
			--LogInfo("sp GetChangedEventFunc ", spellInfo.name, " ", spellInfo.objectId, " desc = ", spellInfo.description:ToWString())

			if spellInfo and spellInfo.name then
				spellInfo.spellID = aSpellID
				local searchResult, findedObj = aCondition:Check(spellInfo)
				if searchResult then
					if self.ignoredDuplSpells[spellInfo.objectId] then
						return
					end
					if self.spellNameDuplicates[spellInfo.objectId] then
						local spellReq = cachedGetRequirements(aSpellID)
						if spellReq and spellReq.casterConditions then
							for _, req in pairs(spellReq.casterConditions) do
								if not req.success then
									self.ignoredDuplSpells[spellInfo.objectId] = true
									return
								end
							end
						end
						self.notifiedDuplSpells[spellInfo.objectId] = true
					end
					if aRemainingMs then
						spellInfo.remainingMs = aRemainingMs
					else
						if aForceReadCooldawn then
							local spellCooldown = cachedGetCooldown(aSpellID)
							if spellCooldown then
								spellInfo.remainingMs = spellCooldown.remainingMs
							else
								spellInfo.remainingMs = 0
							end
						else
							spellInfo.remainingMs = 0
						end
					end
	
					aListener.listenerSpellChanged(spellInfo, aListener, findedObj)
				else
					table.insert(anIgnoreBuffsList, aSpellID)
				end
			end
		end
	end
end


function PlayerSpells:GetReadAllSpellEventFunc()
	return function(aParams)
		local spellbook = avatar.GetSpellBook()
		if spellbook then
			for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
				local condition = self:GetConditionForBuffPlate(i)
				if condition then
					for _, spellID in pairs(spellbook) do
						self:InitIgnorePlatesBuffsList(i)
						self:CallListenerIfNeeded(spellID, nil, buffPlate, condition, self.ignoreSpellID[i], true)
					end
				end
			end					
		end
	end
end

function PlayerSpells:GetChangedEventFunc()
	return function(aParams)	
		if aParams.effect == EFFECT_TYPE_COOLDOWN_STARTED or aParams.effect == EFFECT_TYPE_COOLDOWN_FINISHED then
			for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
				local condition = self:GetConditionForBuffPlate(i)
				if condition then
					self:InitIgnorePlatesBuffsList(i)
					self:CallListenerIfNeeded(aParams.id, aParams.remaining, buffPlate, condition, self.ignoreSpellID[i], aParams.effect == EFFECT_TYPE_COOLDOWN_STARTED)
				end
			end		
		end
	end
end

function PlayerSpells:GetSpellbookChangedEventFunc()
	return function(aParams)	

	end
end

function PlayerSpells:GetAvatarClassFormChangedEventFunc()
	return function(aParams)	
		for idOfDupl, _ in pairs(self.notifiedDuplSpells) do
			for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
				local condition = self:GetConditionForBuffPlate(i)
				if condition then
					buffPlate.listenerSpellRemoved(idOfDupl, buffPlate)
				end
			end	
		end
		self.notifiedDuplSpells = {}
		self.ignoredDuplSpells = {}
		self.readAllSpellEventFunc()
	end
end

function PlayerSpells:BuildSpellDuplicatesList()
	local playerClass = unit.GetClass(g_myAvatarID)
	if playerClass and playerClass.className == "WARLOCK" then
		self.spellNameDuplicates = {}
		local spellInfoList = {}
		local spellbook = avatar.GetSpellBook()
		if spellbook then
			for _, spellID in pairs(spellbook) do
				local spellInfo = spellID and cachedGetDescription(spellID)
				if spellInfo and spellInfo.name then
					local duplicate = false
					for _, info in ipairs(spellInfoList) do
						if info.name == spellInfo.name then
							duplicate = true
							self.spellNameDuplicates[spellInfo.objectId] = spellInfo.name
							self.spellNameDuplicates[info.objectId] = spellInfo.name
							break
						end
					end
					table.insert(spellInfoList, spellInfo)
				end
			end
		end
	end
end

function PlayerSpells:RegisterEvent()
	cachedRegisterEventHandler(self.changedEventFunc, 'EVENT_SPELLBOOK_ELEMENT_EFFECT')

end

function PlayerSpells:UnRegisterEvent()
	cachedUnRegisterEventHandler(self.changedEventFunc, 'EVENT_SPELLBOOK_ELEMENT_EFFECT')
end