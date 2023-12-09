using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// �I�u�W�F�N�g���Փ˂����ӏ��ɔg��𔭐�������
/// </summary>
public class CollisionRipple : MonoBehaviour
{
    [SerializeField] 
    private CustomRenderTexture _customRenderTexture;
    [SerializeField, Range(0.001f, 0.05f)] 
    private float _ripppleSize = 0.01f;
    [SerializeField] 
    private int _iterationPerFrame = 5;

    private CustomRenderTextureUpdateZone _defaultZone;

    private const float TOLERANCE = 1E-2f;
    private int[] _meshTriangles;
    private Vector3[] _meshVertices;
    private Vector2[] _meshUV;
    private MeshFilter _meshFilter;

    // Start is called before the first frame update
    void Start()
    {
        _meshFilter = GetComponent<MeshFilter>();
        _meshTriangles = _meshFilter.mesh.triangles;
        _meshVertices = _meshFilter.mesh.vertices;
        _meshUV = _meshFilter.mesh.uv;

        //������
        _customRenderTexture.Initialize();

        //�g���������̃V�~�����[�g�p��UpdateZone
        //�S�̂̍X�V�p
        _defaultZone = new CustomRenderTextureUpdateZone
        {
            needSwap = true,
            passIndex = 0,
            rotation = 0f,
            updateZoneCenter = new Vector2(0.5f, 0.5f),
            updateZoneSize = new Vector2(1f, 1f)
        };
    }

    //Update�̓_���@���C�t�T�C�N���v�Q��
    private void FixedUpdate()
    {
        //UpdateZone�̓��Z�b�g
        _customRenderTexture.ClearUpdateZones();
        //�X�V�������t���[�������w�肵�čX�V
        _customRenderTexture.Update(_iterationPerFrame);
    }

    private void OnTriggerStay(Collider other)
    {
        Debug.Log("a");
        //�Փˍ��W(���[���h���W)
        var hitPos = other.ClosestPointOnBounds(transform.position);
        //���[���h���W���烍�[�J�����W�ɕϊ�
        var hitLocalPos = transform.InverseTransformPoint(hitPos);
        //p��uv�ɕϊ����đ���@������������s
        if (LocalPointToUV(hitLocalPos, out var uv))
        {
            //�Փˎ��Ɏg�p����UpdateZone
            //�Փ˂����ӏ����X�V�̌��_�Ƃ���
            //�g�p����p�X���Փ˗p�ɕύX
            var interactiveZone = new CustomRenderTextureUpdateZone
            {
                needSwap = true,
                passIndex = 1,
                rotation = 0f,
                updateZoneCenter = new Vector2(uv.x, 1 - uv.y),
                updateZoneSize = new Vector2(_ripppleSize, _ripppleSize)
            };

            _customRenderTexture.SetUpdateZones(new CustomRenderTextureUpdateZone[] { _defaultZone, interactiveZone });
        }
    }

    private void OnTriggerExit(Collider other)
    {
        //�N���b�N����UpdateZone���N���b�N����K�����ꂽ��ԂɂȂ�Ȃ��悤�Ɉ�x��������
        _customRenderTexture.ClearUpdateZones();
    }

    /// <summary>
    /// �󂯎�������[�J�����W��UV���W�ɕϊ�
    /// </summary>
    /// <param name="localPoint">�C�ӂ̃��[�J�����W</param>
    /// <param name="uv">�ϊ����UV���W</param>
    /// <returns>�ϊ��ɐ���������True</returns>
    private bool LocalPointToUV(Vector3 localPoint, out Vector2 uv)
    {
        //�����܂ő卷�Ȃ��炵�����ǈꉞfor���̊O�Ő錾
        int index0;
        int index1;
        int index2;
        Vector3 t1;
        Vector3 t2;
        Vector3 t3;

        //Mesh���ɑ��݂���O�p�`�𒲍�
        //����_p���^����ꂽ3�_�ɂ����ĕ��ʏ�ɑ��݂��邩�v�Z
        for (var i = 0; i < _meshTriangles.Length; i += 3)
        {
            index0 = i + 0;
            index1 = i + 1;
            index2 = i + 2;

            //�O�p�`�̊e���_
            t1 = _meshVertices[_meshTriangles[index0]];
            t2 = _meshVertices[_meshTriangles[index1]];
            t3 = _meshVertices[_meshTriangles[index2]];

            //���ꕽ�ʏ�ɔC�ӂ̍��W����`����Ă��邩�ǂ����`�F�b�N
            if (!CheckInPlane(localPoint, t1, t2, t3))
                continue;
            //�O�p�`�̓����ɑ��݂��邩�ǂ����@���E��(�ӂ̏�A���_�̐^��)���`�F�b�N
            if (!CheckOnTriangleEdge(localPoint, t1, t2, t3) && !CheckInTriangle(localPoint, t1, t2, t3))
                continue;

            //�O�p�`�̊e���_��UV���擾
            var uv1 = _meshUV[_meshTriangles[index0]];
            var uv2 = _meshUV[_meshTriangles[index1]];
            var uv3 = _meshUV[_meshTriangles[index2]];
            //UV���W�ɕϊ�
            uv = CalculateUV(localPoint, t1, uv1, t2, uv2, t3, uv3);
            return true;
        }

        uv = default(Vector3);
        return false;
    }

    /// <summary>
    /// ���ꕽ�ʏ�ɔC�ӂ̍��W����`����Ă��邩�ǂ�������
    /// </summary>
    /// <param name="p">�����Ώۂ̍��W</param>
    /// <param name="t1">�O�p�`�|���S���̒��_���W1</param>
    /// <param name="t2">�O�p�`�|���S���̒��_���W2</param>
    /// <param name="t3">�O�p�`�|���S���̒��_���W3</param>
    /// <returns>���ꕽ�ʏ�ɔC�ӂ̍��W����`����Ă�����True</returns>
    private bool CheckInPlane(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
    {
        //�e�_���m�̐����x�N�g�����v�Z
        var v1 = t2 - t1;
        var v2 = t3 - t1;
        var vp = p - t1;

        //�O�ςɂ��O�p�`�|���S���̒��_�̖@���������Z�o
        var nv = Vector3.Cross(v1, v2);
        //���ςɂ�锻��@���ꕽ�ʂł���ꍇ�A�v�Z���ʂ�0
        var val = Vector3.Dot(nv.normalized, vp.normalized);
        //�v�Z�̌덷�����e���邽�߂̔���
        if (-TOLERANCE < val && val < TOLERANCE)
        {
            return true;
        }

        return false;
    }

    /// <summary>
    /// ���ꕽ�ʏ�ɑ��݂���C�ӂ̍��W���O�p�`�����ɑ��݂��邩�ǂ���
    /// ���E��(�ӂ̏�A���_�̐^��)�͔���O
    /// </summary>
    /// <param name="p">�����Ώۂ̍��W</param>
    /// <param name="t1">�O�p�`�|���S���̒��_���W1</param>
    /// <param name="t2">�O�p�`�|���S���̒��_���W2</param>
    /// <param name="t3">�O�p�`�|���S���̒��_���W3</param>
    /// <returns>���ꕽ�ʏ�ɑ��݂���C�ӂ̍��W���O�p�`�����ɑ��݂��Ă�����True</returns>
    private bool CheckInTriangle(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
    {
        //�O�ςɂ��O�p�`�|���S���̊e���_�̖@���������Z�o
        var a = Vector3.Cross(t1 - t3, p - t1).normalized;
        var b = Vector3.Cross(t2 - t1, p - t2).normalized;
        var c = Vector3.Cross(t3 - t2, p - t3).normalized;

        //���ς𗘗p���Ė@�������������������ǂ����v�Z�@���������Ȃ�1
        var d_ab = Vector3.Dot(a, b);
        var d_bc = Vector3.Dot(b, c);

        //�v�Z�̌덷�����e���邽�߂̔���
        if (1 - TOLERANCE < d_ab && 1 - TOLERANCE < d_bc)
        {
            return true;
        }

        return false;
    }

    /// <summary>
    /// ���W�̏�񂩂�UV���W���Z�o����
    /// </summary>
    /// <param name="p">�����Ώۂ̍��W</param>
    /// <param name="t1">�O�p�`�|���S���̒��_���W1</param>
    /// <param name="t1UV">�O�p�`�|���S���̒��_��UV���W1</param>
    /// <param name="t2">�O�p�`�|���S���̒��_���W2</param>
    /// <param name="t2UV">�O�p�`�|���S���̒��_��UV���W2</param>
    /// <param name="t3">�O�p�`�|���S���̒��_���W3</param>
    /// <param name="t3UV">�O�p�`�|���S���̒��_��UV���W3</param>
    /// <returns>UV���W</returns>
    private Vector2 CalculateUV(Vector3 p, Vector3 t1, Vector2 t1UV, Vector3 t2, Vector2 t2UV, Vector3 t3, Vector2 t3UV)
    {
        //���C���J�����擾
        var renderCamera = Camera.main;
        //�v���W�F�N�V�����ϊ������O��MVP�s�� = �v���W�F�N�V�����s�� * �r���[�s�� * ���f���s��
        Matrix4x4 mvp = renderCamera.projectionMatrix * renderCamera.worldToCameraMatrix * transform.localToWorldMatrix;
        //�e�_���v���W�F�N�V������Ԃ֕ϊ�
        Vector4 p1_p = mvp * new Vector4(t1.x, t1.y, t1.z, 1);
        Vector4 p2_p = mvp * new Vector4(t2.x, t2.y, t2.z, 1);
        Vector4 p3_p = mvp * new Vector4(t3.x, t3.y, t3.z, 1);
        Vector4 p_p = mvp * new Vector4(p.x, p.y, p.z, 1);
        //W�ŏ��Z���邱�ƂŃv���W�F�N�V�������W�ϊ��͊�������
        //Shader�ł͏���ɂ���Ă����炵�����A����͎����ł��@�����ϊ��Ƃ����炵��
        //Z(�[�x)�͔j��
        Vector2 p1_n = new Vector2(p1_p.x, p1_p.y) / p1_p.w;
        Vector2 p2_n = new Vector2(p2_p.x, p2_p.y) / p2_p.w;
        Vector2 p3_n = new Vector2(p3_p.x, p3_p.y) / p3_p.w;
        Vector2 p_n = new Vector2(p_p.x, p_p.y) / p_p.w;
        //���_�̂Ȃ��O�p�`��_p�ɂ��3�������A�K�v�ɂȂ�ʐς��v�Z
        //�O�p�`��񕪊����Ē�Ӂ~�������v�Z������Ɂ�2���Ă�
        var s = ((p2_n.x - p1_n.x) * (p3_n.y - p1_n.y) - (p2_n.y - p1_n.y) * (p3_n.x - p1_n.x)) / 2; //�S��
        var s1 = ((p3_n.x - p_n.x) * (p1_n.y - p_n.y) - (p3_n.y - p_n.y) * (p1_n.x - p_n.x)) / 2; //���������ꕔ
        var s2 = ((p1_n.x - p_n.x) * (p2_n.y - p_n.y) - (p1_n.y - p_n.y) * (p2_n.x - p_n.x)) / 2; //���������ꕔ
        //�ʐϔ䂩��uv���� 
        var u = s1 / s;
        var v = s2 / s;
        //�p�[�X�y�N�e�B�u�R���N�g��K�p���A�ʐϔ�ŔC�ӂ�UV���W�����߂�
        var areaRatio = (1 - u - v) * 1 / p1_p.w + u * 1 / p2_p.w + v * 1 / p3_p.w;
        return ((1 - u - v) * t1UV / p1_p.w + u * t2UV / p2_p.w + v * t3UV / p3_p.w) / areaRatio;
    }

    /// <summary>
    /// �O�p�`�|���S���̊e�ӂ̏�ɍ��W�����邩�ǂ�������
    /// </summary>
    /// <param name="p">Points to investigate.</param>
    /// <param name="t1">�O�p�`�|���S���̒��_���W1</param>
    /// <param name="t2">�O�p�`�|���S���̒��_���W2</param>
    /// <param name="t3">�O�p�`�|���S���̒��_���W3</param>
    /// <returns>�O�p�`�|���S���̊e�ӂ̏�ɍ��W�������True</returns>
    private bool CheckOnTriangleEdge(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
    {
        return CheckOnEdge(p, t1, t2) || CheckOnEdge(p, t2, t3) || CheckOnEdge(p, t3, t1);
    }

    /// <summary>
    /// ���E��(���_)�̃`�F�b�N
    /// </summary>
    /// <param name="p">�����Ώۂ̍��W</param>
    /// <param name="v1">���_���W1</param>
    /// <param name="v2">���_���W2</param>
    /// <returns>�����Ώۂ̍��W�����E��ɂ����True</returns>
    private bool CheckOnEdge(Vector3 p, Vector3 v1, Vector3 v2)
    {
        return 1 - TOLERANCE < Vector3.Dot((v2 - p).normalized, (v2 - v1).normalized);
    }
}
