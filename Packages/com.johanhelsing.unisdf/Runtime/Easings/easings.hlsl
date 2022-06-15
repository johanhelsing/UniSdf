#ifndef UNISDF_EASINGS_HLSL
#define UNISDF_EASINGS_HLSL

#include "../common.hlsl"

// https://youtu.be/mr5xkf6zSzk?t=1571
float normalized_bezier_3(float t, float b, float c)
{
    float s = 1 - t;
    float t2 = t * t;
    float s2 = s * s;
    float t3 = t2 * t;
    return (3 * b * s2 * t) + (3 * c * s * t2) + t3;
}

// The actual functions:

float smooth_start_2(float t)
{
    return pow2(t);
}

float smooth_start_3(float t)
{
    return pow3(t);
}

float2 smooth_start_3_2d(float2 t)
{
    return pow3(t);
}

float smooth_start_4(float t)
{
    return pow4(t);
}

float smooth_start_5(float t)
{
    return pow5(t);
}

float smooth_stop_2(float t)
{
    return 1 - pow2(1 - t);
}

float smooth_stop_3(float t)
{
    return 1 - pow3(1 - t);
}

float2 smooth_stop_3_2d(float2 t)
{
    return 1 - pow3(1 - t);
}

float smooth_stop_4(float t)
{
    return 1 - pow4(1 - t);
}

float smooth_stop_5(float t)
{
    return 1 - pow5(1 - t);
}

float smooth_step_2(float t)
{
    return lerp(smooth_start_2(t), smooth_stop_2(t), t);
}

float smooth_step_3(float t)
{
    return lerp(smooth_start_3(t), smooth_stop_3(t), t);
}

float smooth_step_4(float t)
{
    return lerp(smooth_start_4(t), smooth_stop_4(t), t);
}

float smooth_step_5(float t)
{
    return lerp(smooth_start_5(t), smooth_stop_5(t), t);
}

float2 smooth_step_3_2d(float2 t)
{
    return lerp(smooth_start_3_2d(t), smooth_stop_3_2d(t), t);
}

DECLARE_2F_2F(smooth_step_3_2d);

// https://iquilezles.org/www/articles/functions/functions.htm
float iq_almost_identity(float x, float m, float n)
{
    // Anything above m is just linear
    if (x > m)
    {
        return x;
    }

    const float a = 2 * n - m;
    const float b = 2 * m - 3 * n;
    const float t = x / m;

    return (a * t + b) * t * t + n;
}

// https://iquilezles.org/www/articles/functions/functions.htm
// 0 derivative at 0 and 1 derivative at 1
// good for transitioning things from being stationary to being in motion
float iq_almost_unit_identity(float x)
{
    return x * x * (2 - x);
}

// Great for triggering behaviours or making envelopes for music or animation,
// and for anything that grows fast and then slowly decays.
// Use k to control the stretching of the function.
// Its maximum, which is 1, happens at exactly x = 1/k.
float iq_exp_impulse(float x, float k)
{
    const float h = k * x;
    return h * exp(1 - h);
}

// Similar iq_exp_impulse, but it allows for control on the width of attack
// (through the parameter "k") and the release (parameter "f") independently.
// Also, it ensures the impulse releases at a value of 1.0 instead of 0.
float iq_exp_sustained_impulse(float x, float f, float k)
{
    float s = max(x - f,0);
    return min(x * x / (f * f), 1 + (2 / f) * s * exp(-k * s));
}

// Impulse function that doesn't use exponentials can be designed by using polynomials.
// Use k to control falloff of the function.
// Quadratic which peaks at x = sqrt(1/k).
float iq_quadratic_impulse(float k, float x)
{
    return 2 * sqrt(k) * x / (1 + k * x * x);
}

// More expensive generalized polynomial impulse which peaks at x = (1/k)^(1/n).
float iq_poly_impulse(float k, float n, float x)
{
    return (n / (n - 1.0))
        * pow((n - 1.0) * k, 1.0 / n)
        * x
        / (1.0 + k * pow(x, n));
}

// Replacement for smoothstep(c-w,c,x)-smoothstep(c,c+w,x),
// Useful when trying to isolate some features in a signal.
// You can also use it as a cheap replacement for a gaussian.
float iq_cubic_pulse(float center, float width, float x)
{
    x = abs(x - center);
    if (x > width) return 0.0;
    x /= width;
    return 1.0 - x * x * (3.0 - 2.0 * x);
}

// A natural attenuation is an exponential of a linearly decaying quantity: exp(-x).
// A gaussian is an exponential of a quadratically decaying quantity: exp(-x^2).
// You can generalize and keep increasing powers, and get a sharper and sharper s-shaped curves,
// until you get a step() in the limit.
float iq_exp_step(float x, float edge, float power)
{
    return exp(-edge * pow(x, power));
}

// Remapping the unit interval into the unit interval by expanding the sides and compressing the center,
// and keeping 1/2 mapped to 1/2, that can be done with the gain() function.
// k=1 is the identity curve, k<1 produces the classic gain() shape, and k>1 produces "s" shaped curves.
// The curves are symmetric (and inverse) for k=a and k=1/a.
float iq_gain(float x, float power)
{
    const float a = 0.5 * pow(2.0 * ((x < 0.5) ? x : 1.0 - x), power);
    return (x < 0.5) ? a : 1.0 - a;
}

#define IQ_GAIN_N(DIMENSION) \
    float##DIMENSION iq_gain_##DIMENSION(float##DIMENSION x, float power) \
    { \
        const float##DIMENSION a = 0.5 * pow(2.0 * ((x < 0.5) ? x : 1.0 - x), power); \
        return (x < 0.5) ? a : 1.0 - a; \
    }

IQ_GAIN_N(2);
IQ_GAIN_N(3);
IQ_GAIN_N(4);

// A nice choice to remap the 0..1 interval into 0..1,
// such that the corners are mapped to 0 and the center to 1.
// In other words, parabola(0) = parabola(1) = 0, and parabola(1/2) = 1.
float iq_parabola(float x, float power)
{
    return pow(4 * x * (1 - x), power);
}

// This is a generalization of iq_parabola.
// It also maps the 0..1 interval into 0..1 by keeping the corners mapped to 0.
// But in this generalization you can control the shape one either side of the curve,
// which comes handy when creating leaves, eyes, and many other interesting shapes.
float iq_power_curve_normalized(float x, float a, float b)
{
    // Note that k is chosen such that the curve reaches exactly 1 at its maximum for illustration purposes,
    // but in many applications the curve needs to be scaled anyways so the slow computation of k can be simply avoided.
    const float k = pow(a + b, a + b) / (pow(a, a) * pow(b, b));
    return k * pow(x, a) * pow(1 - x, b);
}

// This is a cheaper version of iq_power_normalized
float iq_power_curve_cheap(float x, float a, float b)
{
    return pow(x, a) * pow(1 - x, b);
}

// A phase shifted sinc curve can be useful if it starts at zero and ends at zero,
// for some bouncing behaviors.
// Give k different integer values to tweak the amount of bounces.
// It peaks at 1.0, but that take negative values, which can make it unusable in some applications.
float iq_sinc(float x, float k)
{
    const float a = PI * (k * x - 1.0);
    return sin(a) / a;
}

// Shader graph interfaces:

DECLARE_1F_1F(smooth_start_2);
DECLARE_1F_1F(smooth_start_3);
DECLARE_1F_1F(smooth_start_4);
DECLARE_1F_1F(smooth_start_5);
DECLARE_1F_1F(smooth_stop_2);
DECLARE_1F_1F(smooth_stop_3);
DECLARE_1F_1F(smooth_stop_4);
DECLARE_1F_1F(smooth_stop_5);
DECLARE_1F_1F(smooth_step_2);
DECLARE_1F_1F(smooth_step_3);
DECLARE_1F_1F(smooth_step_4);
DECLARE_1F_1F(smooth_step_5);

DECLARE_1F1F1F_1F(normalized_bezier_3);

DECLARE_1F1F1F_1F(iq_almost_identity);
DECLARE_1F_1F(iq_almost_unit_identity);
DECLARE_1F1F_1F(iq_exp_impulse);
DECLARE_1F1F1F_1F(iq_exp_sustained_impulse);
DECLARE_1F1F_1F(iq_quadratic_impulse);
DECLARE_1F1F1F_1F(iq_poly_impulse);
DECLARE_1F1F1F_1F(iq_cubic_pulse);
DECLARE_1F1F1F_1F(iq_exp_step);
DECLARE_1F1F_1F(iq_gain);
DECLARE_2F1F_2F(iq_gain_2);
DECLARE_3F1F_3F(iq_gain_3);
DECLARE_4F1F_4F(iq_gain_4);
DECLARE_1F1F_1F(iq_parabola);
DECLARE_1F1F1F_1F(iq_power_curve_normalized);
DECLARE_1F1F1F_1F(iq_power_curve_cheap);
DECLARE_1F1F_1F(iq_sinc);

#endif