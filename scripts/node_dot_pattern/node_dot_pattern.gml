function Node_Dotted(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Dotted";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Surface("Mask", self));
	
	newInput(2, nodeValue_Float("Size", self, 4));
		
	newInput(3, nodeValueMap("Scale Map", self));
	
	newInput(4, nodeValue_Rotation("Angle", self, 0))
		.setMappable(5);
	newInput(5, nodeValueMap("Angle Map", self));
	
	newInput(6, nodeValue_Enum_Button("Render Mode", self,  0, [ "Step", "AA", "Smooth" ]));
	
	newInput(7, nodeValue_Color("BG Color", self, cola(c_black)));
	
	newInput(8, nodeValue_Color("Dot Color", self, cola(c_white)));
	
	newInput(9, nodeValue_Slider("Dot Size", self, .5))
		.setMappable(10);
	newInput(10, nodeValueMap("Dot Size Map", self));
	
	newInput(11, nodeValue_Slider("Intensity", self, 1))
	
	newInput(12, nodeValue_Slider("Smoothness", self, .1))
	
	newInput(13, nodeValue_Enum_Button("Pattern", self,  0, [ "Grid", "Hexagonal" ]));
	
	newInput(14, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	newInput(15, nodeValue_Vec2("Spacing", self, [ 1, 1 ]));
	
	newInput(16, nodeValue_Enum_Button("Dot Color Mode", self,  0, [ "Solid", "Palette", "Random", "Texture" ]));
	
	newInput(17, nodeValue_Palette("Palette", self, DEF_PALETTE));
	
	newInput(18, nodeValue_Gradient("Gradient", self, new gradientObject([cola(c_black), cola(c_white)])) );
	
	newInput(19, nodeValue_Surface("Texture", self));
	
	newInput(20, nodeValueSeed(self));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 20, 
		["Output",     true], 0, 1, 
		["Transform", false], 14, 4, 5, 
		["Pattern",   false], 13, 2, 15, 9, 10, 
		["Render",    false], 7, 6, 16, 8, 17, 18, 19, 12, 11, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		var _hov = false;
		
		var _pos = getSingleValue(14);
		var _px  = _x + _pos[0] * _s;
		var _py  = _y + _pos[1] * _s;
		
		var hv = inputs[14].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv;
		var hv = inputs[ 4].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		inputs[ 4].mappableStep();
		inputs[ 9].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim    = _data[ 0];
		
		var _pattn  = _data[13];
		var _pposi  = _data[14];
		var _space  = _data[15];
		
		var _color  = _data[ 6];
		var _cbg    = _data[ 7];
		var _aa     = _data[12];
		var _ints   = _data[11];
		
		var _cmode  = _data[16];
		var _cdot   = _data[ 8];
		var _palt   = _data[17];
		var _grad   = _data[18];
		var _text   = _data[19];
		var _seed   = _data[20];
		
		inputs[ 8].setVisible(_cmode == 0);
		inputs[17].setVisible(_cmode == 1);
		inputs[18].setVisible(_cmode == 2);
		inputs[19].setVisible(_cmode == 3);
		
		inputs[12].setVisible(_color == 1);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_shader(_outSurf, sh_dotted);
			shader_set_f("seed",      _seed);
			shader_set_2("dimension", _dim);
			shader_set_2("position",  _pposi);
			
			shader_set_f("amount",    _data[ 2]);
			shader_set_2("spacing",   _space);
			shader_set_f_map("angle", _data[ 4], _data[ 5], inputs[ 4]);
			shader_set_f_map("dothr", _data[ 9], _data[10], inputs[ 9]);
			
			shader_set_i("pattern",   _pattn);
			
			shader_set_i("coloring",  _color);
			shader_set_f("intensity", _ints);
			shader_set_f("aa",        _aa);
			
			shader_set_i("colorMode",     _cmode);
			shader_set_c("color0",        _cbg);
			shader_set_c("color1",        _cdot);
			shader_set_surface("texture", _text);
			shader_set_palette(_palt);
			_grad.shader_submit();
			
			draw_empty();
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}