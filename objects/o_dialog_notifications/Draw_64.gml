/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
		
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(56), dialog_y + ui(20), __txt("Notifications"));
	
	var bx = dialog_x + ui(24);
	var by = dialog_y + ui(18);
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, destroy_on_click_out? __txt("Pin") : __txt("Unpin"), 
		THEME.pin, !destroy_on_click_out, destroy_on_click_out? COLORS._main_icon : COLORS._main_icon_light) == 2)
			destroy_on_click_out = !destroy_on_click_out;
#endregion

#region text
	var ww = ui(28);
	var hh = ui(28);
	var bx = dialog_x + dialog_w - ui(padding - 8) - ww;
	var by = dialog_y + ui(18);
	
	var error = !!(filter & NOTI_TYPE.error);
	var toolt = error? __txtx("noti_hide_error", "Hide error") : __txtx("noti_show_error", "Show error");
	var b = buttonInstant(THEME.button_hide, bx, by, ww, hh, mouse_ui, sFOCUS, sHOVER, toolt, THEME.noti_icon_error, error, c_white, 0.3 + error * 0.7);
	if(b == 2) filter = filter ^ NOTI_TYPE.error;
	if(b == 3) menuCall("notification_error_menu",,, rightClickMenu);
	bx -= ui(36);
	
	var warn = !!(filter & NOTI_TYPE.warning);
	var toolt = warn? __txtx("noti_hide_warning", "Hide warning") : __txtx("noti_show_warning", "Show warning");
	var b = buttonInstant(THEME.button_hide, bx, by, ww, hh, mouse_ui, sFOCUS, sHOVER, toolt, THEME.noti_icon_warning, warn, c_white, 0.3 + warn * 0.7);
	if(b == 2) filter = filter ^ NOTI_TYPE.warning;
	if(b == 3) menuCall("notification_warning_menu",,, rightClickMenu);
	bx -= ui(36);
	
	var log = !!(filter & NOTI_TYPE.log);
	var toolt = log? __txtx("noti_hide_log", "Hide log") : __txtx("noti_show_log", "Show log");
	var b = buttonInstant(THEME.button_hide, bx, by, ww, hh, mouse_ui, sFOCUS, sHOVER, toolt, THEME.noti_icon_log, log, c_white, 0.3 + log * 0.7);
	if(b == 2) filter = filter ^ NOTI_TYPE.log;
	if(b == 3) menuCall("notification_log_menu",,, rightClickMenu);
	
	var px = dialog_x + ui(padding);
	var py = dialog_y + ui(title_height);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(title_height + padding);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	sp_noti.setFocusHover(sFOCUS, sHOVER);
	sp_noti.draw(px, py);
#endregion