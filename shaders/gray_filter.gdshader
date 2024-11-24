shader_type canvas_item;

// Uniforms from Shader 1
uniform sampler2D flowMap; // Displacement map
uniform float strength = 0.005;    // Force of the effect
uniform float speed = 6.0;       // Speed of the effect
uniform int frames : hint_range(1, 100) = 3; // Frames of the effect
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Uniforms from Shader 2
uniform sampler2D Noise;
uniform bool weighted = true;   // Determines whether to use normal or weighted averages
uniform bool activate = false;
uniform float Transparency = 4.0;
uniform float Slow = 25.0;
uniform float brightness = 2.5;

// Function to calculate clock frame
float clock(float time) {
    float fframes = float(frames);
    return floor(mod(time * speed, fframes)) / fframes;
}

void fragment() {
    // --- Shader 1 Logic ---
    float c = clock(TIME); // Get clock frame
    // Scale the flowMap to fit the entire image
    vec2 flowMapSize = vec2(textureSize(flowMap, 0)); // Flow map texture size
    vec2 screenSize = vec2(textureSize(SCREEN_TEXTURE, 0)); // Screen texture size
    vec2 scaledUV = UV * (screenSize / flowMapSize); // Scale UV coordinates
    // Add time-based motion and wrap the flowMap UVs
    vec2 movingUV = mod(scaledUV + vec2(c, 0.0), 1.0); // Add motion and wrap around
    // Sample the flowMap with wrapped UV
    vec4 offset = texture(flowMap, movingUV) * strength;

    // Apply the offset to the UV
    vec2 displacedUV = vec2(UV.x, UV.y) + offset.xy - vec2(0.5, 0.5) * strength;
    vec4 baseColor = texture(TEXTURE, displacedUV); // Get the displaced texture color

    // --- Shader 2 Logic ---
    if (activate) {
        // Convert the original color to grayscale
        vec3 gray = mix(
            vec3((baseColor.r + baseColor.g + baseColor.b) / 3.0),      // Normal grayscale
            vec3(0.299 * baseColor.r + 0.587 * baseColor.g + 0.114 * baseColor.b),  // Weighted grayscale
            float(weighted)
        );

		// Make grayscale brighter
		gray *= 1.2;

        // Mix the texture with the grayscale value
        vec3 tex = mix(baseColor.rgb, gray, 1.0);

        // Apply the noise effect and divide by transparency (affects RGB only)
        vec3 resultColor = tex * texture(Noise, texture(Noise, UV).xy + cos(TIME) / Slow).rgb / Transparency;
        resultColor *= brightness;

        // Preserve the original alpha (baseColor.a) and only modify the RGB
        COLOR = vec4(tex, baseColor.a);
    } else {
        // If not activated, just use the result from Shader 1
        COLOR = baseColor;
    }
}