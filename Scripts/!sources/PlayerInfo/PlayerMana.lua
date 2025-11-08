Global( "PlayerMana", {} )

local cachedGetManaPercentage = unit.GetManaPercentage
local cachedEnablePersonalEvent = common.EnablePersonalEvent
local cachedDisablePersonalEvent = common.DisablePersonalEvent

function PlayerMana:Init(anID)
	self.playerID = anID
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

function PlayerMana:SubscribeByType(aType, aLitener)
	if aType == enumSubscribeType.Raid then
		self:ClearLastValues()
		self.base:SubscribeRaidGui(self.playerID, aLitener, self.eventFunc)
	elseif aType == enumSubscribeType.Targeter then
		self:ClearLastValues()
		self.base:SubscribeTargetGui(self.playerID, aLitener, self.eventFunc)
	end
end

function PlayerMana:UnsubscribeByType(aType)
	if aType == enumSubscribeType.Raid then
		self.base:UnsubscribeRaidGui()
	elseif aType == enumSubscribeType.Targeter then
		self.base:UnsubscribeTargetGui()
	end
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
	cachedEnablePersonalEvent("EVENT_UNIT_MANA_PERCENTAGE_CHANGED", anID)
	
	if g_debugSubsrb then
		self.base:reg("mana")
	end
end

function PlayerMana:UnRegisterEvent()
	cachedDisablePersonalEvent("EVENT_UNIT_MANA_PERCENTAGE_CHANGED", self.playerID)

	if g_debugSubsrb then
		self.base:unreg("mana")
	end
end