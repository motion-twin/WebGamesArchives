import Protocole;
import mt.bumdum9.Lib;

typedef Astero = { >Phys, size:Int, ray:Float };

class Asteroid extends Game{//}

	static var SHOT_SPEED = 11;
	static var SHOT_DELAY = 10;

	var impact:Float;

	var cooldown:Float;
	var ship:{>Phys,angle:Float};
	var shots:Array<Phys>;
	var asteros:Array<Astero>;

	var scene:flash.display.MovieClip;
	var adm:mt.DepthManager;


	override function init(dif){
		gameTime = 400;
		super.init(dif);
		dm.attach("asteroid_bg",0);

		initScene();
		impact = 0;

		// SHIP
		ship = cast new Phys(adm.attach("asteroid_ship",1));
		ship.x = Cs.mcw*0.5;
		ship.y = Cs.mch*0.5;
		ship.angle = 0;
		ship.updatePos();
		cooldown = 0;

		// ASTEROIDS
		var mass = 2+dif*8;
		asteros = [];
		while(mass>=1){

			var size = Std.random(3);
			while( mass < Math.pow(2,size) )size--;
			mass -= Math.pow(2,size);

			var sp = getAst(size);
			sp.x = Math.random()*Cs.mcw;
			sp.y = Math.random()*Cs.mch;

			var speed = 1+dif+Math.random();
			var a = Math.random()*6.28;
			sp.vx = Math.cos(a)*speed;
			sp.vy = Math.sin(a)*speed;



			switch(Std.random(4)){
				case 0:
					sp.x = Math.random()*(Cs.mcw-2*sp.ray);
					sp.y = -sp.ray;
				case 1:
					sp.x = Math.random()*(Cs.mcw-2*sp.ray);
					sp.y = Cs.mch+sp.ray;
				case 2:
					sp.x = -sp.ray;
					sp.y = Math.random()*(Cs.mch-2*sp.ray);
				case 3:
					sp.x = Cs.mcw+sp.ray;
					sp.y =  Math.random()*(Cs.mch-2*sp.ray);
			}


		}

		// SHOTS
		shots = [];

		//
		updateScene();
		
	}

	override function update(){
		super.update();

		impact*=0.5;

		// SHIP
		moveShip();

		// ASTEROIDS
		for( sp in asteros ){
			if( sp.x > Cs.mcw+sp.ray )	sp.x -= Cs.mcw+sp.ray*2;
			if( sp.x < -sp.ray )		sp.x += Cs.mcw+sp.ray*2;
			if( sp.y > Cs.mch+sp.ray )	sp.y -= Cs.mch+sp.ray*2;
			if( sp.y < -sp.ray )		sp.y += Cs.mch+sp.ray*2;

			if( ship!= null && sp.getDist(ship) < 8+sp.ray ){

				var mc = adm.attach("asteroid_fxExplode",1);
				mc.x = ship.x;
				mc.y = ship.y;
				ship.kill();
				ship = null;
				setWin(false,20);
			}
		}

		// SHOTS
		var a = asteros.copy();
		var a2 = shots.copy();
		for( sh in a2 ){
			var flDeath = false;
			for( ast in a){
				var dx = ast.x - sh.x;
				var dy = ast.y - sh.y;
				if( Math.sqrt(dx*dx+dy*dy) < ast.ray ){

					// DEDOUBLE
					if( ast.size>0 ){
						var angle = Math.atan2( ast.vy, ast.vx );
						for( i in 0...2 ){
							var sp = getAst(ast.size-1);
							var a = angle+1.57*(i*2-1);
							var r = ast.ray*0.5;
							sp.x = ast.x + Math.cos(a)*r;
							sp.y = ast.y + Math.sin(a)*r;
							var speed = Math.sqrt(ast.vx*ast.vx+ast.vy*ast.vy);
							sp.vx = Math.cos(a)*speed;
							sp.vy = Math.sin(a)*speed;
							sp.updatePos();
						}
					}

					// PARTS
					var max = 8;
					for( i in 0...max ){
						var p = new Phys(adm.attach("asteroid_part",1));
						var a = (i+Math.random())/max *6.28;
						var speed = Math.random()*4;
						var cr = 2.5;
						p.vx = Math.cos(a)*speed + ast.vx*0.5;
						p.vy = Math.sin(a)*speed + ast.vy*0.5;
						p.x = ast.x + p.vx*cr;
						p.y = ast.y + p.vy*cr;
						p.timer = 10 + Std.random(20);
						p.root.gotoAndStop(Std.random(p.root.totalFrames)+1);
						p.root.rotation = Math.random()*360;
						p.vr = (Math.random()*2-1)*12;
						p.fr = 0.98;
						p.frict = 0.97;
						p.fadeType = 0;
						p.updatePos();
					}

					// REMOVE
					asteros.remove(ast);
					ast.kill();
					flDeath = true;

					//
					impact = 1;

					break;

				}
			}
			var ray = 10;
			if( sh.x > Cs.mcw+ray || sh.x < -ray || sh.y > Cs.mch+ray || sh.y < -ray || flDeath){
				sh.kill();
				shots.remove(sh);
			}
		}


		// END
		if( asteros.length==0 ) setWin(true,20);
		updateScene();


	}

	function moveShip(){
		if(ship == null) return;
		var mp = getMousePos();
		var dx = mp.x - ship.x;
		var dy = mp.y - ship.y;

		var ta = Math.atan2(dy,dx);
		var da = Num.hMod(ta-ship.angle,3.14);
		var lim = 0.4;
		ship.angle += Num.mm(-lim,da*0.3,lim);
		ship.root.rotation = ship.angle/0.0174;

		if(cooldown>0)cooldown--;

	
		getSmc(ship.root).visible = false;

		if(!click){
			if(cooldown==0){
				var shot = new Phys( adm.attach("asteroid_shot",1) );
				var cx = Math.cos(ship.angle);
				var cy = Math.sin(ship.angle);
				var speed = SHOT_SPEED;
				shot.x = ship.x + cx*5;
				shot.y = ship.y + cy*5;
				shot.vx = cx*speed + ship.vx;
				shot.vy = cy*speed + ship.vy;
				shot.updatePos();
				cooldown = SHOT_DELAY;
				shots.push(shot);
			}

		}else{
			var acc  = 0.5;
			if( Math.sqrt(dx*dx+dy*dy) > 30 ){
				getSmc(ship.root).visible = true;
				ship.vx += Math.cos(ship.angle)*acc;
				ship.vy += Math.sin(ship.angle)*acc;
			}
		}

		var fr = 0.96;
		ship.vx *= fr;
		ship.vy *= fr;
	}

	function getAst(size){
		var sp:Astero = cast new Phys(adm.attach("asteroid_asteroid",1));
		sp.size = size;
		sp.ray = [15,25,40][sp.size];
		sp.setScale(sp.ray*0.02);
		sp.vr = (Math.random()*2-1)*3;
		asteros.push(sp);
		return sp;
	}


	var bmp:flash.display.Bitmap;
	var qsc:Float;
	function initScene(){
		scene = dm.empty(0);
		adm = new mt.DepthManager(scene);
		//Filt.glow(scene,10,1,0xFFFFFF);
		scene.visible = false;

		qsc = 0.5;
		var width = 	Math.ceil(Cs.mcw*qsc);
		var height = 	Math.ceil(Cs.mch*qsc);

		bmp = new flash.display.Bitmap();
		bmp.bitmapData = new flash.display.BitmapData(width,height,true,0);
		var mc = dm.empty(0);
		mc.addChild(bmp);
		mc.scaleX = mc.scaleY = 2;

	}
	function updateScene(){
		bmp.bitmapData.fillRect(bmp.bitmapData.rect,0);
		var m = new flash.geom.Matrix();
		m.scale(qsc,qsc);
		bmp.bitmapData.draw(scene,m);

		// SCANLINE
		//for( y in 0...Std.int(bmp.height*0.5) )bmp.fillRect(new flash.geom.Rectangle(0,y*2,bmp.width,1),0xFF000000);



		// GLOW
		var fl = new flash.filters.GlowFilter();
		fl.blurX = 2;
		fl.blurY = 2;
		fl.strength = impact*4;
		fl.color = 0xFFFFFF;
		bmp.bitmapData.applyFilter(bmp.bitmapData,bmp.bitmapData.rect,new flash.geom.Point(0,0),fl);

		var bl = 8+impact*8;
		var fl = new flash.filters.GlowFilter();
		fl.blurX = bl;
		fl.blurY = bl;
		fl.strength = 1;
		fl.color = 0xFFFFFF;
		bmp.bitmapData.applyFilter(bmp.bitmapData,bmp.bitmapData.rect,new flash.geom.Point(0,0),fl);


	}

//{
}















