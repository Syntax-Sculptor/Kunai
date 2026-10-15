local KunaiUtils = {}

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


return KunaiUtils