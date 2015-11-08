using UnityEngine;
using System.Collections;
using System.IO;
using System.Linq;

public class CalcCameraKage : MonoBehaviour
{
	public string path;
	public float deltaCheck = 0.05f;
	public int width = 736, height = 480;

	public string propName = "_CameraKage";
	public Material processMat;
	
	[SerializeField]
	string
		fileName;
	[SerializeField]
	Texture2D
		texture;
	[SerializeField]
	RenderTexture
		output;
	
	void Start ()
	{
		InvokeRepeating ("Check", deltaCheck, deltaCheck);
		texture = new Texture2D (width, height, TextureFormat.ARGB32, false);
		output = Extensions.CreateRenderTexture (width, height);
		Shader.SetGlobalTexture (propName, output);
	}
	
	void Check ()
	{
		try {
			var files = Directory.GetFiles (path, "*.png");
			var newFile = files.LastOrDefault ();
			if (newFile != fileName) {
				fileName = newFile;
				var bytes = File.ReadAllBytes (fileName);
				texture.LoadImage (bytes);
				ProcessTexture ();
			}
		} catch {
			Debug.Log ("network error");
		}
	}

	void ProcessTexture ()
	{
		if (processMat != null)
			Graphics.Blit (texture, output, processMat);
		else
			Graphics.Blit (texture, output);
		output.GetBlur (0.01f, 2, 1);
	}
}
