---@meta

-- This file only defines the classes for Lua LSP to detect and load. There is no need to call
-- `include`/`require` on this file; it should be detected on its own.

---@class Vector3 An alternative to `Vector` which supports representing particles in a 3D space. It currently doesn't support operator overloading unlike the normal `Vector` class. For performance reasons, this is not a metatable.
---@field X number
---@field Y number
---@field Z number

---@class Particle This class defines a singular particle instance emitted from a ParticleEmitter.
---@field Position Vector3
---@field Velocity Vector3
---@field FrameCount integer How many update frames the particle has elapsed.
---@field Lifetime integer How many update frames until the particle is removed.
---@field Scale Vector The particle's scale multiplier. Setting it to `Vector(1, 1)` will use the sprite's original dimensions.
---@field Rotation number
---@field Color KColor
---@field StartColor KColor
---@field ColorLerpFactor number
---@field SpawnPosition Vector3

---@alias GradientMode "Blend"|"Fixed"
---@alias ColorOverLifetimeMode "Gradient"|"TwoGradients"

---@class KunaiGradient
---@field ColorKeys KunaiGradientKey[]
---@field AlphaKeys KunaiAlphaKey[]
---@field Mode GradientMode

---@class KunaiColorOverLifetime
---@field Enabled boolean
---@field Mode ColorOverLifetimeMode
---@field Gradient KunaiGradient
---@field GradientMin KunaiGradient
---@field GradientMax KunaiGradient

---@class KunaiVelocityOverLifetime
---@field Enabled boolean
---@field Space "Local"|"World"
---@field LinearVelocity Vector3
---@field OrbitalVelocity Vector3
---@field OrbitalOffset Vector3
---@field Radial number
---@field SpeedModifier number