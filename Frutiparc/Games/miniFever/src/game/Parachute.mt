class game.Parachute extends Game{//}
	
	// CONSTANTES
	var leafLevel:int;
	var paraRay:int;
	
	// VARIABLES
	var flWasUp:bool;
	var leafSens:int;
	var leafSpeed:float;
	var leafRay:float;
	var rotSpeed:float;
	var paraDecal:float;
	
	// MOVIECLIPS
	var para:sp.Phys;
	var leaf:MovieClip;
	var fan:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 140;
		super.init();
		leafRay = 40 - dif*0.1
		leafSpeed = 0.5+dif*0.06
		leafSens = Std.random(2)*2-1
		paraRay = 25
		leafLevel = Cs.mch-15
		attachElements();
		
		rotSpeed = 0;
		
	};
	
	function attachElements(){


		// LEAF
		leaf = dm.attach("mcLeaf",Game.DP_SPRITE)
		leaf._x = leafRay + Std.random(Math.round(Cs.mcw-leafRay))
		leaf._y = leafLevel//Cs.mch*0.5
		leaf._xscale = leafRay*2
		leaf._yscale = leafRay*2

		// FAN
		fan = dm.attach("mcFan",Game.DP_SPRITE)
		fan._x = Cs.mcw*0.5
		fan._y = Cs.mch*0.5 -20
		
		// PARA
		para = newPhys("mcParachute");
		para.x = Cs.mcw*0.5;
		para.y = Cs.mch*0.5//40;
		para.vitr = 0;
		para.flPhys = false;
		para.skin._xscale = paraRay*2;
		para.skin._yscale = paraRay*2;
		para.skin.stop();
		para.init();	
		
	}
	
	function update(){
		switch(step){
			case 1:
				// MOVE LEAF
				moveLeaf();	
			
			
				// GRAVITY
				para.y += 0.75*Timer.tmod	

				// POWER FAN
				var dx = para.x - fan._x
				var left = dx > 0;
				if( Math.abs(dx) < 60 ){	
					var pow = rotSpeed*(left?1:-1)
					para.vitx += pow*0.02
					para.vitr -= pow*0.05
				}
				
				// REPLACE LA FOURMI
				var lim = 1
				para.vitr -= Math.min( Math.max( -lim, (para.skin._rotation*0.05) ), lim )*Timer.tmod;
				para.vitr *= Math.pow( 0.95, Timer.tmod )	// FRICT SUP
			
				// BOUNDS
				if( para.x < paraRay || para.x > Cs.mcw-paraRay ){
					para.vitx *= -0.5
					para.x	= Math.min( Math.max( paraRay, para.x ) , Cs.mcw-paraRay )		
				}				
				
				// BOUGE LE FAN
				moveFan();
				
				// CHECK LANDING
				var y = para.y + Math.cos((para.skin._rotation)*0.0175)*paraRay // A CHECKER
				//var y = para.y + paraRay
				var flUp = y < leafLevel
				
				if( !flUp ){
					if( flWasUp ){
						var d = para.x - leaf._x
						if( Math.abs(d) < leafRay ){
							paraDecal = d
							landing(true)
						}					
					}
					if( y > leafLevel+10 ){
							landing(false)

					}
					
				}
				flWasUp = flUp
				
				break;
			case 2:
				moveLeaf();
				para.x = leaf._x + paraDecal
				fan._alpha *=0.5
				
				break;			
		}
		//
		super.update();
	}
	
	function landing(flag){
		step = 2;
		para.skin.gotoAndPlay(flag?"$landing":"$ploufing");
		setWin(flag);
		para.skin._rotation = 0
		para.vitx = 0;
		para.vity = 0;
		para.vitr = 0;

	}
	
	function moveLeaf(){
		leaf._x += leafSens * leafSpeed
		if( leaf._x < leafRay || leaf._x > Cs.mcw-leafRay ){
			leafSens *= -1
			leaf._x	= Math.min( Math.max( leafRay, leaf._x ) , Cs.mcw-leafRay )
		}
	}
	
	function moveFan(){
		// MOVE
		fan._x = fan._x*0.5 + this._xmouse*0.5
		fan._y = fan._y*0.5 + this._ymouse*0.5
		
		// LEFT RIGHT
		var left = ( para.x - fan._x ) > 0;
		if(left){
			fan.prevFrame();
		}else{
			fan.nextFrame();
		}
		
		// ROTATION
		var dy =  para.y - fan._y ;
		fan._rotation = dy*0.2*(left?1:-1)
		
		// TURNING
		if(base.flPress)rotSpeed += 1*Timer.tmod;
		rotSpeed *= Math.pow(0.95,Timer.tmod)
		Std.cast(fan).fan.fan._rotation += rotSpeed
		
		
	}
	

//{	
}






















