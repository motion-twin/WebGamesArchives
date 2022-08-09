import mt.bumdum.Phys ;
import mt.bumdum.Lib ;
import anim.Anim ;
import anim.Transition ;
import anim.Anim.AnimType ;


typedef HelpBox = {
	var from : flash.MovieClip ;
	var mc : {>flash.MovieClip, _field : flash.TextField} ;
	var anim : anim.Anim ;
}


class Viewer {
	
	static public var viewer : Viewer;
	public var dm : mt.DepthManager ;
	public var jsConnect : Dynamic ;
	
	
	var face : String;
	public var perso : Display;
	public var persoMC : flash.MovieClip;
	public var infos : {>flash.MovieClip, _xp : flash.MovieClip, _grade : flash.MovieClip, _pa : flash.MovieClip, _gold : flash.MovieClip, _token : flash.MovieClip} ;
	public var paMax : Int ;
	public var help : HelpBox ;
	var prexp : String ;
	var xp : String ;
	var txp : String ;
	var pxp : String ;
	public var token : Int ;
	var elem : String ;
	var freeToken : Int ;
	
	
	static var DP_BG = 1 ;
	static var DP_EDITOR_PERSO = 2 ;
	static var DP_INFOS = 3 ;
	static var DP_HELP = 4 ;
	
	 
	static function main(){
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces();
		viewer = new Viewer();
	}
	
	function new(){
		for (d in ["www","beta","data"])
			flash.system.Security.allowDomain(d+".naturalchimie.com") ;
		
		var ctx = new haxe.remoting.Context() ;
		ctx.addObject("_Com", _Com) ;
		jsConnect = haxe.remoting.ExternalConnection.jsConnect("persos_viewer", ctx) ;
		
		init();
	}
		
	function init(){
		var rootFace = Reflect.field(flash.Lib._root, "face");
		face = if (rootFace != null && face == null) rootFace else if (face != null) face else "";
			
		var check = face.split(";") ;
		var ok = true ;
		if (check.length != 27)
			ok = false ;
		else {
			for (e in check) {
				if (e == "" || e == "null" || Std.string(Std.parseInt(e)) != e) {
					ok = false ;
					break ;
				}
			}
		}
		

		dm = new mt.DepthManager(flash.Lib.current) ;
		persoMC = dm.empty(DP_EDITOR_PERSO);
		persoMC._y = 15;
		
		perso = new Display(persoMC);
			
		var doCloud = Reflect.field(flash.Lib._root, "c") == "1" ;
		if (doCloud)
			persoMC._visible = false ;
		if (!ok) {
			face = "0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;10" ;
			perso.extraTypeView = 2 ;
		}
			
		perso.initPerso(0,0,face, if (doCloud) callback(function(v : Viewer) { v.clouds() ; haxe.Timer.delay(callback(function(v : Viewer) {v.persoMC._visible = true ;}, v), 100) ; }, this) else null);
			
		infos = cast dm.attach("userBox", DP_INFOS) ;
		infos._gold._field.text = Reflect.field(flash.Lib._root, "gold") ;
				
		token = Std.parseInt(Reflect.field(flash.Lib._root, "token")) ;
		freeToken = Std.parseInt(Reflect.field(flash.Lib._root, "ftoken")) ;
				
		infos._token._field.text = Std.string(token + freeToken) ;
			
		var other = Std.parseInt(Reflect.field(flash.Lib._root, "other")) == 1 ;
			
		 prexp = Reflect.field(flash.Lib._root, "pxp") ;
		 var sxp  = Reflect.field(flash.Lib._root, "xp").split(";") ;
		elem = Reflect.field(flash.Lib._root, "elem") ;
		 pxp = sxp[0] ;
		 txp = sxp[2] ;
		 xp = sxp[1] ;
				
		if (other) {
			infos._xp._field.text = "?" ;
			infos._xp.smc.gotoAndStop(1) ;
		} else {
			infos._xp._field.text = pxp ;
			infos._xp.smc.gotoAndStop(Std.int(Math.max(1, Std.parseInt(pxp)))) ;
		}
			
		var pa = Reflect.field(flash.Lib._root, "pa") ;
		paMax = Reflect.field(flash.Lib._root, "paMax") ;
		if (other) {
			infos._pa._field.text = "?" ;
			infos._pa.smc.gotoAndStop(1) ;
		} else {
			infos._pa._field.text = pa ;
			infos._pa.smc.gotoAndStop(Std.int(Math.max(1, pa / paMax * 100))) ;
		}
			
		if (other)
			infos._grade._field.text = "?" ;
		else 
			infos._grade._field.text = Reflect.field(flash.Lib._root, "grade") ;
		
		flash.Lib.current.onEnterFrame = this.update ;
			
			
		infos._gold.onRollOver = callback(infoOver, infos._gold._bg, null, 0) ;
		infos._gold.onRollOut = callback(infoOut, infos._gold._bg, null) ;
		infos._gold.onReleaseOutside = infos._gold.onRollOut ;
		//infos._gold.onRelease = callback(showHelp, infos._gold._bg, 0) ;
		
		infos._token.onRollOver = callback(infoOver, infos._token._bg, 0x6699CC, 1) ;
		infos._token.onRollOut = callback(infoOut, infos._token._bg, 0x6699CC) ;
		infos._token.onReleaseOutside = infos._token.onRollOut ;
		//infos._token.onRelease = callback(showHelp, infos._token._bg, 1) ;
		
		if (other) {
			/*infos._xp._visible = false ;
			infos._grade._visible = false ;
			infos._pa._visible = false ;*/
			return ;
		}
		
		infos._xp.onRollOver = callback(infoOver, infos._xp, 0x69DCFF, 2) ;
		infos._xp.onRollOut = callback(infoOut, infos._xp, 0x69DCFF) ;
		infos._xp.onReleaseOutside = infos._xp.onRollOut ;
		//infos._xp.onRelease = callback(showHelp, infos._xp, 2) ;
		
		infos._grade.onRollOver = callback(infoOver, infos._grade, 0xC0FF42, 3) ;
		infos._grade.onRollOut = callback(infoOut, infos._grade, 0xC0FF42) ;
		infos._grade.onReleaseOutside = infos._grade.onRollOut ;
		//infos._grade.onRelease = callback(showHelp, infos._grade, 3) ;
		
		infos._pa.onRollOver = callback(infoOver, infos._pa, 0xFF2B00, 4) ;
		infos._pa.onRollOut = callback(infoOut, infos._pa, 0xFF2B00) ;
		infos._pa.onReleaseOutside = infos._pa.onRollOut ;
		//infos._pa.onRelease = callback(showHelp, infos._pa, 4) ;
	}
	
	
	function update() {
		updateMoves() ;
		
		perso.update() ;
	}
	
	
	function updateMoves() {		
		var list = anim.Anim.onStage.copy() ; 
		for (m in list) m.update() ;
			
		
	}
	
	public function clouds() {
		var nb = 8 ;
		var x = 100 ;
		var height = 270 / nb ;
		
		for(j in 0...nb) {
			var y = height * j + 15 ;			
			for (i in 0...(2 + if (j > nb / 2 ) 1 else 0)) {
				var mc = dm.attach("cloud", 2) ;
				mc.gotoAndStop(Std.random(4) + 1) ;
				
				mc._xscale = 400 ;
				mc._yscale = mc._xscale ;
				
				var sp = new Phys(mc) ;
				var a = Math.random() * 6.28 ;
				var ca = Math.cos(a) ;
				var sa = Math.sin(a) ;
				
				var speed = 2 + Math.random() * 4 ;
				sp.x = x + ca * 15 ;
				sp.y = y + sa * 15 ;
				sp.vx = ca * speed ;
				sp.vy = sa * speed ;
				sp.weight = -0.3 - Math.random() * 0.35 ;
				sp.frict = 0.98 ;
				
				sp.vsc = 0.9 ;
				sp.vr = Math.random() * 10 ;
				sp.fadeType = 6 ;
				sp.timer = 20 + Math.random() * 20 ;
				Filt.blur(sp.root, 2, 2) ;
			}
		}
	}
	
	
	function infoOver(mc : flash.MovieClip, ?col = 0xFFCC00, ?t : Int) {
		//Col.setPercentColor(mc, 20, col) ;
		mc.filters = [] ;
		Filt.glow(mc, 4, 3, col) ;
		
		showHelp(mc, t) ;
		
	}
	
	
	function infoOut(mc : flash.MovieClip, ?col = 0xFFCC00) {
		if (help != null && help.from == mc)
			helpOut() ;
		
		//Col.setPercentColor(mc, 0, col) ;
		mc.filters = [] ;
	}
	
	
	function showHelp(mc : flash.MovieClip, t : Int) {
		if (help != null)
			helpOut() ;
		
		help = {
			from : mc,
			mc : cast dm.attach("help", DP_HELP),
			anim : null
		}
				
		help.mc.gotoAndStop(t + 1) ;
		
		switch(t) {
			case 0 : 
				help.mc._x = 52 ;
				help.mc._y = 25 ;
			case 1 : //token
				help.mc._x = 160;
				help.mc._y = 22 ;
				help.mc._free.text = Std.string(freeToken) + " x" ;
				help.mc._token.text = Std.string(token) + " x" ;
			case 2 : //xp
				help.mc._x = 30 ;
				help.mc._y = 254 ;
				help.mc._xfield.text = prexp + " " + pxp + "%\n[" + xp + "/" + txp + "]" ;
			case 3 : 
				help.mc._x = 93 ;
				help.mc._y = 273 ;
				help.mc._field.text = elem ;
			case 4 : 
				help.mc._x = 163 ;
				help.mc._y = 260 ;
		}
		
		//help.mc._xscale = help.mc._yscale = 0 ;
		help.mc._alpha = 0 ;
		help.mc._field._visible = true ;
		
		/*help.mc._x = flash.Lib.current._xmouse ;
		help.mc._y = flash.Lib.current._ymouse ;*/
		
		//help.anim = new anim.Anim(help.mc, Scale, Elastic(-1, 0.7), {x : 100, y : 100, speed : 0.04}) ;
		help.anim = new anim.Anim(help.mc, Alpha(1), Quart(-1), {x : 100, y : 100, speed : 0.04}) ;
		help.anim.sleep = 5 ;
		//help.anim.addOnCoef(0.6, callback(function(v : Viewer) {v.help.mc._field._visible = true ; }, this)) ;
		help.anim.start() ;
	}
	
	function helpOut() {
		if (help == null)
			return ;
		if (help.anim != null)
			help.anim.kill() ;
		help.mc.removeMovieClip() ;
		help = null ;
	}
}

//### JS CALLS
class _Com {
	public static function _addInfos(g : String, t : String, p : String) : Bool {		
		var vv = Viewer.viewer ;
		var gold = Std.parseInt(g) ;
		if (gold > 0)
			vv.infos._gold._field.text = Std.parseInt(vv.infos._gold._field.text) + gold ;
		var ntoken = Std.parseInt(t) ;
		if (ntoken > 0)
			vv.infos._token._field.text = Std.parseInt(vv.infos._token._field.text) + ntoken ;
			vv.token += ntoken ;
		var pa = Std.parseInt(p) ;
		if (pa >= 0) {
			vv.infos._pa._field.text = pa ;
			vv.infos._pa.smc.gotoAndStop(Std.int(Math.max(1, pa / vv.paMax * 100))) ;
		}		
		return true ;
	}
	
	public static function _transform(s : String) : Bool {
		var vv = Viewer.viewer ;
		var p = vv.persoMC ;
		vv.clouds() ;
		p._visible = false ;
		var showNow = true ;
		vv.perso.updateSprites() ;
		var face = vv.perso.fstr ;
		
		if (face != null) {
			var f = face.split(";") ;
			var as = s.split(",") ;
			for(a in as) {
				var values = a.split(":") ;
				f[Std.parseInt(values[0])] = values[1] ; 
			}
			
			vv.perso.updatePerso(f.join(";")) ;
			if (vv.perso.checkMiscUse()) {
				vv.perso.reinit(callback(function(x : flash.MovieClip) { x._visible = true ;}, p)) ;
				showNow = false ;
			}
		}
		
		if (showNow)
			p._visible = true ;
		
		return true ;
	}
}
