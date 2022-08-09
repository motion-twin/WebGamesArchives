package seq;
import mt.bumdum9.Lib;
import Protocol;
using mt.bumdum9.MBut;

class Editor extends mt.fx.Sequence {//}

	var cursor : SP;
	var root:SP;
	var debug:SP;
	
	var square:Square;
	var so:flash.net.SharedObject;
	
	
	var data:DataProgression;
	var field:TF;
	
	var rectangleStart:Null<Int>;
	var rectangleCursor:SP;
	
	public function new() {
		super();
		Game.me.stepFx = this;
		
		root = new SP();
		Game.me.dm.add(root, Game.DP_INTER);

		// R-CURSOR
		rectangleCursor = new SP();
		rectangleCursor.graphics.lineStyle(1, 0xFF8800);
		rectangleCursor.graphics.drawRect(0, 0, Cs.SQ,Cs.SQ);
		root.addChild(rectangleCursor);
		rectangleCursor.visible = false;
		
		// CURSOR
		cursor = new SP();
		cursor.graphics.lineStyle(1, 0x88FF00);
		cursor.graphics.drawRect(0, 0, Cs.SQ,Cs.SQ);
		root.addChild(cursor);

		
		// FIELD
		field = Cs.getField(0xFFFFFF);
		Filt.glow(field, 2, 8, 0);
		root.addChild(field);
		field.y = Cs.HEIGHT - 12;

		//
		so = flash.net.SharedObject.getLocal("pacman");
		if( so.data.data == null ) resetData();
		loadData();
		loadLevel();
		
		// SAVE BUT
		var mc = new SP();
		mc.graphics.beginFill(0xFF0000);
		mc.graphics.drawRect(0, 0, 60, 12 );
		//mc.onClick(saveString);
		mc.makeBut(saveString);
		root.addChild(mc);
		mc.x = Cs.WIDTH - 64;
		mc.y = Cs.HEIGHT - 16;
		
	}
	
	function clean() {
		for( sq in Game.me.squares ) {
			sq.removeCoin(false);
			if( sq.door != null ) sq.door.kill();
		}
		
		for( e in Game.me.ents.copy() )
			if( e != Game.me.hero )
				e.kill();
	}
	
	override function update() {
		super.update();
		
		var x = Std.int((Game.me.mouseX - Cs.CX) / Cs.SQ);
		var y = Std.int((Game.me.mouseY - Cs.CY) / Cs.SQ);
		
		square = Game.me.getSquare(x, y);
		var pos = Square.getPos(x, y);
		cursor.x = pos.x;
		cursor.y = pos.y;
		
		if( api.AKApi.isToggled( 68 ) ) toggleWall(0);
		if( api.AKApi.isToggled( 83 ) ) toggleWall(1);
		if( api.AKApi.isToggled( 81 ) ) toggleWall(2);
		if( api.AKApi.isToggled( 90 ) ) toggleWall(3);
		
		if( api.AKApi.isToggled( flash.ui.Keyboard.SPACE ) ) 		toggleBlock();
		if( api.AKApi.isToggled( flash.ui.Keyboard.DELETE ) ) 		delete();
		if( api.AKApi.isToggled( flash.ui.Keyboard.ESCAPE ) ) 		leave();
		if( api.AKApi.isToggled( flash.ui.Keyboard.BACKSPACE ) ) 	reset();
		
		if( api.AKApi.isToggled( flash.ui.Keyboard.RIGHT ) ) 	scroll(0);
		if( api.AKApi.isToggled( flash.ui.Keyboard.DOWN ) ) 	scroll(1);
		if( api.AKApi.isToggled( flash.ui.Keyboard.LEFT ) ) 	scroll(2);
		if( api.AKApi.isToggled( flash.ui.Keyboard.UP ) ) 		scroll(3);
		//if( api.AKApi.isToggled( flash.ui.Keyboard.ENTER ) )

		//if( api.AKApi.isToggled( 83 ) ) trace("S");
		//if( api.AKApi.isToggled( 84 ) ) trace("T");
		//if( api.AKApi.isToggled( 85 ) ) trace("U");
		
		if( api.AKApi.isToggled( 72 ) ) toggleHero();			// (H)ero
		if( api.AKApi.isToggled( 82 ) ) doRectangle();			// (R)ectangle
		if( api.AKApi.isToggled( 84 ) ) toggleTurner();			// (T)urner
		
		
		if( api.AKApi.isToggled( 49 ) ) toggleMonster(0);		// 1
		if( api.AKApi.isToggled( 50 ) ) toggleMonster(1);		// 2
		if( api.AKApi.isToggled( 51 ) ) toggleMonster(2);		// 3
		if( api.AKApi.isToggled( 52 ) ) toggleMonster(3);		// 4
		if( api.AKApi.isToggled( 53 ) ) toggleMonster(4);		// 5
	}
	
	// STRUCTURE
	function toggleWall(di) {
		var n = square.getWall(di);
		if( n == 2 ) return;
		setWall(square, di, 1 - n);
		saveLevel();
	}

	function toggleBlock() {
		
		if( !square.isBlock() ) {
			for( di in 0...4 ) setWall(square, di, 1);
		}else {
			for( di in 0...4 ) {
				var nsq = square.dnei[di];
				if( nsq == null || nsq.isBlock() ) continue;
				setWall(square, di, 0);
			}
		}
		
		saveLevel();
	}

	function toggleTurner() {

		trace("::");
		var a = [];
		var sq = square;
		for( di in 0...4 ) {
			a.push(sq);
			sq = sq.dnei[di];
		}
		
		var door = null;
		for( sq in a ) if( sq.door != null ) door = sq.door;
		
		
		if( door == null ) {
			door = new Door(square);
			for( sq in a ) sq.majGfx();
		}else {
			door.kill();
		}
		saveLevel();
	}

	function setWall(sq:Square, di, n) {
		sq.setWall(di, n);
		sq.dnei[di].majGfx();
		sq.majGfx();
	}

	function doRectangle() {
		if( rectangleStart == null ) {
			rectangleStart = square.getId();
			var pos = Square.getPos(square.x, square.y);
			rectangleCursor.x = pos.x;
			rectangleCursor.y = pos.y;
		} else {
			var a = Game.me.squares[rectangleStart];
			var fill = !a.isBlock();
			
			var sx = Std.int(Math.min(a.x, square.x));
			var sy = Std.int(Math.min(a.y, square.y));
			var xmax = Math.abs(a.x - square.x);
			var ymax = Math.abs(a.y - square.y);
			for( x in sx...sx+Std.int(xmax)+1 ) {
				for( y in sy...sy+Std.int(ymax)+1 ) {
					var sq = Game.me.getSquare(x, y);
					if( fill ) {
						for( di in 0...4 ) setWall(sq, di, 1);
					}else{
						var dirs = [0, 1, 2, 3];
						if( x == sx+xmax ) dirs.remove(0);
						if( y == sy+ymax ) dirs.remove(1);
						if( x == sx ) dirs.remove(2);
						if( y == sy ) dirs.remove(3);
						for( di in dirs ) setWall(sq, di, 0);
					}
				}
			}
			majAll();
			rectangleStart = null;
		}
		rectangleCursor.visible = rectangleStart != null;
	}
	
	
	// ENTS
	function toggleHero() {
		trace("::-");
		if( !isFree() ) {
			delete();
			return;
		}
		Game.me.hero.setSquare(square.x, square.y);
		saveLevel();
	}

	function toggleMonster(id) {
		
		if( !isFree() ) {
			delete();
			return;
		}
		
		var b = Game.me.spawnBad(id);
		b.setSquare(square.x, square.y);
		
		 saveLevel();
	}

	function delete() {
		for( e in Game.me.ents.copy() ) if( e.square == square && e!=Game.me.hero) e.kill();
		saveLevel();
	}

	function isFree() {
		if( square.isBlock() ) return false;
		for( e in Game.me.ents ) if( e.square == square ) return false;
		return true;
	}


	// SCROLL
	function scroll(di) {
		//moveAll(di);
		if( api.AKApi.isDown( flash.ui.Keyboard.SHIFT ) ) {
			moveAll(di);
			return;
		}
		
	
		var lim = 20;
		data._cursor = data._cursor + [1, 1, -1, -1][di];
		if( data._cursor < 0 ) 		data._cursor += lim;
		if( data._cursor >= lim ) 	data._cursor -= lim;
		
		loadLevel();
	}
	
	function moveAll(di) {
		var dat = data._list[data._cursor];
		var all = dat._squares;
		var max = Cs.XMAX * Cs.YMAX;
		
		var moveEnts = function(inc) {
			for( id in 0...dat._bads.length>>1 ) {
				var sid = dat._bads[id * 2 + 1];
				sid = Std.int(Num.sMod(sid+inc,max));
				dat._bads[id * 2 + 1] = sid;
			}
			dat._start = Std.int(Num.sMod(dat._start+inc,max));
			
		}
		var prev = function() {
			all.unshift(all.pop());
			moveEnts(1);
		}
		var next = function() {
			all.push(all.shift());
			moveEnts(-1);
		}
		
		switch(di) {
			case 0 :			for( i in 0...Cs.YMAX ) prev();
			case 1 :			prev();
			case 2 :			for( i in 0...Cs.YMAX ) next();
			case 3 :			next();
		}
		

		loadLevel();
	}

	//
	function majAll() {
		for( sq in Game.me.squares ) sq.majGfx();
	}
	
	// DATA
	function resetData() {
		data = { _list:[], _cursor:0 };
		saveData();
	}

	function loadData() {
		data = haxe.Unserializer.run(so.data.data);
		//data = haxe.Unserializer.run(Cs.levels);
	}

	function saveData() {
		so.data.data = haxe.Serializer.run(data);
		majTitle();
	}
	
	function reset() {
		data = haxe.Unserializer.run(Cs.levels);
		loadLevel();
	}
	
	// LEVEL
	function resetLevel() {
		var dat:DataLevel = { _squares:[], _bads:[], _doors:[], _start:(Cs.XMAX*Cs.YMAX)>>1 };
		for( i in 0...Cs.XMAX * Cs.YMAX ) dat._squares.push(0);
		
		data._list[data._cursor] = dat;
		//saveData();
		trace("reset");
	}

	function loadLevel() {
		if( data._list[data._cursor] == null ) resetLevel();
		
		var o = data._list[data._cursor];
		
		// CLEAN
		clean();
		
		// SQUARES
		var id = 0;
		for( n in o._squares ) {
			var sq = Game.me.squares[id];
			for( di in 0...4 ) {
				var base = Std.int(Math.pow(2, di));
				if( sq.dnei[di] == null ) continue;
				sq.setWall(di, (n % (base*2) >= base )?0:1);
			}
			id ++ ;
		}
		majAll();
		
		// DOORS
		if( o._doors != null ){
			for( id in o._doors ) new Door(Game.me.squares[id]);
		}else {
			o._doors = [];
		}
		
		
		// BADS
		for( i in 0...(o._bads.length >> 1)) {
			var b = Game.me.spawnBad(o._bads[i*2]);
			b.gotoSquareId(o._bads[i*2 + 1]);
		}
		
		// HERO
		Game.me.hero.gotoSquareId(o._start);
		
		// FIELD
		majTitle();
	}

	function saveLevel() {
		var o = data._list[data._cursor];
		
		// SQUARES
		var id = 0;
		o._doors = [];
		for( sq in Game.me.squares ) {
			o._squares[id] = sq.getWallId();
			if( sq.door != null && sq.doorDir == 0 ) o._doors.push(sq.getId());
			id++;
		}
		
		// BADS
		o._bads = [];
		for( b in Game.me.bads ) {
			o._bads.push(b.bid);
			o._bads.push(b.square.getId());
		}
		
		// HERO
		o._start = Game.me.hero.square.getId();
		
		
		saveData();
	}
	
	public function saveString() {
		flash.system.System.setClipboard(so.data.data);
	}
	
	//
	public function majTitle() {
		//trace(Cs.levels.length+";;"+so.data.data.length);
		field.text = "niveau " + (data._cursor+1)+" "+((Cs.levels==so.data.data)?"":"*");
	}
	
	//
	public function leave() {
		
		kill();
		root.parent.removeChild(root);
		Game.me.stepFx = null;
		Game.me.fillCoins();
		
		for( b in Game.me.bads ) b.seekDir();	
	}

	
	/*
	function traceWallId() {
		if( debug != null ) root.removeChild(debug);
		
		debug = new SP();
		root.addChild(debug);
		
		for( sq in Game.me.squares ) {
			var f = Cs.getField(0);
			f.text = sq.getWallId() + "";
			debug.addChild(f);
			var pos = sq.getCenter();
			f.x = pos.x;
			f.y = pos.y;
		}
	}
	*/
	
//{
}












