using UnityEngine;
using System.Collections;

public class SetMatrixPropertyToMaterial : MonoBehaviour
{
	public string propModelToWorld = "_MATRIX_O2W";
	public string propWorldToModel = "_MATRIX_W2O";
	public string propWorldToCam = "_MATRIX_W2C";
	public string propCamToWorld = "_MATRIX_C2W";
	public string propCamProjection = "_MATRIX_PROJECTION";
	public string propCamVP = "_MATRIX_VP";
	public string propScreenToWorld = "_MATRIX_S2W";

	public Material targetMat;

	Camera cam;

	// Use this for initialization
	void Start ()
	{
		cam = GetComponent<Camera> ();
	}
	
	// Update is called once per frame
	void Update ()
	{
		if (transform.hasChanged)
			SetParams ();
	}

	void SetParams ()
	{
		var modelToWorld = transform.localToWorldMatrix;
		var worldToModel = transform.worldToLocalMatrix;

		if (targetMat != null) {
			targetMat.SetMatrix (propModelToWorld, modelToWorld);
			targetMat.SetMatrix (propWorldToModel, worldToModel);
		} else {
			Shader.SetGlobalMatrix (propModelToWorld, modelToWorld);
			Shader.SetGlobalMatrix (propWorldToModel, worldToModel);
		}

		if (cam != null) {
			SetCamParams ();
		}
	}
	void SetCamParams ()
	{
		var worldToCam = cam.worldToCameraMatrix;
		var camToWorld = cam.cameraToWorldMatrix;
		var projection = cam.projectionMatrix;
		var inverseP = projection.inverse;
		var vp = projection * worldToCam;
		var screenToWorld = camToWorld * inverseP;
		
		if (targetMat != null) {
			targetMat.SetMatrix (propWorldToCam, worldToCam);
			targetMat.SetMatrix (propCamToWorld, camToWorld);
			targetMat.SetMatrix (propCamProjection, projection);
			targetMat.SetMatrix (propCamVP, vp);
			targetMat.SetMatrix (propScreenToWorld, screenToWorld);
		} else {
			Shader.SetGlobalMatrix (propWorldToCam, worldToCam);
			Shader.SetGlobalMatrix (propCamToWorld, camToWorld);
			Shader.SetGlobalMatrix (propCamProjection, projection);
			Shader.SetGlobalMatrix (propCamVP, vp);
			Shader.SetGlobalMatrix (propScreenToWorld, screenToWorld);
		}
	}
}
