package me;

import mt.MLib;
import mt.deepnight.slb.*;
import mt.deepnight.*;
import flash.display.Bitmap;
import flash.display.Sprite;

class Ball extends MenuEntity {
	public static var ALL = [];

	var ground		: Float;
	var dir			: Int;
	var shadow		: Bitmap;
	var phong		: BSprite;
	var speed		: Float;
	var gravity		: Float;
	public var z			: Float;

	public function new(p) {
		super(p);
		ALL.push(this);
		spr.set("ball");
		spr.a.playAndLoop("ball");
		spr.setCenter(0.5,0.5);
		makeShadow();
		speed = rnd(0.07, 0.14);
		gravity = rnd(0.25, 0.35);
		z = rnd(0, 1);

		phong = process.tiles.get("ballPhong");
		spr.addChild(phong);
		phong.setCenter(0.5, 0.5);

		spr.scaleX = spr.scaleY = 2 - z*1.2;

		dir = Lib.sign();
		ground = process.getHeight() * 0.95 - z*50;
		setPos(dir==1 ? -10 : process.getWidth()+10, ground-rnd(40,100));
	}

	function makeShadow() {
		var s = new Sprite();
		s.graphics.clear();
		s.graphics.beginFill(0x0, 0.5);
		s.graphics.drawEllipse(0,0, 14,7);
		s.filters = [
			new flash.filters.BlurFilter(8,4),
		];

		shadow = mt.deepnight.Lib.flatten(s,8);
		//process.wrapper.addChildAt(shadow, spr.parent.getChildIndex(spr));
		process.wrapper.addChild(shadow);
	}

	override function destroy() {
		super.destroy();
		phong.dispose();
		shadow.bitmapData.dispose(); shadow.bitmapData = null;
		ALL.remove(this);
	}

	override function updateSprite() {
		super.updateSprite();
		spr.y-=5;
		if( shadow!=null ) {
			var h = MLib.fclamp((ground - spr.y)/60, 0,1);
			shadow.scaleX = shadow.scaleY = (1-h)*(0.5+(1-z));
			shadow.alpha = 1-h;
			shadow.x = xx-shadow.width*0.5;
			shadow.y = ground - shadow.height*0.5;
			phong.rotation = -spr.rotation;
		}
	}

	override function update() {
		super.update();

		dx+=speed*dir;
		dy+=gravity;

		if( yy>=ground && dy>0 ) {
			// Bounce
			spr.rotation = rnd(0,360);
			dy = -dy;
		}

		if( dir==1 && xx>=process.getWidth()+10 || dir==-1 && xx<=-10 )
			destroy();
	}
}
