package mt.fx;

class VaporMc
{
	var parent:flash.display.DisplayObjectContainer;
	var inst:String;
	
	public function new(par,str) {
		parent = par;
		inst = str;
	}
	
	public function get() {
		return cast(parent).str;
	}
	
}
