function Node_Surface_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Image";
	
	inputs[| 0] = nodeValue("Base Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Target Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setArrayDepth(1);
	
	inputs[| 2] = nodeValue("Replacement Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setArrayDepth(1);
	
	inputs[| 3] = nodeValue("Color Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1, "How similiar the color need to be in order to be count as matched." )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Draw Base Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 5] = nodeValue("Fast Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 6] = nodeValue("Pixel Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1, "How many pixel need to me matched to replace with replacement image." )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Array mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, { data: [ "Match index", "Randomized" ], update_hover: false });
	
	inputs[| 8] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { inputs[| 8].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 9] = nodeValue("Replace Empty", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surfaces",	 true], 0, 1, 2, 7, 8, 
		["Searching",	false], 5, 3, 6, 
		["Render",		false], 4, 9, 
	];
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	
	static matchTemplate = function(_index, _surf, _base, _target, _cthr, _pthr, _fst) {
		
		surface_set_shader(_surf, _fst? sh_surface_replace_fast_find : sh_surface_replace_find, false);
			shader_set_f("dimension", surface_get_width_safe(_base), surface_get_height_safe(_base));
			
			shader_set_surface("target", _target);
			shader_set_f("targetDimension", surface_get_width_safe(_target), surface_get_height_safe(_target));
			
			shader_set_f("colorThreshold", _cthr);
			shader_set_f("pixelThreshold", _pthr);
			shader_set_f("index", _index);
			shader_set_i("mode", getInputData(7));
			shader_set_f("seed", getInputData(8));
			
			var dest = getInputData(2);
			var size = is_array(dest)? array_length(dest) : 1;
			shader_set_f("size", size);
			
			BLEND_ADD
			draw_surface_safe(_base);
			BLEND_NORMAL
		surface_reset_shader();
	}
	
	static replaceTemplate = function(_index, _base, _res, _replace, _fst) {
		
		shader_set(_fst? sh_surface_replace_fast_replace : sh_surface_replace_replace);
		surface_set_target_ext(0, temp_surface[1]);
		surface_set_target_ext(1, temp_surface[2]);
		
			shader_set_f("dimension",  surface_get_width_safe(_base), surface_get_height_safe(_base));
			
			shader_set_surface("replace", _replace);
			shader_set_f("replace_dim", surface_get_width_safe(_replace), surface_get_height_safe(_replace));
			
			shader_set_surface("findRes", _res);
			shader_set_f("index", _index);
			
			draw_surface_safe(_base);
		surface_reset_shader();
	}
	
	static step = function() {
		var _mode = getInputData(7);
		inputs[| 8].setVisible(_mode == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _bas = _data[0];
		var _tar = _data[1];
		var _rep = _data[2];
		var _drw = _data[4];
		var _fst = _data[5];
		
		var _cthr = _data[3];
		var _pthr = _data[6];
		var _oalp = _data[9];
		
		if(!is_array(_tar)) _tar = [ _tar ]; 
		if(!is_array(_rep)) _rep = [ _rep ];
		
		var _sw = surface_get_width_safe(_bas);
		var _sh = surface_get_height_safe(_bas);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
			surface_clear(temp_surface[i]);
		}
		
		var tamo = array_length(_tar);
		var ramo = array_length(_rep);
		
		for( var i = 0; i < tamo; i++ ) matchTemplate(i / tamo, temp_surface[0], _bas, _tar[i], _cthr, _pthr, _fst);
		// return temp_surface[0];
		
		var amo = max(tamo, ramo);
		for( var i = 0; i < amo; i++ ) {
			var _ri = i % ramo;
			replaceTemplate(_ri / amo, _bas, temp_surface[0], _rep[_ri], _fst);
		}
		
		_outSurf = surface_verify(_outSurf, _sw, _sh);
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_ALPHA
			if(_drw) draw_surface_safe(_bas);
			if(_oalp) {
				BLEND_SUBTRACT
				draw_surface_safe(temp_surface[2]);
				BLEND_ALPHA
			}
			draw_surface_safe(temp_surface[1]);
		surface_reset_target();
		
		return _outSurf;
	}
}