function Node_create_Blend(_x, _y) {
	var node = new Node_Blend(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Blend(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Blend";
	
	inputs[| 0] = nodeValue(0, "Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, DEF_SURFACE);
	inputs[| 1] = nodeValue(1, "Foreground", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, DEF_SURFACE);
	
	inputs[| 2] = nodeValue(2, "Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, BLEND_TYPES )
		.setVisible(false);
	
	inputs[| 3] = nodeValue(3, "Opacity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 4] = nodeValue(4, "Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 5] = nodeValue(5, "Tiling", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Stretch", "Tile" ])
		.setVisible(false);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function process_data(_outSurf, _data, _output_index) {
		var _fore		= _data[1];
		var _type		= _data[2];
		var _opacity	= _data[3];
		var _mask		= _data[4];
		var _tile		= _data[5];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		
		draw_surface_blend(_data[0], _fore, _type, _opacity, _mask, _tile);
		surface_reset_target();
		
		return _outSurf;
	}
}