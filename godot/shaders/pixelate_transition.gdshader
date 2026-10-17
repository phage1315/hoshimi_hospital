shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
	float pixel_size = mix(1.0, 18.0, smoothstep(0.0, 1.0, progress));
	vec2 pixel_uv = (floor(SCREEN_UV * viewport_size / pixel_size) + vec2(0.5)) * pixel_size / viewport_size;
	vec3 scene_color = texture(screen_texture, pixel_uv).rgb;
	float luminance = dot(scene_color, vec3(0.2126, 0.7152, 0.0722));
	scene_color = mix(scene_color, vec3(luminance), progress * 0.48);
	scene_color = mix(scene_color, vec3(0.018, 0.026, 0.038), progress * 0.86);
	COLOR = vec4(scene_color, 1.0);
}
