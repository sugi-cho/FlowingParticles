using UnityEngine;
using System.Collections;

public class MRT : MonoBehaviour
{

	public string[] bufferNames = new string[4]{"_Tex0","_Tex1","_Tex2","_Tex3"};
	public string depthBufferName = "_PostBlendDepth";
	public Material clearMat;
	public OutputProp[] outputs;

	public bool showTex;
	public bool write2out;

	[SerializeField]
	RenderTexture[]
		rts;
	[SerializeField]
	RenderTexture
		dRt;
	RenderBuffer[] buffers;
	Camera cam;
	Vector4 rectProp;

	// Use this for initialization
	void Start ()
	{
		cam = GetComponent<Camera> ();
		cam.hdr = true;
		
		rts = new RenderTexture[bufferNames.Length];
		buffers = new RenderBuffer[bufferNames.Length];
		for (int i = 0; i < rts.Length; i++) {
			rts [i] = new RenderTexture ((int)cam.pixelWidth, (int)cam.pixelHeight, 0, RenderTextureFormat.ARGBFloat);
			rts [i].filterMode = FilterMode.Point;
			rts [i].name = bufferNames [i];
			rts [i].Create ();
			buffers [i] = rts [i].colorBuffer;
		}
		dRt = new RenderTexture ((int)cam.pixelWidth, (int)cam.pixelHeight, 24, RenderTextureFormat.Depth);
		dRt.name = depthBufferName;
		
//		output = new RenderTexture ((int)cam.pixelWidth, (int)cam.pixelHeight, 24, RenderTextureFormat.ARGBFloat);
//		output.name = "_CompMRT" + name;
//		Shader.SetGlobalTexture (output.name, output);
		
		cam.SetTargetBuffers (buffers, dRt.depthBuffer);

		rectProp = new Vector4 (cam.rect.xMin, cam.rect.yMin, cam.rect.xMax, cam.rect.yMax);
		cam.rect = Rect.MinMaxRect (0, 0, 1f, 1f);
	}
	void OnDestroy ()
	{
		ReleaseRenderTextures ();
	}

	void ReleaseRenderTextures ()
	{
		for (int i = 0; i < rts.Length; i++) 
			Extensions.ReleaseRenderTexture (rts [i]);
		Extensions.ReleaseRenderTexture (dRt);
//		Extensions.ReleaseRenderTexture (output);
	}
	
	void OnPreRender ()
	{
		Graphics.SetRenderTarget (buffers, dRt.depthBuffer);
		if (clearMat != null)
			clearMat.DrawFullscreenQuad ();
	}

	void OnPostRender ()
	{
		Graphics.SetRenderTarget (null);
		foreach (var output in outputs)
			output.Render (rts, dRt);

	}

	void OnGUI ()
	{
		if (!showTex)
			return;
		GUILayout.BeginVertical ();
		foreach (var t in rts) {
			GUILayout.Label (t.name);
			GUILayout.Label (t, GUILayout.Height (50));
		}
		GUILayout.EndVertical ();
	}
	[System.Serializable]
	public class OutputProp
	{
		public Material mat;
		public RenderTexture output;
		public string propName;

		void Init ()
		{
			output = new RenderTexture (Screen.width, Screen.height, 24, RenderTextureFormat.ARGBFloat);
			output.name = propName;
			Shader.SetGlobalTexture (output.name, output);
		}
		public void Render (RenderTexture[] rts, RenderTexture dRt)
		{
			if (output == null)
				Init ();
			foreach (var rt in rts)
				mat.SetTexture (rt.name, rt);
			mat.SetTexture (dRt.name, dRt);
			Graphics.Blit (null, output, mat);
		}
	}
}
