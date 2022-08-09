import GameData._ArtefactId ;
import anim.Anim ;
import anim.Transition ;


class Object {
	
	static public var me : Object ;
	public var root : flash.MovieClip ;
	public var mdm : mt.DepthManager ;
	public var omc : ObjectMc ;
	public var sData : String ;
	public var qty : Int ;
	public var mcQty : {>flash.MovieClip, _field : flash.TextField} ;
	public var dataDomain : String ;
	public var anim : anim.Anim ;
	
	
	
	public function new(r : flash.MovieClip) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		
		root = r ;
		mdm = new mt.DepthManager(root) ;
		me = this ;
		
		dataDomain = Reflect.field(flash.Lib._root,"ud") ;
		
		sData = Reflect.field(flash.Lib._root,"d") ;
		var sq = Reflect.field(flash.Lib._root,"q") ;
		if (sq != null)
			qty = Std.parseInt(sq) ;
		
		ObjectMc.DATA_URL = dataDomain+ "/swf/objectMc.swf?v=" + Reflect.field(flash.Lib._root,"vo") ;
		
		init() ;
		
		flash.Lib.current.onEnterFrame = loop ;
	}
	
	
	function init() {
		try {
			data = haxe.Unserializer.run(sData) ;
		} catch(e : Dynamic) {
			trace("invalid data") ; 
			return ;
		}
		
		var f = callback(function(o : Object) {
			o.omc.mc._x = Std.int((48 - 30) / 2) ; 
			o.omc.mc._y = 15 ;
			
			o.setQuantity() ;
			
			/*o.omc.mc._alpha = 0 ;
			o.anim = new anim.Anim(o.omc.mc, Alpha, {speed : 0.04}) ;
			o.anim.setTransition(Cubic(Out)) ;
			o.anim.sleep = Std.random(3) ;
			o.anim.start() ;*/
			
			
		}, this) ;
		omc = new ObjectMc(data._o, mdm, 1, f) ;
		
	}
	
	
	public function setQuantity() {
		if (qty == null && qty <= 0)
			return ;
			
		mcQty = cast omc.mc.attachMovie("mcQty", "mcQty", 2) ;
		mcQty._x = -17 ;
		mcQty._y = 12 ;
		mcQty._field.text = Std.string(qty) ;
		
		if (Std.string(qty).length > 4) {
			mcQty._xscale = 65 ;
			mcQty._yscale = mcQty._xscale ;
			mcQty._x = -3 ;
			mcQty._y = 17 ;
			
		}
			
		
		
	}
	
	static function main() {
		new Object(flash.Lib.current) ;
	}
	
	
	/*public function loop() {
		updateMoves() ;
		
		if (omc != null)
			omc.update() ;
	}
	
	function updateMoves() {
		var list = anim.Anim.onStage.copy() ; 
		for (m in list) m.update() ;

	}
	*/
	
}