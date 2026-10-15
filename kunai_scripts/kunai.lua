local Kunai = {}
local ParticleEmitter = include("kunai_scripts.particle_emitter")
local KunaiGradient = include("kunai_scripts.kunai_gradient")
local KunaiUtils = include("kunai_scripts.kunai_utils")

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

--- Initializes Kunai using the provided `mod`. Errors if Kunai has already been registered.
---@param mod ModReference
function Kunai:Init(mod)
    assert(not initialized, "Kunai was already initialized!")
    
    initialized = true

    mod:AddCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, onPostRoomRenderEntities)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, onPostUpdate)
end

--- Creates a new `ParticleEmitter`.
---@param texturePath string The file path pointing to the texture used for the emitted particles. It must be a `.png` file with a bit-depth of 32. Invalid file paths will cause an error.
---@param position Vector | Vector3 | nil Optional. The starting position of the emitter. Default is (0, 0, 0)
---@return ParticleEmitter
function Kunai:CreateParticleEmitter(texturePath, position)
    assert(initialized, "Kunai must be initialized first before calling `CreateParticleEmitter`")

    if not position then
        position = {X = 0, Y = 0, Z = 0}
    elseif not position.Z then
        ---@cast position Vector
        position = KunaiUtils:VectorToVector3(position)
    else
        position = KunaiUtils:CopyVector3(position)
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
        ParticleRate = 0,
        StartColor = KColor.White,
        ColorOverLifetime = {
            Enabled = false,
            Mode = "Gradient",
            Gradient = KunaiGradient:New(),
            GradientMin = KunaiGradient:New(),
            GradientMax = KunaiGradient:New()
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

return Kunai