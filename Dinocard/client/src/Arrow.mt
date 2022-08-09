class Arrow extends Phys{//}

	
	var flOrient:bool;
	
	var angle:float;
	var angleCoef:float;
	var angleSpeed:float;
	var speed:float;
	var accel:float
	var speedMax:float;

	
	
	
	function new(mc){
		super(mc)

		angle = 0
		speed = 0
		
	}

	function update(){
		super.update();
		
		if(flOrient)orient();

	}
	
	function setVit(speed){
		vx = Math.cos(angle)*speed;
		vy = Math.sin(angle)*speed;
	}
	
	function towardVit(c,speed){
		var dvx = Math.cos(angle)*speed - vx;
		var dvy = Math.sin(angle)*speed - vy;
		vx += dvx*c;
		vy += dvy*c;
	}
	
	function towardAngle(ta,ca,va){
		var da = Cs.hMod( ta-angle, 3.14)
		angle += Cs.mm(-Math.abs(da), Cs.mm(-va,da*ca,va)*Timer.tmod,Math.abs(da));
		updateRotation();
	}
	
	function updateRotation(){
		root._rotation = angle/0.0174
	}
	/*
	function follow(){
		var dist = getDist(wp)
		var dSpeed =   Cs.mm( 0, (dist-tol)*0.1, 1 )*speedMax - speed
		speed += dSpeed*accel*Timer.tmod
		towardAngle(getAng(wp))
		setVit(speed);
		if(dSpeed<0.1 && dist < tol ){
			reachWp()
		}
	}
	*/

	function orient(){
		root._rotation = angle/0.0174
	}

//{
}