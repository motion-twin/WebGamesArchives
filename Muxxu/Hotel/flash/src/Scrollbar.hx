import Game;
import Protocol;
import mt.deepnight.Tweenie;

using mt.deepnight.SuperMovie;
import mt.deepnight.Types;

class Scrollbar {
	public var mc		: interf.ScrollBar;
	var root			: MC;
	var scroller		: SPR;
	var hotel			: _Hotel;
	var fl_scrolling	: Bool;
	var fl_vertical		: Bool;
	
	
	public function new(r, scr, h:_Hotel) {
		root = r;
		scroller = scr;
		fl_scrolling = false;
		
		hotel = h;
		
		mc = new interf.ScrollBar();
		setVertical();
		
		mc.top.onClick( callback(scroll, -Game.FLOOR_HEI*2) );
		mc.top.handCursor(true);
		
		mc.bottom.onClick( callback(scroll, Game.FLOOR_HEI*2) );
		mc.bottom.handCursor(true);
		
		mc.mid.onMouseDown( onStartScroll );
		root.onMouseUp( onEndScroll );
		mc.mid.handCursor(true);
		
		mc.mid.onOver( callback(onOver, mc.mid) );
		mc.mid.onOut( callback(onOut, mc.mid) );
		mc.mid.filters = getBaseFilter();

		mc.top.onOver( callback(onOver, mc.top) );
		mc.top.onOut( callback(onOut, mc.top) );
		mc.top.filters = getBaseFilter();

		mc.bottom.onOver( callback(onOver, mc.bottom) );
		mc.bottom.onOut( callback(onOut, mc.bottom) );
		mc.bottom.filters = getBaseFilter();

		var off = 0.5;
		mc.alpha = off;
		var me = this;
		//mc.filters = [ new flash.filters.DropShadowFilter(2,0,0x203557,1, 0,0,1) ];
		mc.onOver( function() { Game.TW.create(me.mc, "alpha", 1, DateTools.seconds(0.2)); } );
		mc.onOut( function() { Game.TW.create(me.mc, "alpha", off, DateTools.seconds(0.5)); } );
		updateScrollBar();
	}
	
	public function setHorizontal() {
		fl_vertical = false;
		mc.rotation = -90;
		mc.x = 5;
		mc.y = Game.HEI-5;
		updateScrollBar();
	}
	
	public function setVertical() {
		fl_vertical = true;
		mc.rotation = 0;
		mc.x = Game.WID-mc.width-5;
		mc.y = 5;
		updateScrollBar();
	}
	
	public function setHotel(h:_Hotel) {
		hotel = h;
		updateScrollBar();
	}
	

	inline function getMaxScroll() {
		if( fl_vertical )
			return (2+hotel._floors)*Game.FLOOR_HEI-Game.HEI;
		else
			return Math.round( (5.5+hotel._width)*Game.ROOM_WID - Game.WID );
	}
	
	inline function getBaseFilter() {
		return [
			new flash.filters.GlowFilter(0xffffff,0.5,2,2,3, 1,true),
			new flash.filters.DropShadowFilter(2,90,0x666666,1,0,0,10),
			new flash.filters.GlowFilter(0x0,1,2,2,10),
		];
	}
	
	function onOver(mc:MC) {
		mc.filters = getBaseFilter().concat( [ new flash.filters.GlowFilter(0xffffff,1,2,2,10) ] );
	}
	function onOut(mc:MC) {
		mc.filters = getBaseFilter();
	}
	
	function onStartScroll() {
		fl_scrolling = true;
		var sb = mc;
		var maxHeight = sb.bottom.y - (sb.top.y+sb.top.height); // espace libre entre les 2 boutons top / bottom
		sb.mid.startDrag(false, new flash.geom.Rectangle(sb.mid.x,sb.top.y+sb.top.height, 0,maxHeight-sb.mid.height));
	}
	
	function onEndScroll() {
		fl_scrolling = false;
		mc.mid.stopDrag();
		updateScrollBar();
	}
	
	function updateScrollDrag() {
		var sb = mc;
		var maxHeight = sb.bottom.y - (sb.top.y+sb.top.height); // espace libre entre les 2 boutons top / bottom
		var moveRange = maxHeight - sb.mid.height;
		var ratio = 1 - (sb.mid.y-sb.top.height) / moveRange;
		if(fl_vertical)
			scroller.y = ratio*getMaxScroll();
		else
			scroller.x = ratio*getMaxScroll();
	}
	
	public function scroll(delta:Float) {
		var t =
			if (fl_vertical)
				scroller.y-delta;
			else
				scroller.x-delta;
		t = Math.min(getMaxScroll(), t);
		t = Math.max(0, t);
		if(fl_vertical)
			Game.TW.create(scroller, "y", t, TLinear, DateTools.seconds(0.15)).onUpdate = updateScrollBar;
		else
			Game.TW.create(scroller, "x", t, TLinear, DateTools.seconds(0.15)).onUpdate = updateScrollBar;
	}
	
	public function updateScrollBar() {
		var maxScroll = getMaxScroll();
		if ( maxScroll<=50 )
			mc.visible = false;
		else {
			mc.visible = true;
			
			if(fl_vertical)
				mc.bottom.y = Game.HEI-40 - mc.y - mc.bottom.height - 5;
			else
				mc.bottom.y = Game.WID-40 - mc.x - mc.bottom.height - 5;

			var ratio =
				if (fl_vertical)
					Game.HEI / ((2+hotel._floors)*Game.FLOOR_HEI);
				else
					Game.WID / ((5+hotel._width)*Game.ROOM_WID);
			var maxHeight = mc.bottom.y - (mc.top.y+mc.top.height); // espace libre entre les 2 boutons top / bottom
			mc.mid.height = ratio*maxHeight;
			
			var ratio =
				if (fl_vertical)
					1 - scroller.y / maxScroll;
				else
					1 - scroller.x / maxScroll;
			var moveRange = maxHeight - mc.mid.height;
			mc.mid.y = mc.top.y + mc.top.height + ratio*moveRange;
		}
	}
	
	public function update() {
		if ( fl_scrolling ) {
			updateScrollDrag();
			if ( Game.ME.isOut() )
				onEndScroll();
		}
	}
}
