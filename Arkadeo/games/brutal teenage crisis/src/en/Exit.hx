package en;

import mt.deepnight.slb.BSprite;
import mt.MLib;

class Exit extends Entity {
	var isOpen			: Bool;
	var light			: BSprite;
	var glow			: BSprite;

	public function new(x,y) {
		super();
		setPos(x,y);
		isOpen = false;

		glow = mode.tiles.get("glow_bomb");
		sprite.addChild(glow);
		glow.y = -23;
		glow.setCenter(0.5, 0.5);
		glow.visible = false;
		glow.scaleX = glow.scaleY = 2;
		glow.blendMode = ADD;

		light = mode.tiles.get("portalLight");
		mode.dm.add(light, Const.DP_BG_FX);
		light.setCenter(0.5, 0.5);
		light.visible = false;

		sprite.filters = [ mt.deepnight.Color.getBrightnessFilter(-0.5) ];
		sprite.set("portalClosed");
	}

	public function open() {
		isOpen = true;
		sprite.a.play("portalOpen").onEnd( function() sprite.a.stopWith("portalOpen", 1) );
		sprite.filters = [ mt.deepnight.Color.getBrightnessFilter(0.1) ];
		glow.visible = light.visible = true;
		fx.pop(xx,yy, Lang.ExitOpened);
	}

	override function unregister() {
		super.unregister();
		glow.destroy();
		light.destroy();
	}

	override function update() {
		super.update();

		if( isOpen ) {
			light.x = sprite.x;
			light.rotation += 5;
			light.y = sprite.y - 23;

			glow.alpha = 0.25 + 0.05 * Math.cos( mode.time*0.15 ) + mt.deepnight.Lib.rnd(0, 0.1);

			// Hero leave
			var h = mode.hero;
			if( !h.hasLeft && MLib.iabs(cx-h.cx)<=1 && MLib.iabs(cy-h.cy)<=1 )
				mode.asProgression().onExit();
		}

		sprite.y+=4;
	}
}