shader_type canvas_item;

void fragment() {

	vec4 stex = textureLod(SCREEN_TEXTURE, SCREEN_UV, 3.0);
	vec4 tex = textureLod(TEXTURE, UV, 3.0);
	
	vec4 mtex = (stex * tex);

	float m = ((sin(TIME * 2.4 + ((SCREEN_UV.x + SCREEN_UV.y) * 5.8)) + 1.0) * 0.5) * 0.1 + 0.1;
	
	vec4 c = mtex;
	c.r = pow(mtex.r + m, 2.5) * 3.5;
	c.g = pow(mtex.g + m, 1.6) * 3.5;
	c.b = pow(mtex.b + m, 0.7) * 3.5;
	c.a = (c.r + c.g + c.b) * 0.3333 * 0.5;
	
	
	COLOR = c;
//	
	
//	vec4 stex = textureLod(SCREEN_TEXTURE, SCREEN_UV, 1.0);
//	vec4 stex2 = textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(0.8, 0.8), 1.0);
//	vec4 stex3 = textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(-0.8, 0.8), 1.0);
//	vec4 stex4 = textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(0.8, -0.8), 1.0);
//	vec4 stex5 = textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(-0.8, -0.8), 1.0);
//	vec4 tex = textureLod(TEXTURE, UV, 1.0);
//
//	float m1 = ((sin(TIME * 3.0 + (UV.x + UV.y) * 4.0) + 1.0) * 0.5) * 1.0;
//	float m2 = ((cos(TIME * 3.0 - (UV.x + UV.y) * 4.0) + 1.0) * 0.5) * 1.0;
//
//	vec4 c = (stex2 + stex3 + stex3 + stex4) * 0.25 + stex * (m1 + m2);
	
//	c.g += c.g * (pow(tex.r, 4.0) * tex.a * pow((m1), 2.2)) * 0.8;
//	c.b -= c.b * (pow(tex.r, 4.0) * tex.a * pow((m2), 2.2)) * 0.8;
//	c.r += c.r * (pow(tex.r, 4.0) * tex.a * pow((m2 + m1), 2.2)) * 0.8;
	
	COLOR = c;
}