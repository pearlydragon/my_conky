require 'cairo'

function conky_startup()
	start_path = "";
end


function noclip_draw_image (ir,xc, yc, radius, path) 
	local w, h;
	
	cairo_set_source_rgba(ir,1,1,1,1);

	cairo_arc (ir, xc, yc, radius, 0, 2*math.pi);
	-- cairo_clip (ir);
	cairo_new_path (ir); 


	local image = cairo_image_surface_create_from_png (path);
	w = cairo_image_surface_get_width (image);
	h = cairo_image_surface_get_height (image);


	cairo_scale (ir, 2*radius/w, 2*radius/h);
	w = cairo_image_surface_get_width (image);
	h = cairo_image_surface_get_height (image);

	cairo_set_source_surface (ir, image, xc*(1/(2*radius/w)) - w/2, yc*(1/(2*radius/h)) - h/2);
	cairo_paint (ir);

	cairo_surface_destroy (image);
	cairo_destroy(ir);
end

function draw_image (ir,xc, yc, radius, path) 
	local w, h;
	
	cairo_set_source_rgba(ir,1,1,1,1);

	cairo_arc (ir, xc, yc, radius, 0, 2*math.pi);
	cairo_clip (ir);
	cairo_new_path (ir); 


	local image = cairo_image_surface_create_from_png (path);
	w = cairo_image_surface_get_width (image);
	h = cairo_image_surface_get_height (image);


	cairo_scale (ir, 2*radius/w, 2*radius/h);
	w = cairo_image_surface_get_width (image);
	h = cairo_image_surface_get_height (image);

	cairo_set_source_surface (ir, image, xc*(1/(2*radius/w)) - w/2, yc*(1/(2*radius/h)) - h/2);
	cairo_paint (ir);

	cairo_surface_destroy (image);
	cairo_destroy(ir);
end

function draw_waves(xc,yc,base_radius,num) 
	cairo_set_line_width(cr,1);
	for i = 1,num do
		cairo_arc(cr,xc,yc,base_radius+i*3,-(math.pi/180)*(90 - i*7.5),(math.pi/180)*(60-i*7.5));
		cairo_stroke(cr);
		cairo_arc_negative(cr,xc,yc,base_radius+i*3,-(math.pi/180)*(120+i*7.5),(math.pi/180)*(-270+i*7.5));
		cairo_stroke(cr);
	end
	cairo_stroke(cr);
end

function conky_main() 

	-- check for conky window
	if conky_window == nil then
		return;
	end

	-- prepare drawing surface
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height);
	cr = cairo_create(cs);
	
	local imagex = 1150;
	local imagey = 70;
	local image_radius = 60;
	local image_path = "face";
	local text = "";
	local extents = cairo_text_extents_t:create();

	local updates = conky_parse("${updates}");

	-- time and date
	
	cairo_set_source_rgba(cr,1,1,1,0.08);
	cairo_move_to (cr, 0, 200);
	cairo_curve_to (cr, 300, 200, 500, 350, 470, 0);
	cairo_rel_line_to(cr,-470,0);
	cairo_rel_line_to(cr,0,200);
	cairo_fill_preserve(cr);

	local hour = conky_parse('${time %_H}');
	local minute = conky_parse('${time %M}');
	local part = conky_parse('${time %P}');
	local day = conky_parse('${time %d}');
	local month = conky_parse('${time %B}');
	local year = conky_parse('${time %G}');

	cairo_set_source_rgba(cr,1,1,1,1);
	local left={"1","2","3","4","5","6","7","8","9","0"};
	local right={"1","2","3","4","5","6","7","8","9","0"};
	cairo_set_source_rgba(cr,0.9,0.9,0.9,1);
	cairo_set_font_size(cr,130);
	cairo_select_font_face(cr,"CombiNumerals Ltd",0,0);
	local hl = hour/10 - (hour/10)%1;
	if hl == 0 then
		hl = 10;
	end
	local ml = minute/10 - (minute/10)%1;
	if ml == 0 then
		ml = 10;
	end
	local hr = hour%10;
	if hr == 0 then
		hr = 10;
	end
	local mr = minute%10;
	if mr == 0 then
		mr = 10;
	end
	text = left[hl]..right[hr]..":"..left[ml]..right[mr];
	cairo_text_extents(cr,text,extents);
	cairo_move_to(cr,60,120);
	cairo_show_text(cr,text);
	cairo_select_font_face(cr,"Arial",0,0);
	cairo_move_to(cr,extents.width+45,110);
	--cairo_show_text(cr,part);

	cairo_set_source_rgba(cr,0.5,0.7,1,1);
	cairo_set_source_rgba(cr,0.9,0.9,0.9,1);
	cairo_set_font_size (cr, 40);
	cairo_select_font_face (cr, "Royal Acidbath",CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
	text = day.." "..month..", "..year;
	cairo_text_extents(cr,text,extents);
	cairo_move_to(cr,230 - extents.width/2,180);
	cairo_show_text(cr,text);

	cairo_stroke(cr);

	-- freeing surface pointers
	cairo_destroy(cr);
	cairo_surface_destroy(cs);
	cr=nil;
end
