require 'cairo'

function conky_startup()
	noquote = 1;
	quotes = {};
	authors = {};
	no_of_quotes = 0;
	show_quote = 0;

	quotespace = 0;
	start = 1;
    internet = 1;
	io.close(file);
	changeweather = 0;
	noweather = 1;
	days = {};
	lows = {};
	highs = {};
	texts = {};
	city ="";
	region = "";
	country = "";
	condition = "";
	code = "";
	temp = "";
	weatherspace = 0;
	nonews = 1;
	news = {};
	change = 0;
	headline = {};
	no_of_news = 0;
	show_news = 0;
	which_sport = 1;
	start_path = "";
end

function print_weather()

	local min = tonumber(conky_parse('${time %M}'));
	local extents = cairo_text_extents_t:create();
	local city_id = "1502026";
	local apikkey = "e11c8c14cde6fd4a4b4b47651b3b6124";
	local weather = "";
    local file;
    print ("12345");
	if changeweather == 1 then
		if tonumber(hour)%12 == 0  then
			change = 0;
		end
	end

	if tonumber(min)%11 == 0 then
		change = 1;
	end

    noweather = 1;

	if noweather == 1 then
        
        file = io.popen("curl -m 120 'http://api.openweathermap.org/data/2.5/weather?id="..city_id.."&appid="..apikkey.."&units=metric'");
        weather = file:read("*a");
        io.close(file);
		if (weather == "") then
			noweather = 1;
		else
			noweather = 0;
			days = {};
			lows = {};
			highs = {};
			texts = {};
			city ="";
			region = "";
			country = "";
			condition = "";
			code = "";
			temp = "";

			local i = 0;
            condition,code,temp,country,city = string.match(weather, "\"description\":\"(.-)\".-\"icon\":\"(.-)\".-\"temp\":([+-]?%d+)\,.-\"country\":\"(%a+)\".-\"name\":\"(%a+)\"");
            file = io.popen("curl -m 120 'http://api.openweathermap.org/data/2.5/forecast/daily?id="..city_id.."&appid="..apikkey.."&units=metric&cnt=3'");
			weather = file:read("*a");
			io.close(file);
			for A,B,C,D in string.gmatch(weather, "\"dt\":(%d+)\,.-\"day\":(.-)\,.-\"night\":(.-)\,.-\"description\":\"(.-)\"") do
				i = i + 1;
				days[i] = A;
				lows[i] = B;
				highs[i] = C;
				texts[i] = D;
			end
		end
	end

	if noweather == 1 then
			local text = "Unable to download weather info !!!";
			cairo_set_font_size(cr,14);
			cairo_set_source_rgba(cr, 1, 1, 1, 1); -- black
			cairo_text_extents(cr,text,extents);
			cairo_move_to (cr,20,quotespace+30);
			cairo_show_text (cr, text);
			weatherspace = quotespace+50;

	else
        print ("defore all text");
		local text = city..", "..country;
		cairo_set_source_rgba(cr,1,1,1,0.3);
		cairo_set_font_size(cr,20);
		cairo_move_to(cr,20,quotespace+30);
		cairo_show_text(cr, text);
		cairo_stroke(cr);
        
        print (text);
        
		text = (temp+0.5-(temp+0.5)%1).."°C";
		cairo_set_source_rgba(cr,1,1,1,1);
		cairo_set_font_size(cr,80);
		cairo_select_font_face(cr,"Arial",0,0);
		cairo_text_extents(cr,text,extents);
		cairo_move_to(cr,110-extents.width/2,extents.height+quotespace+40);
		cairo_show_text(cr,text);
        
        print (text);

		text = condition;
		cairo_set_font_size(cr,14);
		cairo_set_source_rgba(cr,1,1,1,0.4);
		cairo_text_extents(cr,text,extents)
		cairo_move_to(cr,300-extents.width/2,extents.height+quotespace+100);
		cairo_show_text(cr,text);
        
        print (text);

		cairo_set_font_size(cr,15);
        os.setlocale('en_US')
		for i = 1,3 do
			text = os.date("%a", days[i]).." : "..lows[i].."°C / "..highs[i].."°C  "..texts[i];
			cairo_move_to(cr,20,extents.height+quotespace+100+i*17);
			cairo_show_text(cr,text);
		end

		weatherspace = quotespace+190;

	end

end


function print_quotes( )

	local min = tonumber(conky_parse('${time %M}'));
	local extents = cairo_text_extents_t:create();
	local output = "";

	if (noquote == 1) then

        local file = io.popen("curl -m 100 'http://feeds.feedburner.com/brainyquote/QUOTEBR'");
        output = file:read("*a");
        io.close(file);

		if (output == "") then
			noquote = 1;
		else
			noquote = 0;
			no_of_quotes = 0;
			quotes = {};
			authors = {};

			local nex = 0;
			local a = "";

			for i=1,4 do
				no_of_quotes = no_of_quotes + 1;
				_,nex,a = string.find(output, "<item>%s*(.-)%s*</item>",nex);
				_,_,authors[no_of_quotes] = string.find(a, "<title>%s*(.-)%s*</title>");
				_,_,quotes[no_of_quotes] = string.find(a, "<description>%s*(.-)%s*</description>");

			end
		end
	end

	if noquote == 1 then
			local text = "Unable to download quotes !!!";
			cairo_set_font_size(cr,14);
			cairo_set_source_rgba(cr, 1, 1, 1, 0.1); -- black
			cairo_text_extents(cr,text,extents);
			cairo_move_to (cr,20,275);
			cairo_show_text (cr, text);
			quotespace = 300;
	else
		show_quote = min/15+1;
		show_quote = show_quote - show_quote%1;

		local text = quotes[show_quote];

		cairo_set_source_rgba(cr, 1, 0.7, 0.4, 0.8);
		cairo_text_extents(cr,text,extents);
		cairo_select_font_face(cr,"Arial",1,0);

		local spaces = {};
		local words={""};
		local space = 0;
		local word = 1;
		for i = 1,string.len(text) do
			letter = string.sub(text,i,i);
			words[word] = words[word]..letter;
			if letter == " " or letter == "." then
				space = space+1;
				spaces[space] = i ;
				word = word+1;
				words[word] = "";
			end
		end
		space = space + 1;

		local length = string.len(text);
		no_of_lines = (length-length%65)/65 + 1;

		local val = 65;
		lines = {""};
		local j = 1;
		for i=1,no_of_lines do
			while j < space and spaces[j] <= i*val  do
				lines[i] = lines[i]..words[j];
				j = j+1;
			end
			i = i+1;
			lines[i] = "";
		end
		lines[no_of_lines] = lines[no_of_lines]..words[space];

		quotespace = 300 + (no_of_lines-1)*20;
		cairo_set_font_size(cr,16);

		cairo_set_source_rgba(cr, 1, 1, 1, 1); -- cyan
		for i = 1,no_of_lines do
			cairo_text_extents(cr,lines[i],extents);
			cairo_move_to(cr,20,250+i*20);
			cairo_show_text(cr,lines[i]);
		end

	-- author name -------------------------------- author name --------------------------------------------
		text = authors[show_quote].." :";
		cairo_set_font_size(cr,20);
		cairo_select_font_face(cr,"Arial",1,1);
		cairo_set_source_rgba(cr, 1, 1, 1, 0.3); -- white
		cairo_text_extents(cr,text,extents);
		cairo_move_to (cr,20,248)
		cairo_show_text (cr, text);
		-- end
	end

end

function noclip_draw_image (ir,xc, yc, radius, path)
	local w, h;

	cairo_set_source_rgba(ir,1,1,1,1);

	cairo_arc (ir, xc, yc, radius, 0, 2*math.pi);
	--cairo_clip (ir);
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

function conky_main()
	-- check for conky window
	if conky_window == nil then
		return;
	end

	-- prepare drawing surface
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height);
	cr = cairo_create(cs);

	local file = io.popen("/sbin/route -n | grep -c '^0\.0\.0\.0'");
	internet = file:read("*a");
	io.close(file);

	local updates = conky_parse("${updates}");

    -- printng quotes
    print_quotes();

    -- just
    cairo_move_to(cr,20,quotespace);
    cairo_rel_line_to(cr,200,0);
    cairo_stroke(cr);

    -- weather
    print_weather();
    if noweather == 0 then
    	local path = "weather_icon/"..code..".png";
    	local ir = cairo_create(cs);
    	noclip_draw_image(ir,300,quotespace+50,70,path);
	end

    -- just
    cairo_move_to(cr,20,weatherspace);
    cairo_rel_line_to(cr,200,0);
    cairo_stroke(cr);

	--end

	-- freeing surface pointers
	cairo_destroy(cr);
	cairo_surface_destroy(cs);
	cr=nil;
end
