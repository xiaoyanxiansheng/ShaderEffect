using UnityEngine;
using System.Collections;

public class ZWGDissolveEnvironment : MonoBehaviour {

    public Vector3 dissolveStartPoint;
    [Range(0, 1)]
    public float dissolveThreshold = 0;
    [Range(0, 1)]
    public float distanceEffect = 0.6f;
    MeshFilter[] meshFilters;
    MeshRenderer[] meshRenderers;

    void Awake()
    {
        meshFilters = GetComponentsInChildren<MeshFilter>();
        meshRenderers = GetComponentsInChildren<MeshRenderer>();
    }

	// Use this for initialization
	void Start () {
        float maxDistance = 0;
        for (int i = 0; i < meshFilters.Length; i++)
        {
            float distance = CalculateMaxDistance(meshFilters[i].mesh.vertices);
            if (distance > maxDistance)
                maxDistance = distance;
        }
        for (int i = 0; i < meshRenderers.Length; i++)
        {
            meshRenderers[i].material.SetVector("_StartPoint", dissolveStartPoint);
            meshRenderers[i].material.SetFloat("_MaxDistance", maxDistance);
        }
    }
	
	// Update is called once per frame
	void Update () {
        for (int i = 0; i < meshRenderers.Length; i++)
        {
            meshRenderers[i].material.SetFloat("_Threshold", dissolveThreshold);
            meshRenderers[i].material.SetFloat("_DistanceEffect", distanceEffect);
        }
    }

    //计算给定顶点集到消融开始点的最大距离
    float CalculateMaxDistance(Vector3[] vertices)
    {
        float maxDistance = 0;
        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 vert = vertices[i];
            float distance = (vert - dissolveStartPoint).magnitude;
            if (distance > maxDistance)
                maxDistance = distance;
        }
        return maxDistance;
    }
}
