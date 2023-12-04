using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform target;    //Transform型をいれる
    public float distance = 9.0f;  //float型が入る
    public float xSpeed = 250.0f;
    public float ySpeed = 120.0f;
    public float yMinLimit = -45f;
    public float yMaxLimit = 85f;
    private float _x = 0.0f;
    private float _y = 0.0f;

    // Start is called before the first frame update
    void Start()
    {
        var angles = transform.eulerAngles;     //このゲームオブジェクト（カメラ）の角度
        _x = angles.y;   //「y」の値を取得（代入）
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

            //実際にゲーム内に反映
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