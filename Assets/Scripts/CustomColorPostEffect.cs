using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 自作ポストエフェクトを適用する
/// ImageEffectAllowedInSceneViewというアトリビュートを使うことでシーンビューにも反映される
/// </summary>
[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CustomColorPostEffect : MonoBehaviour
{
    [SerializeField] private Material _colorEffectMaterial;

    private enum UsePass
    {
        UsePass1,
        UsePass2
    }

    [SerializeField] private UsePass _usePass;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, _colorEffectMaterial, (int)_usePass);
    }
}
