local m_cachePanels = {}
local m_usingPanels = {}
local m_zeroPos = {posX=0, posY=0, posZ=0}
local m_wdg3dSize = { sizeX = 1, sizeY = 0 }

local m_wtControl3D = common.GetAddonMainForm("Main"):GetChildChecked( "MainScreenControl3D", false )

Global("HIGH_PRIORITY_PANELS", 102)
Global("NORMAL_PRIORITY_PANELS", 101)
Global("LOW_PRIORITY_PANELS", 100)

local m_smallestPriority = LOW_PRIORITY_PANELS
local m_aboveHeadInitialized = false
local CACHE_PANELS_SIZE = 50

local function RemovePanel(anObjID)
	local panelForRemove = m_usingPanels[anObjID]
	if panelForRemove then
		table.insert(m_cachePanels, panelForRemove)
		hide(panelForRemove.panelWdg)
		HideItemsAboveHead(panelForRemove)
		panelForRemove.priority = NORMAL_PRIORITY_PANELS
		
		object.DetachWidget3D( anObjID, panelForRemove.panelWdg )
		m_wtControl3D:RemoveWidget3D( panelForRemove.panelWdg )
		m_usingPanels[anObjID] = nil
		
		--LogInfo("rem panel above head ", anObjID)
		--LogInfo("rem panel.ai ", panelForRemove.ai)
		--LogInfo("m_usingPanels2 = ", GetTableSize(m_usingPanels))
	end
end

local function FreePlaceForPriority(aPriority)
	local delList = {}
	local minPriority = HIGH_PRIORITY_PANELS
	local minPriorityObjID = nil
	for objID, panel in pairs( m_usingPanels ) do
		if panel and panel.priority < aPriority and minPriority > panel.priority then
			minPriorityObjID = objID
			minPriority = panel.priority
			if minPriority == m_smallestPriority then
				break
			end
		end
	end
	RemovePanel(minPriorityObjID)
	if minPriorityObjID then
		UnsubscribeAboveHeadListeners(minPriorityObjID)
	end
end

local function GetPanel(anObjID, aPriority)
	local panel = m_usingPanels[anObjID]
	if panel then
		panel.priority = aPriority
		
		return panel
	end
	if GetTableSize(m_cachePanels) < 1 then
		if aPriority == HIGH_PRIORITY_PANELS then
			FreePlaceForPriority(HIGH_PRIORITY_PANELS)
		elseif aPriority == NORMAL_PRIORITY_PANELS then
			FreePlaceForPriority(NORMAL_PRIORITY_PANELS)
			if GetTableSize(m_cachePanels) == 0 then
				return nil
			end
		else
			return nil
		end
	end	

	panel = table.remove(m_cachePanels)
	panel.priority = aPriority
	m_usingPanels[anObjID] = panel
	
	m_wtControl3D:AddWidget3D(panel.panelWdg, m_wdg3dSize, m_zeroPos, false, true, 80, WIDGET_3D_BIND_POINT_HIGH, 0.8, 1)
	object.AttachWidget3D( anObjID, m_wtControl3D, panel.panelWdg, 1.2)
	panel.usedBuffSlotCnt = 0
	show(panel.panelWdg)
	
	--LogInfo("m_usingPanels = ", GetTableSize(m_usingPanels))
	--LogInfo("add panel above head ", anObjID, "  ", object.GetName(anObjID))
	--LogInfo("add panel.ai ", panel.ai)
	return m_usingPanels[anObjID]
end



function InitPanelsCache(aForm)
	local settings = GetAboveHeadSettings()
	if settings then
		for i=1, CACHE_PANELS_SIZE do
			local panelContainer = CreateGroupBuffPanel(aForm, settings, true, 100001)
			hide(panelContainer.panelWdg)
			panelContainer.ai = i
			table.insert(m_cachePanels, panelContainer)
		end
		m_aboveHeadInitialized = true
	end
end

function GetAboveHeadPanel(anObjID, aPriority)
	if not m_aboveHeadInitialized then
		return nil
	end

	return GetPanel(anObjID, aPriority)
end

function SetPriorityAboveHeadPanel(anObjID, aPriority)
	if not m_aboveHeadInitialized then
		return
	end
	if not anObjID then
		return
	end
	local panel = m_usingPanels[anObjID]
	if panel then
		panel.priority = aPriority
	end
end

function IsExistAboveHeadPanel(anObjID)
	return m_usingPanels[anObjID]
end

function RemovePanelForNotExistObj(aUnitList)
	if not m_aboveHeadInitialized then
		return
	end
	local reallyExist = false
	
	for objID, panel in pairs( m_usingPanels ) do
		if panel then
			reallyExist = false
			for _, existObjID in pairs(aUnitList) do
				if existObjID == objID then
					reallyExist = true
					break
				end
			end
			if not reallyExist then
				UnsubscribeAboveHeadListeners(objID)
				RemovePanel(objID)
			end
		end
	end
end

function RemovePanelAboveHead(anObjID)
	if not m_aboveHeadInitialized then
		return nil
	end
	RemovePanel(anObjID)
end

function CannotAttachPanelAboveHead(aParams)
	if not m_aboveHeadInitialized then
		return nil
	end
	RemovePanel(aParams.objectId)
end

function HideItemsAboveHead(aPanel)
	aPanel.usedBuffSlotCnt = 0
	for _, buffSettings in pairs(aPanel.buffList) do
		hide(buffSettings.buffWdg)
		buffSettings.buffID = nil
		buffSettings.buffFinishedTime_h = 0
	end
end

local function HideAllAboveHeadPanels()
	for k, panel in pairs( m_usingPanels ) do
		if panel then 
			hide(panel.panelWdg)
		end
	end
end

function RemoveAllAboveHeadPanels()
	if not m_aboveHeadInitialized then
		return nil
	end
	HideAllAboveHeadPanels()
	local panel = nil
	for objID, panel in pairs( m_usingPanels ) do
		if panel then
			RemovePanel(objID)
		end
	end
	
	m_usingPanels = {}
	
	for i=1, CACHE_PANELS_SIZE do
		if m_cachePanels[i] then
			destroy(m_cachePanels[i].panelWdg)
		end
	end
	m_cachePanels = {}
	m_aboveHeadInitialized = false
end
