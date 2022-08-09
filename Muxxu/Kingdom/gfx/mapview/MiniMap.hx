import data.MapData;

class MiniMap {

	static var t :  haxe.Timer;
	static var tmp : flash.display.Shape;
	static var map : flash.display.BitmapData;
	static var cnx : haxe.remoting.AsyncConnection;
	static var DATA : MiniMapData;

	static function onResult( m : MiniMapData ) {
		t.stop();
		DATA = m;
		map = new flash.display.BitmapData(m.width,m.height);
		map.setPixels(map.rect,m.bytes.getData());
		var root = flash.Lib.current;
		root.graphics.beginFill(0);
		root.graphics.drawRect(0,0,m.width,m.height);
		root.addChild(new flash.display.Bitmap(map));
		tmp = new flash.display.Shape();
		root.addChild(tmp);
		mt.flash.Event.click.bind(root.stage,function() {
			var px = Std.int(root.mouseX);
			var py = Std.int(root.mouseY);
			m.x = px - (m.viewX >> 1);
			m.y = py - (m.viewY >> 1);
			cnx.api._setMapPos.call([px,py],function(_) updatePosition(m));
		});
		updatePosition(m);
	}

	static function updatePosition( m : MiniMapData ) {
		var root = flash.Lib.current;
		var sw = 160;
		var sh = 100;
		var dx = m.x - ((sw-m.viewX)>>1);
		var dy = m.y - ((sh-m.viewY)>>1);
		if( dx < 0 ) dx = 0;
		if( dy < 0 ) dy = 0;
		if( dx + sw > m.width ) dx = m.width - sw;
		if( dy + sh > m.height ) dy = m.height - sh;
		root.x = -dx;
		root.y = -dy;
		tmp.graphics.clear();
		tmp.graphics.lineStyle(1,0xFFFFFF);
		tmp.graphics.drawRect(m.x, m.y, m.viewX, m.viewY );
		tmp.graphics.lineStyle();
		tmp.graphics.beginFill(0xFF4040);
		tmp.graphics.drawCircle(m.selX,m.selY,2);
		tmp.graphics.endFill();
	}

	static function _updatePos( x : Int, y : Int, set : Bool ) {
		if( DATA == null ) return;
		if( set ) {
			DATA.selX = x;
			DATA.selY = y;
		}
		DATA.x = x - (DATA.viewX >> 1);
		DATA.y = y - (DATA.viewY >> 1);
		updatePosition(DATA);
	}

	static function _refresh() {
		if( map == null ) return;
		cnx.api._getMap.call([],function(m:MiniMapData) {
			map.setPixels(map.rect,m.bytes.getData());
		});
	}

	public static function main() {
		flash.system.Security.allowDomain("*");
		var ctx = new haxe.remoting.Context();
		ctx.addObject("api",MiniMap);
		t = new haxe.Timer(100);
		t.run = function() {
			cnx = haxe.remoting.FlashJsConnection.connect("cnx","mapview",ctx);
			cnx.setErrorHandler(function(_) {});
			cnx.api._getMap.call([],onResult);
		}
	}

}