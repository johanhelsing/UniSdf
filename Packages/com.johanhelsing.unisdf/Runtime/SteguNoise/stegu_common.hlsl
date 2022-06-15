#ifndef JGJK_STEGU_COMMON_HLSL
#define JGJK_STEGU_COMMON_HLSL

#include "../common.hlsl"

// Modulo 289 without a division (only multiplications)
float2 mod289(float2 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 mod289(float3 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 mod289(float4 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

// Permutation polynomial: (34x^2 + x) mod 289
float3 permute(float3 x)
{
    return mod289((34.0 * x + 1.0) * x);
}

float4 permute(float4 x)
{
    return mod289((34.0 * x + 1.0) * x);
}

#define GENERATE_FBM_WITH_NAME(type, name, noise) \
    float name(type p, int octaves, float gain, float lacunarity) \
    { \
        float y = 0; \
        float amplitude = 1; \
        float frequency = 1; \
        for (int i = 0; i < octaves; ++i) \
        { \
            y += amplitude * noise(frequency * p); \
            frequency *= lacunarity; \
            amplitude *= gain; \
        } \
        return y; \
    }

#define GENERATE_FBM(type, noise) \
    GENERATE_FBM_WITH_NAME(type, noise##_fbm, noise);

#define GENERATE_TURBULENCE(type, noise) \
    float noise##_abs(type p) /* turbulence is just fbm with abs(noise_value) */ \
    { \
        return abs(noise(p)); \
    } \
    GENERATE_FBM_WITH_NAME(type, noise##_turbulence, noise##_abs);

// Adapted from: https://thebookofshaders.com/13/
#define GENERATE_RIDGE(type, noise) \
    float noise##_ridge(type p, int octaves, float gain, float lacunarity, float offset) \
    { \
        float y = 0; \
        float amplitude = 1; \
        float frequency = 1; \
        for (int i = 0; i < octaves; ++i) \
        { \
            y += amplitude * noise(frequency * p); \
            y = abs(y); /* Create creases */ \
            y = offset - y; /* Invert so creases are at top */ \
            y = y * y; /* Sharpen creases */ \
            frequency *= lacunarity; \
            amplitude *= gain; \
        } \
        return y; \
    }

// float3 mod289(float3 x)
// {
//     return x - floor(x / 289.0) * 289.0;
// }
//
// float4 mod289(float4 x)
// {
//     return x - floor(x / 289.0) * 289.0;
// }
//

#endif