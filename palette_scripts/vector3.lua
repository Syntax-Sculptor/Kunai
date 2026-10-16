---@class Vector3
---@field X number
---@field Y number
---@field Z number
local Vector3 = {}
Vector3.__index = Vector3

---@param a Vector3
---@param b Vector3
Vector3.__add = function(a, b)
    return Vector3.new(
        a.X + b.X,
        a.Y + b.Y,
        a.Z + b.Z
    )
end

---@param a Vector3
---@param b Vector3
Vector3.__sub = function(a, b)
    return Vector3.new(
        a.X - b.X,
        a.Y - b.Y,
        a.Z - b.Z
    )
end

---@param a Vector3 | number
---@param b Vector3 | number
Vector3.__mul = function(a, b)
    if type(a) == "number" then
        a, b = b, a
    end

    if type(b) == "number" then
        return Vector3.new(
            a.X * b,
            a.Y * b,
            a.Z * b
        )
    else
        return Vector3.new(
            a.X * b.X,
            a.Y * b.Y,
            a.Z * b.Z
        )
    end
end

---@param a Vector3
---@param b Vector3 | number
Vector3.__div = function(a, b)
    assert(b ~= 0, "Divide by zero")
    assert(type(b) == "number" or (getmetatable(b) == Vector3 and b.X ~= 0 and b.Y ~= 0 and b.Z ~= 0), "Divide by zero")

    if type(b) == "number" then
        return Vector3.new(
            a.X / b,
            a.Y / b,
            a.Z / b
        )
    else
        return Vector3.new(
            a.X / b.X,
            a.Y / b.Y,
            a.Z / b.Z
        )
    end
end

---@param a Vector3
Vector3.__unm = function(a)
    return Vector3.new(-a.X, -a.Y, -a.Z)
end

---@param a Vector3
---@param b any
Vector3.__eq = function(a, b)
    if type(b) ~= "table" or getmetatable(b) ~= Vector3 then
        return false
    end

    return a.X == b.X and a.Y == b.Y and a.Z == b.Z
end

---@param a Vector3
Vector3.__tostring = function(a)
    return a.X .. " " .. a.Y .. " " .. a.Z
end

--- Constructs a new Vector3 object.
---@param x number? Optional. Default: 0
---@param y number? Optional. Default: 0
---@param z number? Optional. Default: 0
---@return Vector3
function Vector3.new(x, y, z)
    x = x or 0
    y = y or 0
    z = z or 0

    local self = {}
    self.X = x
    self.Y = y
    self.Z = z
    setmetatable(self, Vector3)

    return self
end

---@param vec Vector | Vector3
---@return Vector3
function Vector3.fromVector(vec)
    return Vector3.new(vec.X, vec.Y, vec.Z or 0)
end

--- Copies a Vector3 object.
function Vector3:Copy()
    return Vector3.new(self.X, self.Y, self.Z)
end

function Vector3:Length()
    return math.sqrt(self.X^2 + self.Y^2 + self.Z^2)
end

function Vector3:LengthSquared()
    return self.X^2 + self.Y^2 + self.Z^2
end

function Vector3:Normalize()
    local res = self:Normalized()
    self.X = res.X
    self.Y = res.Y
    self.Z = res.Z
    return self
end

function Vector3:Normalized()
    local length = self:Length()
    
    if length == 0 then
        return Vector3.new(0, 0, 0)
    end

    return self / length
end

---@param b Vector3
function Vector3:Distance(b)
    return math.sqrt((b.X - self.X)^2 + (b.Y - self.Y)^2 + (b.Z - self.Z)^2)
end

---@param b Vector3
function Vector3:DistanceSquared(b)
    return (b.X - self.X)^2 + (b.Y - self.Y)^2 + (b.Z - self.Z)^2
end

---@param b Vector3
function Vector3:Dot(b)
    return (self.X * b.X) + (self.Y * b.Y) + (self.Z * b.Z)
end

---@param b Vector3
function Vector3:Cross(b)
    return Vector3.new(
        self.Y * b.Z - self.Z * b.Y, 
        self.Z * b.X - self.X * b.Z, 
        self.X * b.Y - self.Y * b.X
    )
end

---@param b Vector3
---@param t number
function Vector3:Lerp(b, t)
    t = math.max(0, math.min(1, t))
    return self + (b - self) * t
end

---@param degrees number
function Vector3:RotatedX(degrees)
    local angle = math.rad(degrees)
    local sin = math.sin(angle)
    local cos = math.cos(angle)

    return Vector3.new(
        self.X,
        self.Y * cos - self.Z * sin,
        self.Y * sin + self.Z * cos
    )
end

---@param degrees number
function Vector3:RotatedY(degrees)
    local angle = math.rad(degrees)
    local sin = math.sin(angle)
    local cos = math.cos(angle)

    return Vector3.new(
        self.X * cos + self.Z * sin,
        self.Y,
        -self.X * sin + self.Z * cos
    )
end

---@param degrees number
function Vector3:RotatedZ(degrees)
    local angle = math.rad(degrees)
    local sin = math.sin(angle)
    local cos = math.cos(angle)

    return Vector3.new(
        self.X * cos - self.Y * sin,
        self.X * sin + self.Y * cos,
        self.Z
    )
end

---@param degrees number
function Vector3:RotateX(degrees)
    local angle = math.rad(degrees)
    local sin = math.sin(angle)
    local cos = math.cos(angle)

    local newY = self.Y * cos - self.Z * sin
    local newZ = self.Y * sin + self.Z * cos
    self.Y = newY
    self.Z = newZ
    return self
end

---@param degrees number
function Vector3:RotateY(degrees)
    local angle = math.rad(degrees)
    local sin = math.sin(angle)
    local cos = math.cos(angle)

    local newX = self.X * cos + self.Z * sin
    local newZ = -self.X * sin + self.Z * cos
    self.X = newX
    self.Z = newZ
    return self
end

---@param degrees number
function Vector3:RotateZ(degrees)
    local angle = math.rad(degrees)
    local sin = math.sin(angle)
    local cos = math.cos(angle)

    local newX = self.X * cos - self.Y * sin
    local newY = self.X * sin + self.Y * cos
    self.X = newX
    self.Y = newY
    return self
end

function Vector3.One()
    return Vector3.new(1, 1, 1)
end

function Vector3.Zero()
    return Vector3.new()
end

function Vector3:ToVector()
    return Vector(self.X, self.Y)
end

---@param x number
function Vector3:Resize(x)
    local length = self:Length()

    if length == 0 then
        return self
    end
    
    local newLength = x / length
    self.X = self.X * newLength
    self.Y = self.Y * newLength
    self.Z = self.Z * newLength
    return self
end

---@param x number
function Vector3:Resized(x)
    return self:Copy():Resize(x)
end

return Vector3