#ifndef UNISDF_HASH_HLSL
#define UNISDF_HASH_HLSL

#include "../common.hlsl"

// Source: https://www.shadertoy.com/view/4tXyWN
float iq_hash_2u_1f(uint2 x) {
    // The MIT License
    // Copyright © 2017 Inigo Quilez
    // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    uint2 q = 1103515245U * ((x >> 1U) ^ (x.yx));
    uint n = 1103515245U * ((q.x) ^ (q.y >> 3U));
    return float(n) * (1.0 / float(0xffffffffU));
}

DECLARE_2F_1F(iq_hash_2u_1f);

// Source: https://www.shadertoy.com/view/fsKBzw
float iq_hash_2f_1f(float2 f) {
    return iq_hash_2u_1f(asuint(f));
}

DECLARE_2F_1F(iq_hash_2f_1f);

float iq_hash_2i_1f(int2 i) {
    return iq_hash_2u_1f(asuint(i));
}

// shader graph doesn't support ints as input (it will make symmetries along the axis), so just fake it using floor
void iq_hash_2i_1f_float(float2 f, out float Out) {
    int2 i = asint(floor(f));
    Out = iq_hash_2i_1f(asint(i));
}

#endif