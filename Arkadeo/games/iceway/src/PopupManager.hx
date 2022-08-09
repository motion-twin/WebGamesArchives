package ;
import gfx.Popup;

class PopupManager
{
	static var _instance : PopupManager;
	inline public static function get()
	{
		if( _instance == null ) _instance = new PopupManager();
		return _instance;
	}
	
	var _l : List<Popup>;// all free instances
	var _u : List<Popup>;// all used instances
	function new()
	{
		_l = new List();
		_u = new List();
	}
	
	function allocate()
	{
		_l.add( new Popup() );
	}
	
	public function free()
	{
		for( p in _u )
		{
			p.hide();
		}
	}
	
	public function isTalking( entity : Entity )
	{
		for( p in _u )
			if( p.entity == entity )
				return true;
		return false;
	}
	
	public function getEntityPopup( entity : Entity )
	{
		for( p in _u )
			if( p.entity == entity )
				return p;
		return null;
	}
	
	public function syncAll()
	{
		for( p in _u )
			p.sync();
	}
	
	public function freePopup(popup:Popup)
	{
		_u.remove(popup);
		_l.add(popup);
	}
	
	public function getPopup():Popup
	{
		if( _l.length == 0 ) allocate();
		var p = _l.pop();
		_u.add(p);
		return p;
	}
}