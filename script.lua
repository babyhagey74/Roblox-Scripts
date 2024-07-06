local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Rainbow Friends Hub V2',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Chapter1 = Window:AddTab('Chapter 1'),
    Chapter2 = Window:AddTab('Chapter 2'),
    Settings = Window:AddTab('UI Settings'),
    Credits = Window:AddTab('Credits'),
}

local LeftGroupBox0 = Tabs.Settings:AddLeftGroupbox('UI Settings')

local MyButton1 = LeftGroupBox0:AddButton({
    Text = 'Unload GUI',
    Func = function()
        Library:Unload()
    end,
    DoubleClick = false,
    Tooltip = 'Unloads the whole GUI'
})

LeftGroupBox0:AddLabel('Ignore this, use themes.'):AddColorPicker('ColorPicker', {
    Default = Color3.new(0, 1, 0), -- Bright green
    Title = 'Some color', -- Optional. Allows you to have a custom color picker title (when you open it)
    Transparency = 0, -- Optional. Enables transparency changing for this color picker (leave as nil to disable)

    Callback = function(Value)
        ThemeManager:SetLibrary(Library)
        ThemeManager:ApplyToTab(Tabs.Settings)
    end
})

local LeftGroupBox1 = Tabs.Credits:AddLeftGroupbox('Credits')
LeftGroupBox1:AddLabel('monkey_kid03 - Tabs & Sections')
LeftGroupBox1:AddLabel('Join our discord server!')
LeftGroupBox1:AddLabel('discord.gg/CZmKza9fMD')

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('FPS & Ping | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

local LeftGroupBox3 = Tabs.Chapter2:AddLeftGroupbox('ESP | Night 1 - Monsters')

LeftGroupBox3:AddToggle('Highlight Blue', {
    Text = 'Highlight Blue',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see blue.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Blue
        end
        if Value == false then
            game.Workspace.Monsters.Blue.Highlight:Destroy()
        end
    end
})

LeftGroupBox3:AddToggle('Highlight Green', {
    Text = 'Highlight Green',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see green.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Green
        end
        if Value == false then
            game.Workspace.Monsters.Green.Highlight:Destroy()
        end
    end
})

LeftGroupBox3:AddToggle('Highlight Purple', {
    Text = 'Highlight Purple',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see purple.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Purple
        end
        if Value == false then
            game.Workspace.Monsters.Purple.Highlight:Destroy()
        end
    end
})


local LeftGroupBox4 = Tabs.Chapter2:AddLeftGroupbox('ESP | Night 2 - Monsters')

LeftGroupBox4:AddToggle('Highlight Blue', {
    Text = 'Highlight Blue',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see blue.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Blue
        end
        if Value == false then
            game.Workspace.Monsters.Blue.Highlight:Destroy()
        end
    end
})

LeftGroupBox4:AddToggle('Highlight Green', {
    Text = 'Highlight Green',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see green.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Green
        end
        if Value == false then
            game.Workspace.Monsters.Green.Highlight:Destroy()
        end
    end
})

LeftGroupBox4:AddToggle('Highlight Yellow', {
    Text = 'Highlight Yellow',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see yellow.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Bird
        end
        if Value == false then
            game.Workspace.Monsters.Bird.Highlight:Destroy()
        end
    end
})

LeftGroupBox4:AddToggle('Highlight Purple', {
    Text = 'Highlight Purple',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see purple.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Purple
        end
        if Value == false then
            game.Workspace.Monsters.Purple.Highlight:Destroy()
        end
    end
})

local LeftGroupBox5 = Tabs.Chapter2:AddLeftGroupbox('ESP | Night 3 - Monsters')

LeftGroupBox5:AddToggle('Highlight Blue', {
    Text = 'Highlight Blue',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see blue.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Blue
        end
        if Value == false then
            game.Workspace.Monsters.Blue.Highlight:Destroy()
        end
    end
})

LeftGroupBox5:AddToggle('Highlight Green', {
    Text = 'Highlight Green',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see green.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Green
        end
        if Value == false then
            game.Workspace.Monsters.Green.Highlight:Destroy()
        end
    end
})

LeftGroupBox5:AddToggle('Highlight Yellow', {
    Text = 'Highlight Yellow',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see yellow.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Bird
        end
        if Value == false then
            game.Workspace.Monsters.Bird.Highlight:Destroy()
        end
    end
})

LeftGroupBox5:AddToggle('Highlight Purple', {
    Text = 'Highlight Purple',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see purple.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Purple
        end
        if Value == false then
            game.Workspace.Monsters.Purple.Highlight:Destroy()
        end
    end
})

local LeftGroupBox6 = Tabs.Chapter2:AddLeftGroupbox('ESP | Night 4 - Monsters')

LeftGroupBox6:AddToggle('Highlight Blue', {
    Text = 'Highlight Blue',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see blue.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Blue
        end
        if Value == false then
            game.Workspace.Monsters.Blue.Highlight:Destroy()
        end
    end
})

LeftGroupBox6:AddToggle('Highlight Green', {
    Text = 'Highlight Green',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see green.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Green
        end
        if Value == false then
            game.Workspace.Monsters.Green.Highlight:Destroy()
        end
    end
})

LeftGroupBox6:AddToggle('Highlight Yellow', {
    Text = 'Highlight Yellow',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see yellow.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Bird
        end
        if Value == false then
            game.Workspace.Monsters.Bird.Highlight:Destroy()
        end
    end
})

LeftGroupBox6:AddToggle('Highlight Cyan', {
    Text = 'Highlight Cyan',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see cyan.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Cyan
        end
        if Value == false then
            game.Workspace.Monsters.Cyan.Highlight:Destroy()
        end
    end
})

LeftGroupBox6:AddToggle('Highlight Purple', {
    Text = 'Highlight Purple',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see purple.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Purple
        end
        if Value == false then
            game.Workspace.Monsters.Purple.Highlight:Destroy()
        end
    end
})

local RightGroupBox1 = Tabs.Chapter2:AddRightGroupbox('ESP | Night 1 - Items');

local MyButton = RightGroupBox1:AddButton({
    Text = 'Highlight Light Bulbs',
    Func = function()
        local hl = Instance.new("Highlight")
        for i,v in pairs(game.Workspace:GetChildren()) do
            if v.Name == "Lightbulb" then
                hl:Clone().Parent = v
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Highlights lightbulbs.'
})

local RightGroupBox2 = Tabs.Chapter2:AddRightGroupbox('ESP | Night 2 - Items');

local MyButton = RightGroupBox2:AddButton({
    Text = 'Highlight Gas Canisters',
    Func = function()
        local hl = Instance.new("Highlight")
        for i,v in pairs(game.Workspace:GetChildren()) do
            if v.Name == "GasCanister" then
                hl:Clone().Parent = v
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Highlights gas canisters.'
})

local RightGroupBox3 = Tabs.Chapter2:AddRightGroupbox('ESP | Night 3 - Items');

local MyButton = RightGroupBox3:AddButton({
    Text = 'Highlight Lookies',
    Func = function()
        local hl = Instance.new("Highlight")
        for i,v in pairs(game.Workspace:GetChildren()) do
            if v.Name == "Looky" then
                hl:Clone().Parent = v
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Highlights lookies.'
})

local RightGroupBox4 = Tabs.Chapter2:AddRightGroupbox('ESP | Night 4 - Items');

local MyButton = RightGroupBox4:AddButton({
    Text = 'Highlight Cake Mix',
    Func = function()
        local hl = Instance.new("Highlight")
        for i,v in pairs(game.Workspace:GetChildren()) do
            if v.Name == "CakeMix" then
                hl:Clone().Parent = v
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Highlights cake mix.'
})


--CHAPTER 1--

local LeftGroupBox10 = Tabs.Chapter1:AddLeftGroupbox('NOTE')
LeftGroupBox10:AddLabel('Purple is impossible due to')
LeftGroupBox10:AddLabel('it being in the vents.')

local LeftGroupBox7 = Tabs.Chapter1:AddLeftGroupbox('ESP | Night 1 - Monsters')

LeftGroupBox7:AddToggle('Highlight Blue', {
    Text = 'Highlight Blue',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see blue.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Blue
        end
        if Value == false then
            game.Workspace.Monsters.Blue.Highlight:Destroy()
        end
    end
})

local LeftGroupBox8 = Tabs.Chapter1:AddLeftGroupbox('ESP | Night 2 - Monsters')

LeftGroupBox8:AddToggle('Highlight Blue', {
    Text = 'Highlight Blue',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see blue.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Blue
        end
        if Value == false then
            game.Workspace.Monsters.Blue.Highlight:Destroy()
        end
    end
})


LeftGroupBox8:AddToggle('Highlight Green', {
    Text = 'Highlight Green',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see green.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Green
        end
        if Value == false then
            game.Workspace.Monsters.Green.Highlight:Destroy()
        end
    end
})

local LeftGroupBox9 = Tabs.Chapter1:AddLeftGroupbox('ESP | Night 3 - Monsters')

LeftGroupBox9:AddToggle('Highlight Blue', {
    Text = 'Highlight Blue',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see blue.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Blue
        end
        if Value == false then
            game.Workspace.Monsters.Blue.Highlight:Destroy()
        end
    end
})


LeftGroupBox9:AddToggle('Highlight Green', {
    Text = 'Highlight Green',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see green.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Green
        end
        if Value == false then
            game.Workspace.Monsters.Green.Highlight:Destroy()
        end
    end
})

LeftGroupBox9:AddToggle('Highlight Orange', {
    Text = 'Highlight Orange',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see orange.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Orange
        end
        if Value == false then
            game.Workspace.Monsters.Orange.Highlight:Destroy()
        end
    end
})

local LeftGroupBox10 = Tabs.Chapter1:AddLeftGroupbox('ESP | Night 4 - Monsters')

LeftGroupBox10:AddToggle('Highlight Blue', {
    Text = 'Highlight Blue',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see blue.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Blue
        end
        if Value == false then
            game.Workspace.Monsters.Blue.Highlight:Destroy()
        end
    end
})


LeftGroupBox10:AddToggle('Highlight Green', {
    Text = 'Highlight Green',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see green.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Green
        end
        if Value == false then
            game.Workspace.Monsters.Green.Highlight:Destroy()
        end
    end
})

LeftGroupBox10:AddToggle('Highlight Orange', {
    Text = 'Highlight Orange',
    Default = false, -- Default value (true / false)
    Tooltip = 'This highlight is so that you can see orange.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            local hl = Instance.new("Highlight")
            hl.Parent = game.Workspace.Monsters.Orange
        end
        if Value == false then
            game.Workspace.Monsters.Orange.Highlight:Destroy()
        end
    end
})

local RightGroupBox5 = Tabs.Chapter1:AddRightGroupbox('ESP | Night 1 - Items');

local MyButton = RightGroupBox5:AddButton({
    Text = 'Highlight Blocks',
    Func = function()
        local hl = Instance.new("Highlight")
        hl:Clone().Parent = game.workspace.Block1
        hl:Clone().Parent = game.workspace.Block2
        hl:Clone().Parent = game.workspace.Block3
        hl:Clone().Parent = game.workspace.Block4
        hl:Clone().Parent = game.workspace.Block5
        hl:Clone().Parent = game.workspace.Block6
        hl:Clone().Parent = game.workspace.Block7
        hl:Clone().Parent = game.workspace.Block8
        hl:Clone().Parent = game.workspace.Block9
        hl:Clone().Parent = game.workspace.Block10
        hl:Clone().Parent = game.workspace.Block11
        hl:Clone().Parent = game.workspace.Block12
        hl:Clone().Parent = game.workspace.Block13
        hl:Clone().Parent = game.workspace.Block14
        hl:Clone().Parent = game.workspace.Block15
        hl:Clone().Parent = game.workspace.Block16
        hl:Clone().Parent = game.workspace.Block17
        hl:Clone().Parent = game.workspace.Block18
        hl:Clone().Parent = game.workspace.Block19
        hl:Clone().Parent = game.workspace.Block20
        hl:Clone().Parent = game.workspace.Block21
        hl:Clone().Parent = game.workspace.Block22
        hl:Clone().Parent = game.workspace.Block23
        hl:Clone().Parent = game.workspace.Block24
    end,
    DoubleClick = false,
    Tooltip = 'Highlights blocks.'
})

local RightGroupBox5 = Tabs.Chapter1:AddRightGroupbox('ESP | Night 2 - Items');

local MyButton = RightGroupBox5:AddButton({
    Text = 'Highlight Food Bags', --food green, orange and pink
    Func = function()
        local hl = Instance.new("Highlight")
        for i,v in pairs(game.Workspace:GetChildren()) do
            if v.Name == "FoodGreen" or "FoodOrange" or "FoodPink" then
                hl:Clone().Parent = v
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Highlights food bags.'
})

local RightGroupBox6 = Tabs.Chapter1:AddRightGroupbox('ESP | Night 3 - Items');

local MyButton = RightGroupBox6:AddButton({
    Text = 'Highlight Fuses',
    Func = function()
        local hl = Instance.new("Highlight")
        hl:Clone().Parent = game.workspace.Fuse1
        hl:Clone().Parent = game.workspace.Fuse2
        hl:Clone().Parent = game.workspace.Fuse3
        hl:Clone().Parent = game.workspace.Fuse4
        hl:Clone().Parent = game.workspace.Fuse5
        hl:Clone().Parent = game.workspace.Fuse6
        hl:Clone().Parent = game.workspace.Fuse7
        hl:Clone().Parent = game.workspace.Fuse8
        hl:Clone().Parent = game.workspace.Fuse9
        hl:Clone().Parent = game.workspace.Fuse10
        hl:Clone().Parent = game.workspace.Fuse11
        hl:Clone().Parent = game.workspace.Fuse12
        hl:Clone().Parent = game.workspace.Fuse13
        hl:Clone().Parent = game.workspace.Fuse14
    end,
    DoubleClick = false,
    Tooltip = 'Highlights fuses.'
})

local RightGroupBox7 = Tabs.Chapter1:AddRightGroupbox('ESP | Night 4 - Items');

local MyButton = RightGroupBox7:AddButton({
    Text = 'Highlight Batteries',
    Func = function()
        for i,v in pairs(game.Workspace:GetChildren()) do
            if v.Name == "Battery" then
                hl:Clone().Parent = v
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Highlights batteries.'
})