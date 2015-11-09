using UnityEngine;
using System.Collections;

public class Webcam : MonoBehaviour
{
	public string propEmit = "_EmitTex";
	public string propKage = "_CameraKage";
	// Use this for initialization
	void Start ()
	{
		var wc = new WebCamTexture (640, 400);
		wc.Play ();
		Shader.SetGlobalTexture (propEmit, wc);
		Shader.SetGlobalTexture (propKage, wc);
	}
}
