
package mt.flash;

/*
class ProfilerMacro {
	public macro static function build() : Expr
	{
		haxe.macro.Context.onGenerate( function( p_aTypes )
		{
			for ( type in p_aTypes )
			{
				trace("Type generated :" + type);
			}
		} );
		
		return  macro { var t = 'toto'; };
	}
}
*/
import flash.events.Event;
import flash.events.MouseEvent;
import mt.flash.Lib;
//@:build(ProfilerMacro.build())
class Profiler extends Sprite 
{
	public static var current(get, null):Profiler;
	inline static function get_current() {
		if ( current == null ) current = new Profiler();
		return current;
	}
	
	var watchList:Array<mt.signal.Bindable<Dynamic>>;
	var menu:Sprite;
	var panel:Sprite;
	
	function new()
	{
		super();
		watchList = [];
		initMenu();
		initProfiler();	
	}
	
	public function showProfiler()
	{
		panel.visible = true;
	}
	
	public function hideProfiler()
	{
		panel.visible = false;
	}
	
	function initMenu()
	{
		menu = new Sprite();
		var label = createTF("Watcher", 16, 0xFFFFFF, 0);
		menu.addChild(label);
		menu.doubleClickEnabled = true;
		
		
		var isClick = true;
		function onmove(e) {
			isClick = false;
		}
		
		menu.addEventListener(MouseEvent.MOUSE_DOWN, function(e) {
			this.startDrag(false);
			isClick = true;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onmove);
		} );
		
		menu.addEventListener(MouseEvent.MOUSE_UP, function(e) { 
			this.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onmove);
			if( isClick ) {
				if ( panel.visible ) hideProfiler() 
				else showProfiler(); 
			}
		} );
		addChild(menu);
	}
	
	function initProfiler()
	{
		panel = new Sprite();
		panel.y = menu.height;
		addChild( panel );
	}
	
	public function watch( p_name:String, p_var:mt.signal.Bindable<Dynamic> )
	{
		var profileLine = createTF(p_name, 10);
		profileLine.y = Std.int(panel.height);
		panel.addChild(profileLine);
		p_var.onChange.bind( function( p_value ) {
			profileLine.text = p_name + ":  " + p_value;
		} );
		//
		watchList.push( p_var );
	}
	
	function createTF(p_text:String, p_size:Int=12, p_color:Int=0x000000, p_bgColor:Int=0xCCCCCC)
	{
		var label = new flash.text.TextField();
		
		label.selectable = false;
		label.background = true;
		label.backgroundColor = p_bgColor;
		label.autoSize = flash.text.TextFieldAutoSize.LEFT;
		
		var tf = label.getTextFormat();
		tf.font = "_sans";
		tf.color = p_color;
		tf.size = p_size;
		label.defaultTextFormat = tf;
		label.setTextFormat(tf);
		
		label.text = p_text;
		return label;
	}

}	
