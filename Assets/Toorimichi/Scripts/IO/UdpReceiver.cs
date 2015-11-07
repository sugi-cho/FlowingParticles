using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;

public class UdpReceiver : MonoBehaviour
{
	public int listenPort = 6666;
	UdpClient udpClient;
	IPEndPoint endPoint;

	[SerializeField]
	Texture2D
		tex2d;

	// Use this for initialization
	void Start ()
	{
		endPoint = new IPEndPoint (IPAddress.Any, listenPort);
		udpClient = new UdpClient (endPoint);
	}
	
	// Update is called once per frame
	void Update ()
	{
		while (udpClient.Available > 0) {
			var bs = udpClient.Receive (ref endPoint);
			Debug.Log (bs);
		}
	}

	void OnDestroy ()
	{
		udpClient.Close ();
	}
}
