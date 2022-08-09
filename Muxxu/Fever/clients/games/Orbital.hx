import mt.bumdum9.Lib;
import Protocole;

typedef OrbitalMissile = {mc:flash.display.MovieClip,t:Null<Float>,a:Float};

class Orbital extends Game{//}

	// CONSTANTES
	var tRay:Int;
	var pRay:Int;

	// VARIABLES
	var decal:Float;
	var speed:Float;
	var speedDecal:Float;
	var launcher:Array<OrbitalMissile>;
	var missile:Array<Phys>;

	var oTrg:{x:Float,y:Float};

	// MOVIECLIPS
	var planete:Sprite;
	var trg:Sprite;


	var exploded : Bool;
	var fired : Int;
	
	override function init(dif : Float){
		gameTime = 400;
		super.init(dif);
		exploded = false;
		fired = 0;
		speed = 4+dif*10;
		speedDecal = 0;
		decal = Std.random(328);
		pRay = 50;
		tRay = 108;
		missile = new Array();
		attachElements();
		zoomOld();
		
		
	}

	function attachElements(){

		bg = dm.attach("orbital_bg",0);
		bg.cacheAsBitmap = true;

		var bdm = new mt.DepthManager(bg);
		var max = 300;
		for( i in 0...max ){
			var c = Math.pow(i/max,4);
			var mc = bdm.attach("orbital_star",0);
			mc.x = Math.random()*Cs.omcw;
			mc.y = Math.random()*Cs.omch;
			mc.alpha = 0.5+c*0.5;
			mc.scaleX = mc.scaleY = 0.5+c*0.5;
			mc.blendMode = flash.display.BlendMode.ADD;
		}

		// PLANETE
		planete = newSprite("mcPlanete");
		planete.x = Cs.omcw*0.5;
		planete.y = Cs.omch*0.5;
		planete.root.scaleX = pRay*0.02;
		planete.root.scaleY = planete.root.scaleX;
		planete.updatePos();

		// TARGET
		trg = newSprite("mcOrbitalTarget");
		updateTrgPos();
		trg.updatePos();

		// LAUNCHER
		launcher = new Array();
		var max = Std.int( Math.max( 1, Math.round(6-(dif*5)) ) );
		for( i in 0...max ){
			var mc = newSprite("mcMissileLauncher");
			mc.x = planete.x;
			mc.y = planete.y;

			var a = 0.0;
			while(true){
				a = Std.random(628)/100;
				var flag = true;
				for( n in 0...launcher.length ){
					if( Math.abs(launcher[n].a - a) < 0.2 ){
						flag = false;
					}
				}
				if(flag)break;
			}

			mc.root.rotation = a/0.0174;
			mc.root.stop();
			mc.updatePos();
			
			var info:OrbitalMissile = { mc:mc.root, a:a, t:i * 4.0 };
			
			var me = this;
			mc.root.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(e) { me.fire(info); } );

			launcher.push(info);
		}

	}

	function initLauncher(info:OrbitalMissile){

		info.mc.mouseEnabled = true;
		info.t = null;
		info.mc.gotoAndPlay("2");
	}


	function updateTrgPos() {
			trg.x = planete.x + Math.cos(decal/100)*tRay;
			trg.y = planete.y + Math.sin(decal/100)*tRay;
	}
	
	override function update(){
		super.update();
		switch(step){
			case 1:
				// ORBITE
				speedDecal = (speedDecal+10)%628;
				var sp = speed+Math.cos(speedDecal/100)*speed*0.5;
				decal = (decal + sp) % 628;
				updateTrgPos();
				trg.root.rotation += 50/sp;

				// COOLDOWN
				for( info in launcher ){
					if( info.t != null ){
						info.t--;
						if( info.t < 0 )initLauncher(info);
					}

				}

				// CHECK COL
				var a = missile.copy();
				for( s in a ){
					var dist = s.getDist(trg);
					if( dist < 10 && !exploded){
						explosion(trg.x,trg.y);
						setWin(true,20);
						s.kill();
						trg.kill();
						missile.remove(s);
						exploded = true;
					}
				}

				// OLD TRG POS
				oTrg={x:trg.x,y:trg.y};
		}
		//

	}

	function fire(info:OrbitalMissile){
		info.t = 10 + dif * 100;
		info.mc.gotoAndStop("1");
		info.mc.mouseEnabled = false;
		
		
		var mc = newPhys("mcOrbitalMissile");
		var ca = Math.cos(info.a);
		var sa = Math.sin(info.a);
		var d = pRay+10;
		var sp = 6;
		mc.x = info.mc.x + ca*d;
		mc.y = info.mc.y + sa*d;
		mc.vx = ca*6;
		mc.vy = sa*6;
		mc.root.rotation = info.a/0.01714;
		mc.updatePos();
		missile.push(mc);
		fired++;
	}

	function explosion(x,y){

		var dist = trg.getDist(oTrg);
		var ta = trg.getAng(oTrg);

		for( i in 0...12 ){
			var mc = newPhys("mcPartFeather");
			var a = Std.random(628)/100;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var p = 0.5+Std.random(30)*0.1;
			var scale = 50+Std.random(100);
			mc.x = x + ca*p*1.5;
			mc.y = y + sa*p*1.5;
			mc.vx = ca*p - Math.cos(ta)*dist*0.15;
			mc.vy = sa*p - Math.sin(ta)*dist*0.15;
			mc.vr = Math.random()*20;
			mc.updatePos();
			mc.root.gotoAndStop(Std.random(mc.root.totalFrames)+1);
			mc.root.scaleX = scale*0.01;
			mc.root.scaleX = scale*0.01;
		}

	}




//{
}
















