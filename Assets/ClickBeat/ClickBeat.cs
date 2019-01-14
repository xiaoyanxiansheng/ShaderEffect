using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
interface IElastic
{
    void OnElastic(RaycastHit hit);
}
[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
public class ClickBeat : MonoBehaviour, IElastic
{
    private int s_pos, s_nor, s_time;
    private MeshRenderer mesh;

    void Awake()
    {
        mesh = GetComponent<MeshRenderer>();
        s_pos = Shader.PropertyToID("_Position");
        s_nor = Shader.PropertyToID("_Normal");
        s_time = Shader.PropertyToID("_PointTime");
    }

    private void Start()
    {
         
    }

    //调用该方法
    public void OnElastic(RaycastHit hit)
    {
        //反弹的坐标
        Vector4 v = transform.InverseTransformPoint(hit.point);
        //受影响顶点范围的半径
        v.w = 0.6f;
        mesh.material.SetVector(s_pos, v);
        //法线方向，该值为顶点偏移方向，可自己根据需求传。
        v = transform.InverseTransformDirection(hit.normal.normalized);
        //反弹力度
        v.w = 0.2f;
        mesh.material.SetVector(s_nor, v);
        //重置时间
        mesh.material.SetFloat(s_time, Time.time);
    }

    void Update()
    {
        if (!Input.GetMouseButtonDown(0))
        {
            return;
        }

        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hitInfo;
        if (Physics.Raycast(ray,out hitInfo))
        {
            OnElastic(hitInfo);
        }
    }
}
