--[[mouse scrollwheel minimap zoom & remove minimap zoom icons]]
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()

Minimap:EnableMouseWheel(true)
Minimap:SetScript('OnMouseWheel', function(self, arg1)
    if arg1 > 0 then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
end)

--[[remove red boarder from loss of control icon]]
LossOfControlFrame.blackBg:SetAlpha(0)
LossOfControlFrame.RedLineTop:SetAlpha(0)
LossOfControlFrame.RedLineBottom:SetAlpha(0)

--[[hide bags bar]]
MicroButtonAndBagsBar:Hide()

--[[remove xp bar]]
StatusTrackingBarManager:Hide()

--[[hide gryphons]]
MainMenuBarArtFrame.RightEndCap:Hide();
MainMenuBarArtFrame.LeftEndCap:Hide();

--[[hide pvp icons]]
PlayerPVPIcon:SetAlpha(0)
TargetFrameTextureFramePVPIcon:SetAlpha(0)
FocusFrameTextureFramePVPIcon:SetAlpha(0)

--[[hide prestige icons]]
PlayerPrestigeBadge:SetAlpha(0)
PlayerPrestigePortrait:SetAlpha(0)
TargetFrameTextureFramePrestigeBadge:SetAlpha(0)
TargetFrameTextureFramePrestigePortrait:SetAlpha(0)
FocusFrameTextureFramePrestigeBadge:SetAlpha(0)
FocusFrameTextureFramePrestigePortrait:SetAlpha(0)

--[[hide actionbar artwork]]
ActionBarUpButton:SetAlpha(0)
ActionBarDownButton:SetAlpha(0)
MainMenuBarArtFrameBackground:Hide()
MainMenuBarArtFrame.PageNumber:Hide()
MultiBarBottomLeft: ClearAllPoints()
MultiBarBottomLeft:SetPoint('TOP', MainMenuBar, 'BOTTOM', 0, 47)

--[[target castbar tweaks]]
TargetFrameSpellBar:ClearAllPoints()
TargetFrameSpellBar:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
TargetFrameSpellBar.SetPoint = function() end
TargetFrameSpellBar:SetScale(1.2)

--[[class colour name/hp bars on unitframes]]
local frame = CreateFrame("FRAME")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:RegisterEvent("UNIT_FACTION")

local function eventHandler(self, event, ...)
	if UnitIsPlayer("target") then
		c = RAID_CLASS_COLORS[select(2, UnitClass("target"))]
		TargetFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
	end
	if UnitIsPlayer("focus") then
		c = RAID_CLASS_COLORS[select(2, UnitClass("focus"))]
		FocusFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
	end
end

frame:SetScript("OnEvent", eventHandler)

for _, BarTextures in pairs({TargetFrameNameBackground, FocusFrameNameBackground}) do
	BarTextures:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
end

local function colour(statusbar, unit)
        local _, class, c
        if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
                _, class = UnitClass(unit)
                c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
                statusbar:SetStatusBarColor(c.r, c.g, c.b)
        end
end

hooksecurefunc("UnitFrameHealthBar_Update", colour)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
        colour(self, self.unit)
end)

--[[auto sell junk & auto repair]]
local g = CreateFrame("Frame")
g:RegisterEvent("MERCHANT_SHOW")

g:SetScript("OnEvent", function()  
        local bag, slot
        for bag = 0, 4 do
                for slot = 0, GetContainerNumSlots(bag) do
                        local link = GetContainerItemLink(bag, slot)
                        if link and (select(3, GetItemInfo(link)) == 0) then
                                UseContainerItem(bag, slot)
                        end
                end
        end

        if(CanMerchantRepair()) then
                local cost = GetRepairAllCost()
                if cost > 0 then
                        local money = GetMoney()
                        if IsInGuild() then
                                local guildMoney = GetGuildBankWithdrawMoney()
                                if guildMoney > GetGuildBankMoney() then
                                        guildMoney = GetGuildBankMoney()
                                end
                                if guildMoney > cost and CanGuildBankRepair() then
                                        RepairAllItems(1)
                                        print(format("|cfff07100Repair cost covered by Guild Bank: %.1fg|r", cost * 0.0001))
                                        return
                                end
                        end
                        if money > cost then
                                RepairAllItems()
                                print(format("|cffead000Repair cost: %.1fg|r", cost * 0.0001))
                        else
                                print("Not enough gold to cover the repair cost.")
                        end
                end
        end
end)