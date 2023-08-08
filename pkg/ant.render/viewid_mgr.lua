local viewid_pool = {}

local max_viewid<const>					= 256
local bindings = {}
local viewid_names = {}

local remapping_id_list = {}

--viewid is base 0
local function add_view(name, afterview_idx)
	local id = #remapping_id_list
	if id >= max_viewid then
		error(("not enough view id, max viewid: %d"):format(max_viewid))
	end

	local real_id = (afterview_idx and afterview_idx+1 or id)

	bindings[name] = id
	viewid_names[id] = name
	
	assert(#remapping_id_list == id)
	table.insert(remapping_id_list, real_id+1, id)
	return id
end

add_view "csm_fb"		-- 0
add_view "skinning"
add_view "csm1"
add_view "csm2"
add_view "csm3"
add_view "csm4"			-- 5
--TODO: vblur and hblur can use only 1 viewid
add_view "vblur"
add_view "hblur"
-- NOTE: omni shadowmap is not use right now
-- add_view "omni_Green"
-- add_view "omni_Yellow"
-- add_view "omni_Blue"
-- add_view "omni_Red"
add_view "panorama2cubmap"
add_view "panorama2cubmapMips"
add_view "ibl"					--10
add_view "ibl_SH_readback"
add_view "pre_depth"
add_view "scene_depth"
add_view "depth_resolve"
add_view "depth_mipmap"			--15
add_view "ssao"
add_view "main_view"
add_view "outline"
add_view "velocity"
--start postprocess
add_view "postprocess_obj"
--add_view "bloom"
add_view "bloom_ds1"
add_view "bloom_ds2"
add_view "bloom_ds3"
add_view "bloom_ds4"
add_view "bloom_us1"
add_view "bloom_us2"
add_view "bloom_us3"
add_view "bloom_us4"
add_view "effect_view"			--20
add_view "tonemapping"
add_view "taa"
add_view "taa_copy"
add_view "taa_present"
add_view "fxaa"
--end postprocess

add_view "lightmap_storage"
add_view "pickup"
add_view "pickup_blit"			--25
add_view "uiruntime"

local remapping_need_update = true

function viewid_pool.generate(name, afterwho, count)
	assert(nil == viewid_pool.get(name), ("%s already defined"):format(name))

	count = count or 1
	local viewid = add_view(name, viewid_pool.get(afterwho))
	for i=2, count do
		add_view(name, viewid)
	end

	remapping_need_update = true
	return viewid
end

function viewid_pool.all_bindings()
	return bindings
end

function viewid_pool.clear_remapping()
	remapping_need_update = false
end

function viewid_pool.need_update_remapping()
	return remapping_need_update
end

function viewid_pool.remapping()
	return remapping_id_list
end

function viewid_pool.get(name)
	return bindings[name]
end

function viewid_pool.viewname(viewid)
	return viewid_names[viewid]	--viewid base 0
end

--test
-- print "all viewid:"

-- local function print_viewids()
-- 	local viewids = {}
-- 	for viewid in pairs(viewid_names) do
-- 		viewids[#viewids+1] = viewid
-- 	end

-- 	table.sort(viewids)

-- 	for _, viewid in ipairs(viewids) do
-- 		local viewname = viewid_names[viewid]
-- 		print("viewname:", viewname, "viewid:", viewid, "binding:", bindings[viewname])
-- 	end
-- end

-- print_viewids()

-- viewid_pool.generate("main_view1", "main_view")

-- print "============================="

-- print_viewids()


-- local function print_rempping()
-- 	for idx, mviewid in ipairs(remapping_id_list) do
-- 		local viewid = idx-1
-- 		local viewname = viewid_names[mviewid]
-- 		print("viewname:", viewname, "viewid:", viewid, "mapping_viewid:", mviewid)
-- 	end
-- end

-- if viewid_pool.need_update_remapping() then
-- 	print "============================="
-- 	print_rempping()
-- 	viewid_pool.clear_remapping()
-- end

-- print "============================="
-- print("main_view:", viewid_pool.get "main_view", "main_view1:", viewid_pool.get "main_view1", "remapping main_view1:", remapping_id_list[viewid_pool.get "main_view1"])

-- if viewid_pool.get(viewid_names[#viewid_names]) >= viewid_pool.get "main_view1" then
-- 	error "Invalid in generate viewid"
-- end

return viewid_pool