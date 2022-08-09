package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.filters.GlowFilter;
import flash.filters.GradientGlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import mt.kiroukou.motion.Tween;

import mt.deepnight.Color;
import mt.DepthManager;
import mt.MLib;

import flash.text.TextFieldAutoSize;
import mt.deepnight.Particle;
import mt.Compat;
import Game;

using mt.Std;
using mt.flash.Lib;


@:build( mt.kiroukou.macros.IntInliner.create([DP_GRID, DP_FLOORFX, DP_PATH, DP_FLOWERS, DP_KDO, DP_SCORE, DP_TREES, DP_PARTICLES, DP_TEXT, DP_UI]) )
class View extends Sprite
{
	var gfxPathMap:Hash<Null<String>>;
	var gfxCrossMap:Hash<MovieClip>;
	var gfxTriggerMap:Hash<DisplayObject>;
	var gfxKdoMap:Hash<DisplayObject>;
	var gfxBonusMap:Hash<Bitmap>;
	var gfxScoreMap:Hash<ScoreField>;
	var gfxParticlesMap:IntHash<DisplayObjectContainer>;
	
	var gfxLifesMap:Array<MovieClip>;
	
	var pathBitmap:Bitmap;
	
	var depthManager : DepthManager;
	var data:Array<Array<NodeData>>;
	var tmpPathGfx:gfx.Roots2;
	var tmpParticleGfx:gfx.Particleleaf;
	
	inline static var GFX_TILE_SIZE:Int = 50;
	
	public var GRID_HMAX(get_gridHMax, null):Int; 
	inline function get_gridHMax() { return Game.GRID_HMAX; }
	public var GRID_WMAX(get_gridWMax, null):Int; 
	inline function get_gridWMax() { return Game.GRID_WMAX; }
	public var TILE_SIZE(get_tileSize, null):Int;
	inline function get_tileSize() { return Game.TILE_SIZE; }
	
	var gfxChrono : TextField;
	public function new(gridData) 
	{
		super();
		
		gfxPathMap = new Hash();
		gfxCrossMap = new Hash();
		gfxParticlesMap = new IntHash();
		gfxTriggerMap = new Hash();
		gfxScoreMap = new Hash();
		gfxKdoMap = new Hash();
		gfxBonusMap = new Hash();
		
		gfxLifesMap = [];
		
		var gfxRoot = new Sprite();
		addChild(gfxRoot);
		depthManager = new DepthManager(gfxRoot);
		data = gridData;
		
		tmpParticleGfx = new gfx.Particleleaf();
		tmpParticleGfx.scale( TILE_SIZE / GFX_TILE_SIZE );
		
		tmpPathGfx = new gfx.Roots2();
		tmpPathGfx.scale( TILE_SIZE / GFX_TILE_SIZE );
		tmpPathGfx.gotoAndStop(1);
		
		initPathGFX();
		
		switch (api.AKApi.getGameMode() )
		{
			case GM_PROGRESSION:
				var sx:Float = Cs.VIEW_WIDTH - 153;
				var sy:Float = Cs.VIEW_HEIGHT - 430;
				var gfxH = 0.;
				var lives = Game.me.lives.get() - Game.me.gamelevel.get();
				for ( i in 0...Cs.MAX_LIVES.get()+1 )
				{
					var gfx = new gfx.Bonus();
					if ( i > lives ) gfx.gotoAndStop(3);
					else gfx.gotoAndStop(2);
					gfx.x = sx;
					gfx.y = sy;
					depthManager.add(gfx, DP_UI);
					gfxLifesMap.push(gfx);
					
					if ( gfxH == 0 ) gfxH = gfx.height;
					sy += gfxH;
				}
			case GM_LEAGUE:
				var tmp = new gfx.Chrono().flatten(0, true, true, StageQuality.BEST);
				depthManager.add(tmp, DP_UI);
				tmp.x = Cs.VIEW_WIDTH - 193;
				tmp.y = Cs.VIEW_HEIGHT - 110;
				gfxChrono = createScoreTF("", tmp.x + 20, tmp.y - 15, 20, 0xFFFFCC );
				depthManager.add(gfxChrono, DP_UI);
		}
	}
	
	public function dispose()
	{
		Particle.clearAll();
		depthManager.destroy();
		removeAllChildren();
		this.gfxScoreMap = null;
		this.gfxCrossMap = null;
		this.gfxParticlesMap = null;
		this.gfxPathMap = null;
		this.gfxTriggerMap = null;
		this.gfxLifesMap = null;
	}
	
	public function bonusUnlocked( bonus: { x:Int, y:Int, k:BonusKind } )
	{
		var rx = (bonus.x) * TILE_SIZE;
		var ry = (bonus.y) * TILE_SIZE;
		var color = 0xFFFFFF;
		
		var mc = gfxBonusMap.get(x + "_" + y);
		Fx.whiteBlink(mc, 20);
		
		switch( bonus.k ) 
		{
			case BonusKind.TIME:
				for ( i in 0...5 )
				{
					var gfx = new gfx.Firefly().flatten(0, true, true, StageQuality.BEST);
					gfx.scale(2);
					gfx.blendMode = BlendMode.ADD;
					
					var from = new Point(rx * 1.0, ry * 1.0 );
					var to = new Point(gfxChrono.x + gfxChrono.width/2, gfxChrono.y+gfxChrono.height/2);
					
					var t0 = new Point(MLib.frandRange(0, Cs.VIEW_WIDTH), MLib.frandRange(to.y, from.y));
					var t1 = new Point(MLib.frandRange(0, Cs.VIEW_WIDTH), MLib.frandRange(to.y, from.y));
					
					var fx = new mt.kiroukou.fx.BezierMove(gfx, {p:from, t:t0}, {p:to, t:t1} );
					Tween.tween(this, MLib.randRange(25, 80)).onUpdate( function(t, k) fx.update(t.getInterpolation()) ).start().onComplete( function(t) { Fx.gradientRadiate(gfxChrono, 8, 0xFFFFFF, 40, 20); } );
					
					depthManager.add(gfx, DP_PARTICLES);
				}
			case BonusKind.LEVEL:
				var lives = Game.me.lives.get() - Game.me.gamelevel.get();
				var currentLife = this.gfxLifesMap[lives];
				currentLife.gotoAndStop(2);
				Fx.whiteBlink(currentLife, 40);
		}
		
		/*
		var w = TILE_SIZE;
		var h = TILE_SIZE / 0.75;
		
		for ( i in 0...4 )
		{
			var p = new Particle(rx + TILE_SIZE/2, ry + TILE_SIZE/2);
			p.delay = i * 4;
			p.life = 20;
			p.ds = -1 / p.life;
			p.da = -1 / p.life;
			p.dx = p.dy = 0;
			p.gx = p.gy = 0.0;
			p.frictX = p.frictY = 1.0;
			p.fl_wind = false;
			p.dr = MLib.frandRange(2, 30);
			
			p.graphics.lineStyle(4.0, color, 1.0);
			p.graphics.drawCircle(0, 0, TILE_SIZE);
			p.scaleY = 0.75;
			p.filters = [new GlowFilter(color, 1, 10, 10)];
			p.flatten(20);
			
			depthManager.add( p, DP_PARTICLES );
		}
		*/
	}
	
	public function scoreExplosion()
	{
		for ( k in gfxScoreMap.keys() )
		{
			var tf = gfxScoreMap.get(k);
			if (tf == null || tf.unlocked == false ) continue;
			
			var s = k.split('_');
			var x = Std.parseInt(s[0]);
			var y = Std.parseInt(s[1]);
			var rx = x * TILE_SIZE;
			var ry = y * TILE_SIZE;
			
			Game.me.delayer.addFrame( function() {
				var explosion = new gfx.OptiPow();
				explosion.scale( TILE_SIZE / GFX_TILE_SIZE );
				explosion.x = rx + TILE_SIZE / 2;
				explosion.y = ry + TILE_SIZE / 2;
				Game.me.delayer.addFrame( function() explosion.detach(), 19 );
				depthManager.add( explosion, DP_PARTICLES );
			}, Std.random(20) );
			
			tf.detach();
			
			for ( i in 0...3 )
			{
				var gfx = new gfx.Firefly().flatten(0, true, true, StageQuality.BEST);
				
				var from = new Point(rx * 1.0, ry * 1.0 );
				var to = globalToLocal(new Point(430.0, -40.0));
				
				var t0 = new Point(MLib.frandRange(0, Cs.VIEW_WIDTH), MLib.frandRange(to.y, from.y));
				var t1 = new Point(MLib.frandRange(0, Cs.VIEW_WIDTH), MLib.frandRange(to.y, from.y));
				
				var fx = new mt.kiroukou.fx.BezierMove(gfx, {p:from, t:t0}, {p:to, t:t1} );
				Tween.tween(this, MLib.randRange(25, 80)).onUpdate( function(t, k) fx.update(t.getInterpolation()) ).start();
				
				depthManager.add(gfx, DP_PARTICLES);
			}
		}
	}
	
	public function drawBonus( bonus:{x:Int, y:Int, k:BonusKind} )
	{
		var gfx = new gfx.Bonus();
		var frame = switch(bonus.k)
		{
			case LEVEL: 2;
			case TIME: 1;
		}
		gfx.gotoAndStop(frame);
		gfx.scale(TILE_SIZE / GFX_TILE_SIZE);
		gfx.x = bonus.x * TILE_SIZE + TILE_SIZE / 2;
		gfx.y = bonus.y * TILE_SIZE + TILE_SIZE / 2;
		
		var bmp = gfx.flatten(0, true, true, StageQuality.BEST );
		gfxBonusMap.set(x + "_" + y, bmp);
		
		depthManager.add( bmp, DP_TREES );
		depthManager.ysort(DP_TREES);
	}
	
	public function initPathGFX()
	{
		for ( j in 0...GRID_HMAX )
		{
			for ( i in 0...GRID_WMAX )
			{
				var node = getAt(i, j);
				if ( node != null )
				{
					if ( node.points != null )
					{
						var tf = new ScoreField();
						tf.setScore( node.points );
						tf.setAt(i, j);
						tf.blendMode = BlendMode.OVERLAY;
						tf.filters = [new flash.filters.DropShadowFilter(1, 90, 0xEEC061, 1, 0, 0)];
						depthManager.add(tf, DP_SCORE);
						setScoreGfxAt(i, j, tf);
						setPathGfxAt(i, j, null);
					}
				}
			}
		}
		var bd = new BitmapData( TILE_SIZE * GRID_WMAX, TILE_SIZE * GRID_HMAX, true, 0 );
		pathBitmap = new Bitmap(bd);
		depthManager.add(pathBitmap, DP_PATH);
	}
	
	public function fadeIn( cb:Void->Void )
	{
		var ox = this.x;
		this.x = 1000;
		Game.me.tweenie.create(this, "x", ox, 1000).onEnd = cb;
	}
	
	public function fadeOut( cb:Void->Void ) 
	{
		var cpy = getChildAt(0).flatten(0, true, true, StageQuality.BEST);
		removeAllChildren();
		addChild(cpy);
		Game.me.tweenie.create(this, "x", -1000, 1000).onEnd = cb;
	}
	
	inline public function resetMouseGridPos() 
	{ 
		if ( tmpGridPos == null ) tmpGridPos = { x:-1, y:-1 };
		else tmpGridPos.x = tmpGridPos.y = -1; 
	}
	
	var tmpGridPos:{x:Int, y:Int};
	public var mouseGridPos(get, null):{x:Int, y:Int};
	function get_mouseGridPos():{x:Int, y:Int}
	{
		
		var tx = mouseX / TILE_SIZE;
		var ty = mouseY / TILE_SIZE;
		
		if ( tmpGridPos == null ) tmpGridPos = { x:Std.int(tx), y:Std.int(ty) };
		
		var sensivity = 0.25;
		var dx = tx - Std.int(tmpGridPos.x);
		var dy = ty - Std.int(tmpGridPos.y);
		tmpGridPos.x = 	if ( dx >= (1 + sensivity) )
							Std.int(tx);
						else if ( dx <= sensivity )
							Std.int(tx);
						else 
							tmpGridPos.x;
		
		tmpGridPos.y = 	if ( dy >= (1 + sensivity) )
							Std.int(ty);
						else if ( dy <= sensivity )
							Std.int(ty);
						else 
							tmpGridPos.y;
							
		
		return tmpGridPos;
	}
	
	function getPathGfxAt(x:Int, y:Int)
	{
		return gfxPathMap.get(x + "_" + y);
	}

	function setPathGfxAt(x:Int, y:Int, o)
	{
		gfxPathMap.set(x + "_" + y, o);
	}
	
	function getScoreGfxAt(x:Int, y:Int)
	{
		return gfxScoreMap.get(x + "_" + y);
	}

	public function setScoreGfxAt(x:Int, y:Int, o)
	{
		var tf = getScoreGfxAt(x, y);
		if ( tf != null ) tf.detach();
		gfxScoreMap.set(x + "_" + y, o);
	}
	
	function getCrossGfxAt(x:Int, y:Int)
	{
		return gfxCrossMap.get(x + "_" + y);
	}

	function setCrossGfxAt(x:Int, y:Int, o)
	{
		gfxCrossMap.set(x + "_" + y, o);
	}
	
	function createScoreTF( text:String, x:Float, y:Float, size:Int, color:Int = 0xFFFFFF )
	{
		var font = new gfx.font.CooperStd();
		var format = new TextFormat (font.fontName, size, color);
		var textField = new TextField ();
		textField.defaultTextFormat = format;
		textField.embedFonts = true;
		textField.selectable = false;
		textField.autoSize = TextFieldAutoSize.CENTER;
		textField.text = text;
		textField.x = Std.int(x + TILE_SIZE/2 - textField.width / 2);
		textField.y = Std.int(y + TILE_SIZE / 2 - textField.height / 2);
		
		return textField;
	}
	
	public function drawTrigger(t:Trigger)
	{
		var b = new gfx.Trees();
		b.gotoAndStop( 1+t.type );
		b.scale( TILE_SIZE / GFX_TILE_SIZE );		
		b.x = t.x * TILE_SIZE + TILE_SIZE/2;
		b.y = t.y * TILE_SIZE + TILE_SIZE / 2 + 10;
		
		var bmp = b.flatten(0, true, true, StageQuality.BEST );
		gfxTriggerMap.set( t.name, bmp);
		depthManager.add(bmp, DP_TREES);
		
		depthManager.ysort(DP_TREES);
	}
	
	public function onPathCompleted(path:Path)
	{
		var type = path.trigger.type;
		//premier feedback pour bien montrer que la liaison est terminée => flash blanc
		var mcA = gfxTriggerMap.get(path.triggerA.name);
		var mcB = gfxTriggerMap.get(path.triggerB.name);
		var color = 0xFFFFFF;
		
		Tween.tween(this, 20).fx( TLoop ).onUpdate( function(t, k) {
			var ke = t.getInterpolation();
			var ct = Color.getColorizeCT(color, ke);
			mcA.transform.colorTransform = ct; 
			mcB.transform.colorTransform = ct; 
		}).start();
		
		var mc = if ( path.trigger == path.triggerA ) mcB else mcA ;
		var ox = mc.x;
		var offset = 2;
		mc.x -= offset;
		var side = -1.0;
		Tween.tween( this, 15 ).onUpdate(function(_,_) mc.x += offset * (side *= -1)).onComplete( function(t) mc.x = ox ).start();

		// effet additionel qui fait pop des feuilles
		for ( i in 0...15 )
		{
			var gfx = new gfx.Particleleaf();
			gfx.scale( MLib.frandRange(0.1, 1.0) * TILE_SIZE / GFX_TILE_SIZE );
			gfx.gotoAndStop( 1 + type );
			gfx.rotation = MLib.randRange(0, 180);
			
			var p = new Particle((path.currentX + .5) * TILE_SIZE, (path.currentY) * TILE_SIZE);
			p.life = 100000;
			p.delay = MLib.randRange(0,15);
			p.dx = MLib.frandRangeSym(1.2);
			p.dy = MLib.frandRange(0, -0.2);
			p.gy = MLib.frandRange(0.01, 0.1);
			p.fl_wind = false;
			
			p.groundY = (path.currentY+1) * TILE_SIZE;
			p.bounce = 0.0;
			p.onBounce = function() {
				p.life = 15;
				p.dx = p.dy = p.dr = p.gx = p.gy = 0.0;
				gfx.stopAllAnimation();
			}
			
			p.addChild( gfx );
			depthManager.add(p, DP_PARTICLES);
		}
	}
	
	inline function getAt(x:Int, y:Int)
	{
		var v = if ( x < 0 || x >= GRID_WMAX || y < 0 || y >= GRID_HMAX ) null;
				else data[y][x];
		return v;
	}
	
	public function drawGrid()
	{
		var tmp = new Sprite();
		for ( i in 0...GRID_HMAX+1 )
		{
			for ( j in -1...GRID_WMAX+1 )
			{
				if ( getAt(j, i) != null )
				{
					var cell = new gfx.Grass();
					cell.scale( TILE_SIZE / GFX_TILE_SIZE );
					cell.x = j * TILE_SIZE;
					cell.y = i * TILE_SIZE;
					tmp.addChild(cell);
				}
				else
				{
					var top = getAt(j, i - 1);
					var left = getAt(j - 1, i);
					var right = getAt(j + 1, i);
					
					if ( top == null && left == null && right == null ) continue;
					var frame = if ( getAt(j - 1, i - 1) != null && getAt(j + 1, i - 1) != null ) 2
								else if ( getAt(j - 1, i - 1) == null && top != null ) 1
								else if ( getAt(j - 1, i + 1) == null && top != null ) 3
								else if ( left == null ) 4
								else if ( right == null ) 5
								else 0;
					
					var cell = new gfx.Cliffs();
					cell.gotoAndStop(frame);
					cell.scale( TILE_SIZE / GFX_TILE_SIZE );
					cell.x = j * TILE_SIZE;
					cell.y = i * TILE_SIZE;
					tmp.addChild(cell);
				}
			}
		}
		/*
		//bottom cliffs
		for ( j in 0...GRID_WMAX )
		{
			if ( getAt(j, i - 1) == null ) continue;
			
			var i = GRID_HMAX;
			var cell = new gfx.Cliffs();
			cell.scale( TILE_SIZE / GFX_TILE_SIZE );
			cell.x = j * TILE_SIZE;
			cell.y = i * TILE_SIZE;
			
			if ( getAt(j - 1, i - 1) != null && getAt(j + 1, i - 1) != null ) cell.gotoAndStop(2);
			else if ( getAt(j - 1, i - 1) != null ) cell.gotoAndStop(3);
			else cell.gotoAndStop(1);
			tmp.addChild(cell);
		}
		//side cliffs
		for ( i in 0...GRID_HMAX )
		{
			//left
			if ( getAt(0, i ) != null ) 
			{
				var j = -1;
				var cell = new gfx.Cliffs();
				cell.gotoAndStop(4);
				cell.scale( TILE_SIZE / GFX_TILE_SIZE );
				cell.x = j * TILE_SIZE;
				cell.y = i * TILE_SIZE;
				tmp.addChild(cell);
			}
			//right
			var j = GRID_WMAX;
			var cell = new gfx.Cliffs();
			cell.gotoAndStop(5);
			cell.scale( TILE_SIZE / GFX_TILE_SIZE );
			cell.x = j * TILE_SIZE;
			cell.y = i * TILE_SIZE;
			tmp.addChild(cell);
		}
		*/
		var fbmp = tmp.flatten(0, true, true, StageQuality.BEST);
		depthManager.add( fbmp, DP_GRID );
	}
	
	public function onCross(x:Int, y:Int, score:Int)
	{
		if ( false == gfxBonusMap.exists(x + "_" + y) )
		{
			var gfx = new gfx.Flower();
			gfx.scale( TILE_SIZE / GFX_TILE_SIZE );
			gfx.x = x * TILE_SIZE;
			gfx.y = y * TILE_SIZE;
			if ( score == Cs.COMPLEX_COMBO.get() ) gfx.gotoAndStop(2);
			else gfx.gotoAndStop(1);
			
			setCrossGfxAt(x, y, gfx);
			depthManager.add( gfx, DP_FLOWERS );
		}
		
		var tf = createScoreTF( Std.string(score), x * TILE_SIZE, y * TILE_SIZE, 32);
		tf.filters = [new GlowFilter(0xFFFFFF) ];
		var tf = tf.flatten(0, true, true, StageQuality.BEST);
		depthManager.add(tf, DP_SCORE);
		Game.me.tweenie.create(tf, "y", tf.y - 50, 1000);
		Game.me.tweenie.create(tf, "alpha", 0.1, 2000).onEnd = function() { tf.detach(); }
	}
	
	function getFrameFromState(node:NodeData)
	{
		var l = node.left != null;
		var r = node.right != null;
		var b = node.bottom != null;
		var t = node.top != null;
		var empty = ( !l && !r && !b && !t );
		var tr = t && r;
		var br = b && r;
		var tl = t && l;
		var bl = b && l;
		var lr = l && r;
		var bt = b && t;
		var btr = bt && r;
		var btl = bt && l;
		var lrt = lr && t;
		var lrb = lr && b;
		
		return 	if ( empty ) null;
				else if ( l && b && r && t ) "blrt";
				else if ( lrb ) "blr";
				else if ( lrt ) "lrt";
				else if ( btr ) "brt";
				else if ( btl ) "blt";
				else if ( bt ) 	"bt";
				else if ( lr ) 	"lr";
				else if ( bl ) 	"bl";
				else if ( tl ) 	"lt";
				else if ( tr ) 	"rt";
				else if ( br ) 	"br";
				else if ( b ) 	"b";
				else if ( t ) 	"t";
				else if ( l ) 	"l";
				else if ( r ) 	"r";
				else throw "Impossible";
	}
	
	public function grabKdo(kdo : {x:Int, y:Int} )
	{
		var gfx = gfxKdoMap.get(kdo.x + '_' + kdo.y);
		Game.me.tweenie.create(gfx, "y", gfx.y - 30, TElasticEnd, 300).onEnd = function() {
			gfx.filters = [new flash.filters.BlurFilter(8, 4)];
			Game.me.tweenie.create(gfx, "scaleX", 1.2, TElasticEnd, 300);
			Game.me.tweenie.create(gfx, "scaleY", 0, 300);
			Game.me.tweenie.create(gfx, "alpha", 0, 300);
		};
	}
	
	public function drawKdo(kdo)
	{
		var gfx = new gfx.Kado();
		gfx.mouseEnabled = false;
		gfx.gotoAndStop( kdo.frame );
		gfx.scale( 0.75 * TILE_SIZE / GFX_TILE_SIZE);
		gfx.x = kdo.x * TILE_SIZE + TILE_SIZE / 2;
		gfx.y = kdo.y * TILE_SIZE + TILE_SIZE / 2;
		
		var bmp = gfx.flatten(0, true, true, StageQuality.BEST);
		depthManager.add( bmp, DP_KDO);
		gfxKdoMap.set(kdo.x + '_' + kdo.y, bmp);
	}
	
	public function drawHighlight(x:Int, y:Int)
	{
		var fx = new gfx.TileHighlight();
		fx.scale( TILE_SIZE / GFX_TILE_SIZE );
		fx.x = x * TILE_SIZE;
		fx.y = y * TILE_SIZE;
		depthManager.add(fx, DP_FLOORFX );
		Game.me.delayer.addFrame( function() fx.detach(), 15 );
	}
	
	public function updatePathGfx()
	{
		var m = new flash.geom.Matrix();
		var r = new flash.geom.Rectangle(0, 0, TILE_SIZE, TILE_SIZE);
		pathBitmap.bitmapData.lock();
		for ( j in 0...GRID_HMAX )
		{
			for ( i in 0...GRID_WMAX )
			{
				var node = getAt(i, j);
				if ( node != null )
				{
					r.x = i * TILE_SIZE;
					r.y = j * TILE_SIZE;
					
					var nodeLabel = getFrameFromState(node);
					var currentLabel = getPathGfxAt(i, j);
					if ( nodeLabel != currentLabel )
					{
						if ( currentLabel == "blrt" )
						{
							var gfx = getCrossGfxAt(i, j);
							if( gfx != null ) gfx.detach();
							setCrossGfxAt(i, j, null);
						}
						
						setPathGfxAt(i, j, nodeLabel);
						pathBitmap.bitmapData.fillRect( r, 0xFF );
						
						if ( nodeLabel != null )
						{
							tmpPathGfx.gotoAndStop(nodeLabel);
							tmpPathGfx.x = i * TILE_SIZE;
							tmpPathGfx.y = j * TILE_SIZE;
							pathBitmap.bitmapData.draw( tmpPathGfx, tmpPathGfx.transform.matrix );
							//
							var score = getScoreGfxAt(i, j);
							if( score != null ) score.unlock();
						}
						else
						{
							var score = getScoreGfxAt(i, j);
							if( score != null ) score.lock();
						}
					}
				}
			}
		}
		pathBitmap.bitmapData.unlock();
	}
	
	inline function getPathColor(p:Path)
	{
		return switch( p.trigger.type )
		{
			case 0: 0x40A7EB;//bleu
			case 1: 0xE18B35;//orange
			case 2: 0xED7BCA;//rose
			default: throw "unknown trigger type";
		}
	}
	
	
	function createGradientFilter()
	{
		var distance  = 0;
        var angleInDegrees = 45;
        var colors     = [0xFF0000, 0xFF0000, 0xFFFFFF];
        var alphas     = [0, 0.5, 1.];
        var ratios     = [0, 128, 255];
        var blurX     = 60;
        var blurY     = 60;
        var strength  = 10;
        var quality   = flash.filters.BitmapFilterQuality.HIGH;
        var type      = flash.filters.BitmapFilterType.OUTER;
        var knockout = false;
		return new GradientGlowFilter(distance,
                                          angleInDegrees,
                                          colors,
                                          alphas,
                                          ratios,
                                          blurX,
                                          blurY,
                                          strength,
                                          quality,
                                          type,
                                          knockout);
	}
	
	var lastAlarm:Int = 0;
	var alarmFilter : GradientGlowFilter;
	public function update(pathRedraw:Bool)
	{
		if( pathRedraw )
			updatePathGfx();
		
		//SUPER CRADE !!  :(
		if ( gfxChrono != null )
		{
			switch( api.AKApi.getGameMode() )
			{
				case GM_LEAGUE:
					var seconds = Game.me.getTime() / Cs.FPS.get();
					var info = DateTools.parse(seconds * 1000);
					gfxChrono.text = StringTools.lpad( Std.string(info.minutes), "0", 2 ) + ":" + StringTools.lpad( Std.string(info.seconds), "0", 2 );
					
					var danger = info.minutes == 0 && info.seconds <= 15;
					if ( danger )
					{
						if ( info.seconds != lastAlarm )
						{
							if ( info.seconds == 15 ) gfxChrono.blendMode = BlendMode.ADD;
							alarmFilter = createGradientFilter();
							gfxChrono.filters = [alarmFilter];
							lastAlarm = info.seconds;
						}
						else
						{
							if( alarmFilter != null )
							{
								alarmFilter.strength -= 0.5;
								gfxChrono.filters = [alarmFilter];
							}
						}
					}
				case GM_PROGRESSION:
					
			}
 		}
		
		for ( path in Game.me.pathMap )
		{
			if ( path.completed ) continue;
			var cx = path.currentX;
			var cy = path.currentY;
			if ( (cx < 0 || cy < 0) || (cx == path.trigger.x && cy == path.trigger.y) ) continue;
			
			var type = path.trigger.type;
			if ( Game.me.getGameFrame() % 6  != 0 ) continue;
			
			var p = new Particle((path.currentX + .5) * TILE_SIZE, (path.currentY + .5) * TILE_SIZE);
			var gfx = new gfx.Particleleaf();
			gfx.scale( TILE_SIZE / GFX_TILE_SIZE );
			gfx.gotoAndStop( 1 + type );
			p.addChild( gfx );
			
			p.dx = MLib.frandRangeSym(0.8);
			p.dy = MLib.frandRangeSym(0.8);
			p.dr = MLib.frandRangeSym(8);
			
			depthManager.add(p, DP_PARTICLES);
		}
	}
}

class ScoreField extends flash.text.TextField
{
	public static var LOCKED_SIZE = 9;
	public static var UNLOCKED_SIZE = 14;
	
	public static var LOCKED_COLOR = 0x1A2942;
	public static var UNLOCKED_COLOR = 0xFFFFCC;
	
	public function new()
	{
		super();
		var font = new gfx.font.CooperStd();
		var format = new TextFormat (font.fontName, LOCKED_SIZE, LOCKED_COLOR);
		defaultTextFormat = format;
		embedFonts = true;
		selectable = false;
		autoSize = TextFieldAutoSize.CENTER;
		alpha = 0.8;
	}
	
	public function setScore( score:Int )
	{
		this.text = Std.string(score);
		
		var size = MLib.clamp( 5+Std.int(score / 100), LOCKED_SIZE, UNLOCKED_SIZE);
		var tf = this.getTextFormat();
		tf.size = size;
		setTextFormat(tf);
	}
	
	var ox:Float;
	var oy:Float;
	public var unlocked(default, null):Bool;
	public function setAt(i:Int, j:Int)
	{
		this.x = i * Game.TILE_SIZE + Game.TILE_SIZE / 2 - this.width / 2;
		this.y = j * Game.TILE_SIZE + Game.TILE_SIZE / 2;// - this.height / 2;
		this.ox = this.x;
		this.oy = this.y;
	}
	
	public function unlock()
	{
		var tf = this.getTextFormat();
		tf.size = UNLOCKED_SIZE;
		tf.color = UNLOCKED_COLOR;
		defaultTextFormat = tf;
		setTextFormat(tf);
		unlocked = true;
		Game.me.tweenie.create(this, "y", oy - 0.75 * Game.TILE_SIZE, 500);		
		this.blendMode = BlendMode.NORMAL;
	}
	
	public function lock()
	{
		var tf = this.getTextFormat();
		tf.size = MLib.clamp( Std.int( Std.parseInt(text) / 100), LOCKED_SIZE, UNLOCKED_SIZE);
		tf.color = LOCKED_COLOR;
		defaultTextFormat = tf;
		setTextFormat(tf);
		unlocked = false;
		Game.me.tweenie.create(this, "y", oy, 500);
		this.blendMode = BlendMode.OVERLAY;
	}
}