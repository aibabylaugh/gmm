-- i knew you was finna skid it like a good boy ✌
local fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local options = fluent.Options
local MemoryMatchManager = game:GetService("ReplicatedStorage").MemoryMatchManager
local MemoryMatchGui = game:GetService("ReplicatedStorage").Gui.MemoryMatch
local MinigameGui = require(game:GetService("ReplicatedStorage").Gui.MinigameGui)
local MemoryMatchModule = require(game:GetService("ReplicatedStorage").Gui.MemoryMatch)
local Events = require(game:GetService("ReplicatedStorage").Events)
local MemoryMatchTile = require(game:GetService("ReplicatedStorage").Gui.MemoryMatchGui.MemoryMatchGuiTile)
local ActivatablesToys = require(game:GetService("ReplicatedStorage").Activatables.Toys)
local meta = {
    Mega = "BadgeGuild",
    Night = "Night",
    Extreme = "35Zone",
    Winter = "Winter"
}
local expecteditems = {
    ["Mega Memory Match"] = {

    },
    ["Night Memory Match"] = {

    },
    ["Extreme Memory Match"] = {

    },
    ["Winter Memory Match"] = {

    }
}

local function startmemorymatch(name)
    ActivatablesToys.ButtonEffect(game.Players.LocalPlayer, workspace.Toys[name])
end

local Window = Fluent:CreateWindow({
    Title = "MemoryMatcher V1",
    SubTitle = "discord id: 810267151150612500",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local currentmm
local currentmmname
local attempts = {
    ["Mega Memory Match"] = 0,
    ["Night Memory Match"] = 0,
    ["Extreme Memory Match"] = 0,
    ["Winter Memory Match"] = 0,
}

local stopmm = false
local oldstart; oldstart = hookfunction(MinigameGui.StartGame, newcclosure(function(...)
    local mm = oldstart(...)
    currentmm = mm
    -- AUTO mm
    task.spawn(function()
        repeat task.wait() until currentmmname
        if not options[currentmmname .. "GhostMM"].Value then return end
        local itemstoget = expecteditems[currentmmname]
        local a = mm
        local setIdentity = setthreadidentity
        local origThreadIdentity = 0
        local function UpdateGameTable(a)
            local dupes = {}
            local exclude = a.Game.MatchedTiles
        
            for index, value in pairs(a.Game.RevealedTiles) do
                if exclude[index] == nil then
                    if (options[currentmmname .. "BiasMode"].Value and not table.find(itemstoget, value)) then
                        continue
                    end
                    if dupes[value] == nil then
                        dupes[value] = {Indexes = {index}}
                    else
                        table.insert(dupes[value]["Indexes"], index)
                    end
                end
            end
        
            for i,v in pairs(dupes) do
            if #v.Indexes < 2 then dupes[i] = nil end
            end
        
            return dupes
        end

        repeat task.wait() until a and a.Game and a.Game.Grid and a.Game.Grid.InputActive
        for Index = 1, a.Game.NumTiles do
            task.wait()
            --warn("You have",a.Game.Chances,"chances left")
            if a.Game.Chances == 0 then break end
            setIdentity(2)
            local tile
            xpcall(function()tile=a.Game.Grid:GetTileAtIndex(Index)end,function(err)--[[warn("Err:",err)]]end)
            setIdentity(origThreadIdentity)
    
            if a.Game.LastSelectedIndex ~= nil then
                local searchFor = a.Game.RevealedTiles[a.Game.LastSelectedIndex]
                local dupes = UpdateGameTable(a)
                for i2,v2 in pairs(dupes) do
                    if i2 == searchFor and v2.Indexes[1] ~= Index then 
                        setIdentity(2)
                        tile = a.Game.Grid:GetTileAtIndex(v2.Indexes[1])
                        setIdentity(origThreadIdentity)
                        break 
                    end
                end
            else
                local dupes = UpdateGameTable(a)
                for i,v in pairs(dupes) do
                    if #v.Indexes > 1 then
                        setIdentity(2)
                        MemoryMatchModule.RegisterTileSelected(a.Game, a.Game.Grid:GetTileAtIndex(v.Indexes[1]))
                        setIdentity(origThreadIdentity)
                        repeat task.wait() until a.Game.Grid.InputActive or a.Game.Chances <= 0
                        setIdentity(2)
                        tile = a.Game.Grid:GetTileAtIndex(v.Indexes[2])
                        setIdentity(origThreadIdentity)
                        task.wait()
                        break
                    end
                end
            end
            setIdentity(2)
            MemoryMatchModule.RegisterTileSelected(a.Game, tile)
            setIdentity(origThreadIdentity)
            repeat task.wait() until a.Game.Grid.InputActive or a.Game.Chances <= 0
            task.wait()
        end
        if stopmm then return end
        --warn("Finishing memory Match")
        Events.ClientCall("MemoryMatchEvent", {
            Action = "Finish"
        })
        --warn("Ending Game")
        --MinigameGui.EndGame()
        setIdentity(origThreadIdentity)
        --warn("Game ended successfully")
    end)
    return mm
end))
local oldend; oldend = hookfunction(MinigameGui.EndGame, newcclosure(function(...)
    currentmm = nil
    return oldend(...)
end))

local toyevent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ToyEvent")
local mmevent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("MemoryMatchEvent")
local ismatchitems
local function ghostmm(name)
    workspace.Toys[name].Cooldown.Value = 0
    local itemstoget = expecteditems[name]
    repeat task.wait() until currentmm
    task.spawn(function()
        while task.wait() and currentmm do
            local ismatch1 = false
            local ismatch2 = false
            for i, _ in pairs(currentmm.Game.MatchedTiles) do
                local broken
                if currentmm.Game.RevealedAll then break end
                local name = currentmm.Game.RevealedTiles[i]
                if table.find(itemstoget, name) and ismatch1 then
                    ismatch2 = true
                end
                if broken then break end
                if table.find(itemstoget, name) then
                    ismatch1 = true
                end
            end
            ismatchitems = ((ismatch1 == true) and (ismatch2 == true)) or false
            if currentmm.Game.RevealedAll then break end
        end
    end)
    repeat task.wait() until ismatchitems or currentmm == nil
    if ismatchitems then
        task.spawn(function()
            setthreadidentity(8)
            Fluent:Notify({
                Title = "Ghost MM",
                Content = "Items found!! Loot will be recieved after memory match finishes.",
                Duration = 7
            })
            attempts[name] = 0
        end)
    else
        task.spawn(function()
            setthreadidentity(8)
            attempts[name] = attempts[name] + 1
            Fluent:Notify({
                Title = "Ghost MM",
                Content = "No items found. Attempt " .. attempts[name],
                Duration = 7
            })
            if not options[currentmmname .. "GhostMM"].Value then return end
            startmemorymatch(currentmmname)
            repeat
                task.wait()
            until currentmm
        end)
    end
end

local isdoingmm = false
local old; old = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if self == toyevent and tostring(args[1]):find("Memory Match") and (options[args[1] .. "GhostMM"].Value or currentmm) then
        isdoingmm = true
        currentmmname = args[1]
        ----warn("started mm")
        local oldcd = workspace.Toys[args[1]].Cooldown.Value
        task.spawn(ghostmm, args[1])
        repeat task.wait() until not isdoingmm
        if ismatchitems then
            ismatchitems = false
            workspace.Toys[args[1]].Cooldown.Value = oldcd
        else
            return;
        end
    elseif self == mmevent and args[1].Action == "RevealAll" then
        isdoingmm = false
        ----warn("ended mm")
    end
    return old(self, ...)
end)

local maxfastghostmul = 20
local fastghostmul = 0

local help = Window:AddTab({ Title = "Help", Icon = "" })
local settings = Window:AddTab({ Title = "Settings", Icon = "" })
help:AddParagraph({
    Title = "Ghost Memory Match",
    Content = "Ghost Memory Match is an exploit that creates fake instances of memory matches then makes it count as a real memory match when a match that includes one of the selected items is found."
})
help:AddParagraph({
    Title = "Fast Ghost",
    Content = "Fast Ghost simply makes the memory match be completed X times faster where X is the value you selected from settings, which is better for loot but increases detection risk."
})
help:AddParagraph({
    Title = "Bias Mode [Broken]",
    Content = "If enabled, Ghost MM is supposed to ignore all other items except for targetted loot, useful if you just want one really rare item. Although, disabling it breaks the script for some reason so always enable it."
})
settings:AddSlider("FastGhostMul", {
    Title = "Fast Ghost Speed Multiplier",
    Description = "0 = INSTANT",
    Default = fastghostmul,
    Min = 0,
    Max = maxfastghostmul,
    Rounding = 0,
    Callback = function(Value)
        fastghostmul = Value
    end
})
local types = require(game:GetService("ReplicatedStorage").MemoryMatchGameTypes)
local function addmemorymatcher(name)
    local tab = Window:AddTab({ Title = name .. " Memory Match", Icon = "" })
    tab:AddSection("Items To Target")
    local rawitems = {}
    for i, v in pairs(types[meta[name]].Pool) do
        table.insert(rawitems, v.Name .. " (" .. v.Chance .. "%)")
    end
    table.sort(rawitems)
    local targets = tab:AddDropdown(name .. "TargetItems", {
        Title = "Select",
        Values = rawitems,
        Multi = true,
        Default = {},
    })

    targets:OnChanged(function(values)
        local newavals = {}
        for i, v in pairs(values) do
            table.insert(newavals, i:match("(.+) %("))
        end
        expecteditems[name .. " Memory Match"] = newavals
    end)
    tab:AddSection("Settings")
    tab:AddToggle((name .. " Memory Match") .. "GhostMM", {Title = "Ghost MM", Default = false })
    tab:AddToggle((name .. " Memory Match") .. "FastGhost", {Title = "Fast Ghost", Default = false })
    tab:AddToggle((name .. " Memory Match") .. "BiasMode", {Title = "Bias Mode", Default = true}):OnChanged(function(Val)
        if Val == false then
            Fluent:Notify({
                Title = "Dont disable this!!",
                Content = "For some reason if bias mode is not enabled the ghost mm will break after a few attempts so please make sure it's always on",
                Duration = 7
            })
        end
    end)
    tab:AddButton({
        Title = "Start Memory Match",
        Callback = function()
            Window:Dialog({
                Title = "Start?",
                Content = "After pressing yes, ghost memory match will begin. You will not be teleported, tweened or walked to the toy.",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()
                            task.spawn(function()
                                startmemorymatch(name .. " Memory Match")
                            end)
                        end
                    },
                    {
                        Title = "Nevermind!",
                        Callback = function()
                        end
                    }
                }
            })
        end
    })
    tab:AddButton({
        Title = "Print Timer",
        Callback = function()
            local toyname = name .. " Memory Match"
            local Cc = require(game.ReplicatedStorage.ClientStatCache)
            local t = (workspace.Toys[toyname].Cooldown.Value + Cc:Get().ToyTimes[toyname]) - os.time()
            local str = t > 0 and string.format("%d:%02d:%02d", t//3600, (t%3600)//60, t%60) or "Now ✅"
            Fluent:Notify({
                Title = "Ready in ...",
                Content = str,
                Duration = 7
            })
        end
    })
end

for i, v in pairs({"Mega", "Night", "Extreme", "Winter"}) do
    addmemorymatcher(v)
end

-- fast ghost code
local m = getrenv()
local old; old = hookfunction(m.task.wait, newcclosure(function(amn)
	if amn ~= nil and debug.traceback():find("MemoryMatch") and currentmm and options[currentmmname .. "FastGhost"].Value then
		amn = (fastghostmul == 0 and 0 or (amn / fastghostmul))
	end
	return old(amn)
end))

-- destroy old mms
game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MinigameLayer.ChildAdded:Connect(function(v)
    if v.Name == "MemoryMatchFrame" then
        repeat task.wait() until v.Position.Y.Scale == 1
        v:Destroy()
    end
end)

----warn("gmm loaded")
