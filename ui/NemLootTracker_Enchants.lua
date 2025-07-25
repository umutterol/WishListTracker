-- NemLootTracker_Enchants.lua
-- Handles the Enchants tab content for Nem Loot Tracker

NemLootTracker_Enchants = {}

function NemLootTracker_Enchants:CreateEnchantsTab(frame, items)
    local enchantsTab = frame.tabContents[3]
    if not items then
        local msg = enchantsTab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        msg:SetPoint("CENTER", enchantsTab, "CENTER", 0, 0)
        msg:SetText("No data available for this class/spec.")
        return
    end
    
    -- Items grid container anchored at top
    local gridContainer = CreateFrame("Frame", nil, enchantsTab)
    gridContainer:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 16, 600)
    gridContainer:SetPoint("TOP", enchantsTab, "TOP", 0, -30)
    gridContainer:SetPoint("CENTER", enchantsTab, "CENTER", 0, 0)
    
    local colWidth = CARD_WIDTH
    local rowHeight = CARD_HEIGHT / 4.5
    local rowPadding = 14
    local numCols = 2
    local numRows = math.ceil(#SLOT_ORDER / numCols)
    -- Determine class and spec for off-hand hiding
    local _, class = UnitClass("player")
    local specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization())
    local specKey = nil
    if class and NemLootTracker_Core and NemLootTracker_Core.SPEC_KEYS and NemLootTracker_Core.SPEC_KEYS[class] then
        specKey = NemLootTracker_Core.SPEC_KEYS[class][specID]
    end
    local hideOffhand = NemLootTracker_Core.ShouldHideOffhand and class and specKey and NemLootTracker_Core:ShouldHideOffhand(class, specKey)
    local enchSlotOrder = {"HEAD","LEGS","BACK","FEET","CHEST","RINGS","WRIST"}
    if items.enchants and items.enchants["MAIN_HAND"] then
        table.insert(enchSlotOrder, "MAIN_HAND")
    end
    if not hideOffhand and items.enchants and items.enchants["OFF_HAND"] then
        table.insert(enchSlotOrder, "OFF_HAND")
    end
    
    for idx, slotKey in ipairs(enchSlotOrder) do
        local col = ((idx - 1) % numCols)
        local row = math.floor((idx - 1) / numCols)
        
        -- Item card frame
        local slotFrame = CreateFrame("Frame", nil, gridContainer, "BackdropTemplate")
        slotFrame:SetSize(colWidth, ICON_SIZE)
        if col == 0 then
            slotFrame:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 8, -row * (ICON_SIZE + rowPadding))
        else
            slotFrame:SetPoint("TOPRIGHT", gridContainer, "TOPRIGHT", -8, -row * (ICON_SIZE + rowPadding))
        end
        slotFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
        slotFrame:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
        slotFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
        
        -- Slot label (no popularity label)
        -- Get enchant for this slot
        local enchant = items.enchants and items.enchants[slotKey]
        if enchant then
            if col == 0 then
                -- Left column: icon first, then name (left-aligned)
                local icon = CreateFrame("Button", nil, slotFrame)
                icon:SetSize(ICON_SIZE, ICON_SIZE)
                icon:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, 0)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                local iconTexture = enchant.icon
                if not iconTexture or iconTexture == "" then
                    iconTexture = GetItemIcon(enchant.id)
                end
                icon.texture:SetTexture(iconTexture)
                icon:SetScript("OnClick", function()
                    if enchant.id then
                        local itemLink = select(2, GetItemInfo(enchant.id))
                        if itemLink then
                            ChatEdit_InsertLink(itemLink)
                        end
                    end
                end)
                icon:SetMotionScriptsWhileDisabled(true)
                icon:EnableMouse(true)
                icon:RegisterForClicks("AnyUp")
                icon:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
                icon:SetScript("OnEnter", function(self)
                    if enchant.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(enchant.id)
                        GameTooltip:Show()
                    end
                end)
                icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Enchant name
                local enchantName = CreateFrame("Button", nil, slotFrame)
                enchantName:SetPoint("TOPLEFT", icon, "TOPRIGHT", 6, 5)
                enchantName:SetWidth(ITEM_WIDTH - ICON_SIZE - 8)
                enchantName:SetHeight(ICON_SIZE)
                enchantName.text = enchantName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                enchantName.text:SetAllPoints()
                enchantName.text:SetJustifyH("LEFT")
                enchantName.text:SetTextColor(163/255, 48/255, 201/255)
                local displayName = enchant.name
                if #displayName > 25 then
                    displayName = string.sub(displayName, 1, 25) .. "..."
                end
                enchantName.text:SetText(displayName)
                enchantName:SetScript("OnClick", function()
                    if enchant.id then
                        local itemLink = select(2, GetItemInfo(enchant.id))
                        if itemLink then
                            ChatEdit_InsertLink(itemLink)
                        end
                    end
                end)
                enchantName:SetScript("OnEnter", function(self)
                    if enchant.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(enchant.id)
                        GameTooltip:Show()
                    end
                end)
                enchantName:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Slot name underneath enchant name
                local slotName = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                slotName:SetPoint("TOPLEFT", enchantName, "BOTTOMLEFT", 0, 10)
                slotName:SetJustifyH("LEFT")
                slotName:SetTextColor(0.7, 0.7, 0.7)
                slotName:SetText(slotKey:gsub("_", "-"):gsub("%u", string.upper, 1):gsub("%l", string.lower, 2))
                
                -- Usage percentage (right side, vertically centered)
                local popText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                popText:SetPoint("RIGHT", slotFrame, "RIGHT", -8, 0)
                popText:SetPoint("CENTER", slotFrame, "CENTER", (colWidth/2)-8, 0)
                popText:SetTextColor(1, 1, 1)
                popText:SetText(enchant.popularity)
            else
                -- Right column: name first (right-aligned), then icon
                local icon = CreateFrame("Button", nil, slotFrame)
                icon:SetSize(ICON_SIZE, ICON_SIZE)
                icon:SetPoint("TOPRIGHT", slotFrame, "TOPRIGHT", 0, 0)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                local iconTexture = enchant.icon
                if not iconTexture or iconTexture == "" then
                    iconTexture = GetItemIcon(enchant.id)
                end
                icon.texture:SetTexture(iconTexture)
                icon:SetScript("OnClick", function()
                    if enchant.id then
                        local itemLink = select(2, GetItemInfo(enchant.id))
                        if itemLink then
                            ChatEdit_InsertLink(itemLink)
                        end
                    end
                end)
                icon:SetMotionScriptsWhileDisabled(true)
                icon:EnableMouse(true)
                icon:RegisterForClicks("AnyUp")
                icon:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
                icon:SetScript("OnEnter", function(self)
                    if enchant.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(enchant.id)
                        GameTooltip:Show()
                    end
                end)
                icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Enchant name (right-aligned)
                local enchantName = CreateFrame("Button", nil, slotFrame)
                enchantName:SetPoint("TOPRIGHT", icon, "TOPLEFT", -6, 5)
                enchantName:SetWidth(ITEM_WIDTH - ICON_SIZE - 8)
                enchantName:SetHeight(ICON_SIZE)
                enchantName.text = enchantName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                enchantName.text:SetAllPoints()
                enchantName.text:SetJustifyH("RIGHT")
                enchantName.text:SetTextColor(163/255, 48/255, 201/255)
                local displayName = enchant.name
                if #displayName > 25 then
                    displayName = string.sub(displayName, 1, 25) .. "..."
                end
                enchantName.text:SetText(displayName)
                enchantName:SetScript("OnClick", function()
                    if enchant.id then
                        local itemLink = select(2, GetItemInfo(enchant.id))
                        if itemLink then
                            ChatEdit_InsertLink(itemLink)
                        end
                    end
                end)
                enchantName:SetScript("OnEnter", function(self)
                    if enchant.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(enchant.id)
                        GameTooltip:Show()
                    end
                end)
                enchantName:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Slot name underneath enchant name (right-aligned)
                local slotName = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                slotName:SetPoint("TOPRIGHT", enchantName, "BOTTOMRIGHT", 0, 10)
                slotName:SetJustifyH("RIGHT")
                slotName:SetTextColor(0.7, 0.7, 0.7)
                slotName:SetText(slotKey:gsub("_", "-"):gsub("%u", string.upper, 1):gsub("%l", string.lower, 2))
                
                -- Usage percentage (left side, vertically centered)
                local popText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                popText:SetPoint("LEFT", slotFrame, "LEFT", 8, 0)
                popText:SetPoint("CENTER", slotFrame, "CENTER", -(colWidth/2)+8, 0)
                popText:SetTextColor(1, 1, 1)
                popText:SetText(enchant.popularity)
            end
        end
    end
    -- Add Gems Section below the enchants grid
    -- After the enchants grid, position the gemsParentContainer further down
    -- Calculate dynamic height for gems containers
    local epicGems = items and items.epic_gems or {}
    local gems = items and items.gems or {}
    local epicCount = #epicGems
    local gemsCount = #gems
    local epicHeight = 24 + epicCount * (rowHeight + 4)
    local gemsHeight = 24 + gemsCount * (rowHeight + 4)
    local gemsContainerHeight = math.max(epicHeight, gemsHeight)
    -- Parent container for both gems sections
    local gemsParentContainer = CreateFrame("Frame", nil, enchantsTab)
    gemsParentContainer:SetSize(CARD_WIDTH * 2 + 20, gemsContainerHeight)
    gemsParentContainer:SetPoint("CENTER", enchantsTab, "CENTER", 0, -50)
    -- Epic Gems Container (left)
    local epicContainer = CreateFrame("Frame", nil, gemsParentContainer)
    epicContainer:SetSize(CARD_WIDTH, ICON_SIZE)
    epicContainer:SetPoint("TOPLEFT", gemsParentContainer, "TOPLEFT", 0, 0)
    -- Epic Gems Header
    local epicHeader = epicContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    epicHeader:SetPoint("TOPLEFT", epicContainer, "TOPLEFT",0, 25)
    epicHeader:SetText("Epic Gems")
    for i, gem in ipairs(epicGems) do
        local card = CreateFrame("Frame", nil, epicContainer, "BackdropTemplate")
        card:SetSize(CARD_WIDTH, ICON_SIZE)
        card:SetPoint("TOPLEFT", epicContainer, "TOPLEFT", 0, (i-1) * -(ICON_SIZE + 4))
        card:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
        card:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
        card:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
        -- Icon (left)
        local icon = CreateFrame("Button", nil, card)
        icon:SetSize(ICON_SIZE, ICON_SIZE)
        icon:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexture(gem.icon or GetItemIcon(gem.id))
        icon:SetScript("OnClick", function()
            if IsModifiedClick("CHATLINK") then
                local itemLink = select(2, GetItemInfo(gem.id))
                if itemLink then
                    ChatEdit_InsertLink(itemLink)
                end
            end
        end)
        icon:SetMotionScriptsWhileDisabled(true)
        icon:EnableMouse(true)
        icon:RegisterForClicks("AnyUp")
        icon:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
        icon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(gem.id)
            GameTooltip:Show()
        end)
        icon:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        -- Name (left-aligned, y-offset 5)
        local nameBtn = CreateFrame("Button", nil, card)
        nameBtn:SetPoint("TOPLEFT", icon, "TOPRIGHT", 6, 5)
        nameBtn:SetWidth(CARD_WIDTH - ICON_SIZE - 8)
        nameBtn:SetHeight(ICON_SIZE)
        nameBtn.text = nameBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameBtn.text:SetAllPoints()
        nameBtn.text:SetJustifyH("LEFT")
        nameBtn.text:SetTextColor(163/255, 48/255, 201/255)
        local displayName = gem.name
        if #displayName > 25 then
            displayName = string.sub(displayName, 1, 25) .. "..."
        end
        nameBtn.text:SetText(displayName)
        nameBtn:SetScript("OnClick", function()
            local itemLink = select(2, GetItemInfo(gem.id))
            if itemLink then
                ChatEdit_InsertLink(itemLink)
            end
        end)
        nameBtn:EnableMouse(true)
        nameBtn:RegisterForClicks("AnyUp")
        nameBtn:SetMotionScriptsWhileDisabled(true)
        nameBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(gem.id)
            GameTooltip:Show()
        end)
        nameBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        -- Slot name (below name, y-offset 10)
        local slotName = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slotName:SetPoint("TOPLEFT", nameBtn, "BOTTOMLEFT", 0, 10)
        slotName:SetJustifyH("LEFT")
        slotName:SetTextColor(0.7, 0.7, 0.7)
        slotName:SetText("Epic Gem")
        -- Popularity (right, vertically centered)
        local popText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        popText:SetPoint("RIGHT", card, "RIGHT", -8, 0)
        popText:SetTextColor(1, 1, 1)
        popText:SetText(gem.popularity)
    end
    -- Gems Container (right)
    local gemsContainer = CreateFrame("Frame", nil, gemsParentContainer)
    gemsContainer:SetSize(CARD_WIDTH, ICON_SIZE)
    gemsContainer:SetPoint("TOPLEFT", gemsParentContainer, "TOPLEFT", CARD_WIDTH+20, 0)
        -- Gems Header
    local gemsHeader = gemsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    gemsHeader:SetPoint("TOPRIGHT", gemsContainer, "TOPRIGHT", 0, 25)
    gemsHeader:SetText("Gems")
    for i, gem in ipairs(gems) do
        local card = CreateFrame("Frame", nil, gemsContainer, "BackdropTemplate")
        card:SetSize(CARD_WIDTH, ICON_SIZE)
        card:SetPoint("TOPLEFT", gemsContainer, "TOPLEFT", 0, (i-1) * -(ICON_SIZE + 4))
        card:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
        card:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
        card:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
        -- Icon (right)
        local icon = CreateFrame("Button", nil, card)
        icon:SetSize(ICON_SIZE, ICON_SIZE)
        icon:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexture(gem.icon or GetItemIcon(gem.id))
        icon:SetScript("OnClick", function()
            if IsModifiedClick("CHATLINK") then
                local itemLink = select(2, GetItemInfo(gem.id))
                if itemLink then
                    ChatEdit_InsertLink(itemLink)
                end
            end
        end)
        icon:SetMotionScriptsWhileDisabled(true)
        icon:EnableMouse(true)
        icon:RegisterForClicks("AnyUp")
        icon:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
        icon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(gem.id)
            GameTooltip:Show()
        end)
        icon:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        -- Name (right-aligned, y-offset 5)
        local nameBtn = CreateFrame("Button", nil, card)
        nameBtn:SetPoint("TOPRIGHT", icon, "TOPLEFT", -6, 5)
        nameBtn:SetWidth(CARD_WIDTH - ICON_SIZE - 8)
        nameBtn:SetHeight(ICON_SIZE)
        nameBtn.text = nameBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameBtn.text:SetAllPoints()
        nameBtn.text:SetJustifyH("RIGHT")
        nameBtn.text:SetTextColor(163/255, 48/255, 201/255)
        local displayName = gem.name
        if #displayName > 25 then
            displayName = string.sub(displayName, 1, 25) .. "..."
        end
        nameBtn.text:SetText(displayName)
        nameBtn:SetScript("OnClick", function()
            local itemLink = select(2, GetItemInfo(gem.id))
            if itemLink then
                ChatEdit_InsertLink(itemLink)
            end
        end)
        nameBtn:EnableMouse(true)
        nameBtn:RegisterForClicks("AnyUp")
        nameBtn:SetMotionScriptsWhileDisabled(true)
        nameBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(gem.id)
            GameTooltip:Show()
        end)
        nameBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        -- Slot name (below name, y-offset 10)
        local slotName = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slotName:SetPoint("TOPRIGHT", nameBtn, "BOTTOMRIGHT", 0, 10)
        slotName:SetJustifyH("RIGHT")
        slotName:SetTextColor(0.7, 0.7, 0.7)
        slotName:SetText("Gem")
        -- Popularity (left, vertically centered)
        local popText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        popText:SetPoint("LEFT", card, "LEFT", 8, 0)
        popText:SetTextColor(1, 1, 1)
        popText:SetText(gem.popularity)
    end
end 