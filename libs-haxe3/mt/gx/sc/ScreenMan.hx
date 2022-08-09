package mt.gx.sc;

import flash.display.DisplayObjectContainer;
using  mt.gx.Ex;
	
class ScreenMan {
	static var me : ScreenMan;
		
	public var rep : Array<Screen>;
	var cur : Null<Int>;
	public var parent : DOC;
	
	public function new(?p:DOC) {
		rep = [];
		cur = null;
		parent = p;
		me = this;
	}
	
	public inline function add(sc:Screen) {
		rep.pushBack(sc); 
		var idx = rep.length - 1;
		sc.idx = idx;
		return idx;
	}
	
	public inline function next() {
		set( cur + 1);
	}
	
	public function delete( idx : Int ) {
		var s = rep[idx];
		if ( s.isStarted ) s.kill();
		s.detach();
	}
	
	public function set(n:Int) {
		n = mt.gx.MathEx.posMod( n , rep.length );
		
		var i = 0;
		for ( s in rep){
			if (i == n){
				if ( !s.isStarted ){
					s.init();
					parent.addChild(s);
					s.toFront();
				}
			}
			else{
				if ( s.isStarted ) s.kill();
				s.detach();
			}
			i++;
		}
		cur = n;
	}
	
	public function update() {
		if ( cur != null) rep[cur].update();
	}
}
