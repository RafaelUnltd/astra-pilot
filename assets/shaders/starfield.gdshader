shader_type canvas_item;

uniform vec2 resolution = vec2(1920.0, 1080.0);
uniform sampler2D noise_texture: filter_nearest, repeat_enable;
uniform float density: hint_range(1.0, 100.0, 0.1) = 18.0;
uniform float speed_x: hint_range(-100.0, 100.0, 0.1) = 0.05;
uniform float speed_y: hint_range(-100.0, 100.0, 0.1) = 0.02;

void fragment() {
	vec2 uv = UV;
	uv.x *= resolution.x / resolution.y;
	vec2 speed = TIME * vec2(speed_x, speed_y);
	float stars = 0.0;
	stars += pow(texture(noise_texture, uv + speed).r, 18);
	stars = clamp(stars, 0.1, 1);
	COLOR = vec4(vec3(stars), 1.0);
}