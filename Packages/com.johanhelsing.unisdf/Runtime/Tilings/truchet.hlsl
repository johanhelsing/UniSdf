#ifndef UNISDF_TRUCHET_HLSL
#define UNISDF_TRUCHET_HLSL

#include "../common.hlsl"
#include "../Hash/hash.hlsl"

float2 truchet_tile_flip(float2 pos) {
    // pos = pos * 0.5;
    int2 id = floor(pos);
    float r = iq_hash_2f_1f(id);
    float flip = floor(r * 2) * 2 - 1;
    float2 gv = frac(pos) * 2 - 1;
    gv.x *= flip;
    return gv;
}

DECLARE_2F_2F(truchet_tile_flip);

float2 truchet_corner_uv(float2 pos) {
    float y = abs(abs(pos.x + pos.y) - 1);
    // float x = abs(frac(pos.x - pos.y) * 2 - 1);
    float x = abs(abs(pos.x - pos.y) - 1);
    return float2(x, y);
}

DECLARE_2F_2F(truchet_corner_uv);

float2 truchet_circle(float2 pos) {
    float u = (pos.x+pos.y) * 0.5;
    float v = 1 - abs(pos.x-pos.y) * 0.5;
    float r = length(float2(u, v)) - sqrt(2) / 2.;
    float theta = frac(abs(atan2(u, v)) / (PI / 4));
    return float2(theta, r);
}

DECLARE_2F_2F(truchet_circle);

#endif