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
UIDropDownMenu_SetWidth(moduleDropdown, 130)  -- Set width for module dropdown

local subcategoryDropdown = CreateFrame("Frame", "WORS_Loot_SubcategoryDropdown", WORS_Loot, "UIDropDownMenuTemplate")
subcategoryDropdown:SetPoint("TOPLEFT", moduleDropdown, "TOPLEFT", 160, 0)
UIDropDownMenu_SetWidth(subcategoryDropdown, 130)  -- Set width for subcategory dropdown

local thirdDropdown = CreateFrame("Frame", "WORS_Loot_ThirdDropdown", WORS_Loot, "UIDropDownMenuTemplate")
thirdDropdown:SetPoint("TOPLEFT", subcategoryDropdown, "TOPLEFT", 160, 0)
UIDropDownMenu_SetWidth(thirdDropdown, 130)  -- Set width for third dropdown

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
    end
    wipe(lootItems)
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
        for i, item in ipairs(lootEntries) do
            local lootItem = lootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootItem:SetText(item)
            lootItem:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 5, -((#lootItems) * 20))
            table.insert(lootItems, lootItem)
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
WORS_Loot:Show() -- Uncomment this if you want it to show on load
