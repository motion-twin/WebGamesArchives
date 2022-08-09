class Phys extends Sprite{//}


	var flOrient:bool;
	
	var ray:float;
	var weight:float;
	var frict:float;
	var vx:float;
	var vy:float;
	var vr:float;
	function new(mc){
		super(mc)
		frict = 0.95
		vx = 0;
		vy = 0;
	}
	

	function update(){
		super.update();
		
		if( vr!=null ){
			root._rotation += vr*Timer.tmod;
		}
		
		if( weight!=null ){
			vy += weight*Timer.tmod;
		}
		
		if( frict!=null ){
			var f = Math.pow(frict,Timer.tmod)
			vx *= f;
			vy *= f;
		}

		x += vx*Timer.tmod;
		y += vy*Timer.tmod;

		if(flOrient){
			root._rotation = Math.atan2(vy,vx)/0.0174
		}
		
	}

	function updatePos(){
		super.updatePos()
	}
	
	function speedToward(o,c,lim){
		var a = getAng(o)
		var dx = o.x - x;
		var dy = o.y - y;
		vx += Cs.mm(-lim,dx*c,lim)
		vy += Cs.mm(-lim,dy*c,lim)
	}
	
//{
}