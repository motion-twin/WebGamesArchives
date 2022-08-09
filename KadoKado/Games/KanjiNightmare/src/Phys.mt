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
		
		if(flOrient)orient();
		super.update();
		
	}

	function checkPlatCol(){
		//
		if(vy>0){
			var py = y+ray;
			var oy = py-vy*Timer.tmod;
			for( var i=0; i<Cs.game.platList.length; i++ ){
				var pl = Cs.game.platList[i];
				if(oy<pl.y && py>pl.y && x>pl.x && x<pl.x+pl.w ){
					y = pl.y-ray;
					land(pl)
					break;
				}
			}
		}	
	}
	
	function land(plat){

	}
	
	function orient(){
		var sens = 1
		if(vx<0) sens = -1
		root._xscale = sens*100
		root._rotation = Math.atan2(vy,vx)/0.0174 
		if(vx<0)root._rotation += 180	
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