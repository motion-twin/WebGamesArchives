package gfx;
import Lib;

class Selection extends Sprite, implements mt.kiroukou.events.Signaler
{
	@:as3signal(flash.events.MouseEvent.CLICK, this)
	public function onClick():Void;
	
	function new()
	{
		super();
		draw();
	}
	
	public function setCell( cell : GridCell )
	{
		var coord = Lib.getCoord( cell, false );
		x = coord.x;
		y = coord.y;
		visible = true;
		Game.me.dm.over(this);
		return this;
	}
	
	public function setFilters( filters )
	{
		this.filters = filters;
		return this;
	}
	
	function draw()
	{
		var offset = 3;
		var g = graphics;
		g.clear();
		g.lineStyle(2, 0xFFFFFF, 1.);
		g.drawRoundRect(offset, offset, Lib.TILE_SIZE-2*offset, Lib.TILE_SIZE-2*offset, 10);
		g.endFill();
		
		hitArea = new Sprite();
		g = hitArea.graphics;
		g.beginFill(0, 0);
		g.drawRect( -5, -5, Lib.TILE_SIZE + 10, Lib.TILE_SIZE + 10 );
		g.endFill();
		hitArea.mouseEnabled = false;
		addChild(hitArea);
	}
	
	static var _free = new List<Selection>();
	static var _used = new List<Selection>();
	public static function get():Selection
	{
		if( _free.length == 0 )
		{
			_free.add(new Selection());
		}
		var s = _free.pop();
		if( s.parent == null )
		{
			Game.me.dm.add(s, Game.DM_GAME);
		}
		Game.me.dm.over(s);
		_used.add(s);
		return s;
	}
	
	public static function cleanAll()
	{
		for( s in _used )
		{
			free(s);
		}
	}
	
	public static function free(s : Selection)
	{
		s.unbindAll();
		s.visible = false;
		s.filters = [];
		_used.remove(s);
		_free.add(s);
	}
}
