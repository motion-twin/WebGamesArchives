import Protocol;

class Main {

	static inline var Z = 5;
	
	var mc : flash.display.MovieClip;
	var cursor : flash.display.MovieClip;
	var cx : Float;
	var cy : Float;
	var tx : Float;
	var ty : Float;
	
	var cur : QuickMap;
	
	var curpos : flash.text.TextField;
	
	public function new(tmc) {
		this.mc = tmc;
		cur = Codec.getData("data");
		tx = cx = cur.px;
		ty = cy = cur.py;
		
		if( !cur.cur ) {
			mc.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			mc.buttonMode = mc.useHandCursor = true;
			mc.stage.addEventListener(flash.events.MouseEvent.CLICK, function(_) toggleFS());
		}

		cursor = new flash.display.MovieClip();
		mc.addChild(cursor);
		cursor.graphics.beginFill(0xfce59f);
		cursor.graphics.drawRect(0, 0, Z, Z);
				
		var ctx = new haxe.remoting.Context();
		ctx.addObject("api", this);
		haxe.remoting.FlashJsConnection.connect("cnx", null, ctx);
		
		curpos = new flash.text.TextField();
		var fmt = curpos.defaultTextFormat;
		fmt.bold = true;
		curpos.defaultTextFormat = fmt;
		curpos.textColor = 0xFFFFFF;
		curpos.selectable = false;
		curpos.visible = false;
		mc.parent.addChild(curpos);
		
		mc.addEventListener(flash.events.Event.ENTER_FRAME, function(_) update());
		mc.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, function(_) updatePos());
		
		redraw();
		update();
	}
	
	function redraw() {
		var g = mc.graphics;
		g.clear();
		g.beginFill(0x473d2f);
		g.drawRect(-256*Z, -256*Z, 512*Z, 512*Z);
		
		var s0 = cur.seas[0];
		if( s0 == null ) return;
		var xMin = s0.x, yMin = s0.y, xMax = s0.x + s0.w, yMax = s0.y + s0.h;
		for( s in cur.seas ) {
			g.beginFill(0x8f7d4f, 0.3);
			g.drawRect(s.x * Z, s.y * Z, s.w * Z - 1, s.h * Z - 1);
			if( s.x < xMin ) xMin = s.x;
			if( s.y < yMin ) yMin = s.y;
			if( s.x + s.w > xMax ) xMax = s.x + s.w;
			if( s.y + s.h > yMax ) yMax = s.y + s.h;
			g.beginFill(0x8f7d4f, 1);
			for( i in s.islands )
				g.drawRect((i.x + s.x) * Z, (i.y + s.y) * Z, i.w * Z, i.h * Z);
		}
		if( cur.cur ) {
			g.beginFill(0x8f7d4f, 0.5);
			g.drawRect(cur.px * Z, cur.py * Z, Z, Z);
		}
		var kind = -2;
		for( p in cur.pts ) {
			if( p.k != kind ) {
				kind = p.k;
				var color = [0xe3d1aa, 0xFFFFFF, 0x40C040][kind + 1];
				g.beginFill(color, 0.5);
				g.lineStyle(1, color);
			}
			g.drawCircle(p.x * 0.5 * Z, p.y * 0.5 * Z, Z * 0.5);

		}
		
		var grid = 70;
		g.lineStyle(1, 0, 0.1);
		for( x in -grid...grid ) {
			g.moveTo(x * Z * 3, -grid * Z * 3);
			g.lineTo(x * Z * 3, grid * Z * 3);
		}
		for( y in -grid...grid ) {
			g.moveTo(-grid * Z * 3, y * Z * 3);
			g.lineTo(grid * Z * 3, y * Z * 3);
		}
		
		g.lineStyle();
	}
	
	function _rm( px : Int, py : Int, k : Null<Int> ) {
		for( p in cur.pts )
			if( p.x == px && p.y == py ) {
				if( k == null )
					cur.pts.remove(p);
				else
					p.k = k;
				redraw();
				break;
			}
	}
	
	function _add( a ) {
		cur.pts = cur.pts.concat(a);
		redraw();
	}
	
	function _set( m : QuickMap ) {
		if( m.seas != null ) {
			var needRedraw = false;
			for( s in m.seas ) {
				var found = false;
				for( s2 in cur.seas )
					if( s.x == s2.x && s.y == s2.y ) {
						found = true;
						if( s.islands != null )
							for( i in s.islands )
								if( !Lambda.exists(s2.islands, function(i2) return i2.x == i.x && i2.y == i.y) ) {
									s2.islands.push(i);
									needRedraw = true;
								}
						break;
					}
				if( !found ) {
					if( s.islands == null ) s.islands = [];
					cur.seas.push(s);
					needRedraw = true;
				}
			}
			if( needRedraw )
				redraw();
		}
		tx = m.px;
		ty = m.py;
	}
	
	public function update() {
		cx = cx * 0.9 + tx * 0.1;
		cy = cy * 0.9 + ty * 0.1;
		if( Math.abs(cx - tx) < 0.001 ) cx = tx;
		if( Math.abs(cy - ty) < 0.001 ) cy = ty;
		mc.x = -cx * Z + mc.stage.stageWidth*0.5;
		mc.y = -cy * Z + mc.stage.stageHeight * 0.5;
		cursor.x = tx * Z;
		cursor.y = ty * Z;
	}
	
	function updatePos() {
		var px = Math.floor(mc.mouseX / (Z * 3));
		var py = Math.floor(mc.mouseY / (Z * 3));
		curpos.text = px + "°" + py + "'";
	}
	
	function toggleFS() {
		var fs = mc.stage.displayState != flash.display.StageDisplayState.FULL_SCREEN;
		mc.stage.displayState = fs ? flash.display.StageDisplayState.FULL_SCREEN : flash.display.StageDisplayState.NORMAL;
		redraw();
		update();
		updatePos();
		curpos.visible = fs;
	}
	
	function setTarget(x, y) {
		tx = x;
		ty = y;
	}
	
	public static function main() {
		var spr = new flash.display.MovieClip();
		flash.Lib.current.addChild(spr);
		var m = new Main(spr);
		flash.external.ExternalInterface.addCallback("setTarget", m.setTarget);
	}
	
}