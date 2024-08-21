shader_type canvas_item;

uniform sampler2D main_noise: filter_linear_mipmap, repeat_enable;
uniform sampler2D main_noise_normal: filter_linear_mipmap, repeat_enable, hint_normal;
uniform vec3 color_night = vec3(1.0,1.0,1.0);
uniform vec3 color_dawn = vec3(1.0,1.0,1.0);
uniform vec3 color_noon = vec3(1.0,1.0,1.0);
uniform vec3 color_dusk = vec3(1.0,1.0,1.0);
const float daytime_progress = 0.0;
//const vec3 color_dev_debug = vec3(,1.0,1.0);

const float topdown_threshold = 0.25;

void fragment() {
	// Split UV to 2 section, top and bottom
	bool is_top = false;
	float floating_Y = UV.y;
	floating_Y += 0.015 * texture(main_noise, vec2(UV.y+0.01* TIME, UV.x + 0.3 * cos(0.03 * TIME))).r;
	float floating_threshold = topdown_threshold + (floating_Y-UV.y);
	if (UV.y < floating_threshold) {
		is_top = true;
	}
	vec2 mapped_uv = UV;
	//mapped_uv.x = mix((mapped_uv.x-0.5)*0.82+0.5, 0.5, clamp(1.2 * UV.y, 0.0, topdown_threshold));
	mapped_uv.x = mix(mapped_uv.x, 0.5, clamp(1.0 * UV.y, 0.0, topdown_threshold));
	mapped_uv.y = mapped_uv.y - 0.025 * TIME;
	if (is_top) {
		// Slightly add some horizontal shift
		//mapped_uv.x += 0.01 * texture(main_noise, vec2(UV.x + 0.02 * TIME, 0.0)).r * mix(1.0, 0.0, UV.y/floating_threshold);
	} else {
		// Let Y axis fall; lower means faster
		mapped_uv.y -= mix(0.0, 0.45 + UV.y * 0.3, clamp(UV.y - floating_threshold, 0.0, 1.0));
	}
	//vec4 noise_color = texture(main_noise, mapped_uv);
	float pixel_lod = mix(3.2, -1.0, clamp(UV.y/floating_threshold, 0.0, 1.0));
	vec4 noise_color = textureLod(main_noise, mapped_uv, clamp(pixel_lod, 0.0, pixel_lod));
	vec4 noise_color_normal = texture(main_noise_normal, mapped_uv);
	//COLOR = noise_color;
	NORMAL = 2.0 * texture(main_noise_normal, mapped_uv).rgb - 1.0;
	//NORMAL = texture(main_noise_normal, mapped_uv).rgb;
	
	// Manage colors
	//COLOR = texture(TEXTURE, UV);
	vec4 color_dev_debug = COLOR;
	vec4 color_principal = color_dev_debug;
	float color_randomness_bias = textureLod(main_noise, vec2(0.0, mapped_uv.x), 2.0).r;
	vec4 color_dimmer = vec4(color_principal.rgb * (0.4 + 0.1 * color_randomness_bias), 1.0);
	
	// Render color
	COLOR = mix(color_principal, color_dimmer, sqrt(noise_color.r));
	//COLOR = mix(color_dimmer, color_principal, sqrt(noise_color.r));
	//COLOR = mix(color_principal, color_dimmer, 0.0);
	if (is_top) {
		//COLOR.r = 0.1; // Debug
		// Slightly add some light
	} else {
		//COLOR.r = 0.1; // Debug
		COLOR.rgb = mix(COLOR.rgb, vec3(0.0, 0.0, 0.0), UV.y * 0.15);
	}
	if (mod(mapped_uv.x + 0.05, 0.2) < 0.1) {
		//COLOR.g = 0.0; // Debug
		//COLOR.rgb = mix(COLOR.rgb, vec3(0.0, 0.07, 1.0), 0.12);
	} else {
		//COLOR.rgb = mix(COLOR.rgb, vec3(1.0, 1.0, 1.0), 0.4);
	}
	//if (mapped_uv.x < 0.23 || mapped_uv.x > 1.0 - 0.23) {
		//COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), 0.75);
		//COLOR = mix(color_principal, vec4(0.0, 0.0, 0.0, 1.0), 0.7);
		//COLOR = color_principal;
	//}
	//if (abs(noise_color_normal.r - 0.5) < 0.015 && abs(noise_color_normal.g - 0.5) < 0.015) {
	float centerpos = 0.0;
	//centerpos = cos(1.414 * TIME) * 0.1;
	if (abs(NORMAL.r - centerpos) < 0.04 && abs(NORMAL.g - centerpos) < 0.04) {
		float polarity = cos(1.50 * TIME) * 0.5 + 0.5; // 0 ~ 1
		//color_randomness_bias
		//float highlight_strength = (0.012 - abs(NORMAL.r - centerpos)) * 45.0 * (0.85 - UV.y);
		float highlight_strength = 1.0   *  clamp(mix(0.85, -0.10, UV.y), 0.0, 1.0)     *      (abs(NORMAL.r + NORMAL.g))/0.1;
		//COLOR.rgb = mix(COLOR.rgb, vec3(1.0, 1.0, 1.0), clamp(highlight_strength, 0.0, 0.8));
	}
	//COLOR += LIGHT;
	//COLOR = texture(main_noise, mapped_uv);
}

//void light() {
	//float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
	//LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * cNdotL, LIGHT_COLOR.a);
//}