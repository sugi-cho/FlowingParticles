using UnityEngine;
using System.Collections;

public class MRT : MonoBehaviour
{

	public string[] bufferNames;
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
	Camera camera;
	Vector4 rectProp;

	// Use this for initialization
	void Start ()
	{
		camera = GetComponent<Camera> ();
		camera.hdr = true;
		rts = new RenderTexture[bufferNames.Length];
		buffers = new RenderBuffer[bufferNames.Length];
		for (int i = 0; i < rts.Length; i++) {
			rts [i] = new RenderTexture ((int)camera.pixelWidth, (int)camera.pixelHeight, 0, RenderTextureFormat.ARGBHalf);
			rts [i].filterMode = FilterMode.Point;
			rts [i].name = bufferNames [i];
			rts [i].Create ();
			buffers [i] = rts [i].colorBuffer;
		}
		dRt = new RenderTexture ((int)camera.pixelWidth, (int)camera.pixelHeight, 24, RenderTextureFormat.Depth);
		dRt.name = depthBufferName;

		output = new RenderTexture ((int)camera.pixelWidth, (int)camera.pixelHeight, 24, RenderTextureFormat.ARGBHalf);
		output.name = "_CompMRT" + name;
		Shader.SetGlobalTexture (output.name, output);

		camera.SetTargetBuffers (buffers, dRt.depthBuffer);
		rectProp = new Vector4 (camera.rect.xMin, camera.rect.yMin, camera.rect.xMax, camera.rect.yMax);
		camera.rect = Rect.MinMaxRect (0, 0, 1f, 1f);
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
//		camera.SetTargetBuffers (buffers, dRt.depthBuffer);
	}

	void OnPostRender ()
	{
		Graphics.SetRenderTarget (null);
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
