import mt.flash.Volatile;
import flash.display.Sprite;
import mt.deepnight.Tweenie;

class ShopItem {
	public static var ALL : Array<ShopItem> = [];
	public static var WID = 420;
	public static var HEI = 40;
	public static var BG = 0x5C232D;
	
	var game			: Game;
	public var id		: Int;
	public var wrapper	: Sprite;
	public var name		: String;
	public var icon		: lib.ShopIcon;
	public var iconOff	: flash.display.Bitmap;
	public var value	: Volatile<Int>;
	public var max		: Volatile<Int>;
	public var cost		: Volatile<Int>;
	public var apply	: Void->Void;
	var active			: Bool;
	var iconsClass		: Class<Dynamic>;
	
	var message			: Null<flash.text.TextField>;
	
	
	var icons			: Array<flash.display.Bitmap>;
	
	public function new(frame:Int, name:String, v, m, iconsClass:Class<Dynamic>) {
		game = Game.ME;
		value = v;
		this.iconsClass = iconsClass;
		max = m;
		this.name = name;
		id = ALL.length;
		icons = new Array();
		active = false;
		
		wrapper = new Sprite();
		wrapper.y = 40 + ALL.length*(HEI+20);
		if( !isExit() ){
			//var g = wrapper.graphics;
			//g.beginFill(BG, 0.6);
			//g.drawRoundRect(0,-15, WID,HEI-9, 10,10);
		}
		
		var tf = game.createField(name, true, 0);
		wrapper.addChild(tf);
		tf.textColor = BG;
		tf.x = 70;
		tf.y = -9;
		if( isExit() ) {
			tf.textColor = BG;
			tf.scaleX = tf.scaleY = 2;
			tf.x = Std.int(WID*0.5 - tf.textWidth*0.5*tf.scaleX);
			tf.y-=8;
		}
		tf.filters = [
			new flash.filters.DropShadowFilter(1,90, 0xffffff,0.6, 2,2,1),
		];
		
		if( !isExit() ) {
			icon = new lib.ShopIcon();
			wrapper.addChild(icon);
			icon.gotoAndStop(1);
			icon.x = 35;
			icon.scaleX = icon.scaleY = 0.5;
			icon.gotoAndStop(frame);
			iconOff = mt.deepnight.Lib.flatten(icon, 8, true);
			iconOff.bitmapData.applyFilter(iconOff.bitmapData, iconOff.bitmapData.rect, new flash.geom.Point(0,0), mt.deepnight.Color.getSaturationFilter(-0.7));
			iconOff.bitmapData.applyFilter(iconOff.bitmapData, iconOff.bitmapData.rect, new flash.geom.Point(0,0), mt.deepnight.Color.getColorizeMatrixFilter(BG, 0.5, 0.5));
			wrapper.addChild(iconOff);
			icon.scaleX = icon.scaleY = 0.85;
		}
		
		game.shop.addChild(wrapper);
		ALL.push(this);
		
		updateCost();
		update();
		setActive(false);
		

		if( !api.AKApi.isReplay() ) {
			wrapper.addEventListener( flash.events.MouseEvent.CLICK, onClick );
			wrapper.addEventListener( flash.events.MouseEvent.MOUSE_OVER, onOver );
		}
	}
	
	function onClick(_) {
		api.AKApi.emitEvent(100+id);
		api.AKApi.emitEvent(1);
	}
	function onOver(_) {
		api.AKApi.emitEvent(100+id);
	}
	
	public function destroy() {
		if( iconOff!=null )
			iconOff.bitmapData.dispose();
		for(bmp in icons ) {
			Game.TW.terminate(bmp);
			bmp.bitmapData.dispose();
		}
	}
	
	public function updateCost() {
		cost = game.player.build.getNextCost();
	}
	
	public function isExit() {
		return max==0;
	}
	
	public function canBuy() {
		return isExit() || game.player.money>=cost && value<max;
	}
	
	public function setActive(b:Bool) {
		active = b;
		if( !isExit() ) {
			icon.visible = active;
			iconOff.visible = !active;
		}
		if( active ) {
			//if( !isExit() ) {
				//icon.scaleX = icon.scaleY = 0.85;
				//icon.filters = [];
			//}
			Game.TW.create(game.shopCursor, "y", wrapper.y-HEI*0.5-5, TBurnIn, 200);
			//game.shopCursor.y = wrapper.y-wrapper.height*0.5;
		}
		//else
			//if( !isExit() ) {
				//icon.scaleX = icon.scaleY = 0.7;
				//icon.filters = [ mt.deepnight.Color.getSaturationFilter(-0.7) ];
			//}
	}
	
	public function buy() {
		if( isExit() )
			apply();
		else if( canBuy() ) {
			game.player.changeMoney( -cost );
			apply();
			game.player.applyBuild();
			value++;
			for( i in ALL ) {
				i.updateCost();
				i.update();
			}
			if( value<max ) {
				var mc = icons[value];
				mc.alpha = 0;
				Game.TW.create(mc, "alpha", 1, 1000);
			}
			var bmp = icons[value-1];
			game.fx.buyItem(wrapper, bmp, bmp.x+bmp.width*0.5, bmp.y+bmp.height*0.5, bmp.width, bmp.height+1);
		}
		else {
			if( game.player.money<cost ) {
				if( message!=null )
					Game.TW.terminate(message);
				message = game.createField(Lang.CantAfford, true);
				wrapper.addChild(message);
				message.x = 200;
				message.y = -8;
				message.textColor = 0xE2A9BA;
				message.filters = [
					new flash.filters.DropShadowFilter(1,90, 0xE2A9BA,1, 0,0, 50),
					new flash.filters.GlowFilter(0x441724,1, 3,3, 10),
					new flash.filters.GlowFilter(0x441724,1, 16,16, 2),
				];
				Game.TW.create(message, "alpha", 0, TEaseIn, 1200).onEnd = function() {
					if( message!=null && message.parent!=null )
						message.parent.removeChild(message);
					message = null;
				}
			}
		}
	}
	
	public function update() {
		for(bmp in icons ) {
			Game.TW.terminate(bmp);
			bmp.parent.removeChild(bmp);
			bmp.bitmapData.dispose();
		}
		icons = [];
		
		for(i in 1...max+1) {
			var mc = new Sprite();
			mc.x = WID - 25 - 30*8 + i*30;
			
			if( i>value ) {
				var base = new Sprite();
				mc.addChild(base);
				base.graphics.beginFill(0x0, 0.1);
				base.graphics.drawCircle(0,2,8);
				base.graphics.drawCircle(0,0,10);
				base.graphics.endFill();
				base.graphics.lineStyle(1, 0x0, 0.1);
				base.graphics.drawCircle(0,0,10);
			}
			
			if( i<=value ) {
				var icon : flash.display.MovieClip = Type.createInstance( iconsClass, [] );
				mc.addChild(icon);
				icon.gotoAndStop( 1 + Std.int(icon.totalFrames * i/max) );
				icon.y = 0;
			}
			else if( i==value+1 ) {
				var icon = new lib.Piece();
				mc.addChild(icon);
				icon.y = -2;
				icon.scaleX = icon.scaleY = 1.4;
				icon.filters = [
					new flash.filters.DropShadowFilter(1 ,90, 0x9A3103,1, 0,0),
				];
				var tf = game.createField(Std.string(cost), true, 2);
				mc.addChild(tf);
				tf.textColor = 0xC83F04;
				tf.filters = [
					new flash.filters.GlowFilter(0x9A3103,1, 2,2,10),
					new flash.filters.DropShadowFilter(1,90, 0x571C02,1, 2,2,1, 1,true),
					new flash.filters.GlowFilter(0xFFE377,0.8, 4,4,4),
				];
				tf.x = Std.int( - tf.textWidth*0.5 );
				tf.y = -5;
			}
			var bmp = mt.deepnight.Lib.flatten(mc, 16, true);
			wrapper.addChild(bmp);
			icons.push(bmp);
		}
		
		// Teinte rouge
		//if( cost>game.player.money )
			//wrapper.transform.colorTransform = mt.deepnight.Color.getColorizeCT(0xFF0000, 0.3);
		//else
			//wrapper.transform.colorTransform = new flash.geom.ColorTransform();
		
		//wrapper.x = active ? 2 : 0;
		//wrapper.alpha = active ? 1 : 0.7;
	}
}
