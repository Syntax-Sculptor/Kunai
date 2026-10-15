WARNING: Palette is currently under active development. Its API is subject to change and is not ready for production use.

# Palette

**Palette** is a work-in-progress 2.5D particle engine library for The Binding of Isaac: Repentance+ built using the [REPENTOGON](https://repentogon.com/) script extender. Its features are directly modeled after Unity's [Shuriken Particle System](https://docs.unity3d.com/2022.3/Documentation/Manual/ParticleSystemModules.html)

Historically, Isaac's modding API has been extremely limited when it comes to particle effects. Traditionally, the primary function pertaining to particle effects provided is `Game:SpawnParticles`, which is used for various effects such as the gibs spawned when killing a monster. However, it provides very little customization.

Palette aims to fill in the gap by allowing modders to easily create and customize particle effects to create stunning visual effects with very little Lua involved. On top of that, it leverages several low-level rendering features that REPENTOGON exposes with performance in mind.

## Getting Started

TODO

## Planned Features / Roadmap

TODO

## Contribution Policy

Palette is currently in very early development. However, anyone is welcome to jump aboard and contribute! Before getting started, please follow these guidelines:

- Please open a GitHub Issue to discuss major features or architectural changes before implementation.
    - Generally speaking, this should be done for any major new features so you don't waste your time implementing a new feature that doesn't align with the library's vision.

- If any AI tools were used (Claude, Codex, etc.), please disclose its usage in the Pull Request.
    - Blatantly vibecoded Pull Requests that have not been reviewed, tested, or understood by the contributor will be closed.

A formal contribution guidelines page will be written very soon.
