Global( "PlayerAFK", {} )

local cachedIsPlayer = unit.IsPlayer
local cachedIsAfk = unit.IsAfk

function PlayerAFK:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.isAfk = false
	self.lastAfk = -1
	
	self.eventFunc = self:GetEventFunc()
	
	self.base = copyTable(PlayerBase)
	self.base:Init()
	
	self:RegisterEvent(anID)
end

function PlayerAFK:ClearLastValues()
	self.lastAfk = -1
end

function PlayerAFK:SubscribeTargetGui(aLitener)
--	self:ClearLastValues()
--	self.base:SubscribeTargetGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerAFK:UnsubscribeTargetGui()
--	self.base:UnsubscribeTargetGui()
end

function PlayerAFK:SubscribeRaidGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeRaidGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerAFK:UnsubscribeRaidGui()
	self.base:UnsubscribeRaidGui()
end

function PlayerAFK:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerAFK:UpdateValueIfNeeded()
	if self.isAfk ~= self.lastAfk then
		self.lastAfk = self.isAfk
		local res = self.base.guiRaidListener and self.base.guiRaidListener.listenerAfk(self.isAfk, self.base.guiRaidListener)
		res = self.base.guiTargetListener and self.base.guiTargetListener.listenerAfk(self.isAfk, self.base.guiTargetListener)
	end
end

function PlayerAFK:GetEventFunc()
	return function(aParams)
		self.isAfk = aParams.isAfk
		if aParams.isAfk == nil and aParams.unitId and isExist(aParams.unitId) and cachedIsPlayer(aParams.unitId) then
			self.isAfk = cachedIsAfk(aParams.unitId)
		end
	end
end

function PlayerAFK:RegisterEvent(anID)

end

function PlayerAFK:UnRegisterEvent()

end