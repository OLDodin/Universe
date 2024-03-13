local m_template = getChild(mainForm, "Template")

function GetColorSettingsHeight()
	return 245
end

function CreateColorSettingsForm(anInfo)
	if anInfo.useHighlightBuff == nil then
		anInfo.useHighlightBuff = false
	end
	if anInfo.blinkHighlight == nil then
		anInfo.blinkHighlight = false
	end
	if anInfo.highlightColor == nil then
		anInfo.highlightColor = {r=0, g=1, b=0, a=1}
	end
	
	setTemplateWidget(m_template)
	
	local form=createWidget(nil, "colorSettingsForm", "PanelTransparent", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_BOTH, 290, nil, 0, 0, true)
	
	setLocaleText(createWidget(form, "useHighlightBuffCheckBox", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 10, 150), anInfo.useHighlightBuff)
	setLocaleText(createWidget(form, "blinkHighlightCheckBox", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 10, 180), anInfo.blinkHighlight)
	
	setLocaleText(createWidget(form, "setColorButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 150, 30, nil, 5))
	setLocaleText(createWidget(form, "headerColor", "TextView", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_LOW, 250, 25, 20, 40))
	
	local colorPreview = createWidget(form, "colorPreview", "ImageBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 70, 70, 210, 70)	
	
	local redWdg = CreateSlider(form, "redSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 10, 70, 80)
	local greenWdg = CreateSlider(form, "greenSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 10, 95, 80)
	local blueWdg = CreateSlider(form, "blueSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 10, 120, 80)
	--local alphaWdg = CreateSlider(form, "alphaSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 10, 145, 120)
	
	local sliderParams	= {
							valueMin	= 0,
							valueMax	= 1.0,
							stepsCount	= 20,
							value		= 1.0,
							execute		= function( value ) 
								local color = {}
								color.r = redWdg:Get()
								color.g = greenWdg:Get()
								color.b = blueWdg:Get()
								--color.a = alphaWdg:Get()
								color.a = 1
								colorPreview:SetBackgroundColor(color) 
							end
						}
	
	
	sliderParams.description = getLocale()["red"]
	sliderParams.value = anInfo.highlightColor.r
	redWdg:Set(sliderParams)
	sliderParams.description = getLocale()["green"]
	sliderParams.value = anInfo.highlightColor.g
	greenWdg:Set(sliderParams)
	sliderParams.description = getLocale()["blue"]
	sliderParams.value = anInfo.highlightColor.b
	blueWdg:Set(sliderParams)
	--sliderParams.description = getLocale()["alpha"]
	--sliderParams.value = anInfo.highlightColor.a
	--alphaWdg:Set(sliderParams)
	
	colorPreview:SetBackgroundColor(anInfo.highlightColor)
	
	return form
end

function SaveBuffColorHighlight(aForm, anInfo)
	anInfo.highlightColor = getChild(aForm, "colorPreview"):GetBackgroundColor()
	anInfo.useHighlightBuff = getCheckBoxState(getChild(aForm, "useHighlightBuffCheckBox"))
	anInfo.blinkHighlight = getCheckBoxState(getChild(aForm, "blinkHighlightCheckBox"))
end

