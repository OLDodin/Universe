Global( "PlayerSpells", {} )


function PlayerSpells:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.ignoreSpellID = {}

	self.updateCnt = 0
	
	self.changedEventFunc = self:GetChangedEventFunc()
	self.readAllSpellEventFunc = self:GetReadAllSpellEventFunc()

	self.base = copyTable(PlayerBase)
	self.base:Init()

	self:RegisterEvent(anID)
end

function PlayerSpells:ClearLastValues()
	self.updateCnt = 0
	self.ignoreSpellID = {}
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
	if self.updateCnt == 3000 then
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

function PlayerSpells:CallListenerIfNeeded(aSpellID, aListener, aCondition, anIgnoreBuffsList)
	if aListener and aCondition:HasCondtion() then
		local spellInfo = aSpellID and spellLib.GetDescription(aSpellID)
		--LogInfo("sp GetChangedEventFunc ", spellInfo.name, " ", spellInfo.objectId)
		if spellInfo and not anIgnoreBuffsList[spellInfo.objectId] and spellInfo.name then
			spellInfo.spellID = aSpellID
			local searchResult, findedObj = aCondition:Check(spellInfo)
			if searchResult then
				aListener.listenerSpellChanged(spellInfo, aListener, findedObj and findedObj.ind or nil)
			else
				anIgnoreBuffsList[spellInfo.objectId] = true
			end
		end
	end
end


function PlayerSpells:GetReadAllSpellEventFunc()
	return function(aParams)
		local spellbook = avatar.GetSpellBook()
		if spellbook then
			for _, spellID in pairs(spellbook) do
				for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
					self:InitIgnorePlatesBuffsList(i)
					self:CallListenerIfNeeded(spellID, buffPlate, GetSpellConditionForBuffPlate(i), self.ignoreSpellID[i])
				end		
			end
		end
	end
end

function PlayerSpells:GetChangedEventFunc()
	return function(aParams)	
		if aParams.effect == EFFECT_TYPE_COOLDOWN_STARTED or aParams.effect == EFFECT_TYPE_COOLDOWN_FINISHED then
			for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
				self:InitIgnorePlatesBuffsList(i)
				self:CallListenerIfNeeded(aParams.id, buffPlate, GetSpellConditionForBuffPlate(i), self.ignoreSpellID[i])
			end		
		end
	end
end

function PlayerSpells:GetSpellbookChangedEventFunc()
	return function(aParams)	

	end
end

function PlayerSpells:RegisterEvent()
	common.RegisterEventHandler(self.changedEventFunc, 'EVENT_SPELLBOOK_ELEMENT_EFFECT')

end

function PlayerSpells:UnRegisterEvent()
	common.UnRegisterEventHandler(self.changedEventFunc, 'EVENT_SPELLBOOK_ELEMENT_EFFECT')

end