function draw_line_round(x1, y1, x2, y2, w, stCap = true, edCap = true, sample = 8) {
	draw_line_width(x1, y1, x2, y2, w);
	
	draw_set_circle_precision(8);
	
	var dir = point_direction(x1, y1, x2, y2) + 90;
	if(stCap) {
		draw_circle(x1, y1, w/2, false);
		//draw_circle_angle(x1 + 1, y1 + 1, w / 2, dir, dir + 90, sample / 2);
		//draw_circle_angle(x1 + 1, y1 + 1, w / 2, dir + 90, dir + 180, sample / 2);
	}
	
	if(edCap) {
		draw_circle(x2, y2, w/2, false);
		//draw_circle_angle(x2 + 1, y2 + 1, w / 2, dir, dir - 90, sample / 2);
		//draw_circle_angle(x2 + 1, y2 + 1, w / 2, dir - 90, dir - 180, 4, sample / 2);
	}
}

function draw_line_round_color(x1, y1, x2, y2, w, c1, c2, stCap = true, edCap = true) {
	draw_line_width_color(x1, y1, x2, y2, w, c1, c2);
	
	draw_set_circle_precision(8);
	if(stCap) {
		draw_set_color(c1);
		draw_circle(x1, y1, w/2, false);
	}
	
	if(edCap) {
		draw_set_color(c2);
		draw_circle(x2, y2, w/2, false);
	}
}

function draw_line_round_arrow(x1, y1, x2, y2, w, as = 4) {
	draw_line_round(x1, y1, x2, y2, w);
	
	var a = point_direction(x1, y1, x2, y2);
	draw_triangle(x2 + lengthdir_x(as * w, a + 120 * 0), y2 + lengthdir_y(as * w, a + 120 * 0), 
				  x2 + lengthdir_x(as * w, a + 120 * 1), y2 + lengthdir_y(as * w, a + 120 * 1), 
				  x2 + lengthdir_x(as * w, a + 120 * 2), y2 + lengthdir_y(as * w, a + 120 * 2), 
				  false);
}

function draw_line_round_arrow_scale(x1, y1, x2, y2, w, as = 4) {
	draw_line_round(x1, y1, x2, y2, w);
	
	var a = point_direction(x1, y1, x2, y2) + 45;
	
	draw_triangle(x2 + lengthdir_x(as * w, a + 90 * 0), y2 + lengthdir_y(as * w, a + 90 * 0), 
				  x2 + lengthdir_x(as * w, a + 90 * 1), y2 + lengthdir_y(as * w, a + 90 * 1), 
				  x2 + lengthdir_x(as * w, a + 90 * 2), y2 + lengthdir_y(as * w, a + 90 * 2), 
				  false);
				  
	draw_triangle(x2 + lengthdir_x(as * w, a + 90 * 0), y2 + lengthdir_y(as * w, a + 90 * 0), 
				  x2 + lengthdir_x(as * w, a + 90 * 2), y2 + lengthdir_y(as * w, a + 90 * 2), 
				  x2 + lengthdir_x(as * w, a + 90 * 3), y2 + lengthdir_y(as * w, a + 90 * 3), 
				  false);
}