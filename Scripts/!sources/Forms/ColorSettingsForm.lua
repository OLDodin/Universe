local m_colorPanels = {}

function GetColorSettingsHeight()
	return 245
end

local function CreateColorInstrument(aParent, aColor, aNeedAlpha)
	local colorPreview = createWidget(aParent, "colorPreview", "ImageBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 70, 70, 210, aNeedAlpha and 55 or 70)
	
	local redSlider = CreateSlider(aParent, "redSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 10, aNeedAlpha and 40 or 70)
	local greenSlider = CreateSlider(aParent, "greenSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 10, aNeedAlpha and 65 or 95)
	local blueSlider = CreateSlider(aParent, "blueSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 10, aNeedAlpha and 90 or 120)
	local alphaSlider = aNeedAlpha and CreateSlider(aParent, "alphaSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 25, 10, 115) or nil
	
	
	local sliderParams	= {
							valueMin	= 0,
							valueMax	= 1.0,
							stepsCount	= 20,
							value		= 1.0,
							sliderWidth		= 80,
							sliderChangedFunc = function( value ) 
								local color = {}
								color.r = redSlider:Get()
								color.g = greenSlider:Get()
								color.b = blueSlider:Get()
								color.a = aNeedAlpha and alphaSlider:Get() or 1
								colorPreview:SetBackgroundColor(color) 
							end
						}
	
	
	sliderParams.description = getLocale()["red"]
	sliderParams.value = aColor.r
	redSlider:Init(sliderParams)
	sliderParams.description = getLocale()["green"]
	sliderParams.value = aColor.g
	greenSlider:Init(sliderParams)
	sliderParams.description = getLocale()["blue"]
	sliderParams.value = aColor.b
	blueSlider:Init(sliderParams)
	if aNeedAlpha then
		sliderParams.description = getLocale()["alpha"]
		sliderParams.value = aColor.a
		alphaSlider:Init(sliderParams)
	end
	
	colorPreview:SetBackgroundColor(aColor)
	
	m_colorPanels[aParent] = {
		redSliderObj = redSlider,
		greenSliderObj = greenSlider,
		blueSliderObj = blueSlider,
		alphaSliderObj = alphaSlider
	}
end

function CreateColorPanelForBuff(aParent, anInfo)
	if anInfo.useHighlightBuff == nil then
		anInfo.useHighlightBuff = false
	end
	if anInfo.blinkHighlight == nil then
		anInfo.blinkHighlight = false
	end

	if anInfo.highlightColor == nil then
		anInfo.highlightColor = {r=0, g=1, b=0, a=1}
	end
	
	setTemplateWidget("common")
	
	local form=createWidget(aParent, "colorSettingsForm", "PanelTransparent", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_BOTH, 290, nil, 0, 0)
	
	setLocaleText(createWidget(form, "useHighlightBuffCheckBox", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 10, 150), anInfo.useHighlightBuff)
	setLocaleText(createWidget(form, "blinkHighlightCheckBox", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 10, 180), anInfo.blinkHighlight)
	
	setLocaleText(createWidget(form, "setColorButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 150, 30, nil, 5))
	setLocaleText(createWidget(form, "headerColor", "TextView", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_LOW, 250, 25, 20, 40))
	
	CreateColorInstrument(form, anInfo.highlightColor, false)
		
	return form
end

function CreateColorSettingsPanel(aParent, aColor, aHeaderName)
	setTemplateWidget("common")
	
	local form=createWidget(aParent, "colorSettingsForm", "PanelTransparent", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_BOTH, 290, nil, 0, 0)
	setLocaleTextEx(createWidget(form, aHeaderName, "TextView", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 25, 0, 10), nil, "ColorWhite", "center")
	
	local backPreview = createWidget(form, "backPreview", "ImageBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 76, 76, 207, 52)
	
	CreateColorInstrument(form, aColor, true)
	
	backPreview:SetBackgroundTexture(g_texColorBack)
	
	return form
end

function UpdateColorSettingsPanel(aColorPanel, aColor)
	local colorPanelSliders = m_colorPanels[aColorPanel]
	if not colorPanelSliders then
		return
	end

	colorPanelSliders.redSliderObj:Set(aColor.r)
	colorPanelSliders.greenSliderObj:Set(aColor.g)
	colorPanelSliders.blueSliderObj:Set(aColor.b)
	colorPanelSliders.alphaSliderObj:Set(aColor.a)
	
	getChild(aColorPanel, "colorPreview"):SetBackgroundColor(aColor)
end

function SaveBuffColorHighlight(aForm, anInfo)
	anInfo.highlightColor = getChild(aForm, "colorPreview"):GetBackgroundColor()
	anInfo.useHighlightBuff = getCheckBoxState(getChild(aForm, "useHighlightBuffCheckBox"))
	anInfo.blinkHighlight = getCheckBoxState(getChild(aForm, "blinkHighlightCheckBox"))
end

local function ColorPanelPrepareDestroy(aColorPanel)
	local colorPanelSliders = m_colorPanels[aColorPanel]
	if not colorPanelSliders then
		return
	end
	
	colorPanelSliders.redSliderObj:PrepareDestroy()
	colorPanelSliders.greenSliderObj:PrepareDestroy()
	colorPanelSliders.blueSliderObj:PrepareDestroy()
	if colorPanelSliders.alphaSliderObj then
		colorPanelSliders.alphaSliderObj:PrepareDestroy()
	end
	
	m_colorPanels[aColorPanel] = nil
end

function DestroyColorPanel(aColorPanel)
	ColorPanelPrepareDestroy(aColorPanel)
	destroy(aColorPanel)
end