using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// �}�E�X����o��Ray�ƃI�u�W�F�N�g�̏Փˍ��W��Shader�ɓn��
/// �K���ȃI�u�W�F�N�g�ɃA�^�b�`
/// </summary>
public class MouseRayHitPointSendToShader : MonoBehaviour
{
    /// <summary>
    /// �|�C���^�[���o�������I�u�W�F�N�g�̃����_���[
    /// �O��FShader�͍��W�󂯎��ɑΉ��������̂�K�p
    /// </summary>
    [SerializeField]
    private Renderer _renderer;

    /// <summary>
    /// Shader���Œ�`�ς݂̍��W���󂯎��ϐ�
    /// </summary>
    private string _propName = "_MousePosition";

    private Material _mat;

    // Start is called before the first frame update
    void Start()
    {
        _mat = _renderer.material;
    }

    // Update is called once per frame
    void Update()
    {
        //�}�E�X�̓���
        if (Input.GetMouseButton(0))
        {
            //Ray�o��
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit_info = new RaycastHit();
            float max_distance = 100f;

            bool is_hit = Physics.Raycast(ray, out hit_info, max_distance);

            //Ray�ƃI�u�W�F�N�g���Փ˂����Ƃ��̏���������
            if (is_hit)
            {
                //�Փ�
                Debug.Log(hit_info.point);
                //Shader�ɍ��W��n��
                _mat.SetVector(_propName, hit_info.point);
            }
        }
    }
}
