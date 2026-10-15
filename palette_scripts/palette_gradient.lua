local PaletteUtils = include("palette_scripts.palette_utils")

---@class PaletteGradientKey
---@field Time number
---@field Color KColor

---@class PaletteAlphaKey
---@field Time number
---@field Alpha number

local PaletteGradient = {}

--- Evaluates a color from a list of color keys at the specified `time`.
--- 
--- If the list of keys is empty, `KColor.White` is returned. Alternatively, if `time` is outside
--- the range of keys, the closest endpoint color is returned
---@param keys PaletteGradientKey[] The color keys, sorted by timestamp.
---@param time number The time at which to evaluate the color.
---@param mode GradientMode? Optional. Determines how the color is evaluated. "Blend" linearly
---                          interpolates between the two surrounding keys. "Fixed" returns the next 
---                          key's color (the first key with a timestamp greater than `time`), 
---                          producing abrupt transitions. Default: "Blend".
function PaletteGradient:EvaluateColor(keys, time, mode)
    mode = mode or "Blend"
    
    if #keys == 0 then
        return KColor.White
    elseif time <= keys[1].Time then
        return keys[1].Color
    elseif time >= keys[#keys].Time then
        return keys[#keys].Color
    end
    
    local min, max

    for i = 2, #keys do
        if keys[i].Time > time then
            if mode == "Fixed" then
                return keys[i - 1].Color
            end

            min = keys[i - 1]
            max = keys[i]
            break
        end
    end

    local t = (time - min.Time) / (max.Time - min.Time)
    return PaletteUtils:LerpKColor(min.Color, max.Color, t)
end

--- Evaluates a color from a list of alpha keys at the specified `time`.
--- 
--- If the list of keys is empty, 1 is returned. Alternatively, if `time` is outside the range of 
--- keys, the closest endpoint alpha is returned
---@param keys PaletteAlphaKey[] The alpha keys, sorted by timestamp.
---@param time number The time at which to evaluate the alpha.
---@param mode GradientMode? Optional. Determines how the alpha is evaluated. "Blend" linearly
---                          interpolates between the two surrounding keys. "Fixed" returns the next 
---                          key's alpha (the first key with a timestamp greater than `time`), 
---                          producing abrupt transitions. Default: "Blend".
function PaletteGradient:EvaluateAlpha(keys, time, mode)
    mode = mode or "Blend"

    if #keys == 0 then
        return 1
    elseif time <= keys[1].Time then
        return keys[1].Alpha
    elseif time >= keys[#keys].Time then
        return keys[#keys].Alpha
    end
    
    local min, max

    for i = 2, #keys do
        if keys[i].Time > time then
            if mode == "Fixed" then
                return keys[i - 1].Alpha
            end

            min = keys[i - 1]
            max = keys[i]
            break
        end
    end

    local t = (time - min.Time) / (max.Time - min.Time)
    return PaletteUtils:Lerp(min.Alpha, max.Alpha, t)
end

--- Returns a `KColor` from the provided `gradient` based on `time`.
---@param gradient PaletteGradient
---@param time number
---@param mode GradientMode Optional. Determines how the color is evaluated. "Blend" linearly
---                         interpolates between the two surrounding keys. "Fixed" returns the next 
---                         key's color (the first key with a timestamp greater than `time`), 
---                         producing abrupt transitions. Default: "Blend".
function PaletteGradient:Evaluate(gradient, time, mode)
    mode = mode or gradient.Mode or "Blend"
    local color = PaletteGradient:EvaluateColor(gradient.ColorKeys, time, mode)
    local alpha = PaletteGradient:EvaluateAlpha(gradient.AlphaKeys, time, mode)
    return KColor(color.Red, color.Green, color.Blue, alpha)
end

--- Constructs a new gradient object.
---@return PaletteGradient
function PaletteGradient:New()
    ---@type PaletteGradient
    local newGradient = {
        Mode = "Blend",
        ColorKeys = {
            { Time = 0, Color = KColor.White },
            { Time = 1, Color = KColor.White },
        },
        AlphaKeys = {
            { Time = 0, Alpha = 1},
            { Time = 1, Alpha = 1 }
        },
    }

    return newGradient
end

return PaletteGradient