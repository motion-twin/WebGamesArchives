package mt.flash;
import flash.external.ExternalInterface;
/**
 * Classe utilitaire pour capturer le scroll du navigateur si le flash a le focus
 */
class MouseWheelTrap 
{ 
	static var mouseWheelTrapped :Bool = false;
	public static function setup()
	{
		mt.flash.EventTools.listen(flash.Lib.current.stage, flash.events.MouseEvent.MOUSE_MOVE, onMove);
		mt.flash.EventTools.listen(flash.Lib.current.stage, flash.events.Event.MOUSE_LEAVE, onLeave);
	}

	public static function captureAllEvents(){
		if (!ExternalInterface.available)
			return;

		ExternalInterface.call("eval","
			$(window).bind('mousewheel.flashtrap',function(e){
				e.preventDefault();
				try {
					_tid.getFlashObject().mouseWheel( e.originalEvent.wheelDelta/40 );
				}catch(e){}
			});

			if( window.addEventListener ){
				window.addEventListener('DOMMouseScroll',function(e){
					e.preventDefault();
				});
			}
		");

		ExternalInterface.addCallback("mouseWheel",function(delta){
			var e = new flash.events.MouseEvent(flash.events.MouseEvent.MOUSE_WHEEL);
			e.delta = delta;
			flash.Lib.current.stage.dispatchEvent(e);
		});
	}
	
	static function onMove(e) 
	{
		allowBrowserScroll(false);
	}
	
	static function onLeave(e)
	{
		allowBrowserScroll(true);
	}
	
	static function allowBrowserScroll(allow:Bool) 
	{
		createMouseWheelTrap();
		if (ExternalInterface.available)
			ExternalInterface.call("allowBrowserScroll", allow);
	}
	
	static function createMouseWheelTrap()
	{
		if (mouseWheelTrapped) 	return;
		
		if(ExternalInterface.available)
			ExternalInterface.call("eval", js);
		mouseWheelTrapped = true; 
	}
	
	static var js = "	function allowBrowserScroll(value) {  " +
					"		if( false == value ) 	$(window).scroll(stopWheel);"+
					"		else 					$(window).unbind('scroll');"+
					"	}"+
					"	function stopWheel(e) { " +
					"		if(!e) e = window.event; "+
					"		if(e.preventDefault) e.preventDefault(); "+
					"		e.returnValue = false;" +
					"		$(window).scrollTop(0);"+
					"	}  ";
}
