class Phys extends Sprite{//}

	var weight:float;
	var frict:float;
	var vx:float;
	var vy:float;
	var vr:float;
	
	var flash:float;

	function new(mc){
		super(mc)
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
		if(vr!=null){
			if( frict!=null )vr*=frict;
			root._rotation += vr*Timer.tmod
		}
	
		x += vx*Timer.tmod;
		y += vy*Timer.tmod;	
	}
	
	function updateFlash(){
		if(flash!=null){
			var prc = Math.min(flash,100)
			flash *= 0.6
			if( flash < 2 ){
				flash = null
				prc = 0
			}
			Cs.setPercentColor(root,prc,0xFFFFFF)
		}	
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