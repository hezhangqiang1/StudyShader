using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BallRatate : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        this.transform.Rotate(Vector3.up, 45 * Time.deltaTime, Space.Self);

    }
}
