function Node_Iterate_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name    = "Loop";
	color   = COLORS.node_blend_loop;
	icon    = THEME.loop;
	icon_24 = THEME.loop_24;
	
	is_root     = false;
	
	newInput(0, nodeValue_Int("Repeat", self, 1 ))
		.uncache();
		
	managedRenderOrder = true;
	
	attributes.junc_in  = [ "", 0 ];
	attributes.junc_out = [ "", 0 ];
	
	junc_in  = noone;
	junc_out = noone;
	
	value_buffer    = undefined;
	iterated        = 0;
	
	static getIterationCount = function() { return getInputData(0); }
	static bypassConnection  = function() { return iterated > 0 && !is_undefined(value_buffer); }
	static bypassNextNode    = function() { return iterated < getIterationCount(); }
	
	static getNextNodes = function() {
		LOG_BLOCK_START();	
		LOG_IF(global.FLAG.render == 1, "[outputNextNode] Get next node from inline iterate");
		
		resetRender();
		LOG_IF(global.FLAG.render == 1, $"Loop restart: iteration {iterated}");
		var _nodes = __nodeLeafList(nodes);
		array_push_unique(_nodes, junc_in.node);
		iterated++;
		
		LOG_BLOCK_END();
		
		return _nodes;
	}
	
	static connectJunctions = function(jFrom, jTo) {
		junc_in  = jFrom.is_dummy? jFrom.dummy_get() : jFrom;
		junc_out = jTo;
		
		attributes.junc_in  = [ junc_in .node.node_id, junc_in .index ];
		attributes.junc_out = [ junc_out.node.node_id, junc_out.index ];
	}
	
	static scanJunc = function() {
		var node_in  = PROJECT.nodeMap[? attributes.junc_in[0]];
		var node_out = PROJECT.nodeMap[? attributes.junc_out[0]];
		
		junc_in  = node_in?  node_in.inputs[attributes.junc_in[1]]   : noone;
		junc_out = node_out? node_out.outputs[attributes.junc_out[1]] : noone;
		
		if(junc_in)  { junc_in.value_from_loop = self;				addNode(junc_in.node);  }
		if(junc_out) { array_push(junc_out.value_to_loop, self);	addNode(junc_out.node); }
	}
	
	static updateValue = function() {
		var type = junc_out.type;
		var val  = junc_out.getValue();
		
		switch(type) {
			case VALUE_TYPE.surface : 
				surface_array_free(value_buffer);
				value_buffer = surface_array_clone(val);
				break;
				
			default :
				value_buffer = variable_clone(val);
				break;
		}
	}
	
	static getValue = function(arr) {
		INLINE
		
		arr[@ 0] = value_buffer;
		arr[@ 1] = junc_out;
	}
	
	static update = function() {
		iteration_count = inputs[0].getValue();
		iterated        = 0;
		value_buffer    = undefined;
	}
	
	static drawConnections = function(params = {}) {
		params.dashed = true; params.loop   = true;
		drawJuncConnection(junc_out, junc_in, params);
		params.dashed = false; params.loop   = false;
		
		return noone;
	}
	
	static postDeserialize = function() {
		refreshMember();
		scanJunc();
	}
	
	static onDestroy = function() {
		if(junc_in)  junc_in.value_from_loop = noone;
		if(junc_out) array_remove(junc_out.value_to_loop, self);
	}
}