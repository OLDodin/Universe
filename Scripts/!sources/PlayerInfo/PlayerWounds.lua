Global( "PlayerWounds", {} )

local cachedGetRuneWoundsComplexity = unit.GetRuneWoundsComplexity
local cachedGetRelativeWoundsComplexity = unit.GetRelativeWoundsComplexity

function PlayerWounds:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.woundsComplexity = 0
	self.lastWoundsComplexity = -1
		
	self.eventFunc = self:GetEventFunc()
	
	self.base = copyTable(PlayerBase)
	self.base:Init()
	
	self:RegisterEvent(anID)
end

function PlayerWounds:ClearLastValues()
	self.lastWoundsComplexity = -1
end

function PlayerWounds:SubscribeTargetGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeTargetGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerWounds:UnsubscribeTargetGui()
	self.base:UnsubscribeTargetGui()
end

function PlayerWounds:SubscribeRaidGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeRaidGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerWounds:UnsubscribeRaidGui()
	self.base:UnsubscribeRaidGui()
end

function PlayerWounds:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerWounds:UpdateValueIfNeeded()
	local res = nil
	if self.woundsComplexity ~= self.lastWoundsComplexity then
		self.lastWoundsComplexity = self.woundsComplexity
		res = self.base.guiRaidListener and self.base.guiRaidListener.listenerWounds(self.woundsComplexity, self.base.guiRaidListener)
		res = self.base.guiTargetListener and self.base.guiTargetListener.listenerWounds(self.woundsComplexity, self.base.guiTargetListener)
	end
end

function PlayerWounds:GetEventFunc()
	return function(aParams)
		self.woundsComplexity = 100*(1-1/((1+cachedGetRuneWoundsComplexity(aParams.unitId)/10)*(cachedGetRelativeWoundsComplexity(aParams.unitId)))) or 0
		--LogInfo("EVENT_UNIT_WOUNDS_COMPLEXITY_CHANGED ", self.woundsComplexity)
	end
end

function PlayerWounds:RegisterEvent(anID)

end

function PlayerWounds:UnRegisterEvent()

end