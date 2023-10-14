/// @desc Panel for displaying node graph
/// @param {Struct.Project}
function Panel_Graph(project = PROJECT) : PanelContent() constructor {
	title = __txt("Graph");
	context_str = "Graph";
	icon  = THEME.panel_graph;
	
	static setProject = function(project) {
		self.project = project;
		nodes_list   = project.nodes;
	}
	setProject(project);
	
	#region ---- display ----
		display_parameter = {
			show_grid	    : true,
			show_dimension  : true,
			show_compute    : true,
		
			avoid_label   : true,
			preview_scale : 100,
			highlight     : false,
		}
		
		bg_color = c_black;
	#endregion
	
	#region ---- position ----
		scale			= [ 0.01, 0.02, 0.05, 0.10, 0.15, 0.20, 0.25, 0.33, 0.5, 0.65, 0.8, 1, 1.2, 1.35, 1.5, 2.0];
		graph_s			= 1;
		graph_s_to		= graph_s;
		
		graph_dragging_key = false;
		graph_zooming_key  = false;
		
		graph_draggable= true;
		graph_dragging = false;
		graph_drag_mx  = 0;
		graph_drag_my  = 0;
		graph_drag_sx  = 0;
		graph_drag_sy  = 0;
		
		graph_zooming  = false;
		graph_zoom_mx  = 0;
		graph_zoom_my  = 0;
		graph_zoom_m   = 0;
		graph_zoom_s   = 0;
		
		drag_key	   = mb_middle;
		drag_locking   = false;
	#endregion
	
	#region ---- mouse ----
		mouse_graph_x = 0;
		mouse_graph_y = 0;
		mouse_grid_x = 0;
		mouse_grid_y = 0;
		mouse_on_graph = false;
	#endregion
	
	#region ---- nodes ----
		node_context = ds_list_create();
		
		node_dragging = noone;
		node_drag_mx  = 0;
		node_drag_my  = 0;
		node_drag_sx  = 0;
		node_drag_sy  = 0;
		node_drag_ox  = 0;
		node_drag_oy  = 0;
	
		selection_block		= 0;
		nodes_select_list	= ds_list_create();
		nodes_select_drag   = false;
		nodes_select_mx     = 0;
		nodes_select_my     = 0;
	
		nodes_junction_d    = noone;
		nodes_junction_dx   = 0;
		nodes_junction_dy   = 0;
	
		node_hovering		= noone;
		node_hover			= noone;
		node_focus			= noone;
		
		junction_hovering	= noone;
		add_node_draw_junc	= false;
		add_node_draw_x_fix = 0;
		add_node_draw_y_fix = 0;
		add_node_draw_x = 0;
		add_node_draw_y = 0;
		
		connection_aa = 2;
		connection_surface = surface_create(1, 1);
	
		value_focus     = noone;
		value_dragging  = noone;
		value_draggings = [];
	#endregion
	
	#region ---- minimap ----
		minimap_show = false;
		minimap_w = ui(160);
		minimap_h = ui(160);
		minimap_surface = -1;
	
		minimap_panning  = false;
		minimap_dragging = false;
		minimap_drag_sx = 0;
		minimap_drag_sy = 0;
		minimap_drag_mx = 0;
		minimap_drag_my = 0;
	#endregion
	
	#region ---- context frame ----
		context_framing = false;
		context_frame_progress = 0;
		context_frame_direct   = 0;
		context_frame_sx = 0; context_frame_ex = 0;
		context_frame_sy = 0; context_frame_ey = 0;
	#endregion
	
	toolbar_height = ui(40);
	
	function toCenterNode() { #region
		if(!project.active) return; 
		
		if(ds_list_empty(nodes_list)) {
			graph_x = round(w / 2 / graph_s);
			graph_y = round(h / 2 / graph_s);
			return;
		}
		
		var minx =  99999;
		var maxx = -99999;
		var miny =  99999;
		var maxy = -99999;
			
		for(var i = 0; i < ds_list_size(nodes_list); i++) {
			var _node = nodes_list[| i];
			if(!is_struct(_node) || !is_instanceof(_node, Node) || !_node.active)
				continue;
			
			minx = min(_node.x - 32, minx);
			maxx = max(_node.x + _node.w + 32, maxx);
				
			miny = min(_node.y - 32, miny);
			maxy = max(_node.y + _node.h + 32, maxy);
		}
		
		graph_x = w / 2 / graph_s - (minx + maxx) / 2;
		graph_y = (h - toolbar_height) / 2 / graph_s - (miny + maxy) / 2;
		
		graph_x = round(graph_x);
		graph_y = round(graph_y);
		
		//print(title + ": Center " + string(graph_x) + ", " + string(graph_y));
	} #endregion
	
	function initSize() { toCenterNode(); } initSize();
	
	#region ++++ toolbars ++++
	toolbars = [
		[ 
			THEME.icon_preview_export,
			function() { return 0;  },
			function() { return __txtx("panel_graph_export_image", "Export graph as image"); }, 
			function() { dialogPanelCall(new Panel_Graph_Export_Image(self)); }
		],
		[ 
			THEME.icon_center_canvas,
			function() { return 0;  },
			function() { return __txtx("panel_graph_center_to_nodes", "Center to nodes"); }, 
			function() { toCenterNode(); } 
		],
		[ 
			THEME.icon_minimap,
			function() { return minimap_show;  },
			function() { return minimap_show? __txtx("panel_graph_minimap_enabled", "Minimap enabled") : __txtx("panel_graph_minimap_disabled", "Minimap disabled"); }, 
			function() { minimap_show = !minimap_show; } 
		],
		[ 
			THEME.icon_curve_connection,
			function() { return PREF_MAP[? "curve_connection_line"];  },
			function() { return __txtx("panel_graph_connection_line", "Connection render settings"); }, 
			function(param) { 
				dialogPanelCall(new Panel_Graph_Connection_Setting(), param.x, param.y, { anchor: ANCHOR.bottom | ANCHOR.left }); 
			} 
		],
		[ 
			THEME.icon_grid_setting,
			function() { return 0; },
			function() { return __txtx("grid_title", "Grid settings"); }, 
			function(param) { 
				dialogPanelCall(new Panel_Graph_Grid_Setting(), param.x, param.y, { anchor: ANCHOR.bottom | ANCHOR.left }); 
			} 
		],
		[ 
			THEME.icon_visibility,
			function() { return 0; },
			function() { return __txtx("graph_visibility_title", "Visibility settings"); }, 
			function(param) { 
				dialogPanelCall(new Panel_Graph_View_Setting(display_parameter), param.x, param.y, { anchor: ANCHOR.bottom | ANCHOR.left }); 
			} 
		],
	]; #endregion
	
	#region ++++ hotkeys ++++
	addHotkey("Graph", "Add node",			    "A", MOD_KEY.none,	function() { PANEL_GRAPH.callAddDialog(); });
	addHotkey("Graph", "Focus content",			"F", MOD_KEY.none,	function() { PANEL_GRAPH.fullView(); });
	addHotkey("Graph", "Preview focusing node",	"P", MOD_KEY.none,	function() { PANEL_GRAPH.setCurrentPreview(); });
	addHotkey("Graph", "Preview window",		"P", MOD_KEY.ctrl,	function() { create_preview_window(PANEL_GRAPH.node_focus); });
	addHotkey("Graph", "Import image",			"I", MOD_KEY.none,	function() { nodeBuild("Node_Image",			PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y); });
	addHotkey("Graph", "Import image array",	"I", MOD_KEY.shift,	function() { nodeBuild("Node_Image_Sequence",	PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y); });
	addHotkey("Graph", "Add number",			"1", MOD_KEY.none,	function() { nodeBuild("Node_Number",			PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y); });
	addHotkey("Graph", "Add vector2",			"2", MOD_KEY.none,	function() { nodeBuild("Node_Vector2",			PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y); });
	addHotkey("Graph", "Add vector3",			"3", MOD_KEY.none,	function() { nodeBuild("Node_Vector3",			PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y); });
	addHotkey("Graph", "Add vector4",			"4", MOD_KEY.none,	function() { nodeBuild("Node_Vector4",			PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y); });
	
	addHotkey("Graph", "Transform node",		"T", MOD_KEY.ctrl,	function() { PANEL_GRAPH.doTransform(); });
	
	addHotkey("Graph", "Select all",	"A", MOD_KEY.ctrl,	function() { 
		ds_list_clear(nodes_select_list); 
		for(var i = 0; i < ds_list_size(nodes_list); i++) {
			ds_list_add(nodes_select_list, nodes_list[| i]);	
		}
	});
	
	addHotkey("Graph", "Toggle grid",	 "G", MOD_KEY.none,		function() { display_parameter.show_grid = !display_parameter.show_grid; });
	addHotkey("Graph", "Toggle preview", "H", MOD_KEY.none,		function() { PANEL_GRAPH.setTriggerPreview(); });
	addHotkey("Graph", "Toggle render",  "R", MOD_KEY.none,		function() { PANEL_GRAPH.setTriggerRender(); });
	
	if(!DEMO)
		addHotkey("Graph", "Export",	"E", MOD_KEY.ctrl,	function() { PANEL_GRAPH.setCurrentExport(); });
	
	addHotkey("Graph", "Blend",		"B", MOD_KEY.ctrl,					function() { PANEL_GRAPH.doBlend(); });
	addHotkey("Graph", "Compose",	"B", MOD_KEY.ctrl | MOD_KEY.shift,	function() { PANEL_GRAPH.doCompose(); });
	addHotkey("Graph", "Array",		"A", MOD_KEY.ctrl | MOD_KEY.shift,	function() { PANEL_GRAPH.doArray(); });
	
	addHotkey("Graph", "Group",		"G", MOD_KEY.ctrl,					function() { PANEL_GRAPH.doGroup(); });
	addHotkey("Graph", "Ungroup",	"G", MOD_KEY.ctrl | MOD_KEY.shift,	function() { PANEL_GRAPH.doUngroup(); });
	
	addHotkey("Graph", "Loop",		"L", MOD_KEY.ctrl,					function() { PANEL_GRAPH.doLoop(); });
	
	addHotkey("Graph", "Canvas",		"C", MOD_KEY.ctrl | MOD_KEY.shift,		function() { PANEL_GRAPH.setCurrentCanvas(); });
	addHotkey("Graph", "Canvas blend",	"C", MOD_KEY.ctrl | MOD_KEY.alt,		function() { PANEL_GRAPH.setCurrentCanvasBlend(); });
	
	addHotkey("Graph", "Frame",		"F", MOD_KEY.ctrl,					function() { PANEL_GRAPH.doFrame(); });
	
	addHotkey("Graph", "Delete (break)",	vk_delete, MOD_KEY.shift,	function() { PANEL_GRAPH.doDelete(false); });
	addHotkey("Graph", "Delete (merge)",	vk_delete, MOD_KEY.none,	function() { PANEL_GRAPH.doDelete(true); });
	
	addHotkey("Graph", "Duplicate",	"D", MOD_KEY.ctrl,	function() { PANEL_GRAPH.doDuplicate(); });
	addHotkey("Graph", "Copy",		"C", MOD_KEY.ctrl,	function() { PANEL_GRAPH.doCopy(); });
	addHotkey("Graph", "Paste",		"V", MOD_KEY.ctrl,	function() { PANEL_GRAPH.doPaste(); });
	
	addHotkey("Graph", "Pan",		"", MOD_KEY.alt,				function() { 
																		if(PREF_MAP[? "alt_picker"]) return; 
																		PANEL_GRAPH.graph_dragging_key = true; 
																	});
	addHotkey("Graph", "Zoom",		"", MOD_KEY.alt | MOD_KEY.ctrl,	function() { 
																		if(PREF_MAP[? "alt_picker"]) return; 
																		PANEL_GRAPH.graph_zooming_key = true; 
																	});
	#endregion
	
	#region ++++ node setters ++++
		function setCurrentPreview(_node = node_focus) { #region
			if(!_node) return;
		
			PANEL_PREVIEW.setNodePreview(_node);
		} #endregion
	
		function setCurrentExport(_node = node_focus) { #region
			if(DEMO) return;
			if(!_node) return;
		
			var _outp = -1;
			var _path = -1;
		
			for( var i = 0; i < ds_list_size(_node.outputs); i++ ) {
				if(_node.outputs[| i].type == VALUE_TYPE.path)
					_path = _node.outputs[| i];
				if(_node.outputs[| i].type == VALUE_TYPE.surface && _outp == -1)
					_outp = _node.outputs[| i];
			}
		
			if(_outp == -1) return;
		
			var _export = nodeBuild("Node_Export", _node.x + _node.w + 64, _node.y);
			if(_path != -1)
				_export.inputs[| 1].setFrom(_path);
		
			_export.inputs[| 0].setFrom(_outp);
		} #endregion
	
		function setCurrentCanvas(_node = node_focus) { #region
			if(!_node) return;
		
			var _outp = -1;
			var surf = -1;
		
			for( var i = 0; i < ds_list_size(_node.outputs); i++ ) {
				if(_node.outputs[| i].type == VALUE_TYPE.surface) {
					_outp = _node.outputs[| i];
					var _val = _node.outputs[| i].getValue();
					if(is_array(_val))
						surf  = _val[_node.preview_index];
					else
						surf  = _val;
					break;
				}
			}
		
			if(_outp == -1) return;
		
			var _canvas = nodeBuild("Node_Canvas", _node.x + _node.w + 64, _node.y);
		
			_canvas.inputs[| 0].setValue([surface_get_width_safe(surf), surface_get_height_safe(surf)]);
			_canvas.canvas_surface = surface_clone(surf);
			_canvas.apply_surface();
		} #endregion
	
		function setTriggerPreview() { #region
			if(node_focus != noone)
				node_focus.previewable = !node_focus.previewable;
		
			var show = false;
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				if(i == 0) show = !nodes_select_list[| i].previewable;
				nodes_select_list[| i].previewable = show;
			}
		} #endregion
	
		function setTriggerRender() { #region
			if(node_focus != noone)
				node_focus.renderActive = !node_focus.renderActive;
		
			var show = false;
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				if(i == 0) show = !nodes_select_list[| i].renderActive;
				nodes_select_list[| i].renderActive = show;
			}
		} #endregion
	
		function setCurrentCanvasBlend(_node = node_focus) { #region
			if(!_node) return;
		
			var _outp = -1;
			var surf = -1;
		
			for( var i = 0; i < ds_list_size(_node.outputs); i++ ) {
				if(_node.outputs[| i].type == VALUE_TYPE.surface) {
					_outp = _node.outputs[| i];
					var _val = _node.outputs[| i].getValue();
					if(is_array(_val))
						surf  = _val[_node.preview_index];
					else
						surf  = _val;
					break;
				}
			}
		
			if(_outp == -1) return;
		
			var _canvas = nodeBuild("Node_Canvas", _node.x, _node.y + _node.h + 64);
		
			_canvas.inputs[| 0].setValue([surface_get_width_safe(surf), surface_get_height_safe(surf)]);
			_canvas.inputs[| 5].setValue(true);
		
			var _blend = new Node_Blend(_node.x + _node.w + 64, _node.y, getCurrentContext());
			_blend.inputs[| 0].setFrom(_outp);
			_blend.inputs[| 1].setFrom(_canvas.outputs[| 0]);
		} #endregion
	#endregion
	
	function getCurrentContext() { #region
		if(ds_list_empty(node_context)) return noone;
		return node_context[| ds_list_size(node_context) - 1];
	} #endregion
	
	function getNodeList(cont = getCurrentContext()) { #region
		return cont == noone? project.nodes : cont.getNodeList();
	} #endregion
	
	function onFocusBegin() { #region
		PANEL_GRAPH = self; 
		PROJECT = project;
	} #endregion
	
	function stepBegin() { #region
		var gr_x = graph_x * graph_s;
		var gr_y = graph_y * graph_s;
		var m_x  = (mx - gr_x) / graph_s;
		var m_y  = (my - gr_y) / graph_s;
		mouse_graph_x = m_x;
		mouse_graph_y = m_y;
		
		mouse_grid_x = round(m_x / project.graphGrid.size) * project.graphGrid.size;
		mouse_grid_y = round(m_y / project.graphGrid.size) * project.graphGrid.size;
	} #endregion
	
	function focusNode(_node) { #region
		node_focus = _node;
		if(_node == noone) return;
		
		var cx = node_focus.x + node_focus.w / 2;
		var cy = node_focus.y + node_focus.h / 2;
		
		graph_x = w / 2 / graph_s - cx;
		graph_y = (h - toolbar_height) / 2 / graph_s - cy;
		
		graph_x = round(graph_x);
		graph_y = round(graph_y);
	} #endregion
	
	function fullView() { #region
		if(node_focus == noone) {
			toCenterNode();
			return;
		}
		
		graph_x = -(node_focus.x + node_focus.w / 2) + w / 2 / graph_s;
		graph_y = -(node_focus.y + node_focus.h / 2) + h / 2 / graph_s;
			
		graph_x = round(graph_x);
		graph_y = round(graph_y);
	} #endregion
	
	function dragGraph() { #region
		if(graph_dragging) {
			if(!MOUSE_WRAPPING) {
				var dx = mx - graph_drag_mx; 
				var dy = my - graph_drag_my;
			
				graph_x += dx / graph_s;
				graph_y += dy / graph_s;
			}
				
			graph_drag_mx = mx;
			graph_drag_my = my;
			setMouseWrap();
			
			if(mouse_release(drag_key)) 
				graph_dragging = false;
		}
		
		if(graph_zooming) {
			if(!MOUSE_WRAPPING) {
				var dy = -(my - graph_zoom_m) / 200;
				
				var _s = graph_s;
				
				graph_s_to = clamp(graph_s_to * (1 + dy), scale[0], scale[array_length(scale) - 1]);
				graph_s    = graph_s_to;
				
				if(_s != graph_s) {
					var mb_x = (graph_zoom_mx - graph_x * _s) / _s;
					var ma_x = (graph_zoom_mx - graph_x * graph_s) / graph_s;
					var md_x = ma_x - mb_x;
					graph_x += md_x;
				
					var mb_y = (graph_zoom_my - graph_y * _s) / _s;
					var ma_y = (graph_zoom_my - graph_y * graph_s) / graph_s;
					var md_y = ma_y - mb_y;
					graph_y += md_y;
				}
			}
				
			graph_zoom_m = my;
			setMouseWrap();
			
			if(mouse_release(drag_key)) 
				graph_zooming = false;
		}
		
		if(mouse_on_graph && pFOCUS && graph_draggable) {
			var _doDragging = false;
			var _doZooming  = false;
			
			if(mouse_press(mb_middle)) {
				_doDragging = true;
				drag_key = mb_middle;
			} else if(mouse_press(mb_left) && graph_dragging_key) {
				_doDragging = true;
				drag_key = mb_left;
			} else if(mouse_press(mb_left) && graph_zooming_key) {
				_doZooming = true;
				drag_key = mb_left;
			}
			
			if(_doDragging) {
				graph_dragging = true;	
				graph_drag_mx  = mx;
				graph_drag_my  = my;
				graph_drag_sx  = graph_x;
				graph_drag_sy  = graph_y;
			}
			
			if(_doZooming) {
				graph_zooming  = true;	
				graph_zoom_mx  = mx;
				graph_zoom_my  = my;
				graph_zoom_m   = my;
				graph_zoom_s   = graph_s;
			}
		}
		
		if(mouse_on_graph && pHOVER && graph_draggable) {
			var _s = graph_s;
			if(mouse_wheel_down()) { //zoom out
				for( var i = 1, n = array_length(scale); i < n; i++ ) {
					if(scale[i - 1] < graph_s_to && graph_s_to <= scale[i]) {
						graph_s_to = scale[i - 1];
						break;
					}
				}
			}
			if(mouse_wheel_up()) { // zoom in
				for( var i = 1, n = array_length(scale); i < n; i++ ) {
					if(scale[i - 1] <= graph_s_to && graph_s_to < scale[i]) {
						graph_s_to = scale[i];
						break;
					}
				}
			}
			
			graph_s = lerp_float(graph_s, graph_s_to, PREF_MAP[? "graph_zoom_smoooth"]);
			
			if(_s != graph_s) {
				var mb_x = (mx - graph_x * _s) / _s;
				var ma_x = (mx - graph_x * graph_s) / graph_s;
				var md_x = ma_x - mb_x;
				graph_x += md_x;
				
				var mb_y = (my - graph_y * _s) / _s;
				var ma_y = (my - graph_y * graph_s) / graph_s;
				var md_y = ma_y - mb_y;
				graph_y += md_y;
			}
		}
		
		graph_draggable = true;
		graph_x = round(graph_x);
		graph_y = round(graph_y);
	} #endregion
	
	function drawGrid() { #region
		if(!display_parameter.show_grid) return;
		var gls = project.graphGrid.size;
		if(graph_s <= 0.15) gls *= 10;
		
		var gr_x  = graph_x * graph_s;
		var gr_y  = graph_y * graph_s;
		var gr_ls = gls * graph_s;
		var xx = -gr_ls, xs = safe_mod(gr_x, gr_ls);
		var yy = -gr_ls, ys = safe_mod(gr_y, gr_ls);
		
		draw_set_color(project.graphGrid.color);
		draw_set_alpha(project.graphGrid.opacity * (graph_s >= 1? 1 : 0.5));
		while(xx < w + gr_ls) {
			draw_line(xx + xs, 0, xx + xs, h);
			if(xx + xs - gr_x == 0)
				draw_line_width(xx + xs, 0, xx + xs, h, 3);
			xx += gr_ls;
		}
		
		while(yy < h + gr_ls) {
			draw_line(0, yy + ys, w, yy + ys);
			if(yy + ys - gr_y == 0)
				draw_line_width(0, yy + ys, w, yy + ys, 3);
			yy += gr_ls;
		}
		draw_set_alpha(1);
	} #endregion
	
	function drawNodes() { #region
		if(selection_block-- > 0) return;
		//print("==== DRAW NODES ====");
		display_parameter.highlight = (!ds_list_empty(nodes_select_list) || node_focus != noone) * PREF_MAP[? "connection_line_highlight"];
		
		var gr_x = graph_x * graph_s;
		var gr_y = graph_y * graph_s;
		
		var log = false;
		var t = current_time;
		
		for(var i = 0; i < ds_list_size(nodes_list); i++) {
			nodes_list[| i].cullCheck(gr_x, gr_y, graph_s, -32, -32, w + 32, h + 64);
			nodes_list[| i].preDraw(gr_x, gr_y, graph_s, gr_x, gr_y);
		}
		printIf(log, "Predraw time: " + string(current_time - t)); t = current_time;
		
		#region draw frame
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				if(instanceof(nodes_list[| i]) != "Node_Frame") continue;
				nodes_list[| i].drawNode(gr_x, gr_y, mx, my, graph_s, display_parameter);
			}
		#endregion
		printIf(log, "Frame draw time: " + string(current_time - t)); t = current_time;
		
		#region hover
			node_hovering = noone;
			if(pHOVER)
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				var _node = nodes_list[| i];
				_node.branch_drawing = false;
				if(_node.pointIn(gr_x, gr_y, mx, my, graph_s))
					node_hovering = _node;
			}
			
			if(node_hovering != noone)
				_HOVERING_ELEMENT = node_hovering;
			
			if(node_hovering != noone && pFOCUS && struct_has(node_hovering, "onDoubleClick") && DOUBLE_CLICK) {
				node_hovering.onDoubleClick(self);
				DOUBLE_CLICK = false;
				node_hovering = noone;
			}
			
			if(node_hovering) node_hovering.onDrawHover(gr_x, gr_y, mx, my, graph_s);
		#endregion
		printIf(log, "Hover time: " + string(current_time - t)); t = current_time;
		
		#region selection
			if(mouse_on_graph && pHOVER) {
				if(NODE_DROPPER_TARGET != noone && node_hovering) {
					node_hovering.draw_droppable = true;
					if(mouse_press(mb_left, NODE_DROPPER_TARGET_CAN)) {
						NODE_DROPPER_TARGET.expression += node_hovering.internalName;
						NODE_DROPPER_TARGET.expressionUpdate(); 
					}
				} else if(mouse_press(mb_left, pFOCUS)) {
					if(key_mod_press(SHIFT)) {
						if(ds_list_empty(nodes_select_list) && node_focus) 
							ds_list_add(nodes_select_list, node_focus);
						if(node_focus != node_hovering)
							ds_list_add(nodes_select_list, node_hovering);
					} else {
						var _prevFocus = node_focus;
						if(node_hovering != noone || value_focus == noone)
							node_focus = node_hovering;
					
						if(node_focus) {
							if(instanceof(node_focus) == "Node_Frame") {
								var fx0 = (node_focus.x + graph_x) * graph_s;
								var fy0 = (node_focus.y + graph_y) * graph_s;
								var fx1 = fx0 + node_focus.w * graph_s;
								var fy1 = fy0 + node_focus.h * graph_s;
							
								ds_list_clear(nodes_select_list);
							
								if(!key_mod_press(CTRL))
								for(var i = 0; i < ds_list_size(nodes_list); i++) { //select content
									var _node = nodes_list[| i];
									if(instanceof(_node) == "Node_Frame") continue;
									var _x = (_node.x + graph_x) * graph_s;
									var _y = (_node.y + graph_y) * graph_s;
									var _w = _node.w * graph_s;
									var _h = _node.h * graph_s;
								
									if(rectangle_inside_rectangle(fx0, fy0, fx1, fy1, _x, _y, _x + _w, _y + _h))
										ds_list_add(nodes_select_list, _node);	
								}
								ds_list_add(nodes_select_list, node_focus);	
							} else if(DOUBLE_CLICK) {
								PANEL_PREVIEW.setNodePreview(node_focus);
							} else {
								if(_prevFocus != node_focus)
									bringNodeToFront(node_focus);
					
								var hover_selected = false;	
								for( var i = 0; i < ds_list_size(nodes_select_list); i++ ) {
									if(nodes_select_list[| i] == node_focus) {
										hover_selected = true;
										break;
									}
								}
								if(!hover_selected)
									ds_list_clear(nodes_select_list);
							}
						} else {
							if(value_focus == noone)
								ds_list_clear(nodes_select_list);
						
							if(DOUBLE_CLICK && !PANEL_INSPECTOR.locked)
								PANEL_INSPECTOR.inspecting = noone;
						}
					}
				}
			
				if(mouse_press(mb_right, pFOCUS)) { #region
					node_hover = node_hovering;	
					if(node_hover) {
						var menu = [];
						array_push(menu,  
							menuItem(__txtx("panel_graph_send_to_preview", "Send to preview"), function() {
								setCurrentPreview(node_hover);
							}));
						array_push(menu,  
							menuItem(__txtx("panel_graph_preview_window", "Send to preview window"), function() {
								create_preview_window(node_hover);
							}, noone, ["Graph", "Preview window"]));
						array_push(menu,  
							menuItem(__txtx("panel_graph_inspector_panel", "Send to new inspector"), function() {
								var pan = panelAdd("Panel_Inspector", true);
								pan.destroy_on_click_out = false;
								pan.content.setInspecting(node_hover);
								pan.content.locked     = true;
							}));
						
						if(DEMO) {
							array_push(menu,  
								menuItem(__txtx("panel_graph_send_to_export", "Send to export"), function() {
									setCurrentExport(node_hover);
								}, noone, ["Graph", "Export"]));
						}
					
						array_push(menu,  
							menuItem(__txtx("panel_graph_toggle_preview", "Toggle node preview"), function() {
								setTriggerPreview();
							}, noone, ["Graph", "Toggle preview"]));
						array_push(menu,  
							menuItem(__txtx("panel_graph_toggle_render", "Toggle node render"), function() {
								setTriggerRender();
							}, noone, ["Graph", "Toggle render"]));
					
						if(struct_has(node_hover, "nodes")) {
							array_push(menu, -1);
						
							array_push(menu,  
								menuItem(__txtx("panel_graph_enter_group", "Open group"), function() {
									PANEL_GRAPH.addContext(node_hover);
								}, THEME.group));
							array_push(menu,  
								menuItem(__txtx("panel_graph_enter_group_new_tab", "Open group in new tab"), function() {
									var graph = new Panel_Graph(project);
									panel.setContent(graph, true);
								
									for( var i = 0; i < ds_list_size(node_context); i++ ) 
										graph.addContext(node_context[| i]);
									graph.addContext(node_hover);
								
									setFocus(panel);
								}, THEME.group));
							array_push(menu,  
								menuItem(__txt("Ungroup"), function() { 
									doUngroup();
								}, THEME.group, ["Graph", "Ungroup"]));		
						}
					
						if(node_hover.group != noone) {
							array_push(menu,  
								menuItem(__txt("Set as group tool"), function() { 
									node_hover.setTool(!node_hover.isTool);
								}));		
						}
					
						array_push(menu, -1);
						
						array_push(menu,  
							menuItem(__txtx("panel_graph_delete_and_merge_connection", "Delete and merge connection"), function() {
								doDelete(true);
							}, THEME.cross, ["Graph", "Delete (merge)"]));
						array_push(menu,  
							menuItem(__txtx("panel_graph_delete_and_cut_connection", "Delete and cut connection"), function() {
								doDelete(false);
							}, THEME.cross, ["Graph", "Delete (break)"]));
						array_push(menu,  
							menuItem(__txt("Duplicate"), function() {
								doDuplicate();
							}, THEME.duplicate, ["Graph", "Duplicate"]));
						array_push(menu,  
							menuItem(__txt("Copy"), function() {
								doCopy();
							}, THEME.copy, ["Graph", "Copy"]));
					
						array_push(menu, -1);
						array_push(menu, menuItem(__txtx("panel_graph_add_transform", "Add transform"), doTransform, noone, ["Graph", "Transform node"]));
						array_push(menu, menuItem(__txtx("panel_graph_canvas", "Canvas"),
							function(_dat) { 
								return submenuCall(_dat, [
									menuItem(__txtx("panel_graph_copy_to_canvas", "Copy to canvas"), function() {
										setCurrentCanvas(node_hover);
									}, noone, ["Graph", "Canvas"]),
									menuItem(__txtx("panel_graph_overlay_canvas", "Overlay canvas"), function() {
										setCurrentCanvasBlend(node_hover);
									}, noone, ["Graph", "Canvas blend"])
								]);
							}).setIsShelf()
						);
					
						if(ds_list_size(nodes_select_list) >= 2) {
							array_push(menu, -1);
							array_push(menu, 
								menuItem(__txtx("panel_graph_align_nodes", "Align nodes"), function(_dat) { 
									return submenuCall(_dat, [
										menuItemGroup(__txtx("horizontal", "Horizontal"), [ 
											[ [THEME.inspector_surface_halign, 0], function() { node_halign(nodes_select_list, fa_left); } ],
											[ [THEME.inspector_surface_halign, 1], function() { node_halign(nodes_select_list, fa_center); } ],
											[ [THEME.inspector_surface_halign, 2], function() { node_halign(nodes_select_list, fa_right); } ],
										]),
										menuItemGroup(__txtx("vertical", "Vertical"), [ 
											[ [THEME.inspector_surface_valign, 0], function() { node_valign(nodes_select_list, fa_top); } ],
											[ [THEME.inspector_surface_valign, 1], function() { node_valign(nodes_select_list, fa_middle); } ],
											[ [THEME.inspector_surface_valign, 2], function() { node_valign(nodes_select_list, fa_bottom); } ],
										]),
										menuItemGroup(__txtx("distribute", "Distribute"), [ 
											[ [THEME.obj_distribute_h, 0],		   function() { node_hdistribute(nodes_select_list); } ],
											[ [THEME.obj_distribute_v, 0],		   function() { node_vdistribute(nodes_select_list); } ],
										]),
									]);
								}).setIsShelf());
							array_push(menu,  
								menuItem(__txtx("panel_graph_blend_nodes", "Blend nodes"), function() { 
									doBlend();
								}, noone, ["Graph", "Blend"]));
							array_push(menu,  
								menuItem(__txtx("panel_graph_compose_nodes", "Compose nodes"), function() { 
									doCompose();
								}, noone, ["Graph", "Compose"]));
							array_push(menu,  
								menuItem(__txtx("panel_graph_array_from_nodes", "Array from nodes"), function() { 
									doArray();
								}, noone, ["Graph", "Array"]));
						
							array_push(menu,  
								menuItem(__txtx("panel_graph_group_nodes", "Group nodes"), function() { 
									doGroup();
								}, THEME.group, ["Graph", "Group"]));	
						
							array_push(menu,  
								menuItem(__txtx("panel_graph_frame_nodes", "Frame nodes"), function() { 
									doFrame();
								}, noone, ["Graph", "Frame"]));
						}
					
						menuCall("graph_node_selected_multiple_menu",,, menu );
					} else {
						var menu = [];
					
						array_push(menu,  
							menuItem(__txt("Copy"), function() {
								doCopy();
							}, THEME.copy, ["Graph", "Copy"]).setActive(node_focus != noone || ds_list_size(nodes_select_list))
						);
					
						array_push(menu,  
							menuItem(__txt("Paste"), function() {
								doPaste();
							}, THEME.paste, ["Graph", "Paste"]).setActive(clipboard_get_text() != "")
						);
					
						callAddDialog();
						menuCall("graph_node_selected_menu", o_dialog_add_node.dialog_x - ui(8), o_dialog_add_node.dialog_y + ui(4), menu, fa_right );
						setFocus(o_dialog_add_node.id, "Dialog");
					}
				} #endregion
			}
		#endregion
		printIf(log, "Node selection time: " + string(current_time - t)); t = current_time;
		
		#region draw active
			if(node_focus) node_focus.drawActive(gr_x, gr_y, graph_s);
			
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				var _node = nodes_select_list[| i];
				if(!_node) continue;
				_node.drawActive(gr_x, gr_y, graph_s);
			}
		#endregion
		printIf(log, "Draw active: " + string(current_time - t)); t = current_time;
		
		var aa = PREF_MAP[? "connection_line_aa"];
		connection_surface = surface_verify(connection_surface, w * aa, h * aa);
		surface_set_target(connection_surface);
		DRAW_CLEAR
		
		var hov = noone;
		var hoverable = !bool(node_dragging) && pHOVER;
		
		var _params = {
			x  : gr_x,
			y  : gr_y,
			s  : graph_s,
			mx : mx,
			my : my,
			aa : aa,
			bg : bg_color,
			minx : -64,
			miny : -64,
			maxx : w + 64,
			maxy : h + 64,
			active    : hoverable,
			max_layer : ds_list_size(nodes_list),
			highlight : !ds_list_empty(nodes_select_list) || node_focus != noone,
		};
			
		for(var i = 0; i < ds_list_size(nodes_list); i++) {
			_params.cur_layer = i + 1;
			
			var _hov = nodes_list[| i].drawConnections(_params);
			if(_hov != noone && is_struct(_hov)) hov = _hov;
		}
		printIf(log, "Draw connection: " + string(current_time - t)); t = current_time;
		
		surface_reset_target();
		shader_set(sh_downsample);
		shader_set_f("down", aa);
		shader_set_f("dimension", surface_get_width_safe(connection_surface), surface_get_height_safe(connection_surface));
		draw_surface(connection_surface, 0, 0);
		shader_reset();
		
		junction_hovering = (node_hovering == noone && !is_struct(node_hovering))? hov : noone;
		value_focus = noone;
		
		#region draw node
			var t = current_time;
			for(var i = 0; i < ds_list_size(nodes_list); i++)
				nodes_list[| i].onDrawNodeBehind(gr_x, gr_y, mx, my, graph_s);
			
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				var _node = nodes_list[| i];
				if(instanceof(_node) == "Node_Frame") continue;
				var val = _node.drawNode(gr_x, gr_y, mx, my, graph_s, display_parameter);
				
				if(val) {
					if(key_mod_press(SHIFT))
						TOOLTIP = [ val.getValue(), val.type ];
						
					if(key_mod_press(CTRL) && val.value_from != noone) {
						value_focus = val.value_from;
						if(mouse_press(mb_left))
							val.removeFrom();
					} else
						value_focus = val;
				}
			}
			
			for(var i = 0; i < ds_list_size(nodes_list); i++)
				nodes_list[| i].drawBadge(gr_x, gr_y, graph_s);	
			
			printIf(log, "Draw node: " + string(current_time - t)); t = current_time;
		#endregion
		
		#region dragging
			if(mouse_press(mb_left))
				node_dragging = noone;
				
			if(node_dragging && !key_mod_press(ALT)) {
				node_focus = node_dragging;
				
				if(ds_list_size(nodes_select_list) == 0) { // move single node
					var nx = node_drag_sx + (mouse_graph_x - node_drag_mx);
					var ny = node_drag_sy + (mouse_graph_y - node_drag_my);
					
					if(!key_mod_press(CTRL) && project.graphGrid.snap) {
						nx = round(nx / project.graphGrid.size) * project.graphGrid.size;
						ny = round(ny / project.graphGrid.size) * project.graphGrid.size;
					}
					
					node_dragging.move(nx, ny);
				
					if(mouse_release(mb_left) && (nx != node_drag_sx || ny != node_drag_sy)) {
						recordAction(ACTION_TYPE.var_modify, node_dragging, [ node_drag_sx, "x", "node x position" ]);
						recordAction(ACTION_TYPE.var_modify, node_dragging, [ node_drag_sy, "y", "node y position" ]);
					}
				} else { // move multiple nodes
					var nx = node_drag_sx + (mouse_graph_x - node_drag_mx);
					var ny = node_drag_sy + (mouse_graph_y - node_drag_my);
					
					if(!key_mod_press(CTRL) && project.graphGrid.snap) {
						nx = round(nx / project.graphGrid.size) * project.graphGrid.size;
						ny = round(ny / project.graphGrid.size) * project.graphGrid.size;
					}
					
					if(node_drag_ox == -1 || node_drag_oy == -1) {
						node_drag_ox = nx;
						node_drag_oy = ny;
					} else if(nx != node_drag_ox || ny != node_drag_oy) {
						var dx = nx - node_drag_ox;
						var dy = ny - node_drag_oy;
						
						for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
							var _node = nodes_select_list[| i];
							var _nx = _node.x + dx;
							var _ny = _node.y + dy;
							
							if(!key_mod_press(CTRL) && project.graphGrid.snap) {
								_nx = round(_nx / project.graphGrid.size) * project.graphGrid.size;
								_ny = round(_ny / project.graphGrid.size) * project.graphGrid.size;
							}
							
							_node.move(_nx, _ny);
						}
					
						node_drag_ox = nx;
						node_drag_oy = ny;
					}
					
					if(mouse_release(mb_left) && (nx != node_drag_sx || ny != node_drag_sy)) {
						var shfx = node_drag_sx - nx;
						var shfy = node_drag_sy - ny;
						
						for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
							var _n = nodes_select_list[| i];
							if(_n == noone) continue;
							recordAction(ACTION_TYPE.var_modify, _n, [ _n.x + shfx, "x", "node x position" ]);
							recordAction(ACTION_TYPE.var_modify, _n, [ _n.y + shfy, "y", "node y position" ]);
						}
					}
				}
			}
			printIf(log, "Drag node time : " + string(current_time - t)); t = current_time;
			
			if(mouse_release(mb_left))
				node_dragging = noone;
		#endregion
		
		if(mouse_on_graph && pFOCUS) { #region
			if(node_focus && node_focus.draggable && value_focus == noone) {
				if(mouse_press(mb_left) && !key_mod_press(ALT)) {
					node_dragging = node_focus;
					node_drag_mx  = mouse_graph_x;
					node_drag_my  = mouse_graph_y;
					node_drag_sx  = node_focus.x;
					node_drag_sy  = node_focus.y;
				
					node_drag_ox  = -1;
					node_drag_oy  = -1;
				}
			}
			
			if(DOUBLE_CLICK && junction_hovering != noone) {
				var _mx = round(mouse_graph_x / project.graphGrid.size) * project.graphGrid.size;
				var _my = round(mouse_graph_y / project.graphGrid.size) * project.graphGrid.size;
						
				var _pin = nodeBuild("Node_Pin", _mx, _my);
				_pin.inputs[| 0].setFrom(junction_hovering.value_from);
				junction_hovering.setFrom(_pin.outputs[| 0]);
			}
		} #endregion
		
		#region draw selection frame
			if(nodes_select_drag) {
				if(point_distance(nodes_select_mx, nodes_select_my, mx, my) > 16) {
					draw_sprite_stretched_points(THEME.ui_selection, 0, nodes_select_mx, nodes_select_my, mx, my);
					
					for(var i = 0; i < ds_list_size(nodes_list); i++) {
						var _node = nodes_list[| i];
						if(instanceof(_node) == "Node_Frame") continue;
						var _x = (_node.x + graph_x) * graph_s;
						var _y = (_node.y + graph_y) * graph_s;
						var _w = _node.w * graph_s;
						var _h = _node.h * graph_s;
						
						var _sel = rectangle_in_rectangle(_x, _y, _x + _w, _y + _h, nodes_select_mx, nodes_select_my, mx, my);
						
						if(!ds_list_exist(nodes_select_list, _node) && _sel)
							ds_list_add(nodes_select_list, _node);	
						if(ds_list_exist(nodes_select_list, _node) && !_sel)
							ds_list_remove(nodes_select_list, _node);	
					}
				}
			
				if(mouse_release(mb_left))
					nodes_select_drag = false;
			}
			
			if(nodes_junction_d != noone) {
				var shx = nodes_junction_dx + (mx - nodes_select_mx) / graph_s;
				var shy = nodes_junction_dy + (my - nodes_select_my) / graph_s;
				
				shx = value_snap(shx, key_mod_press(CTRL)? 1 : 4);
				shy = value_snap(shy, key_mod_press(CTRL)? 1 : 4);
				
				nodes_junction_d.draw_line_shift_x = shx;
				nodes_junction_d.draw_line_shift_y = shy;
				
				if(mouse_release(mb_left))
					nodes_junction_d = noone;
			}
		
			if(mouse_on_graph && mouse_press(mb_left, pFOCUS) && !graph_dragging_key && !graph_zooming_key) {
				if(junction_hovering && junction_hovering.draw_line_shift_hover) {
					nodes_select_mx		= mx;
					nodes_select_my		= my;
					nodes_junction_d	= junction_hovering;
					nodes_junction_dx	= junction_hovering.draw_line_shift_x;
					nodes_junction_dy	= junction_hovering.draw_line_shift_y;
				} else if(!node_focus && !value_focus && !drag_locking) {
					nodes_select_drag = true;
					nodes_select_mx = mx;
					nodes_select_my = my;
				}
				drag_locking = false;
			}
		#endregion
		
		printIf(log, "Draw selection frame : " + string(current_time - t)); t = current_time;
	} #endregion
	
	function drawJunctionConnect() { #region
		if(value_dragging) {
			var xx     = value_dragging.x;
			var yy     = value_dragging.y;
			var _mx    = mx;
			var _my    = my;
			var target = noone;
			var _addInput = false;
			
			if(value_focus && value_focus != value_dragging && value_focus.connect_type != value_dragging.connect_type)
				target = value_focus;
			if(key_mod_press(CTRL) && node_hovering != noone) {
				if(value_dragging.connect_type == JUNCTION_CONNECT.input) {
					target = node_hovering.getOutput(value_dragging);
					if(target != noone) 
						node_hovering.active_draw_index = 1;
				} else {
					target = node_hovering.getInput(value_dragging);
					if(target != noone) 
						node_hovering.active_draw_index = 1;
				}
			}
			
			if(key_mod_press(CTRL) && target != noone && target.connect_type == JUNCTION_CONNECT.input && target.node.auto_input)
				_addInput = true;
			
			var _mmx = target != noone? target.x : _mx;
			var _mmy = target != noone? target.y : _my;
			
			if(array_empty(value_draggings))
				value_dragging.drawConnectionMouse(_mmx, _mmy, graph_s, target);
			else {
				var _stIndex = array_find(value_draggings, value_dragging);
				
				for( var i = 0, n = array_length(value_draggings); i < n; i++ ) {
					var _dmx = _mmx;
					var _dmy = _mmy + (i - _stIndex) * 24 * graph_s;
					
					value_draggings[i].drawConnectionMouse(_dmx, _dmy, graph_s, target);
				}
			}
			
			value_dragging.drawJunction(graph_s, value_dragging.x, value_dragging.y);
			if(target) 
				target.drawJunction(graph_s, target.x, target.y);
			
			if(mouse_release(mb_left)) {																		// CONNECT junction
				if(target != noone) {
					if(value_dragging.connect_type == JUNCTION_CONNECT.input)
						value_dragging.setFrom(target);
					else if(!_addInput)
						target.setFrom(value_dragging);
					else { //addInput
						if(array_empty(value_draggings))
							target.node.addInput(value_dragging);
						else {
							for( var i = 0, n = array_length(value_draggings); i < n; i++ )
								target.node.addInput(value_draggings[i]);
						}
					}
				} else {
					if(value_dragging.connect_type == JUNCTION_CONNECT.input)
						value_dragging.removeFrom();
					value_dragging.node.triggerRender();
					
					if(value_focus != value_dragging) {
						with(dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8)) {	
							node_target_x = other.mouse_grid_x;
							node_target_y = other.mouse_grid_y;
							node_called   = other.value_dragging;
							
							alarm[0] = 1;
						}
					}
				}
				
				value_dragging = noone;
			}
		} else if(!value_dragging && value_focus && mouse_press(mb_left, pFOCUS) && !key_mod_press(ALT)) {
			value_dragging  = value_focus;
			value_draggings = [];
			
			if(value_dragging.connect_type == JUNCTION_CONNECT.output) {
				var _jlist = ds_priority_create();
				
				for( var i = 0, n = ds_list_size(nodes_select_list); i < n; i++ ) {
					var _node = nodes_select_list[| i];
				
					for( var j = 0, m = ds_list_size(_node.outputs); j < m; j++ ) {
						var _junction = _node.outputs[| j];
						if(!_junction.visible) continue;
						if(value_bit(_junction.type) & value_bit(value_dragging.type) == 0) continue;
					
						ds_priority_add(_jlist, _junction, _junction.y);
					}
				}
				
				while(!ds_priority_empty(_jlist))
					array_push(value_draggings, ds_priority_delete_min(_jlist));
				
				ds_priority_destroy(_jlist);
			}
		}
		
		#region draw junction name
			var gr_x = graph_x * graph_s;
			var gr_y = graph_y * graph_s;
			for(var i = 0; i < ds_list_size(nodes_list); i++)
				nodes_list[| i].drawJunctionNames(gr_x, gr_y, mx, my, graph_s);	
		#endregion
	} #endregion
	
	function callAddDialog() { #region
		with(dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8)) {	
			node_target_x = other.mouse_grid_x;
			node_target_y = other.mouse_grid_y;
			junction_hovering = other.junction_hovering;
			
			resetPosition();
			alarm[0] = 1;
		}
	} #endregion
	
	function drawContext() { #region
		draw_set_text(f_p0, fa_left, fa_center);
		var xx = ui(16), tt, tw, th;
		var bh  = toolbar_height - ui(12);
		var tbh = h - toolbar_height / 2;
		
		for(var i = -1; i < ds_list_size(node_context); i++) {
			if(i == -1) {
				tt = __txt("Global");
			} else {
				var _cnt = node_context[| i];
				tt = _cnt.display_name == ""? _cnt.name : _cnt.display_name;
			}
			
			tw = string_width(tt);
			th = string_height(tt);
			
			if(i < ds_list_size(node_context) - 1) {
				if(buttonInstant(THEME.button_hide_fill, xx - ui(6), tbh - bh / 2, tw + ui(12), bh, [mx, my], pFOCUS, pHOVER) == 2) {
					node_hover		= noone;
					node_focus		= noone;
					PANEL_PREVIEW.resetNodePreview();
					setContextFrame(true, node_context[| i + 1]);
					
					if(i == -1)
						resetContext();
					else {
						for(var j = ds_list_size(node_context) - 1; j > i; j--)
							ds_list_delete(node_context, j);
						nodes_list = node_context[| i].getNodeList();
						toCenterNode();
						
						var node = getCurrentContext();
						title = node.display_name == ""? node.name : node.display_name;
						break;
					}
				}
				
				draw_sprite_ui_uniform(THEME.arrow, 0, xx + tw + ui(16), tbh, 1, COLORS._main_icon);
			}
			
			draw_set_color(COLORS._main_text);
			draw_set_alpha(i < ds_list_size(node_context) - 1? 0.33 : 1);
			draw_text(xx, tbh - 2, tt);
			draw_set_alpha(1);
			xx += tw;
			xx += ui(32);
		}
	} #endregion
	
	function drawToolBar() { #region
		toolbar_height = ui(40);
		var ty = h - toolbar_height;
		
		if(pHOVER && point_in_rectangle(mx, my, 0, ty, w, h))
			mouse_on_graph = false;
		
		draw_sprite_stretched(THEME.toolbar, 0, 0, ty, w, h);
		drawContext();
		
		var tbx = w - toolbar_height / 2;
		var tby = ty + toolbar_height / 2;
		
		for( var i = 0, n = array_length(toolbars); i < n; i++ ) {
			var tb = toolbars[i];
			var tbSpr = tb[0];
			var tbInd = tb[1]();
			var tbTooltip = tb[2]();
			
			var b = buttonInstant(THEME.button_hide, tbx - ui(14), tby - ui(14), ui(28), ui(28), [mx, my], pFOCUS, pHOVER, tbTooltip, tbSpr, tbInd);
			if(b == 2) tb[3]( { x: x + tbx - ui(14), y: y + tby - ui(14) } );
			
			tbx -= ui(32);
		}
		
		draw_set_color(COLORS.panel_toolbar_separator);
		draw_line_width(tbx + ui(12), tby - toolbar_height / 2 + ui(8), tbx + ui(12), tby + toolbar_height / 2 - ui(8), 2);
	} #endregion
	
	function drawMinimap() { #region
		if(!minimap_show) return;
		var mx1 = w - ui(8);
		var my1 = h - toolbar_height - ui(8);
		var mx0 = mx1 - minimap_w;
		var my0 = my1 - minimap_h;
		
		minimap_w = min(minimap_w, w - ui(16));
		minimap_h = min(minimap_h, h - ui(16) - toolbar_height);
		
		var mini_hover = false;
		if(pHOVER && point_in_rectangle(mx, my, mx0, my0, mx1, my1)) {
			mouse_on_graph = false;
			mini_hover = true;
		}
		
		var hover = mini_hover && !point_in_rectangle(mx, my, mx0, my0, mx0 + ui(16), my0 + ui(16)) && !minimap_dragging;
		
		if(!is_surface(minimap_surface) || surface_get_width_safe(minimap_surface) != minimap_w || surface_get_height_safe(minimap_surface) != minimap_h) {
			minimap_surface = surface_create_valid(minimap_w, minimap_h);
		}
		
		surface_set_target(minimap_surface);
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0.75);
		if(!ds_list_empty(nodes_list)) {
			var minx =  99999;
			var maxx = -99999;
			var miny =  99999;
			var maxy = -99999;
			
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				var _node = nodes_list[| i];
				minx = min(_node.x - 32, minx);
				maxx = max(_node.x + _node.w + 32, maxx);
				
				miny = min(_node.y - 32, miny);
				maxy = max(_node.y + _node.h + 32, maxy);
			}
			
			var cx  = (minx + maxx) / 2;
			var cy  = (miny + maxy) / 2;
			var spw = maxx - minx;
			var sph = maxy - miny;
			var ss  = min(minimap_w / spw, minimap_h / sph);
			
			draw_set_alpha(0.4);
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				var _node = nodes_list[| i];
				
				var nx = minimap_w / 2 + (_node.x - cx) * ss;
				var ny = minimap_h / 2 + (_node.y - cy) * ss;
				var nw = _node.w * ss;
				var nh = _node.h * ss;
				
				draw_set_color(_node.color);
				draw_roundrect_ext(nx, ny, nx + nw, ny + nh, THEME_VALUE.minimap_corner_radius, THEME_VALUE.minimap_corner_radius, false);
			}
			draw_set_alpha(1);
			
			var gx = minimap_w / 2 - (graph_x + cx) * ss;
			var gy = minimap_h / 2 - (graph_y + cy) * ss;
			var gw = w / graph_s * ss;
			var gh = h / graph_s * ss;
			
			draw_set_color(COLORS.panel_graph_minimap_focus);
			draw_rectangle(gx, gy, gx + gw, gy + gh, 1);
			
			if(minimap_panning) {
				graph_x = -((mx - mx0 - gw / 2) - minimap_w / 2) / ss - cx;
				graph_y = -((my - my0 - gh / 2) - minimap_h / 2) / ss - cy;
				
				graph_x = round(graph_x);
				graph_y = round(graph_y);
				
				if(mouse_release(mb_left))
					minimap_panning = false;
			}
			
			if(mouse_click(mb_left, hover))
				minimap_panning = true;
		}
		surface_reset_target();
		
		draw_surface_ext_safe(minimap_surface, mx0, my0, 1, 1, 0, c_white, 0.5 + 0.35 * hover);
		draw_set_color(COLORS.panel_graph_minimap_outline);
		draw_rectangle(mx0, my0, mx1 - 1, my1 - 1, true);
		
		if(minimap_dragging) {
			mouse_on_graph = false;
			var sw = minimap_drag_sx + minimap_drag_mx - mx;
			var sh = minimap_drag_sy + minimap_drag_my - my;
			
			minimap_w = max(ui(64), sw);
			minimap_h = max(ui(64), sh);
			
			if(mouse_release(mb_left))
				minimap_dragging = false;
		}
		
		if(pHOVER && point_in_rectangle(mx, my, mx0, my0, mx0 + ui(16), my0 + ui(16))) {
			draw_sprite_ui(THEME.node_resize, 0, mx0 + ui(2), my0 + ui(2), 0.5, 0.5, 180, c_white, 0.75);
			if(mouse_press(mb_left, pFOCUS)) {
				minimap_dragging = true;
				minimap_drag_sx = minimap_w;
				minimap_drag_sy = minimap_h;
				minimap_drag_mx = mx;
				minimap_drag_my = my;
			}
		} else 
			draw_sprite_ui(THEME.node_resize, 0, mx0 + ui(2), my0 + ui(2), 0.5, 0.5, 180, c_white, 0.3);
	} #endregion
	
	function drawContextFrame() { #region
		if(!context_framing) return;
		context_frame_progress = lerp_float(context_frame_progress, 1, 5);
		if(context_frame_progress == 1) 
			context_framing = false;
		
		var _fr_x0 = 0, _fr_y0 = 0;
		var _fr_x1 = w, _fr_y1 = h;
		
		var _to_x0 = context_frame_sx;
		var _to_y0 = context_frame_sy;
		var _to_x1 = context_frame_ex;
		var _to_y1 = context_frame_ey;
		
		var prog = context_frame_direct? context_frame_progress : 1 - context_frame_progress;
		var frm_x0 = lerp(_fr_x0, _to_x0, prog);
		var frm_y0 = lerp(_fr_y0, _to_y0, prog);
		var frm_x1 = lerp(_fr_x1, _to_x1, prog);
		var frm_y1 = lerp(_fr_y1, _to_y1, prog);
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_roundrect_ext(frm_x0, frm_y0, frm_x1, frm_y1, THEME_VALUE.panel_corner_radius, THEME_VALUE.panel_corner_radius, true);
		draw_set_alpha(1);
	} #endregion
	
	function resetContext() { #region
		ds_list_clear(node_context);
		title = __txt("Graph");
		nodes_list = project.nodes;
		toCenterNode();
	} #endregion
	
	function addContext(node) { #region
		title = node.display_name == ""? node.name : node.display_name;
		
		var _node = node.getNodeBase();
		setContextFrame(false, _node);
		
		nodes_list = _node.nodes;
		ds_list_add(node_context, _node);
		
		node_dragging = noone;
		ds_list_clear(nodes_select_list);
		selection_block = 1;
		
		toCenterNode();
	} #endregion
	
	function setContextFrame(dirr, node) { #region
		context_framing = true;
		context_frame_direct   = dirr;
		context_frame_progress = 0;
		context_frame_sx = w / 2 - 8;
		context_frame_sy = h / 2 - 8;
		context_frame_ex = context_frame_sx + 16;
		context_frame_ey = context_frame_sy + 16;
	} #endregion
	
	function drawContent(panel) { #region					>>>>>>>>>>>>>>>>>>>> MAIN DRAW <<<<<<<<<<<<<<<<<<<<
		if(!project.active) return;
		if(project.path == "")	title = "New project";
		else					title = filename_name_only(project.path);
		title += project.modified? "*" : "";
		
		dragGraph();
		
		var context = getCurrentContext();
		bg_color = context == noone? COLORS.panel_bg_clear : merge_color(COLORS.panel_bg_clear, context.color, 0.05);
		draw_clear(bg_color);
		drawGrid();
		
		draw_set_text(f_p0, fa_right, fa_top, COLORS._main_text_sub);
		draw_text(w - ui(8), ui(8), $"x{graph_s_to}");
		
		drawNodes();
		drawJunctionConnect();
		drawContextFrame();
		
		mouse_on_graph = true;
		drawToolBar();
		drawMinimap();
		
		if(pFOCUS && node_focus) node_focus.focusStep();
		
		if(UPDATE == RENDER_TYPE.full)
			draw_text(w - ui(8), ui(28), __txtx("panel_graph_rendering", "Rendering") + "...");
		else if(UPDATE == RENDER_TYPE.partial)
			draw_text(w - ui(8), ui(28), __txtx("panel_graph_rendering_partial", "Rendering partial") + "...");
		
		if(DRAGGING && pHOVER) { #region file dropping
			if(node_hovering && node_hovering.droppable(DRAGGING)) {
				node_hovering.draw_droppable = true;
				if(mouse_release(mb_left))
					node_hovering.onDrop(DRAGGING);
			} else {
				draw_sprite_stretched_ext(THEME.ui_panel_active, 0, 2, 2, w - 4, h - 4, COLORS._main_value_positive, 1);	
				if(mouse_release(mb_left))
					checkDropItem();
			}
		} #endregion
		
		graph_dragging_key = false;
		graph_zooming_key  = false;
	} #endregion
	
	#region ++++ node manipulation ++++
		function doTransform() { #region
			if(ds_list_empty(nodes_select_list)) {
				if(node_focus != noone && !ds_list_empty(node_focus.outputs)) {
					var _o = node_focus.outputs[| 0];
					if(_o.type == VALUE_TYPE.surface || _o.type == VALUE_TYPE.dynaSurface) {
						var tr = nodeBuild("Node_Transform", node_focus.x + node_focus.w + 64, node_focus.y);
						tr.inputs[| 0].setFrom(_o);
					}
				}
			} else {
				for( var i = 0; i < ds_list_size(nodes_select_list); i++ ) {	
					var node = nodes_select_list[| i];
					if(ds_list_empty(node.outputs)) continue;
				
					var _o = node.outputs[| 0];
					if(_o.type == VALUE_TYPE.surface || _o.type == VALUE_TYPE.dynaSurface) {
						var tr = nodeBuild("Node_Transform", node.x + node.w + 64, node.y);
						tr.inputs[| 0].setFrom(_o);
					}
				}
			}
		} #endregion
	
		function doDuplicate() { #region
			var nodeArray = [];
			if(ds_list_empty(nodes_select_list)) {
				if(node_focus == noone) return;
				nodeArray = [node_focus];
			} else {
				for(var i = 0; i < ds_list_size(nodes_select_list); i++)
					nodeArray[i] = nodes_select_list[| i];
			}
		
			var _map  = {};
			var _node = [];
			for(var i = 0; i < array_length(nodeArray); i++)
				SAVE_NODE(_node, nodeArray[i],,,, getCurrentContext());
			_map.nodes = _node;
		
			APPENDING = true;
			CLONING	  = true;
			var _app = __APPEND_MAP(_map);
			APPENDING = false;
			CLONING	  = false;
		
			if(ds_list_size(_app) == 0) {
				ds_list_destroy(_app);
				return;
			}
			
			var x0 = 99999999;
			var y0 = 99999999;
			for(var i = 0; i < ds_list_size(_app); i++) {
				var _node = _app[| i];
				
				x0 = min(x0, _node.x);
				y0 = min(y0, _node.y);
			}
		
			node_dragging = _app[| 0];
			node_drag_mx  = x0; node_drag_my  = y0;
			node_drag_sx  = x0; node_drag_sy  = y0;
			node_drag_ox  = x0; node_drag_oy  = y0;
			
			ds_list_destroy(nodes_select_list);
			nodes_select_list = _app;
		} #endregion

		function doInstance() { #region
			if(node_focus == noone) return;
			if(!struct_has(node_focus, "nodes")) return;
		
			if(node_focus.instanceBase == noone) {
				node_focus.isInstancer = true;
			
				CLONING = true;
				var _type = instanceof(node_focus);
				var _node = nodeBuild(_type, x, y);
				CLONING = false;
			
				_node.setInstance(node_focus);
			}
		
			var _nodeNew  = _node.clone();
		
			node_dragging = _nodeNew;
			node_drag_mx  = _nodeNew.x; node_drag_my  = _nodeNew.y;
			node_drag_sx  = _nodeNew.x; node_drag_sy  = _nodeNew.y;
			node_drag_ox  = _nodeNew.x; node_drag_oy  = _nodeNew.y;
		} #endregion
	
		function doCopy() { #region
			clipboard_set_text("");
		
			var nodeArray = [];
			if(ds_list_empty(nodes_select_list)) {
				if(node_focus == noone) return;
				nodeArray = [node_focus];
			} else {
				for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
					var _node = nodes_select_list[| i];
					nodeArray[i] = _node;
				}
			}
		
			var _map  = {};
			var _node = [];
			for(var i = 0; i < array_length(nodeArray); i++)
				SAVE_NODE(_node, nodeArray[i],,,, getCurrentContext());
			_map.nodes = _node;
		
			clipboard_set_text(json_stringify_minify(_map));
		} #endregion
	
		function doPaste() { #region
			var txt  = clipboard_get_text();
			var _map = json_try_parse(txt, noone);
			
			if(txt == "") return;
			
			if(is_struct(_map)) {
				ds_map_clear(APPEND_MAP);
				APPENDING = true;
				CLONING	  = true;
				var _app  = __APPEND_MAP(_map);
				APPENDING = false;
				CLONING	  = false;
			
				if(_app == noone) 
					return;
			
				if(ds_list_size(_app) == 0) {
					ds_list_destroy(_app);
					return;
				}
			
				var x0 = 99999999;
				var y0 = 99999999;
				for(var i = 0; i < ds_list_size(_app); i++) {
					var _node = _app[| i];
				
					x0 = min(x0, _node.x);
					y0 = min(y0, _node.y);
				}
		
				node_dragging = _app[| 0];
				node_drag_mx  = x0; node_drag_my  = y0;
				node_drag_sx  = x0; node_drag_sy  = y0;
				node_drag_ox  = x0; node_drag_oy  = y0;
			
				ds_list_destroy(nodes_select_list);
				nodes_select_list = _app;
				return;
			}
		
			if(filename_ext(txt) == ".pxc")
				APPEND(txt);
			else if(filename_ext(txt) == ".pxcc")
				APPEND(txt);
			else if(filename_ext(txt) == ".png") {
				if(file_exists(txt)) {
					Node_create_Image_path(0, 0, txt);
					return;
				}
		
				var path = DIRECTORY + "temp/url_pasted_" + string(irandom_range(100000, 999999)) + ".png";
				var img = http_get_file(txt, path);
				CLONING = true;
				var node = Node_create_Image(0, 0);
				CLONING = false;
				var args = [node, path];
		
				global.FILE_LOAD_ASYNC[? img] = [ function(args) {
					args[0].inputs[| 0].setValue(args[1]);
					args[0].doUpdate();
				}, args];
			}
		} #endregion
	
		function doBlend() { #region
			if(ds_list_empty(nodes_select_list)) return;
			if(ds_list_size(nodes_select_list) != 2) return;
		
			var cx = nodes_select_list[| 0].x;
			var cy = 0;
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				var _node = nodes_select_list[| i];
				cx = max(cx, _node.x);
				cy += _node.y;
			}
			cx = cx + 160;
			cy = round(cy / ds_list_size(nodes_select_list) / 32) * 32;
		
			var _blend = new Node_Blend(cx, cy, getCurrentContext());
			var index = 0;
			for( var i = 0; i < ds_list_size(nodes_select_list); i++ ) {
				var _node = nodes_select_list[| i];
				if(ds_list_size(_node.outputs) == 0) continue;
				if(_node.outputs[| 0].type == VALUE_TYPE.surface) {
					_blend.inputs[| index].setFrom(_node.outputs[| 0]);
					index++;
				}
			}
			
			ds_list_clear(nodes_select_list);
		} #endregion
	
		function doCompose() { #region
			if(ds_list_empty(nodes_select_list)) return;
		
			var cx = nodes_select_list[| 0].x;
			var cy = 0;
		
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				var _node = nodes_select_list[| i];
				cx = max(cx, _node.x);
				cy += _node.y;
			}
			cx = cx + 160;
			cy = round(cy / ds_list_size(nodes_select_list) / 32) * 32;
		
			var _compose = nodeBuild("Node_Composite", cx, cy);
		
			for( var i = 0; i < ds_list_size(nodes_select_list); i++ ) {
				var _node = nodes_select_list[| i];
				if(ds_list_size(_node.outputs) == 0) continue;
				if(_node.outputs[| 0].type == VALUE_TYPE.surface) {
					_compose.addInput(_node.outputs[| 0]);
				}
			}
			
			ds_list_clear(nodes_select_list);
		} #endregion
	
		function doArray() { #region
			if(ds_list_empty(nodes_select_list)) return;
		
			var cx = nodes_select_list[| 0].x;
			var cy = 0;
		
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				var _node = nodes_select_list[| i];
				cx = max(cx, _node.x);
				cy += _node.y;
			}
			cx = cx + 160;
			cy = round(cy / ds_list_size(nodes_select_list) / 32) * 32;
		
			var _array = nodeBuild("Node_Array", cx, cy);
		
			for( var i = 0; i < ds_list_size(nodes_select_list); i++ ) {
				var _node = nodes_select_list[| i];
				if(ds_list_size(_node.outputs) == 0) continue;
				_array.addInput(_node.outputs[| 0]);
			}
			
			ds_list_clear(nodes_select_list);
		} #endregion
	
		function doGroup() { #region
			if(ds_list_empty(nodes_select_list) && node_focus != noone)
				ds_list_add(nodes_select_list, node_focus);
			node_focus = noone;
		
			if(ds_list_empty(nodes_select_list)) return;
		
			groupNodes(array_create_from_list(nodes_select_list));
		} #endregion
	
		function doUngroup() { #region
			if(node_focus == noone) return;
			if(!variable_struct_exists(node_focus, "nodes")) return;
			if(!node_focus.ungroupable) return;
		
			upgroupNode(node_focus);
		} #endregion
	
		function doLoop() { #region
			if(ds_list_empty(nodes_select_list) && node_focus != noone)
				ds_list_add(nodes_select_list, node_focus);
		
			if(ds_list_empty(nodes_select_list)) return;
		
			var cx = 0;
			var cy = 0;
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				var _node = nodes_select_list[| i];
				cx += _node.x;
				cy += _node.y;
			}
			cx = round(cx / ds_list_size(nodes_select_list) / 32) * 32;
			cy = round(cy / ds_list_size(nodes_select_list) / 32) * 32;
		
			var _group = new Node_Iterate(cx, cy, getCurrentContext());
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				_group.add(nodes_select_list[| i]);
			}
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				nodes_select_list[| i].checkConnectGroup("loop");
			}
			
			ds_list_clear(nodes_select_list);
		} #endregion
	
		function doFrame() { #region
			var x0 = 999999, y0 = 999999, x1 = -999999, y1 = -999999;
		
			if(ds_list_empty(nodes_select_list)) {
				if(node_focus != noone) {
					x0 = node_focus.x;
					y0 = node_focus.y;
					x1 = node_focus.x + node_focus.w;
					y1 = node_focus.y + node_focus.h;
				} else
					return;	
			} else {
				for( var i = 0; i < ds_list_size(nodes_select_list); i++ )  {
					var _node = nodes_select_list[| i];
					x0 = min(x0, _node.x);
					y0 = min(y0, _node.y);
					x1 = max(x1, _node.x + _node.w);
					y1 = max(y1, _node.y + _node.h);
				}
			}
		
			x0 -= 64;
			y0 -= 64;
			x1 += 64;
			y1 += 64;
		
			var f = new Node_Frame(x0, y0, getCurrentContext());
			f.inputs[| 0].setValue([x1 - x0, y1 - y0]);
		} #endregion
	
		function doDelete(_merge = false) { #region
			if(node_focus != noone && node_focus.manual_deletable)
				nodeDelete(node_focus, _merge);
		
			for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
				if(nodes_select_list[| i].manual_deletable)
					nodeDelete(nodes_select_list[| i], _merge);
			}
			ds_list_clear(nodes_select_list);
		} #endregion
	#endregion
	
	function dropFile(path) { #region
		if(node_hovering && is_callable(node_hovering.on_drop_file))
			return node_hovering.on_drop_file(path);
		return false;
	} #endregion
	
	static checkDropItem = function() { #region
		var node = noone;
		
		switch(DRAGGING.type) {
			case "Color":
				node = nodeBuild("Node_Color", mouse_grid_x, mouse_grid_y, getCurrentContext());
				node.inputs[| 0].setValue(DRAGGING.data);
				break;
			case "Palette":
				node = nodeBuild("Node_Palette", mouse_grid_x, mouse_grid_y, getCurrentContext());
				node.inputs[| 0].setValue(DRAGGING.data);
				break;
			case "Gradient":
				node = nodeBuild("Node_Gradient_Out", mouse_grid_x, mouse_grid_y, getCurrentContext());
				node.inputs[| 0].setValue(DRAGGING.data);
				break;
			
			case "Number":
				if(is_array(DRAGGING.data) && array_length(DRAGGING.data) <= 4) {
					switch(array_length(DRAGGING.data)) {
						case 2 : node = nodeBuild("Node_Vector2", mouse_grid_x, mouse_grid_y, getCurrentContext()); break;
						case 3 : node = nodeBuild("Node_Vector3", mouse_grid_x, mouse_grid_y, getCurrentContext()); break;
						case 4 : node = nodeBuild("Node_Vector4", mouse_grid_x, mouse_grid_y, getCurrentContext()); break;
					}
					
					for( var i = 0, n = array_length(DRAGGING.data); i < n; i++ )
						node.inputs[| i].setValue(DRAGGING.data[i]);
				} else {
					node = nodeBuild("Node_Number", mouse_grid_x, mouse_grid_y, getCurrentContext());
					node.inputs[| 0].setValue(DRAGGING.data);
				}
				break;
			case "Bool":
				node = nodeBuild("Node_Boolean", mouse_grid_x, mouse_grid_y, getCurrentContext());
				node.inputs[| 0].setValue(DRAGGING.data);
				break;
			case "Text":
				node = nodeBuild("Node_String", mouse_grid_x, mouse_grid_y, getCurrentContext());
				node.inputs[| 0].setValue(DRAGGING.data);
				break;
			case "Path":
				node = nodeBuild("Node_Path", mouse_grid_x, mouse_grid_y, getCurrentContext());
				break;
			case "Struct":
				node = nodeBuild("Node_Struct", mouse_grid_x, mouse_grid_y, getCurrentContext());
				break;
				
			case "Asset":
				var app = Node_create_Image_path(mouse_grid_x, mouse_grid_y, DRAGGING.data.path);
				break;
			case "Collection":
				var path = DRAGGING.data.path;
				ds_list_clear(nodes_select_list);
				
				var app = APPEND(DRAGGING.data.path, getCurrentContext());
			
				if(!is_struct(app) && ds_exists(app, ds_type_list)) {
					var cx = 0;
					var cy = 0;
					
					for( var i = 0; i < ds_list_size(app); i++ ) {
						cx += app[| i].x;
						cy += app[| i].y;
					}
					
					cx /= ds_list_size(app);
					cy /= ds_list_size(app);
					
					for( var i = 0; i < ds_list_size(app); i++ ) {
						app[| i].x = app[| i].x - cx + mouse_grid_x;
						app[| i].y = app[| i].y - cy + mouse_grid_y;
					}
					
					ds_list_destroy(app);
				} else {
					app.x = mouse_grid_x;
					app.y = mouse_grid_y;
				}
				break;
		}
			
		if(!key_mod_press(SHIFT) && node && struct_has(DRAGGING, "from") && DRAGGING.from.value_from == noone) {
			for( var i = 0; i < ds_list_size(node.outputs); i++ )
				if(DRAGGING.from.setFrom(node.outputs[| i])) break;
		}
	} #endregion
	
	static bringNodeToFront = function(node) { #region
		if(!ds_list_exist(nodes_list, node)) return;
		
		ds_list_remove(nodes_list, node);
		ds_list_add(nodes_list, node);
	} #endregion
	
	function close() {  #region
		var panels = findPanels("Panel_Graph");
		for( var i = 0, n = array_length(panels); i < n; i++ ) {
			if(panels[i] == self) continue;
			if(panels[i].project == project) {
				panel.remove(self);
				return;
			}
		}
		
		if(!project.modified || project.readonly) {
			closeProject(project);
			return;
		}
		
		var dia = dialogCall(o_dialog_save);
		dia.project = project;
	} #endregion
}