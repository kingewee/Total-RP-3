--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Total RP 3, by Telkostrasz & Ellypse(Kirin Tor - Eu/Fr)
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Minimap button widget
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- Config
local Utils = TRP3_UTILS;
local getConfigValue, registerConfigKey, setConfigValue = TRP3_CONFIG.getValue, TRP3_CONFIG.registerConfigKey, TRP3_CONFIG.setValue;
local math, GetCursorPosition, Minimap, UIParent, cos, sin = math, GetCursorPosition, Minimap, UIParent, cos, sin;
local setTooltipForFrame = TRP3_UI_UTILS.tooltip.setTooltipForFrame;
local color, loc = TRP3_UTILS.str.color, TRP3_L;
local CONFIG_MINIMAP_POS = "minimap_pos";
local minimapButton;


-- Reposition the minimap button using the config values
local function minimapButton_Reposition()
	minimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(getConfigValue(CONFIG_MINIMAP_POS))),(80*sin(getConfigValue(CONFIG_MINIMAP_POS)))-52)
end

-- Function called when the minimap icon is dragged
local function minimapButton_DraggingFrame_OnUpdate(self)
	if self.isDraging then
		local xpos,ypos = GetCursorPosition();
		local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();
	
		xpos = xmin-xpos/UIParent:GetScale()+70;
		ypos = ypos/UIParent:GetScale()-ymin-70;
	
		-- Setting the minimap coordanate
		setConfigValue(CONFIG_MINIMAP_POS,math.deg(math.atan2(ypos,xpos)));
	
		minimapButton_Reposition();
	end
end

-- Initialize the minimap icon button
function TRP3_InitMinimapButton()
	local toggleMainPane, toggleToolbar = TRP3_NAVIGATION.switchMainFrame, TRP3_SwitchToolbar;
	minimapButton = TRP3_MinimapButton;

	registerConfigKey(CONFIG_MINIMAP_POS, 202);

	minimapButton:SetScript("OnUpdate", minimapButton_DraggingFrame_OnUpdate);
	minimapButton:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				-- For some reason, TRP3_SwitchToolbar() is not instanciated at launch
				-- So we will store it the first time so we can use it localy later
				if not toogleToolbar then toogleToolbar = TRP3_SwitchToolbar end
				toogleToolbar();
			else
				toggleMainPane();
			end
		end);
	
	minimapButton_Reposition();

	local minimapTooltip = strconcat(color("y"), loc("CM_L_CLICK"), ": ", color("w"), loc("MM_SHOW_HIDE_MAIN"), "\n",
							color("y"), loc("CM_R_CLICK"), ": ", color("w"), loc("MM_SHOW_HIDE_SHORTCUT"));
	setTooltipForFrame(minimapButton, minimapButton, "BOTTOMLEFT", 0, 0, "Total RP 3", minimapTooltip);
end


