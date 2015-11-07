using UnityEngine;
using System.Collections;
using System.IO;
using System.Linq;

public class DirectoryWatcher : MonoBehaviour
{
	public string path;
	public float deltaCheck = 0.05f;
	public int width = 736, height = 480;
	[SerializeField]
	string
		fileName;
	[SerializeField]
	Texture2D
		texture;

	// Use this for initialization
	void Start ()
	{
		InvokeRepeating ("Check", deltaCheck, deltaCheck);
		texture = new Texture2D (width, height);
	}

	void Check ()
	{
		var files = Directory.GetFiles (path, "*.png");
		var newFile = files.LastOrDefault ();
		if (newFile != fileName) {
			fileName = newFile;
			var bytes = File.ReadAllBytes (fileName);
			texture.LoadImage (bytes);
		}
	}

	void Update ()
	{

	}
}
