----------------------------------------------------------------------------------
--- Total RP 3
---
--- New module model, based on Telkostrasz's module management system
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
local isType = Ellyb.Assertions.isType;
local ModulesManager = TRP3_API.ModulesManager;

---@class TRP3_Module : Object
local Module, _private = Ellyb.Class("Total RP 3 Module");

function Module:initialize(ID, name, description, version, minTRP3Version, requiredDependencies)
	assert(isType(ID, "string", "ID"));
	assert(isType(name, "string", "name"));
	assert(isType(description, "string", "description"));
	assert(isType(version, "number", "version"));
	assert(isType(minTRP3Version, "number", "minTRP3Version"));
	if requiredDependencies ~= nil then
		assert(isType(requiredDependencies, "table", "requiredDependencies"));
	else
		requiredDependencies = {};
	end

	_private[self] = {};

	_private[self].ID = ID;
	_private[self].name = name;
	_private[self].description = description;
	_private[self].version = version;
	_private[self].minTRP3Version = minTRP3Version;
	_private[self].requiredDependencies = requiredDependencies;

	ModulesManager.addModule(self);
end

function Module:GetName()
	return _private[self].name;
end

function Module:GetDescription()
	return _private[self].description;
end

function Module:GetID()
	return _private[self].ID;
end

function Module:SetStatus(status)
	_private[self].status = status;
end

function Module:GetStatus()
	return _private[self].status;
end

function Module:GetVersion()
	return _private[self].version;
end

function Module:IsEnabled()
	return TRP3_API.ModulesManager.isEnabledModule(self:GetID());
end

function Module:Enable()
	TRP3_API.ModulesManager.setModuleEnabledStatus(self:GetID(), true);
end

function Module:Disable()
	TRP3_API.ModulesManager.setModuleEnabledStatus(self:GetID(), false);
end

function Module:GetMinimumRequiredTRPVersion()
	return _private[self].minTRP3Version;
end

function Module:HasRequiredDependencies()
	return Ellyb.Tables.size(self:GetRequiredDependencies()) > 0;
end

function Module:GetRequiredDependencies()
	return _private[self].requiredDependencies;
end

function Module:AreDependenciesValidated()
	for dependencyID, dependencyVersion in pairs(self:GetRequiredDependencies()) do
		local dependency = TRP3_API.ModulesManager.getModule(dependencyID);
		-- If a dependency is missing, out of date or not enabled, it is not valid
		if not dependency and dependency:GetVersion() >= dependencyVersion and dependency:IsEnabled() then
			return false;
		end
	end
	return true;
end

function Module:SetAutoEnabled(autoEnable)
	assert(isType(autoEnable, "boolean", "autoEnable"));
	return _private[self].autoEnable;
end

function Module:IsAutoEnabled()
	return _private[self].autoEnable == true;
end

function Module:SetError(error)
	_private[self].error = error;
end

function Module:GetError()
	return _private[self].error;
end

--[[ Override ]] function Module:Initialize()

end

--[[ Override ]] function Module:Start()

end

TRP3_API.Module = Module;