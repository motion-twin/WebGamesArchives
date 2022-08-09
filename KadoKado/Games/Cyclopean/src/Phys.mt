class Phys extends Sprite{//}


	var flOrient:bool;
	
	var ray:float;
	var weight:float;
	var frict:float;
	var vx:float;
	var vy:float;
	var vr:float;
	var bouncer:Bouncer;
	
	function new(mc){
		super(mc)
		frict = 0.95
		vx = 0;
		vy = 0;
	}
	
	function update(){
		
		
		if( vr!=null ){
			root._rotation += vr*Timer.tmod;
		}
		
		if( weight!=null ){
			
			vx += Cs.game.gcos*weight*Timer.tmod
			vy += Cs.game.gsin*weight*Timer.tmod;
		}
		
		if( frict!=null ){
			var f = Math.pow(frict,Timer.tmod)
			vx *= f;
			vy *= f;
		}
		if(bouncer!=null){
			bouncer.update();
		}else{
			x += vx*Timer.tmod;
			y += vy*Timer.tmod;
		}
		if(flOrient){
			root._rotation = Math.atan2(vy,vx)/0.0174
		}
		super.update();
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