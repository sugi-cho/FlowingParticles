using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class MultiRenderTexture : MonoBehaviour
{
	public Material updateMat;
	public string[] propNames;
	public RenderTextureUtil util;
	public bool showTex;

	public int[] initRenderPasses;
	public int[] updateRenderPasses;

	List<RenderTexture[]>
		rtsList;
	RenderTexture dRt;
	
	public void Render (int pass = 0)
	{
		var cBuffers = rtsList.Select (b => b [0].colorBuffer).ToArray ();
		var dBuffer = dRt.depthBuffer;
		Graphics.SetRenderTarget (cBuffers, dBuffer);
		updateMat.DrawFullscreenQuad (pass);
		SetProps ();
		SwapRts ();
		Graphics.SetRenderTarget (null);
	}

	void Start ()
	{
		rtsList = new List<RenderTexture[]> ();
		for (var i=0; i<propNames.Length; i++) 
			rtsList.Add (CreateRenderTextures (propNames [i]));
		
		dRt = new RenderTexture (util.texSize, util.texSize, 24, RenderTextureFormat.Depth);
		dRt.filterMode = util.filterMode;
		dRt.wrapMode = util.wrapMode;
		dRt.name = "DepthTexture";

		for (var i = 0; i<initRenderPasses.Length; i++)
			Render (initRenderPasses [i]);
	}
	void Update ()
	{
		for (var i = 0; i < updateRenderPasses.Length; i++)
			Render (updateRenderPasses [i]);
	}

	void OnDestroy ()
	{
		foreach (var rts in rtsList) {
			for (var i = 0; i < 2; i++) {
				if (rts [i] != null) {
					rts [i].Release ();
					Destroy (rts [i]);
				}
			}
		}
	}

	RenderTexture[] CreateRenderTextures (string name="output")
	{
		var rts = new RenderTexture[2];
		for (var i = 0; i<2; i++) {
			rts [i] = new RenderTexture (util.texSize, util.texSize, 0, util.format);
			rts [i].filterMode = util.filterMode;
			rts [i].wrapMode = util.wrapMode;
			rts [i].name = name;
		}
		return rts;
	}

	void SwapRts ()
	{
		foreach (var rts in rtsList) {
			var tmp = rts [0];
			rts [0] = rts [1];
			rts [1] = tmp;
		}
	}
	void SetProps ()
	{
		Shader.SetGlobalInt ("_MRT_TexSize", util.texSize);
		for (var i = 0; i < rtsList.Count; i++) 
			Shader.SetGlobalTexture (rtsList [i] [0].name, rtsList [i] [0]);

	}

	void OnGUI ()
	{
		if (!showTex)
			return;
		for (var i = 0; i < rtsList.Count; i++) {
			GUILayout.Label (rtsList [i] [0], GUILayout.Width (util.texSize));
		}
	}

	[System.Serializable]
	public class RenderTextureUtil
	{
		public int texSize = 64;
		public RenderTextureFormat format;
		public FilterMode filterMode;
		public TextureWrapMode wrapMode;
	}
}
