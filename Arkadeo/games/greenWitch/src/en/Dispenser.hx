package en;

import Const;
import mt.deepnight.retro.SpriteLibBitmap;


class Dispenser extends Entity {
	public static var ALL : Array<Dispenser> = [];
	
	var effect			: DispenserEffect;
	var sub				: BSprite;
	var halo			: Null<flash.display.Bitmap>;
	
	public function new(x,y, eff:DispenserEffect) {
		super();
		cx = x;
		cy = y;
		effect = eff;
		collides = false;
		weight = 0;
		selectable = true;
		
		game.currentLevel.addCollision(cx,cy);
		
		// Halo
		if( !api.AKApi.isLowQuality() ) {
			var s = new flash.display.Sprite();
			s.graphics.beginFill(0xFFFFFF, 1);
			s.graphics.drawCircle(0,0, 40);
			s.filters = [ new flash.filters.BlurFilter(16,16) ];
			s.scaleY = 0.6;
			halo = mt.deepnight.Lib.flatten(s, 16, true);
			halo.blendMode = flash.display.BlendMode.OVERLAY;
			game.sdm.add(halo, Const.DP_BG_FX);
		}
		
		sub = new BSprite(game.char);
		sub.setCenter(0.5,1);
		sprite.addChild(sub);
		switch( effect ) {
			case D_GiveTurret(t) :
				sub.swap("tdispenser", switch(t) {
					case T_Gatling : 2;
					case T_Slow : 1;
					case T_Shield : 0;
					case T_Burner : 3;
				});
			case D_GiveWeapon(w) :
				sub.swap("wdispenser", switch(w) {
					case W_Basic : 2;
					case W_Lazer : 0;
					case W_Grenade : 1;
					case W_Lightning : 3;
				});
		}
		
		game.currentLevel.setUsedZone(cx,cy, 1,1);
	}
	
	override public function isOver(x:Float, y:Float) {
		return x>=xx-15 && x<xx+15 && y>=yy-50 && y<=yy;
	}
	
	public override function register() {
		super.register();
		ALL.push(this);
	}
	public override function detach() {
		super.detach();
		ALL.remove(this);
		if( halo!=null ) {
			halo.bitmapData.dispose();
			halo.parent.removeChild(halo);
		}
	}
	
	override function onActivate() {
		super.onActivate();
		
		hero.stop();
		
		if( cd.has("activate") )
			return;
			
		var delay = 20;
		switch( effect ) {
			case D_GiveTurret(t) :
				if( t==game.hero.turretType )
					fx.pop(xx,yy, Lang.TurretReloaded, true);
				else
					fx.pop(xx,yy, Lang.ALL.get("Turret"+Type.enumIndex(t)), true);
				game.hero.setTurret(t);
				S.BANK.item02().play();
				
			case D_GiveWeapon(w) :
				if( w==game.hero.weaponType )
					fx.pop(xx,yy, Lang.WeaponReloaded, true);
				else
					fx.pop(xx,yy, Lang.ALL.get("Weapon"+Type.enumIndex(w)), true);
				game.hero.setWeapon(w);
				delay = 8;
				S.BANK.item02().play();
		}
		cd.set("activate", delay*30);
		
		sub.filters = [
			mt.deepnight.Color.getSaturationFilter(-0.5),
			mt.deepnight.Color.getColorizeMatrixFilter(0x0, 0.5, 0.5),
		];
		if( halo!=null )
			halo.visible = false;
	}
	
	override public function update() {
		super.update();
		
		if( !cd.has("activate") )
			sub.filters = [];
		
		if( halo!=null ) {
			halo.visible = sprite.visible && !cd.has("activate");
			halo.x = sprite.x - halo.width*0.5;
			halo.y = sprite.y - halo.height*0.5;
		}
	}
	
}