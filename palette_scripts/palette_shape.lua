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
    else
        error("Unsupported particle shape: " .. shape.Type)
    end
end

return PaletteShape