Global( "PlayerBuffs", {} )


function PlayerBuffs:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.ignoreRaidBuffsID = {}
	self.ignoreTargeterBuffsID = {}
	self.ignorePlateBuffsID = {}
	self.updateCnt = 0
	
	self.readAllBuffPlatesEventFunc = self:GetReadAllBuffPlatesEventFunc()
	self.readAllRaidEventFunc = self:GetReadAllRaidEventFunc()
	self.readAllTargetEventFunc = self:GetReadAllTargetEventFunc()
	self.readAllAboveHeadEventFunc = self:GetReadAllAboveHeadEventFunc()
	self.delEventFunc = self:GetDelEventFunc()
	self.addEventFunc = self:GetAddEventFunc()
	self.changeEventFunc = self:GetChangedEventFunc()

	self.base = copyTable(PlayerBase)
	self.base:Init()

	self:RegisterEvent(anID)
end

function PlayerBuffs:ClearLastValues()
	self.updateCnt = 0
	self.ignoreRaidBuffsID = {}
	self.ignoreTargeterBuffsID = {}
	self.ignorePlateBuffsID = {}
	self.ignoreAboveHeadBuffsID = {}
end

function PlayerBuffs:SubscribeTargetGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeTargetGui(self.playerID, aLitener, self.readAllTargetEventFunc)
end

function PlayerBuffs:UnsubscribeTargetGui()
	self.base:UnsubscribeTargetGui()
end

function PlayerBuffs:SubscribeRaidGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeRaidGui(self.playerID, aLitener, self.readAllRaidEventFunc)
end

function PlayerBuffs:UnsubscribeRaidGui()
	self.base:UnsubscribeRaidGui()
end

function PlayerBuffs:SubscribeAboveHeadGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeAboveHeadGui(self.playerID, aLitener, self.readAllAboveHeadEventFunc)
end

function PlayerBuffs:UnsubscribeAboveHeadGui()
	self.base:UnsubscribeAboveHeadGui()
end

function PlayerBuffs:SubscribeBuffPlateGui(aLiteners)
	self:ClearLastValues()
	self.base:SubscribeBuffPlateGui(self.playerID, aLiteners, self.readAllBuffPlatesEventFunc)
end

function PlayerBuffs:UnsubscribeBuffPlateGui()
	self.base:UnsubscribeBuffPlateGui()
end


function PlayerBuffs:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerBuffs:UpdateValueIfNeeded()
	self.updateCnt = self.updateCnt + 1
	if self.updateCnt == 3000 then
		self:ClearLastValues()
	end
	for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
		buffPlate.listenerUpdateTick(buffPlate)
	end
	if self.base.guiAboveHeadListener then
		self.base.guiAboveHeadListener.listenerUpdateTick(self.base.guiAboveHeadListener)
	end
end

function PlayerBuffs:InitIgnorePlatesBuffsList(anIndex)
	if not self.ignorePlateBuffsID[anIndex] then
		self.ignorePlateBuffsID[anIndex] = {}
	end
end

function PlayerBuffs:CallListenerIfNeeded(aBuffID, aListener, aCondition, aRaidType, anIgnoreBuffsList)
	if aListener and not anIgnoreBuffsList[aBuffID] then
		local buffInfo = aBuffID and object.GetBuffInfo(aBuffID)
		if buffInfo and buffInfo.name then
			if aCondition:IsImportant(buffInfo) then
				aListener.listenerChangeImportantBuff(buffInfo, aListener)
			end
			local searchResult, findedObj, cleanableBuff = aCondition:Check(buffInfo)
			if searchResult then
				buffInfo.cleanableBuff = cleanableBuff
				if aRaidType then
					if buffInfo.isPositive then
						aListener.listenerChangeBuff(buffInfo, aListener)
					else
						aListener.listenerChangeBuffNegative(buffInfo, aListener)
					end
				else
					aListener.listenerChangeBuffNegative(buffInfo, aListener, findedObj and findedObj.ind or nil)
				end
			else
				anIgnoreBuffsList[aBuffID] = true
			end
		end
	end
end

function PlayerBuffs:GetReadAllEventFunc(aParams, aListener, aCondition, aRaidType, anIgnoreBuffsList)
	if aListener and aCondition then
		--local unitBuffs = object.GetBuffs(aParams.unitId)
		local unitBuffs = object.GetBuffsWithProperties(aParams.unitId, true, true)
		for i, buffID in pairs(unitBuffs) do
			self:CallListenerIfNeeded(buffID, aListener, aCondition, aRaidType, anIgnoreBuffsList)
		end
		unitBuffs = object.GetBuffsWithProperties(aParams.unitId, false, true)
		for i, buffID in pairs(unitBuffs) do
			self:CallListenerIfNeeded(buffID, aListener, aCondition, aRaidType, anIgnoreBuffsList)
		end
	end
end

function PlayerBuffs:GetReadAllRaidEventFunc()
	return function(aParams)
		self:GetReadAllEventFunc(aParams, self.base.guiRaidListener, GetBuffConditionForRaid(), true, self.ignoreRaidBuffsID)
	end
end

function PlayerBuffs:GetReadAllTargetEventFunc()
	return function(aParams)
		local profile = GetCurrentProfile()
		local asRaid = profile.targeterFormSettings.separateBuffDebuff
		self:GetReadAllEventFunc(aParams, self.base.guiTargetListener, GetBuffConditionForTargeter(), asRaid, self.ignoreTargeterBuffsID)
	end
end

function PlayerBuffs:GetReadAllBuffPlatesEventFunc()
	return function(aParams)
		for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
			self:InitIgnorePlatesBuffsList(i)
			self:GetReadAllEventFunc(aParams, buffPlate, GetBuffConditionForBuffPlate(i), false, self.ignorePlateBuffsID[i])
		end
	end
end

function PlayerBuffs:GetReadAllAboveHeadEventFunc()
	return function(aParams)
		--LogInfo("GetReadAllAboveHeadEventFunc ", self.playerID)
		self:GetReadAllEventFunc(aParams, self.base.guiAboveHeadListener, GetBuffConditionForAboveHead(), false, self.ignoreAboveHeadBuffsID)
		--LogInfo("GetReadAllAboveHeadEventFunc end")
	end
end

function PlayerBuffs:GetAddEventFunc()
	return function(aParams)
		local profile = GetCurrentProfile()
		local asRaid = profile.targeterFormSettings.separateBuffDebuff
		
		self:CallListenerIfNeeded(aParams.buffId, self.base.guiRaidListener, GetBuffConditionForRaid(), true, self.ignoreRaidBuffsID)
		self:CallListenerIfNeeded(aParams.buffId, self.base.guiTargetListener, GetBuffConditionForTargeter(), asRaid, self.ignoreTargeterBuffsID)
		
		for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
			self:InitIgnorePlatesBuffsList(i)
			self:CallListenerIfNeeded(aParams.buffId, buffPlate, GetBuffConditionForBuffPlate(i), false, self.ignorePlateBuffsID[i])
		end
		
		self:CallListenerIfNeeded(aParams.buffId, self.base.guiAboveHeadListener, GetBuffConditionForAboveHead(), false, self.ignoreAboveHeadBuffsID)
	end
end

function PlayerBuffs:GetDelEventFunc()
	return function(aParams)
		if self.base.guiRaidListener then
			self.base.guiRaidListener.listenerRemoveBuff(aParams.buffId, self.base.guiRaidListener)
			self.base.guiRaidListener.listenerRemoveBuffNegative(aParams.buffId, self.base.guiRaidListener)
			self.base.guiRaidListener.listenerRemoveImportantBuff(aParams.buffId, self.base.guiRaidListener)
		end
		local profile = GetCurrentProfile()
		local asRaid = profile.targeterFormSettings.separateBuffDebuff
		if self.base.guiTargetListener then
			if asRaid then
				self.base.guiTargetListener.listenerRemoveBuff(aParams.buffId, self.base.guiTargetListener)
			end
			self.base.guiTargetListener.listenerRemoveBuffNegative(aParams.buffId, self.base.guiTargetListener)
		end
		
		for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
			buffPlate.listenerRemoveBuffNegative(aParams.buffId, buffPlate)
		end
		if self.base.guiAboveHeadListener then
			self.base.guiAboveHeadListener.listenerRemoveBuffNegative(aParams.buffId, self.base.guiAboveHeadListener)
		end
	end
end

function PlayerBuffs:GetChangedEventFunc()
	return function(aParams)
		local profile = GetCurrentProfile()
		local asRaid = profile.targeterFormSettings.separateBuffDebuff
		
		self:CallListenerIfNeeded(aParams, self.base.guiRaidListener, GetBuffConditionForRaid(), true, self.ignoreRaidBuffsID)
		self:CallListenerIfNeeded(aParams, self.base.guiTargetListener, GetBuffConditionForTargeter(), asRaid, self.ignoreTargeterBuffsID)
		
		for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
			self:InitIgnorePlatesBuffsList(i)
			self:CallListenerIfNeeded(aParams, buffPlate, GetBuffConditionForBuffPlate(i), false, self.ignorePlateBuffsID[i])
		end
		self:CallListenerIfNeeded(aParams, self.base.guiAboveHeadListener, GetBuffConditionForAboveHead(), false, self.ignoreAboveHeadBuffsID)
	end
end

function PlayerBuffs:RegisterEvent(anID)
	self.unitParams.objectId = anID

	common.RegisterEventHandler(self.addEventFunc, 'EVENT_OBJECT_BUFF_ADDED', self.unitParams)
	common.RegisterEventHandler(self.delEventFunc, 'EVENT_OBJECT_BUFF_REMOVED', self.unitParams)
	if g_debugSubsrb then
		self.base:reg("buff")
		self.base:reg("buff")
	end
end

function PlayerBuffs:UnRegisterEvent()
	common.UnRegisterEventHandler(self.addEventFunc, 'EVENT_OBJECT_BUFF_ADDED', self.unitParams)
	common.UnRegisterEventHandler(self.delEventFunc, 'EVENT_OBJECT_BUFF_REMOVED', self.unitParams)
	
	if g_debugSubsrb then
		self.base:unreg("buff")
		self.base:unreg("buff")
	end
end