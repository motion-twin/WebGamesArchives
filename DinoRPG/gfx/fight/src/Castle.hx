import Fight;

import mt.bumdum.Lib;

class Castle {

	public var max:Int;
	public var life:Int;
	var shake:Float;
	var flBlink:Bool;

	public var slot:SlotDinoz;

	var skin:{ >flash.MovieClip, wall:flash.MovieClip, tower0:flash.MovieClip, tower1:flash.MovieClip, tower2:flash.MovieClip };

	var enclos:flash.MovieClip;
	var pond:flash.MovieClip;
	var armor:flash.MovieClip;
	var repairMan:{>flash.MovieClip,speed:Int,frame:Int};

	public function new(c:CastleInfos){

		Main.me.castle = this;
		max = c._max;
		life = c._life;

		// POND
		if(c._ground>0){
			pond = Scene.me.dm.attach("mcPond",Scene.DP_CASTLE);
			pond.gotoAndStop(c._ground);
		}

		// CASTLE
		skin = cast Scene.me.dm.attach("mcCastle",Scene.DP_CASTLE);
		skin._x = Cs.mcw;

		// ENCLOS
		if( c._cage != null){
			enclos = Scene.me.dm.attach("mcEnclos",Scene.DP_CASTLE);
			enclos._x = skin._x;
		}

		// REPAIRMAN
		if( c._repair>0 ){
			repairMan = cast Scene.me.dm.attach("worker",Scene.DP_CASTLE);
			repairMan._x = 392;
			repairMan._y = 192;
			repairMan.speed =  c._repair;
			repairMan.frame =  0;
			repairMan.smc.gotoAndStop(c._repair);
		}

		// ARMOR
		if( c._armor>0){
			armor = Scene.me.dm.attach("mcCastleArmor",Scene.DP_CASTLE);
			armor.gotoAndStop(c._armor+1);
			armor._x = skin._x;
		}
		
		// INVISIBILITY
		if(  c._invisible ) {
			skin._alpha = 50;
		}

		// COLOR
		if( c._color>0 ) {
			var colors = [
				[1.2,0,0,0,0,
				0,0.7,0,0,0,
				0,0,0.7,0,0,
				0,0,0,1,0],
				[0.7,0,0,0,0,
				0,0.7,0,0,0,
				0,0,0.7,0,0,
				0,0,0,1,0],
			];
			skin.filters = [new flash.filters.ColorMatrixFilter(colors[c._color-1])];
		}

		Scene.WIDTH -= 132;
		slot = new SlotDinoz( 1, null );
		slot.root._visible = true;
		incLife(0);
	}

	public function damage(n,f:Fighter) {
		incLife(-n);
		shake = 30;
		flBlink = true;

		// PARTS
		for( i in 0...20 ) {
			var p = getStone();
			var cy = (Math.random()*2-1);
			p.x = f.x + f.ray;
			p.y = f.y + cy*5;
			p.z = -10+Math.random()*20;
			p.vz = -Math.random()*16;
			p.vx = -Math.random()*4;
			p.vy = cy*2;
			p.updatePos();
		}

		// SLOT
		slot.setLife( life/max );
		slot.fxDamage();
	}

	public function incLife( n ){
		life += n;
		if(life < 0)life = 0;
		var c = 1-life/max;
		var a = [skin.wall,skin.tower0.smc,skin.tower1.smc,skin.tower2.smc];

		for( mc in a ) {
			var fr = 1 + Math.floor(c*(mc._totalframes-1));
			mc.gotoAndStop(fr);
			if( mc == skin.wall && fr == 4 ) {
				armor.removeMovieClip();
				for( i in 0...80 ){
					var p = getStone();
					p.x = 300+Math.random()*80;
					p.y = Math.random()*250 - 50;
					p.vx = (Math.random()*2-1)*3;
					p.vy = (Math.random()*2-1)*3;
					p.z = -Math.random()*100;
					p.updatePos();
				}

				for( i in 0...14 ){
					var p = new Part( Scene.me.dm.attach( "fxCastleSmoke",Scene.DP_FIGHTER) );
					p.x = 300+Math.random()*80;
					p.y = Math.random()*330 -30;
					p.weight = -(0.1+Math.random()*0.1);
					p.vr = (Math.random()*2-1)*12;
					p.z = -Math.random()*100;
					p.friction = 0.98;
					p.frv = 0.9;
					var bl = 16;
					Filt.blur(p.root,bl,bl);
					p.setAlpha(75);
					p.timer = 20+Math.random()*50;
					p.setScale(50+Math.random()*50);
					p.updatePos();

					p.freeze = Math.random()*5;
					p.root._visible = false;
					p.root.stop();

				}
				//repairMan.removeMovieClip();
			}
		}
	}

	public function getStone(){
		var p = new Part( Scene.me.dm.attach( "partCastle", Scene.DP_FIGHTER) );
		p.weight = 0.5+Math.random();
		p.timer = 10+Math.random()*60;
		p.fadeType = 0;
		p.setScale(50+Math.random()*50);
		p.dropShadow();
		return p;
	}

	public function update(){
		if(repairMan != null){
			repairMan.frame += repairMan.speed;
			if( repairMan.frame > 120 ){
				repairMan.frame = 0;
				repairMan.gotoAndPlay("strike");
			}
		}

		if(shake != null) {
			Col.setPercentColor(skin,flBlink?20+shake:0,0xFFFFFF);
			flBlink = !flBlink;
			shake *= 0.5;
			if(shake < 0.5) {
				Col.setPercentColor(skin,0,0xFFFFFF);
				shake = null;
			}
		}
	}
}