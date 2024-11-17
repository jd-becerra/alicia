shader_type canvas_item;

uniform sampler2D flowMap; // Displacement map
uniform float strength = 0.005; // Force of the effect
uniform float speed = 6;       // Speed of the effect
uniform int frames : hint_range(1, 100) = 3; // Frames of the effect
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

// Returns a value between 0 and 1 depending on the frames -> example: frames = 4, frame 1 = 0.25
float clock(float time) {
    float fframes = float(frames);
    return floor(mod(time * speed, fframes)) / fframes;
}

void fragment() {
    float c = clock(TIME); // Get clock frame

    // Scale the flowMap to fit the entire image
    vec2 flowMapSize = vec2(textureSize(flowMap, 0)); // Flow map texture size
    vec2 screenSize = vec2(textureSize(SCREEN_TEXTURE, 0)); // Screen texture size
    vec2 scaledUV = UV * (screenSize / flowMapSize); // Scale UV coordinates

    // Add time-based motion and wrap the flowMap UVs
    vec2 movingUV = mod(scaledUV + vec2(c, 0.0), 1.0); // Add motion and wrap around

    // Sample the flowMap with wrapped UV
    vec4 offset = texture(flowMap, movingUV) * strength;

    // Apply the offset
    COLOR = texture(TEXTURE, vec2(UV.x, UV.y) + offset.xy - vec2(0.5, 0.5) * strength);
}