local PaletteUtils = {}

local utilsRNG = RNG(Random(), 35)

---@param vec Vector3
---@return Vector3
function PaletteUtils:CopyVector3(vec)
    return {
        X = vec.X,
        Y = vec.Y,
        Z = vec.Z
    }
end

--- Adds two Vector3 objects..
---@param left Vector3
---@param right Vector3
---@return Vector3
function PaletteUtils:AddVector3(left, right)
    return {
        X = left.X + right.X,
        Y = left.Y + right.Y,
        Z = left.Z + right.Z
    }
end

--- Subtracts two Vector3 objects..
---@param left Vector3
---@param right Vector3
---@return Vector3
function PaletteUtils:SubtractVector3(left, right)
    return {
        X = left.X - right.X,
        Y = left.Y - right.Y,
        Z = left.Z - right.Z
    }
end

--- Divides a Vector3 object by a number. Errors if the number is 0.
---@param left Vector3
---@param right number
---@return Vector3
function PaletteUtils:DivideVector(left, right)
    assert(right ~= 0, "Attempted to divide Vector3 by 0")

    return {
        X = left.X / right,
        Y = left.Y / right,
        Z = left.Z / right
    }
end

---@param vec Vector3
---@param scale number
---@return Vector3
function PaletteUtils:ResizeVector3(vec, scale)
    return {
        X = vec.X * scale,
        Y = vec.Y * scale,
        Z = vec.Z * scale
    }
end

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

---@param vec Vector
---@return Vector3
function PaletteUtils:VectorToVector3(vec)
    return {
        X = vec.X,
        Y = vec.Y,
        Z = 0
    }
end

---@param vec Vector3
---@param angle number
---@return Vector3
function PaletteUtils:RotateVector3(vec, angle)
    -- Realistically, we could just construct a `Vector` object and call `Rotate` but maybe avoiding
    -- unnecessarily allocations like that might be the best?
    -- TODO: BENCHMARK that observation.

    local radians = math.rad(angle)
    local cos = math.cos(radians)
    local sin = math.sin(radians)

    return {
        X = vec.X * cos - vec.Y * sin,
        Y = vec.X * sin + vec.Y * cos,
        Z = vec.Z
    }
end

---@param vec Vector3
function PaletteUtils:NormalizeVector3(vec)
    local length = math.sqrt(vec.X^2 + vec.Y^2 + vec.Z^2)

    if length == 0 then
        return {X = 0, Y = 0, Z = 0}
    end
    
    return PaletteUtils:DivideVector(vec, length)
end

return PaletteUtils