#ifndef ADDITIONAL_LIGHT_INCLUDED
#define ADDITIONAL_LIGHT_INCLUDED


inline float unity_noise_randomValue (float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
}

inline float unity_noise_interpolate (float a, float b, float t)
{
    return (1.0-t)*a + (t*b);
}

inline float unity_valueNoise (float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = unity_noise_randomValue(c0);
    float r1 = unity_noise_randomValue(c1);
    float r2 = unity_noise_randomValue(c2);
    float r3 = unity_noise_randomValue(c3);

    float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
    float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
    float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
    return t;
}

void Unity_SimpleNoise2_float(float2 UV, float Scale, out float3 Out)
{
    float t = 0.0;

    float freq = pow(3.0, 3.0);
    // pixel definition, grain factor (higher val = less grainy)
    float amp = pow(0.6, 3.0);
    // t += unity_valueNoise(UV * Scale / freq) * amp;
    
    freq = pow(2.0, float(3));
    amp = pow(0.5, float(2));
    t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;


    t = saturate(t); // clamp

    float3 base = float3(t, t, t);
    float3 tint = float3(0.0, 1.0, 1.0);
    // apply tint
    // t = pow(t, 3); // Brightens midtones, shrinks dark areas

    
    Out = lerp(base, tint, t);
    // Out = float3(t, t, t);s
} 

void Unity_IslandNoise_float(float2 UV, float Scale, float Smoothness, out float3 Color)
{
    // Generate noise value
    float noise = unity_valueNoise(UV * Scale);
    float threshold = 0.1; // threshhold for black spots

    // blur the edge w smoothstep
    float edge = smoothstep(threshold, threshold + Smoothness, noise);

    float final = edge;

    Color = float3(final, final, final);
}

// Fractal noise
float fbm_noise(float2 uv, float frequency, int octaves)
{
    float value = 0.0;
    float amp = 0.5;
    float freq = frequency;

    for (int i = 0; i < octaves; i++)
    {
        value += unity_valueNoise(uv * freq) * amp;
        freq *= 2.0;
        amp *= 0.5;
    }
    return value;
}

// Organic island shader function
void Unity_OrganicIslands_float(float2 UV, float Scale, float Smoothness, out float3 Color) {
    // domain breaks up uniformity
    float2 warp = float2(
        unity_valueNoise(UV * Scale * 0.5),
        unity_valueNoise((UV + 10.0) * Scale * 0.5)
    );
    UV += warp * 0.01;

    // Generate fBM noise with 4 octaves
    float rawNoise = fbm_noise(UV, Scale, 8);

    // Apply smooth threshold for soft island edges
    float threshold = 0.45;
    float edge = smoothstep(threshold, threshold + Smoothness, rawNoise);

    float final = edge;
    Color = float3(final, final, final);
}


#endif