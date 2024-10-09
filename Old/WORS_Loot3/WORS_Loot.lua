-- Create the main frame
local WORS_Loot = CreateFrame("Frame", "WORS_Loot", UIParent)
WORS_Loot:SetSize(800, 450)
WORS_Loot:SetPoint("CENTER")
WORS_Loot:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
WORS_Loot:SetBackdropColor(0, 0, 0, 1)
WORS_Loot:Hide()

-- Title
local title = WORS_Loot:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("WORS Loot")

-- Dropdowns
local moduleDropdown = CreateFrame("Frame", "WORS_Loot_ModuleDropdown", WORS_Loot, "UIDropDownMenuTemplate")
moduleDropdown:SetPoint("TOPLEFT", WORS_Loot, "TOPLEFT", 20, -30)
UIDropDownMenu_SetWidth(moduleDropdown, 130)

local subcategoryDropdown = CreateFrame("Frame", "WORS_Loot_SubcategoryDropdown", WORS_Loot, "UIDropDownMenuTemplate")
subcategoryDropdown:SetPoint("TOPLEFT", moduleDropdown, "TOPLEFT", 160, 0)
UIDropDownMenu_SetWidth(subcategoryDropdown, 130)

local thirdDropdown = CreateFrame("Frame", "WORS_Loot_ThirdDropdown", WORS_Loot, "UIDropDownMenuTemplate")
thirdDropdown:SetPoint("TOPLEFT", subcategoryDropdown, "TOPLEFT", 160, 0)
UIDropDownMenu_SetWidth(thirdDropdown, 130)

-- Loot Table Frame
local lootTableFrame = CreateFrame("ScrollFrame", "WORS_Loot_LootTable", WORS_Loot, "UIPanelScrollFrameTemplate")
lootTableFrame:SetSize(250, 400)
lootTableFrame:SetPoint("TOPRIGHT", WORS_Loot, "TOPRIGHT", -30, -30)
lootTableFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
lootTableFrame:SetBackdropColor(0, 0, 0, 1)

local lootContent = CreateFrame("Frame", nil, lootTableFrame)
lootContent:SetSize(250, 400)
lootTableFrame:SetScrollChild(lootContent)

local lootItems = {}

-- Clear Loot Content
local function ClearLootContent()
    for _, item in ipairs(lootItems) do
        item:Hide()
        item:ClearAllPoints()  -- Clear position to reset
    end
    wipe(lootItems)
end

-- Create clickable item link with icon using item ID
-- Create clickable item link with icon using item ID
local function CreateLootButton(itemId, index)
    local lootButton = CreateFrame("Button", nil, lootContent)
    lootButton:SetSize(200, 20)  -- Button size
    lootButton:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((index - 1) * 25))

    -- Set the item icon
    local itemIcon = lootButton:CreateTexture(nil, "ARTWORK")
    itemIcon:SetSize(20, 20)  -- Icon size
    itemIcon:SetPoint("LEFT", lootButton, "LEFT", 0, 0)
    itemIcon:SetTexture(GetItemIcon(itemId))  -- Get the item icon

    -- Set up item tooltip functionality
    lootButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(GetItemLink(itemId))  -- Display the item tooltip
        GameTooltip:Show()
    end)
    lootButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    lootButton:SetText(GetItemInfo(itemId) or "Unknown Item")  -- Set the item name
    lootButton:SetNormalFontObject("GameFontNormal")  -- Use normal font for the button

    -- Set the button to link the item when clicked
    lootButton:SetScript("OnClick", function(self, button)
        print("Button clicked for itemId: " .. itemId)  -- Debug message

        -- Get the item link
        local itemLink = GetItemLink(itemId)
        print("Item link for itemId " .. itemId .. ": " .. itemLink)  -- Debug print
		ChatFrame_OpenChat(itemLink, SELECTED_CHAT_FRAME)  -- Link item in chat
        if itemLink then
            -- Link item in chat when clicked
            ChatFrame_OpenChat(itemLink, SELECTED_CHAT_FRAME)  -- Link item in chat
            print("Linked item: " .. itemLink)  -- Debug message
        else
            print("Item link not found for itemId: " .. itemId)  -- Debug message
        end

        -- Additional check for item info
        local itemName, _, itemRarity = GetItemInfo(itemId)
        if itemName then
            print("Item info - Name: " .. itemName .. ", Rarity: " .. tostring(itemRarity))
        else
            print("Item info not found for itemId: " .. itemId)
        end
    end)

    lootButton:Show()  -- Show the button
    return lootButton
end

-- Update Loot Table based on selection
local function UpdateLootTable(selectedMaster, selectedTask)
    ClearLootContent()
    local lootEntries
    if selectedMaster and selectedTask then
        lootEntries = WORS_Loot_Slayer_Data[selectedMaster][selectedTask]
    elseif selectedTask then
        lootEntries = WORS_Loot_Boss_Data[selectedTask]
    end
    if lootEntries then
        for i, itemId in ipairs(lootEntries) do
            local lootButton = CreateLootButton(itemId, i)
            lootButton:SetParent(lootContent)  -- Set the button's parent to the content frame
            table.insert(lootItems, lootButton)  -- Store the button in the lootItems table
        end
    end
end

-- Update Subcategory for Slayer
local function UpdateSlayerTasks(selectedMaster)
    UIDropDownMenu_ClearAll(thirdDropdown)
    UIDropDownMenu_SetText(thirdDropdown, "Select Task")
    
    local tasks = WORS_Loot_Slayer_Data[selectedMaster]
    UIDropDownMenu_Initialize(thirdDropdown, function(self, level)
        for task, _ in pairs(tasks) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = task
            info.func = function()
                UIDropDownMenu_SetText(thirdDropdown, task)
                UpdateLootTable(selectedMaster, task)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end

-- Update Subcategory Dropdown
local function UpdateSubcategoryDropdown(selectedModule)
    UIDropDownMenu_ClearAll(subcategoryDropdown)
    UIDropDownMenu_ClearAll(thirdDropdown)
    UIDropDownMenu_SetText(thirdDropdown, "")

    if selectedModule == "Bosses" then
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Boss")
        local bosses = {"King Black Dragon", "Kalphite Queen"}
        UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
            for _, boss in ipairs(bosses) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = boss
                info.func = function()
                    UIDropDownMenu_SetText(subcategoryDropdown, boss)
                    UpdateLootTable(nil, boss)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    elseif selectedModule == "Slayer" then
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Slayer Master")
        local slayerMasters = {"Turael", "Mazchna", "Vannaka"}
        UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
            for _, master in ipairs(slayerMasters) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = master
                info.func = function()
                    UIDropDownMenu_SetText(subcategoryDropdown, master)
                    UpdateSlayerTasks(master)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
end

-- Initialize Module Dropdown
UIDropDownMenu_SetText(moduleDropdown, "Select Module")
local modules = {"Bosses", "Slayer"}
UIDropDownMenu_Initialize(moduleDropdown, function(self, level)
    for _, module in ipairs(modules) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = module
        info.func = function()
            UIDropDownMenu_SetText(moduleDropdown, module)
            UpdateSubcategoryDropdown(module)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- Command to toggle the main frame
SLASH_WORSLOOT1 = "/worsloot"
function SlashCmdList.WORSLOOT(msg, editBox)
    if WORS_Loot:IsShown() then
        WORS_Loot:Hide()
    else
        WORS_Loot:Show()
    end
end

-- Show the main frame initially (optional)
-- WORS_Loot:Show() -- Uncomment this if you want it to show on load
