dofile "libs/init.lua"

local bgfx = require "bgfx"
local rhwi = require "render.hardware_interface"
local sm = require "render.resources.shader_mgr"
local task = require "editor.task"
local nk = require "bgfx.nuklear"
local inputmgr = require "inputmgr"
local mapiup = require "inputmgr.mapiup"
local nkmsg = require "inputmgr.nuklear"

local loadfile = require "tested.loadfile"
local ch_charset = require "tested.charset_chinese_range"

local label = require "tested.ui.label"
local button = require "tested.ui.button"
local widget = require "tested.ui.widget"
local image = require "tested.ui.image"
local edit = require "tested.ui.edit"
local progress = require "tested.ui.progress"
local slider = require "tested.ui.slider"
local checkbox = require "tested.ui.checkbox"
local combobox = require "tested.ui.combobox"
local radio = require "tested.ui.radio"
local property = require "tested.ui.property"
local colorStyle = require "tested.ui.styleColors"
local skinStyle = require "tested.ui.styleSkin"
local area = require "tested.ui.areaWindow"
local ir_btn = require "tested.ui.buttonIrregular"


local canvas = iup.canvas {}

local miandlg = iup.dialog {
	canvas,
	title = "simpleui",
	size = "HALFxHALF",
}

local input_queue = inputmgr.queue(mapiup, canvas)

local UI_VIEW = 0


local nkatlas = {}
local nkbtn = {}
local nkimage = {} 
local nkb_images = { button = {} }
local ir_images = { button = {} }

local function save_ppm(filename, data, width, height, pitch)
	local f = assert(io.open(filename, "wb"))
	f:write(string.format("P3\n%d %d\n255\n",width, height))
	local line = 0
	for i = 0, height-1 do
		for j = 0, width-1 do
			local r,g,b,a = string.unpack("BBBB",data,i*pitch+j*4+1)
			f:write(r," ",g," ",b," ")
			line = line + 1
			if line > 8 then
				f:write "\n"
				line = 0
			end
		end
	end
	f:close()
end


function save_screenshot(filename)
	local name , width, height, pitch, data = bgfx.get_screenshot()
	if name then
		local size = #data
		if size < width * height * 4 then
			-- not RGBA
			return
		end
		print("Save screenshot to ", filename)
		save_ppm(filename, data, width, height, pitch)
	end
end



local ctx = {}
local message = {}

local btn_func = {
	LABEL = 1, BUTTON = 2, IMAGE = 3, WIDGET = 4 ,EDIT = 5,
	PROGRESS = 6, SLIDER = 7, CHECKBOX = 8, COMBOBOX = 9,
	PROPERTY = 10, RADIO =11, SKIN = 12, AREA = 13,IRREGULAR=14
}

 
local btn_ac = 0
local function mainloop()
	save_screenshot "screenshot.ppm"
	for _, msg,x,y,z,w,u in pairs(input_queue) do
		nkmsg.push(message, msg, x,y,z,w,u)
	end
	nk.input(message)

    nk.setFont(1)
	if nk.windowBegin( "Test","Test Window 汉字 ui 特性展示", 0, 0, 720, 460,
					   "border", "movable", "title", "scalable",'scrollbar') then 

		nk.layoutRow('static',30,{120,120,32,140,120,140} ) -- layout row 1
		nk.setFont(2)
		if nk.button("label","triangle left") then
			btn_ac  = btn_func.LABEL 
		end 
		if nk.button( "button","triangle right" ) then
			btn_ac = btn_func.BUTTON 
		end 
		--image 
		if nk.button(nil, nk.subImage(nkbtn,0,0,69,52)   ) then 
			btn_ac = btn_func.IMAGE 
		end 
		if nk.button( "widget") then 
			btn_ac = btn_func.WIDGET			
		end 
		if nk.button("edit",nk.subImageId(nkbtn.handle,nkbtn.w,nkbtn.h,0,0,69,52)) then
			btn_ac = btn_func.EDIT 
		end 
		if nk.button("progress","rect solid") then
			btn_ac = btn_func.PROGRESS
		end 
		 
		nk.layoutRow('static',30,{120,120,32,140,140,120} )  -- layout row 2
		if nk.button("slider","rect solid") then
			btn_ac = btn_func.SLIDER
		end 
		if nk.button("radio","circle solid") then
			btn_ac = btn_func.RADIO 
		end 
		if nk.button("o","circle outline") then
			nk.defaultStyle()
		end 
		if nk.button("checkbox","rect outline") then
			btn_ac = btn_func.CHECKBOX 
		end 
		if nk.button("combobox","triangle down") then
			btn_ac = btn_func.COMBOBOX
		end 
		if nk.button("property","plus") then 
			btn_ac = btn_func.PROPERTY 
		end 
		
		nk.layoutRow("dynamic",32,{0.05,0.05,0.05,0.05,0.05,0.2,0.2,0.05})
		if nk.button(nil,"#ff0000") then
			nk.themeStyle("theme red")
		end 
		if nk.button(nil,"#00ff00") then
			colorStyle()
		end 
		if nk.button(nil,"#0000ff") then
			nk.themeStyle("theme blue")
		end 
		if nk.button(nil,"#ffffff") then
			nk.themeStyle("theme white")
		end 
		if nk.button(nil,"#1d1d1d") then
			nk.themeStyle("theme dark")
		end 

		if nk.button("skinning","plus") then 
			btn_ac = btn_func.SKIN
		end 
		if nk.button("area","plus") then 
			btn_ac = btn_func.AREA
		end 
		if nk.button("irregular") then
			btn_ac = btn_func.IRREGULAR
		end 
		
		--nk.layoutRow('dynamic',30,{1/6,1/6,1/6,1/6,1/6,1/6} )
		--nk.layoutRow("dynamic",30,1)

		-- print("---id("..nkimage.handle..")"..' w'..nkimage.w..' h'..nkimage.h)
		-- do action 
		if btn_ac == btn_func.LABEL  then 
			label() 
		elseif btn_ac == btn_func.BUTTON then
			button( nkbtn )
		elseif btn_ac == btn_func.IMAGE then 
			image( nkimage )
		elseif btn_ac == btn_func.WIDGET then
			widget( nkbtn )
		elseif btn_ac == btn_func.EDIT then
			edit()
		elseif btn_ac == btn_func.PROGRESS then
			progress()
		elseif btn_ac == btn_func.SLIDER then
			slider()
		elseif btn_ac == btn_func.CHECKBOX then
			checkbox()
		elseif btn_ac == btn_func.COMBOBOX then
			combobox()
		elseif btn_ac == btn_func.RADIO then
			radio()
		elseif btn_ac == btn_func.PROPERTY then
			property()
		elseif btn_ac == btn_func.SKIN then
			skinStyle(nkb_images,nkatlas )
		elseif btn_ac == btn_func.AREA then
			area(nkbtn)
		elseif btn_ac == btn_func.IRREGULAR then
			ir_btn( ir_images )
		end 

	end 
	nk.windowEnd()
	nk.update()
	bgfx.frame()
end

function loadfonts(font,size,charset)
	print("charset length ="..#charset[2])
	return loadfile(font),size,charset
end 

--staging ,not finished
function loadatlas(texname,cfg)
	atlas.id = loadimage(texname)
	atlas.name = texname
	for _,v in pairs(cfg) do
		atlas[v] = { name,x,x,w,h }
	end 
end 
-- 从 nkimage 按 atlas 找到 subimage 
function subimage(name,nkimage,atlas)
	local si = atlas[ name ]
	print(si.id,si.w,si.h,si.x0,si.y0,si.x1,si.y1)
end 
--staging end 

function loadtexture(texname,info)
	--local f = assert(io.open(texname, "rb"))
	--local imgdata = f:read "a"
	--f:close()
	--local imgdata = loadfile(texname)
	--local h = bgfx.create_texture(imgdata, info)  -- 支持dds,pvr,? 三种格式
	--bgfx.set_name(h, texname)

	local image = nk.loadImage( texname );
	--bgfx.set_name(image.handle,texname)    -- TEXTURE<<16|image.handle 

	return image
end 

local function init(canvas, fbw, fbh)
	rhwi.init(iup.GetAttributeData(canvas,"HWND"), fbw, fbh)
    ---[[
	nk.init {
		view = UI_VIEW,
		width = fbw,
		height = fbh,
		decl = bgfx.vertex_decl {
			{ "POSITION", 2, "FLOAT" },
			{ "TEXCOORD0", 2, "FLOAT" },
			{ "COLOR0", 4, "UINT8", true },
		},
		texture = "s_texColor",
		state = bgfx.make_state {
			WRITE_MASK = "RGBA",
			BLEND = "ALPHA",
			--BLEND_FUNC ="1S"
			--BLEND_FUNC ="1A"
		},
		prog = sm.programLoad("ui/vs_nuklear_texture.sc","ui/fs_nuklear_texture.sc"),

		fonts = {
			{ "宋体行楷", loadfonts("fonts/stxingka.ttf",50, ch_charset()  ), },
			{ "微软雅黑", loadfonts("fonts/msyh.ttf",20, ch_charset() ), },
		},

	}
	--]]
	-- tested 	
	nkbtn = loadtexture( "assets/textures/button_active.png" )
	
	--nkb_images.n =
	nkb_images.button.n =  loadtexture("assets/textures/button.png")
	nkb_images.button.h =  loadtexture("assets/textures/button_hover.png")
	nkb_images.button.c =  loadtexture("assets/textures/button_active.png")
	--irregular button 
	ir_images.button.n = loadtexture("assets/textures/irbtn_normal.png")
	ir_images.button.h = loadtexture("assets/textures/irbtn_hover.png")
	ir_images.button.c = loadtexture("assets/textures/irbtn_active.png")

	-- image tools tested
	-- return image directly
	--nkatlas = loadtexture( "assets/textures/gwen.png") 
	-- return raw data
	local raw_data = nk.loadImageData("assets/textures/gwen.png"); 
	-- makeImage from memory
	nkatlas = nk.loadImageFromMemory(raw_data.data,raw_data.w,raw_data.h,raw_data.c)


	nkimage = nk.makeImage( nkatlas.handle,nkatlas.w,nkatlas.h)  -- make from outside id ,w,h 
	--nkim   = nk.makeImageMem( data,w,h)
	--print("---id("..nkimage.handle..")"..' w'..nkimage.w..' h'..nkimage.h)
	--nk.image( nkimage )  --test nested lua
	--nk.edit("editor",test)
	 
	bgfx.set_view_clear(UI_VIEW, "C", 0x303030ff, 1, 0)

	task.loop(mainloop)
end


function canvas:resize_cb(w,h)
	if init then
		init(self, w, h)
		init = nil
	else
		nk.resize(w,h)
	end
	bgfx.reset(w,h, "v")
	ctx.width = w
	ctx.height = h
end

function canvas:action(x,y)
	mainloop()
end

function canvas:keypress_cb(key, press)
	if key ==  iup.K_F1 and press == 1 then
		ctx.debug = not ctx.debug
		bgfx.set_debug( ctx.debug and "S" or "")
	end
	if key == iup.K_F12 and press == 1 then
		bgfx.request_screenshot()
	end
end


miandlg:showxy(iup.CENTER,iup.CENTER)
miandlg.usersize = nil

iup.MainLoop()
iup.Close()
