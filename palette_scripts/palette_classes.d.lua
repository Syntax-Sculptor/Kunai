---@meta

-- This file only defines the classes for Lua LSP to detect and load. There is no need to call
-- `include`/`require` on this file; it should be detected on its own.

---@class Particle This class defines a singular particle instance emitted from a ParticleEmitter.
---@field Position Vector3
---@field Velocity Vector3
---@field FrameCount integer How many update frames the particle has elapsed.
---@field Lifetime integer How many update frames until the particle is removed.
---@field Scale Vector The particle's scale multiplier. Setting it to `Vector(1, 1)` will use the sprite's original dimensions.
---@field Rotation number
---@field Color KColor
---@field StartColor KColor
---@field LerpFactor number
---@field SpawnPosition Vector3

---@alias GradientMode "Blend"|"Fixed"
---@alias ColorOverLifetimeMode "Gradient"|"TwoGradients"
---@alias CurveMode "Single"|"TwoCurves"

---@class PaletteGradient
---@field ColorKeys PaletteGradientKey[]
---@field AlphaKeys PaletteAlphaKey[]
---@field Mode GradientMode

---@class PaletteColorOverLifetime
---@field Enabled boolean
---@field Mode ColorOverLifetimeMode
---@field Gradient PaletteGradient
---@field GradientMin PaletteGradient
---@field GradientMax PaletteGradient

---@class PaletteVelocityOverLifetime
---@field Enabled boolean
---@field Space "Local"|"World"
---@field LinearVelocity Vector | Vector3
---@field OrbitalVelocity Vector | Vector3
---@field OrbitalOffset Vector | Vector3
---@field Radial number
---@field SpeedModifier number

---@class PaletteMinMaxFloat
---@field Min number
---@field Max number

---@class PaletteMinMaxInteger
---@field Min integer
---@field Max integer

---@class PaletteMinMaxVector
---@field Min Vector
---@field Max Vector

---@class PaletteMinMaxKColor
---@field Min KColor
---@field Max KColor

---@class Keyframe<T>
---@field Time number
---@field Value T

---@class KeyframeSegment<T>
---@field Left T
---@field Right T
---@field Alpha number

---@class SizeOverLifetime
---@field Enabled boolean
---@field Mode GradientMode
---@field Keys Keyframe<Vector>[]
---@field KeysMax Keyframe<Vector>[]
---@field KeysMin Keyframe<Vector>[]
---@field CurveMode CurveMode

---@class RotationOverLifetime
---@field Enabled boolean
---@field Mode GradientMode
---@field Keys KeyframeSegment<number>[]