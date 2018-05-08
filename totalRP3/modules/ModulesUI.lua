----------------------------------------------------------------------------------
--- Total RP 3
---
--- Modules UI code, based on Telkostrasz's module management system
---	---------------------------------------------------------------------------
---	Copyright 2018 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
---	Licensed under the Apache License, Version 2.0 (the "License");
---	you may not use this file except in compliance with the License.
---	You may obtain a copy of the License at
---
---		http://www.apache.org/licenses/LICENSE-2.0
---
---	Unless required by applicable law or agreed to in writing, software
---	distributed under the License is distributed on an "AS IS" BASIS,
---	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
---	See the License for the specific language governing permissions and
---	limitations under the License.
----------------------------------------------------------------------------------

---@type TRP3_API
local _, TRP3_API = ...;
local Ellyb = Ellyb(...);

-- Lua imports
local pairs = pairs;
local insert = table.insert;

-- Total RP 3 imports
local loc = TRP3_API.loc;
local registerPage = TRP3_API.navigation.page.registerPage;
local setPage = TRP3_API.navigation.page.setPage;
local registerMenu = TRP3_API.navigation.menu.registerMenu;
local displayDropDown = TRP3_API.ui.listbox.displayDropDown;
local ModulesManager = TRP3_API.ModulesManager;
local MODULE_STATUS = ModulesManager.MODULE_STATUS;

-- Ellyb imports
local GREEN, RED, GREY = Ellyb.ColorManager.GREEN, Ellyb.ColorManager.RED, Ellyb.ColorManager.GREY;

local function moduleStatusNumberToText(statusCode)
	if statusCode == MODULE_STATUS.OK then
		return GREEN(loc.CO_MODULES_STATUS_1);
	elseif statusCode == MODULE_STATUS.DISABLED then
		return GREY(loc.CO_MODULES_STATUS_2);
	elseif statusCode == MODULE_STATUS.OUT_TO_DATE_TRP3 then
		return RED(loc.CO_MODULES_STATUS_3);
	elseif statusCode == MODULE_STATUS.ERROR_ON_INIT then
		return RED(loc.CO_MODULES_STATUS_4);
	elseif statusCode == MODULE_STATUS.ERROR_ON_LOAD then
		return RED(loc.CO_MODULES_STATUS_5);
	elseif statusCode == MODULE_STATUS.MISSING_DEPENDENCY then
		return RED(loc.CO_MODULES_STATUS_0);
	end
	error("Unknown status code");
end


-- Resizing
TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_RESIZED, function(containerWidth, containerHeight)
	TRP3_ConfigurationModuleContainer:SetSize(containerWidth - 70, 50);
end);

TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()

	local TUTORIAL_STRUCTURE = {
		{
			box = {
				allPoints = TRP3_ConfigurationModuleFrame,
			},
			button = {
				x = 0, y = 10, anchor = "BOTTOM",
				text = loc.CO_MODULES_TUTO,
				textWidth = 425,
				arrow = "UP"
			}
		},
	}

	registerPage({
		id = "main_config_module",
		templateName = "TRP3_ConfigurationModule",
		frameName = "TRP3_ConfigurationModule",
		frame = TRP3_ConfigurationModule,
		tutorialProvider = function()
			return TUTORIAL_STRUCTURE;
		end,
	});
	registerMenu({
		id = "main_99_config_mod",
		text = loc.CO_MODULES,
		isChildOf = "main_90_config",
		onSelected = function() setPage("main_config_module"); end,
	});

	---@type TRP3_Module[]
	local modules = ModulesManager.getModules();
	table.sort(modules, function(a, b) return a:GetName() < b:GetName() end);

	local previous;
	for _, module in pairs(modules) do
		---@type TRP3_ModuleManagerLineMixin
		local line = CreateFrame("Frame", nil, TRP3_ConfigurationModuleContainer, "TRP3_ConfigurationModuleFrame");
		line:SetPreviousLine(previous);
		line:Setup(module);
		previous = line;
	end
end);

---@type Frame|{Name:FontString,ModuleID:FontString,ModuleVersion:FontString, Status:FontString, ActionButton:Button|ScriptObject}
TRP3_ModuleManagerLineMixin = {};

function TRP3_ModuleManagerLineMixin:OnLoad()
	self:SetPoint("LEFT", 0, 0);
	self:SetPoint("RIGHT", 0, 0);
	self:SetPoint("TOP", 0, 0);

	self.ActionButton:SetScript("OnClick", self.OnActionButtonClicked);
	Ellyb.Tooltips.getTooltip(self.ActionButton):SetTitle(loc.CM_ACTIONS);
end

function TRP3_ModuleManagerLineMixin:SetPreviousLine(previousLine)
	if previousLine then
		self:SetPoint("TOP", previousLine, "BOTTOM", 0, 0);
	end
end

---@param module TRP3_Module
function TRP3_ModuleManagerLineMixin:Setup(module)

	self.module = module;

	-- Building the basic UI
	self.Name:SetText(module:GetName());
	self.ModuleVersion:SetText(loc.CO_MODULES_VERSION:format(module:GetVersion()));
	self.ModuleID:SetText(loc.CO_MODULES_ID:format(module:GetID()));
	self.Status:SetText(loc.CO_MODULES_STATUS:format(moduleStatusNumberToText(module:GetStatus())));

	-- Set the border color depending on the module status
	if module:GetStatus() == MODULE_STATUS.OK then
		self:SetBackdropBorderColor(GREEN:GetRGB());
	elseif module:GetStatus() == MODULE_STATUS.DISABLED then
		self:SetBackdropBorderColor(GREY:GetRGB());
	else
		self:SetBackdropBorderColor(RED:GetRGB());
	end

	-- Build tooltip informations
	local tooltip = Ellyb.Tooltips.getTooltip(self);
	tooltip:SetTitle(module:GetName());
	tooltip:AddLine(module:GetDescription())
	tooltip:AddLine(
			loc.CO_MODULES_TT_TRP_2:format(module:GetMinimumRequiredTRPVersion()),
			module:GetStatus() == MODULE_STATUS.OUT_TO_DATE_TRP3 and RED or GREEN
	)

	-- List module dependencies
	if module:HasRequiredDependencies() then
		tooltip:AddLine(loc.CO_MODULES_TT_DEPS .. ": ");
		for dependencyID, dependencyVersion in pairs(self:GetRequiredDependencies()) do
			local dependency = ModulesManager.getModule(dependencyID);

			if not dependency then
				-- Module is missing
				tooltip:AddLine(RED(loc.CO_MODULES_TT_DEP_MISSING:format(dependencyID)));

			elseif dependency:GetVersion() <= dependencyVersion then
				-- Module is outdated
				tooltip:AddLine(loc.CO_MODULES_TT_DEP_2:format(dependency:GetName(), dependencyVersion, RED(dependency:GetVersion())));

			elseif not dependency:IsEnabled() then
				-- Module is disabled
				tooltip:AddLine(loc.CO_MODULES_TT_DEP_DISABLED:format(dependency:GetName()));
			else
				-- Module is available, everything is fine
				tooltip:AddLine(loc.CO_MODULES_TT_DEP_2:format(dependency:GetName(), dependencyVersion, GREEN(dependency:GetVersion())));
			end
		end
	end

	if module:GetError() then
		tooltip:AddLine(loc.CO_MODULES_TT_ERROR:format(module:GetError()));
	end
end

function TRP3_ModuleManagerLineMixin:OnActionButtonClicked()
	---@type TRP3_Module
	local module = self:GetParent().module;
	local values = {};
	if module:IsEnabled() then
		insert(values, {loc.CO_MODULES_DISABLE, 1});
	else
		insert(values, {loc.CO_MODULES_ENABLE, 2});
	end
	displayDropDown(self, values, function(value)
		if value == 1 then
			module:Enable();
		elseif value == 2 then
			module:Disable();
		end
		ReloadUI();
	end , 0, true);
end