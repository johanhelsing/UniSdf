// source: https://www.ronja-tutorials.com/post/036-sdf-space-manipulation/

#ifndef UNISDF_RONJA_SPACE_HLSL
#define UNISDF_RONJA_SPACE_HLSL

#include "../common.hlsl"

float2 ronja_radial_cells(float2 position, float cells, out float index, bool mirrorEverySecondCell = false)
{
    float cellSize = PI * 2 / cells;
    float2 radialPosition = float2(atan2(position.x, position.y), length(position));

    float cellIndex = fmod(floor(radialPosition.x / cellSize) + cells, cells);

    radialPosition.x = fmod(fmod(radialPosition.x, cellSize) + cellSize, cellSize);

    if(mirrorEverySecondCell){
        float flip = fmod(cellIndex, 2);
        flip = abs(flip-1);
        radialPosition.x = lerp(cellSize - radialPosition.x, radialPosition.x, flip);
    }

    sincos(radialPosition.x, position.x, position.y);
    position = position * radialPosition.y;

    index = cellIndex;
    return position;
}

void ronja_radial_cells_float(float2 position, float cells, out float2 out_position, out float index)
{
    out_position = ronja_radial_cells(position, cells, index);
}

void ronja_radial_cells_mirrored_float(float2 position, float cells, out float2 out_position, out float index)
{
    out_position = ronja_radial_cells(position, cells, index, true);
}

float2 ronja_wobble(float2 position, float2 frequency, float2 amount)
{
    float2 wobble = sin(position.yx * frequency) * amount;
    return position + wobble;
}

DECLARE_2F2F2F_2F(ronja_wobble);

float4 ronja_debug_lines(float dist, float4 inside_color = float4(1, 0, 0, 1), float4 outside_color = float4(0, 1, 0, 1), float line_distance = 1, float line_thickness = 0.05, float sub_lines = 3, float sub_line_thickness = 0.0025)
{
    float4 col = lerp(inside_color, outside_color, step(0, dist));
    float distanceChange = fwidth(dist) * 0.5;
    float majorLineDistance = abs(frac(dist / line_distance + 0.5) - 0.5) * line_distance;
    float majorLines = smoothstep(line_thickness - distanceChange, line_thickness + distanceChange, majorLineDistance);
    float distanceBetweenSubLines = line_distance / sub_lines;
    float subLineDistance = abs(frac(dist / distanceBetweenSubLines + 0.5) - 0.5) * distanceBetweenSubLines;
    float subLines = smoothstep(sub_line_thickness - distanceChange, sub_line_thickness + distanceChange, subLineDistance);
    return col * majorLines * subLines;
}

DECLARE_1F4F4F1F1F1F1F_4F(ronja_debug_lines);

#endif
