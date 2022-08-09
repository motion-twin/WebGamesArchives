import mt.bumdum9.Lib;
import mt.flash.Volatile;

class Tree extends Game{//}

	// CONSTANTES
	static var FRAME = 80;
	static var LAG_TIMER_MAX = 100;
	static var HEIGHT = 197;
	static var GL = 216;

	// VARIABLES
	var lagTimer:Null<Float>;
	var frame:Float;
	var angle:Float;
	var oldAngle:Float;
	var timer:Null<Float>;
	var weight:Float;
	var pause:Volatile<Int>;

	var pl:Array<{x:Float,y:Float,vx:Float,vy:Float}>;

	// MOVIECLIPS
	var hero:Sprite;
	var tree:Sprite;

	var shade:flash.display.MovieClip;



	override function init(dif:Float){
		pause = 0;
		gameTime = 150+dif*300;
		super.init(dif);
		lagTimer = LAG_TIMER_MAX;
		frame = 0;
		angle = Math.random()*0.01;
		attachElements();

		weight = 1.03;
		zoomOld();

	}

	function attachElements(){

		 dm.attach("tree_bg",0);

		// SHADE
		shade = dm.attach("mcTreeShade",Game.DP_SPRITE);
		shade.x = Cs.omcw*0.5;
		shade.y = GL+3;
		shade.scaleX = 0;

		// TREE
		tree = newSprite("mcTreeTree");
		tree.x = Cs.omcw*0.5;
		tree.y = 197;
		tree.updatePos();

		// HERO
		hero = newSprite("mcTreeHero");
		hero.x = Cs.omcw*0.5;
		hero.y = 219;
		hero.updatePos();

		// HERB
		dm.attach("mcTreeHerb",Game.DP_SPRITE);

		step = -1;
	}

	override function update(){

		switch(step){
			case -1:
				if( pause++ > 15 ) step = 1;

			case 1:
				// HERO
				var dx = getMousePos().x-hero.x;
				var lim = 4;
				var vx =  Num.mm(-lim,dx*0.1,lim);
				hero.x += vx;

				frame = frame+vx*4;


				angle -= vx*0.005;

				while(frame<0)frame+=FRAME;
				while(frame>FRAME)frame-=FRAME;

				hero.root.gotoAndStop(Std.int(frame)+1);

				// TREE
				var c = 1.0;
				if(lagTimer!=null){
					lagTimer--;
					if(lagTimer<0){
						c = 1-lagTimer/LAG_TIMER_MAX;
						lagTimer = null;
					}
				}

				weight *= 1.0003;

				angle *= (weight*c)+1*(1-c);
				tree.root.rotation = angle/0.0174;
				tree.x = hero.x;

				if( Math.abs(angle) > 0.8 && !win )initFall();
				moveShade(angle-1.57);

				// OLD ANGLE
				oldAngle = angle;

			case 2:
				for( o in pl ){
					o.vy += 0.3;
					var frict = 0.95;
					o.vx *= frict;
					o.vy *= frict;
					o.x += o.vx;
					o.y += o.vy;

					if( o.y > GL ){
						o.y = GL;
						o.vy *= -0.9;
					}
				}
				var p0 = pl[0];
				var p1 = pl[1];
				var dx = p0.x - p1.x;
				var dy = p0.y - p1.y;

				var dist = Math.sqrt(dx*dx+dy*dy);
				var dif = HEIGHT-dist;

				var a = Math.atan2(dy,dx);

				p0.x += Math.cos(a)*dif*0.5;
				p0.y += Math.sin(a)*dif*0.5;

				p1.x -= Math.cos(a)*dif*0.5;
				p1.y -= Math.sin(a)*dif*0.5;

				tree.x = p0.x;
				tree.y = p0.y;
				tree.root.rotation =  a/0.0174 - 90;

				/* DEBUG
				m0.x = pl[0].x
				m0.y = pl[0].y
				m1.x = pl[1].x
				m1.y = pl[1].y
				//*/
				moveShade(a+3.14);

				timer--;
				if(timer<0){
					timeProof = false;
					setWin(false,10);
					timer = null;
				}


		}
		//
		super.update();
	}

	function moveShade(a){
		shade.x = tree.x;
		shade.scaleX = Math.cos(a)*HEIGHT*0.01;
	}


	function initFall(){
		/* DEBUG
		m0 = dm.attach("mcMarker",Game.DP_SPRITE)
		m1 = dm.attach("mcMarker",Game.DP_SPRITE)
		//*/

		timeProof = true;

		step = 2;

		pl = new Array();
		pl.push(cast {x:tree.x,y:tree.y,vx:0,vy:0});

		var a = angle - 1.57;
		var x = pl[0].x+Math.cos(a)*HEIGHT;
		var y = pl[0].y+Math.sin(a)*HEIGHT;

		//var cx = Math.cos(a)*2
		//var cy = Math.sin(a)*2

		a = oldAngle - 1.57;
		var ox = pl[0].x+Math.cos(a)*HEIGHT;
		var oy = pl[0].y+Math.sin(a)*HEIGHT;

		pl.push({x:x, y:y, vx:x-ox, vy:y-oy});

		//dm.over(tree.skin)
		var mc = dm.attach("mcTreeHeroAngry",Game.DP_SPRITE);
		mc.x = hero.x;
		mc.y = hero.y;
		hero.kill();

		timer = 20;


		/* CENTRIFUGE
		for( var i=0; i<pl.length; i++ ){
			var o = pl[i]
			o.vx = cx
			o.vy = cy
		}
		//*/

	}

	override function outOfTime(){
		setWin(true);
	}




//{
}










