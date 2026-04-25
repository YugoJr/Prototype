shader_type canvas_item;

uniform float speed = 1.0;
uniform float frequency = 2.0;

void fragment() {
    // 1. Get the actual color of the TextureProgressBar at this pixel
    // This is the "Mask"
    vec4 mask_tex = texture(TEXTURE, UV);
    
    // 2. Calculate the rainbow color
    // Subtracting TIME makes it scroll LEFT
    float hue = (UV.x * frequency) - (TIME * speed);
    hue = fract(hue); // Keep it between 0 and 1
    
    // Simple HSV to RGB logic
    vec3 rgb = abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0;
    rgb = clamp(rgb, 0.0, 1.0);
    
    // 3. APPLY THE MASK
    // We multiply the rainbow by the alpha of the texture.
    // We also check if the red channel of the mask is > 0 
    // (This helps separate it from the 'Under' texture if the Under is black/empty)
    float final_alpha = mask_tex.a;
    
    COLOR = vec4(rgb, final_alpha);
}