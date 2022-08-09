import mt.bumdum9.Lib;
typedef BRSat = {>Sprite,ray:Float,a:Float,op:{x:Float,y:Float}};

class BossRound extends Game{//}

	// CONSTANTES
	static var SPEED = 3;
	static var SRAY = 112;
	// VARIABLES
	var density:Float;
	var angle:Float;
	var cooldown:Float;
	var timer:Null<Float>;
	var dec:Array<Float>;
	var wList:Array<Array<BRSat>>;
	var sList:Array<Phys>;


	// MOVIECLIPS
	var boss:flash.display.MovieClip;
	var ship:flash.display.MovieClip;


	override function init(dif){
		gameTime = 480;
		super.init(dif);
		sList = new Array();
		cooldown = 0;
		density = 23-dif*12;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("bossRound_bg",0);

		// BOSS
		boss = dm.attach("mcRoundBoss",Game.DP_SPRITE);
		boss.x = Cs.omcw*0.5;
		boss.y = Cs.omch*0.5;


		// WAVES
		wList = new Array();
		dec = new Array();
		for(  i in 0...2 ){
			wList[i] = new Array();
			dec[i] = 0;
			var ray = 44+i*28;
			var max = Std.int((6.28*ray)/density);
			for( n in 0...max ){
				var sp:BRSat = cast newSprite("mcBossRoundSmall");
				sp.a = (n/max)*6.28;
				sp.x = boss.x + Math.cos(sp.a)*ray;
				sp.y = boss.y + Math.sin(sp.a)*ray;
				sp.ray = ray;
				sp.updatePos();
				wList[i].push(sp);
			}
		}

		// SHIP
		ship = dm.attach("mcBossRoundShip",Game.DP_SPRITE);
		ship.x  = boss.x;
		ship.y  = boss.y + SRAY;


	}

	override function update(){

		moveWaves();
		moveShip();


		if( timer!=null ){
			timer--;
			if(timer<0)setWin(true);

			var i = 0;
			for( a in wList ){
				var n = 0;
				for( sp in a ){
					sp.ray += 10-i*3;
					sp.ray *= 1.1;
					n++;
				}
				i++;
			}


		}else{
			for(sp in sList ){
				if( sp.getDist({x:boss.x,y:boss.y}) < 22 ){
					boss.gotoAndPlay("death");
					timer = 16;
					timeProof = true;
					sp.kill();
				}
			}
		}

		super.update();
	}

	function moveWaves(){
		var i = 0;
		while( i<wList.length ){
			var list = wList[i];
			var d = dec[i];
			dec[i] = (d+(SPEED/(1+i*0.8))*(i*2-1))%628;
			var n = 0;
			while( n<list.length){
				// DEPLACEMENT
				var sp = list[n];
				var a = sp.a + d/100;
				sp.x = boss.x + Math.cos(a)*sp.ray;
				sp.y = boss.y + Math.sin(a)*sp.ray;

				var k = 0;
				while( k<sList.length ){
					var shot = sList[k];
					var dist = shot.getDist(sp);
					if(dist<8){

						// VIT
						var vx = sp.x - sp.op.x;
						var vy = sp.y - sp.op.y;

						// PARTS
						for( b in 0...10){
							var p = newPhys("partBossRoundSmall");
							var ang =Math.random()*6.28;
							var ca = Math.cos(ang);
							var sa = Math.sin(ang);
							var r = 3;
							var speed = 0.2+Math.random()*1.5;
							p.x = sp.x + ca*r;
							p.y = sp.y + sa*r;
							p.vx = ca*speed + vx;
							p.vy = sa*speed + vy;
							p.vr = (Math.random()*2-1)*16;

							p.timer = 12+Std.random(12);
							p.frict = 0.97;
							p.fadeType = 0;
							p.updatePos();
							p.root.gotoAndStop(b+1);

						}


						// CLEAN
						sList.splice(k--,1);
						shot.kill();
						wList[i].splice(n--,1);
						sp.kill();
						break;
					}
					k++;

				}
				// OLD POSITIONS
				sp.op = { x:sp.x, y:sp.y };
				n++;
			}
			i++;
		}
	}

	function moveShip() {
		var mp = getMousePos();
		var c = Num.mm(0,mp.x/Cs.omcw,1);
		var a = 1.57 - (c*2-1)*1.2;
		ship.x = boss.x + Math.cos(a)*SRAY;
		ship.y = boss.y + Math.sin(a)*SRAY;
		ship.rotation = a/0.0174;

		if(cooldown>0){
			cooldown--;
		}else{
			if(click){
				a -= 3.14;
				cooldown = 16;
				var sp = newPhys("mcBossRoundShot");
				sp.x = ship.x;
				sp.y = ship.y;
				var speed = 4;
				sp.vx = Math.cos(a)*speed;
				sp.vy = Math.sin(a)*speed;

				sp.updatePos();
				sp.root.rotation = a/0.0174;
				sList.push(sp);
			}
		}
	}



//{
}

