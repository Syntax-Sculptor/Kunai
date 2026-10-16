local PaletteUtils = {}

local utilsRNG = RNG(Random(), 35)

---@param a number
---@param b number
---@param t number
function PaletteUtils:Lerp(a, b, t)
    return a + (b - a) * t
end

---@param a KColor
---@param b KColor
---@param t number
function PaletteUtils:LerpKColor(a, b, t)
    return KColor(
        PaletteUtils:Lerp(a.Red, b.Red, t),
        PaletteUtils:Lerp(a.Green, b.Green, t),
        PaletteUtils:Lerp(a.Blue, b.Blue, t),
        PaletteUtils:Lerp(a.Alpha, b.Alpha, t)
    )
end


---@param left KColor
---@param right KColor
function PaletteUtils:MultiplyKColor(left, right)
    return KColor(
        left.Red * right.Red,
        left.Green * right.Green,
        left.Blue * right.Blue,
        left.Alpha * right.Alpha
    )
end

--- Returns a random number between 0 (inclusive) and 1 (exclusive).
--- 
--- You can pass a seed to generate a random number using it. Alternatively, you can pass a `RNG`
--- object to generate the number (which advances its seed). If you pass nothing, a random number
--- is generated using Palette's internal RNG object.
---@param rngOrSeed RNG | integer | nil
function PaletteUtils:GetRandom(rngOrSeed)
    if type(rngOrSeed) == "number" then
        local rng = RNG(rngOrSeed, 35)
        return rng:RandomFloat()
    elseif type(rngOrSeed) == "userdata" then
        ---@cast rngOrSeed RNG
        return rngOrSeed:RandomFloat()
    else
        return utilsRNG:RandomFloat()
    end
end

return PaletteUtils