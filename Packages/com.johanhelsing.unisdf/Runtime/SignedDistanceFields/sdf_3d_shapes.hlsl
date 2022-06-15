#ifndef UNISDF_SDF_3D_SHAPES_HLSL
#define UNISDF_SDF_3D_SHAPES_HLSL

#include "../common.hlsl"

// Most of this is from:
// https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

float iq_sd_sphere(float3 position, float radius)
{
    return length(position) - radius;
}

DECLARE_3F1F_1F(iq_sd_sphere);

float iq_sd_box(float3 position, float3 bounds)
{
    float3 q = abs(position) - bounds;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

DECLARE_3F3F_1F(iq_sd_box);

float iq_sd_round_box(float3 p, float3 bounds, float radius)
{
    float3 q = abs(p) - bounds;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - radius;
}

DECLARE_3F3F1F_1F(iq_sd_round_box);

float iq_sd_ellipsoid_inexact(float3 position, float3 radii)
{
    float k0 = length(position / radii);
    float k1 = length(position / (radii * radii));
    return k0 * (k0 - 1.0) / k1;
}

DECLARE_3F3F_1F(iq_sd_ellipsoid_inexact);

#define GENERATE_CENTRAL_DIFFERENCES_SDF_NORMAL(sdf) \
    float3 sdf##_normal_central_differences(float3 p) \
    { \
        const float epsilon = 0.0001; /* Or some other value */ \
        /*const float epsilon = 0.0001; /* Or some other value */ \
        const float2 h = float2(epsilon, 0); \
        return normalize(float3( \
            sdf(p + h.xyy) - sdf(p - h.xyy), \
            sdf(p + h.yxy) - sdf(p - h.yxy), \
            sdf(p + h.yyx) - sdf(p - h.yyx) ) \
        ); \
   }

#define GENERATE_FORWARD_DIFFERENCES_SDF_NORMAL(sdf) \
    float3 sdf##_normal_forward_differences(float3 p) \
    { \
        const float epsilon = 0.0001; /* Or some other value */ \
        /*const float epsilon = 0.0001; /* Or some other value */ \
        const float2 h = float2(epsilon, 0); \
        return normalize(float3( \
            sdf(p + h.xyy), \
            sdf(p + h.yxy), \
            sdf(p + h.yyx) ) \
        ); \
   }


#endif
