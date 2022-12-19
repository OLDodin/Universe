local m_template = nil

function CreateMainSettingsForm()
	local form=createWidget(mainForm, "mainSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 600, 360, 200, 100)
	hide(form)
	priority(form, 5)

	setLocaleText(createWidget(form, "configHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 100, 20, nil, 20))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(form, "raidButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 80))
	setLocaleText(createWidget(form, "targeterButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 110))
	setLocaleText(createWidget(form, "buffsButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 140))
	setLocaleText(createWidget(form, "bindButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 170))
	setLocaleText(createWidget(form, "progressCastButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 200))
	setLocaleText(createWidget(form, "profilesButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 370, 230))
	setLocaleText(createWidget(form, "okButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 30))
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
	local mySettings = {}
	mySettings.useRaidSubSystem = getCheckBoxState(getChild(aForm, "useRaidSubSystem"))
	mySettings.useTargeterSubSystem = getCheckBoxState(getChild(aForm, "useTargeterSubSystem"))
	mySettings.useBuffMngSubSystem = getCheckBoxState(getChild(aForm, "useBuffMngSubSystem"))
	mySettings.useBindSubSystem = getCheckBoxState(getChild(aForm, "useBindSubSystem"))
	mySettings.useCastSubSystem = getCheckBoxState(getChild(aForm, "useCastSubSystem"))
	
	return mySettings
end

function LoadMainFormSettings(aForm)
	local profile = GetCurrentProfile()
	local mySettings = profile.mainFormSettings
	if mySettings.useCastSubSystem == nil then 
		mySettings.useCastSubSystem = false 
	end
	
	setLocaleText(getChild(aForm, "useRaidSubSystem"), mySettings.useRaidSubSystem, true)
	setLocaleText(getChild(aForm, "useTargeterSubSystem"), mySettings.useTargeterSubSystem, true)
	setLocaleText(getChild(aForm, "useBuffMngSubSystem"), mySettings.useBuffMngSubSystem, true)
	setLocaleText(getChild(aForm, "useBindSubSystem"), mySettings.useBindSubSystem, true)
	setLocaleText(getChild(aForm, "useCastSubSystem"), mySettings.useCastSubSystem, true)
end


function CreateMainBtn()
	m_template = getChild(mainForm, "Template")
	setTemplateWidget(m_template)
		
	local button=createWidget(mainForm, "UniverseButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 30, 25, 350, 120)
	setText(button, "U")
	DnD.Init(button, button, true)
end