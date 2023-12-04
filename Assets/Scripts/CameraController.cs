using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform target;    //Transform�^�������
    public float distance = 9.0f;  //float�^������
    public float xSpeed = 250.0f;
    public float ySpeed = 120.0f;
    public float yMinLimit = -45f;
    public float yMaxLimit = 85f;
    private float _x = 0.0f;
    private float _y = 0.0f;

    // Start is called before the first frame update
    void Start()
    {
        var angles = transform.eulerAngles;     //���̃Q�[���I�u�W�F�N�g�i�J�����j�̊p�x
        _x = angles.y;   //�uy�v�̒l���擾�i����j
        _y = angles.x;
    }

    // Update is called once per frame
    void Update()
    {
        if (target != null)
        {
            _x += Input.GetAxis("Mouse X") * xSpeed * 0.02f;
            _y -= Input.GetAxis("Mouse Y") * ySpeed * 0.02f;

            _y = ClampAngle(_y, yMinLimit, yMaxLimit);

            var rotation = Quaternion.Euler(_y, _x, 0);
            var position = rotation * new Vector3(0.0f, 0.0f, -distance) + target.position;

            //���ۂɃQ�[�����ɔ��f
            transform.rotation = rotation;
            transform.position = position;
        }
    }

    static float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360) { angle += 360; }
        if (angle > 360) { angle -= 360; }
        return Mathf.Clamp(angle, min, max);
    }
}