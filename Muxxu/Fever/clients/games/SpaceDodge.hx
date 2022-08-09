
typedef SDTurret = {mc:flash.display.MovieClip,c:Float,l:Int};

class SpaceDodge extends Game{//}

	// CONSTANTES

	// VARIABLES
	var sList:Array<Phys>;
	var tList:Array<SDTurret>;
	var qList:Array<flash.display.MovieClip>;
	var pList:Array<{x:Float,y:Float}>;

	// MOVIECLIPS
	var hero:Phys;
	var ship:flash.display.MovieClip;

	override function init(dif:Float){
		gameTime = 140+dif*300;
		super.init(dif);
		sList = new Array();
		tList = new Array();
		pList = new Array();
		attachElements();
		zoomOld();

	}

	function attachElements(){

		bg = dm.attach("spaceDodge_bg",0);
		getSmc(bg).cacheAsBitmap = true;


		// QUEUE
		qList = new Array();
		for( i in 0...6 ){
			var mc = dm.attach("mcAliquet",Game.DP_SPRITE);
			mc.alpha = 0.5-(i*0.08);
			qList.push(mc);
		}

		// HERO
		hero = newPhys("mcAliquet");
		hero.x = Cs.omcw*0.5;
		hero.y = Cs.omch-10;
		hero.updatePos();
		for( i in 0...100 ) pList.push({x:hero.x,y:hero.y});

		// TOURELLE
		ship = cast(bg).ship;
		for( i in 0...10 ){
			//var mc = Std.getVar(ship,"$t"+i);
			var mc:flash.display.MovieClip = Reflect.field(ship,"$t"+i);

			mc.stop();
			tList.push( { mc:mc,c:10.0+Std.random(10),l:5 } );
		}

		var max = Std.int(9-(dif*10));
		for( i in 0...max ){
			var rnd = Std.random(tList.length);
			tList[rnd].mc.visible = false;
			tList.splice(rnd,1);
		}


	}

	override function update(){

		switch(step){
			case 1:
				// HERO
				if( hero != null ){
					hero.toward(getMousePos(),0.2,16,Cs.mch);
					if( hero.y < ship.height ) heroExplode();
				}
				
				// QUEUE
				var max =  pList.length-1;
				var ec = 4;
				for( i in 0...qList.length ){
					var mc = qList[i];
					mc.blendMode = flash.display.BlendMode.LAYER;
					mc.x = pList[max-i*ec].x;
					mc.y = pList[max-i*ec].y;
				}

				if(hero!=null)pList.push({x:hero.x,y:hero.y});

				// TOWER
				if( win == null ) for( o in tList )if( o.c-- < 0 )tShoot(o);

				// SHOTS
				var a = sList.copy();
				for( mc in a ){
					var m = 10;
					if( mc.x<-m || mc.x > Cs.omcw+m || mc.y <-m || mc.y >Cs.omch+m ){
						mc.kill();
						sList.remove(mc);
					}
					var lim = 8;
					if( hero!=null && Math.abs(hero.x-mc.x)<lim && Math.abs(hero.y-mc.y)<lim){
						sList.remove(mc);
						mc.kill();
						heroExplode();
					}

				}
				
				if( win ) {
					for( i in 0...1 ){
						var c = Math.random();
						var sp  = new Phys( dm.attach("dodge_explosion",Game.DP_PART));
						sp.setScale(1-(c*0.5));
						sp.x = Math.random() * Cs.omcw;
						sp.y = Math.random() * ship.height;
						sp.root.rotation = Math.random()*360;
						sp.vr = (Math.random()*2-1)*16;
						sp.fr = 0.92;
						sp.weight = -Math.random() * 0.35 * c;
						sp.setScale(1 + Math.random());
						sp.timer = 40;
					}
				}


		}
		//
		super.update();
	}

	override function outOfTime(){
		setWin(true, 30);
		while(sList.length > 0) {
			var mc = sList.pop();
			mc.kill();
			//if( mc.root.parent != null ) mc.parent.removeChild(mc);
		}
		fxShake(5,1);
	}

	function tShoot(o:SDTurret){
		// SHOT
		var mc = newPhys("mcTurretShot");
		var m = 0.4;
		var a = m+Math.random()*(3.14-2*m);
		var p = 3.2;
		mc.x = o.mc.x;
		mc.y = o.mc.y;
		mc.vx = Math.cos(a)*p;
		mc.vy = Math.sin(a)*p;
		mc.updatePos();
		mc.frict = 1;
		sList.push(mc);
		// TURRET
		o.mc.gotoAndPlay("2");
		o.c = 14;
	}

	function heroExplode(){

		// PART
		var p = newPhys("mcPartSpaceExplo");
		p.x = hero.x;
		p.y = hero.y;
		p.setScale(2);
		p.updatePos();

		//
		hero.kill();
		hero = null;
		setWin(false,20);

		//
		while(qList.length > 0) {
			var mc = qList.pop();
			mc.parent.removeChild(mc);
		}

	}



//{
}




