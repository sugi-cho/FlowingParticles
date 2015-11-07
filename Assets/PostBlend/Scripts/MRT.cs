using UnityEngine;
using System.Collections;

public class MRT : MonoBehaviour
{

	public string[] bufferNames = new string[4]{"_Tex0","_Tex1","_Tex2","_Tex3"};
	public string depthBufferName = "_PostBlendDepth";
	public Material clearMat;
	public Material compMat;
	public RenderTexture output;

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
			rts [i] = new RenderTexture ((int)cam.pixelWidth, (int)cam.pixelHeight, 0, RenderTextureFormat.ARGBHalf);
			rts [i].filterMode = FilterMode.Point;
			rts [i].name = bufferNames [i];
			rts [i].Create ();
			buffers [i] = rts [i].colorBuffer;
		}
		dRt = new RenderTexture ((int)cam.pixelWidth, (int)cam.pixelHeight, 24, RenderTextureFormat.Depth);
		dRt.name = depthBufferName;

		output = new RenderTexture ((int)cam.pixelWidth, (int)cam.pixelHeight, 24, RenderTextureFormat.ARGBHalf);
		output.name = "_CompMRT" + name;
		Shader.SetGlobalTexture (output.name, output);

		cam.SetTargetBuffers (buffers, dRt.depthBuffer);
		rectProp = new Vector4 (cam.rect.xMin, cam.rect.yMin, cam.rect.xMax, cam.rect.yMax);
		cam.rect = Rect.MinMaxRect (0, 0, 1f, 1f);
	}
	void OnDestroy ()
	{
		for (int i = 0; i < rts.Length; i++) 
			Extensions.ReleaseRenderTexture (rts [i]);

	}

	
	void OnPreRender ()
	{
		Graphics.SetRenderTarget (buffers, dRt.depthBuffer);
		if (clearMat != null)
			clearMat.DrawFullscreenQuad ();
//		cam.SetTargetBuffers (buffers, dRt.depthBuffer);
	}

	void OnPostRender ()
	{
		Graphics.SetRenderTarget (null);
		if (compMat == null)
			return;
		foreach (var rt in rts)
			compMat.SetTexture (rt.name, rt);
		compMat.SetTexture (dRt.name, dRt);
		compMat.SetVector ("_CamRect", rectProp);
		if (write2out)
			Graphics.Blit (null, output, compMat);
		else
			Graphics.Blit (null, compMat);
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
}
