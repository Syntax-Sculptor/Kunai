local KunaiUtils = {}

local utilsRNG = RNG(Random(), 35)

---@param vec Vector3
---@return Vector3
function KunaiUtils:CopyVector3(vec)
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
function KunaiUtils:AddVector3(left, right)
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
function KunaiUtils:SubtractVector3(left, right)
    return {
        X = left.X - right.X,
        Y = left.Y - right.Y,
        Z = left.Z - right.Z
    }
end

---@param vec Vector3
---@param scale number
---@return Vector3
function KunaiUtils:ResizeVector3(vec, scale)
    return {
        X = vec.X * scale,
        Y = vec.Y * scale,
        Z = vec.Z * scale
    }
end

---@param a number
---@param b number
---@param t number
function KunaiUtils:Lerp(a, b, t)
    return a + (b - a) * t
end

---@param a KColor
---@param b KColor
---@param t number
function KunaiUtils:LerpKColor(a, b, t)
    return KColor(
        KunaiUtils:Lerp(a.Red, b.Red, t),
        KunaiUtils:Lerp(a.Green, b.Green, t),
        KunaiUtils:Lerp(a.Blue, b.Blue, t),
        KunaiUtils:Lerp(a.Alpha, b.Alpha, t)
    )
end


---@param left KColor
---@param right KColor
function KunaiUtils:MultiplyKColor(left, right)
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
--- is generated using Kunai's internal RNG object.
---@param rngOrSeed RNG | integer | nil
function KunaiUtils:GetRandom(rngOrSeed)
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
---@@return Vector3
function KunaiUtils:VectorToVector3(vec)
    return {
        X = vec.X,
        Y = vec.Y,
        Z = 0
    }
end

return KunaiUtils