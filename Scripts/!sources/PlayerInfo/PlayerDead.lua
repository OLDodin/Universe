Global( "PlayerDead", {} )

local cachedIsDead = object.IsDead

function PlayerDead:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.isDead = 0
	self.lastDead = -1
	
	self.eventFunc = self:GetEventFunc()
	
	self.base = copyTable(PlayerBase)
	self.base:Init()
	
	self:RegisterEvent(anID)
end

function PlayerDead:ClearLastValues()
	self.lastDead = -1
end

function PlayerDead:SubscribeTargetGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeTargetGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerDead:UnsubscribeTargetGui()
	self.base:UnsubscribeTargetGui()
end

function PlayerDead:SubscribeRaidGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeRaidGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerDead:UnsubscribeRaidGui()
	self.base:UnsubscribeRaidGui()
end

function PlayerDead:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerDead:UpdateValueIfNeeded()
	if self.isDead ~= self.lastDead then
		self.lastDead = self.isDead
		local res = self.base.guiRaidListener and self.base.guiRaidListener.listenerDead(self.isDead, self.base.guiRaidListener)
		res = self.base.guiTargetListener and self.base.guiTargetListener.listenerDead(self.isDead, self.base.guiTargetListener)
	end
end

function PlayerDead:GetEventFunc()
	return function(aParams)
		self.isDead = isExist(aParams.unitId) and cachedIsDead( aParams.unitId )
		--LogInfo("EVENT_UNIT_MANA_PERCENTAGE_CHANGED ", self.playerID)
	end
end

function PlayerDead:RegisterEvent(anID)
	
end

function PlayerDead:UnRegisterEvent()

end