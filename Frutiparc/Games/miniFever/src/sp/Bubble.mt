class sp.Bubble extends Sprite {//}
	
	// VARIABLES
	var flShade:bool;
	var flTrg:bool;
	var tx:float;
	var ty:float;
	var vx:float;
	var vy:float;
	var vs:float;
	var vr:float;
	var vd:float;
	var ray:float;
	var sc:float;
	var dec:float;

	var trg:MovieClip;
	var shade:MovieClip;
	var shadeInc:float;
	
	var list:Array<sp.Bubble>;

	function new(){
		super();
	}

	function init(){
		super.init();
	}

	function initDefault(){
		super.initDefault();
		flShade = false;
		tx = x;
		ty = y;
		vx = 0;
		vy = 0;
		vs = 0;
		sc = 100
		vr = -Math.random()*20
		vd = 10+Math.random()*20
		dec = Math.random()*628
		ray = 5+Math.random()*10
	}
	
	function setShade(mc,inc){
		if(inc==null)inc=0;
		shadeInc = inc;
		shade = mc
		flShade = true;
	}
	
	function setTrg(mc){
		trg = mc;
		flTrg = true;
	}

	
	function update(){
		dec = (dec+vd*Timer.tmod)%628
		var ttx = tx+Math.cos(dec/100)*ray
		var tty = ty+Math.sin(dec/100)*ray
		if(trg!=null){
			ttx += trg._x;
			tty += trg._y;
		}		
		var dx = ttx - x
		var dy = tty - y
		var ds = sc - skin._xscale;
		var lim = 0.75//0.5
		vx += Math.min(Math.max(-lim,dx*0.1),lim)*Timer.tmod
		vy += Math.min(Math.max(-lim,dy*0.1),lim)*Timer.tmod
		vs += Math.min(Math.max(-lim,ds*0.1),lim)*Timer.tmod
		
		var frict = Math.pow(0.95,Timer.tmod)
		vx *= frict
		vy *= frict
		vs *= frict
		
		x += vx*Timer.tmod
		y += vy*Timer.tmod
		skin._xscale += vs*Timer.tmod
		skin._yscale = skin._xscale//
		skin._rotation += vr*Timer.tmod
		
		// col
		for( var n=0; n<list.length; n++ ){
			var sp2 = list[n]
			if( this != sp2 ){
				var ddx = sp2.x - x ;
				var ddy = sp2.y - y ;
				var dist = Math.sqrt(ddx*ddx+ddy*ddy) ;
				var ray = (sc+sp2.sc)*0.5 ;
				if( dist<ray ){
					var dd = ray-dist;
					var a = Math.atan2(ddy,ddx);
					var ca = Math.cos(a);
					var sa = Math.sin(a);				
					x -= ca*dd*0.5
					y -= sa*dd*0.5
					sp2.x += ca*dd*0.5
					sp2.y += sa*dd*0.5						
				}
			}
		}
		super.update();
		/*
		if(trg!=null){
			skin._x += trg._x;
			skin._y += trg._y;
		}
		*/
		
		if(flShade){
			shade._x = skin._x
			shade._y = skin._y
			shade._xscale = skin._xscale+6
			shade._yscale = shade._xscale
		}

	};

	
	
//{	
}