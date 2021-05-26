shader_type canvas_item;

void fragment() {
	vec4 stex = textureLod(SCREEN_TEXTURE, SCREEN_UV, 1.0);
	vec4 tex = textureLod(TEXTURE, UV, 1.0);
	
	float m1 = ((sin(TIME * 3.0 + (UV.x + UV.y) * 4.0) + 1.0) * 0.5) * 1.0;
	float m2 = ((cos(TIME * 3.0 - (UV.x + UV.y) * 4.0) + 1.0) * 0.5) * 1.0;
	
	vec4 c = stex;
	
	c.g += c.g * (pow(tex.r, 4.0) * tex.a * pow((m1), 2.2)) * 0.8;
	c.b -= c.b * (pow(tex.r, 4.0) * tex.a * pow((m2), 2.2)) * 0.8;
	c.r += c.r * (pow(tex.r, 4.0) * tex.a * pow((m2 + m1), 2.2)) * 0.8;
	
	COLOR = c;
}