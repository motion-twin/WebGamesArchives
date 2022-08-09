package it;

import mt.flash.Volatile;

enum PowerUpKind {
	FrontBack;
	UpDown;
	Speed;
	Capture;
	Uber;
}

class PowerUp extends Item {
	var kind		: Volatile<PowerUpKind>;
	var duration	: Volatile<Int>;
	
	public function new(from:Entity, k:PowerUpKind) {
		super();
		
		kind = k;
			
		autoKillOutsider = true;
		radius = 25;
		copyPos(from);
		
		var a = 3.14 + getAngleTo(game.player);
		dx = Math.cos(a)*0.1;
		dy = Math.sin(a)*0.1;
		
		followScroll = true;
		duration = 30*10;
		frictX = frictY = 1;
		autoKill = Entity.KillCond.LeaveScreen;
		//dx = rseed.range(0.1, 0.2);
		//dy = rseed.range(0.03, 0.05, true);
		
		var mc = new lib.PowerIcon();
		var s = 0.7;
		switch( kind ) {
			case FrontBack : mc.gotoAndStop(1); s =0.8;
			case UpDown : mc.gotoAndStop(2); s = 0.8;
			case Speed : mc.gotoAndStop(3); s = 0.7;
			case Capture : mc.gotoAndStop(4); s = 0.7;
			case Uber : mc.gotoAndStop(10); s = 1;
		}
		mc.scaleX = mc.scaleY = s;
		mc.blendMode = flash.display.BlendMode.ADD;
		spr.addChild(mc);
		//var s = new flash.display.Sprite();
		//var g = s.graphics;
		//g.beginFill(0x724B8B, 1);
		//g.drawCircle(0,0,radius);
		//g.endFill();
		//g.beginFill(0xC8B4D6, 1);
		//switch( kind ) {
			//case FrontBack : g.drawRect(-10,-2, 20,4);
			//case UpDown : g.drawRect(-2,-10, 4,20);
			//case Capture : g.drawCircle(0,0,10);
			//case Speed :
				//g.drawRect(-10,-2, 20,4);
				//g.drawRect(-2,-10, 4,20);
			//default :
		//}
		//g.endFill();
		//s.filters = [
			//new flash.filters.DropShadowFilter(8,-60, 0x0,0.6, 16,16,1, 2,true),
			//new flash.filters.GlowFilter(0xffffff,0.8, 2,2,2),
			//new flash.filters.GlowFilter(0xFFBF00,0.8, 16,16,2),
		//];
		//spr.addChild( mt.deepnight.Lib.flatten(s,16) ); // TODO dispose
	}
	
	
	public static function randomKind(rs:mt.Rand) {
		var rlist = new mt.deepnight.RandList();
		var b = Game.ME.player.build;
		if( b.front<8 )
			rlist.add( FrontBack, 10 );
		if( b.up<8 )
			rlist.add( UpDown, 10 );
		if( b.speed<5 )
			rlist.add( Speed, 5 );
		if( b.capture<8 )
			rlist.add( Capture, 3 );
		if( rlist.length()==0 )
			return null;
		else
			return rlist.draw(rs.random);
	}
	
	
	override function toString() {
		return super.toString()+"["+kind+"]";
	}
	
	public override function pickUp() {
		super.pickUp();
		var txt = "???";
		var inc = game.isLeague() ? api.AKApi.const(2) : api.AKApi.const(1);
		switch( kind ) {
			case FrontBack :
				game.player.build.front+=inc.get();
				game.player.build.back+=inc.get();
				txt = Lang.Horizontal;
			case UpDown :
				game.player.build.up+=inc.get();
				game.player.build.down+=inc.get();
				txt = Lang.Vertical;
			case Speed :
				game.player.build.speed+=inc.get();
				txt = Lang.Speed;
			case Capture :
				game.player.build.capture+=inc.get();
				txt = Lang.Capture;
			case Uber :
				game.player.uber();
				txt = Lang.Uber;
		}
		game.player.applyBuild();
		var pt = getPoint();
		game.pop(pt.x, pt.y, txt);
	}
	
	public override function update() {
		if( duration<=30*1 )
			spr.alpha = game.time%2==0 ? 0.5 : 1;
		else if( duration<=30*3 )
			spr.alpha = game.time%4==0 ? 0.5 : 1;
			
		if( duration--<=0 ) {
			fx.explodeLight(this, color);
			game.addSkill(-0.2);
			destroy();
			return;
		}
		
		//dy += Math.sin( uid+game.time*0.01*3.14 ) * 0.001;
		
		// Rebonds bords
		var pt = getScreenPoint();
		var m = 30;
		if( pt.x<m && dx<0 || pt.x>=Game.WID-m && dx>0 )
			dx = -dx;
		if( pt.y<m && dy<0 || pt.y>=Game.HEI-m && dy>0 )
			dy = -dy;
			
		super.update();
	}
}
