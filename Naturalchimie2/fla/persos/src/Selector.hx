import mt.bumdum.Phys ;
import mt.bumdum.Lib ;
import anim.Transition ;
import anim.Anim.AnimType ;


enum Step {
	Loading ; 
	Show ; 
	Choose ;
}

class Selector {
	
	static public var selector : Selector;
	public var dm : mt.DepthManager ;
	public var jsConnect : Dynamic ;
	
	
	var face : Array<String> ;
	
	var selectors : Array<Array<Int>> ;
	var rands : IntHash<Array<Int>> ;
	
	var gui : {>flash.MovieClip, 
			_cadre : flash.MovieClip,
			_thumb1 : flash.MovieClip, _thumb2 : flash.MovieClip, _thumb3 : flash.MovieClip, _thumb4 : flash.MovieClip, _thumb5 : flash.MovieClip, _thumb6 : flash.MovieClip, 
		
			_thbg1 : {>flash.MovieClip, _bmp : flash.display.BitmapData}, _thbg2 : {>flash.MovieClip, _bmp : flash.display.BitmapData},
			_thbg3 : {>flash.MovieClip, _bmp : flash.display.BitmapData}, _thbg4 : {>flash.MovieClip, _bmp : flash.display.BitmapData},
			_thbg5 : {>flash.MovieClip, _bmp : flash.display.BitmapData}, _thbg6 : {>flash.MovieClip, _bmp : flash.display.BitmapData}, 
		
			_but1 : flash.MovieClip, _but2 : flash.MovieClip, _but3 : flash.MovieClip, _but4 : flash.MovieClip, _but5 : flash.MovieClip, _but6 : flash.MovieClip, 
			_rand : flash.MovieClip} ;
	var thumbs : Array<{>flash.MovieClip, _bmp : flash.display.BitmapData}> ;
	var tbts : Array<flash.MovieClip> ;
	var buttons : Array<flash.MovieClip> ;
	public var curChoice : Int ;
			
	public var thFaces : Array<String> ;
	
	var step : Step ;
			
	public var dThumb : Display ;
	public var dThumbMc : flash.MovieClip ;
			
	public var perso : Display;
	public var persoMC: flash.MovieClip;
	public var randButton : flash.MovieClip ;
	
	static var DP_EDITOR_PERSO	 = 2 ;
	static var DP_BUTTON	 = 3 ;
	
	static var PERSO = [0, 1, 2, 3, 4, 5] ; //index 0
	static var SIZE = [1, 2, 3] ; //index 1
	static var SKIN_COLOR = [0, 1, 2, 3, 4, 5, 6, 7] ; //index 16
	static var HAIR_COLOR = [0, 1, 2, 3, 4, 5] ; //index 17
	static var HAIR = [0, 1, 2] ; //index 7
	static var EYES = [0, 1, 2] ; //eyes : index 8
	static var EYECOL = [0, 1, 2, 3, 4] ; //eyes : index 17
	static var NOSE = [0, 1, 2, 3] ; //nose : index 9 
	static var MOUTH = [0, 1, 3] ; //mouth : index 10
	static var EARS = [0, 1] ; //ears : index 11
	static var PATTERN = [0, 2, 3] ; //pattern : index 4
	static var BORD = [0] ; //bord : index 5
	static var SHIRT = [0, 1] ; //bg : index 12
	static var TROUSERS = [0, 1] ; //bg : index 13
	static var UNIFCOL1 = [0, 1, 2, 3] ; //uniform color 1 : index 20
	static var UNIFCOL2 = [0, 1, 2, 3] ; //uniform color 2 : index 21
	static var UNIFCOL3 = [0, 1, 2, 3] ; //uniform color 3 : index 2
	static var BOTTOMCOL1 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26] ; //bottom color 1 : index 22
	static var BOTTOMCOL2 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26] ;  //bottom color 2 : index 23
	static var MISCCOL2 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26] ;  //misc color 2 : index 26
	
	
	static function main(){
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces();
		selector = new Selector();
	}
	
	function new(){
		Cs.THUMBW = 77 ;
		Cs.THUMBH = 63 ;
		
		
		for (d in ["www","beta","data"])
			flash.system.Security.allowDomain(d+".naturalchimie.com") ;
		
		/*var ctx = new haxe.remoting.Context() ;
		ctx.addObject("_Com", _Com) ;
		jsConnect = haxe.remoting.ExternalConnection.jsConnect("persos_viewer", ctx) ;*/
		
		init() ;
	}
		
	function init() {
		initRands() ;
		
		//var rootFace = Reflect.field(flash.Lib._root, "face") ;
		/*var rootFace = flash.external.ExternalInterface.call("_loadFace") ;
		
		if (rootFace != null && rootFace.split(";").length == 26)
			forceFace(rootFace) ;
		else */
	
		face = initFace() ;

		dm = new mt.DepthManager(flash.Lib.current) ;
		
		gui = cast dm.attach("GUI", DP_EDITOR_PERSO) ;
		gui._cadre.smc._alpha = 0 ;
		gui._cadre.smc._y -= 10 ;
		
		dThumbMc = dm.empty(40) ;
		dThumbMc._x = dThumbMc._y = -1000 ;
		perso = new Display(gui._cadre.smc, 1);
		
		perso.mcLoading = dm.attach("loading", Cs.DP_MISC) ;
		perso.mcLoading.smc.smc.gotoAndStop(1) ;
		perso.pbar2 = cast dm.attach("loadingBar", Cs.DP_MISC + 1) ;
		perso.mcLoading._x = perso.pbar2._x = 315 ;
		perso.mcLoading._y = perso.pbar2._y = 150 ;
		perso.pbar2._y += 10 ;
		
		perso.initPerso(0,0,face.join(";"), initDisplays) ;	
		updatePerso() ;
		flash.Lib.current.onEnterFrame = loop ;
		
		initButtons() ;
		
		
	}
	
	
	function initRands() {
		rands = new IntHash() ;
		rands.set(0, PERSO) ;
		rands.set(1, SIZE) ;
		rands.set(16, SKIN_COLOR) ;
		rands.set(17, HAIR_COLOR) ;
		rands.set(7, HAIR) ;
		rands.set(8, EYES) ;
		rands.set(9, NOSE) ;
		rands.set(10, MOUTH) ;
		rands.set(11, EARS) ;
		rands.set(12, SHIRT) ;
		rands.set(13, TROUSERS) ;
		rands.set(4, PATTERN) ;
		rands.set(5, BORD) ;
		rands.set(18, EYECOL) ;
		rands.set(19, UNIFCOL1) ;
		rands.set(20, UNIFCOL2) ;
		rands.set(21, UNIFCOL3) ;
		rands.set(22, BOTTOMCOL1) ;
		rands.set(23, BOTTOMCOL2) ;
		rands.set(24, BOTTOMCOL2) ;
		rands.set(26, MISCCOL2) ;
		
		selectors = new Array() ;
		selectors.push([0, 26]) ; //family
		selectors.push([8, 9, 10, 11, 16, 18]) ; //face
		selectors.push([7, 17]) ; //hair
		selectors.push([13, 23, 24]) ; //trousers
		selectors.push([12, 22, 19, 20, 21]) ; //shirts
		
		//selectors.push([1, 16, 17, 7, 8, 9, 10, 11, 4, 5, 19, 20, 21, 22, 23, 25]) ; //randomize all
	}
	
	public function initDisplays() {
		if (dThumb == null) {
			dThumb = new Display(dThumbMc, 0) ;
			dThumb.initThumb(77, 63, face.join(";"), initDisplays) ;
			return ;
		}
		var speed = 0.15 ;
		
		generateThumbs() ;
		
		choose(this, Std.random(6), true) ;
		
		
		var a = new anim.Anim(gui._cadre.smc, Alpha(1), Quint(1), {speed : speed * 1.5}) ;
		a.sleep = 9.0 ;
		a.start() ;
		
		a = new anim.Anim(perso.mcLoading, Alpha(-1), Quint(1), {speed : speed * 1.5}) ;
		a.start() ;
		a = new anim.Anim(perso.pbar2, Alpha(-1), Quint(1), {speed : speed}) ;
		a.onEnd = callback(function(s : Selector) { s.perso.pbar2.removeMovieClip() ; s.perso.mcLoading.removeMovieClip() ;}, this) ;
		a.start() ;
		
		step = Choose ;
		
	}
	
	
	public function generateThumbs(?speed = 0.15) {
		thFaces = new Array() ;
		var deltaWait = 1.5 ;
		
		for (i in 0...6) {
			thumbs[i]._alpha = 0 ;
			var f = initFace(i).join(";") ;
			thFaces.push(f) ;
			dThumb.updatePerso(f) ;
			dThumb.update() ;
			dThumb.update() ;
			
			if (thumbs[i]._bmp != null)
				thumbs[i]._bmp.dispose() ;
			
			thumbs[i]._bmp = dThumb.MCalchemistBitmap.bmp.clone() ;
			
			thumbs[i].attachBitmap(thumbs[i]._bmp, 100) ;
			
			
			var a = new anim.Anim(thumbs[i], Alpha(1), Quint(1), {speed : speed}) ;
			a.sleep = i * deltaWait ;
			a.start() ;
		}
	}
	
	function initButtons() {
		thumbs = cast [gui._thbg1, gui._thbg2, gui._thbg3, gui._thbg4, gui._thbg5, gui._thbg6] ;
		tbts = cast [gui._thumb1, gui._thumb2, gui._thumb3, gui._thumb4, gui._thumb5, gui._thumb6] ;
		buttons = [gui._but1, gui._but2, gui._but3, gui._but4, gui._but5, gui._but6] ;
		
		for (i in 0...6) {
			initButton(tbts[i], callback(choose, this, i, false), callback(function(i : Int, s : Selector) { if (i != s.curChoice) s.tbts[i].gotoAndStop(1) ;}, i, this)) ;
			initButton(buttons[i], callback(change, this, i)) ;
			
			thumbs[i]._alpha = 0 ;
		}
		
		initButton(gui._rand, callback(reRoll, this)) ;
	}
	
	
	function initButton(mc : flash.MovieClip, fRelease : Void -> Void, ?fOut : Void -> Void) {
		mc.gotoAndStop(1) ;
		
		
		mc.onRelease = callback(function(f : Void -> Void, m : flash.MovieClip) {m.gotoAndStop(2) ; f() ;}, fRelease, mc) ;
		mc.onPress = callback(function(m : flash.MovieClip) {m.gotoAndStop(3) ;}, mc) ;
		mc.onRollOver = callback(function(m : flash.MovieClip) {m.gotoAndStop(2) ;}, mc) ;
		mc.onRollOut = if (fOut != null) fOut else callback(function(m : flash.MovieClip) {m.gotoAndStop(1) ;}, mc) ;
		mc.onReleaseOutside  = mc.onRollOut  ;
		mc.useHandCursor = true ;
	}
	
	
	public function change(s : Selector, index : Int) {
		if (s.step != Choose)
			return ;
		
		switch(index) {
			case 0 :  //sex
				if (face[0] == "0" || face[0] == "2" || face[0] == "4")
					face[0] = Std.string(Std.parseInt(face[0]) + 1) ;
				else
					face[0] = Std.string(Std.parseInt(face[0]) - 1) ;
			
			case 1 : //family
				modify(0) ;
				/*var old = face[0] ;
				var c = 0 ;
				while(c < 15) {
					face[0] = Std.random(6) ;
					if (face[0] != old)
						break ;
					c++ ;
				}*/
				
			case 2 : //head
				modify(1) ;
				
			case 3 : //hair
				modify(2) ;
			case 4 : //trousers
				modify(3) ;
			case 5 : //shirt
				modify(4) ;
			
		}
		
		updatePerso() ;
		
	}
	
	public function choose(s : Selector, index : Int, ?force = false) {
		if (s.step != Choose && !force)
			return ;
		if (s.curChoice!= null)
			s.tbts[s.curChoice].gotoAndStop(1) ;
		s.curChoice = index ;
		s.tbts[index].gotoAndStop(2) ;
				
		s.face = s.thFaces[index].split(";") ;
		s.updatePerso() ;
	}
	
	public function reRoll(s : Selector) {
		if (s.step != Choose)
			return ;
		
		for (i in 0...6) {
			if (thumbs[i]._bmp != null)
				thumbs[i]._bmp.dispose() ;
		}
		
		generateThumbs() ;
	}
	
	
	function initFace(?forceFamily : Int) : Array<String> {
		var res= new Array() ;
		
		var nots = new Array() ;
		
		for (i in 0...27) {
			var r = rands.get(i).copy() ;
			
			if (i == 19 || i == 20 || i == 21) {
				for(n in nots)
					r.remove(n) ;
				var v = r[Std.random(r.length)] ;
				nots.push(v) ;
				res.push(Std.string(v)) ;
			} else  {
				if (r == null)
					res.push("0") ;
				else
					res.push(Std.string(r[Std.random(r.length)])) ;
			}
		}
			
		
		if (forceFamily != null)
			res[0] = Std.string(forceFamily) ;
		
		return res ;
	}
	
	
	function update(index : Int, ?back = false) {	
		modify(index, back) ;
		updatePerso() ;
	}
	
	
	public function setValue(index : Int, value : Int) {
		var t = selectors[index] ;
		if (t == null) {
			trace("error in set : no selector for index " + index) ;
			return ;
		}
		
		var values = rands.get(index) ;
		if (values == null) {
			trace("error in set : no values for index " + index) ;
			return ;
		}
		var found = false ;
		for (i in 0...values.length) {
			if (values[i] == value) {
				found = true ;
				break ;
			}
		}
		if (!found) {
			trace("error in set : invalid value " + value) ;
			return ;
		}
		
		face[index] = Std.string(value) ;
		updatePerso() ;
	}
	
	
	function updatePerso() {
		var sf = face.join(";") ;
		perso.updatePerso(sf) ;
		//perso.display() ;
		flash.external.ExternalInterface.call("_updateFace", sf) ;
	}
	
	
	
	function loop() {
		perso.update() ;
		/*if (dThumb != null)
			dThumb.update() ;*/
		updateMoves() ;
		
		switch(step) {
			case Loading :
				//nothing to do
			case Show : 
			
			
			case Choose : 
				
		}
		
	}
	
	
	function updateMoves() {		
		var list = anim.Anim.onStage.copy() ; 
		for (m in list) m.update() ;
	}
	
	
	public function modify(index : Int, ?back = false) {
		var t = selectors[index] ;
		if (t == null) {
			trace("error in modify : no selector for index " + index) ;
			return ;
		}
		
		if (t.length == 1) { //show next 
			var values = rands.get(t[0]) ;
			var i = null ;
			for (j in 0...values.length) {
				if (Std.string(values[j]) == face[index]) {
					i = j ;
					break ;
				}
			}
			if (i == null) {
				trace("error in modify : value " + face[index] + " not found") ;
				return ;
			}
			
			var v = if (back)
						values[if (i + 1 > values.length) i + 1  else 0] ;
					else
						values[if (i - 1 >= 0) i - 1  else values.length - 1] ;
			
			face[index] = Std.string(v) ;
		} else { //random elements
			
			var nots = new Array() ;
			
			for (tr in t) {
				var values = rands.get(tr).copy() ;
				var v = null ;
				if (values.length == 1)
					continue ;
				
				if (tr == 19 || tr == 20 || tr == 21) {
					for(n in nots)
						values.remove(n) ;
					v = values[Std.random(values.length)] ;
					nots.push(v) ;
				} else {
					values.remove(Std.parseInt(face[tr])) ;
					v = values[Std.random(values.length)] ;
				}
								
				face[tr] = Std.string(v) ;
			}
		}
		
		
	}
	
}