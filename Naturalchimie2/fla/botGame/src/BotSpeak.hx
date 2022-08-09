import anim.Anim.AnimType ;
import anim.Transition ;
import BotText.PSpeak ;


typedef Bubble = {>flash.MovieClip, _text : {>flash.MovieClip, _field : flash.TextField}, _bg : {>flash.MovieClip, _sub : flash.MovieClip, _arrow : flash.MovieClip}} ;

enum SpeakStep {
	InitWait ;
	Wait ;
	Written ;
	Done ;
}
	
class BotSpeak {
	
	static var SAVE_INDEX = 10 ;
	
	
	public static var GEN_BUBBLE = {  margin : 13,
									deltaC : 4,
									deltaB : 3,
								} ;
	static var SP = 0.03 ;
	static var WAIT_INIT = 50.0 ;							
	static var WAIT_WRITTEN = 190.0 ;
	static var WAIT_POST = 60.0 ;

	static var WAIT_PNJ = 15.0 ;
	
	public var textIndex : Int ;
	public var lastIndexes : Array<Int> ;
	public var pnjIndex : Int ;
	public var mcPnj : flash.MovieClip ;
	var step : SpeakStep ;
	
	public var mc : flash.MovieClip ;
	public var dm : mt.DepthManager ;
	public var dmc : mt.DepthManager ;
	public var mcSpeak : Bubble ;
	public var mcChatCreate : Bubble ;
	
	var waitTimer : Float ;
	
	
	public function new(mp : flash.MovieClip) {
		mcPnj = mp ;
		pnjIndex = mp._currentframe ;
		
		lastIndexes = new Array() ;
		
		initMc() ;
		
		waitTimer = WAIT_INIT ;
		step = InitWait ;
	}
	
	
	function initMc() {
		
		mc = BotGame.me.mdm.empty(Const.DP_MISSION) ;
		dm = new mt.DepthManager(mc) ;
		
		mcSpeak = cast dm.empty(1) ;
		mcSpeak._bg = cast mcSpeak.createEmptyMovieClip("bg", 1) ;
		mcSpeak._text = cast mcSpeak.attachMovie("pnjSpeak", "pnjSpeak", 2) ;
		mcSpeak._x = 20 ;
		mcSpeak._y = 30 ;
		mcSpeak._alpha = 0 ;
		mcSpeak._text._field.text = "" ;
		
		dmc = new mt.DepthManager(mcSpeak._bg) ;
		mcSpeak._bg._arrow = dmc.attach("bulleArrow", 1) ;
		mcSpeak._bg._arrow.gotoAndStop(1) ;
		mcSpeak._bg._arrow._yscale = -100 ;
		
		mcChatCreate = cast dm.empty(0) ;
		mcChatCreate._bg = null ;
		mcChatCreate._text = cast dm.attach("pnjSpeak",  1) ;
		mcChatCreate._x = -1000 ;
		mcChatCreate._y = -1000 ;
		mcChatCreate._alpha = 0 ;
		
		mcChatCreate._text._field.text = "" ;
	}
	
	
	function choosePnj() {
		if (mcPnj._alpha == 100)
			return ;
		
		pnjIndex++ ;
		if (pnjIndex > mcPnj._totalframes)
			pnjIndex = 1 ;
		
		mcPnj.gotoAndStop(pnjIndex) ;
	}
	
	
	function chooseText() {
		if (textIndex != null) {
			lastIndexes.push(textIndex) ;
			if (lastIndexes.length > SAVE_INDEX)
				lastIndexes.shift() ;
		}
		
		var avText = new Array() ;
		for (i in 0...BotText.PNJSPEAK.length) {
			var t = BotText.PNJSPEAK[i] ;
			if (Lambda.exists(lastIndexes, function(x) {return x == i ;}) || (t.frame != 0 && t.frame != pnjIndex))
				continue ;
			avText.push(i) ;
		}
		
		
		textIndex = if (avText.length == 0)
					Std.random(BotText.PNJSPEAK.length) ;
				else 
					avText[Std.random(avText.length)] ;
				
	}
	
	
	public function update() {
		switch(step) {
			case Wait : //nothing to do
			
			case InitWait : 
				waitTimer = Math.max(0.0, waitTimer - 1.0 * mt.Timer.tmod) ;
				if (waitTimer == 0.0) {
					showSpeak() ;
				}
				
			case Written : 
			
				waitTimer = Math.max(0.0, waitTimer - 1.0 * mt.Timer.tmod) ;
				if (waitTimer == 0.0) {
					hideSpeak() ;
				}
			
			case Done :
				waitTimer = Math.max(0.0, waitTimer - 1.0 * mt.Timer.tmod) ;
				if (waitTimer == 0.0) {
					hidePnj() ;
				}
		}
		
	}
	
	
	function showSpeak() {
		choosePnj() ;
		chooseText() ;
		createBubble() ;
		
		if (mcPnj._alpha == 0) {
			var a = new anim.Anim(mcPnj, Alpha(1), Quint(-1), {speed : SP}) ;
			a.start() ;
				
			a = new anim.Anim(mcSpeak, Alpha(1), Quint(-1), {speed : SP}) ;
			a.sleep = WAIT_PNJ ;
			a.start() ;
		
		} else {
			var a = new anim.Anim(mcSpeak, Alpha(1), Quint(-1), {speed : SP}) ;
			a.start() ;
		}
		
		waitTimer = WAIT_WRITTEN ;
		step = Written ;
	}
	
	
	function hideSpeak() {
		var a = new anim.Anim(mcSpeak, Alpha(-1), Quint(-1), {speed : SP}) ;
		a.start() ;
		
		waitTimer = WAIT_POST ;
		step = Done ;
	}
	
	
	function hidePnj() {
		var a = new anim.Anim(mcPnj, Alpha(-1), Quint(-1), {speed : SP}) ;
		a.onEnd = callback(function(bs : BotSpeak) {
				bs.showSpeak() ;
			}, this) ;
		a.start() ;
		
		step = Wait ;
	}
	
	
	
	function createBubble() {
		var m : Bubble = mcSpeak ;
		if (m._bg._sub != null) {
			m._bg._sub.removeMovieClip() ;
			m._bg._sub = null ;
		}
		
		var d = dmc ;
		
		var text : PSpeak = BotText.PNJSPEAK[textIndex] ;
		
		mcChatCreate._text._field.text = text.text ;		
		
		var h = mcChatCreate._text._field.textHeight + GEN_BUBBLE.margin * 1.5 ;
		var l = mcChatCreate._text._field.textWidth + GEN_BUBBLE.margin * 2 ;

		m._bg._sub = cast d.empty(1) ;
	
		var start = {	x : m._text._x - GEN_BUBBLE.margin / 2, 
					y : m._text._y - GEN_BUBBLE.margin / 2} ;
		var deltaStart = {x : Std.random(GEN_BUBBLE.deltaC) * (Std.random(2) * 2 - 1), y : Std.random(GEN_BUBBLE.deltaC) * (Std.random(2) * 2 - 1)} ;
		var from = {x : start.x, y : start.y} ;
		
		m._bg._sub.beginFill(0xFFFFFF, 100) ;
		m._bg._sub.moveTo(from.x + deltaStart.x, from.y + deltaStart.y) ;
		for (i in 0...4) {
			
			var breakPoint = 0 ;
			var next = {x : from.x, y : from.y} ;
			var dd = null ;
			
			
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
				
					while(breakPoint > 0) {
						var mb = dd / 2 ;
						mb += (dd / 3) * (Std.random(2) * 2 - 1) ;
						m._bg._sub.lineTo(next.x - GEN_BUBBLE.deltaC + Std.random(GEN_BUBBLE.deltaC * 2), next.y - mb) ;
						breakPoint-- ;
					}
				
					next = start ;
			}
			
			if (i < 3) 
				m._bg._sub.lineTo(next.x, next.y) ;
			else
				m._bg._sub.lineTo(next.x + deltaStart.x, next.y + deltaStart.y) ;
			from = next ;
		}
		
		m._bg._sub.endFill() ;
		
		m._bg._arrow.gotoAndStop(Std.random(m._bg._arrow._totalframes) + 1) ;
		
			
		m._bg._arrow._x = m._bg._sub._x + m._bg._sub._width - 10 ;
		m._bg._arrow._y = 15 + Std.random(5) ;
		
		m._bg._sub.blendMode = "add";
		m._bg._arrow.blendMode = "add";
		m._bg.filters = [new flash.filters.DropShadowFilter(8,45, 0x000000,0.4,8, 8, 3)] ;
		
		mcChatCreate._text._field.text = "" ;
		
		m._text._field.text = text.text ;
	}

	
	public function kill() {
		//### TODO
	}
	
	
}