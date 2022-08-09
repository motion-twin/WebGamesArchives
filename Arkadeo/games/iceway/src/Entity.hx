package;

import Lib;
import mt.deepnight.SpriteLib;
import mt.deepnight.Particle;
import mt.kiroukou.motion.Ease;

enum EntityKind
{
	EK_Boy;
	EK_Girl;
	EK_Dog;
}

using GridTools;
class Entity implements mt.kiroukou.events.Signaler
{
	static var ID = 0;
	var id : Int;
	
	var _talkCB : List < Void->Void > ;
	var movesStack : Array<{dir:MoveDir, dest:GridCell}>;
	public var gfx(default, null) : DSprite;
	public var cell : Null<GridCell>;
	public var dest : Null<GridCell>;
	public var origin : GridCell;
	public var isMoving : Bool = false;
	public var moveDir : Null<MoveDir>;
	public var reflection : Null<Reflection>;
	public var kind(default, null) : EntityKind;
	public var hitArea(default, null) : Sprite;
	
	public var follower : Null<Entity>;
	
	@:as3signal( flash.events.Event.ENTER_FRAME, gfx )
	public function onFrame() { }
	
	public var speed: Int = 7;
	
	public function new( kind : EntityKind, gfx:DSprite, cell )
	{
		this.id = ID ++;
		this.gfx = gfx;
		this.origin = cell;
		this.cell = origin;
		this.kind = kind;
		//
		hitArea = new Sprite();
		hitArea.graphics.beginFill(0, 0);
		hitArea.graphics.drawRect( -Lib.TILE_MID_SIZE, -Lib.TILE_MID_SIZE, Lib.TILE_SIZE, Lib.TILE_SIZE);
		hitArea.graphics.endFill();
		gfx.addChild(hitArea);
		//
		if( kind != EK_Boy )
		{
			this.gfx.hitArea = hitArea;
		}
		else
		{
			this.gfx.mouseEnabled = false;
			this.gfx.mouseChildren = false;
		}
		movesStack = [];
		_talkCB = new List();
	}
	
	public function dispose()
	{
		unbindAll();
		//Tween.removeTarget(gfx);
		if( gfx != null && gfx.parent != null ) gfx.parent.removeChild(gfx);
	}

	
	function _afterTalk( p : gfx.Popup)
	{
		p.hide();
		if( _talkCB.length != 0 )
		{
			haxe.Timer.delay( _talkCB.pop(), 100 );
		}
	}
	
	public function talk( text : String, ?duration:Int = 4, ?shakeDuration:Float=0., ?shakeStrength:Int=10 )
	{
		if( PopupManager.get().isTalking(this) )
		{
			_talkCB.push( callback( talk, text, duration, shakeDuration, shakeStrength ) );
			return;
		}
		
		var p = PopupManager.get().getPopup();
		p.setText( text );
		p.attach(this);
		p.sync();
		p.show();
		
	}
	
	public function update()
	{
		if ( isMoving ) 
		{
			_move();
		}
	}
	
	public function reset()
	{
		movesStack = [];
		isMoving = false;
		if( kind == EK_Girl )
			gfx.libGroup = "down";
		else if( kind == EK_Boy )
			gfx.libGroup = "cry";
	}
	
	public function sync()
	{
		var coord = Lib.getCoord( cell );
		gfx.x = coord.x;
		gfx.y = coord.y;
	}

	public function move(dir, dest)
	{
		if( isMoving )
		{
			movesStack.push( { dir:dir, dest:dest } );
			return;
		}
		this.moveDir = dir;
		this.dest = dest;
		switch( moveDir )
		{
			case MLeft: gfx.scaleX = 1; gfx.libGroup = "left";
			case MRight : gfx.scaleX = -1;  gfx.libGroup = "left";
			case MUp : gfx.libGroup = "up";
			case MDown: gfx.libGroup = "down";
		}
		gfx.playAnim("walk");
		isMoving = true;
	}
	
	function _move()
	{
		var oldcell = cell;
		var coord = Lib.getCoord( dest );
		var dx = Std.int(coord.x - gfx.x);
		var dy = Std.int(coord.y - gfx.y);
		var dist = MLib.max( MLib.abs(dx), MLib.abs(dy) );
		if( dx != 0 )
		{
			gfx.x += if( dx > 0 ) MLib.min(dx, speed) else MLib.max(dx, -speed);
		}
		if( dy != 0 )
		{
			gfx.y += if( dy > 0 ) MLib.min(dy, speed) else MLib.max(dy, -speed);
		}
		var cx = Std.int(gfx.x / Lib.TILE_SIZE);
		var cy = Std.int(gfx.y / Lib.TILE_SIZE);
		cell = Game.me.grid.getAt( cx, cy );
		//TODO !
		if( cell != oldcell )
		{
			if( kind == EK_Girl )
			{
				if( cell.flags.has(Kdo) )
				{
					var gfx : gfx.Kado = cast cell.gfx;
					var coord = Lib.getCoord(cell, true );
					
					Fx.kdoFound( coord.x + Game.me.dm.getMC().x, coord.y + Game.me.dm.getMC().y, Lib.KDO_COLORS[gfx.prizeToken.frame-1] );
					//
					var token = gfx.prizeToken;
					Game.me.grabToken(token);
					// clean
					cell.flags.unset(Kdo);
					if( gfx.parent != null )
						gfx.parent.removeChild(gfx);
				}
				for( e in Game.me.allEntities )
				{
					if( e == this ) continue;
					if( e.cell == cell && follower == null )
					{
						gfx.libGroup = "oups";
						gfx.playAnim("missed", 1);
						
						this.talk( Texts.Oups, 2, 2 );
						break;
					}
				}
			}
		}
		if( Std.random(4) == 0 )
		{
			var b = hitArea.getBounds(Game.me.dm.getMC());
			var cx = b.right - Lib.TILE_MID_SIZE;
			var cy = b.bottom;
			Fx.makeSnowDust(cx, cy, b.bottom - Lib.TILE_MID_SIZE);
		}
		if( dist == 0 )
		{
			_moveEnded();
		}
	}
	
	function _moveEnded()
	{
		isMoving = false;
		//
		
		if( PopupManager.get().isTalking(this) )
		{
			PopupManager.get().getEntityPopup(this).hide();
		}
		
		if( movesStack.length == 0 )
		{
			moveDir = null;
			gfx.stopAnim(0);
			Game.me.onMoveEnd(this);
		}
		else
		{
			var m = movesStack.shift();
			move( m.dir, m.dest );
		}
	}
	
	public function toString()
	{
		return "Entity : " + id + " : " + this.kind;
	}
}
