local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local aimEnabled, aimToggle, chamsEnabled = false, false, false
local trackedPlayer = nil  -- Игрок, за которым будет следить aimbot
local aimKey = Enum.KeyCode.LeftAlt
local aimRadius = 300  -- Радиус круга aimbot (по умолчанию 300)
local chamsObjects = {}  -- Для хранения объектов Chams

-- Создание меню GUI
local screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
screenGui.Name = "AimbotChamsMenu"

-- Основное меню
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 230)
mainFrame.Position = UDim2.new(0.5, -100, 0.4, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.Visible = false  -- Меню скрыто по умолчанию
mainFrame.Active = true
mainFrame.Draggable = true

-- Заголовок меню
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, -30)
titleLabel.Text = ""
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSans
titleLabel.TextSize = 18

-- Кнопка для включения и выключения Aimbot
local aimButton = Instance.new("TextButton", mainFrame)
aimButton.Size = UDim2.new(1, -20, 0, 30)
aimButton.Position = UDim2.new(0, 10, 0, 10)
aimButton.Text = "Toggle Aimbot (OFF)"
aimButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- Кнопка для включения и выключения CHAMS
local chamsButton = Instance.new("TextButton", mainFrame)
chamsButton.Size = UDim2.new(1, -20, 0, 30)
chamsButton.Position = UDim2.new(0, 10, 0, 50)
chamsButton.Text = "Toggle CHAMS (OFF)"
chamsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- Ползунок для регулировки радиуса круга aimbot
local radiusSliderLabel = Instance.new("TextLabel", mainFrame)
radiusSliderLabel.Size = UDim2.new(1, -20, 0, 20)
radiusSliderLabel.Position = UDim2.new(0, 10, 0, 90)
radiusSliderLabel.Text = "Aimbot Radius: " .. aimRadius
radiusSliderLabel.BackgroundTransparency = 1
radiusSliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusSliderLabel.Font = Enum.Font.SourceSans
radiusSliderLabel.TextSize = 14

-- Кнопка для увеличения радиуса круга
local increaseRadiusButton = Instance.new("TextButton", mainFrame)
increaseRadiusButton.Size = UDim2.new(0.5, -10, 0, 30)
increaseRadiusButton.Position = UDim2.new(0, 10, 0, 120)
increaseRadiusButton.Text = "+"
increaseRadiusButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- Кнопка для уменьшения радиуса круга
local decreaseRadiusButton = Instance.new("TextButton", mainFrame)
decreaseRadiusButton.Size = UDim2.new(0.5, -10, 0, 30)
decreaseRadiusButton.Position = UDim2.new(0.5, 0, 0, 120)
decreaseRadiusButton.Text = "-"
decreaseRadiusButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- Кнопка для сворачивания меню (не делает ничего)
local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Size = UDim2.new(1, -20, 0, 30)
closeButton.Position = UDim2.new(0, 10, 0, 200)
closeButton.Text = "Script by Alowyyy. , _gimgo10_"
closeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- Переключение aimbot через меню
aimButton.MouseButton1Click:Connect(function()
    aimToggle = not aimToggle
    aimButton.Text = "Toggle Aimbot (" .. (aimToggle and "ON" or "OFF") .. ")"
end)

-- Переключение CHAMS через меню
chamsButton.MouseButton1Click:Connect(function()
    chamsEnabled = not chamsEnabled
    chamsButton.Text = "Toggle CHAMS (" .. (chamsEnabled and "ON" or "OFF") .. ")"
end)

-- Закрытие меню (не делает ничего)
closeButton.MouseButton1Click:Connect(function()
    -- Ничего не делаем, просто оставляем кнопку
end)

-- Изменение радиуса круга
increaseRadiusButton.MouseButton1Click:Connect(function()
    aimRadius = aimRadius + 50
    radiusSliderLabel.Text = "Aimbot Radius: " .. aimRadius
end)

decreaseRadiusButton.MouseButton1Click:Connect(function()
    if aimRadius > 50 then
        aimRadius = aimRadius - 50
        radiusSliderLabel.Text = "Aimbot Radius: " .. aimRadius
    end
end)

-- Создание круга aimbot
local aimCircle = Drawing.new("Circle")
aimCircle.Visible = true
aimCircle.Transparency = 1
aimCircle.Thickness = 2
aimCircle.Color = Color3.new(1, 1, 0)  -- Цвет круга (жёлтый)
aimCircle.Filled = false

-- Функция для прицеливания на середину головы с небольшим смещением вниз
local function aimAtHead(target)
    if target and target:FindFirstChild("Head") then
        local head = target.Head
        local adjustedPosition = head.Position + Vector3.new(0, head.Size.Y / 3, 0)
        camera.CFrame = CFrame.new(camera.CFrame.Position, adjustedPosition)
    end
end

-- Нахождение ближайшего игрока в радиусе круга
local function getClosestPlayerInRadius()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPoint, onScreen = camera:WorldToScreenPoint(player.Character.Head.Position)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
            if onScreen and distance < shortestDistance and distance <= aimRadius then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    return closestPlayer
end

-- Управление активацией aimbot с помощью Left Alt
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == aimKey and aimToggle then
        if trackedPlayer then
            trackedPlayer = nil
            aimEnabled = false
        else
            trackedPlayer = getClosestPlayerInRadius()
            aimEnabled = trackedPlayer ~= nil
        end
    end
end)

-- Функция для добавления CHAMS (без изменений для вашего персонажа)
local function addChams(player)
    if player == localPlayer then return end  -- Вашему персонажу чамсы не нужны
    if not player.Character then return end

    -- Получаем цвет команды
    local teamColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 0, 0)  -- Красный по умолчанию

    for _, part in pairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") then
            local chamsPart = Instance.new("BoxHandleAdornment")
            chamsPart.Size = part.Size
            chamsPart.AlwaysOnTop = true
            chamsPart.ZIndex = 5
            chamsPart.Adornee = part
            chamsPart.Color3 = teamColor
            chamsPart.Transparency = 0.5
            chamsPart.Parent = part

            -- Сохраняем объект в таблице
            if not chamsObjects[player] then
                chamsObjects[player] = {}
            end
            table.insert(chamsObjects[player], chamsPart)
        end
    end
end

-- Функция для удаления CHAMS
local function removeChams(player)
    if chamsObjects[player] then
        for _, chamsPart in pairs(chamsObjects[player]) do
            chamsPart:Destroy()
        end
        chamsObjects[player] = nil
    end
end

-- Обновление CHAMS для всех игроков
game:GetService("RunService").RenderStepped:Connect(function()
    if chamsEnabled then
        for _, player in pairs(players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                addChams(player)
            end
        end
    else
        for _, player in pairs(players:GetPlayers()) do
            removeChams(player)
        end
    end

    -- Обновление круга aimbot
    aimCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    aimCircle.Radius = aimRadius

    if aimEnabled and trackedPlayer and trackedPlayer.Character then
        aimAtHead(trackedPlayer.Character)
    end
end)

-- Открытие/закрытие меню по клавише Insert
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
