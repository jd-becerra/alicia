shader_type canvas_item;

uniform sampler2D Noise;

// --- Uniforms --- //
uniform bool weighted = true;   // Determines whether to use normal or weighted averages
uniform bool activate = false;
uniform float Transparency = 4.0;
uniform float Slow = 25.0;
uniform float brightness = 2.5;

void fragment() {
    if (activate) {
        // Convert the original color to grayscale
        vec3 gray = mix(
            vec3((COLOR.r + COLOR.g + COLOR.b) / 3.0),      // Normal grayscale
            vec3(0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b),  // Weighted grayscale
            float(weighted)
        );

        // Mix the texture with the grayscale value
        vec3 tex = mix(texture(TEXTURE, UV).rgb, gray, 1.0);

        // Apply the noise effect and divide by transparency (affects RGB only)
        vec3 resultColor = tex * texture(Noise, texture(Noise, UV).xy + cos(TIME) / Slow).rgb / Transparency;

		resultColor *= brightness;

        // Preserve the original alpha (COLOR.a) and only modify the RGB
        COLOR = vec4(resultColor, COLOR.a);
    }
}
