class game.Bomb extends Game{//}
	
	// CONSTANTES
	var powerMax:int;
	var limit:int;
	var speed:float;
	var angle:float;
	
	// VARIABLES
	var flReady:bool;
	var power:float
	var water:Array<sp.Phys>
	
	
	// MOVIECLIPS
	var bomb:MovieClip;
	var monster:MovieClip;
	var spark:MovieClip;
	var mask:MovieClip;

	
	function new(){
		super();
	}

	function init(){
		gameTime = 540-dif*3;
		super.init();
		limit = 169
		powerMax = 10
		angle = -Math.PI*0.75
		speed = 0.5 + dif*0.015
		water = new Array();
		attachElements();
	};
	
	function attachElements(){
		
		
	}
	
	function update(){
		super.update();
		switch(step){
			case 1:
				// SPARK
				spark._x += speed*Timer.tmod;
				if(spark._x > limit ){
					setWin(false);
					step = 2
					play();
					return;
				}
				mask._x = spark._x
				mask._xscale = Cs.mcw-spark._x
				
				// WATER
				for( var i=0; i<water.length; i++ ){
					var mc = water[i]
					if( mc.y > spark._y ){
						if( Math.abs(spark._x - mc.x) < 10 ){
							spark.gotoAndPlay("smoke")
							setWin(true)
							step = 2
						}	
						explosion( mc.x, spark._y, mc.vitx )
						mc.kill();
						water.splice(i,1)
						i--;						
					}
				}
				
				// LAUNCH
				if( base.flPress ){
					if( power == null ){
						power = 0;
					}else{
						power = Math.min( power+0.5*Timer.tmod, 10 )
						monster.gotoAndStop( string(Math.round(power+20)) );

					}
				}else{
					if( power != null ){
						launch();
					}
				}
				
				
			
				break;
		}
	
	}
	
	function launch(){
		if( power > 2.5 ){
			var mc = newPhys("mcWaterBall")
			mc.x = monster._x - 39;
			mc.y = monster._y - 63;
			mc.vitx = Math.cos(angle)*power*0.8
			mc.vity = Math.sin(angle)*power*0.8
			mc.weight = 0.5
			mc.init();
			mc.skin._xscale = 60
			mc.skin._yscale = 60
			water.push(mc)
		}
		monster.gotoAndStop("20");
		power = null;
	}
	
	function explosion(x,y,vx){
		for( var n=0; n<10; n++ ){
			var g = newPart("mcPartGoutte")
			g.x = x
			g.y = y
			g.vitx = 5*(Math.random()*2-1) + vx;
			g.vity = -(3+Math.random()*8)
			g.scale = 40+Std.random(60);
			g.weight = 0.5;
			g.timer = 10+Std.random(10);
			g.timerFadeType = 1;
			g.skin._alpha = 60
			g.init();
		}	
	}
	
	
	
	

	
	
//{	
}

