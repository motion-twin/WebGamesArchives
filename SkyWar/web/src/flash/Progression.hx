import Event;
import Player;

class Progression {
	public static var ALPHA_LINE_INACTIVE = 0.5;
	public static var FILTER_LINE_INACTIVE : flash.filters.DropShadowFilter;
	public static var FILTER_LINE_ACTIVE : flash.filters.DropShadowFilter;
	public static var colors : Array<UInt> =[
		0xDCEEFF,
		0xAF88FF,
		0xFF72F1,
		0xFF6B60,
		0xFC9504,
		0xFFEA3C,
		0x2DE346,
		0x33E8FD
	];
	public static var fgEvtColors : Array<UInt> =[
		0x61686c, 0, 0, 0, 0, 0x61686c, 0, 0x61686c
	];

	static var maxW = 0;
	static var maxH = 0;
	public static var W = 0.0;
	static var DW = 0.0;
	public static var H = 0.0;
	static var DH = 0.0;
	static var PAD_LEFT = 0.0;
	static var PAD_TOP = 27;
	static var PAD_BOT = 20;
	static var IN_PAD_TOP = 70;
	static var IN_PAD_RIGHT = 30;
	static var me : Int = 0;
	public static var players = new List<Player>();
	public static var events = new List<Event>();
	public static var eventsLines : flash.display.Sprite;

	public static function getPlayerColor( id:Int ) : { bg:UInt, fg:UInt } {
		for (p in players)
			if (p.data._id == id){
				return { fg:fgEvtColors[p.data._color], bg:colors[p.data._color] };
			}
		return { bg:0x000000, fg:0x000000 };
	}
	
	public static function getPlayerName( id:Int ){
		for (p in players)
			if (p.data._id == id)
				return p.data._name;
		return null;
	}
	
	public static function tickToX( tick:Int ){
		return Math.max(PAD_LEFT, PAD_LEFT + (tick / 6) * (DW - IN_PAD_RIGHT) / maxW);
	}

	inline static function valueToY( v:Int ) : Float {
		return Math.max(PAD_TOP, PAD_TOP + DH - (v * ((DH - IN_PAD_TOP)/maxH)));
	}
	
	static function line( p:Pl ){
		var pl = new Player(p);
		pl.y = 5;
		players.add(pl);
		var spr = new flash.display.Sprite();
		var gfx = spr.graphics;
		gfx.lineStyle(1, colors[p._color]);
		gfx.moveTo(PAD_LEFT, PAD_TOP + DH);
		var w = PAD_LEFT + DW / maxW;
		for (v in p._data){
			var y = valueToY(v);
			gfx.lineTo(w, y);
			w += (DW - IN_PAD_RIGHT) / maxW;
		}
		spr.filters = [FILTER_LINE_INACTIVE];
		spr.alpha = ALPHA_LINE_INACTIVE;
		pl.setLine(spr);

		flash.Lib.current.addChild(spr);
		flash.Lib.current.addChild(pl);
	}

	public static function fillEllipse( mc:flash.display.Sprite, color, x, y, w, h ){
		mc.graphics.beginFill(color);
		mc.graphics.drawEllipse(x, y, w, h);
		mc.graphics.endFill();
	}
	
	public static function fillRect( mc:flash.display.Sprite, color, x, y, w, h ){
		mc.graphics.beginFill(color);
		mc.graphics.drawRect(x, y, w, h);
		mc.graphics.endFill();
	}

	public static function dispatchEvents( currentPlayer:Player ){
		// return;
		eventsLines.graphics.clear();
		// for (e in events)
		//	e.visible = true;
		try {
			var list = Lambda.array(Lambda.filter(events, function(e) return e.visible));
			if (list.length == 0)
				return;
			var iter = 0;
			var groups : List<List<Event>>;
			do {
				groups = new List();
				// create collision groups
				var currentGroup = new List();
				var prev : Event = null;
				for (e in list){
					if (prev != null && prev.x + prev.width < e.x){
						groups.add(currentGroup);
						currentGroup = new List();
					}
					currentGroup.add(e);
					prev = e;
				}
				if (currentGroup.length > 0)
					groups.add(currentGroup);
				if (groups.length == list.length)
					break;		// no collision
				var n = 0;
				for (group in groups){
					++n;
					var requiredSpace = group.length * prev.width;
					var xstart = group.first().x; // - (requiredSpace / 2) + (prev.width / 2);
					if (xstart < 0)
						xstart = 0;
					if (xstart + requiredSpace > W)
						xstart = W - requiredSpace;
					var c = Std.random(255) << 16 | Std.random(255) << 8 | Std.random(255);
					fillRect(eventsLines, c, xstart, n * prev.height, requiredSpace, prev.height);
					var i = 0;
					for (e in group){
						e.x = xstart + i * prev.width;
						//				e.y = n * prev.height;
						++i;
					}
				}
			}
			while (groups.length != list.length && ++iter < 10);
			if (groups.length == 1 && groups.first().length * Event.W > W){
				var maingroup = groups.first();
				var index = 0;
				for (e in maingroup){
					e.x = (index++) * (W-Event.W) / maingroup.length;
				}
			}
			eventsLines.graphics.clear();
			eventsLines.alpha = 0.7;
			for (e in list){
				// eventsLines.graphics.lineStyle(0x777777);
				eventsLines.graphics.lineStyle(1, colors[currentPlayer.data._color]);
				var x = e.x + e.width / 2;
				var tx = tickToX(e.gameEvent.tick);
				eventsLines.graphics.moveTo(x, e.y + e.height);
				// var v = currentPlayer.getValue(Math.floor(e.gameEvent.tick / 6));
				var v = currentPlayer.getValue(e.gameEvent.tick / 6);
				var ty = valueToY(v);
				if (Math.isNaN(ty))
					continue;
				var dx = x - tx;
				var index = dx / e.width;
				var my = e.y + e.height + 3 + Math.abs(5 * index);
				if (my < ty){
					eventsLines.graphics.lineTo(e.x + e.width / 2, my);
					eventsLines.graphics.lineTo(tx, my);
				}
				eventsLines.graphics.lineTo(tx, ty);
			}
		}
		catch (ex:Dynamic){
			trace(Std.string(ex));
			trace(haxe.Stack.exceptionStack().join("\n"));
		}
	}
	
	public static function main(){
		haxe.Serializer.USE_ENUM_INDEX = true;
		FILTER_LINE_INACTIVE = new flash.filters.DropShadowFilter();
		FILTER_LINE_INACTIVE.distance = 2;
		FILTER_LINE_INACTIVE.color = 0x333333;
		FILTER_LINE_INACTIVE.blurX = 2;
		FILTER_LINE_INACTIVE.blurY = 2;
		FILTER_LINE_ACTIVE = new flash.filters.DropShadowFilter();
		FILTER_LINE_ACTIVE.distance = 2;
		FILTER_LINE_ACTIVE.color = 0x000000;
		FILTER_LINE_ACTIVE.blurX = 2;
		FILTER_LINE_ACTIVE.blurY = 2;
		
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces();
		try {
			W = 746; // flash.Lib.current.stage.stageWidth;
			H = 297; // flash.Lib.current.stage.stageHeight;

			DW = W - PAD_LEFT;
			DH = H - PAD_TOP - PAD_BOT;

			var data = flash.Lib.current.loaderInfo.parameters.dat;
			var data = Base64.decode(data);
			var data : List<Pl> = haxe.Unserializer.run(data);
			for (p in data){		
				maxW = Std.int(Math.max(maxW, p._data.length));
				for (i in p._data)
					if (i > maxH)
						maxH = i;
			}
			me = Std.parseInt(flash.Lib.current.loaderInfo.parameters.me);
			for (p in data){
				if (p._id == me){
					data.remove(p);
					data.add(p);
					break;
				}
			}

			var loader = new flash.display.Loader();
			loader.load(new flash.net.URLRequest("/gfx/topdown.gif"));
			loader.x = W - 750;
			loader.y = 0;
			flash.Lib.current.addChild(loader);

			var bg = new flash.display.Sprite();
			flash.Lib.current.addChild(bg);
			fillRect(bg, 0x4D5357, 0, 0, 40, 40);
			// fillRect(flash.Lib.current, 0x4f5356, 0, 0, W, 26);
			// fillRect(bg, 0x3d3d3f, 0, 26, W, 1);
			fillRect(bg, 0x1c1c1c, 0, 27, W, H);
			// fillRect(bg, 0x787878, PAD_LEFT, PAD_TOP, DW, DH);

			var loader = new flash.display.Loader();
			loader.load(new flash.net.URLRequest("/gfx/fond_courbes.jpg"));
			loader.x = PAD_LEFT;
			loader.y = PAD_TOP;
			flash.Lib.current.addChild(loader);
			
			var lines = new flash.display.Sprite();
			flash.Lib.current.addChild(lines);
			
			var twelveHours = maxW / 16; // every 6 ticks : one stat, every tick = 45 seconds
			for (h in 1...Math.ceil(twelveHours)){
				var x = h * (DW / twelveHours);
				fillRect(lines, 0x636363, x,  PAD_TOP, 1, DH);
				var txt = new flash.text.TextField();
				var fmt = new flash.text.TextFormat();
				fmt.font = "Arial";
				fmt.size = 10;
				txt.selectable = false;
				txt.autoSize = flash.text.TextFieldAutoSize.CENTER;
				txt.textColor = 0x636363;
				txt.text = Std.string(h * 12) + "h";
				txt.setTextFormat(fmt);
				txt.x = x - txt.width / 2;
				txt.y = PAD_TOP + DH;
				lines.addChild(txt);
			}

			eventsLines = new flash.display.Sprite();
			flash.Lib.current.addChild(eventsLines);
			
			for (p in data)
				line(p);

			var x = 5.0;
			for (p in players){
				p.x = x;
				x += p.width + 10;
			}

			var history = flash.Lib.current.loaderInfo.parameters.his;
			var history = Base64.decode(history);
			var history : List<GEvent> = try haxe.Unserializer.run(history) catch (x:Dynamic) {
				haxe.Firebug.trace(Std.string(x));
				null;
			}
			if (history != null){				
				for (ev in history){
					var e = new Event({
						tick:Reflect.field(ev,"tick"),
						date:Reflect.field(ev,"date"),
						kind:Reflect.field(ev,"kind")
					});
					e.visible = false;
					flash.Lib.current.addChild(e);
					events.push(e);
				}
			}

			for (p in players){
				if (p.data._id == me){
					p.enable();
					break;
				}
			}

			Tip.init();
		}
		catch (e:Dynamic){
			trace(Std.string(e));
			trace(haxe.Stack.exceptionStack().join("\n"));
		}
	}
}
