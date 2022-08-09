import mt.bumdum9.Lib;
typedef PierceBall = {>Phys,trg:{x:Float,y:Float}};

class Pierce extends Game{//}



	// CONSTANTES
	static var MARGIN = 12;
	static var SIDE = 20;

	// VARIABLES
	var bList:Array<PierceBall>;
	var ray:Float;
	var sens:Int;

	// MOVIECLIPSv
	var hero:Sprite;


	override function init(dif:Float){
		gameTime = 320-dif*120;
		super.init(dif);
		ray = 32-dif*20;
		if(ray<12)ray = 12;
		sens = 1;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("pierce_bg",0);

		// BALLONS
		bList = new Array();
		var max = 2 + Std.int(dif*5);
		for( i in 0...max){
			var sp:PierceBall = cast(newPhys("mcPierceBallon"));
			var m = 12;
			sp.x = m+Math.random()*(Cs.omcw-2*m);
			sp.y = m+Math.random()*(Cs.omch-2*m);
			sp.root.scaleX = ray*0.02;
			sp.root.scaleY = ray*0.02;
			sp.frict = 0.92;
			sp.updatePos();
			newTarget(sp);
			bList.push(sp);
			//Filt.glow(sp.root,2,4,0);
		}

		// HERO
		hero = newSprite("mcPiercer");
		hero.x = MARGIN;
		hero.y = Cs.omch*0.5;
		hero.updatePos();
		//Filt.glow(hero.root,2,4,0);




	}

	override function update(){

		super.update();
		moveBall();

		switch(step){
			case 1:
				var dy = Num.mm(0,box.mouseY,Cs.omch)-hero.y;
				hero.y += dy*0.1;

				var tr = (-sens+1)*0.5*180;
				var dr =  tr - hero.root.rotation;
				while(dr>180)dr-=360;
				while(dr<-180)dr+=360;
				hero.root.rotation += dr*0.3;


				if( click && Math.abs(dr) < 2){
					step = 2;
					hero.root.rotation = tr;
				}


			case 2:
				var tx = Cs.omcw*0.5 + (Cs.omcw*0.5-MARGIN)*sens;
				var dx = (tx-hero.x);
				var vx = dx*0.3;

				var lim = 20;
				while( vx != 0 ){

					var vit = Num.mm(-lim,vx,lim);
					hero.x += vit;
					vx -= vit;
					checkCol();

					var p = dm.attach("partPiercer",Game.DP_SPRITE2);
					p.x = hero.x;
					p.y = hero.y;
					p.rotation = hero.root.rotation;
					//break;
				}

				if( Math.abs(dx) < 3 ){
					hero.x = tx;
					step = 1;
					sens *= -1;
				}


			case 3:

		}


	}

	function moveBall(){
		for( sp in bList ){

			sp.towardSpeed(sp.trg,0.1,1);
			if( sp.getDist(sp.trg)<20 )newTarget(sp);


			for( spo in bList ){

				if(sp!=spo){
					var dist = sp.getDist(spo);
					if( dist < 2*ray ){
						var d = (2*ray)-dist;
						var a = sp.getAng(spo);
						var ca = Math.cos(a);
						var sa = Math.sin(a);
						sp.x -= ca*d*0.5;
						sp.y -= sa*d*0.5;
						spo.x += ca*d*0.5;
						spo.y += sa*d*0.5;

					}
				}
			}
			sp.root.x = sp.x;
			sp.root.y = sp.y;
		}
	}

	function newTarget(sp){
		var mx = (ray+SIDE)+20;
		var my = ray;
		sp.trg = {
			x:mx+Math.random()*(Cs.omcw-2*mx),
			y:my+Math.random()*(Cs.omch-2*my),
		}
	}

	function checkCol(){
		var pos = {
			x:hero.x + 8*sens,
			y:hero.y
		}

		var a = bList.copy();
		for( sp in a ){
			if( sp.getDist(pos) < ray+7 ){
				var max = Std.int((sp.root.scaleX*100)/7);
				for( n in 0...2 ){
					var dec = n*(6.28/max)*0.5;
					var speed = 4;
					for( n2 in 0...max ){
						var p = newPhys("partPierceExplo");
						var a = dec + (n2/max)*6.28;
						var ca = Math.cos(a);
						var sa = Math.sin(a);

						var sc = 0.8 - n*0.2;

						p.x = sp.x + ca*ray*sc;
						p.y = sp.y + sa*ray*sc;
						p.vx = ca*speed;
						p.vy = sa*speed;
						p.frict = 0.95-n*0.05;
						p.timer = 16 + n*2 +Std.random(8);
						p.fadeType =0;
						p.vr = 24+(n+Math.random())*8;
						p.fr = 0.95;
						p.updatePos();
						p.root.rotation = a/0.0174;
					}
				}



				sp.kill();
				bList.remove(sp);
			}





		}




		if( bList.length == 0 )setWin(true,10);

	}


//{
}















