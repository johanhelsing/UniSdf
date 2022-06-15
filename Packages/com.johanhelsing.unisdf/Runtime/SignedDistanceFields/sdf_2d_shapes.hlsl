#ifndef UNISDF_SDF_2D_SHAPES_HLSL
#define UNISDF_SDF_2D_SHAPES_HLSL

#include "../common.hlsl"

// https://www.iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm
// Has huge issues with instability when close to a circle or very eccentric
float iq_sd_ellipse_analytical(float2 p, float2 ab)
{
    p = abs(p);
    if (p.x > p.y)
    {
        p = p.yx;
        ab = ab.yx;
    }
    float l = ab.y * ab.y - ab.x * ab.x;
    float m = ab.x * p.x / l;
    float m2 = m * m;
    float n = ab.y * p.y / l;
    float n2 = n * n;
    float c = (m2 + n2 - 1.0) / 3.0;
    float c3 = c * c * c;
    float q = c3 + m2 * n2 * 2.0;
    float d = c3 + m2 * n2;
    float g = m + m * n2;
    float co;
    if (d < 0)
    {
        float h = acos(q / c3) / 3.0;
        float s = cos(h);
        float t = sin(h) * sqrt(3.0);
        float rx = sqrt(-c * (s + t + 2.0) + m2);
        float ry = sqrt(-c * (s - t + 2.0) + m2);
        co = (ry + sign(l) * rx + abs(g) / (rx * ry) - m) / 2.0;
    }
    else
    {
        float h = 2.0 * m * n * sqrt(d);
        float s = sign(q + h) * pow(abs(q + h), 1.0 / 3.0);
        float u = sign(q - h) * pow(abs(q - h), 1.0 / 3.0);
        float rx = -s - u - c * 4.0 + 2.0 * m2;
        float ry = (s - u) * sqrt(3.0);
        float rm = sqrt(rx * rx + ry * ry);
        co = (ry / sqrt(rm - rx) + 2.0 * g / rm - m) / 2.0;
    }
    float2 r = ab * float2(co, sqrt(1.0 - co * co));
    return length(r - p) * sign(p.y - r.y);
}

DECLARE_2F2F_1F(iq_sd_ellipse_analytical);

// https://www.iquilezles.org/www/articles/ellipsedist/ellipsedist.htm
#define IQ_SD_ELLIPSE_NUMERICAL(ITERATIONS) \
    float iq_sd_ellipse_numerical_##ITERATIONS(float2 p, float2 ab) \
    { \
        p = abs(p); \
        \
        /* Determine in/out and initial omega value */ \
        bool s = dot(p / ab, p / ab) > 1.0; \
        float w = s ? atan2(p.y * ab.x, p.x * ab.y) : ((ab.x * (p.x - ab.x) < ab.y * (p.y - ab.y)) ? 1.5707963 : 0.0); \
        \
        /* Find root with Newton solver */ \
        for (int i = 0; i < ITERATIONS; i++) \
        { \
            float2 cs = float2(cos(w), sin(w)); \
            float2 u = ab * float2(cs.x, cs.y); \
            float2 v = ab * float2(-cs.y, cs.x); \
            w = w + dot(p - u, v) / (dot(p - u, u) + dot(v, v)); \
        } \
        \
        /* Compute final point and distance */ \
        return length(p - ab * float2(cos(w), sin(w))) * (s ? 1.0 : -1.0); \
    }

IQ_SD_ELLIPSE_NUMERICAL(0);
IQ_SD_ELLIPSE_NUMERICAL(1);
IQ_SD_ELLIPSE_NUMERICAL(2);
IQ_SD_ELLIPSE_NUMERICAL(3);
IQ_SD_ELLIPSE_NUMERICAL(4);
IQ_SD_ELLIPSE_NUMERICAL(5);
DECLARE_2F2F_1F(iq_sd_ellipse_numerical_0);
DECLARE_2F2F_1F(iq_sd_ellipse_numerical_1);
DECLARE_2F2F_1F(iq_sd_ellipse_numerical_2);
DECLARE_2F2F_1F(iq_sd_ellipse_numerical_3);
DECLARE_2F2F_1F(iq_sd_ellipse_numerical_4);
DECLARE_2F2F_1F(iq_sd_ellipse_numerical_5);

float iq_sd_arc(float2 p, float2 sin_cos_orientation, float2 sin_cos_aperture, float radius_a, float radius_b)
{
    p = mul(float2x2(sin_cos_orientation.x, sin_cos_orientation.y, -sin_cos_orientation.y, sin_cos_orientation.x), p);
    p.x = abs(p.x);
    float k = (sin_cos_aperture.y * p.x > sin_cos_aperture.x * p.y) ? dot(p.xy, sin_cos_aperture) : length(p);
    return sqrt(dot(p, p) + radius_a * radius_a - 2.0 * radius_a * k) - radius_b;
}

float iq_sd_rounded_cross(float2 p, float h)
{
    float k = 0.5 * (h + 1.0 / h); // k should be const at modeling time
    p = abs(p);
    return (p.x < 1.0 && p.y < p.x * (k - h) + h)
        ? k - sqrt(dot2(p - float2(1, k)))
        : sqrt(min(dot2(p - float2(0, h)),
                    dot2(p - float2(1, 0))));
}

DECLARE_2F1F_1F(iq_sd_rounded_cross);

float iq_sd_trapezoid(float2 p, float r1, float r2, float he)
{
    float2 k1 = float2(r2, he);
    float2 k2 = float2(r2 - r1, 2.0 * he);
    p.x = abs(p.x);
    float2 ca = float2(p.x - min(p.x , (p.y<0.0) ? r1 : r2), abs(p.y) - he);
    float2 cb = p - k1 + k2 * clamp(dot(k1 - p, k2) / dot2(k2), 0.0, 1.0);
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s * sqrt(min(dot2(ca), dot2(cb)));
}

DECLARE_2F1F1F1F_1F(iq_sd_trapezoid);

DECLARE_2F2F2F1F1F_1F(iq_sd_arc);

float iq_sd_hexagon(float2 p, float r)
{
    float3 k = float3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= float2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

DECLARE_2F1F_1F(iq_sd_hexagon);

// Estimated distance to an iso curve defined by f(p) = 0
// x is f(p), while grad_x is ∇f(p)
// Derived from: https://www.iquilezles.org/www/articles/distance/distance.htm
float iq_implicit_iso_curve_distance(float x, float grad_x)
{
    return abs(x) / length(grad_x);
}

DECLARE_1F1F_1F(iq_implicit_iso_curve_distance);

#endif
