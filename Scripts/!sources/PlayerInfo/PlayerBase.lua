Global( "PlayerBase", {} )

Global( "g_regCnt", {})

function PlayerBase:Init()
	self.refCnt = 0
	self.guiRaidListener = nil
	self.guiTargetListener = nil
	self.guiAboveHeadListener = nil
	self.guiBuffPlatesListeners = {}
end

function PlayerBase:SubscribeBuffPlateGui(anID, aLiteners, aEventFunc)
	if GetTableSize(self.guiBuffPlatesListeners) == 0 and GetTableSize(aLiteners) ~= 0 then
		self.refCnt = self.refCnt + 1
	end
	self.guiBuffPlatesListeners = aLiteners

	local params = {}
	params.unitId = anID
	aEventFunc(params)
end

function PlayerBase:UnsubscribeBuffPlateGui()
	if GetTableSize(self.guiBuffPlatesListeners) ~= 0 then
		self.refCnt = self.refCnt - 1
	end
	self.guiBuffPlatesListeners = {}
end

function PlayerBase:SubscribeAboveHeadGui(anID, aLitener, aEventFunc)
	if not self.guiAboveHeadListener then
		self.refCnt = self.refCnt + 1
	end
	self.guiAboveHeadListener = aLitener

	local params = {}
	params.unitId = anID
	aEventFunc(params)
end

function PlayerBase:UnsubscribeAboveHeadGui()
	if self.guiAboveHeadListener then
		self.refCnt = self.refCnt - 1
	end
	self.guiAboveHeadListener = nil
end


function PlayerBase:SubscribeTargetGui(anID, aLitener, aEventFunc)
	if not self.guiTargetListener then
		self.refCnt = self.refCnt + 1
	end
	self.guiTargetListener = aLitener

	local params = {}
	params.unitId = anID
	aEventFunc(params)
end

function PlayerBase:UnsubscribeTargetGui()
	if self.guiTargetListener then
		self.refCnt = self.refCnt - 1
	end
	self.guiTargetListener = nil
end

function PlayerBase:SubscribeRaidGui(anID, aLitener, aEventFunc)
	if not self.guiRaidListener then
		self.refCnt = self.refCnt + 1
	end
	self.guiRaidListener = aLitener

	local params = {}
	params.unitId = anID
	aEventFunc(params)
end

function PlayerBase:UnsubscribeRaidGui()
	if self.guiRaidListener then
		self.refCnt = self.refCnt - 1
	end
	self.guiRaidListener = nil
end

function PlayerBase:CanDestroy()
	if self.refCnt == 0 then
		return true
	end
	return false
end


function PlayerBase:unreg(aName)
	
	g_regCnt[aName] = g_regCnt[aName] - 1
end

function PlayerBase:reg(aName)
	if not g_regCnt[aName] then g_regCnt[aName] = 0 end
	g_regCnt[aName] = g_regCnt[aName] + 1
end