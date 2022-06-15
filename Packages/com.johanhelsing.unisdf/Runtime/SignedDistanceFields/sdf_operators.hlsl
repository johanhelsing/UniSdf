#ifndef UNISDF_SDF_OPERATORS_HLSL
#define UNISDF_SDF_OPERATORS_HLSL

#include "../common.hlsl"

float iq_union(float distance1, float distance2)
{
    return min(distance1, distance2);
}

float iq_subtraction(float distance1, float distance2)
{
    return max(-distance1, distance2);
}

float iq_intersection(float distance1, float distance2)
{
    return max(distance1, distance2);
}

float iq_smooth_union(float distance1, float distance2, float k)
{
    float h = clamp(0.5 + 0.5 * (distance2 - distance1) / k, 0.0, 1.0);
    return lerp(distance2, distance1, h) - k * h * (1.0 - h);
}

DECLARE_1F1F1F_1F(iq_smooth_union);

float iq_smooth_intersect(float d1, float d2, float k)
{
    float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return lerp(d2, d1, h) + k * h * (1.0-h);
}

DECLARE_1F1F1F_1F(iq_smooth_intersect);

float iq_smooth_subtract(float d1, float d2, float k)
{
    float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return lerp(d2, -d1, h) + k * h * (1.0 - h);
}

DECLARE_1F1F1F_1F(iq_smooth_subtract);

// https://iquilezles.org/www/articles/smin/smin.htm
float iq_smooth_exp_part(float distance, float k)
{
    return exp2(-k * distance);
}

float iq_smooth_exp_unwrap(float exp_distance, float k)
{
    return -log2(exp_distance) / k;
}

float iq_smooth_exp_union(float distance1, float distance2, float k)
{
    float exp_distance = iq_smooth_exp_part(distance1, k) + iq_smooth_exp_part(distance2, k);
    return iq_smooth_exp_unwrap(exp_distance, k);
}

DECLARE_1F1F1F_1F(iq_smooth_exp_union);

float iq_smooth_exp_subtract_interior(float distance1, float distance2, float k)
{
    float exp_distance = iq_smooth_exp_part(distance1, k) - iq_smooth_exp_part(distance2, k);
    return iq_smooth_exp_unwrap(max(exp_distance, 0.00000001), k);
}

DECLARE_1F1F1F_1F(iq_smooth_exp_subtract_interior);

// 2D Finite repetition
// https://iquilezles.org/www/articles/distfunctions/distfunctions.htm adapted for 2d
float2 iq_rep_lim(float2 position, float period, float2 limits)
{
    return position - period * clamp(round(position / period), -limits, limits);
}

DECLARE_2F1F2F_2F(iq_rep_lim);

#endif
