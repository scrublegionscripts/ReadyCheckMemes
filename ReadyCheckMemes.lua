local addonName = "ReadyCheckMemes"

-- Create saved variables table
ReadyCheckMemesDB = ReadyCheckMemesDB or {}

local frame = CreateFrame("Frame", "ReadyCheckFrame", UIParent)
frame:SetSize(256, 256)
frame:SetFrameStrata("HIGH")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

-- Make frame draggable
frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save position
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    ReadyCheckMemesDB.point = point
    ReadyCheckMemesDB.relativePoint = relativePoint
    ReadyCheckMemesDB.xOfs = xOfs
    ReadyCheckMemesDB.yOfs = yOfs
end)

-- Load saved position or use default
local function LoadPosition()
    if ReadyCheckMemesDB.point then
        frame:ClearAllPoints()
        frame:SetPoint(
            ReadyCheckMemesDB.point,
            UIParent,
            ReadyCheckMemesDB.relativePoint,
            ReadyCheckMemesDB.xOfs,
            ReadyCheckMemesDB.yOfs
        )
    else
        frame:SetPoint("CENTER")
    end
end

local texture = frame:CreateTexture()
texture:SetAllPoints(frame)
frame:Hide()

local NUM_IMAGES = 17
local HIDE_DELAY = 10 -- seconds to wait before hiding
local hideTimer = nil

local function OnReadyCheck()
    -- Cancel any existing timer
    if hideTimer then
        hideTimer:Cancel()
        hideTimer = nil
    end
    
    local randomNumber = math.random(1, NUM_IMAGES)
    local imagePath = string.format("Interface\\Addons\\ReadyCheckMemes\\media\\%d.tga", randomNumber)

    texture:SetTexture(imagePath)

    frame:Show()
end

local function OnReadyCheckConfirm()
    
    -- Start timer to hide frame after delay
    hideTimer = C_Timer.NewTimer(HIDE_DELAY, function()
        frame:Hide()
        hideTimer = nil
    end)
end

frame:RegisterEvent("READY_CHECK")
frame:RegisterEvent("READY_CHECK_CONFIRM")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event)
    if event == "READY_CHECK" then
        OnReadyCheck()
    elseif event == "READY_CHECK_CONFIRM" then
        OnReadyCheckConfirm()
    elseif event == "PLAYER_LOGIN" then
        LoadPosition()
    end
end)