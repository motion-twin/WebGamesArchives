import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import haxe.FastList;
import mt.fx.Flash;
import haxe.EnumFlags;
import mt.gx.BitArray;
import mt.gx.Debug;
import Text;
import DefaultImport;

using mt.gx.Ex;

class BmpLd extends BitmapData{}


class Data
{
	public var platforms : IntHash< { corner:Array<{bmp:Bitmap,ofsY:Float}>,  mid:Array<{bmp:Bitmap,ofsY:Float}> }>;
	public var props : IntHash<Bitmap>;
	public var walls : IntHash<Bitmap>;
	
	public var wallLine : Array<Bitmap>;
	
	public var tilesSrc : gfx.Tiles;
	
	public var ldBmp : BmpLd;
	public var ldLines : Array <RectI>;
	
	var fxMove : mt.gx.Pool< gfx.MovementFX >;
	
	
	public static var ORANGE = 0xde7a00;
	
	public var bmpHit : Bitmap;
	
	public var game(get, null) : Game; function get_game() return Game.me
	
	public function playFX( str:String )
	{
		var mc = fxMove.create();
		
		//Game.level.addChild(mc);
		game.level.dm.add( mc, Level.FX_DEPTH );
		//mt.gx.as.Lib.toFront( mc );
		mc.gotoAndStop( str );

		mc.scaleX = mc.scaleY=1;
		mc.rotationZ = 0;
		
		game.level.tasks.pushBack( function()
		{
			if ( mc.smc != null)
			{
				mc.smc.stop();
				
				if ( mc.smc.currentFrame >= mc.smc.totalFrames )
				{
					mc.smc.gotoAndStop(0);
					
					mc.detach();
					fxMove.destroy( mc );
					return true;
				}
				else
				{
					mc.smc.nextFrame();
					return false;
				}
			}
			return false;
		});
			
		
		
		return mc;
	}
	
	public function new()
	{
		ldBmp = new BmpLd(0,0,false);
		tilesSrc = new gfx.Tiles();
		fxMove = new mt.gx.Pool( function() return new gfx.MovementFX() );
		platforms = new IntHash();
		var i = 0;
		for ( p in ['p1','p2','p3','p4','p5'] )
		{
			tilesSrc.gotoAndStop(p);
			var t = { corner:[], mid:[], };
			var n = tilesSrc.numChildren;
			var mc : flash.display.MovieClip = cast tilesSrc.getChildAt(n - 1);
			
			var bi = 0;
			for ( i in 1...mc.totalFrames)
			{
				mc.gotoAndStop( i );
				if ( mc.currentLabel == 'start' )
					t.corner.pushBack( {bmp:mt.deepnight.Lib.flatten(mc),ofsY:0.0} );
				else if ( mc.currentLabel == 'body')
				{
					var fl = mt.deepnight.Lib.flatten(mc);
					var b = mc.getBounds(mc);
					var r = mc.getRect(mc);
					t.mid.pushBack( {bmp:fl,ofsY:b.y} );
					bi++;
				}
			}
			platforms.set( i++, t );
		}
		
		tilesSrc.gotoAndStop( 'props' );
		props = Lib.cacheFrames( cast tilesSrc.getChildAt(0) );
		
		tilesSrc.gotoAndStop( 'wall' );
		walls = Lib.cacheFrames( cast tilesSrc.getChildAt(0) );
		
		wallLine = [];
		for ( i in 0...100)
		{
			var w = new flash.display.Shape();
			var prev = null;
			for ( i in 0...Lib.nbch()+1)
			{
				var r = walls.random();
				if ( r == prev )
					r = walls.random();
				prev = r;
				var gfx = w.graphics;
				gfx.beginBitmapFill( r.bitmapData );
				gfx.drawRect(0, i*16, 16, 16);
				gfx.endFill();
			}
			wallLine.pushBack( mt.deepnight.Lib.flatten(w) );
		}
		
		makeLdLines();
		for ( i in 0...LD.length)
			if ( LD[i].sms == null )
				LD[i].sms = Text.ALL.get("lvl_" + (i + 1));
				
		var spr = new flash.display.Sprite();
		spr.graphics.beginFill(0x0,1.0);
		spr.graphics.drawRect(0, 0, Lib.w(), Lib.h());
		spr.graphics.endFill();
		
		var s = 120.0;
		var f = new flash.filters.GlowFilter(0xFF0707, 0.9, s, s,2,1,true);
		spr.filters = [f];
		bmpHit = mt.deepnight.Lib.flatten( spr );
		bmpHit.blendMode = flash.display.BlendMode.ADD;
		//bmpHit.tra
	}
	
	function debug()
	{
		
	}
	
	public static var PW_JUMP_ONLY = 
	{
		var r : EnumFlags<CharPowers> = EnumFlags.ofInt(0);
		r;
	}
	
	public static var PW_DOUBLE_JUMP = 
	{
		var r : EnumFlags<CharPowers> = EnumFlags.ofInt(0);
		r.set(CP_DOUBLE_JUMP);
		r;
	}
	
	public static var PW_SUPER_JUMP = 
	{
		var r : EnumFlags<CharPowers> = EnumFlags.ofInt(0);
		r.set(CP_SUPER_JUMP);
		r;
	}
	
	public static var PW_GRAB = 
	{
		var r : EnumFlags<CharPowers> = EnumFlags.ofInt(0);
		r.set(CP_WALL_STICK);
		r;
	}
	
	public static var PW_JUMP_GRAB = 
	{
		var r : EnumFlags<CharPowers> = EnumFlags.ofInt(0);
		r.set(CP_DOUBLE_JUMP);
		r.set(CP_SUPER_JUMP);
		r.set(CP_WALL_STICK);
		r;
	}
	
	public static var PW_KICK = 
	{
		var r : EnumFlags<CharPowers> = EnumFlags.ofInt(0);
		r.set(CP_DOUBLE_JUMP);
		r.set(CP_SUPER_JUMP);
		r.set(CP_WALL_STICK);
		r.set(CP_KICK);
		r;
	}
	
	public static var PW_KICK_ONLY = 
	{
		var r : EnumFlags<CharPowers> = EnumFlags.ofInt(0);
		r.set(CP_KICK);
		r;
	}
	
	
	public static var PW_CANCEL = 
	{
		var r : EnumFlags<CharPowers> = EnumFlags.ofInt(0);
		r.set(CP_DOUBLE_JUMP);
		r.set(CP_CANCEL);
		r;
	}
	
	public static var PW_ALL = 
	{
		var r : EnumFlags<CharPowers> = EnumFlags.ofInt(0);
		r.set(CP_DOUBLE_JUMP);
		r.set(CP_SUPER_JUMP);
		r.set(CP_WALL_STICK);
		r.set(CP_KICK);
		r.set(CP_CANCEL);
		r;
	}

	

	public static var LD  : Array<{seq:Array<LD_PATTERN>, diff:Array<{d:Float,w:Int}>, ?sms : String, ? deadline : Float,? platforms:Int}>= 
	[
		{seq:[LDPage(0)]											, diff:[{d:1.0,w:100}]						}, //jump 1
		{seq:[LDPage(1)]											, diff:[{d:1.0,w:100}]						},
		{seq:[LDPage(2)]											, diff:[{d:1.0,w:100}] 						}, // double jump
		{seq:[LDPage(3), LDGen(2), LDPage(5)]											, diff:[{d:1.0,w:100}]						},
		{seq:[LDPage(4), LDGen(6), LDPage(5) ]						, diff:[{d:1.0,w:100}]						},

		{seq:[LDPage(6), LDGen(8), LDPage(5)]						, diff:[{d:1.0,w:100},	]					}, // super jump 6
		{seq:[LDPage(6), LDGen(10), LDPage(7)]						, diff:[{d:1.0,w:100},	]					},
		{seq:[LDPage(8), LDGen(8), LDPage(10)]						, diff:[{d:1.0,w:100},]						}, // grab
		{seq:[LDPage(8), LDGen(9), LDPage(5)]						, diff:[{d:1.0,w:100},]						},
		{seq:[LDPage(12), ]											, diff:[ { d:1.0, w:100 } ]						}, // kick
		
		
		{seq:[LDPage(14), LDGen(6), LDPage(5)]						, diff:[ { d:1.0, w:20 },		]	, platforms:2 }, // cancel
		{seq:[LDPage(13),LDGen(8),LDPage(5)]						, diff:[{ d:1.0, w:10 }		]	},
		{seq:[LDPage(4), LDGen(10), LDPage(5)]						, diff:[{d:1.0,w:20},	]		},
		
		{seq:[LDPage(15), LDGen(10), LDPage(5)]						, diff:[{ d:1.0, w:20 },{d:2.0,w:100}, 				]		,sms:Text.for_real},
		{seq:[LDPage(4), LDGen(12), LDPage(5)]						, diff:[{d:2.0,w:80}, 	{d:3.0,w:40 }]		}, 
																	  
		{seq:[LDPage(4), LDGen(5), LDPage(16), LDGen(5), LDPage(5)]	, diff:[{ d:1.0, w:30 },{d:2.0,w:40},{d:3.0,w:10}]			,platforms:4}, //16
		{seq:[LDPage(4), LDGen(18), LDPage(5)]						, diff:[ { d:2.0, w:80 }, { d:3.0, w:40 } ]			},//17
		{seq:[LDPage(4), LDGen(7), LDPage(17), LDGen(7), LDPage(5)]	, diff:null 		},//18
		{seq:[LDPage(4), LDGen(20), LDPage(5)]						, diff:null, 		deadline:0.7,platforms:3	},
		{seq:[LDPage(4), LDGen(20), LDPage(18)]						, diff:null,		deadline:0.85,platforms:2	},
	];
	
	function snum(s)
	{
		return 
		switch(s)
		{
			case LDPage(_): 1;
			case LDGen(nb): nb;
		}
	}
	
	public function ldLength(l:Int)
	{
		return Data.LD[l].seq.sum( snum );
	}
	
	var nth = 0;
	public function addLdLines(rd : mt.Rand)
	{
		var totalH = Lib.nbch() * 128;
		
		pageBmp = new BitmapData( Lib.nbcw(), totalH, false);
		pageBmp.fillRect( new Rectangle( 0, 0, pageBmp.width, pageBmp.height), 0xFF000000);
		genLines = [];
		
		var cy : Int = 0;
		var cx : Int = 0;
		var isLeague = Game.isLeague();
		var procStart : Int = 19; 
		//trace("nb lines:" + ldLines.length);
		function std() 
		{
			var idx = procStart + rd.random(ldLines.length - procStart );
			//trace("choosing idx " + idx);
			return ldLines[ idx  ];
		}
		
		
		var l : Int = Game.getLevel();
		var seqLen = Game.isLevelup() ? Data.LD[l].seq.sum( snum ) : 0;
		function seqPg(pg)
		{
			for(s in Data.LD[l].seq)
			{
				pg -= snum(s);
				if ( pg < 0 )
					return s;
			}
			return null;
		}
			
		//trace("sq "+seqLen);
		Lib.Prof.get().begin("blit");
		while(true)
		{
			var e = null;
			
			if ( isLeague )
				if ( nth == 0 ) 
					e = ldLines[ procStart ];
				else
				{
					
					#if test_level
					var st = 32;
					e = ldLines[st + procStart + nth];
					if ( e == null)
					#end
					
					e = std();	
				}
			else
			{
				if ( nth >= seqLen )
					break;
				else
				{
					switch(seqPg(nth))
					{
						case LDPage(p): 	e = ldLines[p]; //trace('p');
						case LDGen(_):  	e = std();		//trace('g');
					}
				}
				
				//trace("chosen " + e);
				if ( e == null )
					break;
				
			}
			
			var eh = Std.int(e.height + 0.5);
			var ew = Std.int(e.width + 0.5);
			
			var flipX = rd.random(2) == 1;
			if ( !Level.ENABLE_FLIP )  flipX = false;			
			
			for ( y in 0...eh)
			{
				var ry = eh - y - 1;
				for ( x in 0...ew)
				{
					var dx = cx;
					if ( flipX ) dx = pageBmp.width - cx ;
					
					var p = ldBmp.getPixel(e.x + x, e.y + ry );
					pageBmp.setPixel( dx, cy, p );
					
					if ( p == 0x00FF00 && !Game.isLeague() )
						game.level.winCy = cy;
					
					cx++;
				}
				cx = 0;
				cy++;
			}
			
			if ( cy > totalH )
				return;
			//trace(e);
			genLines.push( e );
			nth++;
		}
		
		Lib.Prof.get().end("blit");
	}
	
	
	public inline function getPixel(n,lx:Int,ly:Int)
	{
		ly = -ly;
		var pc = pageBmp.getPixel( lx, ly + Lib.nbch() * n  );
		return pc;
	}
	
	public inline function iterPage( n,proc )
		for ( y in 0...Lib.nbch() )
			for ( x in 0...Lib.nbcw() + 1)
			{
				var px = x;
				var py = Lib.nbch() * n + y;
				var pc = pageBmp.getPixel( x, py);
				proc( x, y , pc);
			}
	
	public var genLines : Array<RectI>;
	public var pageBmp : BitmapData;
	
	public function makeLdLines()
	{
		var a : Array<RectI> = [];
		var streakY = -1;
		for ( y in 0...ldBmp.height)
		{
			var pix = ldBmp.getPixel( 0, y );
			
			function push()
			{
				a.pushBack( 
					{
						x:0,
						y:streakY,
						width:Std.int(0.5 + ldBmp.width),
						height:y-streakY,
					});
				streakY = -1;
			}
			
			switch( pix )
			{
				case 0xFFFFFF:
					if (streakY >= 0)
						push();
				case 0xEEeeEE, 0xeeff00:
					if (streakY >= 0)
						push();
					break;
				default: 
					if ( streakY < 0 ) streakY = y;
			}
		}
		
		
		ldLines = a;
	}
	
	
	public static function getOrangeFilter()
	{
		var g = new flash.filters.GlowFilter();
		g.blurX = 12;
		g.blurY = 12;
		g.color = 0xff8200;
		g.alpha = 0.3;
		g.inner = true;
		
		return g;
	}
	
	public static function getOuterBlackFilter()
	{
		var g = new flash.filters.GlowFilter();
		g.blurX = 4;
		g.blurY = 4;
		g.strength = 4;
		g.color = 0x0;
		g.alpha = 0.4;
		
		return g;
	}
	
	public static var SMS_KDO_REP = Text.sms_kdo.split('|');
	public static var SMS_RAND_REP = Text.sms_flash.split('|');
	
	public static var SMS_P = Text.var_p.split(',');
	public static var SMS_N = Text.var_n.split(',');
	
	public static function getSmsKdo()
	{
		var rd = new mt.Rand( Game.getSeed() *  Game.getLevel() + Game.getFrame());
		return SMS_KDO_REP.random(rd).split("$n").join(SMS_N.random(rd)).split("$p").join(SMS_P.random(rd));
	}
	
	public static function getSmsVar()
	{
		var rd = new mt.Rand( Game.getSeed() * 8788383 +  Game.getLevel() + Game.getFrame());
		return SMS_RAND_REP.random(rd).split("$n").join(SMS_N.random(rd)).split("$p").join(SMS_P.random(rd));
	}
	
	
}