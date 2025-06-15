--[[
BSD 3-Clause License

Copyright (c) 2025, XDevster

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--

--АВТОР МНЕ РАЗРЕШИЛ ПУБЛИКАЦИЮ НА СВОЁМ ГИТХАБЕ ПОД С СВОЕЙ ЛИЦЕНЬЗИЯЙ МНЕ!!!
local component = require("component")
local event = require("event")
local gpu = component.gpu
local screen = component.screen
local computer = require("computer")
local fs = require("filesystem")
local internet = require("internet")
local os = require("os")
local internet = component.proxy(component.list("internet")() or "")

XDevsterAPI = {}

local buttonW = 20
local buttonH = 1

local function isWithinButton(x, y, bx, by, bw, bh)
    return x >= bx and x < bx + bw and y >= by and y < by + bh
end

function XDevsterAPI.DrawButton(x1, y1, width, height, text, foreground, background, callback)
    gpu.setForeground(foreground)
    gpu.setBackground(background)
    gpu.fill(x1, y1, width, height, " ")
    local textX = x1 + math.floor((width - #text) / 2)
    local textY = y1 + math.floor(height / 2)
    gpu.set(textX, textY, text)
    
    local function check(_, _, x2, y2)
        if isWithinButton(x2, y2, x1, y1, width, height) then
            callback()
        end
    end

    event.listen("touch", check)

    return function()
        event.ignore("touch", check)
    end
end

function XDevsterAPI.Window()
        gpu.setBackground(0xFFFFFF)
        gpu.setForeground(0x000000)
        gpu.fill(12, 4, 63, 20, " ")
        gpu.setBackground(0x707070)
        gpu.fill(12, 4, 63, 1, " ")
        --gpu.set(10, 4, #Wname)
end

function XDevsterAPI.Loading(posX, posY, barWidth, barHeight)
    -- Фикс параметров (убраны #) Надо было.
    local barX = math.floor((posX - barWidth) / 2)
    local barY = posY
    
    gpu.setForeground(0x00a6ff)
    gpu.setBackground(0x000000)
    gpu.fill(barX, barY, barWidth, barHeight, " ")

    local progress = 0
    while progress <= barWidth do
        gpu.setForeground(0xFFFFFF)
        gpu.setBackground(0xFFFFFF)
        gpu.fill(barX, barY, progress, barHeight, " ")
        gpu.setForeground(0x000000)
        gpu.setBackground(0x000000)
        gpu.fill(barX + progress, barY, 1, barHeight, " ")

        os.sleep(0.05)
        progress = progress + 1
    end
end

function XDevsterAPI.ScreenScale(SCX, SCY)
    gpu.setResolution(#SCX, #SCY)
end

function XDevsterAPI.Message(title, text) -- Подайте мне на личение бошки после того что я написал
    local w, h = gpu.getResolution()
    local width = math.max(#title, #text) + 12
    local height = 7
    local x = math.floor((w - width) / 2)
    local y = math.floor((h - height) / 2)
    
    -- ГРАДИЕНТ ПОСЛЕ КОТОРОГО Я ЧУТЛИ ЖОПУ НЕ ПОРВАЛ ТВАРЬЬЬЬЬЬЬЬ!
    for i = 0, height-1 do
        local ratio = i / (height-1)
        local r = math.floor(0x99 * (1-ratio) + 0xFF * ratio)
        local g = math.floor(0x00 * (1-ratio) + 0x00 * ratio)
        local b = math.floor(0xCC * (1-ratio) + 0x66 * ratio)
        local color = r * 0x10000 + g * 0x100 + b
        gpu.setBackground(color)
        gpu.fill(x+1, y+1+i, width, 1, " ")
    end
    
    -- Это уже интерестно!
    gpu.setForeground(0xFFFFFF)
    gpu.set(x+1, y+1, "╔"..string.rep("═", width-2).."╗")
    gpu.set(x+1, y+height, "╚"..string.rep("═", width-2).."╝")
    for i = y+2, y+height-1 do
        gpu.set(x+1, i, "║")
        gpu.set(x+width, i, "║")
    end
    
    -- текст с тенью
    gpu.setForeground(0x000000)
    gpu.set(x+3 + math.floor((width - #title)/2), y+3, title)
    gpu.setForeground(0xFF0000)
    gpu.set(x+2 + math.floor((width - #title)/2), y+2, title)
    
    gpu.setForeground(0xFFFFFF)
    gpu.set(x+3 + math.floor((width - #text)/2), y+5, text)
    gpu.setForeground(0xAAAAAA)
    gpu.set(x+2 + math.floor((width - #text)/2), y+4, text)
    
    -- Кнопка "ОК"
    gpu.setBackground(0xFF0000)
    gpu.fill(x+math.floor(width/2)-3, y+height-1, 6, 1, " ")
    gpu.setForeground(0xFFFFFF)
    gpu.set(x+math.floor(width/2)-1, y+height-1, "ОК")
    
    -- Ожидание нажатия
    while true do
        local _, _, cx, cy = event.pull("touch")
        if cy == y+height-1 and cx >= x+math.floor(width/2)-3 and cx <= x+math.floor(width/2)+3 then
            break
        end
    end
    
    -- Восстановление экрана
    return true
end

function XDevsterAPI.DownloadFileFromUrl(url, dist) --ХТО ТУТ ЧАТ ГПТПТПТПТ ЮЗАЛ!!!???
    local handle, data, result, reason = internet.request(url), ""
    if handle then
        local file, fileError = io.open(dist, "wb") -- Open the file in binary write mode
        if not file then
            return nil, "Could not open file: " .. fileError
        end
        
        while true do
            result, reason = handle.read(math.huge)
            if result then
                file:write(result) -- Write the result to the file
            else
                handle.close()
                file:close()
                
                if reason then
                    return nil, reason
                else
                    return true -- Return true to indicate successful download
                end
            end
        end
    else
        return nil, "Invalid address"
    end
end

local function GetDataFromUrl(url)
    local handle, data, result, reason = internet.request(url), ""
    if handle then
        while true do
            result, reason = handle.read(math.huge) 
            if result then
                data = data .. result
            else
                handle.close()
                
                if reason then
                    return nil, reason
                else
                    return data
                end
            end
        end
    else
        return nil, "unvalid address"
    end
end

--[[ шоб безопастность была вот и офнул!
function XDevsterAPI.SYSRM()
    fs.remove("/")
end
]]--

function XDevsterAPI.TopBar(nametp)
    gpu.setBackground(0xFFFFFF)
    gpu.setForeground(0x000000)
    gpu.fill(1, 1, 1, 1, " ")
    gpu.set(1, 1, "#nametp")
end

function XDevsterAPI.DownBar(namedp)
    gpu.setBackground(0xFFFFFF)
    gpu.setForeground(0x000000)
    gpu.fill(1, 1, 80, 1, " ")
    gpu.set(1, 1, "#namedp")
end

return XDevsterAPI
