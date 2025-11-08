Global( "PlayerDistance", {} )


function PlayerDistance:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.distance = 0
	self.lastDistance = -1
	self.lastAngle = -1
	self.SKIP_UPDATES_CNT = 5
	self.skipCnt = 0
	self.base = copyTable(PlayerBase)
	self.base:Init()
	
	self.eventFunc = self:GetEventFunc()

	self:RegisterEvent(anID)
end

function PlayerDistance:SubscribeByType(aType, aLitener)
	if aType == enumSubscribeType.Raid then
		self.lastDistance = -1
		self.lastAngle = -1
		self.skipCnt = 0
		self.base:SubscribeRaidGui(self.playerID, aLitener, self.eventFunc)
		self:UpdateValueIfNeeded()
	end
end

function PlayerDistance:UnsubscribeByType(aType)
	if aType == enumSubscribeType.Raid then
		local info = { }
		info.needShow = false
		info.visibleChanged = true	
		local res = self.base.guiRaidListener and self.base.guiRaidListener.listenerDistance(info, self.base.guiRaidListener)
		
		self.base:UnsubscribeRaidGui()
	end
end

function PlayerDistance:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerDistance:UpdateValueIfNeeded()
	if self.skipCnt == 0 then
		self.skipCnt = self.SKIP_UPDATES_CNT
	else
		self.skipCnt = self.skipCnt - 1
		return
	end
	self.distance = getDistanceToTarget( self.playerID )
	local angle = 0
	local profile = GetCurrentProfile()
	if self.distance ~= nil and profile.raidFormSettings.showArrowButton then
		angle = getAngleToTarget(self.playerID)
	end
	
	if self.distance ~= self.lastDistance or angle ~= self.lastAngle then		
		local info = { }
		info.dist = self.distance
		info.angle = angle
		info.needShow = self.distance ~= nil
		info.visibleChanged = self.distance ~= self.lastDistance
		
		self.lastDistance = info.dist
		self.lastAngle = info.angle
		local res = self.base.guiRaidListener and self.base.guiRaidListener.listenerDistance(info, self.base.guiRaidListener)
	end
	
end

function PlayerDistance:GetEventFunc()
	return function(aParams)

	end
end

function PlayerDistance:RegisterEvent(anID)

end

function PlayerDistance:UnRegisterEvent()
	
end