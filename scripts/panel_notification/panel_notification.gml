function Panel_Notification() : PanelContent() constructor {
	title = get_text("noti_title", "Notification");
	w = ui(720);
	h = ui(480);
	
	title_height = 64;
	padding = 24;
	
	current_page = 0;
	filter = NOTI_TYPE.log | NOTI_TYPE.warning | NOTI_TYPE.error;
	showHeader  = false;
	
	rightClickMenu = [ 
		menuItem(get_text("noti_clear_log", "Clear log messages"), function() { 
			for( var i = ds_list_size(STATUSES) - 1; i >= 0; i-- ) {
				if(STATUSES[| i].type == NOTI_TYPE.log) 
					ds_list_delete(STATUSES, i);
			}
		}), 
		menuItem(get_text("noti_clear_warn", "Clear warning messages"), function() { 
			for( var i = ds_list_size(STATUSES) - 1; i >= 0; i-- ) {
				if(STATUSES[| i].type == NOTI_TYPE.warning) 
					ds_list_delete(STATUSES, i);
			}
		}),
		-1,
		menuItem(get_text("noti_clear_all", "Clear all notifications"), function() { 
			ds_list_clear(STATUSES);
		}),
		-1,
		menuItem(get_text("noti_open_log", "Open log file"), function() { 
			shellOpenExplorer(DIRECTORY + "log.txt");
		}),
	];
	
	function onResize() {
		PANEL_PADDING
		
		sp_noti.resize(w - ui(padding + padding), h - ui(title_height + padding));
	}
	
	sp_noti = new scrollPane(w - ui(padding + padding), h - ui(title_height + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hh = 32;
		var yy = _y;
		var txw = sp_noti.surface_w - ui(48 + 48 + 20);
		var amo = ds_list_size(STATUSES);
		
		draw_set_font(f_p3);
		var timeW = string_width("00:00:00");
		
		for( var i = 0; i < ds_list_size(STATUSES); i++ ) {
			var index = amo - 1 - i;
			var noti = STATUSES[| index];
			if(noti.type & filter == 0) continue;
			
			draw_set_font(f_p2);
			var _w = sp_noti.surface_w;
			var _h = ui(8) + string_height_ext(noti.txt, -1, txw) + ui(8);
			
			if(yy >= -_h && yy <= sp_noti.h) {
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy + ui(2), _w, _h - ui(4), COLORS.dialog_notification_bg, 1);
			
				if(pHOVER && pHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, _w, yy + _h - ui(4))) {
					draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy + ui(2), _w, _h - ui(4), COLORS.dialog_notification_bg_hover, 1);
					
					if(noti.tooltip != "")
						TOOLTIP = noti.tooltip;
				
					if(noti.onClick != noone && mouse_press(mb_left, pFOCUS))
						noti.onClick();
				
					if(mouse_press(mb_right, pFOCUS)) {
						var dia = menuCall(,, [ 
							menuItem(get_text("noti_copy_message", "Copy notification message"), function() { 
								clipboard_set_text(o_dialog_menubox.noti.txt);
							}), 
							menuItem(get_text("noti_delete_message", "Delete notification"), function() { 
								ds_list_remove(STATUSES, o_dialog_menubox.noti);
							}), 
						]);
						dia.noti = noti;
					}
				}
			
				if(noti.life_max > 0) {
					var _nwx = sp_noti.w - ui(12) - ui(40);
					var _nw  = _nwx * noti.life / noti.life_max;
				
					draw_sprite_stretched_ext(THEME.group_label, 0, ui(40), yy + ui(2), _nw, _h - ui(4), COLORS.dialog_notification_icon_bg, 1);
				}
			
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy + ui(2), ui(48), _h - ui(4), noti.color, 1);
			
				if(noti.icon_end != noone)
					draw_sprite_ui(noti.icon_end, 1, _w - ui(24), yy + _h / 2,,,, COLORS._main_icon);
			
				var ic = noti.icon;
				if(noti.icon == noone) {
					switch(noti.type) {
						case NOTI_TYPE.log :	 ic = THEME.noti_icon_log; break;	
						case NOTI_TYPE.warning : ic = THEME.noti_icon_warning; break;	
						case NOTI_TYPE.error :	 ic = THEME.noti_icon_error; break;	
					}
				}
			
				draw_sprite_ui(ic, 1, ui(24), yy + _h / 2);
			
				var tx = ui(48) + timeW + ui(12);
			
				draw_set_text(f_p3, fa_right, fa_center, COLORS._main_text_sub);
				draw_text_ext(tx - ui(4), yy + _h / 2, noti.time, -1, txw);
			
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_ext(tx + ui(4), yy + _h / 2, noti.txt, -1, txw);
				
				if(noti.amount > 1) {
					draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
					var bw = max( ui(32), string_width(noti.amount) + ui(10) );
					var bh = ui(28);
					
					var bx = _w - ui(0) - bw;
					var by = yy + ui(0) + ui(2);
					
					draw_sprite_stretched_ext(THEME.group_label, 0, bx, by, bw, bh, COLORS._main_icon_dark, 0.75);
					
					draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_accent);
					draw_text(bx + bw / 2, by + bh / 2, noti.amount);
				}
			}
			
			yy += _h;
			hh += _h;
		}
		
		return hh;
	});
	
	function drawContent(panel) { 
		PANEL_PADDING
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_title);
		draw_text_over(in_dialog? ui(56) : ui(24), title_height / 2, title);
		
		var ww = ui(28);
		var hh = ui(28);
		var bx = w - ui(in_dialog? padding - 8 : padding) - ww;
		var by = title_height / 2 - ui(14);
	
		var error = !!(filter & NOTI_TYPE.error);
		var toolt = error? get_text("noti_hide_error", "Hide error") : get_text("noti_show_error", "Show error");
		var b = buttonInstant(THEME.button_hide, bx, by, ww, hh, [mx, my], pFOCUS, pHOVER, toolt, THEME.noti_icon_error, error, c_white, 0.75 + error * 0.25);
		if(b == 2) filter = filter ^ NOTI_TYPE.error;
		if(b == 3) menuCall(,, rightClickMenu);
		bx -= ui(36);
	
		var warn = !!(filter & NOTI_TYPE.warning);
		var toolt = warn? get_text("noti_hide_warning", "Hide warning") : get_text("noti_show_warning", "Show warning");
		var b = buttonInstant(THEME.button_hide, bx, by, ww, hh, [mx, my], pFOCUS, pHOVER, toolt, THEME.noti_icon_warning, warn, c_white, 0.75 + warn * 0.25);
		if(b == 2) filter = filter ^ NOTI_TYPE.warning;
		if(b == 3) menuCall(,, rightClickMenu);
		bx -= ui(36);
	
		var log = !!(filter & NOTI_TYPE.log);
		var toolt = log? get_text("noti_hide_log", "Hide log") : get_text("noti_show_log", "Show log");
		var b = buttonInstant(THEME.button_hide, bx, by, ww, hh, [mx, my], pFOCUS, pHOVER, toolt, THEME.noti_icon_log, log, c_white, 0.75 + log * 0.25);
		if(b == 2) filter = filter ^ NOTI_TYPE.log;
		if(b == 3) menuCall(,, rightClickMenu);
	
		var px = ui(padding);
		var py = ui(title_height);
		var pw = w - ui(padding + padding);
		var ph = h - ui(title_height + padding);
	
		draw_sprite_stretched(THEME.ui_panel_bg, !in_dialog, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sp_noti.setActiveFocus(pHOVER, pHOVER);
		sp_noti.draw(px, py, mx - px, my - py);
	}
}