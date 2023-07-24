Global( "PlayerMana", {} )

local cachedGetManaPercentage = unit.GetManaPercentage
local cachedRegisterEventHandler = common.RegisterEventHandler
local cachedUnRegisterEventHandler = common.UnRegisterEventHandler

function PlayerMana:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.mana = 0
	self.lastMana = -1
	
	self.eventFunc = self:GetEventFunc()
	
	self.base = copyTable(PlayerBase)
	self.base:Init()
	
	self:RegisterEvent(anID)
end

function PlayerMana:ClearLastValues()
	self.lastMana = -1
end

function PlayerMana:SubscribeTargetGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeTargetGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerMana:UnsubscribeTargetGui()
	self.base:UnsubscribeTargetGui()
end

function PlayerMana:SubscribeRaidGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeRaidGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerMana:UnsubscribeRaidGui()
	self.base:UnsubscribeRaidGui()
end

function PlayerMana:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerMana:UpdateValueIfNeeded()
end

function PlayerMana:UpdateValueIfNeededInternal()
	if self.mana ~= self.lastMana then
		self.lastMana = self.mana
		local res = self.base.guiRaidListener and self.base.guiRaidListener.listenerMana(self.mana, self.base.guiRaidListener)
		res = self.base.guiTargetListener and self.base.guiTargetListener.listenerMana(self.mana, self.base.guiTargetListener)
	end
end

function PlayerMana:GetEventFunc()
	return function(aParams)
		self.mana = cachedGetManaPercentage( aParams.unitId )
		self:UpdateValueIfNeededInternal()
	end
end

function PlayerMana:RegisterEvent(anID)
	self.unitParams.unitId = anID
	cachedRegisterEventHandler(self.eventFunc, "EVENT_UNIT_MANA_PERCENTAGE_CHANGED", self.unitParams)
	if g_debugSubsrb then
		self.base:reg("mana")
	end
end

function PlayerMana:UnRegisterEvent()
	cachedUnRegisterEventHandler(self.eventFunc, "EVENT_UNIT_MANA_PERCENTAGE_CHANGED", self.unitParams)
	if g_debugSubsrb then
		self.base:unreg("mana")
	end
end