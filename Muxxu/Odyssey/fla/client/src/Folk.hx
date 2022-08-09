import Protocole;
import mt.bumdum9.Lib;


class Folk extends SP{//}
	
	public static var SCALE_MULT = 1.1;

	public static var FAKE = false;
	public static var FAKE2 = false;

	public var side:Int;
	public var sens :Int;
	
	public var mid:MonsterType;
	
	public var pc:PC;
	public var box:SP;
	
	public var anim:PC;

	

	public function new() {
		
		super();
		Scene.me.dm.add(this, Scene.DP_FOLKS);
		x = -50;
		y = Scene.HEIGHT - Scene.GH;
		side = 0;
		sens = 1;

	}
	

	// SKIN
	public function setHero(link:String,ht:HeroType) {
		side = 0;
	
		var mcName = __unprotect__("gfx") + "." + Type.enumConstructor(ht);
		setSkin("gfx." + link, mcName );
		box.scaleX = box.scaleY = Hero.DATA[Type.enumIndex(ht)].scale * 0.01 * SCALE_MULT;
		
	}
	public function setMonster(id:MonsterType) {
		mid = id;
		side = 1;
		var data = Monster.DATA[Type.enumIndex(id)];

	
		//var str = "gfx." + id;
		var str = "gfx." + data.link;
		var mcName = __unprotect__("gfx") + "." + Type.enumConstructor(id);
		
		if( data.link.charCodeAt(0) == "_".code ) {
			var link = data.link.substr(1);
			mcName = null;
			for( m in Monster.DATA )
				if( m.link == link ) {
					mcName = __unprotect__("gfx") + "." + Type.enumConstructor(m.id);
					break;
				}
			if( mcName != null )
				str = "gfx." + link;
		}
		
		if( !Main.player.linkages.exists(str) ) {
			str = "gfx.FOX";
			mcName = __unprotect__("gfx") + "." + __unprotect__("FOX");
		}
		
		
		setSkin(str, mcName);
		box.scaleX = box.scaleY = Monster.DATA[Type.enumIndex(id)].scale * 0.01 * SCALE_MULT;
		

		
	}
	public function setSkin(str,mcname) {
		box = new SP();
		
		pc = Scene.me.attach(str,mcname);
		box.addChild(pc.mc);
		addChild(box);
		

		pc.stop();
		pc.sync();
		//pc.get("box").mc.visible = false;

	}
	public function setSens(n) {
		sens = n;
		scaleX = sens;
	}

	// ANIM
	public function play(str,?onHit:Void->Void,?backToStand:Bool) {
		if ( FAKE ) return;
		
		if ( pc.getFrameLabel(str) != null ) {
			pc.gotoAndStop("stand");
			pc.gotoAndStop(str);
		}
		
		pc.sync();
		var a = pc.children();
		anim = a[0];

		if ( anim == null ) {
			if ( backToStand ) play("stand");
			if ( onHit != null ) onHit();
			return ;
		}
		
		if ( onHit != null)		anim.setLabelEvent("hit", onHit);
		if ( backToStand )		anim.addEndEvent( callback(play, "stand",null,false));
		
	}
	public function haveAnim(str) {
		return pc.getFrameLabel(str) != null;
	}
	
	// TOOLS
	public function getCenter(cx=0.5,cy=0.5) {
		var b = getBounds(this);
		return {
			x : x+(b.left+b.right)*cx,
			y : y+(b.top+b.bottom)*cy,
		}
		
	}
	public function getRandomBodyPos() {
		var b = getBounds(parent);
		var n = 200;
		while (n-->0) {
			var p = {
				x : b.left+Math.random()*b.width,
				y : b.top+Math.random()*b.height,
			}
			if ( this.hitTestPoint(p.x, p.y, true) ) {
				return p;
			}
		}
		return {x:0.0,y:0.0};
		
		/*
		return {
			x : b.left+Math.random()*b.width,
			y : b.top+Math.random()*b.height,
		}
		*/
	}
	public function getGlobalPos() {
		var pos = getCenter();
		return pos;
	}
	
	// FX
	public function fxTwinkle(max,color){
		for( i in 0...max ){
			var p = new mt.fx.Part( new FxDustTwinkle());
			var pos = getRandomBodyPos();
			p.setPos(pos.x,pos.y);
			p.timer = 10 + Std.random(15);
			p.weight = -Math.random() * 0.1;
			p.root.gotoAndPlay( Std.random(p.root.totalFrames) + 1);
			Scene.me.dm.add(p.root,Scene.DP_FX);
			Filt.glow(p.root, 8, 1, color);
			p.root.blendMode = flash.display.BlendMode.ADD;
		}
		
		new mt.fx.Flash(this, 0.5, 0xFFFFFF);
		
	}
	public function fxHeal(){
		new mt.fx.Flash(this, 0.2, 0x88FF00);
		//fxTwinkle(3, 0x88FF00);
	}
	//
	function fakeGfx() {
		graphics.beginFill(0);
		graphics.drawRect( -20, -70, 40, 70);
	}
	
	//
	public dynamic function getStandPos() {
		return 0;
	}
	
	//
	public function kill() {
		parent.removeChild(this);
	}
	
	
//{
}









