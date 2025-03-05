function Node_PB_FX_Bevel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bevel";
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_i("Height", self, 2));
	
	newInput(2, nodeValue_Gradient("Color Over Height", self, new gradientObject( cola(c_white) )))
	newInput(3, nodeValue_Gradient("Color Over Angles", self, new gradientObject( [ cola(c_black), cola(c_white) ] )))
	newInput(4, nodeValue_r("Shift Angle", self, 0));
	
	newInput(5, nodeValue_b(  "Highlight",           self, false));
	newInput(6, nodeValue_c(  "Highlight Color",     self, cola(c_white)));
	newInput(7, nodeValue_r(  "Highlight Direction", self, 0));
	newInput(8, nodeValue_b(  "Highlight All",       self, false));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Inner Area", self, VALUE_TYPE.surface, noone)).setVisible(false);
	
	input_display_list = [ 0,
	    ["Bevel",  false], 1, 
	    ["Colors", false], 2, 3, 4, 
	    ["Highlight",  false, 5], 8, 7, 6, 
    ];
	
	temp_surface = [ 0, 0, 0 ];
	
	static step = function() {}
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) { 
	    var _surf  = _data[0];
	    var _heigh = _data[1];
	    var _grHig = _data[2];
	    var _grRad = _data[3];
	    var _radsh = _data[4];
	    
	    var _high = _data[5];
	    var _hgcl = _data[6];
	    var _hdir = _data[7];
	    var _hall = _data[8];
	    
	    inputs[7].setVisible(!_hall);
	    
	    var _dim = surface_get_dimension(_surf);
	    for( var i = 0, n = array_length(temp_surface); i < n; i++ )
	        temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
	    
	    surface_set_shader(temp_surface[0], sh_pb_fx_bevel_edge);
	        shader_set_dim("dimension", _surf);
	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    surface_set_shader(temp_surface[1], sh_pb_fx_bevel_angle);
	        shader_set_dim("dimension", _surf);
	        draw_surface_safe(temp_surface[0]);
	    surface_reset_shader();
	    
	    var _outSurf   = surface_verify(_outData[0], _dim[0], _dim[1]);
	    var _innerSurf = surface_verify(_outData[1], _dim[0], _dim[1]);
	    
	    shader_set(sh_pb_fx_bevel);
    	    surface_set_target_ext(0, temp_surface[2]);
    	    surface_set_target_ext(1, _innerSurf);
	        DRAW_CLEAR
	        
	        shader_set_dim("dimension",    _surf);
	        shader_set_f("height",         _heigh);
	        shader_set_f("shiftAngle",     _radsh / 360);
	        shader_set_surface("edgeSurf", temp_surface[1]);
			
			_grHig.shader_submit("height");
			_grRad.shader_submit("radius");
			
	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    surface_set_shader(_outSurf, sh_pb_fx_bevel_apply);
	        shader_set_dim("dimension", _surf);
	        
			shader_set_i("highlight",      _high);
	        shader_set_c("highlightColor", _hgcl);
	        shader_set_f("highlightDir",   degtorad(_hdir));
	        shader_set_i("highlightAll",   _hall);
	        shader_set_surface("insideSurf", _innerSurf);
	        
	        draw_surface_safe(temp_surface[2]);
	    surface_reset_shader();
	    
	    return [ _outSurf, _innerSurf ]; 
	}
}