shader_type canvas_item;

uniform sampler2D dissolve_texture : source_color, repeat_enable;
uniform sampler2D voronoi_texture  : source_color, repeat_enable;

uniform float dissolve_value : hint_range(0,1) = 1.0;
uniform float burn_size      : hint_range(0.0, 0.5) = 0.0;

// Color layers
uniform vec4 ash_color       : source_color = vec4(0,0,0,1.0);
uniform vec4 fire_edge_color : source_color = vec4(3.236,1.499,0.361,1.0);

// Adjustable strengths
uniform float fire_edge_strength : hint_range(0.1, 10.0, 0.1) = 10.0;
uniform float ash_edge_strength  : hint_range(1.0, 100.0, 1.0) = 100.0;

// Noise scrolling
uniform vec2 offset = vec2(0.0, 0.0);
uniform float noise_speed = 0.125;
uniform float noise_scale = 1.0;


uniform float crack_scale_x     = 4.0;
uniform float crack_scale_y     = 2.0;

void fragment() {
	
	
    float noise_val = texture(dissolve_texture, UV / 5.0 + offset).r;
	
    float wobble = (noise_val - 0.5) * 0.5;   // adjust amplitude
	float rotation = (noise_val - 0.5) * 3.14159 * 0.5; // max ±90° scaled by factor
	
	
	vec2 center = UV - vec2(0.5);

	// radial distance
	float r = length(center);

	// angle
	float angle = atan(center.y, center.x);
	
	float new_angle = angle + rotation * (1.0 - smoothstep(0.0, 1.0, clamp(dissolve_value + 0.5, 0.0, 1.0)));
	vec2 radial = vec2(cos(new_angle), sin(new_angle)) * r;
	
	
	
	
	// shift back to UV space
	vec2 distorted_uv = radial + vec2(0.5);

	
	distorted_uv.y += mix(0.5,0.0, smoothstep(0.0, 1.0, clamp(dissolve_value + 0.5, 0.0, 1.0)));
    distorted_uv.x += wobble * (1.0 - smoothstep(0.0, 1.0, clamp(dissolve_value + 0.5, 0.0, 1.0)));
	
    vec4 color_result = texture(TEXTURE, distorted_uv);
	

    if (color_result.a > 0.0) {

        // Base dissolve noise
        float noise_v = texture(dissolve_texture, distorted_uv + offset).r;

        float threshold = smoothstep(noise_v - burn_size, noise_v, dissolve_value);
        float border    = smoothstep(noise_v,         noise_v + burn_size, dissolve_value);

        // base alpha
        color_result.a = color_result.a * threshold;

        // ------------------------------------------------------------
        // FIRE / PREBURN MIX
        // ------------------------------------------------------------
		
		float blackbody = 0.2;
		
        vec3 fire_mix = mix(fire_edge_color.rgb,
                            vec3(-blackbody),
                            1.0 - pow(1.0 - border, fire_edge_strength));

        // Fire animation (floaty noise)
        vec2 animated_uv = wobble + distorted_uv + radial * noise_scale + vec2(TIME * noise_speed);
		animated_uv.y /= 2.0;
        float n = texture(dissolve_texture, animated_uv).r;
        fire_mix *= (3.0 * n);
		
		
		float new_crack_scale_y = mix(0.0, crack_scale_y, dissolve_value - 0.5);
		
        float crack_amount = clamp((0.5 - dissolve_value) * 2.0, 0.0, 1.0);

        vec2 crack_uv = distorted_uv * vec2(crack_scale_x, new_crack_scale_y) + offset;
        float crack_noise = texture(voronoi_texture, crack_uv).r;

        // Use smoothstep to make crack_sharpness meaningful
        float crack_mask = smoothstep(1.0 - crack_amount, 1.0 - crack_amount + 0.05, crack_noise);

        // cracks remove ash → alpha only
        float ash_alpha = 1.0 - crack_mask;
		
		vec3 ash_visible = mix(vec3(1.5), ash_color.rgb, color_result.a * ash_alpha);

        // ------------------------------------------------------------
        // FINAL ASH MIX
        // ------------------------------------------------------------
        vec3 ash_mix = mix(ash_visible,
                           fire_mix,
                           1.0 - pow(1.0 - border, ash_edge_strength));

        color_result.rgb = mix(ash_mix, color_result.rgb, border);

        // propagate ash cracks into alpha
        color_result.a *= ash_alpha;
    }
	
	
	
    COLOR = color_result;
}
