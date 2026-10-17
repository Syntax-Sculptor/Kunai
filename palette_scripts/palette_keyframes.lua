local PaletteKeyframes = {}

--- Finds the closest two keyframes relative to `time` and returns them.
---@generic T
---@param keyframes table[]
---@param time number
---@param valueName string
---@param defaultValue T
---@return KeyframeSegment
function PaletteKeyframes.FindSegment(keyframes, time, valueName, defaultValue)
    if #keyframes == 0 then
        return { Left = defaultValue, Right = defaultValue, Alpha = 1}
    elseif time <= keyframes[1].Time then
        local firstValue = keyframes[1][valueName]
        return { Left = firstValue, Right = firstValue, Alpha = 1}
    elseif time >= keyframes[#keyframes].Time then
        local maxValue = keyframes[#keyframes][valueName]
        return { Left = maxValue, Right = maxValue, Alpha = 1}
    end
    
    local min, max

    for i = 2, #keyframes do
        if keyframes[i].Time > time then
            min = keyframes[i - 1]
            max = keyframes[i]
            break
        end
    end
    
    return {
        Left = min[valueName],
        Right = max[valueName],
        Alpha = (time - min.Time) / (max.Time - min.Time)
    }
end

---@generic T
---@param keyframes table[]
---@param time number
---@param valueName string
---@param defaultValue T
---@param mode GradientMode
---@param lerpFunction fun(a: T, b: T, t: number)
function PaletteKeyframes.Evaluate(keyframes, time, valueName, defaultValue, mode, lerpFunction)
    local segment = PaletteKeyframes.FindSegment(keyframes, time, valueName, defaultValue)

    if mode == "Fixed" then
        return segment.Left
    else
        return lerpFunction(segment.Left, segment.Right, segment.Alpha)
    end
end

return PaletteKeyframes