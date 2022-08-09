import mt.bumdum.Lib;


class Hero extends Element{//}

	static var BASE_WEIGHT = 0.05;//0.07;

	var flReady:Bool;
	var flBoost:Bool;
	var flCrash:Bool;


	public var danger:mt.flash.Volatile<Int>;
	var step:Int;
	var landTimer:Int;
	var angle:Float;
	var ray:Float;
	var nitro:Float;
	var flh:Float;

	var loopBonus:mt.flash.Volatile<Int>;


	var plat:Plat;

	var folks:mt.flash.PArray<Folk>;


	public function new(?fr){

		super(Game.me.dm.attach("mcHero",Game.DP_HERO));
		if(fr==null)fr = 1;
		root.gotoAndStop(fr);

		x = -1;//Cs.mcw*0.5;
		y = Cs.mcw*0.5;

		ray = 10;
		angle = -1.57;

		folks = new mt.flash.PArray();

		Game.me.focus= this;
		takeOff();


		var pl = Game.me.plats[1];
		var px = pl.skin.rampe._x - 30;
		if( px < -(pl.ray-8) ) px += 80;
		x = pl.x+px;
		y = pl.y;
		land(pl);




		loopBonus = 0;
		flh = 100;

		/*
		var v = new Vehicule();
		v.x = x;
		v.setType(0);
		*/

		//Filt.glow(root,2,4,0);



	}
	public function init(){
		var pl = Game.me.plats[1];
		x = pl.x;
		y = pl.y;
		land(pl);

	}

	override function update(){
		flBoost = false;


		if( flh!=null ){
			var prc = flh;
			flh *= 0.93;
			if( flh < 0.1 ){
				flh = null;
				prc = 0;
			}
			Col.setPercentColor( root, prc, 0xFFFFFF );
			root.filters = [];
			if(flh!=null){
				Filt.glow(root,14*flh*0.01,3*flh*0.01,0xFFFFFF);
			}
		}


		switch(step){
			case 0: updateFly();
			case 1: updateLand();
		}






		super.update();
		checkShots();

		if(flBoost)fxBoost();
		else nitro = null;
		for( i in 0...2 ){
			Reflect.field(root,"_reac"+i)._visible = flBoost;
		}






	}

	// FLY
	public function takeOff(){
		vy = -2;
		weight = BASE_WEIGHT;
		step = 0;
	}
	public function updateFly(){


		if( Math.abs(Num.hMod(angle-3.14,3.14)) < 0.1 ){
			loopBonus = 100;
		}
		if(loopBonus>0)loopBonus--;

		if( flash.Key.isDown(flash.Key.LEFT) ) 			turn(-1);
		if( flash.Key.isDown(flash.Key.RIGHT) ) 		turn(1);
		if( flash.Key.isDown(flash.Key.UP) && Game.me.fuel>0 )	boost();
		checkLanding();
		checkLandCrash();

		//
		if( Cs.CONTROL_TYPE == 1 ){
			var da = Num.hMod( angle+1.57, 3.14 );
			da *= 0.95;
			angle = da - 1.57;
			turn(0);
		}


		// BOUND PLAFOND
		if( y<-30 ){
			vy = 0;
			y=-20;
		}




	}

	public function turn(n:Float){
		var spa = 0.08;
		angle += n*spa;
		var n = 10;
		root._rotation = Std.int( (angle/0.0174) /n )*n +90;

	}
	public function boost(){

		Game.me.incFuel(-0.12);
		flBoost = true;
		var pow = 0.2;
		var ca = Math.cos(angle);
		var sa = Math.sin(angle);
		vx += ca*pow;
		vy += sa*pow;


	}

	public function checkLanding(){
		// UPDATE DANGER
		//gyro.stab.smc._rotation = hero.root._rotation;
		var rot = Math.abs( root._rotation );
		danger = 0;
		if( rot > 10 )danger++;
		if( rot > 30 )danger++;

		var speed = Math.sqrt(vy*vy+vx*vx);
		if( speed >  Cs.LAND_SPEED_LIMIT )	danger++;
		if( speed >  Cs.LAND_SPEED_LIMIT*2 )	danger++;

		if(danger>2)danger = 2;


		// CHECK PLATS
		for( pl in Game.me.plats ){
			var flUp = y+9 < pl.y;
			if( flUp != pl.flUp ){
				var dx = Math.abs(pl.x-x);
				if( pl.flUp && dx < pl.ray+ray ){
					if( danger < 2 && dx < pl.ray){
						land(pl);
					}else{
						crash();
					}


				}
				pl.flUp = flUp;
			}

		}

	}
	public function getSpeed(){
		return Math.sqrt(vx*vx+vy*vy);
	}

	public function checkLandCrash(){

		for( i in 0...2 ){
			var sens = i*2-1;
			var x  = (x+10*sens);
			var gy = Game.me.getGY(x);
			//Game.me.mark(x,gy);

			if( gy < y+8 ){
				crash();
			}

		}
	}
	public function checkShots(){
		var px = Cs.getPX(x);
		var py = Cs.getPY(y);
		var a = Game.me.sgrid[px][py];
		for( shot in a ){
			var dx = Game.me.getHeroDX(shot.x);
			var dy = y - shot.y;
			if( Math.sqrt(dx*dx+dy*dy) < ray ){
				shot.kill();
				crash();
				return;
			}
		}
	}

	public function crash(){
		flCrash = true;

		while(folks.length>0){
			var f = drop();
			f.x = x+(Math.random()*2-1)*10;
			f.y = y+(Math.random()*2-1)*10;
		}

		// EXPLO
		var mc = Game.me.dm.attach("mcExplosion",Game.DP_UNDER_FX);
		mc._x = x;
		mc._y = y;
		mc.blendMode = "add";

		// DUST

		var max = 80;
		if(Math.abs(Game.me.getGY(x)-y)>20)max = 0;
		for( i in 0...max ){
			var sp = 2+Math.random()*5;
			var a = i/max * 6.28;
			var cr = 2;
			var ca = Math.cos(a)*sp;
			var sa = Math.sin(a)*sp;
			var p = Game.me.getDust();
			p.x = x+ca*cr;
			p.y = y+sa*cr;
			p.vx = ca + vx*0.3;
			p.vy = sa + vy*0.3;
			//p.root._xscale = p.root._yscale = 200;
			p.updatePos();

		}


		// PARTS
		for( i in 0...12 ){
			var mc:flash.MovieClip = Game.me.dm.attach("partHero",Game.DP_FX);
			mc._x = x;
			mc._y = y;
			mc._rotation = root._rotation;
			mc.gotoAndStop(i+1);
			var pos = Geom.getParentCoord(mc.smc,mc);
			mc.smc._x = 0;
			mc.smc._y = 0;
			var p = new Part( mc );
			var a = Math.atan2(pos.y-mc._y,pos.x-mc._x);
			var sp = Math.random()*4;
			p.x = pos.x;
			p.y = pos.y;
			//Game.me.mark(pos.x,pos.y);
			p.vx = Math.cos(a)*sp + vx*0.5;
			p.vy = Math.sin(a)*sp + vy*0.5;
			p.vr = (Math.random()*2-1)*12;
			p.timer = 40+Math.random()*60;
			p.weight = 0.05+Math.random()*0.05;
			p.ray = 6;
			p.updatePos();
			//if( i == 0 )Game.me.focus = p;
		}


		// SPARKS
		var max = 80;
		for( i in 0...max ){
			var sp = Math.random()*8;
			var a = i/max * 6.28;
			var cr = 5;
			var ca = Math.cos(a)*sp;
			var sa = Math.sin(a)*sp;
			var p = getSpark(0);
			p.x += ca*cr;
			p.y += sa*cr;
			p.vx = ca + vx*0.2;
			p.vy = sa + vy*0.2;
			p.updatePos();

		}

		// ONDE
		var mc = Game.me.dm.attach("mcOnde",Game.DP_UNDER_FX);
		mc._x = x;
		mc._y = y;

		// PROJETT FOLKS

		for( f in Game.me.folks ){
			f.fly();
			f.flBounce = true;
			f.root.gotoAndPlay("_jump2");
			f.root.gotoAndPlay(f.root._currentframe+Std.random(10));
			f.vx += 100/(f.x-x);
			f.vy = -Math.abs(300/(f.x-x));
			var lim = 3+Math.random()*5;
			while( Math.abs(f.vx)>lim || Math.abs(f.vy)>lim ){
				f.vx *= 0.9;
				f.vy *= 0.9;
			}
			//f.vx = Num.mm(-lim,f.vx,lim);
			//f.vy = Num.mm(-lim,f.vy,lim);
			if( f.x-x == 0  )f.kill();
		}




		if(Game.me.flRescue)		Game.me.spawn();
		else				Game.me.endTimer = 20;


		Game.me.hero = null;
		kill();




	}


	// FOLKS
	public function isFree(){
		return step==0 && folks.length < 10;
	}
	public function board(f:Folk){
		vy += 0.5;
		folks.push(f);
		updateFolks();

		var sc = Cs.SCORE_BOARD;
		var bonus = KKApi.cmult(Cs.SCORE_BOARD_BONUS,KKApi.const(folks.length-1));
		sc = KKApi.cadd( sc, bonus );
		KKApi.addScore(sc);
		Game.me.fxScore(x,y-10,KKApi.val(sc));

	}
	function drop():Folk{
		//trace("drop!"+angle);
		var f = folks.pop();

		//var mc = Reflect.field(root,"_p"+folks.length);
		//var pos = Geom.getParentCoord(mc,root);

		var c = 2;
		//if(flCrash)c = 6;

		f.unride();
		f.x = x+(Math.random()*12-6)*c;
		f.y = y+(Math.random()*12-6)*c;
		updateFolks();
		return f;
	}
	/*
	function checkFolkFall(){
		var da = Num.hMod(angle-1.57,3.14);
		if( Math.random()*2 > Math.abs(da) )drop();

	}
	*/

	function updateFolks(){
		if(step==0){
			weight  = BASE_WEIGHT + folks.length *0.02; //+ Game.me.dif*0.0001;
		}

		Game.me.mdm.clear(8);
		var id = 0;
		for( f in folks ){
			var mc = Game.me.mdm.attach("mcCosmo",8);
			mc._x = 2 + id*14;
			mc._y = 2;
			mc._xscale = mc._yscale = 200;
			Reflect.setField(mc,"_colorMe",f.colorMe);
			id++;
		}


	}


	// FX
	public function getSpark(distMax){
		var p = new Part(Game.me.dm.attach("partSpark",Game.DP_UNDER_FX));
		p.x = x ;
		p.y = y;
		p.weight = 0.025 + Math.random()*0.04;
		p.timer = 10+Math.random()*50;
		p.bounceFrict = 0;



		var a = Math.random()*6.28;
		var dist = Math.random()*distMax;
		p.root._rotation = a/0.0174;

		p.root.smc._x += dist;
		p.vr = (Math.random()*2-1)*20;
		p.fr  = 0.95;
		p.x -= Math.cos(a)*dist;
		p.y -= Math.sin(a)*dist;

		return p;

	}
	function fxBoost(){
		if(nitro==null)nitro = 1;

		var ec = 8;

		var dx = Math.cos(angle+1.57)*ec;
		var dy = Math.sin(angle+1.57)*ec;

		for( i in 0...2 ){
			if(Math.random()<nitro  && Std.random(Game.me.lag) == 0 ){
				var sens = i*2-1;
				var a = angle+(Math.random()*2-1)*0.1;
				var sp = 0.5+Math.random()*3;
				var ca = Math.cos(a);
				var sa = Math.sin(a);
				var p = getSpark(10);
				p.x += dx*sens - ca*ec;
				p.y += dy*sens - sa*ec;
				p.vx = vx*0.5-ca*sp;
				p.vy = vy*0.5-sa*sp;
				p.updatePos();
			}
		}


		// DUST GROUND
		if( Std.random(Game.me.lag) == 0 ){
			var sx = x;
			var sy = y;
			var max = 10;
			var ec = 10;
			var ca = Math.cos(angle);
			var sa = Math.sin(angle);
			var coef = null;
			for( i in 0...max ){
				sx -= ca*ec;
				sy -= sa*ec;
				if( Game.me.getGY(sx) < sy ){
					coef = 1-i/max;
					break;
				}
			}
			if( coef !=null ){
				var max = Std.int(coef*4);
				var pw = coef*4;
				for( i in 0...max ){
					var p = Game.me.getDust(sx);
					p.vx = (Math.random()*2-1)*pw;
					p.vy = -Math.random()*pw*0.75;
					p.root._xscale = p.root._yscale = 150;
				}
			}


		}

		if(nitro>0.1)nitro *= 0.8;

		/*
		var c = 1- (Game.me.getGY(x)-y) / 100;
		if( Math.random()<c &&  c <1 ){
			for( i in 0...2 )fxDust( c*2 );
		}
		*/


	}
	/*
	function fxDust(pw:Float){
		var p = Game.me.getDust(x);
		p.vx = (Math.random()*2-1)*pw;
		p.vy = -Math.random()*pw;
		p.root._xscale = p.root._yscale = 150;
	}
	*/



	// LANDING
	public function land(pl){

		flReady = false;
		step = 1;
		vx = 0;
		vy = 0;
		plat = pl;
		angle = -1.57;
		root._rotation = 0;
		weight = 0;
		landTimer = 3;
		y = plat.y+1-ray;

		updatePos();
		// PERFECT BONUS


		// LOOP BONUS
		if( folks.length>0 ){

			if( loopBonus>0 ){

				loopBonus = 0;
				var sc = KKApi.cmult( Cs.SCORE_LOOP, KKApi.const(folks.length) );
				KKApi.addScore(sc);
				Game.me.fxScore(x,y-15,KKApi.val(sc));

			}else if( danger == 0 ){
				/*
				var sc = Cs.SCORE_PERFECT;
				KKApi.addScore(sc);
				Game.me.fxScore(x,y-15,KKApi.val(sc));
				*/
			}
		}

	}
	public function updateLand(){
		Game.me.incFuel(1);
		if( landTimer++>3 && folks.length > 0 ){
			Game.me.stopRescue();
			landTimer = 0;
			var f = drop();
			f.jumpTo(plat);
		}

		if( folks.length == 0 && flash.Key.isDown(flash.Key.UP) ){
			if(flReady)takeOff();
		}else{
			flReady = true;
		}

	}



//{
}










