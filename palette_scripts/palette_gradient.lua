local PaletteUtils = include("palette_scripts.palette_utils")
local PaletteKeyframes = include("palette_scripts.palette_keyframes")

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
---@param mode InterpolationMode? Optional. Determines how the color is evaluated. "Blend" linearly
---                          interpolates between the two surrounding keys. "Fixed" returns the next 
---                          key's color (the first key with a timestamp greater than `time`), 
---                          producing abrupt transitions. Default: "Blend".
function PaletteGradient:EvaluateColor(keys, time, mode)
    mode = mode or "Blend"
    return PaletteKeyframes.Evaluate(keys, time, "Color", KColor.White, mode, PaletteUtils.LerpKColor)
end

--- Evaluates a color from a list of alpha keys at the specified `time`.
--- 
--- If the list of keys is empty, 1 is returned. Alternatively, if `time` is outside the range of 
--- keys, the closest endpoint alpha is returned
---@param keys PaletteAlphaKey[] The alpha keys, sorted by timestamp.
---@param time number The time at which to evaluate the alpha.
---@param mode InterpolationMode? Optional. Determines how the alpha is evaluated. "Blend" linearly
---                          interpolates between the two surrounding keys. "Fixed" returns the next 
---                          key's alpha (the first key with a timestamp greater than `time`), 
---                          producing abrupt transitions. Default: "Blend".
function PaletteGradient:EvaluateAlpha(keys, time, mode)
    mode = mode or "Blend"
    return PaletteKeyframes.Evaluate(keys, time, "Alpha", 1, mode, PaletteUtils.Lerp)
end

--- Returns a `KColor` from the provided `gradient` based on `time`.
---@param gradient PaletteGradient
---@param time number
---@param mode InterpolationMode Optional. Determines how the color is evaluated. "Blend" linearly
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