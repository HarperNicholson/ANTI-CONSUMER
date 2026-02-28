shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 100.0, 0.1) = 1.0;
uniform float anti_alias_amount : hint_range(0.0, 1.0, 0.01) = 0.05;

void fragment() {
    vec2 pixel_size = vec2(1.0 / texture(TEXTURE, UV).x, 1.0 / texture(TEXTURE, UV).y);
    float closest_outline_distance = 1.0;

    for (float x = -outline_width; x <= outline_width; x++) {
        for (float y = -outline_width; y <= outline_width; y++) {
            vec2 offset = vec2(x, y) * pixel_size;
            if (length(offset) > outline_width) {
                continue;
            }
            
            float alpha = texture(TEXTURE, UV + offset).a;
            if (alpha > 0.0) {
                closest_outline_distance = min(closest_outline_distance, length(offset));
            }
        }
    }
    
    vec4 base_color = texture(TEXTURE, UV);
    float alpha = 1.0 - smoothstep(closest_outline_distance - anti_alias_amount, closest_outline_distance + anti_alias_amount, closest_outline_distance);
    
    COLOR = mix(base_color, outline_color, alpha);
}