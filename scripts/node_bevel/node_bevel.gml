function Node_create_Bevel(_x, _y) {
	var node = new Node_Bevel(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Bevel(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Bevel";
	
	uniform_dim = shader_get_uniform(sh_bevel, "dimension");
	uniform_shf = shader_get_uniform(sh_bevel, "shift");
	uniform_sca = shader_get_uniform(sh_bevel, "scale");
	uniform_hei = shader_get_uniform(sh_bevel, "height");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 2] = nodeValue(2, "Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function process_data(_outSurf, _data, _output_index) {
		var _hei = _data[1];
		var _shf = _data[2];
		var _sca = _data[3];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
		
			shader_set(sh_bevel);
			shader_set_uniform_f(uniform_hei, _hei);
			shader_set_uniform_f_array(uniform_shf, _shf);
			shader_set_uniform_f_array(uniform_sca, _sca);
			shader_set_uniform_f_array(uniform_dim, [ surface_get_width(_data[0]), surface_get_height(_data[0]) ]);
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}