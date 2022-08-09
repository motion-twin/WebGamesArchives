import flash.display.Sprite;
import com.gen.LevelGenerator;
import mt.deepnight.mui.*;
import mt.deepnight.Particle;

class Game extends mt.deepnight.Process { //}
	static var GRID = 25;
	public static var ME : Game;

	public var ui			: Group;
	var lid					: Int;
	var wrapper				: Sprite;
	var gen					: LevelGenerator;
	public var log			: TextInput;
	//public var infos		: TextInput;

	public function new() {
		super();
		ME = this;

		lid = 58;

		wrapper = new Sprite();
		root.addChild(wrapper);
		wrapper.x = 400;
		wrapper.y = 100;
		var h = root.stage.stageHeight;

		// Log
		log = new TextInput(root);
		log.color = 0x121218;
		log.readOnly = true;
		log.setSize(350, h);
		log.multiLine = true;
		gen = new LevelGenerator();

		// UI
		ui = new VGroup(root);
		ui.setWidth(250);
		ui.setPos(root.stage.stageWidth-ui.getWidth(), 0);
		ui.color = 0x121218;

		ui.label("Progression level", 0xFFFFFF, 20);
		var g = ui.hgroup(true);
		g.label("Level (1-100)");

		var i = g.input(Std.string(lid), function(v) makeProgression(Std.parseInt(v)) );
		i.watchValue( function() return Std.string(lid) );
		g.button("<<", function() makeProgression(lid-1) );
		g.button(">>", function() makeProgression(lid+1) );


		// Level infos
		//infos = new TextInput(ui);
		//infos.readOnly = true;
		//infos.setHeight(100);

		ui.button("Verify all levels", verifyAll);

		makeProgression(lid);
	}

	function makeProgression(l) {
		lid = l;
		var t = haxe.Timer.stamp();
		gen.generateProgressionLevel(l);
		log.addLine('Time: ${ms(haxe.Timer.stamp()-t)}');
		renderLevel();
	}

	inline function ms(s:Float) {
		return mt.MLib.round(s*10000)/10 + " ms";
	}


	function verifyAll() {
		var failed = [];
		var total = 0.;
		var manyFails = [];
		for(i in 1...LevelGenerator.MAX_LEVEL+1) {
			var t = haxe.Timer.stamp();
			var r = gen.generateProgressionLevel(i);
			if( r==null )
				failed.push(i);
			else if( r.failures>=15 )
				manyFails.push('Level $i => ${r.failures} fails (${r.report})');
			total += haxe.Timer.stamp() - t;
		}

		makeProgression(lid);

		if( failed.length==0 )
			log.setText("SUCCESS!! =)");
		else
			log.setText("FAILED: "+failed);

		log.addLine("Many fails ("+manyFails.length+"):\n"+manyFails.join("\n"));
		log.addLine("---------------------");
		log.addLine('Total: ${ms(total)}');
		log.addLine('Average: '+ms(total/LevelGenerator.MAX_LEVEL));
	}


	function renderLevel() {
		var g = GRID;

		var s = wrapper;
		s.removeChildren();
		s.graphics.clear();

		s.graphics.beginFill(0x323C5A, 1);
		s.graphics.drawRect(0,0, gen.wid*g, gen.hei*g);

		for( p in gen.platforms ) {
			// Platform
			s.graphics.beginFill(0x9CABD1, 0.5);
			s.graphics.lineStyle(1, 0xFFFFFF, 0.9, true, NONE);
			s.graphics.drawRect(p.cx*g, p.cy*g, p.wid*g,g);

			// Ladders
			for(lcx in p.ladders ) {
				var cy = p.cy-1;
				while( cy>=0 && !gen.hasPlatform(lcx, cy) ) {
					s.graphics.beginFill(0xE76516, 0.7);
					s.graphics.lineStyle(0, 0x0, 0);
					s.graphics.drawRect(lcx*g+6, cy*g, g-12,g);
					cy--;
				}
			}
		}

		// Locks
		var i = 1;
		for(t in gen.targets) {
			var col = switch( t.type ) {
				case LT_Silver : 0xDCE1E4;
				case LT_Gold : 0xFFFF00;
				case LT_Movable : 0xCD7EEF;
			}
			s.graphics.beginFill(col, 0.7);
			s.graphics.lineStyle(1, col, 1);
			s.graphics.drawRect(t.cx*g+4, t.cy*g+8, g-8,g-8);
			var tf = createField(i);
			tf.x = t.cx*g+4;
			tf.y = t.cy*g+5;
			tf.filters = [ new flash.filters.GlowFilter(0x0,0.5, 2,2,4) ];
			s.addChild(tf);
			i++;
		}

		// Exit
		s.graphics.beginFill(0x8A4D91, 0.5);
		s.graphics.lineStyle(0, 0x0, 0);
		s.graphics.drawRect( (gen.exit.cx-1)*g, (gen.exit.cy-1)*g+2, g*3, g*2-2);

		// Misc
		for(cy in 0...gen.hei) {
			// Y axis
			var tf = createField(cy);
			s.addChild(tf);
			tf.x = -20;
			tf.y = cy*g;

			for(cx in 0...gen.wid) {
				// X axis
				if( cy==0 ) {
					var tf = createField(cx);
					s.addChild(tf);
					tf.x = cx*g;
					tf.y = -g;
				}

				// Grid
				s.graphics.lineStyle(1, 0x0, 0.08, true, NONE);
				s.graphics.beginFill(0x0, 0);
				s.graphics.drawRect(cx*g, cy*g, g,g);
			}
		}

	}

	static var MARKER_DELAY = 0;
	public function clearMarkers() {
		Particle.clearAll();
		MARKER_DELAY = 0;
	}

	public function marker(cx,cy, ?col=0xFF0080) {
		var p = new Particle(wrapper.x + (cx+0.5)*GRID, wrapper.y + (cy+0.5)*GRID);
		p.drawCircle(10, col, 0.5);
		p.life = 99999;
		root.addChild(p);
		return p;
	}

	public function textMarker(cx,cy, txt:Dynamic) {
		var p = new Particle(wrapper.x + (cx+0.5)*GRID, wrapper.y + (cy+0.5)*GRID);
		var tf = createField(txt);
		tf.filters = [ new flash.filters.GlowFilter(0x0, 1, 2,2, 4) ];
		tf.x = Std.int( -tf.textWidth*0.5 );
		tf.y = Std.int( -tf.textHeight*0.5 );
		p.addChild(tf);
		p.life = 99999;
		root.addChild(p);
		return p;
	}

	public function delayedMarker(cx,cy, d, ?col) {
		var p = marker(cx,cy, col);
		p.delay = MARKER_DELAY*d;
		MARKER_DELAY++;
		return p;
	}

	function createField(str:Dynamic) {
		var tf = new flash.text.TextField();
		var f = new flash.text.TextFormat("verdana", 10, 0xFFFFFF);

		tf.defaultTextFormat = f;
		tf.text = Std.string(str);
		tf.multiline = false;
		tf.mouseEnabled = tf.mouseWheelEnabled = tf.selectable = false;
		tf.width = tf.textWidth+5;
		tf.height = tf.textHeight+4;
		return tf;
	}

	override function update() {
		super.update();
		Component.updateAll();
		Particle.update();
	}
}
