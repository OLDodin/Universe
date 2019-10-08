function CreateImportProfilesForm()
	local form=createWidget(nil, "importProfilesForm", "Form", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 600, 280, 800, 450)
	priority(form, 5500)
	hide(form)
	local panel=createWidget(form, nil, "Panel")
	setLocaleText(createWidget(form, "importProfilesHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 450, 20, nil, 20))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")


	setLocaleText(createWidget(form, "importBtn", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 150, 25, 0, 10))
	createWidget(form, "EditBox1", "EditBox", nil, nil, 560, 180, 20, 50)
	

	DnD:Init(form, panel, true)

	return form
end

function ShowImportError()
	local form=createWidget(nil, "importProfilesError", "Form", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 100, 50, 100)
	priority(form, 5501)
	
	local panel=createWidget(form, nil, "Panel")
	setLocaleText(createWidget(form, "importErrorTxt", "TextView",  WIDGET_ALIGN_CENTER, nil, 300, 20, nil, 20))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(form, "closeButtonOK", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 150, 25, 0, 10))

	DnD:Init(form, panel, true)

	show(form)
end

function GetImportText(aForm)
	return getText(getChild(aForm, "EditBox1"))
end