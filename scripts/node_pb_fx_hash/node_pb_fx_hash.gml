function Node_PB_Fx_Hash(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Hash";
	
	inputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 2] = nodeValue("Hash", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2. );
	
	inputs[| 3] = nodeValue("Invert", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 4] = nodeValue("Dissolve", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0. )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ] )
	
	inputs[| 5] = nodeValue("Detail", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
	
	inputs[| 6] = nodeValue("Dissolve Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0,
		["Effect",	 false], 2, 1, 3, 
		["Dissolve", false], 4, 6, 5, 
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _nbox = _pbox.clone();
		
		var _colr = _data[1];
		var _hash = _data[2];
		var _inv  = _data[3];
		
		var _diss = _data[4];
		var _dItr = _data[5];
		var _dSca = _data[6];
		
		surface_set_shader(_nbox.content, sh_pb_hash);
			shader_set_dim(, _pbox.content);
			shader_set_color("color", _colr);
			shader_set_f("hash", _hash);
			shader_set_i("invert", _inv);
			
			shader_set_f("dissolve", _diss);
			shader_set_f("dissolveSca", _dSca);
			shader_set_i("dissolveItr", _dItr);
			
			draw_surface_ext_safe(_pbox.content, 0, 0,,,, _colr);
		surface_reset_shader();
		
		return _nbox;
	}
}