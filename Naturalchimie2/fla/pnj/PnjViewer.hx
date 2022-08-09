import GameData._ArtefactId ;
import GameData._ProductData ;
import anim.Anim ;
import anim.Transition ;
import mt.bumdum.Lib ;

class PnjViewer extends DefaultLoader {
	
	static public var me : PnjViewer ;
	public var root : flash.MovieClip ;
	public var mdm : mt.DepthManager ;
	public var sData : String ;
	public var data : {_pnj : String, _frame : String} ;
	public var pnj : Pnj ;
	public var pnjRatio : Int ;
	public var pnjDx : Int ;
	public var pnjDy : Int ;
	public var curProduct : _ProductData ;
	public var omc : ObjectMc ;
	public var qty : Int ;
	public var shmc : ShopMc ;
	public var mcQty : {>flash.MovieClip, _field : flash.TextField} ;
	public var anim : anim.Anim ;
	public var jsConnect : Dynamic ;
	public var decor : flash.MovieClip ;
		
	
	static public var DP_PNJ = 1 ;
	static public var DP_DECOR = 2 ;
	static public var DP_OBJECT = 3 ;
	
	
	public function new(r : flash.MovieClip) {
		super(r) ;
		for (d in ["www","beta","data"])
			flash.system.Security.allowDomain(d+".naturalchimie.com") ;
		
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		
		root = r ;
		mdm = new mt.DepthManager(root) ;
		me = this ;
		
		var ctx = new haxe.remoting.Context() ;
		ctx.addObject("_Com", _Com) ;
		jsConnect = haxe.remoting.ExternalConnection.jsConnect("pnjViewer", ctx) ;
		
		dataDomain = Reflect.field(flash.Lib._root,"ud") ;
		
		pnjDx = Std.parseInt(Reflect.field(flash.Lib._root,"dx")) ;
		pnjDy = Std.parseInt(Reflect.field(flash.Lib._root,"dy")) ;
		if (pnjDx == null)
			pnjDx = 0 ;
		if (pnjDy == null)
			pnjDy = 0 ;
		pnjRatio = Std.parseInt(Reflect.field(flash.Lib._root,"r")) ;
		if (pnjRatio == null)
			pnjRatio = 100 ;
		
		sData = Reflect.field(flash.Lib._root,"d") ;
		var sq = Reflect.field(flash.Lib._root,"q") ;
		if (sq != null)
			qty = Std.parseInt(sq) ;
		
		//ObjectMc.DATA_URL = dataDomain+ "/swf/objectMc.swf?v=" + Reflect.field(flash.Lib._root,"vo") ;
		ShopMc.DATA_URL = dataDomain+ "/swf/shopMc.swf?v=" + Reflect.field(flash.Lib._root,"vo") ;		
		Pnj.DATA_URL = dataDomain+ "/swf/pnj__.swf?v=" + Reflect.field(flash.Lib._root,"vo") ;
		
		ObjectMc.initMc(dataDomain+ "/swf/objectMc.swf?v=" + Reflect.field(flash.Lib._root,"vo"), mdm, 0, callback(function() { PnjViewer.me.init() ;})) ; 
		
		//init() ;
		
		
		var dec = Reflect.field(flash.Lib._root,"dec") ;
		if (dec != null) {
			decor = mdm.attach("mg", DP_DECOR) ;
			decor.gotoAndStop(dec) ;
			decor._x = 20 ;
			decor._y = 300-decor._height ;
		}
		var o = Reflect.field(flash.Lib._root,"o") ;
		if (o != null) 
			setProduct(o) ;

		flash.Lib.current.onEnterFrame = loop ;
	}
	
	
	function init() {
		try {
			data = haxe.Unserializer.run(sData) ;
		} catch(e : Dynamic) {
			trace("invalid data") ; 
			return ;
		}
		
		pnj = new Pnj(data._pnj, mdm, DP_PNJ, this,
					callback(function(p : PnjViewer) {
							p.pnj.setFrame(p.data._frame) ; 
							p.pnj.mc._x = 200 + p.pnjDx  ; 
							p.pnj.mc._y = 300 + p.pnjDy;
							p.pnj.mc._alpha = 100 ;
							if (p.pnjRatio != 100) {
								p.pnj.mc._xscale = p.pnjRatio ;
								p.pnj.mc._yscale = p.pnjRatio ;
							}
						}, this)) ;
	}
	
	
	public function setObject(o : _ArtefactId) {
		if (omc != null)
			omc.kill() ;
		
		omc = new ObjectMc(o, mdm, DP_OBJECT, null, null, null, null, 150) ;
		omc.mc._x = 75 ;
		omc.mc._y = 200 ;
		//omc.mc._xscale = p.omc.mc._yscale = 150 ;
		setGlow(omc.mc) ;
		setObjectQuantity() ;
	}
	
	
	public function setProductObj(o : _ProductData) {
		if (shmc != null)
			shmc.kill() ;
		
		var f = callback(function(p : PnjViewer) {
			p.shmc.mc._x = 70 ; 
			p.shmc.mc._y =180 ;
			p.shmc.mc._xscale = p.shmc.mc._yscale = 150 ;
			p.setGlow(p.shmc.mc) ;
			
			
		}, this) ;
		shmc = new ShopMc(o, mdm, DP_OBJECT, f) ;
	}
	
	
	public function setGlow(mc : flash.MovieClip) {
		Filt.glow(mc, 5, 1, 0xFFFFFF) ;
	}
	
	
	public function setFrame(f : String) {
		if (pnj == null)
			return ;
		
		if (omc != null)
			omc.kill() ;
		if (shmc != null)
			shmc.kill() ;
		
		if (f == "hide") {
			pnj.mc._visible = false ;
		} else {
			pnj.setFrame(f) ;
			pnj.mc._visible = true ;
		}
	}
	
	
	public function setProduct(sp : String) {
		var pData : _ProductData = haxe.Unserializer.run(sp) ;
		
		if (Type.enumEq(pData, curProduct))
			return ;
		
		if (omc != null)
			omc.kill() ;
		if (shmc != null)
			shmc.kill() ;
		
		curProduct = pData ;
		
		if (pData == null)
			return ;
		
		switch(pData) {
			case _Art(o, q) :
				qty = q ;
				setObject(o) ;
			default : 
				setProductObj(pData) ;
		}
	}
	
	
	public function setObjectQuantity() {
		if (qty == null || qty <= 1)
			return ;
			
		mcQty = cast omc.mc.attachMovie("mcQty", "mcQty", 2) ;
		mcQty._x = -17 ;
		mcQty._y = 12 ;
		mcQty._field.text = Std.string(qty) ;
		
		//if (Std.string(qty).length > 4) {
			mcQty._xscale = 100 ;
			mcQty._yscale = mcQty._xscale ;
			mcQty._x = -5 ;
			mcQty._y = 20;
			
		//}
	}
	
	static function main() {
		new PnjViewer(flash.Lib.current) ;
	}
	
	
	public function loop() {
		updateMoves() ;
		
		if (omc != null)
			omc.update() ;
	}
	
	
	function updateMoves() {
		var list = anim.Anim.onStage.copy() ; 
		for (m in list) m.update() ;
	}
	
	override public function initLoading(?c : Int, ?x : Float, ?y : Float) {
		super.initLoading(c) ;
				
		loading = mdm.attach("loading", 4) ;
		loading.smc.smc.gotoAndStop(Std.random(15) + 1) ;
		loading._x = 200 / 2 ; 
		loading._y = 300 / 2 ; 
	}
	
	

	
}


//### JS CALLS
class _Com {
	
	public static function _sFrame(f : String) {
		if (PnjViewer.me.pnj == null)
			return  ;
		PnjViewer.me.setFrame(f) ;
	}
	
	
	public static function _sObj(o : String) {
		if (PnjViewer.me.pnj == null)
			return  ;
		PnjViewer.me.setProduct(o) ;
		
	}
	
	
	
}
