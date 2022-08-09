import flash.Key ;
import mt.bumdum.Lib ;
import anim.Anim.AnimType ;
import anim.Transition ;
import ZoneData._DialogInfos ;


enum SpeakingStep {
	Pause ;
	Write ;
	Done ;
}


typedef FadeInfos = {
	var mc : flash.MovieClip ;
	var action : Int ;
	var speed : Float ;
	var sleep : Float ;
	var timer : Float ;
	var transition : Float -> Float ;
	var params : Dynamic ;
	var toWrite : TextInfos ;
	var postFunc : Void -> Void ;
}


typedef TextInfos = {
	var isHero : Bool ; 
	var text : String ;
	var off : Bool ;
	var fast : Int ;
	var frame : String ;
	var postFunc : Void -> Void ;
}


typedef Bubble = {>flash.MovieClip, _text : {>flash.MovieClip, _field : flash.TextField}, _bg : {>flash.MovieClip, _sub : flash.MovieClip, _arrow : flash.MovieClip}} ;





class Dialog {
	
	static var DP_PNJ = 1 ;
	static var DP_CHAT_HERO = 2 ;
	static var DP_PART = 3 ;
	static var DP_CHAT_PNJ = 4 ;
	static var DP_MOUSE = 5 ;
	
	static var DELAY_NEXT = 350 ;
	
	public static var GEN_BUBBLE = {  margin : 13,
									deltaC : 4,
									deltaB : 3,
								} ;
	
	public static var PNJ_PADDING = 0 ;
	public static var PNJ_DY = 0 ;
	public static var PNJ_WAIT = 10.0 ;
	
	static public var CHAT_PNJ_DX = 25 ;
	static public var CHAT_PNJ_DY = 170 ;
								
	static public var LAST_PNJ_DX = 25.0 ;
	static public var LAST_PNJ_DY = 170.0 ;
								
								
	static public var CHAT_HERO_DX = 45 ;
	static public var CHAT_HERO_DY = 35 ;
	
	static var DEFAULT_SPEED_FADE_IN = 0.09 ;
	static var DEFAULT_SPEED_FADE_OUT = 0.08 ;
	static var DEFAULT_PAUSE = 25 ;
	
	
	static var ERROR = "erreur lors de la réception des données. Merci de réessayer." ;
	static var NEXT = "autoNext" ;
	
	static var parent : Dynamic ;
	static public var me : Dialog ;
	public var dp : Int ;
	public var mc : flash.MovieClip ;
	public var dm : mt.DepthManager ;
	public var dmc : mt.DepthManager ;
	public var dmch : mt.DepthManager ;
	public var pnj : Pnj ;
	public var mcChatPnj : Bubble ;
	public var mcChatHero : Bubble ;
	public var mcChatCreate : Bubble ;
	
	public var id : String ;
	var sHandler : String ;
	var speakStep : SpeakingStep ;
	public var waitingResponse : Bool ;
	var pnjHidden : Bool ;
	var externPnj : Bool ;
	public var infos : _DialogInfos ;
	var texts : List<Dynamic> ;
	
	
	var currentFades : Array<FadeInfos> ;
	var currentWrite : Writer ;
	
	public var cmdFunc : Void -> Void ;
	public var postKill : Void -> Void ;
	
	var waitTimer : Float ;
	var waitRedir : Float ;
	public var autoKill : Bool ;
	
	
	public function new(id : String, parent, dp : Int, epnj : Pnj, sh, ?textInfo : String, ?noRequest = false) {
		me = this ;
		this.id = id ;
		Dialog.parent = parent ;
		this.dp = dp ;
		sHandler = sh ;
		waitingResponse = false ;
		externPnj = false ;
		speakStep = Done ;
		currentFades = new Array() ;
		waitTimer = 0.0 ;
		
		if (epnj != null) {
			pnj = epnj ;
			pnjHidden = false ;
			externPnj = true ;
		}
		
		if (noRequest) {
			autoKill = true ;
			return ;
		}
		
		if (id  != null)
			init() ;
		else if (textInfo != null && textInfo != "")
			setInfo(textInfo)  ;
		else 
			kill() ;
	}
	
	
	function init() {
		getNext(null) ;
	}
	
	
	function initMcs(?f : Void -> Void) {
		mc = parent.me.mdm.empty(dp) ;
		dm = new mt.DepthManager(mc) ;
		
		mcChatPnj = cast dm.empty(DP_CHAT_PNJ) ;
		//dmc = new mt.DepthManager(mcChatPnj) ;
		
		mcChatHero = cast dm.empty(DP_CHAT_HERO) ;
		//dmch = new mt.DepthManager(mcChatHero) ;
		
		mcChatPnj._bg = cast mcChatPnj.createEmptyMovieClip("bg", 1) ;
		mcChatPnj._text = cast mcChatPnj.attachMovie("pnjSpeak", "pnjSpeak", 2) /*cast dmc.attach("pnjSpeak", 2)*/ ;
		mcChatPnj._text.gotoAndStop(1) ;
		mcChatPnj._x = CHAT_PNJ_DX ;
		mcChatPnj._y = CHAT_PNJ_DY ;
		mcChatPnj._alpha = 0 ;
		mcChatPnj._text._field.text = "" ;
		
		dmc = new mt.DepthManager(mcChatPnj._bg) ;
		mcChatPnj._bg._arrow = dmc.attach("bulleArrow", 1) ;
		mcChatPnj._bg._arrow.gotoAndStop(1) ;
		
		//mcChatHero = cast dm.attach("heroSpeak", DP_CHAT_HERO) ;
		mcChatHero._bg = cast mcChatHero.createEmptyMovieClip("bg", 1) ;
		mcChatHero._text = cast mcChatHero.attachMovie("heroSpeak", "heroSpeak", 2) /*cast dmch.attach("heroSpeak", 2)*/ ;
		mcChatHero._text.gotoAndStop(1) ;
		mcChatHero._x = CHAT_HERO_DX ;
		mcChatHero._y = CHAT_HERO_DY ;
		mcChatHero._alpha = 0 ;
		mcChatHero._text._field.text = "" ;
		
		dmch = new mt.DepthManager(mcChatHero._bg) ;
		mcChatHero._bg._arrow = dmch.attach("bulleArrow", 1) ;
		mcChatHero._bg._arrow.gotoAndStop(1) ;
		mcChatHero._bg._arrow._xscale = -100 ;
		mcChatHero._bg._arrow._yscale = -100 ;
		
		
		mcChatCreate = cast dm.empty(0) ;
		
		mcChatCreate._bg = null ;
		mcChatCreate._text = cast dm.attach("pnjSpeak", 0) ;
		mcChatCreate._text.gotoAndStop(1) ;
		mcChatCreate._x = -1000 ;
		mcChatCreate._y = -1000 ;
		mcChatCreate._alpha = 0 ;
		mcChatCreate._text._field.text = "" ;
		

		
		var size = [0, 500, 0, 300] ;
		var mcMouse = dm.empty(DP_MOUSE) ;
		mcMouse.beginFill(1, 0) ;
		mcMouse.moveTo(size[0], size[2]) ;
		mcMouse.lineTo(size[1], size[2]) ;
		mcMouse.lineTo(size[1], size[3]) ;
		mcMouse.lineTo(size[0], size[3]) ;
		mcMouse.lineTo(size[0], size[2]) ;
		mcMouse.endFill() ;
		
		mcMouse.onPress = onMousePress ;
		mcMouse.onRelease = onMouseRelease ;
				
		if (infos._gfx != null && infos._gfx != "hide" && !externPnj) {
			setPnj(infos._gfx, f) ;
			return ;
		}
		
		if (f != null)
			f() ;
	}
	
	
	function setPnj(gfx : String, ?pf : Void -> Void) {
		if (pnj != null)
			return ;
		
		var df = callback(function(t : Dialog, f : Void -> Void) {
			
			//t.pnj.mc._x = t.getPnjHideX() ;
			t.pnj.mc._alpha = 0 ;
			t.pnj.mc._x = t.getPnjX() ;
			t.pnj.mc._y = parent.HEIGHT - PNJ_DY ;
		
			// colored sharpen outer glow 

			t.pnj.setGlow() ;
			
			t.pnjHidden = true ;
			
			if (f != null)
				f() ;
		}, this, pf) ;
		
		pnj = new Pnj(gfx, dm, DP_PNJ, parent.me.loader, df) ;
	}

	
	
	public function loop() {
		
		switch(speakStep) {
			
			case Pause :
				if (waitTimer <= 0.0) {
					speakStep = Done ;
				} else 
					waitTimer -= mt.Timer.tmod ; 
				
			case Write :
				//trace("Write " ); 
				if (currentFades.length > 0)
					updateFades(-1) ;
			
				if (writeDone()) {
					currentWrite = null ;
					setPause() ;
					return ;
				} else
					speaks() ;
			
			case Done :
				//trace("Done : " + currentFades.length) ;
				if (currentFades.length > 0)
					updateFades() ;
				else {
					if (infos._redir != null && infos._redir._auto && texts.length == 0) {
						if (waitRedir == null) {
							waitRedir = 5.0 ;
							//trace("##### WAIT REDIR");
						} else {
							waitRedir = Math.max(0.0, waitRedir - 0.3 * mt.Timer.tmod) ;
							//trace("##### " + waitRedir);
							
							if (waitRedir == 0.0) {
								setUrl(infos._redir._url) ;
								infos._redir = null ;
							}
							return ;
						}
					}
				}
		}
		
	}
	
	
	function setPause(?t) {
		waitTimer = if (t != null) t else DEFAULT_PAUSE ;
		speakStep = Pause ;
	}
	
	
	function printAnswers() {
		var sa = "" ;
		
		for (a in infos._answers) {
			if (sa != "")
				sa += "#" ;
			sa += a._id + "µ" + Writer.getTextOnly(a._text) ;
		}
			
		if (sa == "" )
			return ;
		
		//trace("## print answers") ;
		flash.external.ExternalInterface.call("_setAnswers", sa) ;
	}
	
	function printNext() {
		var sa = "autoNextµsuite..." ;
		flash.external.ExternalInterface.call("_setAnswers", sa) ;
	}
	
	
	
	function hideAnswers() {
		flash.external.ExternalInterface.call("_hideAnswers") ;
	}
	
	
	
	function isVisiblePnjBubble() : Bool {
		return mcChatPnj._alpha == 100 ;
	}
	
	
	function isVisibleHeroBubble() : Bool {
		return mcChatHero._alpha == 100 ;
	}
	
	
	function updateFades(?only : Int) {
		var mcDone = new List() ;
		
		for (f in currentFades.copy()) {
			if (only != null && f.action != only)
				continue ;
			
			if (currentWrite != null && currentWrite.field == (cast f.mc)._text._field && f.action == -1) //no fade out on currentWrite
				continue ;
			
			if (f.sleep != null) {
				f.sleep -= mt.Timer.tmod ;
				if (f.sleep <= 0)
					f.sleep = null ;
				continue ;
			}
			
			if (Lambda.exists(mcDone, function(m) {return m == f.mc ;})) {
				continue ;
			}
			
			var sp = if (f.speed != null) f.speed else {if (f.action > 0) DEFAULT_SPEED_FADE_IN ; else DEFAULT_SPEED_FADE_OUT ; } ;
			
			f.timer = Num.mm(0, f.timer + sp * mt.Timer.tmod, 1) ;
			var delta = f.transition(f.timer/*, f.params*/) ; 			
			
			f.mc._alpha = if (f.action > 0) delta * 100 else 100 - delta * 100 ;
			
			mcDone.push(f.mc) ;
			
			if (f.timer >= 1.0) {
				if (f.toWrite != null && canWrite())
					beginWriting(f.toWrite) ;
				
				if (f.postFunc != null) {
					f.postFunc() ;
				}
				
				currentFades.remove(f) ;
			}
		}
	}
	
	
	function canWrite() : Bool {
		return currentWrite == null ;
	}
	
	
	function setBubble(w : TextInfos) {
		if (pnjHidden) {
			if (!w.isHero && !w.off && w.frame != Pnj.HIDE_FRAME) { //
				pnjIn(callback(showBubble, w), PNJ_WAIT, w.frame) ;
				return ;
			}
		} else {
			if (pnj != null && !pnjHidden && pnj.isHideNeeded(w.frame)) {
				pnjOut(callback(setBubble, w)) ;
				if (isVisiblePnjBubble()) {
					addFade(mcChatPnj, -1, null, null, null, Cubic(-1), null, 
						callback(function(d : Dialog, w : TextInfos) { 
									d.preparePnj(w) ;
							}, this, w)
					) ; //fade out
						}
				return ;
			}
		}
		
		showBubble(w) ;
	}
	
	
	function showBubble(w : TextInfos) {
		var m = if (w.isHero) cast mcChatHero else cast mcChatPnj ;
		if ((w.isHero && isVisibleHeroBubble()) || (!w.isHero && isVisiblePnjBubble())) {
			addFade(m, -1, 0.2, null, null, Cubic(-1), null, 
				if (w.isHero)
					callback(function(d : Dialog) { d.prepareHero(w) ; }, this) ;
				else
					callback(function(d : Dialog, w : TextInfos) { 
								d.preparePnj(w) ;
						}, this, w)
			) ; //fade out
		} else {
			if (w.isHero)
				prepareHero(w) ;
			else
				preparePnj(w) ;
		}
		
		addFade(m, 1, null, null, w, Cubic(-1)) ; //fade in
	}
	
	
	function preparePnj(w : TextInfos) {
		mcChatPnj._x = CHAT_PNJ_DX ;
		mcChatPnj._y = CHAT_PNJ_DY ;
		mcChatPnj._text.gotoAndStop(if (w.off) 2 else 1) ;
		if (!w.off)	
			createBubble(w) ; 
		else {
			if (mcChatPnj._bg._sub != null) {
				mcChatPnj._bg._sub.removeMovieClip() ;
				mcChatPnj._bg._sub = null ;
			}
			mcChatPnj._bg._arrow._alpha = 0 ;
		}
			
		mcChatPnj._text._field.text = "" ;
	}
	
	
	function createBubble(w : TextInfos) {
		var m : Bubble = if (w.isHero) mcChatHero else mcChatPnj ;
		if (m._bg._sub != null) {
			m._bg._sub.removeMovieClip() ;
			m._bg._sub = null ;
		}
		
		var d = if (w.isHero) dmch else dmc ;
			
		mcChatCreate._text._field.text = Writer.getTextOnly(w.text) ;
		//m._text._field.text = Writer.getTextOnly(w.text) ;
				
		var h = mcChatCreate._text._field.textHeight + GEN_BUBBLE.margin * 2 ;
		var l = mcChatCreate._text._field.textWidth + GEN_BUBBLE.margin * 2 ;
		
		//trace("l : " + l + " # h : " + h  +" / " + m._text._field.textHeight ) ;

		m._bg._sub = cast d.empty(1) ;
	
		var start = {	x : m._text._x - GEN_BUBBLE.margin / 2, 
					y : m._text._y - GEN_BUBBLE.margin / 2} ;
		var deltaStart = {x : Std.random(GEN_BUBBLE.deltaC) * (Std.random(2) * 2 - 1), y : Std.random(GEN_BUBBLE.deltaC) * (Std.random(2) * 2 - 1)} ;
		var from = {x : start.x, y : start.y} ;
		
		m._bg._sub.beginFill(0xFFFFFF, 100) ;
		m._bg._sub.moveTo(from.x + deltaStart.x, from.y + deltaStart.y) ;
		for (i in 0...4) {
			
			var breakPoint = 0 ; //Std.random(2) ;
			var next = {x : from.x, y : from.y} ;
			var dd = null ;
			
			//trace(i + " => " + next.x + ", " + next.y) ;
			
			switch(i) {
				case 0 :
					dd = l ;
					while(breakPoint > 0) {
						var mb = dd / 2 ;
						mb += (dd / 3) * (Std.random(2) * 2 - 1) ;
						m._bg._sub.lineTo(next.x + mb, next.y - GEN_BUBBLE.deltaC + Std.random(GEN_BUBBLE.deltaC * 2)) ;
						breakPoint-- ;
					}
					
					next = {x : next.x + dd,
						y : next.y} ;
						
				case 1 :
					dd = h ;
					
					/*var extraPoints = if (w.isHero) null else makeBubbleTarget(w, dd, from) ;
					if (extraPoints != null) {
						for (i in 0...extraPoints.length) {
							var e = extraPoints[i] ;
							m._bg.lineTo(next.x + e.x, next.y + e.y) ;
							
							if (i == extraPoints.length - 1) {
								dd -= e.y ;
								next.y = next.y + e.y ;
							}
						}
					}*/
				
					while(breakPoint > 0) {
						var mb = dd / 2 ;
						mb += (dd / 3) * (Std.random(2) * 2 - 1) ;
						var bx = next.x - GEN_BUBBLE.deltaC + Std.random(GEN_BUBBLE.deltaC * 2) ;
						m._bg._sub.lineTo(bx, next.y + mb) ;
						breakPoint-- ;
					}
				
					next = {x : next.x,
						y : next.y + dd} ;
				
				case 2 :
					dd = l ;
					while(breakPoint > 0) {
						var mb = dd / 2 ;
						mb += (dd / 3) * (Std.random(2) * 2 - 1) ;
						var by = next.y - GEN_BUBBLE.deltaC + Std.random(GEN_BUBBLE.deltaC * 2) ;
						m._bg._sub.lineTo(next.x - mb, by) ;
						breakPoint-- ;
					}
					next = {x : next.x - dd ,
							y : next.y - GEN_BUBBLE.deltaC + Std.random(GEN_BUBBLE.deltaC * 2)} ;
				case 3 :
					dd = h ;
					
					/*var extraPoints = if (!w.isHero) null else makeBubbleTarget(w, dd, from) ;
					if (extraPoints != null) {
						for (i in 0...extraPoints.length) {
							var e = extraPoints[i] ;
							m._bg.lineTo(start.x + e.x, start.y + e.y) ;
							
							if (i == extraPoints.length - 1) {
								dd -= e.y ;
								next.y = start.y + e.y ;
							}
						}
					}*/
				
					while(breakPoint > 0) {
						var mb = dd / 2 ;
						mb += (dd / 3) * (Std.random(2) * 2 - 1) ;
						m._bg._sub.lineTo(next.x - GEN_BUBBLE.deltaC + Std.random(GEN_BUBBLE.deltaC * 2), next.y - mb) ;
						breakPoint-- ;
					}
				
					next = start ;
			}
			
			if (w.isHero) {
				m._text._y -= 0.5 ;
			}
			
			if (i < 3) 
				m._bg._sub.lineTo(next.x /*- inf.deltaC + Std.random(inf.deltaC * 2)*/, next.y/* - inf.deltaC + Std.random(inf.deltaC * 2)*/) ;
			else
				m._bg._sub.lineTo(next.x + deltaStart.x, next.y + deltaStart.y) ;
			from = next ;
		}
		
		m._bg._sub.endFill() ;
		
		
		var dx = 0.0 ;
		var dy = 0.0 ;
		
		
		m._bg._arrow._alpha = 100 ;
		m._bg._arrow.gotoAndStop(Std.random(m._bg._arrow._totalframes) + 1) ;
		
		if (w.isHero) {
			m._bg._arrow._x = m._bg._sub._x - 3 ;
			m._bg._arrow._y = 7 ;
		} else {
			dx = 300 - (m._x + m._bg._sub._width) ;
			dy = parent.HEIGHT - (m._y + m._bg._sub._height) ;
			
			m._bg._arrow._x = m._bg._sub._x + m._bg._sub._width - 10 ;
			m._bg._arrow._y = 10 + Std.random(5) ;
		}
		
		
		/*m._bg._sub._alpha = 90 ;
		m._bg._arrow._alpha = 90 ;*/
		m._bg._sub.blendMode = "add";
		m._bg._arrow.blendMode = "add";
		m._bg.filters = [new flash.filters.DropShadowFilter(8,45, 0x000000,0.4,8, 8, 3)] ;
				
		if (dx > 0)
			m._x += Std.random(Std.int(dx)) ;
		if (dy > 0)
			m._y += Std.random(Std.int(dy)) ;
		
		LAST_PNJ_DX = m._x ;
		LAST_PNJ_DY = m._y ;
		
		
		mcChatCreate._text._field.text = "" ;
	}
	
	
	function makeBubbleTarget(w : TextInfos, dd : Float, from : {x : Float, y : Float}) : Array<{x : Float, y : Float}> {
		var res = [[], []] ;
		var skel = [] ;
		var d = if (w.isHero) 30 else 50 ;
		var dx = Std.int(d* 2 / 3 + Std.random(Std.int(d * 1 / 3))) ;
		var dy = Std.int(d* 2 / 3 + Std.random(Std.int(d * 1 / 3))) ;
		
		var side = Std.random(2) * 2 - 1 ;
		//var side = -1 ;
		
		var breaks = Std.random(2) + (if (w.isHero) 0 else 1) ;
	//	breaks = 0 ;
		
		var startD = if (w.isHero) 8 else 13 ;
		
		var startDiameter = startD + Std.random(8) ;
		var startR = 2 ; //random begin of bubble target 
		var minMargin = 10 ;
		
		var sd = dd - minMargin * 2 - startDiameter / 2 ;
		if (sd < 0) {
			sd = 0 ;
			startDiameter = startD ;
		}
		
		if (w.isHero) {
			skel.push({x : 0.0, y : minMargin + startDiameter / 2 + Std.random(Std.int(sd)), a : null, b : null}) ;
			skel.push({x : skel[0].x - dx, y : skel[0].y + dy / 2, a : null, b : null}) ;
			
			var width = Math.sqrt((skel[1].x - skel[0].x) * (skel[1].x - skel[0].x) + (skel[1].y - skel[0].y) * (skel[1].y - skel[0].y)) ; 
			var dp = Math.abs(skel[1].x - skel[0].x) / (breaks + 1) ;
			var da = (skel[1].y - skel[0].y) / (skel[1].x - skel[0].x) ;
			var db = skel[0].y - da * skel[0].x ;
			
			for (b in 0...breaks) {
				var nx = skel[b].x - dp ;
				var  ny = da * nx + db ;
				
				var dda = -1 / da ;
				var ddb = ny - dda * nx ;
				
				var nnx : Float = null ;
				var nny : Float = null ;
				
				var spd = 4 ;
				if (side <= 0)
					nnx = nx - dp / spd - Std.random(Std.int(dp / spd)) ;
				else
					nnx = nx + dp / spd + Std.random(Std.int(dp / spd)) ;
				nny = dda * nnx + ddb ;

				skel.insert(skel.length -1, {x : nnx, y : nny, a : dda, b : ddb}) ;
				
				side = if (side > 0) -1 else 1 ;
			}
		} else {
			skel.push({x : 0.0, y : minMargin + startDiameter / 2 + Std.random(Std.int(sd)), a : null, b : null}) ;
			skel.push({x : skel[0].x + dx, y : skel[0].y - dy, a : null, b : null}) ;
			
			var width = Math.sqrt((skel[1].x - skel[0].x) * (skel[1].x - skel[0].x) + (skel[1].y - skel[0].y) * (skel[1].y - skel[0].y)) ; 
			var dp = Math.abs(skel[1].x - skel[0].x) / (breaks + 1) ;
			var da = (skel[1].y - skel[0].y) / (skel[1].x - skel[0].x) ;
			var db = skel[0].y - da * skel[0].x ;
			
			for (b in 0...breaks) {
				var nx = skel[b].x + dp ;
				var  ny = da * nx + db ;
				
				var dda = -1 / da ;
				var ddb = ny - dda * nx ;
				
				var nnx : Float = null ;
				var nny : Float = null ;
				
				var spd = 3 ;
				if (side > 0)
					nnx = nx - dp / spd - Std.random(Std.int(dp / spd)) ;
				else
					nnx = nx + dp / spd + Std.random(Std.int(dp / spd)) ;
				nny = dda * nnx + ddb ;

				skel.insert(skel.length -1, {x : nnx, y : nny, a : dda, b : ddb}) ;
				
				side = if (side > 0) -1 else 1 ;
			}
			
		}
		
		
		var ddp = if (w.isHero) 3 else 6 ;
		var ddf = 2 ;
		
		//trace("skel : " + Std.string(skel)) ;
		
		for(i in 0...skel.length) {
			var s = skel[i] ;
			
			if (i == 0) {
				
				res[if (w.isHero) 1 else 0].push({x : s.x + Std.random(Std.int(startR)) * (Std.random(2) * 2 - 1), y : s.y - startDiameter / 2}) ;
				res[if (w.isHero) 0 else 1].push({x : s.x + Std.random(Std.int(startR)) * (Std.random(2) * 2 - 1), y : s.y + startDiameter / 2}) ;
				
			} else if (i == skel.length - 1)  {
				res[0].push({x : s.x, y : s.y}) ;
			} else {
				var n = {x : s.x - ddf - Std.random(Std.int(ddp / (i + 1)))/* * (Std.random(2) * 2 -1)*/, y : null} ;
				n.y = n.x * s.a + s.b ;
				if (w.isHero)
					res[1].unshift(n) ;
				else
					res[0].push(n) ;
				n = {x : s.x  + ddf + Std.random(Std.int(ddp / (i + 1)))/* * (Std.random(2) * 2 -1)*/, y : null} ;
				n.y = n.x * s.a + s.b + (Std.random(2) * 2 -1) * Std.random(ddp) ;
				if (w.isHero)
					res[0].push(n) ;
				else
					res[1].unshift(n) ;
			}
		}
		
		var r = res[0].concat(res[1]) ;
		//trace("res : " + Std.string(r)) ;
		
		return r ;
	}
	
	
	public function setPnjFrame(f) {
		if (f == null)
			pnj.setFrame("1") ; 
		else
			pnj.setFrame(f) ; 
	}
	
	
	function prepareHero(w : TextInfos) {
		mcChatHero._x = CHAT_HERO_DX ;
		mcChatHero._y = CHAT_HERO_DY ;
		createBubble(w) ; 
		
		mcChatHero._text._field.text = "" ;
	}
	
	
	function beginWriting(w) {
		currentWrite = new Writer(w, this) ;
		speakStep = Write ;
	}
	
	
	function writeDone() : Bool {			
		var res = currentWrite.isDone() ;
		if (res && currentWrite.infos.postFunc != null)
			currentWrite.infos.postFunc() ;
		return res ;
	}
	
	function speaks() {
		if (currentWrite == null)
			return ;
		currentWrite.update() ;
			
		/*var m = if (currentWrite.infos.isHero) cast mcChatHero else cast mcChatPnj ;		
		m._field.text = currentWrite.infos.text ;*/
	}
	
	
	public function answer(aid : String) {
		if (aid == NEXT) {
			if (texts == null || texts.length == 0) {
				if (infos._answers.length == 1 && infos._answers.first()._id == "begin") {
					getNext(infos._answers.first()._target) ;
					return true ;
				} else 
					return false ;
			}
			
			var t = texts.pop() ;
			//trace(t) ;
			setBubble(t) ; 
			
			return true ;
		}
		
		if (infos._answers == null || infos._answers.length == 0)
			return false ;
		
		for (a in infos._answers) {
			if (a._id == aid) {
				if (aid == "exit") {
					var f = callback(function(d : Dialog) {
						d.cancel() ;
						d.exit() ;
					}, this) ;
					heroSpeaks(a._text, f) ;
					
					/*cancel() ;
					exit() ;*/
					return true ;
				} else if (aid == "end") {
					if (a._target == null) {
						cancel() ;
						exit() ;
					} else {
						setUrl(a._target) ;
					}
					
					return true ;
				} else if (a._off) {
					//setUrl(a._redir) ;
					getNext(a._target) ;
					//exit() ;
					return true ;
				} else {
					heroSpeaks(a._text) ;
					getNext(a._target) ;
					return true ;
				}
			}
		}
	
		return false ;
	}
	
	
	function getNext(aid : String) {
		if (waitingResponse) {
			return ;
		}
		
		waitingResponse = true ;
		
		// send server request
		var url = (cast parent.me.loader).domain + sHandler + "dialog/" + id +"?rn=" + Std.random(100000) +  (if (aid == null) "" else "&goto=" + aid) ;
		haxe.Timer.delay(callback(request, url, onServerData), DELAY_NEXT) ;
	}
	
	
	function cancel() {
		var url = (cast parent.me.loader).domain + sHandler + "dialogCancel" ;
		haxe.Timer.delay(callback(sendCancel, url, null), DELAY_NEXT) ;
	}


	function sendCancel(url, ?f : String -> Void) {
		var lv = new flash.LoadVars() ;
		if (f != null)
			lv.onData = f ;
		lv.load(url) ;

	}
	
	function request(url : String, ? f : String -> Void) {

		secure.Codec.load(url, null, f) ;

		/*var lv = new flash.LoadVars() ;
		if (f != null)
			lv.onData = f ;

		if( !lv.load(url))
			trace("Impossible de contacter le serveur de jeu. Merci de réessayer.") ; */
	}
	
	
	function onServerData(data : Dynamic) {
		//trace("onServerData") ;
		if (data == null) {
			/*trace(ERROR) ;
			exit() ;*/
			setDecodeErrorInfos() ; 
			processInfos() ;
			return ;
		}
		
		
		try {
			/*var s = secure.Utils.decode(data) ;
			infos = haxe.Unserializer.run(s) ;*/
			infos = data ;
		} catch(e : Dynamic) {
			/*trace(ERROR + " " + Std.string(e)) ;
			return ;*/
			setDecodeErrorInfos() ;
		}
		
		if (cast infos._error != null) {
			trace(Std.string((cast infos)._error)) ;
			return ;
		}
		
		
		waitingResponse = false ;
		processInfos() ;
	}
	
	public function setErrorInfos(str : String) {
		infos = {
			_gfx : "normal",
			_texts : [{
				_off : true,
				_frame : null,
				_fast : 2,
				_text : str
				}],
			_id : "error",
			_answers : new List(),
			_redir : null,
			_error : null
		} ;
		
	}
	
	
	function setDecodeErrorInfos() {

		trace("DECODE ERROR INFOS") ;

		infos = {
			_gfx : "hide",
			_texts : [{
				_off : true,
				_frame : null,
				_fast : 2,
				_text : "Oups, le dialogue en cours a été interrompu. \nCela peut arriver si vous avez ouvert [Naturalchimie] dans un autre onglet de votre navigateur. \nHeureusement, vous n'avez rien perdu. Terminez la discussion pour pouvoir reprendre le jeu normalement."
				}],
			_id : "error",
			_answers : new List(),
			_error : null,
			_redir : {_url : "/act",
				_auto : false}
		} ;
		
		infos._answers.push({_off : true, _id : "end", _text : "Terminer la discussion.", _target : "/act"}) ;
		
	}
	
	
	public function processInfos() {
		if (infos._redir != null && infos._texts.length == 0) {
			return ;
		}
		
		var f = null ;
		if (infos._texts.length == 0 && infos._answers.length == 1) { //begin with a user speak
			f = callback(function(t : Dialog) {
				var ff = callback(function(tt : Dialog) {tt.printNext() ;}, t) ;
				t.heroSpeaks(t.infos._answers.first()._text, ff) ; 
			}, this) ;
			
		} else {
			f = callback(function(t : Dialog) {
				if (!t.infos._texts[0]._off && t.pnjHidden && t.infos._texts[0]._frame != Pnj.HIDE_FRAME) {
					t.pnjIn(callback(function(d : Dialog) {
								d.pnjSpeaks() ;
							}, t), if (t.mcChatPnj != null && t.mcChatPnj._currentframe == 2) PNJ_WAIT else null, if (t.pnjHidden) t.infos._texts[0]._frame else null) ;
				} else {
					t.pnjSpeaks() ;
				}
			}, this) ;
		}
		
		if (mc == null)
			initMcs(f) ;
		else
			f() ;
	}
	
	
	public function setUrl(u : String) {
		//exit() ;
		(cast parent.me.loader).initLoading(1) ;
		var lv = new flash.LoadVars() ;
		lv.send((cast parent.me.loader).domain + u, "_self") ;
	}
	
	
	public function onMousePress() {
		if (speakStep == Write && currentWrite != null && !currentWrite.infos.off)
			currentWrite.setUserSpeed() ;
	}
	
	
	public function onMouseRelease() {
		return ; //DISABLE
		
		if (speakStep == Write && currentWrite != null && !currentWrite.infos.off) {
			currentWrite.setBaseSpeed() ;
		}
	}
	
	
	function heroSpeaks(text : String, ?postFunc) {
		if (isVisiblePnjBubble()) 
			addFade(mcChatPnj, -1, null, null, 30) ;
		
		var w = {isHero : true, text : text, off : false, fast : 1, frame : null, postFunc : postFunc} ;
		
		setBubble(w) ;
	}
	
	
	function pnjSpeaks() {

		if (isVisibleHeroBubble()) //fade out of hero bubble
			haxe.Timer.delay(callback(function(d : Dialog, m) { d.addFade(m, -1, null, null, 30) ; }, this, mcChatHero), 1000) ;
		
		
		var ws = [] ;
		for (i in 0...infos._texts.length) {
			ws.push({isHero : false, text : infos._texts[i]._text, off : infos._texts[i]._off, fast : infos._texts[i]._fast, frame : infos._texts[i]._frame, anim : false, postFunc : printNext}) ;
		}
		
		if (autoKill)
			ws[ws.length - 1].postFunc = callback(exit) ;
		else 
			ws[ws.length - 1].postFunc = callback(printAnswers) ;
		texts = Lambda.list(ws) ;
		
		setBubble(texts.pop()) ;
	}
	
	
	function addFade(m, action, speed, sleep, ?write, ?transitionType, ?transitionParams, ?f) { //action : -1 / 1 
		for (f in currentFades) {
			if (f.mc == m && action == f.action) //same action already queued
				return ;
		}
		
		currentFades.push({
			mc : m,
			action : action,
			sleep : sleep,
			speed : speed,
			timer : 0.0,
			transition : anim.Anim.getTransitionFunction(if (transitionType != null) transitionType else Linear),
			params : transitionParams,
			toWrite : write,
			postFunc : f
		}) ;
	}
	
	
	function pnjIn(?f, ?sleep : Float, ?frame) {
		if (frame != null && frame != "start") {
			setPnjFrame(frame) ;
		}
		
		pnjHidden = false ;
		
		if (frame == "start") {
			pnj.mc._x = getPnjX() ;
			pnj.mc._alpha = 100 ;
			pnj.setNext(f) ;
			setPnjFrame(frame) ;
			return ;
		}
		
		
		var m = new anim.Anim(pnj.mc, /*Translation*/Alpha(1), Quart(-1), {/*x : getPnjX(), y : pnj.mc._y,*/x : 0, y : 0, speed : 0.04}) ;
		m.onEnd = f ;
		m.sleep = sleep ;
		m.start() ;
		
	}
	
	
	function pnjOut(?f) {
		var m = new anim.Anim(pnj.mc, Alpha(-1), Quart(1), {x : 0, y : 0, speed : 0.04}) ;
		m.onEnd = f ;
		m.start() ;
		pnjHidden = true ;
	}
	
	
	public function exit() {
		hideAnswers() ;
		
		var noFade = true ;
		var post = callback(function(t : Dialog) {
			if (t.pnj != null && !t.externPnj)
				t.pnjOut(t.kill) ;
			else
				t.kill() ;
			
		}, this) ;
		
		if (isVisibleHeroBubble()) {
			addFade(mcChatHero, -1, null, null, null, Cubic(-1), null, if (!isVisiblePnjBubble()) post else null) ; //fade out
			noFade = false ;
		}
		
		if (isVisiblePnjBubble()) {
			addFade(mcChatPnj, -1, null, null, null, Cubic(-1), null, post) ; //fade out
			noFade = false ;
		}
		
		if (noFade)
			post() ;
	}
	
	
	function setInfo(t : String) {	
		
		infos = {
			_id : null,
			_gfx : null,
			_redir : null,
			_texts : [{_text : t, _off : true, _frame : null, _fast : 1}],
			_answers : null,
			_error : null} ;
		if (mc == null)
			initMcs() ;
		pnjSpeaks() ;
	}
	
	

	public function kill() {
		if (pnj != null && !externPnj)
			pnj.kill() ;
		if (mc != null)
			mc.removeMovieClip() ;
		
		flash.external.ExternalInterface.call("_showDesc") ;
		parent.me.dialog = null ;
		if (postKill != null)
			postKill() ;
	}
	
	
	public function getPnjX() : Float {
		//return 300 ;
		return parent.WIDTH - PNJ_PADDING ;
	}
	
	public function getPnjY() : Float {
		//return 150 ;
		return parent.HEIGHT - PNJ_DY ;
	}
	
	
	function getPnjHideX() : Float {
		//return 200 ;
		return parent.WIDTH + PNJ_PADDING + if (pnj.mc != null) pnj.mc._width else 0 ;
	}

}


typedef TextCol = {
	var col : Int ;
	var start : Int ;
	var end : Int ;
}


class Writer {
	
	public static var CMD = "%" ;
	public static var WORD_ENDS = [" ", CMD, ",", ".", ";", ":", "?", "!"] ;
	public static var SPEED = [0.5, 1.14, 2.2, 3.0] ;
	public static var BASE_SPEED = 1.1 ;
	public static var USER_FAST_SPEED = 3.5 ;
	public static var DEFAULT_PAUSE = 10.0 ;
		
	static var DEFAULT_COLOR	= 0x445155 ;
	static var EM_COLOR		= 0xD25502 ;
	static var BOLD_COLOR		= 0x0272BF ;
		
	var dialog : Dialog ;
	
	public var infos : TextInfos ;
	public var words : Array<String> ;
	var events : {nb : Int, h : IntHash<List<Void -> Void>>} ;
	var colors : Array<TextCol> ;
	public var text : String ;
	public var raw : String ;
	public var next : Float ;
	public var index : Int ;
	public var speedIndex : Int ;
	public var defaultSpeed : Int ;
	public var bSpeed : Float ;
	public var defaultFrame : String ;
	public var pauseTimer : Float ;
	public var shakeTimer : Float ;
		
	var lastFrame : String ;	
	var noEvent : Bool ;
	
	public var field : flash.TextField ;
	
	


	public function new(w : TextInfos, d : Dialog) {
		dialog = d ;
		field = if (w.isHero) cast dialog.mcChatHero._text._field else cast dialog.mcChatPnj._text._field ;
		next = 1 ;
		index = 0 ;
		shakeTimer = 0.0 ;
		noEvent = false ;
		infos = w ;
		defaultSpeed = infos.fast ;
		bSpeed = BASE_SPEED ;
		colors = new Array() ;
		text = convertBasic(w.text) ; 
		words = sanitize(splitWords(text)) ;
		
		setEvents(words) ;
		setAutoEvents(words) ;
		
		raw = getRaw(words) ;
		autoEndL() ;
		
		setSpeed(defaultSpeed) ;
		defaultFrame = w.frame ;
		
		var setFrame = false ;
		if (isCommand(w.text)) {
			var c = w.text.substr(1,w.text.indexOf(CMD, 2) - 1) ;
			setFrame = !isFrameEvent(c) ;
		} else 
			setFrame = dialog.pnj != null && !dialog.pnj.isSameFrame(w.frame) ;
		
		if (setFrame && !w.isHero) {
			dialog.setPnjFrame(w.frame) ;
		}
	}
	
	
	function launchCmdFunc() {
		if (dialog.cmdFunc == null)
			return ;
		dialog.cmdFunc() ;
		
	}
	
	
	static public function getTextOnly(t : String) : String {
		var text = convertBasic(t) ; 
		var words = sanitize(splitWords(text)) ;
		return getRaw(words) ;
	}
	
	
	
	public function update() {
		
		if (shakeTimer > 0)
			shake() ;
		
		if (pauseTimer != null) {
			pauseTimer -= mt.Timer.tmod ;
			if (pauseTimer <= 0.0)
				pauseTimer = null ;
			return ;
		}
		
		/*if (Key.isDown(Key.SPACE) && !infos.off)
			infos.off = true ;*/
		
		
		next += SPEED[speedIndex] * bSpeed ;
		if (infos.off || infos.isHero) {//voix off => ecriture en une fois
			noEvent = true ;
			next = raw.length ;
			if (lastFrame != null)
				Dialog.me.setPnjFrame(lastFrame) ;
		}
		
		while(next >= 1.0) {
			var c = raw.charAt(index) ;
			next -= 1 ;
			executeEvents(index) ;
			field.text += c ;
			index++ ;
			if (!infos.off && pauseTimer != null) //pas de pause pour la voix off
				break ;
		}
		
		for (c in colors) {
			var tf = new flash.TextFormat() ;
			tf.color = c.col ;
			field.setTextFormat(c.start, c.end, tf) ;
		}
	}
	
	
	public function isDone() : Bool {
		return index >= raw.length && events.nb <= 0 && shakeTimer <= 0.0 ;
	}
	
	
	function setSpeed(i) {
		if (noEvent)
			return ;
		
		speedIndex = i ;
	}
	
	
	public function setBaseSpeed() {
		//trace("base") ;
		bSpeed = BASE_SPEED ;
	}
	
	public function setUserSpeed() {
		//trace("user") ;
		bSpeed = USER_FAST_SPEED ;
	}
	
	
	function setPause(m : Float) {
		if (noEvent)
			return ;
		
		pauseTimer = m * DEFAULT_PAUSE / bSpeed ;
	}
	
	function setColor(c : Int) {
		colors.push({col : c, start : index, end : 9999}) ;
	}
	
	
	public function setShake(s : Float) {
		if (noEvent)
			return ;
		
		shakeTimer = Math.min(6, shakeTimer + s) ;
	}
	
	
	function shake() {
		shakeTimer -= 0.2 ;
		var b = null ;
		var pos = null ;
		if (infos.isHero) {
			b = cast Dialog.me.mcChatHero ;
			pos = {x : Dialog.CHAT_HERO_DX, y : Dialog.CHAT_HERO_DY} ;
		} else {
			b = cast Dialog.me.mcChatPnj ;
			pos = {x : Std.int(Dialog.LAST_PNJ_DX), y : Std.int(Dialog.LAST_PNJ_DY)} ;
		}
		b._x = pos.x + Std.random(Math.round(shakeTimer * 10)) / 10 * (Std.random(2) * 2 - 1) ;
		b._y = pos.y + Std.random(Math.round(shakeTimer * 10)) / 10 * (Std.random(2) * 2 - 1) ;
			
		if (!infos.isHero && Dialog.me.pnj != null) {
			Dialog.me.pnj.mc._x = Dialog.me.getPnjX() + Std.random(Math.round(shakeTimer * 10)) / 10 * (Std.random(2) * 2 - 1) ;
			Dialog.me.pnj.mc._y = Dialog.me.getPnjY() + Std.random(Math.round(shakeTimer * 10)) / 10 * (Std.random(2) * 2 - 1) ;
		}
	}
	
	
	// ### PREPARE TEXT FUNCTIONS ### 
	static function convertBasic(txt:String) {
		txt = StringTools.replace(txt, "++", "%sfast%") ;
		txt = StringTools.replace(txt, "==", "%snormal%") ;
		txt = StringTools.replace(txt, "--", "%sslow%") ;
		txt = StringTools.replace(txt, "|", "%pause%") ;
		txt = StringTools.replace(txt, "*", "%shake%") ;
		txt = StringTools.replace(txt, "[", "%bold%") ;
		txt = StringTools.replace(txt, "]", "%/bold%") ;
		txt = StringTools.replace(txt, "{", "%em%") ;
		txt = StringTools.replace(txt, "}", "%/em%") ;
		
		return txt ;
	}
	
	
	
	static function splitWords(txt : String) : Array<String> {
		var res = new Array() ;
		var sub = "" ;
		for (c in txt.split("")) {
			if (Lambda.exists(WORD_ENDS, function(x) { return x == c ;})) {
				if (sub.length>0) {
					res.push(sub) ;
				}
				res.push(c) ;
				sub="" ;
			} else
				sub+=c ;
		}
		
		if (sub != "")
			res.push(sub) ;

		// merge CMD separators & keywords
		var i=0 ;
		while (i < res.length) {
			if (res[i] == CMD) {
				res[i] = CMD + res[i+1] + CMD ;
				res[i] = res[i].toLowerCase() ;
				res.splice(i + 1, 2) ;
			}
			i++ ;
		}
				
		return res ;
	}
	
	
	
	static function sanitize(wlist : Array<String>) {
		var i=0 ;
		
		// useless spaces
		while(i < wlist.length - 1) {
			var w = wlist[i] ;
			var n = i + 1 ;
			while(n < wlist.length && isCommand(wlist[n])) {
				n++ ;
			}
			if (n < wlist.length) {
				var nxt = wlist[n] ;
				if((w == " " && nxt == " ") || (w == " " && nxt == ".") || (w == " " && nxt == ",")) {
					wlist.splice(i, 1) ;
					i-- ;
				}
			}
			i++ ;
		}

		// leading spaces
		i=0 ;
		while(i < wlist.length - 1) {
			var w = wlist[i] ;
			if (!isCommand(w) && w != " ")
				break ;
			if (w == " ") {
				wlist.splice(i, 1) ;
				i-- ;
			}
			i++ ;
		}

		// trailing spaces
		i = wlist.length - 1 ;
		while(i >= 0) {
			var w = wlist[i] ;
			if (!isCommand(w) && w != " ")
				break ;
			if (w == " ") {
				wlist.splice(i, 1) ;
			}
			i-- ;
		}
		return wlist ;
	}
	
	
	static function isCommand(txt : String) {
		return txt.charAt(0) == CMD ;
	}
	
	
	function isDelim(c:String) {
		return c==" " || c=="." || c=="," || c==";" || c==":" || c=="?" || c=="!";
	}
	
	
	static function getRaw(wlist : Array<String>) {
		var l = new Array() ;
		for(w in wlist) {
			if (!isCommand(w))
				l.push(w) ;
		}
		return l.join("") ;
	}
	
	
	function getCapsRatio(str:String) {
		var caps=0 ;
		for (c in str.split("")) {
			if ( c>="A" && c<="Z" ) {
				caps++ ;
			}
		}
		return caps/str.length ;
	}
	
	
	function autoEndL() {
		var i;
		var wlist = splitWords(raw);
		field.text = "X";
		var h = field.textHeight;
		field.text = "";

		// group words + delims (unbreakable spaces)
		i=0;
		while (i<wlist.length) {
			if ( !isDelim(wlist[i]) ) {
				var j=i+1;
				var limit=0;
				while (isDelim(wlist[j]) && j<wlist.length && limit<100) {
					wlist[i] += wlist[j];
					wlist.splice(j,1);
					limit++;
				}
				if ( limit>=100 ) { trace("WARNING: limit overflow on autoEndL"); }
			}
			i++;
		}

		// auto end lines
		var t=0;
		i=0;
		var limit = 0;
		while (i<wlist.length && limit<100) {
			var w = wlist[i];
			field.text+=w;
			//trace(w + " -- " + field.text) ;
			if ( h<field.textHeight) {
			//	trace(w) ;
				var wl = w.length ;
				if (w.charAt(0) != "\n") {
					wlist.insert(i,"\n") ;
					offsetEvents(t,1) ;
					t += 2 ;
					i++ ;
				}
				field.text = field.text.substr(0, field.text.length-wl) + "\n" + w ;
				h = field.textHeight ;
			} 
			t += w.length ;
			i++ ;
			limit++ ;
		}
		if ( limit>=100 ) { trace("WARNING: limit overflow on autoEndL (loop 2)"); }
		field.text = "";


		raw = wlist.join("") ;
	}
	
	function offsetEvents(pos, offset) {
		var keys = new Array() ;
		for (k in events.h.keys()) 
			keys.push(k) ;
		
		keys.sort(function(x, y) {
			return if (x < y) 1 else -1 ;
		}) ;
		
		for (k in keys) {
			if (k < pos)
				continue ;
			var  l = events.h.get(k) ;
			events.h.set(k + offset, l) ;
			events.h.remove(k) ;
		}
		
		
	}
	
	
	
	// ### EVENTS ###
	function setEvents(wlist : Array<String>) {
		events = {nb : 0, h : new IntHash()} ;
		var t=0 ;
		for (w in wlist) {
			if (!isCommand(w)) {
				t+=w.length ;
				continue ;
			}
				
			var cmd = w.substr(1, w.length - 2) ;
			var f = null;
			switch (cmd) {
				case "sfast"	: 	f = callback(setSpeed, 2) ;
				case "snormal":	f = callback(setSpeed, 1) ;
				case "sslow"	: 	f = callback(setSpeed, 0) ;
				case "pause"	: 	f = callback(setPause, 2) ;
				case "shake"	: 	f = callback(setShake, 2) ;
				case "bold"	: 	f = callback(setColor,BOLD_COLOR) ;
				case "/bold"	: 	f = callback(setColor,DEFAULT_COLOR) ;
				case "em"	: 	f = callback(setColor,EM_COLOR) ;
				case "/em"	: 	f = callback(setColor,DEFAULT_COLOR) ;
				case "func"	: 	f = callback(launchCmdFunc);
				
			}
			
			if (f == null) {
				
				/*for (e in PNJ_FRAMES) {
					var name = "f_"+e.toLowerCase() ;
					if (name == cmd) {
						f = callback(Dialog.me.setPnjFrame, if (e == "default") defaultFrame else e) ;
						break ;
					}
				}*/
				f = callback(Dialog.me.setPnjFrame, cmd/*.substr(2)*/) ; //for debug. no check
				lastFrame = cmd ;
				
			}
			if (f == null)
				trace("unknown command : "+cmd) ;
			else
				addEvent(t, f) ;
			
		}
	}
	
	
	function isFrameEvent(s : String) : Bool {
		switch (s) {
			case "sfast"	: 	return false ;
			case "snormal":	return false ;
			case "sslow"	: 	return false ;
			case "pause"	: 	return false ;
			case "shake"	: 	return false ;
			case "bold"	: 	return false ;
			case "/bold"	: 	return false ;
			case "em"	: 	return false ;
			case "/em"	: 	return false ;
		}
		return true ;
	}
	
	
	function setAutoEvents(wlist : Array<String>) {
		var start=0 ;
		var t=0 ;
		for (w in wlist) {
			if (!isCommand(w)) {
				if (w != " " && isDelim(w)) {
					var len = t - start ;
					if (w=="!" && len > 1) 
						addEvent(start, callback(setSpeed, 2)) ;
					else if (w == "." || w == "!" || w == "?" || w == ";")
						addEvent(start, callback(setSpeed, defaultSpeed)) ;
					start=t;
				}
				t+=w.length ;
			}
		}

		t = 0 ;
		for (i in 0...wlist.length) {
			var w = wlist[i] ;
			var f = null ;
			var offset = 1 ; // event timer offset
			switch(w) {
				case "!"	: f = callback(setPause, 1.3) ;
				case "?"	: f = callback(setPause, 1) ;
				case "."	: f = callback(setPause, 0.8) ; offset = 0 ;
				case ";"	: f = callback(setPause, 0.8) ;
				case ":"	: f = callback(setPause, 0.3) ; offset = 0 ;
				//case ","	: f = callback(setPause, 0.3) ; offset = 0 ;
			}
			var nx = wlist[i+1] ;
			if ((w == "!" && nx == "!") || (w == "?" && nx == "?") || (w == "." && nx == "."))
				f = null ;

			/*if (f == null && getCapsRatio(w) >= 0.7 ) // shake on caps
				f = callback(setShake, Math.min(3.5, 2 + w.length / 8)) ;*/
			if (f != null) {
				addEvent(t + offset, f) ;
			}
			
			if (!isCommand(w))
				t += w.length ;
		}
	}
	
	
	function addEvent(k : Int, f : Void -> Void) {
		var l = null ;
		if (!events.h.exists(k))
			l = new List() ;
		else 
			l = events.h.get(k) ;
		
		l.add(f) ;
		events.nb++ ;
		events.h.set(k, l) ;
	}
	
	
	function executeEvents(t) {
		
		if (!events.h.exists(t))
			return ;
		
		var l = events.h.get(t) ;
		//trace(t + " # " + l.length + " >> " + raw.charAt(t) + " #### " + events.nb) ;
		for(e in l) {
			e() ;
			if (pauseTimer != null)
				break;
		}
		events.nb -= l.length ;
		events.h.remove(t) ; 
	}

	
}