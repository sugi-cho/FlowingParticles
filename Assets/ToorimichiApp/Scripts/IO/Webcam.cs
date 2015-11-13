using UnityEngine;
using System.Collections;

public class Webcam : MonoBehaviour
{
	public string propEmit = "_EmitTex";
	public string propKage = "_CameraKage";
	public string propProcessedTex = "_ProcessWebTex";
	public Material processMat;
	[SerializeField]
	RenderTexture
		output;
	RenderTexture rt;
	WebCamTexture wc;
	// Use this for initialization
	void Start ()
	{
		wc = new WebCamTexture (640, 400);
		wc.Play ();
		Shader.SetGlobalTexture (propEmit, wc);
		Shader.SetGlobalTexture (propKage, wc);

		rt = Extensions.CreateRenderTexture (640, 400);
		output = Extensions.CreateRenderTexture (640, 400);
		Shader.SetGlobalTexture (propProcessedTex, output);
	}

	void Update ()
	{
		Graphics.Blit (wc, rt);
		rt.GetBlur (0.5f, 2, 1);
		Graphics.Blit (rt, output, processMat);
	}
}
