#ifndef UNISDF_COMMON_HLSL
#define UNISDF_COMMON_HLSL

// Utilities and constants

#ifndef PI
#define PI 3.1415926538
#endif

#ifndef PHI
#define PHI 1.618034
#endif

float dot2(float2 v)
{
    return dot(v,v);
}

float pow2(float x)
{
    return x * x;
}

float pow3(float x)
{
    return x * x * x;
}

float2 pow3(float2 x)
{
    return x * x * x;
}

float pow4(float x)
{
    return pow2(pow2(x));
}

float pow5(float x)
{
    return pow4(x) * x;
}

// Shader graph interfaces:

#define DECLARE_1F_1F(name) \
    void name##_float(float x, out float Out) \
    { \
        Out = name(x); \
    }

#define DECLARE_1F1F_1F(name) \
    void name##_float(float x, float y, out float Out) \
    { \
        Out = name(x, y); \
    }

#define DECLARE_1F1F_3F(name) \
    void name##_float(float x, float y, out float3 Out) \
    { \
        Out = name(x, y); \
    }

#define DECLARE_1F1F1F_1F(name) \
    void name##_float(float x, float y, float z, out float Out) \
    { \
        Out = name(x, y, z); \
    }

#define DECLARE_2F_1F(name) \
    void name##_float(float2 x, out float Out) \
    { \
        Out = name(x); \
    }

#define DECLARE_2F_2F(name) \
    void name##_float(float2 x, out float2 Out) \
    { \
        Out = name(x); \
    }

#define DECLARE_2F1F_1F(name) \
    void name##_float(float2 x, float y, out float Out) \
    { \
        Out = name(x, y); \
    }

#define DECLARE_2F1F1F1F_1F(name) \
    void name##_float(float2 x, float y, float z, float w, out float Out) \
    { \
        Out = name(x, y, z, w); \
    }

#define DECLARE_2F1F_2F(name) \
    void name##_float(float2 x, float y, out float2 Out) \
    { \
        Out = name(x, y); \
    }

#define DECLARE_2F2F_1F(name) \
    void name##_float(float2 x, float2 y, out float Out) \
    { \
        Out = name(x, y); \
    }

#define DECLARE_2F1F2F_2F(name) \
    void name##_float(float2 x, float y, float2 z, out float2 Out) \
    { \
        Out = name(x, y, z); \
    }

#define DECLARE_2F2F2F_2F(name) \
    void name##_float(float2 x, float2 y, float2 z, out float2 Out) \
    { \
        Out = name(x, y, z); \
    }

#define DECLARE_2F2F2F1F1F_1F(name) \
    void name##_float(float2 a, float2 b, float2 c, float d, float e, out float Out) \
    { \
        Out = name(a, b, c, d, e); \
    }


#define DECLARE_3F_1F(name) \
    void name##_float(float3 x, out float Out) \
    { \
        Out = name(x); \
    }

#define DECLARE_3F_2F(name) \
    void name##_float(float3 x, out float2 Out) \
    { \
        Out = name(x); \
    }

#define DECLARE_3F_4F(name) \
    void name##_float(float3 x, out float4 Out) \
    { \
        Out = name(x); \
    }

#define DECLARE_3F1F_1F(name) \
    void name##_float(float3 x, float y, out float Out) \
    { \
        Out = name(x, y); \
    }

#define DECLARE_3F1F_3F(name) \
    void name##_float(float3 x, float y, out float3 Out) \
    { \
        Out = name(x, y); \
    }

#define DECLARE_3F3F_1F(name) \
    void name##_float(float3 x, float3 y, out float Out) \
    { \
        Out = name(x, y); \
    }

#define DECLARE_3F3F1F_1F(name) \
    void name##_float(float3 x, float3 y, float z, out float Out) \
    { \
        Out = name(x, y, z); \
    }

#define DECLARE_3F3F3F_1F(name) \
    void name##_float(float3 x, float3 y, float3 z, out float Out) \
    { \
        Out = name(x, y, z); \
    }

#define DECLARE_3F3F3F1F_1F(name) \
    void name##_float(float3 x, float3 y, float3 z, float w, out float Out) \
    { \
        Out = name(x, y, z, w); \
    }

#define DECLARE_3F3F3F1F_2F(name) \
    void name##_float(float3 x, float3 y, float3 z, float w, out float2 Out) \
    { \
        Out = name(x, y, z, w); \
    }

#define DECLARE_3F3F_3F(name) \
    void name##_float(float3 x, float3 y, out float3 Out) \
    { \
        Out = name(x, y); \
    }

#define DECLARE_4F1F_4F(name) \
    void name##_float(float4 x, float y, out float4 Out) \
    { \
        Out = name(x, y); \
    }

#endif