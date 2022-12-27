function Node_Blur_Radial(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Radial blur";
	
	shader = sh_blur_radial;
	uniform_str = shader_get_uniform(shader, "strength");
	uniform_cen = shader_get_uniform(shader, "center");
	uniform_sam = shader_get_uniform(shader, "sampleMode");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2);
	
	inputs[| 2] = nodeValue(2, "Center",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(0, index); });
		
	inputs[| 3] = nodeValue(3, "Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [ 
		["Surface",	false],	0, 3, 
		["Effect", false],	1, 2,
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 2].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 1].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny, 0, 64, THEME.anchor_scale_hori);
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _str = _data[1];
		var _cen = _data[2];
		var _sam = _data[3];
		_cen[0] /= surface_get_width(_outSurf);
		_cen[1] /= surface_get_height(_outSurf);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVER
		
			shader_set(shader);
			shader_set_uniform_f(uniform_str, _str);
			shader_set_uniform_f_array(uniform_cen, _cen);
			shader_set_uniform_i(uniform_sam, _sam);
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}