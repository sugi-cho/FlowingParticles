using UnityEngine;
using System.Collections;
using System.Net;
using System.Net.Sockets;

public class UdpSender : MonoBehaviour
{
	public string hostName = "localhost";
	public int sendToPort = 6666;
	public Texture2D source;

	UdpClient udpClient;
	IPEndPoint endPoint;
	
	public void Send ()
	{
//		try {
		udpClient = new UdpClient (hostName, sendToPort);
		var data = source.EncodeToPNG ();
		Debug.Log (data.Length);
		udpClient.Send (data, data.Length);
		udpClient.Close ();
//		} catch {
//			Debug.Log ("Network Error!");
//		}
	}
	// Use this for initialization
	void Start ()
	{

	}
	
	// Update is called once per frame
	void Update ()
	{
		if (Input.GetMouseButtonDown (0))
			Send ();
	}
}
