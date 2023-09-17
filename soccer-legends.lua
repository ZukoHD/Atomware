--// initializing vars
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Character = Player.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = {
    KickBall = ReplicatedStorage:WaitForChild("RE"):WaitForChild("React")
}

local Mouse = Player:GetMouse()

--// initializing ui
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Atomware - V1.0", "BloodTheme")

--// tabs
local Main = Window:NewTab("Main")
local Fun = Window:NewTab("Fun")
local Other = Window:NewTab("Other")

--// main tab sections
local AutoGoal = Main:NewSection("Auto Goal")
local BallAura = Main:NewSection("Ball Aura")
local Character = Main:NewSection("Character")

getgenv().AutoGoal = false
getgenv().BallAura = false
getgenv().BallAuraVisible = false
getgenv().WalkSpeed = 16
getgenv().JumpPower = 50
getgenv().AnticheatBypassed = false

--// main -> autogoal
local Goals = {
    Blue = CFrame.new(-402, 6, -454),
    Red = CFrame.new(-136, 6, -454)
}

function GetBall()
    return workspace:WaitForChild("Balls"):FindFirstChild("Ball")
end

function GetBallOwnership() 
    if GetBall() == nil then return end
    local Ownership = GetBall():WaitForChild("Ownership")
    local oldPosition = HumanoidRootPart.CFrame
    while tostring(Ownership.Value) ~= Player.Name do HumanoidRootPart.CFrame = GetBall().CFrame task.wait() end
    HumanoidRootPart.CFrame = oldPosition
end

function ScoreGoal()
    if Player.TeamColor == BrickColor.new("Institutional white") then return end
    GetBallOwnership()
    if GetBall() == nil then return end

    if Player.TeamColor == BrickColor.new("Electric blue") then
        GetBall().CFrame = Goals.Red
    elseif Player.TeamColor == BrickColor.new("Bright red") then
        GetBall().CFrame = Goals.Blue
    end
end

AutoGoal:NewToggle("Auto Goal", "Whether or not Auto Goal is enabled.", function(state)
    getgenv().AutoGoal = state
end)

AutoGoal:NewButton("Score Goal", "Teleports the ball into the goal.", function()
    ScoreGoal()
end)

--// main -> ball aura
function KickBall(power)
    Remotes.KickBall:FireServer(GetBall(), HumanoidRootPart.CFrame, power)
end

function CreateRange(size)
    local RangePart = Instance.new("Part", HumanoidRootPart)
    RangePart.Name = "RangePart"
    RangePart.Size = size
    RangePart.CFrame = HumanoidRootPart.CFrame
    RangePart.CanCollide = false
    RangePart.Anchored = true
    RangePart.Transparency = 1
    RangePart.Touched:Connect(function() end)
end

function DestroyRange()
    local RangePart = HumanoidRootPart:FindFirstChild("RangePart")
    if RangePart == nil then return end
    RangePart:Destroy()
end

function UpdateRange(size)
    local RangePart = HumanoidRootPart:FindFirstChild("RangePart")
    if RangePart == nil then return end
    RangePart.CFrame = HumanoidRootPart.CFrame
    if size ~= nil then RangePart.Size = size end
end

function SetRangeVisible(value)
    local RangePart = HumanoidRootPart:FindFirstChild("RangePart")
    if RangePart == nil then return end
    if value then
        RangePart.Transparency = 0.5
    else
        RangePart.Transparency = 1
    end
end

function IsInRange(part)
    local RangePart = HumanoidRootPart:FindFirstChild("RangePart")
    if RangePart == nil then return false end
    for _,v in RangePart:GetTouchingParts() do
        if v == nil then return false end
        if part == nil then return false end
        if v.Name == part.Name then
            return true
        end
    end
    return false
end

function GetRangeSize()
    local RangePart = HumanoidRootPart:FindFirstChild("RangePart")
    if RangePart == nil then return 0 end
    return RangePart.Size
end

BallAura:NewToggle("Ball Aura", "Whether or not Ball Aura is enabled.", function(state)
    getgenv().BallAura = state
    if getgenv().BallAura then
        CreateRange(Vector3.new(1, 10, 1))
    else
        DestroyRange()
    end
end)

BallAura:NewSlider("Range Width", "The range width for Ball Aura", 250, 1, function(s)
    UpdateRange(Vector3.new(s, GetRangeSize().Y, GetRangeSize().Z))
end)

BallAura:NewSlider("Range Height", "The range height for Ball Aura", 250, 1, function(s)
    UpdateRange(Vector3.new(GetRangeSize().X, s, GetRangeSize().Z))
end)

BallAura:NewSlider("Range Length", "The range length for Ball Aura", 250, 1, function(s)
    UpdateRange(Vector3.new(GetRangeSize().X, GetRangeSize().Y, s))
end)

BallAura:NewToggle("Visual Range", "Whether or not the range is visible.", function(state)
    getgenv().BallAuraVisible = state
end)

--// main -> character
Character:NewSlider("Speed", "The character's speed.", 100, 16, function(s)
    getgenv().WalkSpeed = s
end)

Character:NewSlider("Jump Power", "The character's jump power.", 500, 50, function(s)
    getgenv().JumpPower = s
end)

--// fun tab sections
local Ball = Fun:NewSection("Ball")

local savedBallCFrame = nil
getgenv().ControlBall = false

--// fun -> ball
Ball:NewButton("Destroy Ball", "Destroys the Ball.", function()
    GetBallOwnership()
    if GetBall() == nil then return end
    if savedBallCFrame ~= nil then return end
    savedBallCFrame = GetBall().CFrame
    GetBall().CFrame = CFrame.new(0, 250, 0)
end)

Ball:NewButton("Restore Ball", "Restores the Ball.", function()
    GetBallOwnership()
    if GetBall() == nil then return end
    if savedBallCFrame == nil then return end
    GetBall().CFrame = savedBallCFrame
    task.wait(5)
    savedBallCFrame = nil
end)

Ball:NewToggle("Control Ball", "Teleports the ball to your mouse.", function(state)
    getgenv().ControlBall = state
end)

--// other tab sections
local Anticheat = Other:NewSection("Anticheat")
local Credits = Other:NewSection("Credits")

--// other -> anticheat
Anticheat:NewButton("Anticheat Bypass", "Bypasses the anticheat. Needed for certain features.", function()
    if getgenv().AnticheatBypassed == false then
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        local protect = newcclosure or protect_function
    
        if not protect then
            protect = function(f) 
                return f 
            end
        end
    
        setreadonly(mt, false)
        mt.__namecall = protect(function(self, ...)
        local method = getnamecallmethod()
            if method == "Kick" then
                wait(9e9)
                return
            end
            return old(self, ...)
        end)
        hookfunction(Player.Kick,protect(function() 
            wait(9e9) 
        end))
        getgenv().AnticheatBypassed = true
    end
end)

--// other -> credits
Credits:NewLabel("Made by dorian")
Credits:NewLabel("discord.gg/QNZa9YJh7h")

--// loop
RunService.Heartbeat:Connect(function(deltaTime)
    if getgenv().AutoGoal then
        ScoreGoal()
    end
    if getgenv().BallAura and IsInRange(GetBall()) then
        KickBall(math.huge) 
    end

    UpdateRange()
    SetRangeVisible(getgenv().BallAuraVisible)

    if getgenv().ControlBall then
        GetBallOwnership()
        if GetBall() == nil then return end
        GetBall().CFrame = CFrame.new(Mouse.Hit.Position.X, Mouse.Hit.Position.Y, Mouse.Hit.Position.Z)
    end

    if getgenv().AnticheatBypassed then
        if Player:WaitForChild("PlayerGui"):WaitForChild("UI"):WaitForChild("M"):WaitForChild("Countdown").Visible then return end
        if Humanoid == nil then
            if Character == nil then Character = workspace:WaitForChild(Player.Name) end
            Humanoid = Character:WaitForChild("Humanoid")
        end
        Humanoid.WalkSpeed = getgenv().WalkSpeed
        Humanoid.JumpPower = getgenv().JumpPower
    end
end)
