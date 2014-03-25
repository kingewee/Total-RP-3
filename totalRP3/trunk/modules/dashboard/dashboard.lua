--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Total RP 3
-- Telkostrasz & Ellypse
-- Dashboard page
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_DASHBOARD = {};

-- imports
local loc = TRP3_L;
local getcharacter = TRP3_PROFILE.getCharacter;
local Utils = TRP3_UTILS;
local setupListBox = TRP3_UI_UTILS.listbox.setupListBox;
local setTooltipForSameFrame = TRP3_UI_UTILS.tooltip.setTooltipForSameFrame;

-- The variable which gonna make people cry : Currently status characters limit. :D
local CURRENTLY_SIZE = 200;

local function onStatusChange(status)
	local character = getcharacter();
	local old = character.RP;
	character.RP = status;
	if old ~= status then
		character.v = Utils.math.incrementNumber(character.v or 1, 2);
	end
end

local function onStatusXPChange(status)
	local character = getcharacter();
	local old = character.XP;
	character.XP = status;
	if old ~= status then
		character.v = Utils.math.incrementNumber(character.v or 1, 2);
	end
end

local function onCurrentlyChanged()
	local character = getcharacter();
	local old = character.CU;
	character.CU = TRP3_DashboardStatus_Currently:GetText();
	if old ~= character.CU then
		character.v = Utils.math.incrementNumber(character.v or 1, 2);
	end
end

local function onShow(context)
	local character = getcharacter();
	TRP3_DashboardStatus_CharactStatusList:SetSelectedValue(character.RP or 1);
	TRP3_DashboardStatus_XPStatusList:SetSelectedValue(character.XP or 2);
	TRP3_DashboardStatus_Currently:SetText(character.CU or "");
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_DASHBOARD.init = function()

	TRP3_RegisterMenu({
		id = "main_00_dashboard",
		align = "CENTER",
		text = TRP3_GLOBALS.addon_name,
		onSelected = function() TRP3_SetPage("dashboard"); end,
	});
	
	TRP3_RegisterPage({
		id = "dashboard",
		frame = TRP3_Dashboard,
		onPagePostShow = onShow,
	});
	
	TRP3_FieldSet_SetCaption(TRP3_DashboardStatus, loc("DB_STATUS"), 150);
	TRP3_FieldSet_SetCaption(TRP3_DashboardNotifications, loc("DB_NOTIFICATIONS"), 150);
	TRP3_DashboardStatus_CurrentlyText:SetText(loc("DB_STATUS_CURRENTLY"));
	TRP3_DashboardNotifications_No:SetText(loc("DB_NOTIFICATIONS_NO"));
	setTooltipForSameFrame(TRP3_DashboardStatus_CurrentlyHelp, "LEFT", 0, 5, loc("DB_STATUS_CURRENTLY"), loc("DB_STATUS_CURRENTLY_TT"));
	TRP3_DashboardStatus_Currently:SetScript("OnTextChanged", onCurrentlyChanged);
	
	TRP3_DashboardStatus_Currently:SetMaxLetters(CURRENTLY_SIZE);
	
	TRP3_DashboardStatus_CharactStatus:SetText(loc("DB_STATUS_RP"));
	local statusTab = {
		{loc("DB_STATUS_RP_IC"), 1},
		{loc("DB_STATUS_RP_OOC"), 2},
	};
	setupListBox(TRP3_DashboardStatus_CharactStatusList, statusTab, onStatusChange, nil, 120, true);
	
	TRP3_DashboardStatus_XPStatus:SetText(loc("DB_STATUS_XP"));
	local xpTab = {
		{loc("DB_STATUS_XP_BEGINNER"), 1},
		{loc("DB_STATUS_RP_EXP"), 2},
		{loc("DB_STATUS_RP_VOLUNTEER"), 3},
	};
	setupListBox(TRP3_DashboardStatus_XPStatusList, xpTab, onStatusXPChange, nil, 120, true);
	
end