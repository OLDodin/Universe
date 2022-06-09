local m_imagebox = nil

function CreateHelpForm()
	local form=createWidget(nil, "helpForm", "Form", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 1280, 780, 800, 450)
	priority(form, 5500)
	hide(form)
	
	local panel=createWidget(form, nil, "Panel")
	setLocaleText(createWidget(form, "helpHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 300, 20, nil, 10))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 10), "x")
	
	setLocaleText(createWidget(form, "nextHelpBtn", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_HIGH, 80, 25, 20, 20))
	setLocaleText(createWidget(form, "prevHelpBtn", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_HIGH, 80, 25, 20, 20))
	setLocaleText(createWidget(form, "closeButtonOK", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))

	m_imagebox = createWidget(form, "colorPreview", "ImageBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 1260, 670, 10, 40)
	
	m_imagebox:SetBackgroundTexture(common.GetAddonRelatedTextureGroup("common"):GetTexture("help1"))
	
	DnD.Init(form, panel, true)

	return form
end

function NextHelp()
	m_imagebox:SetBackgroundTexture(common.GetAddonRelatedTextureGroup("common"):GetTexture("help2"))
end

function PrevHelp()
	m_imagebox:SetBackgroundTexture(common.GetAddonRelatedTextureGroup("common"):GetTexture("help1"))
end