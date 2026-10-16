local Palette = {}
local ParticleEmitter = include("palette_scripts.particle_emitter")
local PaletteGradient = include("palette_scripts.palette_gradient")
local PaletteUtils = include("palette_scripts.palette_utils")

local initialized = false

---@type ParticleEmitter[]
local emitters = {}

local function onPostRoomRenderEntities()
    for _, particleEmitter in ipairs(emitters) do
        particleEmitter:_Render()
    end
end

local function onPostUpdate()
    for _, particleEmitter in ipairs(emitters) do
        particleEmitter:Update()
    end
end

---@param emitter ParticleEmitter
local function unregisterEmitter(emitter)
    for i, registeredEmitter in ipairs(emitters) do
        if registeredEmitter == emitter then
            table.remove(emitters, i)
            return
        end
    end
end

local function destroyNonPersistentEmitters()
    -- We loop through the emitters backwards since calling :Destroy() on one will cause the 
    -- `emitters` table to shift due to a call to `table.remove`.
    for i = #emitters, 1, -1 do
        local emitter = emitters[i]
        if not emitter.PersistAcrossRooms then
            emitter:Destroy()
        end
    end
end

---@param x number
---@param y number
---@param z number? Default: 0
---@return Vector3
function Palette.Vector3(x, y, z)
    return {
        X = x,
        Y = y,
        Z = z or 0
    }
end

--- Initializes Palette using the provided `mod`. Errors if Palette has already been registered.
---@param mod ModReference
function Palette:Init(mod)
    assert(not initialized, "Palette was already initialized!")
    
    initialized = true

    mod:AddCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, onPostRoomRenderEntities)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, onPostUpdate)
    mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, destroyNonPersistentEmitters)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, destroyNonPersistentEmitters)
end

--- Creates a new `ParticleEmitter`.
---@param texturePath string The file path pointing to the texture used for the emitted particles. It must be a `.png` file with a bit-depth of 32. Invalid file paths will cause an error.
---@param position Vector | Vector3 | nil Optional. The starting position of the emitter. Default is (0, 0, 0)
---@return ParticleEmitter
function Palette:CreateParticleEmitter(texturePath, position)
    assert(initialized, "Palette must be initialized first before calling `CreateParticleEmitter`")

    if not position then
        position = {X = 0, Y = 0, Z = 0}
    else
        position = PaletteUtils:CopyVector3(position)
    end

    ---@cast position Vector3
        
    local image = Renderer.LoadImage(texturePath)
    local sourceQuad = SourceQuad.NewFromRectangle(Vector.Zero, image:GetWidth(), image:GetHeight())

    ---@type ParticleEmitter
    local ParticleEmitterInstance = {
        IsWorldSpace = true,
        Position = position,
        MaxParticles = 100,
        Lifetime = 60,
        ParticleRate = 5,
        StartColor = KColor.White,
        ColorOverLifetime = {
            Enabled = false,
            Mode = "Gradient",
            Gradient = PaletteGradient:New(),
            GradientMin = PaletteGradient:New(),
            GradientMax = PaletteGradient:New()
        },
        VelocityOverLifetime = {
            Enabled = false,
            Space = "Local",
            LinearVelocity = {
                X = 0,
                Y = 0,
                Z = 0,
            },
            OrbitalVelocity = {
                X = 0,
                Y = 0,
                Z = 0,
            },
            OrbitalOffset = {
                X = 0,
                Y = 0,
                Z = 0,
            },
            Radial = 0,
            SpeedModifier = 1,
        },
        Orientation = 0,
        StartSpeed = 2,
        StartDirection = {X = 0, Y = -1, Z = 0},
        StartSize = Vector.One,
        StartRotation = 0,
        PersistAcrossRooms = false,

        _IsDestroyed = false,
        _EmissionAccumulator = 0,
        _IsEmitting = true,
        _Particles = {},
        _ParticlePool = {},
        _RenderImage = image,
        _EmitterSourceQuad = sourceQuad,
        _DestroyFun = unregisterEmitter,
    }

    local ParticleEmitterMT = setmetatable(ParticleEmitterInstance, ParticleEmitter)

    ---@cast ParticleEmitterMT ParticleEmitter
    table.insert(emitters, ParticleEmitterMT)

    return ParticleEmitterMT
end

return Palette