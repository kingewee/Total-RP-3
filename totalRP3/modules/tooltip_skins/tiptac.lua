----------------------------------------------------------------------------------
-- Total RP 3
-- TipTac plugin
-- ---------------------------------------------------------------------------
-- Copyright 2017 Renaud "Ellypse" Parize (ellypse@totalrp3.info)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------------------

---@type TRP3_API
local _, TRP3_API = TRP3_API;

local loc = TRP3_API.loc;

local TipTacModule = TRP3_API.Module(
		"trp3_tiptac",
		"TipTac",
		loc.MO_TOOLTIP_CUSTOMIZATIONS_DESCRIPTION:format("TipTac"),
		1.2,
		45
);

function TipTacModule:Initialize()
	-- Stop right here if TipTac is not installed
	if not TipTac then
		TipTacModule:SetStatus(TRP3_API.ModulesManager.MODULE_STATUS.MISSING_DEPENDENCY);
		TipTacModule:SetError(loc.MO_ADDON_NOT_INSTALLED:format("TipTac"));
		return
	end
end

function TipTacModule:Start()
	-- List of the tooltips we want to be customized by TipTac
	local TOOLTIPS = {
		-- Total RP 3
		"TRP3_MainTooltip",
		"TRP3_CharacterTooltip",
		"TRP3_CompanionTooltip",
		-- Total RP 3: Extended
		"TRP3_ItemTooltip",
		"TRP3_NPCTooltip"
	}

	-- Wait for the add-on to be fully loaded so all the tooltips are available
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_FINISH, function()

		-- Go through each tooltips from our table
		for _, tooltip in pairs(TOOLTIPS) do
			if _G[tooltip] then -- We check that the tooltip exists and then add it to TipTac
				TipTac:AddModifiedTip(_G[tooltip]);
			end
		end

	end);
end