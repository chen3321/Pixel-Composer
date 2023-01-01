function Node_create_Json_File_Read(_x, _y, _group = -1) {
	var path = "";
	if(!LOADING && !APPENDING) {
		path = get_open_filename(".json", "");
		if(path == "") return noone;
	}
	
	var node = new Node_Json_File_Read(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_create_Json_File_Read_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_Json_File_Read(_x, _y);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;	
}

function Node_Json_File_Read(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "JSON file";
	color = COLORS.node_blend_input;
	previewable = false;
	
	w = 128;
	min_h = 0;
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.json", ""]);
	
	outputs[| 0] = nodeValue(0, "Content", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	outputs[| 1] = nodeValue(1, "Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	content = "";
	path_current = "";
	
	first_update = false;
	
	on_dragdrop_file = function(path) {
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	function updatePaths(path) {
		if(path_current == path) return false;
		
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext = filename_ext(path);
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		switch(ext) {
			case ".json":
				outputs[| 1].setValue(path);
				
				content = json_load(path);
				
				if(path_current == "") 
					first_update = true;
				path_current = path;
				
				return true;
		}
		return false;
	}
	
	static update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		
		outputs[| 0].setValue(content);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var cx = xx + w / 2 * _s;
		var cy = yy + 10 + h / 2 * _s;
		
		var str = filename_name(path_current);
		var ss = min((w - 8) * _s / string_width(str), (h - 24) * _s / string_height(str));
		
		draw_text_transformed(cx, cy, str, ss, ss, 0);
	}
}