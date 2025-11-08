Global( "PlayerCanSelect", {} )

local cachedCanSelectTarget = unit.CanSelectTarget

function PlayerCanSelect:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.canSelect = true
	self.lastCanSelect = -1
	
	self.eventFunc = self:GetEventFunc()
	
	self.base = copyTable(PlayerBase)
	self.base:Init()
	
	self:RegisterEvent(anID)
end

function PlayerCanSelect:ClearLastValues()
	self.lastCanSelect = -1
end

function PlayerCanSelect:SubscribeByType(aType, aLitener)
	if aType == enumSubscribeType.Raid then
		self:ClearLastValues()
		self.base:SubscribeRaidGui(self.playerID, aLitener, self.eventFunc)
	elseif aType == enumSubscribeType.Targeter then
		self:ClearLastValues()
		self.base:SubscribeTargetGui(self.playerID, aLitener, self.eventFunc)
	end
end

function PlayerCanSelect:UnsubscribeByType(aType)
	if aType == enumSubscribeType.Raid then
		self.base:UnsubscribeRaidGui()
	elseif aType == enumSubscribeType.Targeter then
		self.base:UnsubscribeTargetGui()
	end
end

function PlayerCanSelect:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerCanSelect:UpdateValueIfNeeded()
end

function PlayerCanSelect:UpdateValueIfNeededInternal()
	self.canSelect = cachedCanSelectTarget(self.playerID)
	if self.lastCanSelect ~= self.canSelect then
		self.lastCanSelect = self.canSelect
		local res = self.base.guiTargetListener and self.base.guiTargetListener.listenerCanSelect(self.canSelect, self.base.guiTargetListener)
		res = self.base.guiRaidListener and self.base.guiRaidListener.listenerCanSelect(self.canSelect, self.base.guiRaidListener)
	end
end

function PlayerCanSelect:GetEventFunc()
	return function(aParams)
		local playerID = aParams.unitId or aParams.objectId
		self:UpdateValueIfNeededInternal()
		--LogInfo("SELECTABLE_CHANGED ", playerID, " canselect = ", cachedCanSelectTarget(playerID))
	end
end

function PlayerCanSelect:RegisterEvent(anID)
end

function PlayerCanSelect:UnRegisterEvent()
end