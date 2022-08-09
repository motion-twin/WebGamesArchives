package mt.gx.sc;
import flash.display.DisplayObjectContainer;
using mt.gx.Ex;

class Screen extends flash.display.Sprite{
	
	var screenName : flash.text.TextField;

	public var idx = -1;
	public var isStarted = false;
	
	public function new(){
		super();
		screenName = mt.gx.as.Lib.getTf( getName() );
		visible = false;
	}

	public function getName() : String {
		return Std.string(Type.getClass(this));
	}
	
	/** Dont forget to call me */
	public function init(){
		isStarted = true;
		visible = true;
		
		#if !master
		addChild(screenName);
		#end
	}
	
	
	/** returns true whether you shoould continue the kill */
	public function kill(){
		if ( !isStarted ) return false;
		
		isStarted = false;
		visible = false;
		return true;
	}
	
	public function update(){
		if (!isStarted) return;
		screenName.toFront();
	}
}