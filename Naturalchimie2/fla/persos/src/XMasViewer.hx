import mt.bumdum.Phys ;
import mt.bumdum.Lib ;
import anim.Transition ;
import anim.Anim.AnimType ;



class XMasViewer extends DefaultLoader {
	
	static public var me : XMasViewer ;
	public var root : flash.MovieClip ;
	public var mdm : mt.DepthManager ;
	public var pdm : mt.DepthManager ;
	public var bg : flash.MovieClip ;
	public var pmc : flash.MovieClip ;
	public var perso : Display;
	public var persoMC : flash.MovieClip ;
	
	public var pnj : Pnj ;
	public var pnjRatio : Int ;
	public var pnjDx : Int ;
	public var pnjDy : Int ;
	
	public var dPnj : {pnj : String, frame : String} ;
	public var face : String ;
	public var sBg : String ;
	public var bgInfos : {id : String, x : Int, y : Int} ;
	public var avScale : Float ;
	public var seed : mt.Rand ;
	
	static var PSCALES = [125, 125, 150, 150, 150, 150, 100, 100, 100, 100, 100, 75] ;
	
	static var SIZE = 180 ;
	static public var DP_BG = 1 ;
	static public var DP_PERSOS = 2 ;
	static public var DP_PNJ = 0 ;
	static public var DP_AVATAR = 1 ;
	static public var DP_PNJ_ARM = 2 ;
	
	
	public function new(r : flash.MovieClip) {
		super(r) ;
		for (d in ["www","beta","data"])
			flash.system.Security.allowDomain(d+".naturalchimie.com") ;
		
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		
		root = r ;
		mdm = new mt.DepthManager(root) ;
		me = this ;
		
		
		dataDomain = Reflect.field(flash.Lib._root,"dom") ;
		face = Reflect.field(flash.Lib._root,"f") ;
		sBg = Reflect.field(flash.Lib._root,"b") ;
		sBg = "apvos:-240:-160,0" ;
		
		
		var sd= 0 ;
		for (f in face.split(";")) {
			sd += Std.parseInt(f) ;
		}
		seed = new mt.Rand(sd) ;
		
		
		
		var frames = ["nowel", "nowelsad", "nowelhappy"] ;
		dPnj = {pnj : "jzpouma", frame : frames[seed.random(frames.length)]} ;
		
		pnjDx = 10 ;
		pnjDy = 1 ;
		pnjRatio = 55 ;
		
		pmc = mdm.empty(DP_PERSOS) ;
		pdm = new mt.DepthManager(pmc) ;
		
		persoMC = pdm.empty(DP_AVATAR) ;
		avScale = PSCALES[Std.parseInt(face.split(";")[0])] ;
		persoMC._xscale = persoMC._yscale  = avScale;
		//persoMC._y = 15;
		perso = new Display(persoMC) ;
		perso.extraTypeView = 1 ; //no bg
		perso.initPerso(0,0,face, initAvatar) ;

		
		
		pmc.filters = [new flash.filters.GlowFilter(0xC6FCFF,0.9,1.3,1.3,3, 2, false, false), new flash.filters.GlowFilter(0xC6FCFF,0.6,6.4,6.4,1, 1, false, false)];
		
		
		Pnj.DATA_URL = dataDomain+ "/swf/pnj__.swf?v=" + Reflect.field(flash.Lib._root,"vo") ;
		
		flash.Lib.current.onEnterFrame = loop ;
		init() ;
	}
	
	
	function initAvatar() {
		var cx = 50 ;
		var cy = 150 ;
		
		persoMC._x = cx ;
		persoMC._y = cy ;
		perso.MCalchemist._x =  -perso.cadre.x ;
		perso.MCalchemist._y =  -perso.cadre.y ;
		
		var ff = Std.parseInt(face.split(";")[0]) ;
		
		var cm = new flash.filters.ColorMatrixFilter( [0.678610265254974,0.389040946960449,0.0523488000035286,0,12.5399971008301,0.19701024889946,0.870640933513641,0.0523488000035286,0,12.5399971008301,0.19701024889946,0.389040946960449,0.53394877910614,0,12.5399971008301,0,0,0,1,0] );		
		perso.MCalchemist._alchemist._p0.filters = if (ff > 7) [] else [cm];
		
	}
	
	function init() {
		initBg() ;
		pnj = new Pnj(dPnj.pnj, pdm, DP_PNJ, this,
					callback(function(p : XMasViewer) {
							p.pnj.setFrame(p.dPnj.frame) ; 
							p.pnj.mc._x =  SIZE + p.pnjDx  ; 
							p.pnj.mc._y = SIZE + p.pnjDy;
							p.pnj.mc._alpha = 100 ;
							if (p.pnjRatio != 100) {
								p.pnj.mc._xscale = p.pnjRatio ;
								p.pnj.mc._yscale = p.pnjRatio ;
							}
						}, this)) ;
	}
	
	
	function initBg() {
		bg = mdm.empty(DP_BG) ;
		
		var tbg = sBg.split(":") ;
		bgInfos = {id : tbg[0], x : Std.parseInt(tbg[1]), y : Std.parseInt(tbg[2])} ;
		//if (bgCoords != null && bgCoords.length >2)
		//	Pnj.GLOW_TYPE = Std.parseInt(bgCoords[2]) ;
		
		bg._x = bgInfos.x + seed.random(160) ;
		bg._y = bgInfos.y + seed.random(30) ;
		
		var mcl = new flash.MovieClipLoader() ;
		var me = this ;
		mcl.onLoadError = function(_,err) {
			me.reportError(err) ;
		}
		mcl.onLoadInit = function(_) {
			me.setBlur(me.bg) ;
		}
		
		mcl.loadClip(dataDomain + "/img/bg/" + bgInfos.id + ".jpg", bg) ;
	}
	
	
	public function setGlow(mc : flash.MovieClip) {
		Filt.glow(mc, 5, 1, 0xFFFFFF) ;
	}
	public function setBlur(mc : flash.MovieClip) {
		mc.filters = [new flash.filters.BlurFilter(1.2, 1.2, 100)];	
	}	
	

	
	static function main() {
		new XMasViewer(flash.Lib.current) ;
	}
	
	
	public function loop() {
		updateMoves() ;
		
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