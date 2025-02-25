Global("g_myAvatarID", nil)

--------------------------------------------------------------------------------
-- Profile functions
--------------------------------------------------------------------------------
Global("EventProfilingEnable", false)

Global("TEventProfile", {})
function TEventProfile:CreateNewObject(aEventName, aFunc, aParams)
	return setmetatable({
			EventName = aEventName,
			OriginFunc = aFunc,
			OriginParams = aParams,
			TotalWorkingTime = 0,
			CallCount = 0,
			MaxWorkingTime = 0,
			MyFunc = nil,
			Active = true
		}, { __index = self })
end

function TEventProfile:GetEventFunc()
	self.MyFunc = function(aParams)
		local startTime = common.GetMks()
		
		self.OriginFunc(aParams)
		
		local workingTime = (common.GetMks() - startTime) / 1000
		self.CallCount = self.CallCount + 1
		self.TotalWorkingTime = self.TotalWorkingTime + workingTime
		self.MaxWorkingTime = math.max(self.MaxWorkingTime, workingTime)
	end
	return self.MyFunc
end

function TEventProfile:PrintInfo()
	if self.CallCount > 0 then
		LogInfo(self.EventName, " max = ", self.MaxWorkingTime, " avg = ", self.TotalWorkingTime/self.CallCount, " cnt = ", self.CallCount)
	end
end

local originRegisterEventHandler = common.RegisterEventHandler
local originUnRegisterEventHandler = common.UnRegisterEventHandler
local m_callingTable = {}

function ProfilePrint()
	LogInfo("========================================", "=")
	for _, profileCaller in ipairs(m_callingTable) do
		profileCaller:PrintInfo()
	end
	LogInfo("========================================", "=")
end

function ProfileRegisterEventHandler(aFunc, aEventName, aParams)
	local profileCaller = TEventProfile:CreateNewObject(aEventName, aFunc, aParams)
	table.insert(m_callingTable, profileCaller)
	originRegisterEventHandler(profileCaller:GetEventFunc(), aEventName, profileCaller.OriginParams)
end

function ProfileUnRegisterEventHandler(aFunc, aEventName, aParams)
	for _, profileCaller in ipairs(m_callingTable) do
		if profileCaller.Active and profileCaller.EventName == aEventName then 
			if profileCaller.OriginParams == aParams then
				if string.dump(profileCaller.OriginFunc) == string.dump(aFunc) then
					profileCaller.Active = false
					originUnRegisterEventHandler(profileCaller.MyFunc, aEventName, profileCaller.OriginParams)
					break
				end
			end
		end
	end
end

function onAOPanelLeft( params )
	if params.sender == common.GetAddonName() then
		ProfilePrint()
	end
end

if EventProfilingEnable then
	common.RegisterEventHandler = ProfileRegisterEventHandler
	common.UnRegisterEventHandler = ProfileUnRegisterEventHandler
	
	common.RegisterEventHandler( onAOPanelLeft, "AOPANEL_BUTTON_LEFT_CLICK" )
end

--------------------------------------------------------------------------------
-- Helper functions
--------------------------------------------------------------------------------
function GetTableSize( t )
	if not t then
		return 0
	end
	return table.nkeys(t)
end
--------------------------------------------------------------------------------
-- Logging helpers
--------------------------------------------------------------------------------
function GetStringListByArguments( ... )
	local argList = {...}
	local newArgList = {}
	
	for i = 1, #argList do
		local arg = argList[ i ]
		if apitype( arg ) == "WString" then
			newArgList[ i ] = arg
		else
			newArgList[ i ] = tostring( arg )
		end
	end

	return newArgList
end
--------------------------------------------------------------------------------
function LogInfo( ... )
	common.LogInfo( common.GetAddonName(), unpack( GetStringListByArguments( ... ) ) )
end
--------------------------------------------------------------------------------
function LogInfoCommon( ... )
	common.LogInfo( "common", unpack( GetStringListByArguments( ... ) ) )
end
--------------------------------------------------------------------------------
function LogWarning( ... )
	common.LogWarning( "common", unpack( GetStringListByArguments( ... ) ) )
end
--------------------------------------------------------------------------------
function LogError( ... )
	common.LogError( "common", unpack( GetStringListByArguments( ... ) ) )
end
--------------------------------------------------------------------------------
function LogToChat(aMessage, aType)
	if not aType then
		aType = "notice"
	end
	if apitype(aMessage) ~= "WString" then
		aMessage = userMods.ToWString(tostring(aMessage))
	end
	userMods.SendSelfChatMessage(aMessage, aType)
end

function LogTable( t, tabstep )
	tabstep = tabstep or 1
	if t == nil then
		LogInfo( "nil (no table)" )
		return
	end
	assert( type( t ) == "table", "Invalid data passed" )
	local TabString = string.rep( "    ", tabstep )
	local isEmpty = true
	for i, v in pairs( t ) do
		if type( v ) == "table" then
			LogInfo( TabString, i, ":" )
			LogTable( v, tabstep + 1 )
		else
			LogInfo( TabString, i, " = ", v )
		end
		isEmpty = false
	end
	if isEmpty then
		LogInfo( TabString, "{} (empty table)" )
	end
end