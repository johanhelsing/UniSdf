using UnityEngine;
using UnityEngine.UI;

namespace UniSdf
{
    public class CanvasGraph : Graphic
    {
        [Tooltip("Pixels to grow the vertices in each direction. Use this for drop shadows or other effects that might extend outside the rect.")]
        [SerializeField] private float _extendPixels = 0f;

        [Tooltip("Instance data can be used to pass custom data to the shader. Will only work if the canvas is set up to use additional UV channels.")]

        // There is a bug in Unity where uv1 is overwritten, uv2 and uv3 still work, though.
        [SerializeField] private Vector4 _uv2;
        [SerializeField] private Vector4 _uv3;

        /// <summary>
        /// Pixels to grow the vertices in each direction
        /// 
        /// Use this for drop shadows or other effects that might extend outside the rect.
        /// </summary>
        public float ExtendPixels
        {
            get => _extendPixels;
            set
            {
                if (Mathf.Approximately(_extendPixels, value)) return;
                _extendPixels = value;
                SetVerticesDirty();
            }
        }

        /// <summary>
        /// Custom instance data that can be used in the shader.
        /// </summary>
        public Vector4 Uv2
        {
            get => _uv2;
            set
            {
                if (_uv2 == value) return;
                _uv2 = value;
                SetVerticesDirty();
            }
        }

        /// <summary>
        /// Custom instance data that can be used in the shader.
        /// </summary>
        public Vector4 Uv3
        {
            get => _uv3;
            set
            {
                if (_uv3 == value) return;
                _uv3 = value;
                SetVerticesDirty();
            }
        }

#if UNITY_EDITOR
        protected override void OnValidate()
        {
            base.OnValidate();
            SetVerticesDirty();
        }
#endif

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

            // Calculate UVs so that uvs go from 0 to 1 over the original rect size
            var uvXOffset = (width + _extendPixels) / width;
            var uvYOffset = (height + _extendPixels) / height;
            var uvX0 = 1 - uvXOffset;
            var uvY0 = 1 - uvYOffset;
            var uvX1 = uvXOffset;
            var uvY1 = uvYOffset;

            var uv1 = Vector4.zero; // Canvas shader graph ignores overwrites this uv channel

            vh.Clear();

            // GOTCHA: can't use AddUIVertexQuad, as it ignores uv2 and uv3

            // Bottom-left
            vh.AddVert(
                new Vector3(rect.xMin, rect.yMin),
                color,
                new Vector4(uvX0, uvY0, width, height),
                uv1,
                _uv2,
                _uv3,
                UIVertex.simpleVert.normal,
                UIVertex.simpleVert.tangent
            );

            // Top-left
            vh.AddVert(
                new Vector3(rect.xMin, rect.yMax),
                color,
                new Vector4(uvX0, uvY1, width, height),
                uv1,
                _uv2,
                _uv3,
                UIVertex.simpleVert.normal,
                UIVertex.simpleVert.tangent
            );

            // Top-right
            vh.AddVert(
                new Vector3(rect.xMax, rect.yMax),
                color,
                new Vector4(uvX1, uvY1, width, height),
                uv1,
                _uv2,
                _uv3,
                UIVertex.simpleVert.normal,
                UIVertex.simpleVert.tangent
            );

            // Bottom-right
            vh.AddVert(
                new Vector3(rect.xMax, rect.yMin),
                color,
                new Vector4(uvX1, uvY0, width, height),
                uv1,
                _uv2,
                _uv3,
                UIVertex.simpleVert.normal,
                UIVertex.simpleVert.tangent
            );

            vh.AddTriangle(0, 1, 2);
            vh.AddTriangle(2, 3, 0);
        }
    }
}
