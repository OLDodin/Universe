function CreateImportProfilesForm()
	setTemplateWidget("common")
	local form=createWidget(mainForm, "importProfilesForm", "PanelWnd", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 600, 280, 800, 450)
	hide(form)
	WndMgr.AddWnd(form)

	setLocaleText(createWidget(form, "importProfilesHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 450, 20, nil, 20))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")


	setLocaleText(createWidget(form, "importBtn", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 150, 25, 0, 10))
	createWidget(form, "EditBox1", "EditBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 560, 180, 20, 50)
	

	DnD.Init(form, form, true)

	return form
end

function CreateImportError()
	setTemplateWidget("common")
	local form=createWidget(mainForm, "importProfilesError", "PanelWnd", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 100, 50, 100)
	hide(form)
	WndMgr.AddWnd(form)
	
	setLocaleText(createWidget(form, "importErrorTxt", "TextView",  WIDGET_ALIGN_CENTER, nil, 300, 20, nil, 20))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(form, "closeButtonOK", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 150, 25, 0, 10))

	DnD.Init(form, form, true)

	return form
end

function GetImportText(aForm)
	return getText(getChild(aForm, "EditBox1"))
end