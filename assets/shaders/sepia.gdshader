shader_type canvas_item;

uniform sampler2D screen_tex: hint_screen_texture, filter_linear;

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 color = texture(screen_tex, SCREEN_UV).rgb;
	float r = color.r;
	float g = color.g;
	float b = color.b;

	float sepiaR = (r*0.393) + (g*0.769) + (b * 0.189);
	float sepiaG = (r*0.349) + (g*0.686) + (b * 0.168);
	float sepiaB = (r*0.272) + (g*0.534) + (b * 0.131);

	COLOR.rgb = vec3(sepiaR, sepiaG, sepiaB);
	COLOR.a = texture(screen_tex, SCREEN_UV).a;
}