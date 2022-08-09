class sp.Phys extends Sprite {//}
	
	// VARIABLES
	var vitx:float;
	var vity:float;
	var vitr:float;
	var weight:float;
	var friction:float;
	//var volume:float;
	
	var flPhys:bool;
	
	function new(){
		super();
	}

	function init(){
		super.init();
		addToList(Cs.PHYS)
	}

	function initDefault(){
		super.initDefault();
		vitx = 0;
		vity = 0;
		weight = 1;
		flPhys = true;
	}
	
	function update(){
		if( flPhys ){
			vity += (game.gravite*weight)*Timer.tmod
		}
		//var frict = Math.pow(game.airFrict,volume)
		var f = game.airFrict
		if(friction!=null)f=friction;
		vitx *= f
		vity *= f
		

		x += vitx * Timer.tmod
		y += vity * Timer.tmod
		
		if(vitr != null){
			vitr *= game.airFrict
			skin._rotation += vitr
		}
		super.update();

	};
	
	function alignRot(){
		skin._rotation = Math.atan2(vity,vitx)/0.0174
	}

	function towardSpeed(t,c,lim){
		var dx = t.x - x
		var dy = t.y - y
		vitx += Math.min( Math.max( -lim, dx*c*Timer.tmod ), lim )
		vity += Math.min( Math.max( -lim, dy*c*Timer.tmod ), lim )
	}
	
	function checkBounds(c,m,b){
				
		if( c == null ) c = -1;
		if( m == null ) m = 0;
		if( b == null ) b = { xMin:0, xMax:Cs.mcw, yMin:0, yMax:Cs.mch };
	
		if( x < b.xMin+m || x >b.xMax-m ){
			x = Math.min(Math.max ( b.xMin+m, x ), b.xMax-m )
			vitx *= c
		}
		if( y < b.yMin+m || y >b.yMax-m ){
			y = Math.min(Math.max ( b.yMin+m, y ), b.yMax-m )
			vity *= c
		}		
	}
	
	
//{	
}