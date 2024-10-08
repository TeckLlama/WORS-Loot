-- WORS_Loot.lua

-- Create the main frame
local WORS_Loot = CreateFrame("Frame", "WORS_Loot", UIParent)
WORS_Loot:SetSize(800, 450)  -- Set window size to 800x450
WORS_Loot:SetPoint("CENTER")
WORS_Loot:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
WORS_Loot:SetBackdropColor(0, 0, 0, 1)
WORS_Loot:Hide()

-- Create the title
local title = WORS_Loot:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("WORS Loot")

-- Create the module dropdown
local moduleDropdown = CreateFrame("Frame", "WORS_Loot_ModuleDropdown", WORS_Loot, "UIDropDownMenuTemplate")
moduleDropdown:SetPoint("TOPLEFT", WORS_Loot, "TOPLEFT", 20, -30)

-- Create the subcategory dropdown
local subcategoryDropdown = CreateFrame("Frame", "WORS_Loot_SubcategoryDropdown", WORS_Loot, "UIDropDownMenuTemplate")
subcategoryDropdown:SetPoint("TOPLEFT", moduleDropdown, "TOPLEFT", 160, 0)

-- Create a loot table frame
local lootTableFrame = CreateFrame("ScrollFrame", "WORS_Loot_LootTable", WORS_Loot, "UIPanelScrollFrameTemplate")
lootTableFrame:SetSize(250, 400)  
lootTableFrame:SetPoint("TOPRIGHT", WORS_Loot, "TOPRIGHT", -30, -30)

lootTableFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
lootTableFrame:SetBackdropColor(0, 0, 0, 1)

-- Scroll frame content
local lootContent = CreateFrame("Frame", nil, lootTableFrame)
lootContent:SetSize(250, 400)  
lootTableFrame:SetScrollChild(lootContent)

-- Table to hold loot items
local lootItems = {}

-- Function to clear loot content
local function ClearLootContent()
    print("Clearing loot content...")  -- Debug print
    for _, item in ipairs(lootItems) do
        item:Hide()  -- Hide the item
        item = nil  -- Optionally clear the reference
    end
    wipe(lootItems)  -- Clear the table
end

-- Function to update the loot table based on selected boss
local function UpdateLootTable(selectedBoss)
    ClearLootContent()  -- Clear previous loot before updating

    if selectedBoss == "King Black Dragon" then
        local lootEntries = {"King Black Dragon's Head", "Dragon Armor"}
        for i, item in ipairs(lootEntries) do
            local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootItem:SetText(item)
            lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))  -- Place based on count
            table.insert(lootItems, lootItem)  -- Store the reference
        end
    elseif selectedBoss == "Kalphite Queen" then
        local lootEntries = {"Kalphite Queen's Carapace", "Kalphite Queen's Blade"}
        for i, item in ipairs(lootEntries) do
            local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootItem:SetText(item)
            lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))  -- Place based on count
            table.insert(lootItems, lootItem)  -- Store the reference
        end
    end
end

-- Function to update Slayer tasks
local function UpdateSlayerTasks(selectedMaster)
    ClearLootContent()  -- Clear previous loot before updating

    if selectedMaster == "Turael" then
        local tasks = {"Aberrant Spectres", "Abyssal Demons", "Ankou"}
        for i, task in ipairs(tasks) do
            local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootItem:SetText(task)
            lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))  -- Place based on count
            table.insert(lootItems, lootItem)  -- Store the reference
        end
    elseif selectedMaster == "Mazchna" then
        local tasks = {"Giant Bats", "Murlocs"}
        for i, task in ipairs(tasks) do
            local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootItem:SetText(task)
            lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))  -- Place based on count
            table.insert(lootItems, lootItem)  -- Store the reference
        end
    elseif selectedMaster == "Vannaka" then
        local tasks = {"Abyssal Demons", "Black Demons"}
        for i, task in ipairs(tasks) do
            local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootItem:SetText(task)
            lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))  -- Place based on count
            table.insert(lootItems, lootItem)  -- Store the reference
        end
    end
end

-- Function to update skill tiers
local function UpdateSkillTiers(selectedSkill)
    ClearLootContent()  -- Clear previous loot before updating

    if selectedSkill == "Smithing" then
        local tiers = {"Bronze", "Iron", "Steel"}
        for i, tier in ipairs(tiers) do
            local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootItem:SetText(tier)
            lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))  -- Place based on count
            table.insert(lootItems, lootItem)  -- Store the reference
        end
    elseif selectedSkill == "Fletching" then
        local tiers = {"Logs", "Oak", "Willow"}
        for i, tier in ipairs(tiers) do
            local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootItem:SetText(tier)
            lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))  -- Place based on count
            table.insert(lootItems, lootItem)  -- Store the reference
        end
    elseif selectedSkill == "Crafting" then
        local tiers = {"Leather", "Cloth", "Gem"}
        for i, tier in ipairs(tiers) do
            local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootItem:SetText(tier)
            lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))  -- Place based on count
            table.insert(lootItems, lootItem)  -- Store the reference
        end
    end
end

-- Variables to keep track of selected module and subcategory
local selectedModule = nil
local selectedSubcategory = nil

-- Update the subcategory dropdown based on the module selected
local function UpdateSubcategoryDropdown(selectedModule)
    -- Clear previous items
    UIDropDownMenu_ClearAll(subcategoryDropdown)

    if selectedModule == "Bosses" then
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Boss")
        local bosses = {"King Black Dragon", "Kalphite Queen"}
        UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
            for _, boss in ipairs(bosses) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = boss
                info.func = function()
                    selectedSubcategory = boss  -- Store selected boss
                    UpdateLootTable(boss)  -- Update loot based on selected boss
                    UIDropDownMenu_SetText(subcategoryDropdown, selectedSubcategory)  -- Set the selected value
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
                    selectedSubcategory = master  -- Store selected master
                    UpdateSlayerTasks(master)  -- Update tasks based on selected master
                    UIDropDownMenu_SetText(subcategoryDropdown, selectedSubcategory)  -- Set the selected value
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    elseif selectedModule == "Skills" then
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Skill")
        local skills = {"Smithing", "Fletching", "Crafting"}
        UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
            for _, skill in ipairs(skills) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = skill
                info.func = function()
                    selectedSubcategory = skill  -- Store selected skill
                    UpdateSkillTiers(skill)  -- Update tiers based on selected skill
                    UIDropDownMenu_SetText(subcategoryDropdown, selectedSubcategory)  -- Set the selected value
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
end

-- Initialize module dropdown
UIDropDownMenu_SetText(moduleDropdown, "Select Module")
local modules = {"Bosses", "Slayer", "Skills"}
UIDropDownMenu_Initialize(moduleDropdown, function(self, level)
    for _, module in ipairs(modules) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = module
        info.func = function()
            selectedModule = module  -- Store selected module
            UpdateSubcategoryDropdown(module)  -- Update subcategories based on selected module
            UIDropDownMenu_SetText(moduleDropdown, selectedModule)  -- Set the selected value
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- Show the main frame (for testing purposes)
WORS_Loot:Show()
