package en;

import mt.deepnight.slb.BSprite;

class Item extends Entity {
	var autoKill			: Int;
	var blink				: Bool;
	var glow				: Null<BSprite>;
	var floating			: Bool;

	public function new(x,y) {
		super();
		setPos(x,y);
		blink = false;
		autoKill = -1;
		floating = true;
		mode.dm.add(sprite, Const.DP_ITEM);

		cd.set("pick", 5);
		gravity *= rnd(0.4, 0.6);
		setDuration(9);
	}

	inline function addGlow(k:String) {
		glow = mode.tiles.get(k);
		mode.dm.add(glow, Const.DP_BG_FX);
		glow.setCenter(0.5, 0.5);
		glow.blendMode = ADD;
		glow.visible = false;
	}

	override function unregister() {
		super.unregister();
		if( glow!=null )
			glow.destroy();
	}

	public function setDuration(?seconds:Int) {
		if( mode.isProgression() )
			autoKill = -1;
		else
			if( seconds==null )
				autoKill = -1;
			else
				autoKill = 30*seconds;
	}

	function setGenericSkin(letter:String, col:Int) {
		var r = 14;
		sprite.graphics.clear();
		sprite.graphics.beginFill(col,1);
		sprite.graphics.drawCircle(0,-14,14);
		sprite.filters = [
			new flash.filters.DropShadowFilter(4, -120, 0x0, 0.5, 8,8,1, 1,true),
			new flash.filters.GlowFilter(col, 0.9, 16,16,1, 2),
		];

		var tf = mode.createField(letter, 0xFFFFFF, true);
		sprite.addChild(tf);
		tf.filters = [ new flash.filters.GlowFilter(0x0, 0.8, 4,4,1) ];
		tf.x = Std.int(-tf.width*0.5 + 1);
		tf.y = Std.int(-r - tf.height*0.5 - 1);
	}

	public function onPick() {
		destroy();
	}

	override function update() {
		super.update();

		frictX = stable ? 0.85 : 0.92;

		if( autoKill>=0 ) {
			if( autoKill--<=0 )
				destroy();

			if( autoKill<=30*2 ) {
				if( cd.hasSet("blink", 5) )
					blink = !blink;
				sprite.alpha = blink ? 0.4 : 0.8;
			}
		}

		if( !cd.has("pick") ) {
			var hero = mode.hero;
			if( Math.abs(cx-hero.cx)<=2 && Math.abs(cy-hero.cy)<=2 )
				if( mt.deepnight.Lib.distance(xx,yy-5, hero.xx,hero.yy-hero.radius) <= radius+hero.radius )
					onPick();
		}

		if( floating ) {
			sprite.y += - 3 + Math.cos((mode.time+uid)*0.2) * 4;
			sprite.y = Std.int(sprite.y);
		}

		if( glow!=null ) {
			glow.x = sprite.x;
			glow.y = sprite.y - Const.GRID*0.5;
			glow.alpha = sprite.alpha;
			glow.visible = sprite.visible;
		}
	}
}