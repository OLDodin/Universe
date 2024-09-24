--------------------------------------------------------------------------------
-- LibDnD.lua // "Drag&Drop Library" by SLA, version 2011-05-28
--                                   updated version 2024-09-24 by oldodin
-- Help, support and updates: 
-- https://alloder.pro/topic/260-how-to-libdndlua-biblioteka-dragdrop/
--------------------------------------------------------------------------------
Global( "DnD", {} )

-- PUBLIC FUNCTIONS --
function DnD.Init( wtMovable, wtReacting, fUseCfg, fLockedToParentArea, Padding, KbFlag, Cursor, oldParam1, oldParam2 )
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
		DnD.Screen = common.GetPosConverterParams()
		common.RegisterEventHandler( DnD.OnPickAttempt, "EVENT_DND_PICK_ATTEMPT" )
		common.RegisterEventHandler( DnD.OnResolutionChanged, "EVENT_POS_CONVERTER_CHANGED" )
	end
	wtReacting = wtReacting or wtMovable
	local ID = DnD.AllocateDnDID(wtReacting)
	local newDndInfo = {}
	DnD.Widgets[ ID ] = newDndInfo
	
	newDndInfo.wtReacting = wtReacting
	newDndInfo.wtMovable = wtMovable
	newDndInfo.Enabled = true
	newDndInfo.fUseCfg = fUseCfg or false
	newDndInfo.CfgName = fUseCfg and "DnD:" .. DnD.GetWidgetTreePath( newDndInfo.wtMovable )
	newDndInfo.fLockedToParentArea = fLockedToParentArea == nil and true or fLockedToParentArea
	newDndInfo.KbFlag = type(KbFlag) == "number" and KbFlag or false
	newDndInfo.Cursor = Cursor == false and "default" or type(Cursor) == "string" and Cursor or "drag"
	newDndInfo.Padding = { 0, 0, 0, 0 } -- { T, R, B, L }
	if type( Padding ) == "table" then
		for i = 1, 4 do
			if Padding[ i ] then
				newDndInfo.Padding[ i ] = Padding[ i ]
			end
		end
	elseif type( Padding ) == "number" then
		for i = 1, 4 do
			newDndInfo.Padding[ i ] = Padding
		end
	end
	local InitialPlace = newDndInfo.wtMovable:GetPlacementPlain()
	if fUseCfg then
		local Cfg = GetConfig( newDndInfo.CfgName )
		if Cfg then
			local LimitMin, LimitMax = DnD.PrepareLimits( ID, InitialPlace )
			InitialPlace.posX = Cfg.posX or InitialPlace.posX
			InitialPlace.posY = Cfg.posY or InitialPlace.posY
			InitialPlace.highPosX = Cfg.highPosX or InitialPlace.highPosX
			InitialPlace.highPosY = Cfg.highPosY or InitialPlace.highPosY
			if newDndInfo.fLockedToParentArea then
				newDndInfo.wtMovable:SetPlacementPlain( DnD.NormalizePlacement( InitialPlace, LimitMin, LimitMax ) )
			else
				newDndInfo.wtMovable:SetPlacementPlain( InitialPlace )
			end
		end
	end
	newDndInfo.Initial = { X = InitialPlace.posX, Y = InitialPlace.posY, HX = InitialPlace.highPosX, HY = InitialPlace.highPosY }
	
	DnD.Register( wtReacting, true )
end
function DnD.Remove( wtWidget, oldParam1 )
	if not DnD.Widgets then return end
	if wtWidget == DnD then wtWidget = oldParam1 end
	local ID = DnD.GetWidgetID( wtWidget )
	if ID then
		DnD.Register( wtWidget, false )
		DnD.Widgets[ ID ] = nil
	end
end
function DnD.Enable( wtWidget, fEnable, oldParam1 )
	if not DnD.Widgets then return end
	if wtWidget == DnD then wtWidget, fEnable = fEnable, oldParam1 end
	local ID = DnD.GetWidgetID( wtWidget )
	if ID then 
		local dndInfo = DnD.Widgets[ ID ]
		if dndInfo.Enabled ~= fEnable then
			dndInfo.Enabled = fEnable
			dndInfo.wtReacting:DNDEnable(fEnable)
		end
	end
end
function DnD.UpdatePadding( wtWidget, Padding )
	if not DnD.Widgets then return end
	local ID = DnD.GetWidgetID( wtWidget )
	if ID then
		local dndInfo = DnD.Widgets[ ID ]
		if type( Padding ) == "table" then
			for i = 1, 4 do
				if Padding[ i ] then
					dndInfo.Padding[ i ] = Padding[ i ]
				end
			end
		elseif type( Padding ) == "number" then
			for i = 1, 4 do
				dndInfo.Padding[ i ] = Padding
			end
		end
	end
end
function DnD.IsDragging()
	return DnD.Dragging and true or false
end
-- FREE BONUS --
function GetConfig( name )
	local cfg = userMods.GetGlobalConfigSection( common.GetAddonName() )
	if not name then return cfg end
	return cfg and cfg[ name ]
end
function SetConfig( name, value )
	local cfg = userMods.GetGlobalConfigSection( common.GetAddonName() ) or {}
	if type( name ) == "table" then
		for i, v in pairs( name ) do cfg[ i ] = v end
	elseif name ~= nil then
		cfg[ name ] = value
	end
	userMods.SetGlobalConfigSection( common.GetAddonName(), cfg )
end
-- INTERNAL FUNCTIONS --
function DnD.AllocateDnDID( wtWidget )
	return wtWidget:GetId() * DND_CONTAINER_STEP + DND_GENERIC_WIDGET_USER
end
function DnD.GetWidgetID( wtWidget )
	for ID, W in pairs( DnD.Widgets ) do
	--в текущих версиях оператор == для виджетов сверяет типы и затем как IsEqual
		if W.wtReacting == wtWidget or W.wtMovable == wtWidget then
			return ID
		end
	end
end
function DnD.GetWidgetTreePath( wtWidget )
	local components = {}
	while wtWidget do
		table.insert( components, 1, wtWidget:GetName() )
		wtWidget = wtWidget:GetParent()
	end
	return table.concat( components, '.' )
end
function DnD.Register( wtWidget, fRegister )
	if not DnD.Widgets then return end
	local ID = DnD.GetWidgetID( wtWidget )
	if ID then
		local dndInfo = DnD.Widgets[ ID ]
		local currentDNDState = dndInfo.wtReacting:DNDGetState()
		local currentReactingWdg = dndInfo.wtReacting
		
		if fRegister and dndInfo.Enabled then
			if currentDNDState == DND_STATE_NOT_REGISTERED then
				currentReactingWdg:DNDRegister(ID, true)
			end
		elseif not fRegister then
			if DnD.Dragging == ID then
				if currentDNDState ~= DND_STATE_NOT_REGISTERED then
					currentReactingWdg:DNDCancelDrag()
				end
				DnD.OnDragCancelled()
			end
			if currentDNDState ~= DND_STATE_NOT_REGISTERED then
				currentReactingWdg:DNDUnregister()
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------
function DnD.GetParentRealSize( Widget )
	local ParentSize = {}
	local ParentRect
	local parent = Widget:GetParent()
	if parent then
		ParentRect = parent:GetRealRect()
		ParentSize.sizeX = (ParentRect.x2 - ParentRect.x1) * DnD.Screen.fullVirtualSizeX / DnD.Screen.realSizeX
		ParentSize.sizeY = (ParentRect.y2 - ParentRect.y1) * DnD.Screen.fullVirtualSizeY / DnD.Screen.realSizeY
	else
		ParentRect = { x1 = 0, y1 = 0, x2 = DnD.Screen.realSizeX, y2 = DnD.Screen.realSizeY }
		ParentSize.sizeX = DnD.Screen.fullVirtualSizeX
		ParentSize.sizeY = DnD.Screen.fullVirtualSizeY
	end
	return ParentSize, ParentRect
end
function DnD.NormalizePlacement( Place, LimitMin, LimitMax )
	local Opposite = { posX = "highPosX", posY = "highPosY", highPosX = "posX", highPosY = "posY"  }
	for k,v in pairs(LimitMax) do
		if Place[k] > v then
			Place[ Opposite[k] ] = Place[ Opposite[k] ] + Place[k] - v
			Place[k] = v
		end
	end
	for k,v in pairs(LimitMin) do
		if Place[k] < v then
			Place[ Opposite[k] ] = Place[ Opposite[k] ] + Place[k] - v
			Place[k] = v
		end
	end
	return Place
end
function DnD.PrepareLimits( ID, Place )
	local dndInfo = DnD.Widgets[ ID ]
	local LimitMin = {}
	local LimitMax = {}
	local ParentSize, ParentRect = DnD.GetParentRealSize( dndInfo.wtMovable )
	local Padding = dndInfo.Padding
	Place = Place or dndInfo.wtMovable:GetPlacementPlain()
	if Place.alignX == WIDGET_ALIGN_LOW then
		LimitMin.posX = Padding[ 4 ]
		LimitMax.posX = ParentSize.sizeX - Place.sizeX - Padding[ 2 ]
	elseif Place.alignX == WIDGET_ALIGN_HIGH then
		LimitMin.highPosX = Padding[ 2 ]
		LimitMax.highPosX = ParentSize.sizeX - Place.sizeX - Padding[ 4 ]
	elseif Place.alignX == WIDGET_ALIGN_CENTER then
		LimitMin.posX = Place.sizeX / 2 - ParentSize.sizeX / 2 + Padding[ 4 ]
		LimitMax.posX = ParentSize.sizeX / 2 - Place.sizeX / 2 - Padding[ 2 ]
	elseif Place.alignX == WIDGET_ALIGN_BOTH then
		LimitMin.posX = Padding[ 4 ]
		LimitMin.highPosX = Padding[ 2 ]
	elseif Place.alignX == WIDGET_ALIGN_LOW_ABS then
		LimitMin.posX = Padding[ 4 ] * DnD.Screen.realSizeX / DnD.Screen.fullVirtualSizeX
		LimitMax.posX = ( ParentSize.sizeX - Place.sizeX - Padding[ 2 ] ) * DnD.Screen.realSizeX / DnD.Screen.fullVirtualSizeX
	end
	if Place.alignY == WIDGET_ALIGN_LOW then
		LimitMin.posY = Padding[ 1 ]
		LimitMax.posY = ParentSize.sizeY - Place.sizeY - Padding[ 3 ]
	elseif Place.alignY == WIDGET_ALIGN_HIGH then
		LimitMin.highPosY = Padding[ 3 ]
		LimitMax.highPosY = ParentSize.sizeY - Place.sizeY - Padding[ 1 ]
	elseif Place.alignY == WIDGET_ALIGN_CENTER then
		LimitMin.posY = Place.sizeY / 2 - ParentSize.sizeY / 2 + Padding[ 1 ]
		LimitMax.posY = ParentSize.sizeY / 2 - Place.sizeY / 2 - Padding[ 3 ]
	elseif Place.alignY == WIDGET_ALIGN_BOTH then
		LimitMin.posY = Padding[ 1 ]
		LimitMin.highPosY = Padding[ 3 ]
	elseif Place.alignY == WIDGET_ALIGN_LOW_ABS then
		LimitMin.posY = Padding[ 1 ] * DnD.Screen.realSizeY / DnD.Screen.fullVirtualSizeY
		LimitMax.posY = (ParentSize.sizeY - Place.sizeY - Padding[ 3 ] ) * DnD.Screen.realSizeY / DnD.Screen.fullVirtualSizeY
	end
	return LimitMin, LimitMax
end
-----------------------------------------------------------------------------------------------------------
function DnD.OnPickAttempt( params )
	local Picking = params.srcId
	local dndInfo = DnD.Widgets[ Picking ]
	if dndInfo and dndInfo.Enabled 
	and (
	not dndInfo.KbFlag 
	or (dndInfo.KbFlag == KBF_NONE and params.kbFlags == KBF_NONE)
	or bit.band( params.kbFlags, dndInfo.KbFlag ) ~= 0
	) then
		DnD.Place = dndInfo.wtMovable:GetPlacementPlain()
		DnD.Reset = dndInfo.wtMovable:GetPlacementPlain()
		DnD.Cursor = { X = params.posX , Y = params.posY }
		DnD.Screen = common.GetPosConverterParams()
		if dndInfo.fLockedToParentArea then
			DnD.LimitMin, DnD.LimitMax = DnD.PrepareLimits( Picking, DnD.Place )
		end
		common.SetCursor( dndInfo.Cursor )
		DnD.Dragging = Picking
		common.RegisterEventHandler( DnD.OnDragTo, "EVENT_DND_DRAG_TO" )
		common.RegisterEventHandler( DnD.OnDropAttempt, "EVENT_DND_DROP_ATTEMPT" )
		common.RegisterEventHandler( DnD.OnDragCancelled, "EVENT_DND_DRAG_CANCELLED" )
		
		dndInfo.wtReacting:DNDConfirmPickAttempt()
	end
end
function DnD.OnDragTo( params )
	if not DnD.Dragging then return end
	local dndInfo = DnD.Widgets[ DnD.Dragging ]
	local dx = params.posX - DnD.Cursor.X
	local dy = params.posY - DnD.Cursor.Y
	if DnD.Place.alignX ~= WIDGET_ALIGN_LOW_ABS then
		dx = dx * DnD.Screen.fullVirtualSizeX / DnD.Screen.realSizeX
	end
	if DnD.Place.alignY ~= WIDGET_ALIGN_LOW_ABS then
		dy = dy * DnD.Screen.fullVirtualSizeY / DnD.Screen.realSizeY
	end
	DnD.Place.posX = math.floor( DnD.Reset.posX + dx )
	DnD.Place.posY = math.floor( DnD.Reset.posY + dy )
	DnD.Place.highPosX = math.floor( DnD.Reset.highPosX - dx )
	DnD.Place.highPosY = math.floor( DnD.Reset.highPosY - dy )
	if dndInfo.fLockedToParentArea then
		DnD.Place = DnD.NormalizePlacement( DnD.Place, DnD.LimitMin, DnD.LimitMax )
	end
	dndInfo.wtMovable:SetPlacementPlain( DnD.Place )
	common.SetCursor( dndInfo.Cursor )
end
function DnD.OnDropAttempt()
	DnD.StopDragging( true )
end
function DnD.OnDragCancelled()
	DnD.StopDragging( false )
end
function DnD.StopDragging( fSuccess )
	if not DnD.Dragging then return end
	common.UnRegisterEventHandler( DnD.OnDragTo, "EVENT_DND_DRAG_TO" )
	common.UnRegisterEventHandler( DnD.OnDropAttempt, "EVENT_DND_DROP_ATTEMPT" )
	common.UnRegisterEventHandler( DnD.OnDragCancelled, "EVENT_DND_DRAG_CANCELLED" )
	local dndInfo = DnD.Widgets[ DnD.Dragging ]
	if fSuccess then
		dndInfo.wtReacting:DNDConfirmDropAttempt()
		if dndInfo.fUseCfg then
			SetConfig( dndInfo.CfgName, { posX = DnD.Place.posX, posY = DnD.Place.posY, highPosX = DnD.Place.highPosX, highPosY = DnD.Place.highPosY } )
		end
		dndInfo.Initial = { X = DnD.Place.posX, Y = DnD.Place.posY, HX = DnD.Place.highPosX, HY = DnD.Place.highPosY }
	else
		dndInfo.wtMovable:SetPlacementPlain( DnD.Reset )
	end
	DnD.Place = nil
	DnD.Reset = nil
	DnD.Cursor = nil
	DnD.LimitMin = nil
	DnD.LimitMax = nil
	DnD.Dragging = nil
	common.SetCursor( "default" )
end
function DnD.OnResolutionChanged()
	if DnD.Dragging and DnD.Widgets[ DnD.Dragging ] then
		DnD.Widgets[ DnD.Dragging ].wtReacting:DNDCancelDrag()
	end
	DnD.OnDragCancelled()
	DnD.Screen = common.GetPosConverterParams()
	for ID, W in pairs( DnD.Widgets ) do
		if W.fLockedToParentArea then
			local InitialPlace = W.wtMovable:GetPlacementPlain()
			local LimitMin, LimitMax = DnD.PrepareLimits( ID, InitialPlace )
			InitialPlace.posX = W.Initial.X
			InitialPlace.posY = W.Initial.Y
			InitialPlace.highPosX = W.Initial.HX
			InitialPlace.highPosY = W.Initial.HY
			W.wtMovable:SetPlacementPlain( DnD.NormalizePlacement( InitialPlace, LimitMin, LimitMax ) )
		end
	end
end

-- для совместимости, начиная с 15.3 движок сохраняет DND при сменах видимости
DnD.SwapWdg = function(aWdg)
	if aWdg:IsVisible() then
		DnD.HideWdg(aWdg)
	else
		DnD.ShowWdg(aWdg)
	end
end
DnD.ShowWdg = function(aWdg)
	aWdg:Show(true)
end
DnD.HideWdg = function(aWdg)
	aWdg:Show(false)
end