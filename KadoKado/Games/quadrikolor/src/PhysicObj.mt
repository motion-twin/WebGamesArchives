class PhysicObj {

	// user/sim vars
	var x : float;
	var y : float;
	var r : float;
	var dx : float;
	var dy : float;
	var mass : float;
	
	var onCollide : PhysicObj -> void;

	// for computation
	var col : float;
	var target : PhysicObj;
	var sx : float;
	var sy : float;	

}