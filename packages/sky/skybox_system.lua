local ecs = ...
local world = ecs.world

local renderpkg = import_package "ant.render"
local computil = renderpkg.components

local skybox_sys = ecs.system "skybox_system"

function skybox_sys:init()
    computil.create_skybox()
end