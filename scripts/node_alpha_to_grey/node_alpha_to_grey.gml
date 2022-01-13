function Node_create_Alpha_Grey(_x, _y) {
	var node = new Node_Alpha_Grey(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Alpha_Grey(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Alpha to grey";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function process_data(_outSurf, _data, _output_index) {
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		shader_set(sh_alpha_grey);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}