local m_imagebox = nil

function CreateHelpForm()
	setTemplateWidget("common")
	local form=createWidget(mainForm, "helpForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 1180, 780, 800, 450)
	priority(form, 507)
	hide(form)
	
	setLocaleText(createWidget(form, "helpHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 300, 20, nil, 10))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 10), "x")
	
	setLocaleText(createWidget(form, "nextHelpBtn", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_HIGH, 80, 25, 20, 20))
	setLocaleText(createWidget(form, "prevHelpBtn", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 80, 25, 20, 20))
	setLocaleText(createWidget(form, "closeButtonOK", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))

	m_imagebox = createWidget(form, "colorPreview", "ImageBox", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_LOW, 1160, 670, 0, 40)
	
	m_imagebox:SetBackgroundTexture(common.GetAddonRelatedTextureGroup("common"):GetTexture("help1"))
	resize(m_imagebox, 1024)
	DnD.Init(form, form, true)

	return form
end

function NextHelp()
	resize(m_imagebox, 1024)
	m_imagebox:SetBackgroundTexture(common.GetAddonRelatedTextureGroup("common"):GetTexture("help2"))
end

function PrevHelp()
	resize(m_imagebox, 1024)
	m_imagebox:SetBackgroundTexture(common.GetAddonRelatedTextureGroup("common"):GetTexture("help1"))
end