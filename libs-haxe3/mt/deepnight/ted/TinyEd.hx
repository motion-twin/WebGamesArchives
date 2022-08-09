package mt.deepnight.ted;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.mui.*;
import mt.deepnight.slb.*;
import mt.deepnight.Color;
import mt.deepnight.Lib;
import mt.deepnight.Bresenham;
import mt.MLib;
import mt.flash.Key;
import flash.ui.Keyboard;

class TinyEd<T> extends mt.deepnight.FProcess {
	static var GRID = 25;

	var scene				: Sprite;
	var mainBar				: Group;
	var buttons				: Map<String, Button>;

	var tiles				: BLib;
	var enumType			: Enum<T>;
	public var levels		: Array<TinyLevel<T>>;
	var lid					: Int;
	var level				: TinyLevel<T>;
	var wid					: Int;
	var hei					: Int;
	var curTool				: T;

	var tileBitmaps			: Map<String, BitmapData>;
	var sceneBitmaps		: Array<Bitmap>;

	var srect				: Sprite;
	var drag				: Null<{ gx:Float, gy:Float, startX:Int, startY:Int, cx:Int, cy:Int, button:Int }>;

	public function new(parent:Sprite, cellEnum:Enum<T>) {
		super(parent);
		enumType = cellEnum;
		levels = new Array();
		buttons = new Map();
		tileBitmaps = new Map();
		sceneBitmaps = [];

		initBitmaps();

		wid = Std.int(root.stage.stageWidth);
		hei = Std.int(root.stage.stageHeight);

		// Bg
		var bg = new Sprite();
		root.addChild(bg);
		bg.graphics.beginFill(0x0, 0.8);
		bg.graphics.drawRect(0,0,wid,hei);

		mainBar = new HGroup(root);
		mainBar.button("Quit", destroy);
		mainBar.separator();
		mainBar.button("Load", load);
		mainBar.button("Save", save);
		mainBar.button("<<<", function() changeLevel(-1));
		mainBar.button(">>>", function() changeLevel(1));

		//mainBar.separator();
		//mainBar.button("wid-", function() { level.changeSize(-1,0); redraw(); });
		//mainBar.button("wid+", function() { level.changeSize(1,0); redraw(); });

		mainBar.separator();

		var g = new HGroup(mainBar);
		g.removeBorders();
		for(k in Type.getEnumConstructs(enumType)) {
			var b = g.button(k, function() {
				selectTool(Type.createEnum(enumType,k));
			});
			buttons.set( k, b );
		}

		scene = new Sprite();
		root.addChild(scene);

		scene.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, onLeftDown );
		root.addEventListener( flash.events.MouseEvent.MOUSE_UP, onLeftUp );

		root.addEventListener( flash.events.MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleDown );
		root.addEventListener( flash.events.MouseEvent.MIDDLE_MOUSE_UP, onMiddleUp );

		scene.addEventListener( flash.events.MouseEvent.RIGHT_MOUSE_DOWN, onRightDown );
		root.addEventListener( flash.events.MouseEvent.RIGHT_MOUSE_UP, onRightUp );


		srect = new Sprite();
		root.addChild(srect);
		srect.filters = [
			new flash.filters.GlowFilter(0xFFCC00,1, 4,4,2),
			new flash.filters.GlowFilter(0xFF9300,0.8, 16,16,1),
		];

		levels[0] = createLevel();
		selectTool(Type.createEnumIndex(enumType, 0));
		selectLevel(0);

		scene.x = Std.int(wid*0.5 - scene.width*0.5);
		scene.y = Std.int(hei*0.5 - scene.height*0.5);
	}

	function createLevel() {
		return new TinyLevel(enumType, 20,20);
	}

	function save() {
		trimEmptyLevels();
		var all = levels.map( function(l) return l.serialize() );
		mt.deepnight.Lib.saveFile("levels.txt", all.join("\n"));
	}

	function trimEmptyLevels() {
		while( levels[levels.length-1].isEmpty() )
			levels.pop();
	}

	function load() {
		mt.deepnight.Lib.loadFile(function(b,f) {
			var all = b.toString();
			levels = [];
			for(raw in all.split("\n"))
				levels.push( TinyLevel.unserialize(enumType,raw) );
			selectLevel(0);
			redraw();
		});
	}

	function changeLevel(delta) {
		lid+=delta;
		if( lid<0 )
			lid = 0;
		if( lid>=levels.length)
			levels[lid] = createLevel();
		selectLevel(lid);
		redraw();
	}

	override function unregister() {
		super.unregister();

		for(bd in tileBitmaps)
			bd.dispose();
		tileBitmaps = null;

		mainBar.destroy();

		levels = null;
	}

	function startDrag(bt:Int) {
		srect.graphics.clear();
		var pt = getMouse();
		drag = {
			button	: bt,
			startX	: pt.cx,
			startY	: pt.cy,
			gx		: pt.gx,
			gy		: pt.gy,
			cx		: pt.cx,
			cy		: pt.cy,
		}
	}

	function endDrag() {
		if( drag==null )
			return;

		srect.graphics.clear();
		if( Key.isDown(Key.SHIFT) ) {
			var m = getMouse();
			var r = getDragRect(m.cx, m.cy);
			for(cx in r.cx...r.cx+r.wid)
				for(cy in r.cy...r.cy+r.hei) {
					switch( drag.button ) {
						case 0 :
							level.add(cx, cy, curTool);

						case 1 :
							if( Key.isDown(Key.CTRL) )
								level.removeAll(cx, cy);
							else
								level.remove(cx, cy, curTool);

						case 2 :
					}
				}
			redraw();
		}

		drag = null;
	}


	function onLeftDown(_) {
		startDrag(0);
	}
	function onLeftUp(_) {
		endDrag();
	}


	function onRightDown(_) {
		startDrag(1);
	}
	function onRightUp(_) {
		endDrag();
	}

	function onMiddleDown(_) {
		startDrag(2);
	}
	function onMiddleUp(_) {
		endDrag();
	}


	function selectTool(e:T) {
		curTool = e;
		for(b in buttons)
			b.removeState("active");
		buttons.get(Std.string(e)).addState("active");
	}

	function selectLevel(id:Int) {
		lid = id;
		level = levels[lid];
		redraw();
	}

	function redraw() {
		for(bmp in sceneBitmaps)
			bmp.bitmapData = null;
		sceneBitmaps = [];

		scene.removeChildren();

		var g = scene.graphics;
		g.clear();

		// Bg
		g.beginFill(0x0,1);
		g.drawRect(0,0, level.wid*GRID, level.hei*GRID);
		g.endFill();

		// Grid
		g.lineStyle(1, 0xFFFFFF, 0.15, true, NONE);
		for(cx in 0...level.wid+1) {
			g.moveTo(cx*GRID, 0);
			g.lineTo(cx*GRID, level.hei*GRID);
		}
		for(cy in 0...level.hei+1) {
			g.moveTo(0, cy*GRID);
			g.lineTo(level.wid*GRID, cy*GRID);
		}

		// Content
		for(cx in 0...level.wid)
			for(cy in 0...level.hei) {
				var n = 0;
				for( e in level.get(cx,cy) ) {
					var bmp = getTile(e);
					scene.addChild(bmp);
					bmp.x = cx*GRID + n*3;
					bmp.y = cy*GRID + n*1;
					bmp.width -= n*6;
					bmp.height -= n*6;
					if( n>0 )
						bmp.filters = [ new flash.filters.GlowFilter(0x0,0.4, 2,2,4, 1,true) ];
					sceneBitmaps.push(bmp);
					n++;
				}
			}
	}

	function initBitmaps() {
		var col = 0x666666;
		var s = new Sprite();
		s.graphics.beginFill(col, 1);
		s.graphics.drawRect(0,0,GRID,GRID+2);
		s.filters = [
			new flash.filters.GlowFilter(0x0,0.6, 8,8,1, 2,true),
			new flash.filters.DropShadowFilter(2,-90, Color.darken(col,0.4),1, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0x0,0.1, 2,2,4, 1,true),
		];
		var base = Lib.flatten(s).bitmapData;

		for(k in Type.getEnumConstructs(enumType)) {
			var bd = base.clone();
			var meta = Reflect.field(haxe.rtti.Meta.getFields(enumType), k);
			var col = Std.parseInt( Reflect.field(meta, "col") );
			if( meta==null || col==null )
				col = 0xFF00FF;
			bd.applyFilter(bd, bd.rect, pt0, Color.getColorizeFilter(col, 1, 0));

			// Label
			var txt = Reflect.field(meta, "txt");
			if( txt!=null ) {
				var tf = new flash.text.TextField();
				var f = new flash.text.TextFormat("Arial", 8, Color.autoContrast(col));
				tf.setTextFormat(f);
				tf.defaultTextFormat = f;
				tf.text = txt;
				tf.y = -3;
				tf.width = tf.textWidth+5;
				tf.height = tf.textHeight+5;
				tf.scaleX = tf.scaleY = GRID/tf.width;
				bd.draw(tf, tf.transform.matrix);
			}

			tileBitmaps.set(k, bd);
		}

		base.dispose();
	}

	function getTile(e:T) : Bitmap {
		return new Bitmap(tileBitmaps.get(Std.string(e)));
	}

	function getMouse() {
		var pt = screenToGrid( root.mouseX, root.mouseY );
		return {
			x	: scene.mouseX,
			y	: scene.mouseY,
			gx	: root.mouseX,
			gy	: root.mouseY,
			cx	: pt.cx,
			cy	: pt.cy,
		}
	}

	function screenToGrid(x:Float,y:Float) {
		return {
			cx	: MLib.clamp( Std.int( (x-scene.x)/GRID ), 0, level.wid-1 ),
			cy	: MLib.clamp( Std.int( (y-scene.y)/GRID ), 0, level.hei-1 ),
		}
	}

	function gridToScreen(cx:Int, cy:Int, ?center=false) {
		return {
			x	: scene.x + (cx+(center?0.5:0))*GRID,
			y	: scene.y + (cy+(center?0.5:0))*GRID,
		}
	}


	function getDragRect(ex,ey) {
		if( drag==null )
			return null;
		else {
			var cx = drag.startX;
			var cy = drag.startY;
			var w = MLib.iabs(ex-cx+1);
			var h = MLib.iabs(ey-cy+1);
			if( ex<cx ) {
				cx = ex;
				w+=2;
			}
			if( ey<cy ) {
				cy = ey;
				h+=2;
			}
			return { cx:cx, cy:cy, wid:w, hei:h }
		}
	}


	function pan(dx,dy, all:Bool) {
		level.pan(dx,dy, all ? null : curTool);
		redraw();
	}


	override function update() {
		super.update();

		Key.update();

		// UI position
		if( mainBar.x!=scene.x )
			mainBar.setPos(scene.x, scene.y-mainBar.getHeight());

		if( Key.isDown(Key.CTRL) )
			scene.filters = [
				new flash.filters.GlowFilter(0x0,1, 2,2,8),
				new flash.filters.GlowFilter(0xDD7575,1, 2,2,8)
			];
		else
			scene.filters = [];

		// Panning
		if( Key.isToggled(Key.RIGHT) ) pan(1,0, Key.isDown(Key.CTRL));
		if( Key.isToggled(Key.LEFT) ) pan(-1,0, Key.isDown(Key.CTRL));
		if( Key.isToggled(Key.UP) ) pan(0,-1, Key.isDown(Key.CTRL));
		if( Key.isToggled(Key.DOWN) ) pan(0,1, Key.isDown(Key.CTRL));

		var m = getMouse();
		if( drag!=null ) {
			if( Key.isDown(Keyboard.SHIFT) ) {
				// Rectangular selection
				srect.graphics.clear();
				var r = getDragRect(m.cx, m.cy);
				srect.graphics.lineStyle(1, 0xFFFF80,1, true, NONE);
				srect.graphics.drawRect(scene.x + r.cx*GRID, scene.y + r.cy*GRID, r.wid*GRID, r.hei*GRID);
			}
			else {
				// Normal painting
				switch( drag.button ) {
						case 0 : // Left
						for( pt in Bresenham.getThinLine(drag.cx, drag.cy, m.cx, m.cy) )
							level.add(pt.x, pt.y, curTool);
						redraw();

					case 1 : // Right
						for( pt in Bresenham.getThinLine(drag.cx, drag.cy, m.cx, m.cy) )
							if( Key.isDown(Key.CTRL) )
								level.removeAll(pt.x, pt.y);
							else
								level.remove(pt.x, pt.y, curTool);
						redraw();

					case 2 : // Middle
						scene.x += m.gx-drag.gx;
						scene.y += m.gy-drag.gy;

					default :
				}
			}
			drag.cx = m.cx;
			drag.cy = m.cy;
			drag.gx = m.gx;
			drag.gy = m.gy;
		}

		Component.updateAll();
	}
}

