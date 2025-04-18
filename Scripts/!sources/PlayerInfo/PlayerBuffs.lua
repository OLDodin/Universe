Global( "PlayerBuffs", {} )

local cachedGetBuffInfo = object.GetBuffInfo
local cachedGetBuffs = object.GetBuffs
local cachedRegisterEventHandler = common.RegisterEventHandler
local cachedUnRegisterEventHandler = common.UnRegisterEventHandler
local cachedGetBuffsInfo = object.GetBuffsInfo

function PlayerBuffs:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.ignoreRaidBuffsID = {}
	self.ignoreTargeterBuffsID = {}
	self.ignorePlateBuffsID = {}
	self.ignoreAboveHeadBuffsID = {}
	
	self.workingRaidBuffsID = {}
	self.workingTargeterBuffsID = {}
	self.workingPlateBuffsID = {}
	self.workingAboveHeadBuffsID = {}
	
	self.wasBuffChanges = false
	
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

function PlayerBuffs:ClearRaidBuffsValues()
	self.ignoreRaidBuffsID = {}
	self.workingRaidBuffsID = {}
end

function PlayerBuffs:ClearTargeterBuffsValues()
	self.ignoreTargeterBuffsID = {}
	self.workingTargeterBuffsID = {}
end

function PlayerBuffs:ClearPlateBuffsValues()
	self.ignorePlateBuffsID = {}
	self.workingPlateBuffsID = {}
end

function PlayerBuffs:ClearAboveHeadBuffsValues()
	self.ignoreAboveHeadBuffsID = {}
	self.workingAboveHeadBuffsID = {}
end

function PlayerBuffs:SubscribeTargetGui(aLitener)
	self:ClearTargeterBuffsValues()
	self.base:SubscribeTargetGui(self.playerID, aLitener, self.readAllTargetEventFunc)
end

function PlayerBuffs:UnsubscribeTargetGui()
	self.base:UnsubscribeTargetGui()
end

function PlayerBuffs:SubscribeRaidGui(aLitener)
	self:ClearRaidBuffsValues()
	self.base:SubscribeRaidGui(self.playerID, aLitener, self.readAllRaidEventFunc)
end

function PlayerBuffs:UnsubscribeRaidGui()
	self.base:UnsubscribeRaidGui()
end

function PlayerBuffs:SubscribeAboveHeadGui(aLitener)
	self:ClearAboveHeadBuffsValues()
	self.base:SubscribeAboveHeadGui(self.playerID, aLitener, self.readAllAboveHeadEventFunc)
end

function PlayerBuffs:UnsubscribeAboveHeadGui()
	self.base:UnsubscribeAboveHeadGui()
end

function PlayerBuffs:SubscribeBuffPlateGui(aLiteners)
	self:ClearPlateBuffsValues()
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

local function FindBuffID(aBuffID, aBuffArray)
	for _, buffID in pairs(aBuffArray) do
		if aBuffID == buffID then
			return true
		end
	end
	return false
end

--[[
	затычка - очень редко EVENT_OBJECT_BUFF_REMOVED может не прийти
	сверяем список баффов на объекте
	сам по себе EVENT_OBJECT_BUFF_REMOVED может в ПВП приходить с задержкой относительно 
	изменения списка в GetBuffs
]]
function PlayerBuffs:CheckExist(aWorkingBuffArray, aExistBuffArray)
	local notExistArr = {}
	for buffID, _ in pairs(aWorkingBuffArray) do
		if not FindBuffID(buffID, aExistBuffArray) then
			table.insert(notExistArr, buffID)
		end
	end
	for _, buffID in ipairs(notExistArr) do
		self.delEventFunc( { buffId = buffID } )
	end
end

function PlayerBuffs:UpdateValueIfNeeded()
	if self.wasBuffChanges then
		local currBuffs = cachedGetBuffs(self.playerID)
		
		self:CheckExist(self.workingRaidBuffsID, currBuffs)
		self:CheckExist(self.workingTargeterBuffsID, currBuffs)
		self:CheckExist(self.workingAboveHeadBuffsID, currBuffs)
		for _, plateBuff in pairs(self.workingPlateBuffsID) do
			self:CheckExist(plateBuff, currBuffs)
		end
		
		self.wasBuffChanges = false
	end
	
	for _, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
		buffPlate.listenerUpdateTick(buffPlate)
	end
	if self.base.guiAboveHeadListener then
		self.base.guiAboveHeadListener.listenerUpdateTick(self.base.guiAboveHeadListener)
	end
	if self.base.guiRaidListener then
		self.base.guiRaidListener.listenerUpdateTick(self.base.guiRaidListener)
	end
	if self.base.guiTargetListener then
		self.base.guiTargetListener.listenerUpdateTick(self.base.guiTargetListener)
	end
end

function PlayerBuffs:InitPlatesBuffsList(anIndex)
	if not self.ignorePlateBuffsID[anIndex] then
		self.ignorePlateBuffsID[anIndex] = {}
	end
	if not self.workingPlateBuffsID[anIndex] then
		self.workingPlateBuffsID[anIndex] = {}
	end
end

local function CallAddListenerIfNeeded(aBuffID, aListener, aCondition, aRaidType, anIgnoreBuffsList, aWorkingBuffsList, aBuffInfo)
	if not aListener or anIgnoreBuffsList[aBuffID] then
		return aBuffInfo
	end

	local buffInfo = aBuffInfo or cachedGetBuffInfo(aBuffID)
	if buffInfo and buffInfo.name then
		local ignoreBuff = true
		if aCondition:IsImportant(buffInfo) then
			ignoreBuff = false
			aListener.listenerChangeImportantBuff(buffInfo, aListener)
		end
		local searchResult, findedObj, cleanableBuff = aCondition:Check(buffInfo)
		if searchResult then
			ignoreBuff = false
			if aRaidType and buffInfo.isPositive then
				aListener.listenerAddBuff(buffInfo, aListener, findedObj, cleanableBuff)
			else
				aListener.listenerAddBuffNegative(buffInfo, aListener, findedObj, cleanableBuff)
			end
		end
		if ignoreBuff then
			anIgnoreBuffsList[aBuffID] = true
		else
			aWorkingBuffsList[aBuffID] = true
		end
		return buffInfo
	end

	return aBuffInfo
end

local function ReadAllBuffs(aParams, aListener, aCondition, aRaidType, anIgnoreBuffsList, aWorkingBuffsList)
	if aListener and aCondition then
		local unitBuffs = cachedGetBuffs(aParams.unitId, not aCondition.settings.systemBuffButton)
		if next(unitBuffs) then
			for buffID, buffInfo in pairs(cachedGetBuffsInfo(unitBuffs) or {}) do
				CallAddListenerIfNeeded(buffID, aListener, aCondition, aRaidType, anIgnoreBuffsList, aWorkingBuffsList, buffInfo)
			end
		end
	end
end

function PlayerBuffs:GetReadAllRaidEventFunc()
	return function(aParams)
		ReadAllBuffs(aParams, self.base.guiRaidListener, GetBuffConditionForRaid(), true, self.ignoreRaidBuffsID, self.workingRaidBuffsID)
	end
end

function PlayerBuffs:GetReadAllTargetEventFunc()
	return function(aParams)
		local asRaid = GetCurrentProfile().targeterFormSettings.separateBuffDebuff
		ReadAllBuffs(aParams, self.base.guiTargetListener, GetBuffConditionForTargeter(), asRaid, self.ignoreTargeterBuffsID, self.workingTargeterBuffsID)
	end
end

function PlayerBuffs:GetReadAllBuffPlatesEventFunc()
	return function(aParams)
		for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
			self:InitPlatesBuffsList(i)
			ReadAllBuffs(aParams, buffPlate, GetBuffConditionForBuffPlate(i), false, self.ignorePlateBuffsID[i], self.workingPlateBuffsID[i])
		end
	end
end

function PlayerBuffs:GetReadAllAboveHeadEventFunc()
	return function(aParams)
		ReadAllBuffs(aParams, self.base.guiAboveHeadListener, GetBuffConditionForAboveHead(), false, self.ignoreAboveHeadBuffsID, self.workingAboveHeadBuffsID)
	end
end

function PlayerBuffs:GetAddEventFunc()
	return function(aParams)
		local asRaid = GetCurrentProfile().targeterFormSettings.separateBuffDebuff
		
		self.wasBuffChanges = true
		
		local buffInfo = CallAddListenerIfNeeded(aParams.buffId, self.base.guiRaidListener, GetBuffConditionForRaid(), true, self.ignoreRaidBuffsID, self.workingRaidBuffsID)
		buffInfo = CallAddListenerIfNeeded(aParams.buffId, self.base.guiTargetListener, GetBuffConditionForTargeter(), asRaid, self.ignoreTargeterBuffsID, self.workingTargeterBuffsID, buffInfo)
		
		for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
			self:InitPlatesBuffsList(i)
			buffInfo = CallAddListenerIfNeeded(aParams.buffId, buffPlate, GetBuffConditionForBuffPlate(i), false, self.ignorePlateBuffsID[i], self.workingPlateBuffsID[i], buffInfo)
		end
		
		CallAddListenerIfNeeded(aParams.buffId, self.base.guiAboveHeadListener, GetBuffConditionForAboveHead(), false, self.ignoreAboveHeadBuffsID, self.workingAboveHeadBuffsID, buffInfo)
	end
end

function PlayerBuffs:GetDelEventFunc()
	return function(aParams)
		local buffID = aParams.buffId
		local asRaid = GetCurrentProfile().targeterFormSettings.separateBuffDebuff
		self.wasBuffChanges = true
		
		self.ignoreRaidBuffsID[buffID] = nil
		self.ignoreTargeterBuffsID[buffID] = nil
		self.ignoreAboveHeadBuffsID[buffID] = nil
		for _, plateBuff in pairs(self.ignorePlateBuffsID) do
			plateBuff[buffID] = nil
		end	
		
		if self.base.guiRaidListener and self.workingRaidBuffsID[buffID] then
			self.workingRaidBuffsID[buffID] = nil
			
			self.base.guiRaidListener.listenerRemoveBuff(buffID, self.base.guiRaidListener)
			self.base.guiRaidListener.listenerRemoveBuffNegative(buffID, self.base.guiRaidListener)
			self.base.guiRaidListener.listenerRemoveImportantBuff(buffID, self.base.guiRaidListener)
		end	
		
		if self.base.guiTargetListener and self.workingTargeterBuffsID[buffID] then
			self.workingTargeterBuffsID[buffID] = nil
			
			if asRaid then
				self.base.guiTargetListener.listenerRemoveBuff(buffID, self.base.guiTargetListener)
			end
			self.base.guiTargetListener.listenerRemoveBuffNegative(buffID, self.base.guiTargetListener)
		end
		
		for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
			if self.workingPlateBuffsID[i][buffID] then
				self.workingPlateBuffsID[i][buffID] = nil
				
				buffPlate.listenerRemoveBuffNegative(buffID, buffPlate)
			end
		end
		
		if self.base.guiAboveHeadListener and self.workingAboveHeadBuffsID[buffID] then
			self.workingAboveHeadBuffsID[buffID] = nil
			
			self.base.guiAboveHeadListener.listenerRemoveBuffNegative(buffID, self.base.guiAboveHeadListener)
		end
	end
end

local function CallChangeListenerIfNeeded(aBuffID, aBuffDynamicInfo, aListener, aWorkingBuffsList)
	if aListener and aWorkingBuffsList[aBuffID] then
		aListener.listenerChangeBuff(aBuffID, aBuffDynamicInfo, aListener)
	end
end

function PlayerBuffs:GetChangedEventFunc()
	return function(aBuffID)	
		self.wasBuffChanges = true
		
		local buffDynamicInfo = object.GetBuffDynamicInfo(aBuffID)
		if not buffDynamicInfo then
			return
		end
		CallChangeListenerIfNeeded(aBuffID, buffDynamicInfo, self.base.guiRaidListener, self.workingRaidBuffsID)
		CallChangeListenerIfNeeded(aBuffID, buffDynamicInfo, self.base.guiTargetListener, self.workingTargeterBuffsID)
		
		for i, buffPlate in pairs(self.base.guiBuffPlatesListeners) do
			self:InitPlatesBuffsList(i)
			CallChangeListenerIfNeeded(aBuffID, buffDynamicInfo, buffPlate, self.workingPlateBuffsID[i])
		end
		CallChangeListenerIfNeeded(aBuffID, buffDynamicInfo, self.base.guiAboveHeadListener, self.workingAboveHeadBuffsID)
	end
end

function PlayerBuffs:RegisterEvent(anID)
	self.unitParams.objectId = anID

	cachedRegisterEventHandler(self.addEventFunc, 'EVENT_OBJECT_BUFF_ADDED', self.unitParams)
	cachedRegisterEventHandler(self.delEventFunc, 'EVENT_OBJECT_BUFF_REMOVED', self.unitParams)
	if g_debugSubsrb then
		self.base:reg("buff")
		self.base:reg("buff")
	end
end

function PlayerBuffs:UnRegisterEvent()
	cachedUnRegisterEventHandler(self.addEventFunc, 'EVENT_OBJECT_BUFF_ADDED', self.unitParams)
	cachedUnRegisterEventHandler(self.delEventFunc, 'EVENT_OBJECT_BUFF_REMOVED', self.unitParams)
	
	if g_debugSubsrb then
		self.base:unreg("buff")
		self.base:unreg("buff")
	end
end