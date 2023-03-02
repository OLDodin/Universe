local m_originalFunc = DnD.OnPickAttempt

function DnD.SetDndCallbackFunc(aPickAttempFunc)
	DnD.PickAttemptPrepareFunc = aPickAttempFunc
end

DnD.OnPickAttempt = function( params )
	local Picking = params.srcId
	if DnD.Widgets[ Picking ] and DnD.Widgets[ Picking ].Enabled then
		if DnD.PickAttemptPrepareFunc then	
			DnD.PickAttemptPrepareFunc(params)
		end
	end
	m_originalFunc(params)
end

DnD.Init = function( wtMovable, wtReacting, fUseCfg, fLockedToParentArea, Padding, KbFlag, Cursor, oldParam1, oldParam2 )
	if wtMovable == DnD then
		wtMovable, wtReacting, fUseCfg, fLockedToParentArea, Padding, KbFlag, Cursor, oldParam1 =
		           wtReacting, fUseCfg, fLockedToParentArea, Padding, KbFlag, Cursor, oldParam1, oldParam2
	end
	if type(wtMovable) == "number" then
		wtReacting, wtMovable, fUseCfg, fLockedToParentArea, Padding, KbFlag, Cursor, oldParam1 =
		           wtReacting, fUseCfg, fLockedToParentArea, Padding, KbFlag, Cursor, oldParam1, oldParam2
	end
	if type(wtMovable) ~= "userdata" then return end
	if not DnD.Widgets then
		DnD.Widgets = {}
		DnD.Screen = widgetsSystem:GetPosConverterParams()
		common.RegisterEventHandler( DnD.OnPickAttempt, "EVENT_DND_PICK_ATTEMPT" )
		common.RegisterEventHandler( DnD.OnResolutionChanged, "EVENT_POS_CONVERTER_CHANGED" )
	end
	wtReacting = wtReacting or wtMovable
	local ID = DnD.AllocateDnDID(wtReacting)
	DnD.Widgets[ ID ] = {}
	DnD.Widgets[ ID ].wtReacting = wtReacting
	DnD.Widgets[ ID ].wtMovable = wtMovable
	DnD.Widgets[ ID ].Enabled = true
	DnD.Widgets[ ID ].fUseCfg = fUseCfg or false
	DnD.Widgets[ ID ].CfgName = fUseCfg and "DnD:" .. DnD.GetWidgetTreePath( DnD.Widgets[ ID ].wtMovable )
	DnD.Widgets[ ID ].fLockedToParentArea = fLockedToParentArea == nil and true or fLockedToParentArea
	DnD.Widgets[ ID ].KbFlag = type(KbFlag) == "number" and KbFlag or false
	DnD.Widgets[ ID ].Cursor = Cursor == false and "default" or type(Cursor) == "string" and Cursor or "drag"
	DnD.Widgets[ ID ].Padding = { 0, 0, 0, 0 } -- { T, R, B, L }
	if type( Padding ) == "table" then
		for i = 1, 4 do
			if Padding[ i ] then
				DnD.Widgets[ ID ].Padding[ i ] = Padding[ i ]
			end
		end
	elseif type( Padding ) == "number" then
		for i = 1, 4 do
			DnD.Widgets[ ID ].Padding[ i ] = Padding
		end
	end
	local InitialPlace = DnD.Widgets[ ID ].wtMovable:GetPlacementPlain()
	if fUseCfg then
		local Cfg = GetConfig( DnD.Widgets[ ID ].CfgName )
		if Cfg then
			local LimitMin, LimitMax = DnD.PrepareLimits( ID, InitialPlace )
			InitialPlace.posX = Cfg.posX or InitialPlace.posX
			InitialPlace.posY = Cfg.posY or InitialPlace.posY
			InitialPlace.highPosX = Cfg.highPosX or InitialPlace.highPosX
			InitialPlace.highPosY = Cfg.highPosY or InitialPlace.highPosY
			if DnD.Widgets[ ID ].fLockedToParentArea then
				DnD.Widgets[ ID ].wtMovable:SetPlacementPlain( DnD.NormalizePlacement( InitialPlace, LimitMin, LimitMax ) )
			else
				DnD.Widgets[ ID ].wtMovable:SetPlacementPlain( InitialPlace )
			end
		end
	end
	DnD.Widgets[ ID ].Initial = { X = InitialPlace.posX, Y = InitialPlace.posY, HX = InitialPlace.highPosX, HY = InitialPlace.highPosY }
	
	--[[
	--после этого вызывается для вообще всех виджетов аддона при вызове Show
	local mt = getmetatable( wtReacting )
	if not mt._Show then
		mt._Show = mt.Show
		mt.Show = function ( self, show )
			self:_Show( show ); 
			if self:IsValid() then DnD.Register( self, show ) end
		end
	end]]
	DnD.Register( wtReacting, true )
end

DnD.SwapWdg = function(aWdg)
	if aWdg:IsVisible() then
		DnD.HideWdg(aWdg)
	else
		DnD.ShowWdg(aWdg)
	end
end

DnD.ShowWdg = function(aWdg)
	aWdg:Show(true)
	DnD.Register(aWdg, true)
end

DnD.HideWdg = function(aWdg)
	aWdg:Show(false)
	DnD.Register(aWdg, false)
end