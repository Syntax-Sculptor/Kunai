local GAME_FRAMES_PER_SECOND = 30

local KunaiUtils = include("kunai_scripts.kunai_utils")

---@class ParticleEmitter This class defines a `ParticleEmitter`, which is responsible for creating particles and managing them.
---@field IsWorldSpace boolean Whether the emitted particles are rendered on the world space or directly onto your screen. Default: True
---@field Position Vector3 The position of the emitter. This is where all spawned particles originate from. Default: (0, 0, 0).
---@field MaxParticles integer The maximum amount of particles that can be active at a given time. Default: 100
---@field Lifetime integer How many frames a particle exists until it's destroyed.
---@field ParticleRate number How many particles are emitted over the course of one second.
---@field private _IsEmitting boolean Determines whether particles are being continuously emitted. Note that `ParticleEmitter:Emit` will still work even with this set to false.
---@field private _RenderImage Image
---@field private _Particles Particle[]
---@field private _ParticlePool Particle[]
---@field private _EmitterSourceQuad SourceQuad
---@field private _EmissionAccumulator number
---@field private _IsDestroyed boolean
---@field private _DestroyFun fun(self: ParticleEmitter)
local ParticleEmitter = {}
ParticleEmitter.__index = ParticleEmitter

--- Updates the ParticleEmitter's logic including its current particles. By default, this is called
--- every frame using `MC_POST_UPDATE`. While there's typically no need to call this method as
--- it's done automatically, it may be useful for forcing updates.
function ParticleEmitter:Update()
    if self._IsDestroyed then
        return
    end

    self:_UpdateParticles()
    self:_UpdateContinuousEmission()
end

--- Spawns multiple particles in a single batches. If the number of particles exceeds or is equal to
--- `ParticlEmitter.MaxParticles`, extraneous particles are not spawned.
---@param count integer
function ParticleEmitter:Emit(count)
    assert(self._IsDestroyed, "Attempted to Emit particles on a destroyed ParticleEmitter")

    for i = 1, count do
        if #self._Particles >= self.MaxParticles then
            break
        end

        -- Our Object Pool logic here will reduce the amount of times we need to allocate an entire
        -- table to save performance.
        local newParticle

        if #self._ParticlePool > 0 then
            newParticle = table.remove(self._ParticlePool)
        else
            newParticle = {}
        end
        
        self:_InitializeParticle(newParticle)

        ---@cast newParticle Particle
        table.insert(self._Particles, newParticle)
    end
end

--- Returns whether continuous particle emission is enabled.
function ParticleEmitter:IsEmitting()
    return self._IsEmitting
end

--- Returns whether at least one particle from the emitter is active or the emitter is continuously
--- emitting particles.
function ParticleEmitter:IsPlaying()
    return self._IsEmitting or #self._Particles > 0
end

--- Enables continuous particle emission.
function ParticleEmitter:Play()
    if self._IsDestroyed then
        return
    end
    
    self._IsEmitting = true
end

--- Disables continuous particle emission. This does not clear particles that have already spawned.
--- If you wish to destroy already spawned particles, use `ParticleEmitter:Clear()`.
function ParticleEmitter:Stop()
    if self._IsDestroyed then
        return
    end

    self._IsEmitting = false
end

--- Destroys all particles spawned by the emitter.
function ParticleEmitter:Clear()
    if self._IsDestroyed then
        return
    end

    for _, particle in pairs(self._Particles) do
        table.insert(self._ParticlePool, particle)
    end

    self._Particles = {}
end

--- Destroys the ParticleEmitter and all of the particles it has spawned. When destroyed, it can no
--- longer be used.
function ParticleEmitter:Destroy()
    if self._IsDestroyed then
        return
    end

    self:Clear()
    self:_DestroyFun()

    self._ParticlePool = {}
    self._Particles = {}
    self._IsEmitting = false
    self._IsDestroyed = true
    self._RenderImage = nil
    self._EmitterSourceQuad = nil
    self._DestroyFun = nil
end

function ParticleEmitter:_Render()
    if self._IsDestroyed then
        return
    end

    local imageWidth, imageHeight = self._RenderImage:GetWidth(), self._RenderImage:GetHeight()

    for _, particle in ipairs(self._Particles) do
        ---@type Vector
        local renderPos
        local pos2D = Vector(particle.Position.X, particle.Position.Y)

        if self.IsWorldSpace then
            local worldScreenPos = Isaac.WorldToScreen(pos2D)
            -- Applying Z projection here. Might be useful later to give the illusion of 3D
            -- particles.
            renderPos = Vector(worldScreenPos.X, worldScreenPos.Y - particle.Position.Z)
        else
            renderPos = pos2D
        end

        local scaledWidth, scaledHeight =
            imageWidth * particle.Scale.X, imageHeight * particle.Scale.Y

        local destinationQuad = DestinationQuad.NewFromRectangle(
            renderPos - Vector(scaledWidth / 2, scaledHeight / 2),
            scaledWidth,
            scaledHeight
        )
        self._RenderImage:Render(self._EmitterSourceQuad, destinationQuad, particle.Color)
    end
end

function ParticleEmitter:_UpdateContinuousEmission()
    if not self._IsEmitting then
        return
    end

    self._EmissionAccumulator = self._EmissionAccumulator + self.ParticleRate / GAME_FRAMES_PER_SECOND

    local particlesToEmit = math.floor(self._EmissionAccumulator)

    if particlesToEmit > 0 then
        self:Emit(particlesToEmit)
    end

    self._EmissionAccumulator = self._EmissionAccumulator - particlesToEmit
end

function ParticleEmitter:_UpdateParticles()
    if self._IsDestroyed then
        return
    end

    for i = #self._Particles, 1, -1 do
        local particle = self._Particles[i]

        particle.Position = KunaiUtils:AddVector3(particle.Position, particle.Velocity)
        particle.FrameCount = particle.FrameCount + 1

        if particle.FrameCount >= particle.Lifetime then
            local removedParticle = table.remove(self._Particles, i)
            table.insert(self._ParticlePool, removedParticle)
        end
    end
end

---@param particle Particle
function ParticleEmitter:_InitializeParticle(particle)
    particle.Position = KunaiUtils:CopyVector3(self.Position)
    particle.Velocity = { X = 0, Y = 0, Z = 0 }
    particle.FrameCount = 0
    particle.Scale = Vector.One
    particle.Color = KColor.White
    particle.Lifetime = self.Lifetime
    particle.Rotation = 0
end

return ParticleEmitter
