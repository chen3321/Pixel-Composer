function Node_Wiggler(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name			= "Wiggler";
	update_on_frame = true;
	setDimension(96, 96);
	
	inputs[| 0] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 0.1] });
	
	inputs[| 2] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { inputs[| 2].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 3] = nodeValue("Display", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Number", "Graph" ]);
	
	inputs[| 4] = nodeValue("Clip", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b11 )
		.setDisplay(VALUE_DISPLAY.toggle, { data : [ "Start", "End" ] });
		
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	input_display_list = [
		["Display",	 true],	3,
		["Wiggle",	false], 2, 0, 1, 4, 
	];
	
	graph_display = array_create(64, 0);
	
	range_min    = 0;
	range_max    = 0;
	disp_text    = 0;
	wiggle_seed  = 0;
	wiggle_freq  = 1;
	
	clip_start = true;
	clip_end   = true;
	
	function __getWiggle(_time = 0) { #region
		
		var _ed   = TOTAL_FRAMES;
		var sdMin = floor(_time / wiggle_freq) * wiggle_freq;
		var sdMax = min(_ed, sdMin + wiggle_freq);
		
		var _x0 = (clip_start && sdMin <= 0)?    0.5 : random1D(PROJECT.seed + wiggle_seed + sdMin);
		var _x1 = (clip_end && sdMax >= _ed)?	 0.5 : random1D(PROJECT.seed + wiggle_seed + sdMax);
		
		var t = (_time - sdMin) / (sdMax - sdMin);
		    t = -(cos(pi * t) - 1) / 2;
		    
		var _lrp = lerp(_x0, _x1, t);
		return lerp(range_min, range_max, _lrp);
	} #endregion
	
	static onValueUpdate = function(index = 0) {
		var ran     = getSingleValue(0);
		range_min   = array_safe_get_fast(ran, 0);
		range_max   = array_safe_get_fast(ran, 1);
		
		var fre     = getSingleValue(1);
		wiggle_freq = fre == 0? 1 : max(1, TOTAL_FRAMES / fre);
		wiggle_seed = getSingleValue(2);
		
		var clp     = getSingleValue(4);
		clip_start  = bool(clp & 0b01);
		clip_end    = bool(clp & 0b10);
		
		var step = TOTAL_FRAMES / 64;
		for( var i = 0; i < 64; i++ )
			graph_display[i] = __getWiggle(step * i);
	} 
	
	run_in(1, function() { onValueUpdate(); });
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var ran     = _data[0];
		range_min   = array_safe_get_fast(ran, 0);
		range_max   = array_safe_get_fast(ran, 1);
		
		var fre     = _data[1];
		wiggle_freq = fre == 0? 1 : max(1, TOTAL_FRAMES / fre);
		wiggle_seed = _data[2];
		
		var clp     = _data[4];
		clip_start  = bool(clp & 0b01);
		clip_end    = bool(clp & 0b10);
		
		var val = __getWiggle(CURRENT_FRAME);
		if(_output_index == 0) disp_text = val;
		
		return val;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		
		var ran  = array_safe_get_fast(current_data, 0);
		var fre  = array_safe_get_fast(current_data, 1);
		var sed  = array_safe_get_fast(current_data, 2);
		var disp = array_safe_get_fast(current_data, 3);
		var time = CURRENT_FRAME;
		var total_time = TOTAL_FRAMES;
		
		if(!is_array(ran)) return;
		
		switch(disp) {
			case 0 :
				draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
				draw_text_bbox(bbox, disp_text);
				break;
				
			case 1 :
				var _min = ran[0];
				var _max = ran[1];
				var val  = (_min + _max) / 2;
				var _ran = _max - _min;
				
				var x0 = xx + 8 * _s;
				var x1 = xx + (w - 8) * _s;
				var y0 = yy + 20 * draw_name + 8  * _s;
				var y1 = yy + (h - 8) * _s;
				var ww = x1 - x0;
				var hh = y1 - y0;
				
				var yc = (y0 + y1) / 2;
				draw_set_color(COLORS.node_wiggler_frame);
				draw_set_alpha(0.5);
				draw_line(x0, yc, x1, yc);
				draw_set_alpha(1);
				
				draw_set_text(f_sdf, fa_right, fa_bottom, COLORS._main_text_sub);
				draw_text_transformed(x1 - 2 * _s, y1, disp_text, 0.3 * _s, 0.3 * _s, 0);
				
				var lw = ww / (64 - 1);
				var ox, oy;
				draw_set_color(c_white);
				for( var i = 0; i < 64; i++ ) {
					var _x = x0 + i * lw;
					var _y = yc - (graph_display[i] - val) / _ran * hh;
					if(i) draw_line(ox, oy, _x, _y);
					
					ox = _x;
					oy = _y;
				}
				draw_set_color(COLORS._main_accent);
				var _fx = x0 + (time / total_time * ww);
				draw_line(_fx, y0, _fx, y1);
				
				draw_set_color(COLORS.node_wiggler_frame);
				draw_rectangle(x0, y0, x1, y1, true);
				
				break;
		}
	} #endregion
	
	static doApplyDeserialize = function() { onValueUpdate(); }
}