local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local mc = import_package "ant.math".constant
local setting = import_package "ant.settings".setting
local components = import_package "ant.ecs".components
local disable_cull = setting:data().graphic.disable_cull

local cullcore = require "cull.core"

local icp = ecs.interface "icull_primitive"

local function cull(cull_tags, vp_mat)
	local frustum_planes = math3d.frustum_planes(vp_mat)
	for vv in w:select "view_visible render_object scene:in" do
		local aabb = vv.scene.scene_aabb
		if aabb ~= mc.NULL then
			local culled = math3d.frustum_intersect_aabb(frustum_planes, aabb) < 0
			for i=1, #cull_tags do
				local ct = cull_tags[i]
				vv[ct] = culled
				w:sync(ct .. "?out", vv)
			end
		end
	end
end

icp.cull = cull

local cull_sys = ecs.system "cull_system"

local queue_tags = {}
local function add_queue_tags(ceid, culltags)
	local tags = queue_tags[ceid]
	if tags == nil then
		tags = {}
		queue_tags[ceid] = tags
		table.move(culltags, 1, #culltags, 1, tags)
	else
		for i=1, #culltags do
			local ct = culltags[i]
			if tags[ct] == nil then
				tags[ct] = true
				tags[#tags+1] = ct
			end
		end
	end
end

local function remove_queue_tags(ceid, culltags)
	local tags = queue_tags[ceid]
	if tags then
		for i=1, #culltags do
			table.remove(tags, culltags[i])
		end
	end
end

local qv_mb = world:sub{"queue_visible_changed"}
local camera_changed_mbs = {}

local queue_cameras = {}
function cull_sys:component_init()
	-- for q in w:select "INIT visible queue_name:in cull_tag:in camera_ref:in" do
	-- 	local qn = q.queue_name
	-- 	local ceid = q.camera_ref
	-- 	add_queue_tags(ceid, q.cull_tag)
	-- 	queue_cameras[qn] = ceid
	-- 	camera_changed_mbs[#camera_changed_mbs+1] = world:sub{qn, "camera_changed"}
	-- end
end

function cull_sys:data_changed()
	-- for i=1, #camera_changed_mbs do
	-- 	for qn, _, ceid in camera_changed_mbs[i]:unpack() do
	-- 		local old_ceid = queue_cameras[qn]
	-- 		assert(ceid ~= old_ceid)
	-- 		local q = w:singleton(qn, "cull_tag:in camera_ref:in")
	-- 		if old_ceid then
	-- 			remove_queue_tags(old_ceid, q.cull_tag)
	-- 		end
	-- 		queue_cameras[qn] = nil

	-- 		add_queue_tags(ceid, q.cull_tag)
	-- 	end
	-- end

	-- for _, qn, visible in qv_mb:unpack() do
	-- 	local q = w:singleton(qn, "camera_ref:in cull_tag:in")
	-- 	if visible then
	-- 		add_queue_tags(q.camera_ref, q.cull_tag)
	-- 	else
	-- 		remove_queue_tags(q.camera_ref, q.cull_tag)
	-- 	end
	-- end
end

function cull_sys:entity_ready()
	
end

local function find_queue_tags()
	local cull_tags = {}
	for qe in w:select "visible queue_name:in camera_ref:in" do
		local cref = qe.camera_ref
		local tags = cull_tags[cref]
		if tags == nil then
			tags = {}
			cull_tags[cref] = tags
		end
		tags[#tags+1] = qe.queue_name .. "_cull"
	end
	return cull_tags
end

local tag_ids = {}
for idx, cc in ipairs(components) do
	tag_ids[cc] = idx
end
local function build_tags(tags)
	local t = {}
	for i=1, #tags do
		t[i] = assert(tag_ids[tags[i]])
	end
	return t
end

function cull_sys:cull()
	if disable_cull then
		return
	end

	for ceid, tags in pairs(find_queue_tags()) do
		local camera = world:entity(ceid).camera
		--cull(tags, camera.viewprojmat)
		cullcore.cull(world._ecs_world, build_tags(tags), camera.viewprojmat)
	end
end
