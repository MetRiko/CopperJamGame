shader_type canvas_item;


void fragment() {
	
	vec4 tex = textureLod(TEXTURE, UV, 1.0);
	
	vec4 c = tex - tex.b * abs(sin(TIME * 1.4 + UV.x + UV.y)) * 0.4 ; 
	
	if (c.r + c.g + c.b < 0.2) {
		c.r = sin(UV.x * 0.4 + TIME * 0.01) * c.r * 1.5;
		c.g = cos(UV.x * 0.2 + TIME * 0.01) * c.r * 0.2;
	}
	
	COLOR = c;
	
}