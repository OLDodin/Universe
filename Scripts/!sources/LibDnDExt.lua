local m_originalPickFunc = DnD.OnPickAttempt

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
	m_originalPickFunc(params)
end
