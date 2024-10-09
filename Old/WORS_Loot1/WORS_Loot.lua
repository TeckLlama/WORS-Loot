-- WORS_Loot.lua

-- Create the main frame
local WORS_Loot = CreateFrame("Frame", "WORS_Loot", UIParent)
WORS_Loot:SetSize(800, 450)
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

-- Create the third dropdown for Slayer tasks
local taskDropdown = CreateFrame("Frame", "WORS_Loot_TaskDropdown", WORS_Loot, "UIDropDownMenuTemplate")
taskDropdown:SetPoint("TOPLEFT", subcategoryDropdown, "TOPLEFT", 160, 0)

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
    for _, item in ipairs(lootItems) do
        item:Hide()
    end
    wipe(lootItems)
end

-- Function to update the loot table based on selection
local function UpdateLootTable(lootEntries)
    ClearLootContent()
    for i, item in ipairs(lootEntries) do
        local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lootItem:SetText(item)
        lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))
        table.insert(lootItems, lootItem)
    end
end

-- Function to populate tasks for Slayer module
local function UpdateTaskDropdown(selectedMaster)
    UIDropDownMenu_ClearAll(taskDropdown)
    UIDropDownMenu_SetText(taskDropdown, "Select Task")

    local tasks
    if selectedMaster == "Turael" then
        tasks = {"Aberrant Spectres", "Abyssal Demons", "Ankou"}
    elseif selectedMaster == "Mazchna" then
        tasks = {"Giant Bats", "Murlocs"}
    elseif selectedMaster == "Vannaka" then
        tasks = {"Abyssal Demons", "Black Demons"}
    end

    UIDropDownMenu_Initialize(taskDropdown, function(self, level)
        for _, task in ipairs(tasks) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = task
            info.func = function()
                UIDropDownMenu_SetText(taskDropdown, task)  -- Update task dropdown text
                UpdateLootTable({ task .. " Loot" })  -- Update loot based on task selection
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end

-- Function to populate subcategory based on module selection
local function UpdateSubcategoryDropdown(selectedModule)
    UIDropDownMenu_ClearAll(subcategoryDropdown)
    UIDropDownMenu_ClearAll(taskDropdown)
    taskDropdown:Hide()

    if selectedModule == "Bosses" then
        local bosses = {"King Black Dragon", "Kalphite Queen"}
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Boss")
        UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
            for _, boss in ipairs(bosses) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = boss
                info.func = function()
                    UIDropDownMenu_SetText(subcategoryDropdown, boss)  -- Update subcategory dropdown text
                    UpdateLootTable({ boss .. " Loot 1", boss .. " Loot 2" })  -- Display loot
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    elseif selectedModule == "Slayer" then
        local slayerMasters = {"Turael", "Mazchna", "Vannaka"}
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Slayer Master")
        UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
            for _, master in ipairs(slayerMasters) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = master
                info.func = function()
                    UIDropDownMenu_SetText(subcategoryDropdown, master)  -- Update subcategory dropdown text
                    UpdateTaskDropdown(master)  -- Show tasks for selected master
                    taskDropdown:Show()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    elseif selectedModule == "Skills" then
        -- Additional skill-related options can be added here.
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
            UIDropDownMenu_SetText(moduleDropdown, module)  -- Update module dropdown text
            UpdateSubcategoryDropdown(module)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- Show the main frame (for testing purposes)
WORS_Loot:Show()
