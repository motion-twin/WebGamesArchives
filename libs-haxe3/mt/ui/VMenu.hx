package mt.ui;

import flash.events.Event;
import flash.events.MouseEvent;

using mt.Std;
using mt.flash.Lib;
/**
 * Simple vertical menu with smooth scrolling and possible rectangle visibility area
 */
class VMenu<T:DisplayObject> extends Sprite
{
	var content:T;
	public var container:DisplayObject;
	var cache:Bitmap;
	var background:Shape;
	var button:mt.ui.Button<VMenu<T>>;
	//
	public var damping:Float = 0.9;
	public var mouseWheelScrollSpeed : Float = 6.0;
	//
	public var cacheContentOnScroll:Bool = false;
	public var scrollDisabled:Bool = false;
	//margin vertical en haut et bas pour le scroll qui ne coupe pas le contenu
	//useful for content invalidation
	var contentHeight:Float;
	var tween:Null<mt.motion.Tween>;
	var dragging:Bool = false;
	var my:Float;
	public var oy(default, null):Float;
	public var vy(default, null):Float;
	public var margin(default, null):Float;
	
	public function new( p_screen:T, p_visibleRectArea:Rectangle )
	{
		super();
		
		background = new Shape();
		container = content = p_screen;
		
		addChild(background);
		addChild(container);
		
		contentHeight = 0;
		
		setDisplayArea( p_visibleRectArea );
		setBackgroundColor(0, 0.0);
		
		margin = mt.Metrics.px("16dp");
		
		button = new mt.ui.Button(this);
		mouseChildren = true;
		
		button.onSelected = function() {
			if( dragging ) return;
			if( tween != null ) {
				tween.dispose();
				tween = null;
			}
			oy = container.y;
			dragging = true;
			button.dragged = true;
			my = flash.Lib.current.stage.mouseY;
			if( cacheContentOnScroll ) cacheContent();
		}
		
		button.onDisabled = function() {
			dragging = false;
			button.dragged = false;
		}
		
		button.onCanceled = function() {
			dragging = false;
			button.dragged = false;
		}
		
		button.onReleased = function() {
			dragging = false;
			button.dragged = false;
			//use was forcing !
			if( container.y != oy ) {
				vy = 0;
				tween = new mt.motion.Tween();
				tween.to(mt.motion.Duration.fromString("100ms"), container.y = oy).ease(mt.motion.Ease.easeOutQuad).onComplete = function() { tween = null; }
			}
		}
	}

	function cacheContent()
	{
		removeChild(container);
		if( cache == null )
			cache = mt.flash.Lib.flatten(container, true );
		addChild( container = cache );
	}
	
	function uncacheContent()
	{
		if( container == content ) return;
		content.y = cache.y;
		removeChild( cache );
		addChild( container = content );
	}
	
	public function isAtTop()
	{
		return container.y >= margin;
	}
	
	public function scrollTop()
	{
		container.y = margin;
	}
	
	public function scrollBottom()
	{
		if( container.height >= scrollRect.height )
			container.y = margin + mt.MLib.fmin(container.height, scrollRect.height) - container.height;
	}
	
	function handleMouseWheel(event:flash.events.Event)
	{
		var me:flash.events.MouseEvent = cast event;
		vy = mouseWheelScrollSpeed * me.delta;
	}
	
	public function clean()
	{
		if( button != null ) 
		{
			button.clean();
		}
	}
	
	public function dispose()
	{
		if( tween != null )
		{
			tween.dispose();
			tween = null;
		}
		if( button != null )
		{
			button.dispose();
			button = null;
		}
		if( background != null )
		{
			background.detach();
			background = null;
		}
		if( container != null )
		{
			container.detach();
			container = null;
		}
		mt.flash.EventTools.unlisten(flash.Lib.current.stage, MouseEvent.MOUSE_WHEEL, handleMouseWheel);
	}
	
	public function setDisplayArea( p_rect:Rectangle )
	{
		scrollRect = new Rectangle(p_rect.x, p_rect.y, p_rect.width, p_rect.height);
		background.width = scrollRect.width;
		background.height = scrollRect.height;
	}
	
	public function clearBackground()
	{
		background.graphics.clear();
		background.visible = false;
	}
	
	var backgroundColor:Int;
	var backgroundAlpha:Float;
	public function setBackgroundColor( p_color:Int, ?p_alpha:Float=1.0 )
	{
		backgroundColor = p_color;
		backgroundAlpha = p_alpha;
		redrawBackground();
		background.width = scrollRect.width;
		background.height = scrollRect.height;
		background.visible = true;
	}
	
	function redrawBackground()
	{
		background.graphics.clear();
		background.graphics.beginFill(backgroundColor, backgroundAlpha);
		background.graphics.drawRect(0, 0, 4, 4);
		background.graphics.endFill();
		background.cacheAsBitmap = true;
	}
	
	public function update()
	{
		if( parent == null || stage == null ) return;
		
		if( container.height != contentHeight )
		{
			if( container.height >= scrollRect.height && !scrollDisabled) 
			{
				if( button.enabled == false )
					button.enabled = true;
				
				if( !mt.flash.EventTools.isListening( flash.Lib.current.stage, MouseEvent.MOUSE_WHEEL ) )
					mt.flash.EventTools.listen(flash.Lib.current.stage, MouseEvent.MOUSE_WHEEL, handleMouseWheel);
			} 
			else 
			{
				if( button.enabled == true )
					button.enabled = false;
				
				if( mt.flash.EventTools.isListening( flash.Lib.current.stage, MouseEvent.MOUSE_WHEEL ) )
					mt.flash.EventTools.unlisten(flash.Lib.current.stage, MouseEvent.MOUSE_WHEEL, handleMouseWheel);
			}
			contentHeight = container.height;
		}
		
		if( tween != null )
		{
			tween.update();
			return;
		}
		
		if( dragging )
		{
			vy = stage.mouseY - my;
		}
		else
		{
			vy *= damping;
		}
		
		if( mt.MLib.fabs(vy) > 0.5 )
		{
			this.mouseChildren = false;
			var dy = vy;
			var min = mt.MLib.fmin(container.height, scrollRect.height) - container.height;
			min -= margin;
			var max = mt.MLib.fmax(scrollRect.height - container.height, 0);
			max += margin;
			if( (container.y + dy) < min )
			{
				container.y = min + dy / 5;
				oy = min;
			}
			else if( (container.y + dy) > max )
			{
				container.y = max + dy / 5;
				oy = max;
			}
			else
			{
				container.y += dy;
				my += dy;
				oy += dy;
			}
		}
		else if( false == this.mouseChildren )
		{
			this.mouseChildren = true;
			if( cacheContentOnScroll ) uncacheContent();
			vy = 0;
		}
	}
}
