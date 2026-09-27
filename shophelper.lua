-- ============================================================
-- Shopkeeper Helper (Tester)
-- Авто-экипировка, авто-уборка, авто-продажа, авто-разгрузка
-- ============================================================

-- ==================== КОНФИГ ====================
local CFG = {
    TrashKeys   = {"trash","puddle","cola","spill","garbage","mud"},
    MopKeys     = {"puddle","cola","spill","wet"},
    BroomKeys   = {"trash","garbage","dry"},
    GloveKeys   = {"glove"},
    ScannerKeys = {"scanner","scan","register","cashier","kassa","barcode"},
    BoxKeys     = {"box","crate","delivery","package"},
    ShelfKeys   = {"shelf","rack","stand"},
}
-- ===============================================

local F=loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local P=game:GetService("Players")
local W=game:GetService("Workspace")
local L=P.LocalPlayer
local win=F:CreateWindow({Title="Shopkeeper Helper",SubTitle="Tester",TabWidth=160,Size=UDim2.fromOffset(520,360),Acrylic=true,Theme="Dark",MinimizeKey=Enum.KeyCode.LeftControl})
local T=win:AddTab({Title="Main",Icon="home"})

local C,S,U = false,false,false

-- ==================== УТИЛИТЫ ====================
local function root()
    local c=L.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function press(obj)
    if not obj then return false end
    local d=obj:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildWhichIsA("ClickDetector",true)
    if d then
        if fireclickdetector then fireclickdetector(d,10) else d:MouseClick() end
        return true
    end
    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        if firesignal then firesignal(obj.MouseButton1Click) else obj.MouseButton1Click:Fire() end
        return true
    end
    local pp=obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt",true)
    if pp then
        if fireproximityprompt then fireproximityprompt(pp) end
        return true
    end
    return false
end

local function tp(pos)
    local r=root()
    if r and pos then r.CFrame=CFrame.new(pos+Vector3.new(0,3,0)) end
end

local function findWorld(keys)
    for _,o in ipairs(W:GetDescendants()) do
        if o:IsDescendantOf(W) and not o:IsA("Script") and not o:IsA("LocalScript") then
            local n=o.Name:lower()
            for _,k in ipairs(keys) do
                if n:find(k) then return o end
            end
        end
    end
end

local function equip(name)
    local c=L.Character
    if not c then return end
    local cur=c:FindFirstChildOfClass("Tool")
    if cur and cur.Name:lower():find(name:lower()) then return end
    local bp=L:FindFirstChild("Backpack")
    if bp then
        local t=bp:FindFirstChild(name)
        if t then
            local h=c:FindFirstChildOfClass("Humanoid")
            if h then h:EquipTool(t) end
            return
        end
    end
    for _,o in ipairs(W:GetDescendants()) do
        if o:IsA("Tool") and o.Name:lower():find(name:lower()) then
            local h=c:FindFirstChildOfClass("Humanoid")
            if h then h:EquipTool(o) end
            return
        end
    end
end

local function equipBoth()
    equip("Mop"); task.wait(0.2); equip("Broom")
end

-- ==================== 1. УБОРКА ====================
T:AddToggle("A",{Title="Авто-уборка",Default=false}):OnChanged(function(s)
    C=s if not s then return end
    task.spawn(function()
        while C do
            local back=root() and root().CFrame
            local target=findWorld(CFG.TrashKeys)
            if target and back then
                local n=target.Name:lower()
                local needMop=false
                for _,k in ipairs(CFG.MopKeys) do if n:find(k) then needMop=true break end end
                if needMop then equip("Mop") else equip("Broom") end
                task.wait(0.2)
                local pivot=target:IsA("Model") and target:GetPivot().Position or target.Position
                tp(pivot); task.wait(0.25)
                press(target); task.wait(0.25)
                local r=root()
                if r then r.CFrame=back end
            end
            task.wait(0.5)
        end
    end)
end)

-- ==================== 2. ПРОДАЖА ====================
T:AddToggle("B",{Title="Авто-продажа",Default=false}):OnChanged(function(s)
    S=s if not s then return end
    task.spawn(function()
        while S do
            local back=root() and root().CFrame
            local glove=findWorld(CFG.GloveKeys)
            if glove and back then
                local gp=glove:IsA("Model") and glove:GetPivot().Position or glove.Position
                tp(gp); task.wait(0.25)
                press(glove); task.wait(0.4)
                local scanner=findWorld(CFG.ScannerKeys)
                if scanner then
                    local sp=scanner:IsA("Model") and scanner:GetPivot().Position or scanner.Position
                    tp(sp); task.wait(0.25)
                    press(scanner); task.wait(0.3)
                end
                local r=root()
                if r then r.CFrame=back end
            end
            task.wait(0.6)
        end
    end)
end)

-- ==================== 3. АВТО-РАЗГРУЗКА (с авто-телепортом к полке) ====================
T:AddToggle("C",{Title="Авто-разгрузка коробок",Default=false}):OnChanged(function(s)
    U=s if not s then return end
    task.spawn(function()
        while U do
            local back=root() and root().CFrame
            local box=findWorld(CFG.BoxKeys)
            if box and back then
                -- 1. Телепорт к коробке
                local bp=box:IsA("Model") and box:GetPivot().Position or box.Position
                tp(bp); task.wait(0.25)

                -- 2. Клик по коробке (берём в руки)
                press(box); task.wait(0.4)

                -- 3. Сразу телепорт к полке
                local shelf=findWorld(CFG.ShelfKeys)
                if shelf then
                    local sp=shelf:IsA("Model") and shelf:GetPivot().Position or shelf.Position
                    tp(sp); task.wait(0.25)

                    -- 4. Клик по полке (разгрузка)
                    press(shelf); task.wait(0.3)
                end

                -- 5. Возврат на исходную позицию
                local r=root()
                if r then r.CFrame=back end
            end
            task.wait(0.8)
        end
    end)
end)

-- ==================== 4. АВТО-ЭКИПИРОВКА ====================
T:AddToggle("D",{Title="Авто-экипировка (Mop/Broom)",Default=false}):OnChanged(function(s)
    if s then
        equipBoth()
        L.CharacterAdded:Connect(function()
            task.wait(2)
            equipBoth()
        end)
    end
end)
