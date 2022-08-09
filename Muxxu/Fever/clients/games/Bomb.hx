import Protocole;

class Bomb extends Game{//}

	// CONSTANTES
	var powerMax:Int;
	var limit:Int;
	var speed:Float;
	var angle:Float;

	// VARIABLES
	var flReady:Bool;
	var power:Null<Float>;
	var water:Array<Phys>;
	var others:Array<flash.display.MovieClip>;


	// MOVIECLIPS
	var bomb:flash.display.MovieClip;
	var monster:flash.display.MovieClip;
	var spark:flash.display.MovieClip;
	var mask_:flash.display.MovieClip;



	override function init(dif:Float){
		gameTime = 540-dif*300;
		super.init(dif);
		limit = 169;
		powerMax = 10;
		angle = -Math.PI*0.75;
		speed = 0.5 + dif*1.5;
		water = new Array();
		attachElements();
		zoomOld();
	}

	function attachElements(){
		bg = dm.attach("bomb_bg",0);
		bomb = Reflect.field(bg,"_bomb");
		monster = Reflect.field(bg,"_monster");
		spark = Reflect.field(bg,"_spark");
		mask_ = Reflect.field(bg,"_mask");
		others = [];
		for( i in 0...8 ){
			var mc:flash.display.MovieClip = Reflect.field(bg, "_p" + i);
			if( mc == null ) continue;
			mc.gotoAndPlay(10);
			others.push(mc);
		}

	}

	override function update(){
		super.update();
		switch(step){
			case 1:
				// SPARK
				spark.x += speed;
				if(spark.x > limit ){
					setWin(false,20);
					step = 2;
					bg.play();
					for( mc in others )mc.gotoAndPlay(27+Std.random(7));

					return;
				}
				mask_.x = spark.x;
				mask_.scaleX = (Cs.mcw-spark.x)*0.01;

				// WATER
				var a = water.copy();
				for( mc in a ){
					if( mc.y > spark.y ){
						if( Math.abs(spark.x - mc.x) < 10 ){
							spark.gotoAndPlay("smoke");
							setWin(true,20);
							step = 2;
						}
						explosion( mc.x, spark.y, mc.vx );
						mc.kill();
						water.remove(mc);
					}
				}

				// LAUNCH
				if( click ){
					if( power == null ){
						power = 0;
					}else{
						power = Math.min( power+0.5, 10 );
						monster.gotoAndStop(Math.round(power+20) );

					}
				}else{
					if( power != null )launch();
				}


		}

	}

	function launch(){
		if( power > 2.5 ){
			var mc = newPhys("mcWaterBall");
			mc.x = monster.x - 39;
			mc.y = monster.y - 63;
			mc.vx = Math.cos(angle)*power*0.8;
			mc.vy = Math.sin(angle)*power*0.8;
			mc.weight = 0.5;
			mc.updatePos();
			mc.root.scaleX = 0.6;
			mc.root.scaleY = 0.6;
			water.push(mc);
		}
		monster.gotoAndStop("20");
		power = null;
	}

	function explosion(x,y,vx){
		for( n in 0...10 ){
			var g = newPhys("bomb_fxGoutte");
			g.x = x;
			g.y = y;
			g.vx = 5*(Math.random()*2-1) + vx;
			g.vy = -(3+Math.random()*8);
			g.scale = 0.4 + Math.random() * 0.6;
			g.weight = 0.5;
			g.timer = 10+Std.random(10);
			g.fadeType = 0;
			g.root.alpha = 0.6;
			g.updatePos();
		}
	}







//{
}

