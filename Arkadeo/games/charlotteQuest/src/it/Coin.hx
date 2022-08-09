package it;

import mt.flash.Volatile;

class Coin extends Item {
	static var COPPER = api.AKApi.const(1);
	static var SILVER = api.AKApi.const(2);
	static var GOLD = api.AKApi.const(5);
	
	var value		: api.AKConst;
	var playSpeed	: Float;
	
	public function new(e:Entity, type:Int) {
		super();
		
		radius = 25;
		copyPos(e);
		
		frictX = 0.98;
		frictY = 0.95;
		gravity = 0.002 + rnd(0, 0.002);
		autoKill = Entity.KillCond.ReachDown;
		autoKillOutsider = true;
		
		spr.rotation = rnd(5,40,true);
		playSpeed = rnd(4,7);
		
		animMC = cast new lib.Gold();
		spr.addChild(animMC);
		
		var gen = cacheAnims("coin_"+type, type==2 ? 1.2 : 1 );
		setAnim("label");

		var desat = mt.deepnight.Color.getSaturationFilter(-1);
		switch( type ) {
			case 0 :
				value = COPPER;
				if( gen ) {
					var pt0 = new flash.geom.Point(0,0);
					var teints = [ 0xD0A3D3, 0xBA8965, 0xA28C59 ];
					var f = 0;
					for( bd in animCache.get("label") ) {
						bd.applyFilter(bd, bd.rect, pt0, desat);
						bd.colorTransform( bd.rect, mt.deepnight.Color.getColorizeCT(0xCF5641, 0.7) );
						if( f!=0 && Std.random(100)<30 )
							bd.colorTransform( bd.rect, mt.deepnight.Color.getColorizeCT(teints[Std.random(teints.length)], 0.4) );
						f++;
					}
				}
			case 1 :
				value = SILVER;
				if( gen ) {
					var pt0 = new flash.geom.Point(0,0);
					var teints = [ 0xD0A3D3, 0xDDC799, 0xC0E7C6 ];
					var f = 0;
					for( bd in animCache.get("label") ) {
						bd.applyFilter(bd, bd.rect, pt0, desat);
						bd.colorTransform( bd.rect, mt.deepnight.Color.getColorizeCT(0xB0DFEE, 0.3) );
						if( f!=0 && Std.random(100)<30 )
							bd.colorTransform( bd.rect, mt.deepnight.Color.getColorizeCT(teints[Std.random(teints.length)], 0.4) );
						f++;
					}
				}
			case 2 :
				color = 0xFFBF00;
				value = GOLD;
			default : throw "err"+type;
		}
		
		game.totalMoney+=value.get();
		
		spr.scaleX = spr.scaleY = switch(type) {
			case 2 : 1;
			case 1 : 0.75;
			case 0 : 0.55;
		}
		
		dy = -rnd(0.10, 0.16);
	}
	
	public override function setPos(x,y,?xrr:Float,?yrr:Float) {
		super.setPos(x,y,xrr,yrr);
		var pt = getScreenPoint();
		dx = 0.05 * (pt.x<Game.WID*0.5 ? 1 : -1) + game.lastScroll.x;
	}
	
	public override function pickUp() {
		super.pickUp();
		game.player.changeMoney(value.get(), this);
		//fx.pickCoin(this);
	}
	
	override function onAutoKill() {
		super.onAutoKill();
		game.addSkill(-0.01);
	}

	public override function update() {
		super.update();
		
		if( game.perf<0.65 ) {
			if( !animPaused )
				setAnimFrame(0);
			animPaused = true;
		}

		spr.rotation *= 0.91;
		
		if( !skipThisAnimFrame() ) {
			var skip = Math.ceil(playSpeed)-1;
			for(i in 0...skip) {
				cachedAnimFrame++;
				if( animDone() )
					cachedAnimFrame = 0;
			}
			if( skip>0 )
				setAnimFrame(cachedAnimFrame);
			if( playSpeed>1 )
				playSpeed-=0.07;
		}
	}
}
