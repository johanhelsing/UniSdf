// source: https://www.ronja-tutorials.com/post/036-sdf-space-manipulation/

#ifndef UNISDF_RONJA_SPACE_HLSL
#define UNISDF_RONJA_SPACE_HLSL

#include "../common.hlsl"

float2 ronja_radial_cells(float2 position, float cells, out float index, bool mirrorEverySecondCell = false){
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

#endif
