#macro struct_has variable_struct_exists
#macro struct_key variable_struct_get_names

function struct_override(original, override) {
	INLINE
	
	var args = variable_struct_get_names(override);
	
	for( var i = 0, n = array_length(args); i < n; i++ ) {
		var _key = args[i];
		
		if(!struct_has(original, _key)) continue;
		original[$ _key] = override[$ _key];
	}
	
	return original;
}

function struct_override_nested(original, override) {
	INLINE
	
	var args = variable_struct_get_names(override);
	
	for( var i = 0, n = array_length(args); i < n; i++ ) {
		var _key = args[i];
		
		if(!struct_has(original, _key)) continue;
		if(is_struct(original[$ _key]))
			struct_override_nested(original[$ _key], override[$ _key])
		else 
			original[$ _key] = override[$ _key];
	}
	
	return original;
}

function struct_append(original, append) {
	INLINE
	
	var args = variable_struct_get_names(append);
	
	for( var i = 0, n = array_length(args); i < n; i++ )
		original[$ args[i]] = append[$ args[i]];
	
	return original;
}

function struct_try_get(struct, key, def = 0) {
	INLINE
	
	if(struct[$ key] != undefined) return struct[$ key];
	
	key = string_replace_all(key, "_", " ");
	return struct[$ key] ?? def;
}

function struct_try_override(original, override, key) {
	INLINE
	
	if(!is_struct(original) || !is_struct(override)) return;
	if(!struct_has(override, key)) return;
	
	original[$ key] = override[$ key];
}
