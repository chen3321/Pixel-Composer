varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   axis;
uniform float iteration;

void main() {
	vec2 tx  = 1. / dimension;
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = col;
	
	if(col.a > 0.)
		return;
	
	float _min, _cmp;
	vec2  _str, _axs;
	
	if(axis == 0) {
		_min = dimension.x;
		_cmp = _min * v_vTexcoord.x;
		
		_str = vec2(0., v_vTexcoord.y);
		_axs = vec2(tx.x, 0.);
		
	} else {
		_min = dimension.y;
		_cmp = _min * v_vTexcoord.y;
		
		_str = vec2(v_vTexcoord.x, 0.);
		_axs = vec2(0., tx.y);
		
	}
		
	for(float i = 1.; i < 2048.; i++) {
		if(i > iteration) break;
		
		vec2 sx = _str + _axs * i;
		vec4 ss = texture2D( gm_BaseTexture, sx);
			
		if(ss.a > 0. && abs(i - _cmp) < _min) {
			_min = abs(i - _cmp);
			col  = ss;
		}
	}
	
	gl_FragColor = col;
}
