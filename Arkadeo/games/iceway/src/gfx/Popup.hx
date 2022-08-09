package gfx;

import Lib;

class Popup extends Sprite, implements mt.kiroukou.events.Signaler
{
	var _bubble : Bubble;
	var _text:flash.text.TextField;
	
	public var entity(default, null) : Entity;
	public var container(default, null) : Sprite;
	
	@:as3signal( flash.events.MouseEvent.CLICK, this )
	function onClicked();
	
	@:as3signal( flash.events.MouseEvent.MOUSE_OVER, this )
	function onOver();
	
	inline static var TEXT_OFFSET_X = 10;
	inline static var TEXT_OFFSET_Y = 5;
	
	public function new()
	{
		super();
		container = new Sprite();
		addChild(container);
		_bubble = new Bubble();
		_bubble.width = 100;
		container.addChild(_bubble);
		
		var tf = new flash.text.TextFormat( "_PixelSquare", 10, 0 );
		_text = new flash.text.TextField();
		_text.defaultTextFormat = tf;
		container.addChild(_text);
		_text.x = TEXT_OFFSET_X;
		_text.y = TEXT_OFFSET_Y;
		
		_text.antiAliasType = flash.text.AntiAliasType.ADVANCED;
		_text.embedFonts = true;
		_text.mouseEnabled = false;
		_text.selectable = false;
		_text.width = 95;
		_text.height = _bubble.height;
		_text.multiline = true;
		_text.wordWrap = true;
		_text.condenseWhite = true;
		_text.autoSize = flash.text.TextFieldAutoSize.LEFT;
		bindOnClicked( hide );
		bindOnOver( hide );
	}
	
	public function setText( msg:String )
	{
		_text.text = msg;
		_text.setTextFormat( _text.defaultTextFormat );
		resize();
	}
	
	public function attach( ent : Entity )
	{
		Game.me.dm.add( this, Game.DM_UI );
		entity = ent;
		sync();
	}
	
	public function sync()
	{
		if( entity == null ) return;
		var root = Game.me.dm.getMC();
		var b = entity.hitArea.getBounds( root );
		/*
		if( b.left + 5 > (Lib.STAGE_WIDTH - width - root.x) )
		{
			scaleX = -1;
			//_text.scaleX = -1;
			//_text.x = -120;
		}
		else
		{
			scaleX = 1;
			_text.scaleX = 1;
			_text.x = TEXT_OFFSET_X;
		}
		*/
		x = MLib.fclamp(b.left + 5, -root.x, Lib.STAGE_WIDTH - width - root.x);
		y = MLib.fclamp(b.top - height, -root.y, Lib.STAGE_HEIGHT - height - root.y);
	}
	
	public function resize()
	{
		_text.height = _text.textHeight;
		_bubble.height = _text.height + 20;
	}
	
	public function isVisible()
	{
		return visible;
	}
	
	public function show()
	{
		visible = true;
		alpha = 1.;
	}
	
	public function hide()
	{
		PopupManager.get().freePopup(this);
		visible = false;
	}
	
	function clean()
	{
		if( this.parent != null ) this.parent.removeChild(this);
	}
	
}