shader_type canvas_item;

uniform float blur_radius = 2.25;
uniform float saturation = 0.82;

void fragment() {
	vec2 offset = TEXTURE_PIXEL_SIZE * blur_radius;
	vec4 color = texture(TEXTURE, UV) * 0.20;
	color += texture(TEXTURE, UV + vec2(offset.x, 0.0)) * 0.12;
	color += texture(TEXTURE, UV - vec2(offset.x, 0.0)) * 0.12;
	color += texture(TEXTURE, UV + vec2(0.0, offset.y)) * 0.12;
	color += texture(TEXTURE, UV - vec2(0.0, offset.y)) * 0.12;
	color += texture(TEXTURE, UV + offset) * 0.08;
	color += texture(TEXTURE, UV - offset) * 0.08;
	color += texture(TEXTURE, UV + vec2(offset.x, -offset.y)) * 0.08;
	color += texture(TEXTURE, UV + vec2(-offset.x, offset.y)) * 0.08;
	float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	color.rgb = mix(vec3(luminance), color.rgb, saturation);
	COLOR = color;
}
