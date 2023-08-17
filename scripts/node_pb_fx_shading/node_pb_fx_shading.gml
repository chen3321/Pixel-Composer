function Node_PB_Fx_Shading(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Shading";
	
	inputs[| 1] = nodeValue("Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.padding);
		
	inputs[| 2] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	input_display_list = [ 0, 
		["Effect",	false], 1, 2, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		if(_pbox == noone) return _pbox;
		
		var _nbox = _pbox.clone();
		
		var _padd = _data[1];
		var _colr = _data[2];
		
		surface_set_shader(_nbox.content, sh_pb_shade);
			shader_set_dim(, _pbox.content);
			shader_set_f("padding", _padd);
			
			draw_surface_ext_safe(_pbox.content, 0, 0,,,, _colr);
		surface_reset_shader();
		
		return _nbox;
	}
}