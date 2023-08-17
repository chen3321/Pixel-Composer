enum JUNCTION_CONNECT {
	input,
	output
}

enum VALUE_TYPE {
	integer   = 0,
	float     = 1,
	boolean   = 2,
	color     = 3,
	surface   = 4,
	
	path      = 5,
	curve     = 6,
	text      = 7,
	object    = 8,
	node      = 9,
	d3object  = 10,
	
	any       = 11,
	
	pathnode  = 12,
	particle  = 13,
	rigid     = 14,
	fdomain   = 15,
	struct    = 16,
	strands   = 17,
	mesh	  = 18,
	trigger	  = 19,
	atlas	  = 20,
	
	d3vertex  = 21,
	gradient  = 22,
	armature  = 23,
	buffer    = 24,
	
	pbBox     = 25,
	
	d3Mesh	  = 26,
	d3Light	  = 27,
	d3Camera  = 28,
	d3Scene	  = 29,
	
	action	  = 99,
}

enum VALUE_DISPLAY {
	_default,
	range,
	
	//Int
	enum_scroll,
	enum_button,
	rotation,
	rotation_range,
	slider,
	slider_range,
	
	//Color
	palette,
	
	//Int array
	padding,
	vector,
	vector_range,
	area,
	kernel,
	transform,
	corner,
	toggle,
	
	//Curve
	curve,
	
	//Misc
	puppet_control,
	button,
	label,
	
	//Array
	path_array,
	
	//Text
	code,
	text_array,
	
	//path
	path_save,
	path_load,
	path_font,
	
	//vertex
	d3vertex,
}

function value_color(i) {
	static JUNCTION_COLORS = [ 
		$6691ff, //int 
		$78e4ff, //float
		$5d3f8c, //bool
		$5dde8f, //color
		$976bff, //surface
		$4b00eb, //path
		$d1c2c2, //curve
		$e3ff66, //text
		$b5b5ff, //object
		$ffa64d, //node
		#c1007c, //3D
		$808080, //any
		$b5b5ff, //path
		$5dde8f, //particle
		$e3ff66, //rigid
		#4da6ff, //fdomain
		$5d3f8c, //struct
		$6691ff, //strand
		$d1c2c2, //mesh
		$5dde8f, //trigger
		$976bff, //atlas
		#c1007c, //d3vertex
		$5dde8f, //gradient
		$6691ff, //armature
		$808080, //buffer
		$976bff, //pbBox
		$ffa64d, //d3Mesh	
		$ffa64d, //d3Light	
		$ffa64d, //d3Camera
		$ffa64d, //d3Scene	
	];
	
	if(i == 99) return $5dde8f;
	return JUNCTION_COLORS[safe_mod(max(0, i), array_length(JUNCTION_COLORS))];
}

function value_bit(i) {
	switch(i) {
		case VALUE_TYPE.integer		: return 1 << 0 | 1 << 1;
		case VALUE_TYPE.float		: return 1 << 2 | 1 << 1;
		case VALUE_TYPE.boolean		: return 1 << 3 | 1 << 1;
		case VALUE_TYPE.color		: return 1 << 4;
		case VALUE_TYPE.gradient	: return 1 << 25;
		case VALUE_TYPE.surface		: return 1 << 5;
		case VALUE_TYPE.path		: return 1 << 10;
		case VALUE_TYPE.text		: return 1 << 10;
		case VALUE_TYPE.object		: return 1 << 13;
		case VALUE_TYPE.d3object	: return 1 << 14;
		case VALUE_TYPE.d3vertex	: return 1 << 24;
		
		case VALUE_TYPE.pathnode	: return 1 << 15;
		case VALUE_TYPE.particle	: return 1 << 16;
		case VALUE_TYPE.rigid   	: return 1 << 17;
		case VALUE_TYPE.fdomain 	: return 1 << 18;
		case VALUE_TYPE.struct   	: return 1 << 19;
		case VALUE_TYPE.strands   	: return 1 << 20;
		case VALUE_TYPE.mesh	  	: return 1 << 21;
		case VALUE_TYPE.atlas	  	: return 1 << 23;
		case VALUE_TYPE.armature  	: return 1 << 26 | 1 << 19;
		
		case VALUE_TYPE.node		: return 1 << 32;
		
		case VALUE_TYPE.buffer		: return 1 << 27;
		
		case VALUE_TYPE.pbBox		: return 1 << 28;
		
		case VALUE_TYPE.trigger		: return 1 << 22;
		case VALUE_TYPE.action		: return 1 << 22 | 1 << 3;
		
		case VALUE_TYPE.d3Mesh		: return 1 << 29;
		case VALUE_TYPE.d3Light		: return 1 << 29;
		case VALUE_TYPE.d3Camera	: return 1 << 29;
		case VALUE_TYPE.d3Scene		: return 1 << 29 | 1 << 30;
	
		case VALUE_TYPE.any			: return ~0 & ~(1 << 32);
	}
	return 0;
}

function value_type_directional(f, t) {
	if(f == VALUE_TYPE.surface && t == VALUE_TYPE.integer)	return true;
	if(f == VALUE_TYPE.surface && t == VALUE_TYPE.float)	return true;
	
	if(f == VALUE_TYPE.integer && t == VALUE_TYPE.text) return true;
	if(f == VALUE_TYPE.float   && t == VALUE_TYPE.text) return true;
	if(f == VALUE_TYPE.boolean && t == VALUE_TYPE.text) return true;
	
	if(f == VALUE_TYPE.integer && t == VALUE_TYPE.color)	return true;
	if(f == VALUE_TYPE.float   && t == VALUE_TYPE.color)	return true;
	if(f == VALUE_TYPE.color   && t == VALUE_TYPE.integer)	return true;
	if(f == VALUE_TYPE.color   && t == VALUE_TYPE.float  )	return true;
	if(f == VALUE_TYPE.color   && t == VALUE_TYPE.gradient) return true;
	
	if(f == VALUE_TYPE.strands && t == VALUE_TYPE.pathnode ) return true;
	
	if(f == VALUE_TYPE.color && t == VALUE_TYPE.struct ) return true;
	if(f == VALUE_TYPE.mesh  && t == VALUE_TYPE.struct ) return true;
	
	return false;
}

function typeArray(_type) {
	switch(_type) {
		case VALUE_DISPLAY.range :
		case VALUE_DISPLAY.vector_range :
		case VALUE_DISPLAY.rotation_range :
		case VALUE_DISPLAY.slider_range :
		
		case VALUE_DISPLAY.vector :
		case VALUE_DISPLAY.padding :
		case VALUE_DISPLAY.area :
		case VALUE_DISPLAY.puppet_control :
		case VALUE_DISPLAY.kernel :
		case VALUE_DISPLAY.transform :
			
		case VALUE_DISPLAY.curve :
			
		case VALUE_DISPLAY.path_array :
		case VALUE_DISPLAY.palette :
		case VALUE_DISPLAY.text_array :
		
		case VALUE_DISPLAY.d3vertex :
			return 1;
	}
	return 0;
}

function typeArrayDynamic(_type) {
	switch(_type) {
		case VALUE_DISPLAY.curve :
		case VALUE_DISPLAY.palette :
			return true;
	}
	return false;
}

function typeCompatible(fromType, toType, directional_cast = true) {
	if(value_bit(fromType) & value_bit(toType) != 0)
		return true;
	if(!directional_cast) 
		return false;
	return value_type_directional(fromType, toType);
}

function typeIncompatible(from, to) {
	if(from.type == VALUE_TYPE.surface && (to.type == VALUE_TYPE.integer || to.type == VALUE_TYPE.float)) {
		switch(to.display_type) {
			case VALUE_DISPLAY.area : 
			case VALUE_DISPLAY.kernel : 
			case VALUE_DISPLAY.vector_range : 
			case VALUE_DISPLAY.puppet_control : 
			case VALUE_DISPLAY.padding : 
			case VALUE_DISPLAY.curve : 
				return true;
		}
	}
	
	return false;
}

enum KEYFRAME_END {
	hold,
	loop,
	ping,
	wrap,
}

globalvar ON_END_NAME;
ON_END_NAME = [ "Hold", "Loop", "Ping pong", "Wrap" ];

enum VALIDATION {
	pass,
	warning,
	error
}

enum VALUE_UNIT {
	constant,
	reference
}

function isGraphable(prop) {
	if(prop.type == VALUE_TYPE.integer || prop.type == VALUE_TYPE.float) {
		if(prop.display_type == VALUE_DISPLAY.puppet_control)
			return false;
		return true;
	}
	if(prop.type == VALUE_TYPE.color && prop.display_type == VALUE_DISPLAY._default) 
		return true;
		
	return false;
}

function nodeValueUnit(value) constructor {
	self.value = value;
	
	mode = VALUE_UNIT.constant;
	reference = noone;
	triggerButton = button(function() { 
		mode = !mode; 
		value.cache_value[0] = false;
		value.unitConvert(mode);
		value.node.doUpdate();
	});
	triggerButton.icon_blend = COLORS._main_icon_light;
	triggerButton.icon = THEME.unit_ref;
	
	static setMode = function(type) {
		if(type == "constant" && mode == VALUE_UNIT.constant) return;
		if(type == "relative" && mode == VALUE_UNIT.reference) return;
		
		mode = type == "constant"? VALUE_UNIT.constant : VALUE_UNIT.reference;
		value.cache_value[0] = false;
		value.unitConvert(mode);
		value.node.doUpdate();
	}
	
	static draw = function(_x, _y, _w, _h, _m) {
		triggerButton.icon_index = mode;
		triggerButton.tooltip = (mode? "Fraction" : "Pixel") + " unit";
		
		triggerButton.draw(_x, _y, _w, _h, _m, THEME.button_hide);
	}
	
	static invApply = function(value, index = 0) {
		if(mode == VALUE_UNIT.constant) 
			return value;
		if(reference == noone)
			return value;
		
		return convertUnit(value, VALUE_UNIT.reference, index);
	}
	
	static apply = function(value, index = 0) {
		if(mode == VALUE_UNIT.constant) 
			return value;
		if(reference == noone)
			return value;
		
		return convertUnit(value, VALUE_UNIT.constant, index);
	}
	
	static convertUnit = function(value, unitTo, index = 0) {
		var disp = self.value.display_type;
		var base = reference(index);
		var inv = unitTo == VALUE_UNIT.reference;
		
		if(!is_array(base) && !is_array(value))
			return inv? value / base : value * base;
		
		if(!is_array(base) && is_array(value)) {
			for( var i = 0, n = array_length(value); i < n; i++ )
				value[i] = inv? value[i] / base : value[i] * base;
			return value;
		}
		
		if(is_array(base) && !is_array(value)) {
			return value;
		}
			
		switch(disp) {
			case VALUE_DISPLAY.padding :
			case VALUE_DISPLAY.vector :
			case VALUE_DISPLAY.vector_range :
				for( var i = 0, n = array_length(value); i < n; i++ )
					value[i] = inv? value[i] / base[i % 2] : value[i] * base[i % 2];
				return value;
			case VALUE_DISPLAY.area :
				for( var i = 0; i < 4; i++ )
					value[i] = inv? value[i] / base[i % 2] : value[i] * base[i % 2];
				return value;
		}
		
		return value;
	}
}

global.displaySuffix_Range		= [ "min", "max" ];
global.displaySuffix_Area		= [ "x", "y", "w", "h" ];
global.displaySuffix_Padding	= [ "right", "top", "left", "bottom" ];
global.displaySuffix_VecRange	= [ "x min", "x max", "y min", "y max" ];
global.displaySuffix_Axis		= [ "x", "y", "z", "w"];

function nodeValue(_name, _node, _connect, _type, _value, _tooltip = "") {
	return new NodeValue(_name, _node, _connect, _type, _value, _tooltip);
}

function NodeValue(_name, _node, _connect, _type, _value, _tooltip = "") constructor {
	node  = _node;
	x	  = node.x;
	y     = node.y;
	index = _connect == JUNCTION_CONNECT.input? ds_list_size(node.inputs) : ds_list_size(node.outputs);
	type  = _type;
	forward = true;
	
	_initName = _name;
	name = __txt_junction_name(instanceof(node), type, index, _name);
	name = _name;
	
	static updateName = function() {
		internalName = string_lower(string_replace_all(name, " ", "_"));
	} updateName();
	
	if(struct_has(node, "inputMap")) {
		if(_connect == JUNCTION_CONNECT.input)       node.inputMap[?  internalName] = self;
		else if(_connect == JUNCTION_CONNECT.output) node.outputMap[? internalName] = self;
	}
	
	tooltip    = _tooltip;
	editWidget = noone;
	
	connect_type = _connect;
	value_from   = noone;
	value_to     = ds_list_create();
	value_to_arr = [];
	accept_array = true;
	array_depth  = 0;
	auto_connect = true;
	setFrom_condition = -1;
	
	is_anim		= false;
	sep_axis	= false;
	sepable		= is_array(_value) && array_length(_value) > 1;
	animator	= new valueAnimator(_value, self, false);
	animators	= [];
	if(is_array(_value))
	for( var i = 0, n = array_length(_value); i < n; i++ ) {
		animators[i] = new valueAnimator(_value[i], self, true);
		animators[i].index = i;
	}
	
	def_val		= _value;
	on_end		= KEYFRAME_END.hold;
	loop_range  = -1;
	
	unit		= new nodeValueUnit(self);
	extra_data	= {};
	dyna_depo   = ds_list_create();
	
	draw_line_shift_x	= 0;
	draw_line_shift_y	= 0;
	draw_line_thick		= 1;
	draw_line_shift_hover	= false;
	drawLineIndex			= 1;
	draw_line_vb		= noone;
	
	show_graph	= false;
	graph_h		= ui(64);
	
	visible = _connect == JUNCTION_CONNECT.output || _type == VALUE_TYPE.surface || _type == VALUE_TYPE.path;
	show_in_inspector = true;
	
	display_type = VALUE_DISPLAY._default;
	if(_type == VALUE_TYPE.curve)			display_type = VALUE_DISPLAY.curve;
	else if(_type == VALUE_TYPE.d3vertex)	display_type = VALUE_DISPLAY.d3vertex;
	
	display_data = -1;
	display_attribute = noone;
	
	value_validation = VALIDATION.pass;
	error_notification = noone;
	
	extract_node = "";
	
	is_changed  = true;
	cache_value = [ false, false, undefined ];
	cache_array = [ false, false ];
	use_cache   = true;
	
	expUse     = false;
	expression = "";
	expTree    = noone;
	
	express_edit = new textArea(TEXTBOX_INPUT.text, function(str) { 
		expression = str;
		expressionUpdate();
	});
	express_edit.autocomplete_server	= pxl_autocomplete_server;
	express_edit.function_guide_server	= pxl_function_guide_server;
	express_edit.parser_server			= pxl_document_parser;
	express_edit.format   = TEXT_AREA_FORMAT.code;
	express_edit.font     = f_code;
	express_edit.boxColor = COLORS._main_value_positive;
	express_edit.align    = fa_left;
	
	process_array = true;
	validateValue = true;
	
	fullUpdate = false;
	
	static setDefault = function(vals) {
		if(LOADING || APPENDING) return self;
		
		ds_list_clear(animator.values);
		for( var i = 0, n = array_length(vals); i < n; i++ )
			ds_list_add(animator.values, new valueKey(vals[i][0], vals[i][1], animator));
			
		return self;
	}
	
	static resetValue = function() { setValue(def_val); }
	
	static setUnitRef = function(ref, mode = VALUE_UNIT.constant) {
		unit.reference  = ref;
		unit.mode		= mode;
		cache_value[0]  = false;
		
		return self;
	}
	
	static setVisible = function(inspector) {
		if(connect_type == JUNCTION_CONNECT.input) {
			show_in_inspector = inspector;
			visible = argument_count > 1? argument[1] : visible;
		} else 
			visible = inspector;
			
		return self;
	}
	
	static setDisplay = function(_type = VALUE_DISPLAY._default, _data = -1, _attr = noone) {
		display_type	  = _type;
		display_data	  = _data;
		display_attribute = _attr;
		resetDisplay();
		
		return self;
	}
	
	static rejectArray = function() {
		accept_array = false;
		return self;
	}
	
	static uncache = function() {
		use_cache = false;
		return self;
	}
	
	static setArrayDepth = function(aDepth) {
		array_depth = aDepth;
		return self;
	}
	
	static rejectConnect = function() {
		auto_connect = false;
		return self;
	}
	
	static rejectArrayProcess = function() {
		process_array = false;
		return self;
	}
	
	static nonForward = function() {
		forward = false;
		return self;
	}
	
	static nonValidate = function() {
		validateValue = false;
		return self;
	}
	
	static isAnimable = function() {
		//if(type == VALUE_TYPE.gradient)				 return false;
		if(display_type == VALUE_DISPLAY.text_array) return false;
		return true;
	}
	
	static setDropKey = function() {
		switch(type) {
			case VALUE_TYPE.integer		: drop_key = "Number"; break;
			case VALUE_TYPE.float		: drop_key = "Number"; break;
			case VALUE_TYPE.boolean		: drop_key = "Bool";   break;
			case VALUE_TYPE.color		: 
				switch(display_type) {
					case VALUE_DISPLAY.palette :  drop_key = "Palette";  break;
					default : drop_key = "Color";
				}
				break;
			case VALUE_TYPE.gradient    : drop_key = "Gradient"; break;
			case VALUE_TYPE.path		: drop_key = "Asset";  break;
			case VALUE_TYPE.text		: drop_key = "Text";   break;
			case VALUE_TYPE.pathnode	: drop_key = "Path";   break;
			case VALUE_TYPE.struct   	: drop_key = "Struct"; break;
			
			default: 
				drop_key = "None";
		}
	}
	setDropKey();
	
	static resetDisplay = function() {
		editWidget = noone;
		switch(display_type) {
			case VALUE_DISPLAY.button :
				editWidget = button(display_data[0]);
				editWidget.text = display_data[1];
				visible = false;
				return;
		}
		
		switch(type) {
			case VALUE_TYPE.float :
			case VALUE_TYPE.integer :
				var _txt = TEXTBOX_INPUT.number;
				
				switch(display_type) {
					case VALUE_DISPLAY._default :
						editWidget = new textBox(_txt, function(val) { 
							return setValueDirect(val);
						} );
						editWidget.slidable = true;
						if(type == VALUE_TYPE.integer) editWidget.slide_speed = 1;
						if(display_data != -1) editWidget.slide_speed = display_data;
						
						extract_node = "Node_Number";
						break;
					case VALUE_DISPLAY.range :
						editWidget = new rangeBox(_txt, function(index, val) { 
							//var _val = animator.getValue();
							//_val[index] = val;
							return setValueDirect(val, index);
						} );
						if(type == VALUE_TYPE.integer) editWidget.setSlideSpeed(1);
						if(display_data != -1) editWidget.extras = display_data;
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get(global.displaySuffix_Range, i);
						
						extract_node = "Node_Number";
						break;
					case VALUE_DISPLAY.vector :
						var val = animator.getValue();
						if(array_length(val) <= 4) {
							editWidget = new vectorBox(array_length(animator.getValue()), function(index, val) { 
								//var _val = animator.getValue();
								//_val[index] = val;
								return setValueDirect(val, index);
							}, unit );
							if(type == VALUE_TYPE.integer) editWidget.setSlideSpeed(1);
							if(display_data != -1) editWidget.extras = display_data;
							
							if(array_length(val) == 2) {
								extract_node = [ "Node_Vector2", "Node_Path" ];
							} else if(array_length(val) == 3)
								extract_node = "Node_Vector3";
							else if(array_length(val) == 4)
								extract_node = "Node_Vector4";
						}
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + string(array_safe_get(global.displaySuffix_Axis, i));
						
						break;
					case VALUE_DISPLAY.vector_range :
						var val = animator.getValue();
						
						editWidget = new vectorRangeBox(array_length(val), _txt, function(index, val) { 
							//var _val = animator.getValue();
							//_val[index] = val;
							return setValueDirect(val, index);
						}, unit );
						if(type == VALUE_TYPE.integer) editWidget.setSlideSpeed(1);
						if(display_data != -1) editWidget.extras = display_data;
						
						if(array_length(val) == 2)
							extract_node = "Node_Vector2";
						else if(array_length(val) == 3)
							extract_node = "Node_Vector3";
						else if(array_length(val) == 4)
							extract_node = "Node_Vector4";
							
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + string(array_safe_get(global.displaySuffix_VecRange, i));
						
						break;
					case VALUE_DISPLAY.rotation :
						editWidget = new rotator(function(val) {
							return setValueDirect(val);
						}, display_data );
						
						extract_node = "Node_Number";
						break;
					case VALUE_DISPLAY.rotation_range :
						editWidget = new rotatorRange(function(index, val) { 
							//var _val = animator.getValue();
							//_val[index] = round(val);
							return setValueDirect(val, index);
						} );
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get(global.displaySuffix_Range, i);
						
						extract_node = "Node_Vector2";
						break;
					case VALUE_DISPLAY.slider :
						editWidget = new slider(display_data[0], display_data[1], display_data[2], function(val) { 
							return setValueDirect(toNumber(val));
						} );
						if(type == VALUE_TYPE.integer) editWidget.setSlideSpeed(1);
						
						extract_node = "Node_Number";
						break;
					case VALUE_DISPLAY.slider_range :
						editWidget = new sliderRange(display_data[0], display_data[1], display_data[2], function(index, val) {
							//var _val = animator.getValue();
							//_val[index] = val;
							return setValueDirect(val, index);
						} );
						if(type == VALUE_TYPE.integer) editWidget.setSlideSpeed(1);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get(global.displaySuffix_Range, i);
						
						extract_node = "Node_Vector2";
						break;
					case VALUE_DISPLAY.area :
						editWidget = new areaBox(function(index, val) { 
							return setValueDirect(val, index);
						}, unit);
						if(type == VALUE_TYPE.integer) editWidget.setSlideSpeed(1);
						if(display_data != -1) editWidget.onSurfaceSize = display_data;
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get(global.displaySuffix_Area, i, "");
						
						extra_data.area_type = AREA_MODE.area;
						extract_node = "Node_Area";
						break;
					case VALUE_DISPLAY.padding :
						editWidget = new paddingBox(function(index, val) { 
							//var _val = animator.getValue();
							//_val[index] = val;
							return setValueDirect(val, index);
						}, unit);
						if(type == VALUE_TYPE.integer) editWidget.setSlideSpeed(1);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get(global.displaySuffix_Padding, i);
						
						extract_node = "Node_Vector4";
						break;
					case VALUE_DISPLAY.corner :
						editWidget = new cornerBox(function(index, val) { 
							return setValueDirect(val, index);
						}, unit);
						if(type == VALUE_TYPE.integer) editWidget.setSlideSpeed(1);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get(global.displaySuffix_Padding, i);
						
						extract_node = "Node_Vector4";
						break;
					case VALUE_DISPLAY.puppet_control :
						editWidget = new controlPointBox(function(index, val) { 
							//var _val = animator.getValue();
							//_val[index] = val;
							return setValueDirect(val, index);
						});
						
						extract_node = "";
						break;
					case VALUE_DISPLAY.enum_scroll :
						editWidget = new scrollBox(display_data, function(val) {
							if(val == -1) return;
							return setValueDirect(toNumber(val)); 
						} );
						if(is_struct(display_attribute)) {
							editWidget.update_hover = display_attribute[$ "update_hover"];
						}
						
						rejectConnect();
						extract_node = "";
						break;
					case VALUE_DISPLAY.enum_button :
						editWidget = new buttonGroup(display_data, function(val) { 
							return setValueDirect(val);
						} );
						
						rejectConnect();
						extract_node = "";
						break;
					case VALUE_DISPLAY.kernel :
						editWidget = new matrixGrid(_txt, function(index, val) {
							var _val = animator.getValue();
							_val[index] = val;
							return setValueDirect(_val);
						}, unit );
						if(type == VALUE_TYPE.integer) editWidget.setSlideSpeed(1);
						if(display_data != -1) editWidget.extras = display_data;
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + string(i);
						
						extract_node = "";
						break;
					case VALUE_DISPLAY.transform :
						editWidget = new transformBox(function(index, val) {
							var _val = animator.getValue();
							_val[index] = val;
							return setValueDirect(_val);
						});
						
						extract_node = "Node_Transform_Array";
						break;
					case VALUE_DISPLAY.toggle :
						editWidget = new toggleGroup(display_data, function(val) { 
							return setValueDirect(val);
						} );
						
						rejectConnect();
						extract_node = "";
						break;
				}
				break;
			case VALUE_TYPE.boolean :
				editWidget = new checkBox(function() {
					return setValueDirect(!animator.getValue()); 
				} );
				
				extract_node = "Node_Boolean";
				break;
			case VALUE_TYPE.color :
				switch(display_type) {
					case VALUE_DISPLAY._default :
						editWidget = new buttonColor(function(color) { 
							return setValueDirect(color);
						} );
						
						graph_h		 = ui(16);
						extract_node = "Node_Color";
						break;
					case VALUE_DISPLAY.palette :
						editWidget = new buttonPalette(function(color) { 
							return setValueDirect(color);
						} );
						
						extract_node = "Node_Palette";
						break;
				}
				break;
			case VALUE_TYPE.gradient :
				editWidget = new buttonGradient(function(gradient) { 
					return setValueDirect(gradient);
				} );
						
				extract_node = "Node_Gradient_Out";
				break;
			case VALUE_TYPE.path :
				switch(display_type) {
					case VALUE_DISPLAY.path_array :
						editWidget = new pathArrayBox(node, display_data, function(path) { setValueDirect(path); } );
						break;
					case VALUE_DISPLAY.path_load :
						editWidget = new textBox(TEXTBOX_INPUT.text, function(str) { setValueDirect(str); }, 
							button(function() { 
								var path = get_open_filename(display_data[0], display_data[1]);
								key_release();
								if(path == "") return noone;
								return setValueDirect(path);
							}, THEME.button_path_icon)
						);
						editWidget.align = fa_left;
						
						extract_node = "Node_String";
						break;
					case VALUE_DISPLAY.path_save :
						editWidget = new textBox(TEXTBOX_INPUT.text, function(str) { setValueDirect(str); }, 
							button(function() { 
								var path = get_save_filename(display_data[0], display_data[1]);
								key_release();
								if(path == "") return noone;
								return setValueDirect(path);
							}, THEME.button_path_icon)
						);
						editWidget.align = fa_left;
						
						extract_node = "Node_String";
						break;
						
					case VALUE_DISPLAY.path_font :
						editWidget = new fontScrollBox(
							function(val) {
								return setValueDirect(DIRECTORY + "Fonts/" + FONT_INTERNAL[val]);
							}
						);
						break;
				}
				break;
			case VALUE_TYPE.curve :
				display_type = VALUE_DISPLAY.curve;
				editWidget = new curveBox(function(_modified) { 
					return setValueDirect(_modified); 
				});
				break;
			case VALUE_TYPE.text :
				switch(display_type) {
					case VALUE_DISPLAY._default :
						editWidget = new textArea(TEXTBOX_INPUT.text, function(str) { 
							return setValueDirect(str); 
						});
						extract_node = "Node_String";
						break;
					
					case VALUE_DISPLAY.code :
						editWidget = new textArea(TEXTBOX_INPUT.text, function(str) { 
							return setValueDirect(str); 
						});
						
						editWidget.font = f_code;
						editWidget.format = TEXT_AREA_FORMAT.code;
						editWidget.min_lines = 4;
						extract_node = "Node_String";
						break;
					
					case VALUE_DISPLAY.text_array :
						editWidget = new textArrayBox(function() { 
							return animator.values[| 0].value; }, display_data, function() { node.doUpdate(); 
						});
						break;
				}
				break;
			case VALUE_TYPE.surface :
				editWidget = new surfaceBox(function(ind) { 
					return setValueDirect(ind); 
				}, display_data );
				show_in_inspector = true;
				extract_node = "Node_Canvas";
				break;
			case VALUE_TYPE.pathnode :
				extract_node = "Node_Path";
				break;
		}
		
		setDropKey();
	}
	resetDisplay();
	
	static expressionUpdate = function() {
		expTree    = evaluateFunctionList(expression);
		node.triggerRender();
	}
	
	static onValidate = function() {
		if(!validateValue) return;
		var _val = value_validation, str = "";
		value_validation = VALIDATION.pass; 
		
		switch(type) {
			case VALUE_TYPE.path:
				switch(display_type) {
					case VALUE_DISPLAY.path_load: 
						var path = animator.getValue();
						if(is_array(path)) path = path[0];
						if(try_get_path(path) == -1) {
							value_validation = VALIDATION.error;	
							str = "File not exist: " + string(path);
						}
						break;
					case VALUE_DISPLAY.path_array: 
						var paths = animator.getValue();
						if(is_array(paths)) {
							for( var i = 0, n = array_length(paths); i < n; i++ ) {
								if(try_get_path(paths[i]) != -1) continue;
								value_validation = VALIDATION.error;	
								str = "File not exist: " + string(paths[i]);
							} 
						} else {
							value_validation = VALIDATION.error;	
							str = "File not exist: " + string(paths);
						}
						break;
				}
				break;
		}
		
		node.onValidate();
		
		if(_val == value_validation) return self;
		
		#region notification
			if(value_validation == VALIDATION.error && error_notification == noone) {
				error_notification = noti_error(str);
				error_notification.onClick = function() { PANEL_GRAPH.focusNode(node); };
			}
				
			if(value_validation == VALIDATION.pass && error_notification != noone) {
				noti_remove(error_notification);
				error_notification = noone;
			}
		#endregion
		
		return self;
	}
	
	static valueProcess = function(value, nodeFrom, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom.type;
		var display  = nodeFrom.display_type;
		
		if(type == VALUE_TYPE.gradient && typeFrom == VALUE_TYPE.color) { 
			if(is_struct(value) && instanceof(value) == "gradientObject")
				return value;
			if(is_array(value)) {
				var amo = array_length(value);
				var grad = array_create(amo);
				for( var i = 0; i < amo; i++ )
					grad[i] = new gradientKey(i / amo, value[i]);
				var g = new gradientObject();
				g.keys = grad;
				return g;
			} 
			
			var grad = new gradientObject(value);
			return grad;
		}
		
		if(display_type == VALUE_DISPLAY.palette && !is_array(value)) {
			return [ value ];
		}
		
		if(display_type == VALUE_DISPLAY.area) {
			var dispType = struct_try_get(nodeFrom.extra_data, "area_type", AREA_MODE.area);
			var surfGet = nodeFrom.display_data;
			if(!applyUnit || surfGet == -1) {
				//print($"     {value}");
				return value;
			}
			
			var surf = surfGet();
			var ww = surf[0];
			var hh = surf[1];
			
			switch(dispType) {
				case AREA_MODE.area : 
					return value;	
					
				case AREA_MODE.padding : 
					var cx = (ww - value[0] + value[2]) / 2
					var cy = (value[1] + hh - value[3]) / 2;
					var sw = abs((ww - value[0]) - value[2]) / 2;
					var sh = abs(value[1] - (hh - value[3])) / 2;
					return [cx, cy, sw, sh, value[4]];
					
				case AREA_MODE.two_point : 
					var cx = (value[0] + value[2]) / 2
					var cy = (value[1] + value[3]) / 2;
					var sw = abs(value[0] - value[2]) / 2;
					var sh = abs(value[1] - value[3]) / 2;
					return [cx, cy, sw, sh, value[4]];
			}
		}
		
		
		if(type == VALUE_TYPE.text) {
			switch(display_type) {
				case VALUE_DISPLAY.text_array : 
					return value;
				default:
					return string_real(value);
			}
		}
		
		if(typeFrom == VALUE_TYPE.integer && type == VALUE_TYPE.color)
			return value;
		
		if((typeFrom == VALUE_TYPE.integer || typeFrom == VALUE_TYPE.float || typeFrom == VALUE_TYPE.boolean) && type == VALUE_TYPE.color)
			return value >= 1? value : make_color_hsv(0, 0, value * 255);
			
		if(typeFrom == VALUE_TYPE.boolean && type == VALUE_TYPE.text)
			return value? "true" : "false";
		
		if(type == VALUE_TYPE.integer || type == VALUE_TYPE.float) {
			if(typeFrom == VALUE_TYPE.text)
				value = toNumber(value);
			
			if(applyUnit)
				return unit.apply(value, arrIndex);
		}
		
		if(type == VALUE_TYPE.surface && connect_type == JUNCTION_CONNECT.input && !is_surface(value) && def_val == USE_DEF)
			return DEF_SURFACE;
		
		return value;
	}
	
	static resetCache = function() {
		cache_value[0] = false;
	}
	
	#region[#eb004b20] === GetValue ===
	static getValueCached = function(_time = PROJECT.animator.current_frame, applyUnit = true, arrIndex = 0) {
		return getValue(_time, applyUnit, arrIndex, true);
	}
	
	static getValue = function(_time = PROJECT.animator.current_frame, applyUnit = true, arrIndex = 0, useCache = false) {
		if(type == VALUE_TYPE.trigger)
			useCache = false;
			
		global.cache_call++;
		if(useCache && use_cache) {
			var cache_hit = cache_value[0];
			cache_hit &= (!is_anim && value_from == noone) || cache_value[1] == _time;
			cache_hit &= cache_value[2] != undefined;
			cache_hit &= connect_type == JUNCTION_CONNECT.input;
			cache_hit &= unit.reference == noone || unit.mode == VALUE_UNIT.constant;
			//cache_hit &= !expUse;
			
			if(cache_hit) {
				global.cache_hit++;
				return cache_value[2];
			}
		}
		
		var val = _getValue(_time, applyUnit, arrIndex);
		
		if(useCache) {
			is_changed = !isEqual(cache_value[2], val);
			cache_value[0] = true;
			cache_value[1] = _time;
		}
		
		cache_value[2] = val;
		
		return val;
	}
	
	static __getAnimValue = function(_time = PROJECT.animator.current_frame) {
		if(sep_axis) {
			var val = [];
			for( var i = 0, n = array_length(animators); i < n; i++ )
				val[i] = animators[i].getValue(_time);
			return val;
		} else	
			return animator.getValue(_time);
	}
	
	static _getValue = function(_time = PROJECT.animator.current_frame, applyUnit = true, arrIndex = 0) {
		var _val = getValueRecursive(_time);
		var val = _val[0];
		var nod = _val[1];
		var typ = nod.type;
		var dis = nod.display_type;
		
		if(typ == VALUE_TYPE.surface && (type == VALUE_TYPE.integer || type == VALUE_TYPE.float) && accept_array) { //Dimension conversion
			if(is_array(val)) {
				var eqSize = true;
				var sArr = [];
				var _osZ = 0;
				
				for( var i = 0, n = array_length(val); i < n; i++ ) {
					if(!is_surface(val[i])) continue;
					
					var surfSz = [ surface_get_width(val[i]), surface_get_height(val[i]) ];
					array_push(sArr, surfSz);
					
					if(i && !array_equals(surfSz, _osZ))
						eqSize = false;
					
					_osZ = surfSz;
				}
				
				if(eqSize) return _osZ;
				return sArr;
			} else if (is_surface(val)) 
				return [ surface_get_width(val), surface_get_height(val) ];
			return [1, 1];
		} 
		
		if(is_array(def_val) && !typeArrayDynamic(display_type)) { //Balance array (generate uniform array from single values)
			if(!is_array(val)) {
				val = array_create(array_length(def_val), val);	
				return valueProcess(val, nod, applyUnit, arrIndex);
			} else if(array_length(val) < array_length(def_val)) {
				for( var i = array_length(val); i < array_length(def_val); i++ )
					val[i] = 0;
			}
		}
		
		if(isArray(val) && array_length(val) < 128) { //Process data
			for( var i = 0, n = array_length(val); i < n; i++ )
				val[i] = valueProcess(val[i], nod, applyUnit, arrIndex);
		} else 
			val = valueProcess(val, nod, applyUnit, arrIndex);
		
		return val;
	}
	
	static getValueRecursive = function(_time = PROJECT.animator.current_frame) {
		var val = [ -1, self ];
		
		if(type == VALUE_TYPE.trigger && connect_type == JUNCTION_CONNECT.output) //trigger even will not propagate from input to output, need to be done manually
			return [ __getAnimValue(_time), self ];
		
		if(value_from == noone) {
			var _val = __getAnimValue(_time);
			val = [ _val, self ];
		} else if(value_from != self)
			val = value_from.getValueRecursive(_time); 
		
		if(expUse && is_struct(expTree) && expTree.validate()) {
			//print($"========== EXPRESSION CALLED ==========");
			//print(debug_get_callstack(8));
			
			if(global.EVALUATE_HEAD != noone && global.EVALUATE_HEAD == self)  {
				//noti_warning($"Expression evaluation error : recursive call detected.");
			} else {
				printIf(global.LOG_EXPRESSION, $"==================== EVAL BEGIN {expTree} ====================");
				//print(json_beautify(json_stringify(expTree)));
				//printCallStack();
				
				global.EVALUATE_HEAD = self;
				var params = { 
					name: name,
					node_name: node.display_name,
					value: val[0] 
				};
				
				var _exp_res = expTree.eval(variable_clone(params));
				if(is_undefined(_exp_res)) {
					val[0] = 0;
					noti_warning("Expression not returning any values.");
				} else 
					val[0] = _exp_res;
				global.EVALUATE_HEAD = noone;
			}
		}
		
		return val;
	}
	#endregion
	
	static setAnim = function(anim) {
		is_anim = anim;
		PANEL_ANIMATION.updatePropertyList();
	}
	
	static __anim = function() {
		if(node.update_on_frame) return true;
		if(expUse) {
			if(!is_struct(expTree)) return false;
			var res = expTree.isAnimated();
			switch(res) {
				case EXPRESS_TREE_ANIM.none :		return false;
				case EXPRESS_TREE_ANIM.base_value : return is_anim;
				case EXPRESS_TREE_ANIM.animated :	return true;
			}
		}
		
		return is_anim;
	}
	
	static isAnimated = function() {
		if(value_from == noone) return __anim();
		else					return value_from.isAnimated() || value_from.__anim();
	}
	
	static showValue = function() { 
		var useCache = true;
		if(display_type == VALUE_DISPLAY.area)
			useCache = false;
		
		var val = getValue(, false, 0, useCache);
		
		if(isArray()) {
			if(array_length(val) == 0) return 0;
			var v = val[safe_mod(node.preview_index, array_length(val))];
			if(array_length(v) >= 100) return $"[{array_length(v)}]";
		}
		return val;
	}
	
	static isArray = function(val = undefined) {
		if(val == undefined) {
			if(cache_array[0])
				return cache_array[1];
			val = getValue();
		}
		
		cache_array[0] = true;
		
		if(!is_array(val)) { //Value is array
			cache_array[1] = false;
			return cache_array[1];
		}
		
		if(array_depth == 0 && !typeArray(display_type)) { //Value is not an array by default, and no array depth enforced
			cache_array[1] = true;
			return cache_array[1];
		}
		
		var ar = val;
		repeat(array_depth + typeArray(display_type)) { //Recursively get the first member of subarray to check if value has depth of "array_depth" or not
			if(!is_array(ar) || !array_length(ar)) { //empty array
				cache_array[1] = false;
				return cache_array[1];
			}
			
			ar = ar[0];
		}
		
		cache_array[1] = is_array(ar);
		return cache_array[1];
	}
	
	static arrayLength = function(val = undefined) {
		if(val == undefined)
			val = getValue();
		
		if(!isArray(val)) 
			return 0;
		
		if(array_depth == 0 && !typeArray(display_type)) 
			return array_length(val);
		
		var ar = val;
		repeat(array_depth - 1 + typeArray(display_type))
			ar = ar[0];
		
		return array_length(ar);
	}
	
	#region[#8fde5d16] === SetValue ===
	static setValue = function(val = 0, record = true, time = PROJECT.animator.current_frame, _update = true) {
		//if(type == VALUE_TYPE.d3vertex && !is_array(val))
		//	print(val);
		
		val = unit.invApply(val);
		return setValueDirect(val, noone, record, time, _update);
	}
	
	static setValueDirect = function(val = 0, index = noone, record = true, time = PROJECT.animator.current_frame, _update = true) {
		var updated = false;
		
		if(sep_axis) {
			if(index == noone) {
				for( var i = 0, n = array_length(animators); i < n; i++ )
					updated |= animators[i].setValue(val[i], connect_type == JUNCTION_CONNECT.input && record, time); 
			} else
				updated = animators[index].setValue(val, connect_type == JUNCTION_CONNECT.input && record, time); 
		} else {
			if(index != noone) {
				var _val = variable_clone(animator.getValue(time));
				_val[index] = val;
				updated = animator.setValue(_val, connect_type == JUNCTION_CONNECT.input && record, time); 
			} else
				updated = animator.setValue(val, connect_type == JUNCTION_CONNECT.input && record, time); 
		}
		
		if(type == VALUE_TYPE.gradient)				updated = true;
		if(display_type == VALUE_DISPLAY.palette)   updated = true;
		
		if(updated) {
			if(connect_type == JUNCTION_CONNECT.input) {
				node.triggerRender();
				if(_update) node.valueUpdate(self.index);
				node.clearCacheForward();
				
				if(fullUpdate)	UPDATE |= RENDER_TYPE.full;
				else			UPDATE |= RENDER_TYPE.partial;
			}
			
			if(!LOADING) PROJECT.modified = true; 
			cache_value[0] = false;
		}
		
		onValidate();
		
		return updated;
	}
	#endregion
	
	static isConnectable = function(_valueFrom, checkRecur = true, log = false) {		
		if(_valueFrom == -1 || _valueFrom == undefined || _valueFrom == noone) {
			if(log)
				noti_warning("LOAD: Cannot set node connection from " + string(_valueFrom) + " to " + string(name) + " of node " + string(node.name) + ".",, node);
			return false;
		}
		
		if(_valueFrom == value_from) {
			print("whaT");
			return false;
		}
		
		if(_valueFrom == self) {
			if(log)
				noti_warning("setFrom: Self connection is not allowed.",, node);
			return false;
		}
		
		if(!typeCompatible(_valueFrom.type, type)) { 
			if(log) 
				noti_warning($"setFrom: Type mismatch {_valueFrom.type} to {type}",, node);
			return false;
		}
		
		if(typeIncompatible(_valueFrom, self)) {
			if(log) 
				noti_warning("setFrom: Type mismatch",, node);
			return false;
		}
		
		if(connect_type == _valueFrom.connect_type) {
			if(log)
				noti_warning("setFrom: Connect type mismatch",, node);
			return false;
		}
		
		if(checkRecur && _valueFrom.searchNodeBackward(node)) {
			if(log)
				noti_warning("setFrom: Cyclic connection not allowed.",, node);
			return false;
		}
		
		if(!accept_array && isArray(_valueFrom.getValue())) {
			if(log)
				noti_warning("setFrom: Array mismatch",, node);
			return false;
		}
			
		if(!accept_array && _valueFrom.type == VALUE_TYPE.surface && (type == VALUE_TYPE.integer || type == VALUE_TYPE.float)) {
			if(log)
				noti_warning("setFrom: Array mismatch",, node);
			return false;
		}
		
		return true;
	}
	
	static setFrom = function(_valueFrom, _update = true, checkRecur = true, log = false) {
		if(_valueFrom == noone)
			return removeFrom();
		
		if(!isConnectable(_valueFrom, checkRecur, log)) 
			return -1;
		
		if(setFrom_condition != -1 && !setFrom_condition(_valueFrom)) 
			return -2;
		
		if(value_from != noone)
			ds_list_remove(value_from.value_to, self);
		
		var _o = animator.getValue();
		recordAction(ACTION_TYPE.junction_connect, self, value_from);
		value_from = _valueFrom;
		ds_list_add(_valueFrom.value_to, self);
		//show_debug_message("connected " + name + " to " + _valueFrom.name)
		
		node.valueUpdate(index, _o);
		if(_update && connect_type == JUNCTION_CONNECT.input) {
			node.onValueFromUpdate(index);
			node.triggerRender();
			node.clearCacheForward();
			
			UPDATE |= RENDER_TYPE.partial;
		}
		
		cache_array[0] = false;
		cache_value[0] = false;
		
		draw_line_shift_x	= 0;
		draw_line_shift_y	= 0;
		
		if(!LOADING) PROJECT.modified = true;
		
		return true;
	}
	
	static removeFrom = function(_remove_list = true) {
		recordAction(ACTION_TYPE.junction_disconnect, self, value_from);
		if(_remove_list && value_from != noone)
			ds_list_remove(value_from.value_to, self);	
		value_from = noone;
		
		if(connect_type == JUNCTION_CONNECT.input)
			node.onValueFromUpdate(index);
		node.clearCacheForward();
		
		return false;
	}
	
	static getShowString = function() {
		var val = showValue();
		return string_real(val);
	}
	
	static setString = function(str) {
		var _o = animator.getValue();
		
		if(string_pos(",", str) > 0) {
			string_replace(str, "[", "");
			string_replace(str, "]", "");
			
			var ss  = str, pos, val = [], ind = 0;
			
			while(string_length(ss) > 0) {
				pos = string_pos(",", ss);
				
				if(pos == 0) {
					val[ind++] = toNumber(ss);
					ss = "";
				} else {
					val[ind++] = toNumber(string_copy(ss, 1, pos - 1));
					ss  = string_copy(ss, pos + 1, string_length(ss) - pos);
				}
			}
			
			var _t = typeArray(display_type);
			if(_t) {
				if(array_length(_o) == array_length(val) || _t == 2)
					setValue(val);
			} else if(array_length(val) > 0) {
				setValue(val[0]);	
			}
		} else {
			if(is_array(_o)) {
				setValue(array_create(array_length(_o), toNumber(str)));
			} else {
				setValue(toNumber(str));
			}
		}
	}
	
	static checkConnection = function(_remove_list = true) {
		if(value_from == noone) return;
		if(value_from.node.active) return;
		
		removeFrom(_remove_list);
	}
	
	static searchNodeBackward = function(_node) {
		if(node == _node) return true;
		for(var i = 0; i < ds_list_size(node.inputs); i++) {
			var _in = node.inputs[| i].value_from;
			if(_in && _in.searchNodeBackward(_node))
				return true;
		}
		return false;
	}
	
	static unitConvert = function(mode) {
		var _v = animator.values;
		
		for( var i = 0; i < ds_list_size(_v); i++ )
			_v[| i].value = unit.convertUnit(_v[| i].value, mode);
	}
	
	drag_type = 0;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sx   = 0;
	drag_sy   = 0;
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(type != VALUE_TYPE.integer && type != VALUE_TYPE.float) return -1;
		if(value_from != noone) return -1;
		if(expUse) return -1;
		
		switch(display_type) {
			case VALUE_DISPLAY._default :
				var _angle = argument_count >  8? argument[ 8] : 0;
				var _scale = argument_count >  9? argument[ 9] : 1;
				var _spr   = argument_count > 10? argument[10] : THEME.anchor_selector;
				return preview_overlay_scalar(value_from == noone, active, _x, _y, _s, _mx, _my, _snx, _sny, _angle, _scale, _spr);
						
			case VALUE_DISPLAY.rotation :
				var _rad = argument_count >  8? argument[ 8] : 64;
				return preview_overlay_rotation(value_from == noone, active, _x, _y, _s, _mx, _my, _snx, _sny, _rad);
						
			case VALUE_DISPLAY.vector :
				var _spr = argument_count > 8? argument[8] : THEME.anchor_selector;
				var _sca = argument_count > 9? argument[9] : 1;
				return preview_overlay_vector(value_from == noone, active, _x, _y, _s, _mx, _my, _snx, _sny, _spr);
						
			case VALUE_DISPLAY.area :
				return preview_overlay_area(value_from == noone, active, _x, _y, _s, _mx, _my, _snx, _sny, display_data);
						
			case VALUE_DISPLAY.puppet_control :
				return preview_overlay_puppet(value_from == noone, active, _x, _y, _s, _mx, _my, _snx, _sny);
		}
		
		return -1;
	}
	
	junction_drawing = [ THEME.node_junctions_single, type ];
	static drawJunction = function(_s, _mx, _my, sca = 1) {
		if(!isVisible()) return false;
		
		var ss = max(0.25, _s / 2);
		var is_hover = false;
		
		if(PANEL_GRAPH.pHOVER && point_in_circle(_mx, _my, x, y, 10 * _s * sca)) {
			//var _to = getJunctionTo();
			//var _ss = "";
			//for( var i = 0, n = array_length(_to); i < n; i++ ) 
			//	_ss += (i? ", " : "") + _to[i].internalName;
			//TOOLTIP = _ss;
			
			is_hover = true;
			if(type == VALUE_TYPE.action)
				junction_drawing = [THEME.node_junction_inspector, 1];
			else
				junction_drawing = [isArray()? THEME.node_junctions_array_hover : THEME.node_junctions_single_hover, type];
		} else {
			if(type == VALUE_TYPE.action)
				junction_drawing = [THEME.node_junction_inspector, 0];
			else
				junction_drawing = [isArray()? THEME.node_junctions_array : THEME.node_junctions_single, type];
		}
		
		draw_sprite_ext(junction_drawing[0], junction_drawing[1], x, y, ss, ss, 0, c_white, 1);
		
		return is_hover;
	}
	
	static drawNameBG = function(_s) {
		if(!isVisible()) return false;
		
		draw_set_text(f_p1, fa_left, fa_center);
		
		var tw = string_width(name) + 32;
		var th = string_height(name) + 16;
		
		if(type == VALUE_TYPE.action) {
			var tx = x;
			draw_sprite_stretched_ext(THEME.node_junction_name_bg, 0, tx - tw / 2, y - th, tw, th, c_white, 0.5);
		} else if(connect_type == JUNCTION_CONNECT.input) {
			var tx = x - 12 * _s;
			draw_sprite_stretched_ext(THEME.node_junction_name_bg, 0, tx - tw + 16, y - th / 2, tw, th, c_white, 0.5);
		} else {
			var tx = x + 12 * _s;
			draw_sprite_stretched_ext(THEME.node_junction_name_bg, 0, tx - 16, y - th / 2, tw, th, c_white, 0.5);
		}
	}
	static drawName = function(_s, _mx, _my) {
		if(!isVisible()) return false;
		
		var _hover = PANEL_GRAPH.pHOVER && point_in_circle(_mx, _my, x, y, 10 * _s);
		var _draw_cc = _hover? COLORS._main_text : COLORS._main_text_sub;
		draw_set_text(f_p1, fa_left, fa_center, _draw_cc);
		
		if(type == VALUE_TYPE.action) {
			var tx = x;
			draw_set_text(f_p1, fa_center, fa_center, _draw_cc);
			draw_text(tx, y - (line_get_height() + 16) / 2, name);
		} else if(connect_type == JUNCTION_CONNECT.input) {
			var tx = x - 12 * _s;
			draw_set_halign(fa_right);
			draw_text(tx, y, name);
		} else {
			var tx = x + 12 * _s;
			draw_set_halign(fa_left);
			draw_text(tx, y, name);
		}
	}
	
	static drawConnections = function(_x, _y, _s, mx, my, _active, aa = 1, minx = undefined, miny = undefined, maxx = undefined, maxy = undefined) {
		if(value_from == noone)		return noone;
		if(!value_from.node.active) return noone;
		if(!isVisible())			return noone;
		
		var hovering = noone;
		var jx  = x;
		var jy  = y;	
			
		var frx = value_from.x;
		var fry = value_from.y;
			
		if(!is_undefined(minx)) {
			if(jx < minx && frx < minx) return noone;
			if(jx > maxx && frx > maxx) return noone;
				
			if(jy < miny && fry < miny) return noone;
			if(jy > maxy && fry > maxy) return noone;
		}
					
		var c0  = value_color(value_from.type);
		var c1  = value_color(type);
			
		var shx = draw_line_shift_x * _s;
		var shy = draw_line_shift_y * _s;
			
		var cx  = round((frx + jx) / 2 + shx);
		var cy  = round((fry + jy) / 2 + shy);
			
		var hover = false;
		var th = max(1, PREF_MAP[? "connection_line_width"] * _s);
		draw_line_shift_hover = false;
			
		var downDirection = type == VALUE_TYPE.action || value_from.type == VALUE_TYPE.action;
			
		if(PANEL_GRAPH.pHOVER)
		switch(PREF_MAP[? "curve_connection_line"]) {
			case 0 : 
				hover = distance_to_line(mx, my, jx, jy, frx, fry) < max(th * 2, 6);
				break;
			case 1 : 
				if(downDirection) 
					hover = distance_to_curve_corner(mx, my, jx, jy, frx, fry, _s) < max(th * 2, 6);
				else 
					hover = distance_to_curve(mx, my, jx, jy, frx, fry, cx, cy, _s) < max(th * 2, 6);
						
				if(PANEL_GRAPH.value_focus == noone)
					draw_line_shift_hover = hover;
				break;
			case 2 : 
				if(downDirection) 
					hover = distance_to_elbow_corner(mx, my, frx, fry, jx, jy) < max(th * 2, 6);
				else
					hover = distance_to_elbow(mx, my, frx, fry, jx, jy, cx, cy, _s, value_from.drawLineIndex, drawLineIndex) < max(th * 2, 6);
					
				if(PANEL_GRAPH.value_focus == noone)
					draw_line_shift_hover = hover;
				break;
			case 3 :
				if(downDirection) 
					hover  = distance_to_elbow_diag_corner(mx, my, frx, fry, jx, jy) < max(th * 2, 6);
				else
					hover  = distance_to_elbow_diag(mx, my, frx, fry, jx, jy, cx, cy, _s, value_from.drawLineIndex, drawLineIndex) < max(th * 2, 6);
					
				if(PANEL_GRAPH.value_focus == noone)
					draw_line_shift_hover = hover;
				break;
		}
			
		if(_active && hover)
			hovering = self;
			
		var thicken = false;
		thicken |= PANEL_GRAPH.nodes_junction_d == self;
		thicken |= _active && PANEL_GRAPH.junction_hovering == self && PANEL_GRAPH.value_focus == noone;
		thicken |= instance_exists(o_dialog_add_node) && o_dialog_add_node.junction_hovering == self;
			
		th *= thicken? 2 : 1;
			
		var corner = PREF_MAP[? "connection_line_corner"] * _s;
		var ty = LINE_STYLE.solid;
		if(type == VALUE_TYPE.node)
			ty = LINE_STYLE.dashed;
			
		var ss  = _s * aa;
		jx  *= aa;
		jy  *= aa;
		frx *= aa;
		fry *= aa;
		th  *= aa;
		cx  *= aa;
		cy  *= aa;
		corner *= aa;
		th = max(1, round(th));
			
		draw_set_color(c0);
			
		var fromIndex = value_from.drawLineIndex;
		var toIndex   = drawLineIndex;
		
		switch(PREF_MAP[? "curve_connection_line"]) {
			case 0 : 
				if(ty == LINE_STYLE.solid)
					draw_line_width_color(jx, jy, frx, fry, th, c1, c0);
				else
					draw_line_dashed_color(jx, jy, frx, fry, th, c1, c0, 12 * ss);
				break;
			case 1 : 
				if(downDirection)
					draw_line_curve_corner(jx, jy, frx, fry, ss, th, c0, c1); 
				else
					draw_line_curve_color(jx, jy, frx, fry, cx, cy, ss, th, c0, c1, ty); 
				break;
			case 2 : 
				if(downDirection)
					draw_line_elbow_corner(frx, fry, jx, jy, ss, th, c0, c1, corner, fromIndex, toIndex, ty); 
				else
					draw_line_elbow_color(frx, fry, jx, jy, cx, cy, ss, th, c0, c1, corner, fromIndex, toIndex, ty); 
				break;
			case 3 : 
				if(downDirection)
					draw_line_elbow_diag_corner(frx, fry, jx, jy, ss, th, c0, c1, corner, fromIndex, toIndex, ty); 
				else
					draw_line_elbow_diag_color(frx, fry, jx, jy, cx, cy, ss, th, c0, c1, corner, fromIndex, toIndex, ty); 
				break;
		}
		
		return hovering;
	}
	
	static drawConnectionMouse = function(_mx, _my, ss, target) {
		var drawCorner = type == VALUE_TYPE.action;
		if(target != noone)
			drawCorner |= target.type == VALUE_TYPE.action;
		
		var corner = PREF_MAP[? "connection_line_corner"] * ss;
		var th     = PREF_MAP[? "connection_line_width"]  * ss;
		
		var col = value_color(type);
		draw_set_color(col);
		
		switch(PREF_MAP[? "curve_connection_line"]) {
			case 0 : 
				draw_line_width(x, y, _mx, _my, th); 
				break;
			case 1 : 
				if(drawCorner) {
					if(type == VALUE_TYPE.action)
						draw_line_curve_corner(_mx, _my, x, y, ss, th, col, col);
					else
						draw_line_curve_corner(x, y, _mx, _my, ss, th, col, col);
				} else {
					if(connect_type == JUNCTION_CONNECT.output)
						draw_line_curve_color(_mx, _my, x, y,,, ss, th, col, col);
					else 
						draw_line_curve_color(x, y, _mx, _my,,, ss, th, col, col);
				}
				break;
			case 2 : 
				if(drawCorner) {
					if(type == VALUE_TYPE.action)
						draw_line_elbow_corner(_mx, _my, x, y, ss, th, col, col, corner);
					else
						draw_line_elbow_corner(x, y, _mx, _my, ss, th, col, col, corner);
				} else {
					if(connect_type == JUNCTION_CONNECT.output)
						draw_line_elbow_color(x, y, _mx, _my,,, ss, th, col, col, corner);
					else 
						draw_line_elbow_color(_mx, _my, x, y,,, ss, th, col, col, corner);
				}
				break;
			case 3 : 
				if(drawCorner) {
					if(type == VALUE_TYPE.action)
						draw_line_elbow_diag_corner(_mx, _my, x, y, ss, th, col, col, corner);
					else
						draw_line_elbow_diag_corner(x, y, _mx, _my, ss, th, col, col, corner);
				} else {
					if(connect_type == JUNCTION_CONNECT.output)
						draw_line_elbow_diag_color(x, y, _mx, _my,,, ss, th, col, col, corner);
					else 													
						draw_line_elbow_diag_color(_mx, _my, x, y,,, ss, th, col, col, corner);
				}
				break;
		}
	}
	
	static isVisible = function() {
		if(!node.active) 
			return false;
			
		if(value_from) 
			return true;
		
		if(connect_type == JUNCTION_CONNECT.input) {
			if(!visible) 
				return false;
				
			if(is_array(node.input_display_list))
				return array_exists(node.input_display_list, index);
		}
		return visible;
	}
	
	static extractNode = function(_type = extract_node) {
		if(_type == "") return noone;
		
		var ext = nodeBuild(_type, node.x, node.y);
		ext.x -= ext.w + 32;
		
		for( var i = 0; i < ds_list_size(ext.outputs); i++ ) {
			if(setFrom(ext.outputs[| i])) break;
		}
		
		var animFrom = animator.values;
		var len = 2;
		
		switch(_type) {
			case "Node_Vector4": len++;
			case "Node_Vector3": len++;
			case "Node_Vector2": 
				for( var j = 0; j < len; j++ ) {
					var animTo = ext.inputs[| j].animator;
					var animLs = animTo.values;
					
					ext.inputs[| j].setAnim(is_anim);
					ds_list_clear(animLs);
				}
				
				for( var i = 0; i < ds_list_size(animFrom); i++ ) {
					for( var j = 0; j < len; j++ ) {
						var animTo = ext.inputs[| j].animator;
						var animLs = animTo.values;
						var a = animFrom[| i].clone(animTo);
						
						a.value = a.value[j];
						ds_list_add(animLs, a);
					}
				}
				break;
			case "Node_Path": 
				break;
			default:
				var animTo = ext.inputs[| 0].animator;
				var animLs = animTo.values;
				
				ext.inputs[| 0].setAnim(is_anim);
				ds_list_clear(animLs);
				
				for( var i = 0; i < ds_list_size(animFrom); i++ )
					ds_list_add(animLs, animFrom[| i].clone(animTo));
				break;
		}
		
		ext.doUpdate();
		PANEL_ANIMATION.updatePropertyList();
	}
	
	static getJunctionTo = function() {
		var to =  [];
		
		for(var j = 0; j < ds_list_size(value_to); j++) {
			var _to = value_to[| j];
			if(!_to.node.active || _to.value_from == noone) continue; 
			if(_to.value_from != self) continue;
			
			array_push(to, _to);
		}
				
		return to;
	}
	
	static dragValue = function() {
		if(drop_key == "None") return;
		
		DRAGGING = { 
			type: drop_key, 
			data: showValue(),
		}
		
		if(type == VALUE_TYPE.path) {
			DRAGGING.data = new FileObject(node.name, DRAGGING.data);
			DRAGGING.data.getSpr();
		}
		
		if(connect_type == JUNCTION_CONNECT.input)
			DRAGGING.from = self;
	}
	
	#region[#88ffe916] === Save Load ===
	static serialize = function(scale = false, preset = false) {
		var _map = {};
		
		_map.visible = visible;
		
		if(connect_type == JUNCTION_CONNECT.output) 
			return _map;
		
		_map.name		= name;
		_map.on_end		= on_end;
		_map.loop_range	= loop_range;
		_map.unit		= unit.mode;
		_map.sep_axis	= sep_axis;
		_map.shift_x	= draw_line_shift_x;
		_map.shift_y	= draw_line_shift_y;
		_map.from_node  = !preset && value_from? value_from.node.node_id	: -1;
		_map.from_index = !preset && value_from? value_from.index			: -1;
		_map.global_use = expUse;
		_map.global_key = expression;
		_map.anim		= is_anim;
		
		_map.raw_value  = animator.serialize(scale);
		
		var _anims = [];
		for( var i = 0, n = array_length(animators); i < n; i++ )
			array_push(_anims, animators[i].serialize(scale));
		_map.animators = _anims;
		_map.data = extra_data;
		
		return _map;
	}
	
	con_node  = -1;
	con_index = -1;
	
	static applyDeserialize = function(_map, scale = false, preset = false) {
		if(_map == undefined) return;
		if(_map == noone)     return;
		if(!is_struct(_map))  return;
		
		visible = struct_try_get(_map, "visible", visible);
		if(connect_type == JUNCTION_CONNECT.output) 
			return;
		
		//printIf(TESTING, "     |- Applying deserialize to junction " + name + " of node " + node.name);
		name 		= struct_try_get(_map, "name", name);
		on_end		= struct_try_get(_map, "on_end");
		loop_range	= struct_try_get(_map, "loop_range", -1);
		unit.mode	= struct_try_get(_map, "unit");
		expUse    	= struct_try_get(_map, "global_use");
		expression	= struct_try_get(_map, "global_key");
		expTree     = evaluateFunctionList(expression); 
		
		sep_axis	= struct_try_get(_map, "sep_axis");
		is_anim		= struct_try_get(_map, "anim");
		
		draw_line_shift_x = struct_try_get(_map, "shift_x");
		draw_line_shift_y = struct_try_get(_map, "shift_y");
		
		animator.deserialize(struct_try_get(_map, "raw_value"), scale);
		
		if(struct_has(_map, "animators")) {
			var anims = _map.animators;
			var amo = min(array_length(anims), array_length(animators));
			for( var i = 0; i < amo; i++ )
				animators[i].deserialize(anims[i], scale);
		}
		
		if(!preset) {
			con_node  = struct_try_get(_map, "from_node",  -1);
			con_index = struct_try_get(_map, "from_index", -1);
		}
		
		if(struct_has(_map, "data") && is_struct(_map.data))
			extra_data = _map.data;
		
		if(APPENDING) def_val = getValue(0);
		
		onValidate();
	}
	
	static connect = function(log = false) {
		if(con_node == -1 || con_index == -1)
			return true;
		
		var _node = con_node;
		if(APPENDING) {
			_node = GetAppendID(con_node);
			if(_node == noone)
				return true;
		}
		
		if(!ds_map_exists(PROJECT.nodeMap, _node)) {
			var txt = $"Node connect error : Node ID {_node} not found.";
			log_warning("LOAD", $"[Connect] {txt}", node);
			return false;
		}
		
		var _nd = PROJECT.nodeMap[? _node];
		var _ol = ds_list_size(_nd.outputs);
		
		if(log) log_warning("LOAD", $"[Connect] Reconnecting {node.name} to {_nd.name}", node);
		
		if(con_index < _ol) {
			var _set = setFrom(_nd.outputs[| con_index], false, true);
			if(_set) return true;
			
				 if(_set == -1) log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : Not connectable.", node);
			else if(_set == -2) log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : Condition not met.", node); 
			
			return false;
		}
		
		log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : Output not exist.", node);
		return false;
	}
	#endregion
	
	static destroy = function() {
		if(error_notification != noone) {
			noti_remove(error_notification);
			error_notification = noone;
		}	
	}
	
	static cleanUp = function() {
		ds_list_destroy(value_to);
		animator.cleanUp();
		delete animator;
	}
}