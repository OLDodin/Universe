local m_currentFormSettings = nil

function CreateMainSettingsForm()
	setTemplateWidget("common")
	
	local form=createWidget(mainForm, "mainSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 600, 360, 200, 100)
	hide(form)
	priority(form, 505)

	setLocaleText(createWidget(form, "configHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 100, 20, nil, 20))
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(form, "raidButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 80))
	setLocaleText(createWidget(form, "targeterButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 110))
	setLocaleText(createWidget(form, "buffsButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 140))
	setLocaleText(createWidget(form, "bindButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 170))
	setLocaleText(createWidget(form, "progressCastButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 200))
	setLocaleText(createWidget(form, "profilesButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 230))
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 30))
	setLocaleText(createWidget(form, "helpButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_HIGH, 100, 30, 30, 30))
	
	createWidget(form, "useRaidSubSystem", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 80)
	createWidget(form, "useTargeterSubSystem", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 110)
	createWidget(form, "useBuffMngSubSystem", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 140)
	createWidget(form, "useBindSubSystem", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 170)
	createWidget(form, "useCastSubSystem", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 200)
	
	DnD.Init(form, form, true)
		
	return form
end

function SaveMainFormSettings(aForm)
	if not aForm then
		return m_currentFormSettings
	end
	
	m_currentFormSettings.useRaidSubSystem = getCheckBoxState(getChild(aForm, "useRaidSubSystem"))
	m_currentFormSettings.useTargeterSubSystem = getCheckBoxState(getChild(aForm, "useTargeterSubSystem"))
	m_currentFormSettings.useBuffMngSubSystem = getCheckBoxState(getChild(aForm, "useBuffMngSubSystem"))
	m_currentFormSettings.useBindSubSystem = getCheckBoxState(getChild(aForm, "useBindSubSystem"))
	m_currentFormSettings.useCastSubSystem = getCheckBoxState(getChild(aForm, "useCastSubSystem"))
	
	return m_currentFormSettings
end

function UpdateMainFormButtons(aForm)
	getChild(aForm, "raidButton"):Enable(m_currentFormSettings.useRaidSubSystem)
	getChild(aForm, "targeterButton"):Enable(m_currentFormSettings.useTargeterSubSystem)
	getChild(aForm, "buffsButton"):Enable(m_currentFormSettings.useBuffMngSubSystem)
	getChild(aForm, "bindButton"):Enable(m_currentFormSettings.useBindSubSystem)
	getChild(aForm, "progressCastButton"):Enable(m_currentFormSettings.useCastSubSystem)
end

function LoadMainFormSettings(aForm)
	local profile = GetCurrentProfile()
	m_currentFormSettings = deepCopyTable(profile.mainFormSettings)
	
	if not aForm then
		return
	end
	
	setLocaleText(getChild(aForm, "useRaidSubSystem"), m_currentFormSettings.useRaidSubSystem)
	setLocaleText(getChild(aForm, "useTargeterSubSystem"), m_currentFormSettings.useTargeterSubSystem)
	setLocaleText(getChild(aForm, "useBuffMngSubSystem"), m_currentFormSettings.useBuffMngSubSystem)
	setLocaleText(getChild(aForm, "useBindSubSystem"), m_currentFormSettings.useBindSubSystem)
	setLocaleText(getChild(aForm, "useCastSubSystem"), m_currentFormSettings.useCastSubSystem)
	
	UpdateMainFormButtons(aForm)
end

function UpdateUseRaidSubSystemMainForm(aForm)
	getChild(aForm, "raidButton"):Enable(getCheckBoxState(getChild(aForm, "useRaidSubSystem")))
end

function UpdateUseTargeterSubSystemMainForm(aForm)
	getChild(aForm, "targeterButton"):Enable(getCheckBoxState(getChild(aForm, "useTargeterSubSystem")))
end

function UpdateUseBuffMngSubSystemMainForm(aForm)
	getChild(aForm, "buffsButton"):Enable(getCheckBoxState(getChild(aForm, "useBuffMngSubSystem")))
end

function UpdateUseBindSubSystemMainForm(aForm)
	getChild(aForm, "bindButton"):Enable(getCheckBoxState(getChild(aForm, "useBindSubSystem")))
end

function UpdateUseProgressCastSubSystemMainForm(aForm)
	getChild(aForm, "progressCastButton"):Enable(getCheckBoxState(getChild(aForm, "useCastSubSystem")))
end


function CreateMainBtn()
	setTemplateWidget("common")
		
	local button=createWidget(mainForm, "UniverseButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 30, 25, 350, 120)
	setText(button, "U")
	DnD.Init(button, button, true)
end