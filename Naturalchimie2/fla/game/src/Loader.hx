import GameData.CheckData ;
import GameData.StartData ;
import GameData.SaveResult ;
import anim.Transition ;
import anim.Anim.AnimType ;
import mt.bumdum.Phys ;
import mt.bumdum.Lib;
import anim.TransitionFunctions ;



class TextFr {
	public static var RLD = "Merci de relancer le jeu.";
	public static var ERR_START = "Une erreur a eu lieu lors de l'initialisation de la partie. " + RLD ;
	public static var ERR_SVR = "Impossible de contacter le serveur de jeu. Votre partie n'est pas perdue." ;
}


class Loader implements Load {

	public static var TEXT = TextFr ;
	static var FFA: Array<Dynamic>;
	
	public var game : Game ;
	public var count : Int ;
	public var n : Int ;
	public var s : String ;
	public var k : String ;
	public var locked : Bool ;
	public var loading : flash.MovieClip ;
	
	//public var clickToStart : flash.MovieClip ;
	public var mcCircle : flash.MovieClip ;
	public var mcError : {>flash.MovieClip, _field : flash.TextField} ;
	public var hidePanel : {>flash.MovieClip, _field : flash.TextField, _csc : {>flash.MovieClip, _field : flash.TextField}, _band : flash.MovieClip} ;
	public var pStart : flash.MovieClip ;
	var mc : flash.MovieClip ;
	var waitingResponse : Bool ;
	public var domain : String ;
	public var dataDomain : String ;
	var gameOverDone : Bool ;
	var retry : Dynamic ;
	var rcode : Int ;
	var step : Int ;
	var timer : Float ;
	var psp : Phys ;
	var va:Float ;
	var ca:Float ;
	var trg : {x : Float, y : Float} ;
	
	var an : anim.Anim ;
	var xmouse : Float ;
	var ymouse : Float ;
	
	
	
	static var DOMAIN_K = "8tleTrleno0u1i96Riu7riEQLad8Ediugu3z2Fc" ;
	static var DOMAINS = [
			"uVZP%14%18%1CR%60j%12CDjfYDrD%40%5DC%5CG%0F%14rMC", //http://dev.naturalchimie2.com
			"liV%5E%1A%01%18DAr2RLQkaJI%7DOAYGP%0C%5EU%7C", //http://www.naturalchimie.com
			"uVZP%14%18%1CRdh%5D%03K%7Fg%5EW%7FKK%5CGXKX%14rMC", //http://data.naturalchimie.com
			"uVZP%14%18%1CT%60h%5D%03K%7Fg%5EW%7FKK%5CGXKX%14rMC" //http://beta.naturalchimie.com
		] ;
	
	
	function new( root : flash.MovieClip ) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;

		haxe.Serializer.USE_ENUM_INDEX = true ;
		
		FFA = new Array() ;
		var rnd = Std.random(1000) ;
		for (i in 0...rnd)
			FFA.push([]) ;
		
		mc = root ;
		locked = false ;
		waitingResponse = false ;
		gameOverDone = false ;
		step = 0 ;
		timer = 0 ;
		trg = {x : 150.0, y : 200.0} ;
		
		n = Reflect.field(flash.Lib._root,"n") ;
		s = Reflect.field(flash.Lib._root,"sid") ;
		k = Reflect.field(flash.Lib._root,"k") ;
		domain = Reflect.field(flash.Lib._root,"u") ;
		dataDomain = Reflect.field(flash.Lib._root,"ud") ;
		if (!checkDomain(domain) || !checkDomain(dataDomain))
			return ;

		secure.Codec.displayError = traceError ;

		game = new Game(root, this) ;
		game.uid = Reflect.field(flash.Lib._root,"ui") ;
		game.loadData() ;
		flash.Lib.current.onEnterFrame = game.loop ;
	}


	static public function traceError(str) {
		//nothing to do
	}
	
	
	static function main() {
		new Loader(flash.Lib.current) ;
	}
	
	
	public function lock() {
		locked = true ;
	}
	
	public function unlock() {
		locked = false ;
	}
	
	public function isLocked() : Bool {
		return locked ;
	}
	
	public function isLoading() : Bool {
		return count > 0 ;
	}
	
	public function done() {
		if( --count > 0 )
			return null ;
		loading.removeMovieClip() ;
		return count == 0 ;
	}

	
	public function initLoading(?c : Int, ?x : Float, ?y : Float) {
		if (loading != null)
			loading.removeMovieClip() ;
		if (c != null)
			count = c ;
		
		if (hidePanel == null) {
			hidePanel = cast Game.me.mdm.attach("clickToStart", Const.DP_BLACK_LOADING) ;
			hidePanel.gotoAndStop(2) ;
			
			pStart = Game.me.mdm.attach("pStart", Const.DP_PART) ;
			pStart._x = 99 ;
			pStart._y = 130 ;
			
			
			/*var me = this ;
			hidePanel.onPress = function() {me.game.sound.play("clic") ; } ;*/
			hidePanel.onPress = startPlaying ;
		}
		
		loading = Game.me.mdm.attach("loading", Const.DP_LOADING) ;
		loading.smc.smc.gotoAndStop(Std.random(15) + 1) ;
		loading._x = if (x != null) x else Const.WIDTH / 2 ;
		loading._y = if (y != null) y else Const.HEIGHT / 2 ;
		loading._xscale = loading._yscale = 40 ;
		loading._alpha = 80 ;
		
	}
	
	
	function startPlaying() {
		if (count > 0 || waitingResponse)
			return ;
		waitingResponse = true ;
		
		xmouse = game.root._xmouse ;
		ymouse = game.root._ymouse ;
		
		var a= new anim.Anim(cast hidePanel._field, Alpha(-1), Quint(-1), {x : 0, speed : 0.05}) ;
		a.start() ;
		game.sound.play("clic") ;
		
		initLoading(1, 100, 195) ;
		
		
		var dd = 7 ;
		var sc = 80 ;
		var speed = 0.4 ;
		//pStart._y -= dd ;
		//a = new anim.Anim(pStart, Translation, Elastic(-1, 0.6), {x : pStart._x, y : pStart._y + dd, speed : 0.035}) ;
	//	a.start() ;
		var a = new anim.Anim(pStart, Translation, Quint(-1), {x : pStart._x, y : pStart._y + dd, speed : speed}) ;
		a.start() ;
		a = new anim.Anim(pStart, Scale, Quint(-1), {x : sc, y : sc, speed : speed}) ;
		a.onEnd = callback(function(l : Loader, d : Int) {
					var speed = 0.018 ;
					var el = 1.6 ;
					var a = new anim.Anim(l.pStart, Translation, Elastic(-1, el), {x : l.pStart._x, y : l.pStart._y - d * 1.2, speed : speed}) ;
					a.start() ;
					a = new anim.Anim(l.pStart, Scale, Elastic(-1, el), {x : 100, y : 100, speed : speed}) ;
					a.start() ;
				}, this, dd) ;
		a.start() ;
		
		
		rcode = Std.random(0xFFFFFF) ;
		
		// send server request
		var v : CheckData = {
			_lsize : mc.getBytesTotal(),
			_object : game.data._object,
			_chain : game.data._chain,
			_artefacts : game.data._artefacts,
			_rcode : rcode,
			_qmin : game.data._qmin
		} ;
		/*var data = secure.Utils.encode(haxe.Serializer.run(v)) ;
		
		
		var rlv = new flash.LoadVars() ;
		rlv.onData = onServerData ;
		
		var lv = new flash.LoadVars() ;
		//lv.onData = onServerData ;
		//var url = domain + "/act/start?d=" + data ;
		
		var url = domain + "/act/start" ;
		Reflect.setField(lv, "d", data) ;
		
		
		if( !lv.sendAndLoad(url, rlv, "POST"))
			error(TEXT.ERR_SVR) ;*/
		var url = domain + "/act/start" ;
		secure.Codec.load(url, v, onServerData) ;
	}
	
	
	
	function onServerData(data : StartData) {
		done() ;
		if (data == null) {
			error("- " + TEXT.ERR_START) ;
			return ;
		}

		if (data._error != null) {
			error(data._error) ;
			return ;
		}

		var d = data ;
			
		/*try {
			var s = secure.Utils.decode(data) ;
			d = haxe.Unserializer.run(s) ;
			//trace("gold : " + d._gold + " # score : " + d._goldScore) ;
			
		} catch(e : Dynamic) {
			error("> " + TEXT.ERR_START) ;
			return ;
		}*/
		
		pStart.smc.gotoAndPlay(2) ;
		
		game.id = d._id ;
		if (game.id == null)
			error(Std.string(d._error)) ;
		else if (d._rcheck != rcode ^ 0xAD0AD0)
			error("# " + TEXT.ERR_START + " #") ;
		else  {
			if (d._goldScore != null)
				showContract(d._goldScore) ;
			else 
				start() ;
		}
	}
	
	function showContract(score : Int) {
		/*clickToStart.removeMovieClip() ;
		clickToStart = cast Game.me.mdm.attach("contract", Const.DP_WAITING) ;
		clickToStart._x = 0 ;
		clickToStart._y = 0 ;*/
		hidePanel.gotoAndStop(3) ;
		game.apaScore = score ;
		
		hidePanel._csc._field.text = Std.string(score) ;
		
		
		hidePanel.onRelease = callback(start, true) ;
		
		var sp = 0.1 ;
		var a= new anim.Anim(hidePanel._csc, Translation,  Quint(-1), {x : 0, speed : sp}) ;
		a.start() ;
		a= new anim.Anim(hidePanel._band, Translation, Quint(-1), {x : 0, speed : sp}) ;
		a.start() ;
	}
	
	
	function start(?fromScore = false) {
		game.sound.play("activation") ;
		hidePanel.onRelease = null ;
				
		flash.external.ExternalInterface.call("_pconf") ; //flag confirm on back button
		//game.start() ;
		//waitingResponse = false ;
		//game.initStage() ;
		step = if (fromScore) 2 else 1 ;
		loaderOut() ;
	}
	
	
	
	public function update() {
		
		switch(step) {
			case 0 : //nothing to do (waiting for clic)
				
			case 1 : //wait 
				timer = Math.min(timer + 0.043 * mt.Timer.tmod, 1) ;
			
				if (timer == 1) {
					timer = 0 ;
					step = 2 ;
					
					/*psp = new Phys(pStart) ;
					va = 0.7 ;
					ca = 0.02 ;
					psp.vx = (1 + Std.random(4)) * (Std.random(2) * 2 - 1) ;
					psp.vy = -15 - Std.random(15) ;*/
					
					/*an = new anim.Anim(mcCircle, Scale, Quint(1), {x : 1100, y : 1100, speed : 0.063}) ;
					an.onEnd = callback(function(l : Loader) {
						//l.game.start() ;
						l.waitingResponse = false ;
						l.game.bg.setMask(null) ;
						l.mcCircle.removeMovieClip() ;
						//l.clickToStart.removeMovieClip() ;
						l.hidePanel.removeMovieClip() ;
					}, this) ;
					a.start() ;*/
				}
				
			case 2 : //circle out			
				timer = Math.min(timer + 0.07 * mt.Timer.tmod, 1) ;
				var delta = anim.TransitionFunctions.quart(timer) ;
			
				pStart._xscale = 100 - timer * 100 ;
				pStart._yscale = pStart._xscale ;
				pStart._rotation = 300 * timer ;
				
			
				/*var speed = 20 ;
			
				var a = Math.atan2(psp.vy,psp.vx) ;
				var dx = trg.x - psp.x ;
				var dy = trg.y - psp.y ;
				var ta = Math.atan2(dy,dx) ;

				ca = Math.min(ca+0.002*mt.Timer.tmod,1) ;
				

				va += Num.hMod(ta-a,3.14) * ca;
				va *= Math.pow(0.8,mt.Timer.tmod);

				a += va;//*mt.Timer.tmod;

				psp.vx = Math.cos(a)*speed;
				psp.vy = Math.sin(a)*speed;
				
				var tra = psp.getAng(trg) ;
				psp.root._rotation = 180 * a / 3.14 + 90  ;
				
				psp.root._xscale = 100 - (100 * delta) ;
				psp.root._yscale = psp.root._xscale ; 
				*/
				if (timer > 0.95 && an == null) {
					/*mcCircle._x = psp.root._x ;
					mcCircle._y = psp.root._y ;*/
					mcCircle._x = pStart._x ;
					mcCircle._y = pStart._y ;
					an = new anim.Anim(mcCircle, Scale, Quint(1), {x : 1100, y : 1100, speed : 0.063}) ;
					an.onEnd = callback(function(l : Loader) {
						l.waitingResponse = false ;
						l.game.bg.setMask(null) ;
						l.mcCircle.removeMovieClip() ;
						l.hidePanel.removeMovieClip() ;
					}, this) ;
					an.start() ;
				}
					
				
				if (timer == 1) {
					game.start() ;
					var mc = Game.me.mdm.attach("vanish", Const.DP_PART) ;
					mc._x = pStart._x ;
					mc._y = pStart._y ;
					var p = new Phys(mc) ;
					p.timer = 20 ;
					pStart.removeMovieClip() ;
				}
					
			
		}
	}
	
	
	function loaderOut() {
		game.initStage() ;
		
		mcCircle =  game.mdm.attach("endCircle", Const.DP_STAGE_MASK) ;
		mcCircle._xscale = mcCircle._yscale = 0 ;
		mcCircle._x = trg.x ;
		mcCircle._y = trg.y ;
		
		game.stage.mc.setMask(mcCircle) ;
		game.stage.initBgImg() ;
		
		
	}

	
	public function reportError( e : Dynamic ) {
		haxe.Log.trace(e,cast { fileName : "ERROR" }) ;
	}
	
	
	function checkDomain(dom : String) {
		var c = new mt.net.Codec(DOMAIN_K) ;
		for(d in DOMAINS) {
			var d = StringTools.urlDecode(d) ;
			if (c.run(dom.substr(0,d.length)) == d)
				return true ;
		}
		return false ;
	}
	
	
	public function gameOver() {
		if (gameOverDone)
			return ;
		
		loading = Game.me.mdm.attach("loading", Const.DP_LOADING) ;
		loading.smc.smc.gotoAndStop(Std.random(15) + 1) ;
		loading._x = 100 ;
		loading._y = 220 ;
		loading._xscale = loading._yscale = 50 ;
		loading._alpha = 80 ;
		
		/*loading = Game.me.rdm.attach("loading", ) ;
		loading._x = Const.WIDTH / 2 ;
		loading._y = Const.HEIGHT / 2 ;*/
		
		gameOverDone = true ;
		waitingResponse = true ;
		
		// send server request
		var fl = Game.me.log.getFinalLog() ;
		var me = this ;

		/*var data = secure.Utils.encode(haxe.Serializer.run(fl)) ;
		var rlv = new flash.LoadVars() ;
		rlv.onData = onSaveScoreData ;
		var lv = new flash.LoadVars() ;
		Reflect.setField(lv, "i", Game.me.id) ;
		Reflect.setField(lv, "d", data) ;*/
		
		retry = new haxe.Timer(60000) ;
		retry.run = function() {
			secure.Codec.load(me.domain + "/act/end?i=" + Game.me.id, fl, me.onSaveScoreData) ;
			//lv.sendAndLoad(me.domain + "/act/end", rlv, "POST") ;
		};
		retry.run() ;
	}

	function onSaveScoreData(end : SaveResult) {
		if (end == null)
			return ;
		
		/*var s = secure.Utils.decode(data) ;
		var end : SaveResult = haxe.Unserializer.run(s) ;*/
		
		if( end._endUrl != null ) {
			retry.stop() ;
			redirect(end._endUrl) ;
		}
	}

	/*function onSaveScoreData(data : String) {
		if( data == null )
			return ;
		
		var s = secure.Utils.decode(data) ;
		var end : SaveResult = haxe.Unserializer.run(s) ;
		
		if( end._endUrl != null ) {
			retry.stop() ;
			redirect(end._endUrl) ;
		}
	}*/
	
	
	function error(txt : String) {
		//trace(txt) ;		
		
		mcError = cast Game.me.mdm.attach("errorInfo", Const.DP_ERROR) ;
		mcError._x = 50 ;
		mcError._y = 50 ;
		
		mcError._field.text = txt ;
	}

	public function redirect( url ) {
		flash.Lib.getURL(url,"_self");
	}

}
