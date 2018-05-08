----------------------------------------------------------------------------------
--- Total RP 3
---
--- New module manager, based on Telkostrasz's module management system
--- This new system uses a more object oriented design pattern
--- and offers more freedom when registering modules
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
local assert = assert;
local pairs = pairs;

-- Ellyb imports
local GREY = Ellyb.ColorManager.GREY;

local ModulesManager = {};
local modulesHaveBeenInitialized = false;

local MODULE_STATUS = {
	READY = -1,
	MISSING_DEPENDENCY = 0,
	OUT_TO_DATE_TRP3 = 1,
	ERROR_ON_INIT = 2,
	ERROR_ON_LOAD = 3,
	DISABLED = 4,
	OK = 5,
}
ModulesManager.MODULE_STATUS = MODULE_STATUS;

local ERRORS = {
	MODULE_ALREADY_EXISTS = "Trying to register a new module with the module ID " .. GREY("%s") .. " but a module already exists for that ID.",
	MODULES_ALREADY_INITIALIZED = "Trying to register module " .. GREY("%s") .. " after the modules have already been initialized. Modules should be registered before."
}

---@type table<string, TRP3_Module>
local modules = {};
---@type table<string, boolean>
local modulesEnabledStatus = {}

---@param module TRP3_Module
function ModulesManager.addModule(module)
	assert(not modules[module:GetID()], ERRORS.MODULE_ALREADY_EXISTS:format(module:GetID()));

	modules[module:GetID()] = module;
	module:SetStatus(MODULE_STATUS.READY);

	-- If the modules have already been initialized, we fire up this module right away
	if modulesHaveBeenInitialized then
		module:SetStatus(MODULE_STATUS.OK);
		module:Initialize();
		module:Start();
	end
end

function ModulesManager.initializeModules()
	for moduleID, module in pairs(modules) do
		if module:GetStatus() == nil then
			module:SetStatus(MODULE_STATUS.OK);
			module:Initialize();
		end
	end
end

function ModulesManager.startModules()
	for moduleID, module in pairs(modules) do
		if module:GetStatus() == MODULE_STATUS.OK then
			module:Start();
		end
	end
end

---@return TRP3_Module
function ModulesManager.getModule(moduleID)
	return modules[moduleID];
end

function ModulesManager.getModules()
	return modules;
end

function ModulesManager.isEnabledModule(moduleID)
	return modulesEnabledStatus[moduleID] == true;
end

function ModulesManager.setModuleEnabledStatus(moduleID, status)
	modulesEnabledStatus[moduleID] = true;
end

function ModulesManager.initialize()
	assert(TRP3_Configuration, "TRP3_Configuration should be set. Problem in the include sequence ?");
	modulesHaveBeenInitialized = true;
	if not TRP3_Configuration.MODULE_ACTIVATION then
		TRP3_Configuration.MODULE_ACTIVATION = {};
	end
	modulesEnabledStatus = TRP3_Configuration.MODULE_ACTIVATION;

	for moduleID, module in pairs(modules) do
		module:SetStatus(MODULE_STATUS.READY);

		-- No status saved for this module, this is a new module
		if modulesEnabledStatus[module:GetID()] == nil then
			modulesEnabledStatus[module:GetID()] = module:IsAutoEnabled();
		end

		-- If saved status is disable, then disable the module
		if modulesEnabledStatus[module:GetID()] == false then
			module:SetStatus(MODULE_STATUS.DISABLED);
		else
			-- Check if the module requires a higher version of Total RP 3
			if not module:GetMinimumRequiredTRPVersion() <= TRP3_API.globals.version then
				module:SetStatus(MODULE_STATUS.OUT_TO_DATE_TRP3);
			--
			elseif not module:AreDependenciesValidated() then
				module:SetStatus(MODULE_STATUS.MISSING_DEPENDENCY);
			end
		end
	end
end


TRP3_API.ModulesManager = ModulesManager;