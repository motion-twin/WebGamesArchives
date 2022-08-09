class Phys extends Sprite{//}

	
	
	var weight:float;
	var frict:float;
	var vx:float;
	var vy:float;
	
	function new(mc){
		super(mc)
		frict = 0.95
		vx = 0;
		vy = 0;
	}
	
	function update(){
		super.update();
		
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