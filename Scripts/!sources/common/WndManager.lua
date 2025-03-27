Global( "WndMgr", {} )

local m_wndList = {}
local m_initPriority = 505
local m_currentPriority = m_initPriority
local m_maxPriority = 10000000

local function ResetPriority()
	m_currentPriority = m_initPriority
	for _, wnd in pairs(m_wndList) do
		m_currentPriority = m_currentPriority + 1
		wnd:SetPriority(m_currentPriority)
	end
end

local function IsContainWnd(aWnd)
	for _, wnd in pairs(m_wndList) do
		if aWnd == wnd then
			return true
		end
	end
	return false
end

local function ForegroundWnd(aWnd)
	if not IsContainWnd(aWnd) then
		return
	end
	m_currentPriority = m_currentPriority + 1
	if m_currentPriority >= m_maxPriority then
		ResetPriority()
		m_currentPriority = m_currentPriority + 1
	end
	
	aWnd:SetPriority(m_currentPriority)
end

function WndMgr.AddWnd(aWnd)
	table.insert(m_wndList, aWnd)
end

function WndMgr.RemoveWnd(aWnd)
	for i, wnd in pairs(m_wndList) do
		if aWnd == wnd then
			m_wndList[i] = nil
			return
		end
	end
end

function WndMgr.RemoveAllWnd()
	m_wndList = {}
end

function WndMgr.OnWndClicked(aWnd)
	ForegroundWnd(aWnd)
end

function WndMgr.SwapWnd(aWnd)
	if not aWnd then
		return
	end
	if aWnd:IsVisible() then
		WndMgr.HideWdg(aWnd)
	else
		WndMgr.ShowWdg(aWnd)
	end
end

function WndMgr.ShowWdg(aWnd)
	if not aWnd then
		return
	end
	ForegroundWnd(aWnd)
	aWnd:Show(true)
end

function WndMgr.HideWdg(aWnd)
	if not aWnd then
		return
	end
	aWnd:Show(false)
end