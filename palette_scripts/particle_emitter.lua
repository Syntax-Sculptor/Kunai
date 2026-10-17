local GAME_FRAMES_PER_SECOND = 30

local PaletteUtils = include("palette_scripts.palette_utils")
local PaletteGradient = include("palette_scripts.palette_gradient")
local Vector3 = include("palette_scripts.vector3")

---@class ParticleEmitter This class defines a `ParticleEmitter`, which is responsible for creating particles and managing them.
---@field IsWorldSpace boolean Whether the emitted particles are rendered on the world space or directly onto your screen. Default: True
---@field Position Vector | Vector3 The position of the emitter. This is where all spawned particles originate from. Default: (0, 0, 0)
---@field MaxParticles integer The maximum amount of particles that can be active at a given time. Default: 100
---@field Lifetime PaletteMinMaxFloat | number How many frames a particle exists until it's destroyed. Default: 60
---@field ParticleRate number How many particles are emitted over the course of one second. Default: 5
---@field ColorOverLifetime PaletteColorOverLifetime Attributes relating to how the particles change color over its lifespan.
---@field StartColor PaletteMinMaxKColor | KColor The initial color for spawned particles. If `ColorOverLifetime.Enabled` is set to `true`, the gradient is multiplied by this.
---@field VelocityOverLifetime PaletteVelocityOverLifetime Dictates how particles move over its lifespan.
---@field StartSpeed PaletteMinMaxFloat | number The initial speed of the particle when spawned. Default: 2
---@field StartDirection Vector | Vector3 The default direction of the particle. Default: (0, -1, 0)
---@field StartRotation number | PaletteMinMaxFloat The initial rotation for each particle. Default: 0
---@field Orientation number The emitter's rotation, in degrees. This is solely used to handle how particles move out from the emitter as opposed to changing the rotation of the particle's sprite. To change the sprite's actual rotation, use `StartRotation`. Default: 0
---@field StartSize Vector | PaletteMinMaxVector The initial scale of spawned particles. Default: (1, 1)
---@field PersistAcrossRooms boolean Whether the particle emitter is destroyed when leaving the current room or exiting the game. Default: false
---@field DirectionSpread number How spread out the spawned particles are relative to `StartDirection`. Default: 0
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
    if self:IsDestroyed() then
        return
    end

    self:_UpdateParticles()
    self:_UpdateContinuousEmission()
end

--- Spawns multiple particles in a single batches. If the number of particles exceeds or is equal to
--- `ParticlEmitter.MaxParticles`, extraneous particles are not spawned.
---@param count integer
function ParticleEmitter:Emit(count)
    assert(not self:IsDestroyed(), "Attempted to Emit particles on a destroyed ParticleEmitter")

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
    if self:IsDestroyed() then
        return
    end
    
    self._IsEmitting = true
end

--- Disables continuous particle emission. This does not clear particles that have already spawned.
--- If you wish to destroy already spawned particles, use `ParticleEmitter:Clear()`.
function ParticleEmitter:Stop()
    if self:IsDestroyed() then
        return
    end

    self._IsEmitting = false
end


--- Returns whether the ParticleEmitter was destroyed.
function ParticleEmitter:IsDestroyed()
    return self._IsDestroyed
end

--- Destroys all particles spawned by the emitter.
function ParticleEmitter:Clear()
    if self:IsDestroyed() then
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
    if self:IsDestroyed() then
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
    if self:IsDestroyed() then
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
        destinationQuad:Rotate(particle.Rotation, renderPos)
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
    if self:IsDestroyed() then
        return
    end

    for i = #self._Particles, 1, -1 do
        local particle = self._Particles[i]

        particle.FrameCount = particle.FrameCount + 1

        if particle.FrameCount >= particle.Lifetime then
            local removedParticle = table.remove(self._Particles, i)
            table.insert(self._ParticlePool, removedParticle)
        else
            local velocity = self:_GetParticleVelocity(particle)
            particle.Position = particle.Position + velocity

            self:_UpdateParticleColor(particle)
        end
    end
end


---@param particle Particle
function ParticleEmitter:_UpdateParticleColor(particle)
    if not self.ColorOverLifetime.Enabled or particle.Lifetime <= 0 then
        particle.Color = particle.StartColor
        return
    end
    
    local t = particle.FrameCount / particle.Lifetime

    if self.ColorOverLifetime.Mode == "Gradient" then
        local gradientColor = PaletteGradient:Evaluate(self.ColorOverLifetime.Gradient, t, self.ColorOverLifetime.Gradient.Mode)
        particle.Color = PaletteUtils:MultiplyKColor(particle.StartColor, gradientColor)
    elseif self.ColorOverLifetime.Mode == "TwoGradients" then
        local gradientColorMin = PaletteGradient:Evaluate(self.ColorOverLifetime.GradientMin, t, self.ColorOverLifetime.GradientMin.Mode)
        local gradientColorMax = PaletteGradient:Evaluate(self.ColorOverLifetime.GradientMax, t, self.ColorOverLifetime.GradientMax.Mode)
        local gradientColor = PaletteUtils:LerpKColor(gradientColorMin, gradientColorMax, particle.ColorLerpFactor)
        particle.Color = PaletteUtils:MultiplyKColor(particle.StartColor, gradientColor)
    end
end

---@param particle Particle
function ParticleEmitter:_InitializeParticle(particle)
    local direction = Vector3.fromVector(self.StartDirection)
    direction:Normalize():RotateZ(self.Orientation)
    
    particle.SpawnPosition = Vector3.fromVector(self.Position)
    particle.Position = particle.SpawnPosition:Copy()
    particle.Velocity = direction * PaletteUtils:SampleFloat(self.StartSpeed)
    particle.FrameCount = 0
    particle.Scale =  PaletteUtils:SampleVector(self.StartSize)
    particle.StartColor = PaletteUtils:SampleKColor(self.StartColor)
    particle.Color = PaletteUtils:SampleKColor(self.StartColor)
    particle.Lifetime = PaletteUtils:SampleFloat(self.Lifetime)
    particle.Rotation = PaletteUtils:SampleFloat(self.StartRotation)
    particle.ColorLerpFactor = PaletteUtils:GetRandom()

    -- To prevent brief visual artifacts like new particles flickering.
    self:_UpdateParticleColor(particle)
end

---@param particle Particle
function ParticleEmitter:_GetParticleVelocity(particle)
    local velocityOverLifetime = self.VelocityOverLifetime

    if not velocityOverLifetime.Enabled then
        return particle.Velocity
    end

    -- Linear Velocity Logic

    local linearVelocity = Vector3.fromVector(velocityOverLifetime.LinearVelocity)

    if velocityOverLifetime.Space == "Local" then
        linearVelocity:RotateZ(self.Orientation)
    end

    local newVelocity = (particle.Velocity + linearVelocity) * velocityOverLifetime.SpeedModifier

    -- Orbital Velocity Logic

    local orbitalOffset = Vector3.fromVector(velocityOverLifetime.OrbitalOffset)

    if velocityOverLifetime.Space == "Local" then
        orbitalOffset:RotateZ(self.Orientation)
    end

    local center = particle.SpawnPosition + orbitalOffset
    local relativePos = particle.Position - center

    if velocityOverLifetime.Space == "Local" then
        relativePos:RotateZ(-self.Orientation)
    end

    -- Orbital X: Rotate in the YZ plane.
    local orbitalX = velocityOverLifetime.OrbitalVelocity.X * velocityOverLifetime.SpeedModifier

    if orbitalX ~= 0 then
        relativePos:RotateX(orbitalX)
    end

    -- Orbital Y: Rotate in the XZ plane.
    local orbitalY = velocityOverLifetime.OrbitalVelocity.Y * velocityOverLifetime.SpeedModifier

    if orbitalY ~= 0 then
        relativePos:RotateY(orbitalY)
    end

    -- Orbital Z: Rotate in the XY plane.
    local orbitalZ = (velocityOverLifetime.OrbitalVelocity.Z or 0) * velocityOverLifetime.SpeedModifier

    if orbitalZ ~= 0 then
        relativePos:RotateZ(orbitalZ)
    end

    if velocityOverLifetime.Space == "Local" then
        relativePos:RotateZ(self.Orientation)
    end

    local orbitalVelocity = center + relativePos - particle.Position

    newVelocity = newVelocity + orbitalVelocity

    -- Radial Velocity Logic
    local radialDirection = particle.Position - center
    local length = radialDirection:Length()

    if length > 0 then
        local radialVelocity = radialDirection * (velocityOverLifetime.Radial * velocityOverLifetime.SpeedModifier / length)
        newVelocity = newVelocity + radialVelocity
    end

    return newVelocity
end

return ParticleEmitter
