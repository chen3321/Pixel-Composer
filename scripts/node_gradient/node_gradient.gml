function Node_create_Gradient(_x, _y) {
	var node = new Node_Gradient(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Gradient(_x, _y) : Node(_x, _y) constructor {
	name = "Gradient";
	
	uniform_grad_blend = shader_get_uniform(sh_gradient, "gradient_blend");
	uniform_grad = shader_get_uniform(sh_gradient, "gradient_color");
	uniform_grad_time = shader_get_uniform(sh_gradient, "gradient_time");
	uniform_key = shader_get_uniform(sh_gradient, "keys");
	uniform_type = shader_get_uniform(sh_gradient, "type");
	uniform_center = shader_get_uniform(sh_gradient, "center");
	
	uniform_angle = shader_get_uniform(sh_gradient, "angle");
	uniform_radius = shader_get_uniform(sh_gradient, "radius");
	uniform_radius_shf = shader_get_uniform(sh_gradient, "shift");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 2] = nodeValue(2, "Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Linear", "Circular", "Radial" ]);
	
	inputs[| 3] = nodeValue(3, "Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 4] = nodeValue(4, "Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .5);
	inputs[| 5] = nodeValue(5, "Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-2, 2, 0.01]);
	
	inputs[| 6] = nodeValue(6, "Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [def_surf_size / 2, def_surf_size / 2])
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	input_display_list = [
		["Output",		true],	0, 
		["Gradient",	false], 1, 2, 3, 4, 5, 6
	];
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		inputs[| 6].drawOverlay(_active, _x, _y, _s, _mx, _my);
	}
	
	function update() {	
		var _dim = inputs[| 0].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
			
		var _gra = inputs[| 1].getValue();
		var _gra_data = inputs[| 1].getExtraData();
		
		var _typ = inputs[| 2].getValue();
		var _ang = inputs[| 3].getValue();
		var _rad = inputs[| 4].getValue();
		var _shf = inputs[| 5].getValue();
		var _cnt = inputs[| 6].getValue();
		var _grad_color = [];
		var _grad_time  = [];
		
		for(var i = 0; i < ds_list_size(_gra); i++) {
			_grad_color[i * 4 + 0] = color_get_red(_gra[| i].value) / 255;
			_grad_color[i * 4 + 1] = color_get_green(_gra[| i].value) / 255;
			_grad_color[i * 4 + 2] = color_get_blue(_gra[| i].value) / 255;
			_grad_color[i * 4 + 3] = 1;
			_grad_time[i]  = _gra[| i].time;
		}
		
		if(_typ == 0 || _typ == 2) {
			inputs[| 3].show_in_inspector	= true;
			inputs[| 4].show_in_inspector	= false;
		} else if(_typ == 1) {
			inputs[| 3].show_in_inspector	= false;
			inputs[| 4].show_in_inspector	= true;
		} 
		
		surface_set_target(_outSurf);
		shader_set(sh_gradient);
			shader_set_uniform_i(uniform_grad_blend, ds_list_get(_gra_data, 0));
			shader_set_uniform_f_array(uniform_grad, _grad_color);
			shader_set_uniform_f_array(uniform_grad_time, _grad_time);
			shader_set_uniform_f_array(uniform_center, [_cnt[0] / _dim[0], _cnt[1] / _dim[1]]);
			shader_set_uniform_i(uniform_key, ds_list_size(_gra));
			shader_set_uniform_i(uniform_type, _typ);
			
			shader_set_uniform_f(uniform_angle, degtorad(_ang));
			shader_set_uniform_f(uniform_radius, _rad * sqrt(2));
			shader_set_uniform_f(uniform_radius_shf, _shf);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
	}
	update();
}