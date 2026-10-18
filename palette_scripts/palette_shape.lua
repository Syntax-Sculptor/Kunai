local PaletteShape = {}

local PaletteUtils = include("palette_scripts.palette_utils")
local Vector3 = include("palette_scripts.vector3")

---@param shape PaletteShapeConfig
---@param emitterPosition Vector3
---@param orientation number
---@return Vector3
function PaletteShape.GetSpawnPosition(shape, emitterPosition, orientation)
    if shape.Type == "Point" then
        return emitterPosition
    elseif shape.Type == "Circle" then
        -- Inverse Transform Sampling so we can generate a position uniformly distributed inside
        -- the circle's thickness.
        local u = PaletteUtils.GetRandom()
        local minRadius = shape.Radius * (1 - shape.RadiusThickness)
        local chosenRadius = math.sqrt(minRadius^2 + u * (shape.Radius^2 - minRadius^2))
        local angle = math.rad(PaletteUtils.GetRandomFloat(0, shape.Arc) + orientation)

        return emitterPosition + Vector3.new(
            chosenRadius * math.cos(angle),
            chosenRadius * math.sin(angle),
            0
        )
    elseif shape.Type == "Rectangle" then
        local randX = PaletteUtils.GetRandomFloat(-shape.Size.X / 2, shape.Size.X / 2)
        local randY = PaletteUtils.GetRandomFloat(-shape.Size.Y / 2, shape.Size.Y / 2)

        local offset = Vector3.new(randX, randY, 0)
        offset:RotateZ(orientation)

        return emitterPosition + offset
    elseif shape.Type == "Box" then
        local randX = PaletteUtils.GetRandomFloat(-shape.Size.X / 2, shape.Size.X / 2)
        local randY = PaletteUtils.GetRandomFloat(-shape.Size.Y / 2, shape.Size.Y / 2)
        local randZ = PaletteUtils.GetRandomFloat(-shape.Size.Z / 2, shape.Size.Z / 2)

        local offset = Vector3.new(randX, randY, randZ)
        offset:RotateZ(orientation)

        return emitterPosition + offset
    elseif shape.Type == "Sphere" then
        -- Inverse Transform Sampling... again!
        -- https://corysimon.github.io/articles/uniformdistn-on-sphere/ Thank this goat
        local u, v, w = PaletteUtils.GetRandom(), PaletteUtils.GetRandom(), PaletteUtils.GetRandom()

        local minRadius = shape.Radius * (1 - shape.RadiusThickness)
        local chosenRadius = (minRadius^3 + u * (shape.Radius^3 - minRadius^3)) ^ (1/3)
        local angle = 2 * math.pi * w
        local z = 2 * v - 1
        local x = math.sqrt(1 - z^2) * math.cos(angle)
        local y = math.sqrt(1 - z^2) * math.sin(angle)

        return emitterPosition + Vector3.new(x, y, z) * chosenRadius
    else
        error("Unsupported particle shape: " .. shape.Type)
    end
end


---@param shape PaletteShapeConfig
---@param emitterPosition Vector3
---@param startPosition Vector3
---@param startDirection Vector3
---@return Vector3
function PaletteShape.GetDirection(shape, emitterPosition, startPosition, startDirection)
    if shape.DirectionMode == "Default" then
        return startDirection:Copy()
    elseif shape.DirectionMode == "Radial" then
        local vec = startPosition - emitterPosition

        if vec:LengthSquared() == 0 then
            return startDirection:Copy()
        end

        return vec:Normalize()
    else
        error("Unsupported shape direction mode: " .. tostring(shape.DirectionMode))
    end
end

return PaletteShape