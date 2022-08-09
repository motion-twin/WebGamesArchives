import flash.display.Sprite;
import mt.deepnight.Tweenie;
import mt.deepnight.Color;

class LifeJauge extends Sprite {
	var man				: Manager;
	
	var hearts			: Array<Sprite>;
	var shields			: Array<Sprite>;
	var hWrapper		: Sprite;
	var sWrapper		: Sprite;
	var resistSlots		: Sprite;
	var bg				: Sprite;
	
	public var life		: Int;
	public var resist	: Int;
	public var maxResist(default, setMaxResist): Int;
	public var maxWidth	: Float;
	
	public var compact	: Bool;
	
	public function new() {
		super();
		man = Manager.ME;
		life = resist = 0;
		hearts = [];
		shields = [];
		compact = false;
		maxWidth = 100;
		maxResist = 0;
		
		bg = new Sprite();
		//bg.graphics.beginFill(0x0, 0.4);
		//bg.graphics.drawRect(0,0,100, 10);
		//addChild(bg);
		
		addChild( hWrapper = new Sprite() );
		addChild( resistSlots = new Sprite() );
		addChild( sWrapper = new Sprite() );
		//sWrapper.filters = [ new flash.filters.GlowFilter(0x38221D,1, 2,2,4) ];
	}
	
	public function setHostile(b:Bool) {
		if( b )
			filters = [
				new flash.filters.GlowFilter(0xFF9F11,1, 2,2,10),
				//new flash.filters.GlowFilter(0x0,0.5, 2,2,6),
			];
		else
			filters = [
				//new flash.filters.GlowFilter(0x745652,1, 2,2,10),
				//new flash.filters.GlowFilter(0x0,0.6, 2,2,6),
			];
	}
	
	function setMaxResist(m) {
		maxResist = m;
		//resistSlots.graphics.clear();
		//var g = resistSlots.graphics;
		//g.lineStyle(1, 0xD3CAB6, 1, flash.display.LineScaleMode.NONE);
		//for(i in 0...m)
			//g.drawRect(i*4-1,-2, 3,5);
		return maxResist;
	}
	
	public function update(?anim=true) {
		bg.width = maxWidth;
		bg.height = compact ? 7 : 11;
		// Bug fix (TODO)
		if( life<0 ) life = 0;
		if( resist<0 ) resist = 0;
		
		//var oldLife = hearts.length;
		//var oldResist = shields.length;
		//for(s in hearts)
			//s.parent.removeChild(s);
		//hearts = [];
		//for(s in shields)
			//s.parent.removeChild(s);
		//shields = [];

		//var w = compact ? 3 : 12;
		//var h = compact ? 5 : 9;
		
		// Vies
		var spacing = compact ? 5 : 13;
		var old = hearts.length;
		if( life>old)
			// Ajout
			for(i in 0...life-old) {
				var s = compact ? man.tiles.getSprite("smallLife") : man.tiles.getSprite("largeJauge", 0);
				s.setCenter(0,0);
				hWrapper.addChild(s);
				s.x = Math.round(hearts.length*spacing);
				hearts.push(s);
				s.y = anim ? 4 : 0;
				man.tw.create(s,"y", 0, TEaseOut, 1000).onUpdateT = function(t) {
					if( t<1 )
						s.filters = [
							new flash.filters.GlowFilter(0xffffff,1-t, 2,2, 10),
							new flash.filters.GlowFilter(0xffffff,1-t, 4,4,8, 1,true),
						];
					else
						s.filters = [];
				}
			}
		if( life<old ) {
			// Suppression
			while( hearts.length>life ) {
				var s = hearts.splice(hearts.length-1, 1)[0];
				man.tw.create(s, "y", s.y-7, TEaseOut, 400);
				man.tw.create(s, "alpha", 0, TEaseIn, 1500).onEnd = function() {
					s.parent.removeChild(s);
				}
			}
		}
		
		//if( resist>0 )
			if( anim ) {
				var a = man.tw.create(sWrapper, "x", Std.int(hearts.length*spacing), TEaseOut );
				a.fl_pixel = true;
				a.onUpdate = function() {
					resistSlots.x = sWrapper.x;
				}
			}
			else {
				sWrapper.x = resistSlots.x = Std.int(hearts.length*spacing);
			}
		
		
				
		// Boucliers
		var spacing = compact ? 5 : 13;
		var old = shields.length;
		if( resist>old)
			// Ajout
			for(i in 0...resist-old) {
				var s = compact ? man.tiles.getSprite("smallShield") : man.tiles.getSprite("largeJauge", 1);
				s.setCenter(0,0);
				//var s = new Sprite();
				sWrapper.addChild(s);
				//s.graphics.beginFill(0xD3CAB6, 1);
				//s.graphics.drawRect(0,0, w, h);
				s.x = Math.round(shields.length*spacing);
				shields.push(s);
				if( anim ) {
					s.scaleX = 2;
					s.scaleY = 2;
					man.tw.create(s,"scaleX", 1, TEaseOut, 800);
					man.tw.create(s,"scaleY", 1, TEaseOut, 800);
				}
			}
		if( resist<old ) {
			// Suppression
			while( shields.length>resist ) {
				var s = shields.splice(shields.length-1, 1)[0];
				man.tw.create(s, "y", s.y-7, TEaseOut, 400).onUpdateT = function(t) {
					s.filters = [ new flash.filters.GlowFilter(0xFFFFFF,t, 4,4, 3) ];

				}
				man.tw.create(s, "alpha", 0, TEaseIn, 1500).onEnd = function() {
					s.parent.removeChild(s);
				}
			}
		}
		
		scaleX = 1;
		if( (hearts.length+shields.length)*spacing > maxWidth )
			scaleX = maxWidth / ( (hearts.length+shields.length)*spacing );
		
		// Fonds des boucliers
		//if( !compact ) {
			//while( resistSlots.numChildren>0 )
				//resistSlots.removeChildAt(0);
			//for(i in 0...maxResist) {
				//var s = man.tiles.getSprite(compact ? "smallJauge" : "largeJauge", 2);
				//s.setCenter(0,0);
				//resistSlots.addChild(s);
				//s.x = i*(w+1);
			//}
		//}
		
		/*
		for(i in 0...resist) {
			var s = new Sprite();
			sWrapper.addChild(s);
			s.graphics.beginFill(0xD3CAB6, 1);
			s.graphics.drawRect(Std.int(-w*0.5), Std.int(-h*0.5), w, h);
			s.x = Math.round(x);
			shields.push(s);
			x+=spacing;
		}
		*/

		//if( compact )
			//hWrapper.filters = [
				//new flash.filters.DropShadowFilter(1,-90, 0x0,0.5, 0,0,1, 1,true),
				//new flash.filters.GlowFilter(0x0,0.7, 2,2,4),
			//];
		//else
			//hWrapper.filters = [
				//new flash.filters.DropShadowFilter(1,0, 0xffffff,0.3, 0,0,1, 1,true),
				//new flash.filters.DropShadowFilter(3,-90, 0x0,0.5, 0,0,1, 1,true),
				//new flash.filters.GlowFilter(0x0,0.5, 2,2,4),
			//];
		//sWrapper.filters = hWrapper.filters;
	}
}
