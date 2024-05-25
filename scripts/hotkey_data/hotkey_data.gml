#region
	globalvar HOTKEYS_CUSTOM;
	HOTKEYS_CUSTOM  = {
		"Node_Canvas": {
			"Selection":		new hotkeySimple("S"),
			"Magic Selection":	new hotkeySimple("W"),
			"Pencil":			new hotkeySimple("B"),
			"Eraser":			new hotkeySimple("E"),
			"Rectangle":		new hotkeySimple("N"),
			"Ellipse":			new hotkeySimple("M"),
			"Fill":				new hotkeySimple("G"),
			"Freeform":			new hotkeySimple("Q"),
		},
		"Node_Mesh_Warp": {
			"Edit control point": new hotkeySimple("V"),
			"Pin mesh":			  new hotkeySimple("P"),
			"Mesh edit":		  new hotkeySimple("M"),
			"Anchor remove":	  new hotkeySimple("E"),
		},
		"Node_Armature": {
			"Move":			new hotkeySimple("V"),
			"Scale":		new hotkeySimple("S"),
			"Add bones":	new hotkeySimple("A"),
			"Remove bones":	new hotkeySimple("E"),
			"Detach bones":	new hotkeySimple("D"),
			"IK":			new hotkeySimple("K"),
		},
		"Node_Path": {
			"Transform":			new hotkeySimple("T"),
			"Anchor add / remove":	new hotkeySimple("A"),
			"Edit Control point":	new hotkeySimple("C"),
			"Draw path":			new hotkeySimple("B"),
			"Rectangle path":		new hotkeySimple("N"),
			"Circle path":			new hotkeySimple("M"),
		},
		"Node_Rigid_Object": {
			"Mesh edit":		new hotkeySimple("A"),
			"Anchor remove":	new hotkeySimple("E"),
		},
		"Node_Strand_Create": {
			"Push":		new hotkeySimple("P"),
			"Comb":		new hotkeySimple("C"),
			"Stretch":	new hotkeySimple("S"),
			"Shorten":	new hotkeySimple("D"),
			"Grab":		new hotkeySimple("G"),
		},
		"Node_Path_Anchor": {
			"Adjust control point":		new hotkeySimple("A"),
		},
		"Node_3D_Object": {
			"Transform":	new hotkeySimple("G"),
			"Rotate":		new hotkeySimple("R"),
			"Scale":		new hotkeySimple("S"),
		},
		"Node_3D_Camera": {
			"Move Target":	new hotkeySimple("T"),
		},
	};
	
	function getToolHotkey(_group, _key, _def = "") {
		INLINE
		
		if(!struct_has(HOTKEYS_CUSTOM, _group)) return _def;
		
		var _grp = HOTKEYS_CUSTOM[$ _group];
		if(!struct_has(_grp, _key)) return _def;
		return _grp[$ _key].key;
	}
#endregion

#region hotkeys	
	function hotkeySimple(_key) constructor {
		self.key = _key;
		dkey     = _key;
	}
	
	function hotkeyObject(_context, _name, _key, _mod = MOD_KEY.none, _action = noone) constructor {
		context	= _context;
		name	= _name;
		key		= _key;
		modi	= _mod;
		action	= _action;
		
		dKey	= _key;
		dModi	= _mod;
		
		static serialize = function() { return { context, name, key, modi }; }
		
		static deserialize = function(ll) {
			key  = is_struct(ll)? ll.key  : ll[2];
			modi = is_struct(ll)? ll.modi : ll[3];
		}
		
		var _loadKey = $"{context}_{name}";
		if(struct_has(HOTKEYS_DATA, _loadKey))
			deserialize(HOTKEYS_DATA[$ _loadKey]);
	}
	
	function addHotkey(_context, _name, _key, _mod, _action) {
		if(is_string(_key)) {
			var ind = key_get_index(_key);
			_key = ind? ind : ord(_key);
		}
		
		var key = new hotkeyObject(_context, _name, _key, _mod, _action);
		
		if(!ds_map_exists(HOTKEYS, _context)) {
			HOTKEYS[? _context] = ds_list_create();
			if(!ds_list_exist(HOTKEY_CONTEXT, _context))
				ds_list_add(HOTKEY_CONTEXT, _context);
		}
		
		for(var i = 0; i < ds_list_size(HOTKEYS[? _context]); i++) {
			var hotkey	= HOTKEYS[? _context][| i];
			if(hotkey.name == key.name) {
				delete HOTKEYS[? _context][| i];
				HOTKEYS[? _context][| i] = key;
				return;
			}
		}
		
		if(_context == "") ds_list_insert(HOTKEYS[? _context], 0, key);
		else			   ds_list_add(HOTKEYS[? _context], key);
	}
	
	function find_hotkey(_context, _name) { #region
		if(!ds_map_exists(HOTKEYS, _context)) return noone;
		
		for(var j = 0; j < ds_list_size(HOTKEYS[? _context]); j++) {
			if(HOTKEYS[? _context][| j].name == _name)
				return HOTKEYS[? _context][| j];
		}
	} #endregion
#endregion

function hotkey_draw(keyStr, _x, _y) {
	if(keyStr == "") return;
	
	draw_set_text(f_p1, fa_right, fa_center, COLORS._main_text_sub);
	var _tw = string_width( keyStr);
	var _th = string_height(keyStr);
	
	draw_sprite_stretched_ext(THEME.ui_panel_fg, 1, _x - _tw - ui(4), _y - _th / 2 - ui(3), _tw + ui(8), _th + ui(3), COLORS._main_text_sub, 0.5);
	draw_text(_x, _y, keyStr);
}