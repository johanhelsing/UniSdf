using UnityEngine;
using UnityEngine.UI;

namespace UniSdf
{
    public class CanvasGraph : Graphic
    {
        /// <summary>
        /// Pixels to grow the vertices in each direction
        /// 
        /// Use this for drop shadows or other effects that might extend outside the rect.
        /// </summary>
        [SerializeField] private float _extendPixels = 0f;

        protected override void OnPopulateMesh(VertexHelper vh)
        {
            var rect = GetPixelAdjustedRect();
            var width = rect.width;
            var height = rect.height;

            // Expand rect by extendPixels in each direction
            rect.xMin -= _extendPixels;
            rect.yMin -= _extendPixels;
            rect.xMax += _extendPixels;
            rect.yMax += _extendPixels;

            var vertex = UIVertex.simpleVert;
            vertex.color = color;
            // Set width and height in unused UV channels
            vertex.uv0.z = width;
            vertex.uv0.w = height;

            // Calculate UVs so that uvs go from 0 to 1 over the original rect size
            var uvXOffset = (width + _extendPixels) / width;
            var uvYOffset = (height + _extendPixels) / height;
            var uvX0 = 1 - uvXOffset;
            var uvY0 = 1 - uvYOffset;
            var uvX1 = uvXOffset;
            var uvY1 = uvYOffset;

            vh.Clear();
            var v1 = vertex;
            v1.position = new Vector3(rect.xMin, rect.yMin);
            v1.uv0.x = uvX0;
            v1.uv0.y = uvY0;

            var v2 = vertex;
            v2.position = new Vector3(rect.xMin, rect.yMax);
            v2.uv0.x = uvX0;
            v2.uv0.y = uvY1;

            var v3 = vertex;
            v3.position = new Vector3(rect.xMax, rect.yMax);
            v3.uv0.x = uvX1;
            v3.uv0.y = uvY1;

            var v4 = vertex;
            v4.position = new Vector3(rect.xMax, rect.yMin);
            v4.uv0.x = uvX1;
            v4.uv0.y = uvY0;

            vh.AddUIVertexQuad(new[] { v1, v2, v3, v4 });
        }
    }
}
