Global( "PlayerHP", {} )

local cachedGetHealthInfo = object.GetHealthInfo
local cachedRegisterEventHandler = common.RegisterEventHandler
local cachedUnRegisterEventHandler = common.UnRegisterEventHandler

function PlayerHP:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.objParams = {}
	self.shield = 0
	self.hp = 0
	self.lastShield = -1
	self.lastHP = -1
	--PlayerWounds.lua не достаточно, тк EVENT_UNIT_WOUNDS_COMPLEXITY_CHANGED не приходит на руническое проклятье и тд
	self.woundsComplexity = 0
	self.lastWoundsComplexity = -1
	self.eventFunc = self:GetEventFunc()
	
	self.base = copyTable(PlayerBase)
	self.base:Init()
	
	self:RegisterEvent(anID)
end

function PlayerHP:ClearLastValues()
	self.lastHP = -1
	self.lastShield = -1
	self.lastWoundsComplexity = -1
end

function PlayerHP:SubscribeTargetGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeTargetGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerHP:UnsubscribeTargetGui()
	self.base:UnsubscribeTargetGui()
end

function PlayerHP:SubscribeRaidGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeRaidGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerHP:UnsubscribeRaidGui()
	self.base:UnsubscribeRaidGui()
end

function PlayerHP:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerHP:UpdateValueIfNeeded()
end

function PlayerHP:UpdateValueIfNeededInternal()
	local res = nil
	local profile = GetCurrentProfile()
	
	if self.shield ~= self.lastShield then
		self.lastShield = self.shield

		res = profile.raidFormSettings.showShieldButton and self.base.guiRaidListener and self.base.guiRaidListener.listenerShield(self.shield, self.base.guiRaidListener)
		res = profile.targeterFormSettings.showShieldButton and self.base.guiTargetListener and self.base.guiTargetListener.listenerShield(self.shield, self.base.guiTargetListener)
	end
	
	if self.hp ~= self.lastHP then
		self.lastHP = self.hp
		res = self.base.guiRaidListener and self.base.guiRaidListener.listenerHP(self.hp, self.base.guiRaidListener)
		res = self.base.guiTargetListener and self.base.guiTargetListener.listenerHP(self.hp, self.base.guiTargetListener)

		
		if profile.raidFormSettings.woundsShowButton or profile.targeterFormSettings.woundsShowButton then
			self.woundsComplexity = 100*(1-1/((1+unit.GetRuneWoundsComplexity(self.playerID)/10)*(unit.GetRelativeWoundsComplexity(self.playerID)))) or 0
			if self.hp == 100 then
				self.woundsComplexity = 0
			end
			if self.woundsComplexity ~= self.lastWoundsComplexity then
				self.lastWoundsComplexity = self.woundsComplexity
				res = profile.raidFormSettings.woundsShowButton and self.base.guiRaidListener and self.base.guiRaidListener.listenerWounds(self.woundsComplexity, self.base.guiRaidListener)
				res = profile.targeterFormSettings.woundsShowButton and self.base.guiTargetListener and self.base.guiTargetListener.listenerWounds(self.woundsComplexity, self.base.guiTargetListener)
			end
		end
	end
end

function PlayerHP:GetEventFunc()
	return function(aParams)
		local playerID = aParams.unitId or aParams.id
		if isExist(playerID) then
			local healthInfo = cachedGetHealthInfo(playerID)
			self.shield = healthInfo and healthInfo.additionalPercents 
			self.hp = healthInfo and healthInfo.valuePercents
			
			self:UpdateValueIfNeededInternal()
		end
	end
end

function PlayerHP:RegisterEvent(anID)
	self.unitParams.unitId = anID
	cachedRegisterEventHandler(self.eventFunc, "EVENT_UNIT_HEALTH_CHANGED", self.unitParams)
	self.objParams.id = anID
	cachedRegisterEventHandler(self.eventFunc, "EVENT_OBJECT_HEALTH_CHANGED", self.objParams)
	if g_debugSubsrb then
		self.base:reg("hp")
		self.base:reg("hp")
	end
end

function PlayerHP:UnRegisterEvent()
	cachedUnRegisterEventHandler(self.eventFunc, "EVENT_UNIT_HEALTH_CHANGED", self.unitParams)
	cachedUnRegisterEventHandler(self.eventFunc, "EVENT_OBJECT_HEALTH_CHANGED", self.objParams)
	if g_debugSubsrb then
		self.base:unreg("hp")
		self.base:unreg("hp")
	end
end