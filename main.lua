-- NOTE: THIS MAIN.LUA FILE IS TEMPORARY.
-- IT WILL BE STRIPPED OUT FROM THE REPOSITORY SOON.

local TestMod = RegisterMod("Palette Test Mod", 1)
local Palette = include("palette_scripts.palette")
Palette:Init(TestMod)
