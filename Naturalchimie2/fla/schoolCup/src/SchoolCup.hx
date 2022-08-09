import mt.bumdum.Lib ;

class SchoolCup {
	
	public static var DP_BG = 0 ;
	public static var DP_GRAPH = 2 ;
	public static var DP_BUTTON = 3 ;
	public static var DP_FG = 4 ;
	public static var DP_TIP = 5 ;
		
	public static var G_START = {x : 50.0, y : 155.0} ; 
	public static var G_HEIGHT = 110 ; 
		
	public static var WIDTH  = 300 ;
	public static var HEIGHT  = 170 ;
		
	
	public static var AVG = 0 ;
	public static var BEST = 1 ;
	public static var ALL = 2 ;
	
	public static var COLORS : Array<Array<Int>> =[
		[0x84AB27, 0xE9EE87, 0xF76D18, 0x3E4D20], //GM
		[0xC8E0EA, 0xFFB521, 0x569BBE, 0x333E47], //AP
		[0xCF381A, 0xFEE7B4, 0xF76D18, 0x666633], //SK
		[0x801AC4, 0xD7ACF4, 0xFFB521, 0x190033], //JZ
	] ;
	public static var COL_BUTTON_DISABLED = 0x8B8579 ;
		public static var COL_BUTTON_ACTIVE = 0xFCECAD ;
	
	public static var DELTA_DAY = 32 ;
	
	public var root : flash.MovieClip ;
	public var mc : flash.MovieClip ;
	public var mdm : mt.DepthManager ;
	public var mcGraph : flash.MovieClip ;
		
	public var mcTip : {>flash.MovieClip, _school : flash.TextField, _points : flash.TextField} ;
		
	public var scNames : Array<String> ;
	public var byTypeInfos : Array<{min : Float, ratio : Float, values : Array<Array<Int>>}> ;
	
	public var buttons : Array<{state: Int, mc : {>flash.MovieClip, _cupName : flash.TextField}}> ;
	public var infos : Array<String> ;
	public var tfd : flash.TextFormat ;
	public var tfa : flash.TextFormat ;
	public var mcMoreInfos : {>flash.MovieClip, _field : flash.TextField} ;
	
	
	public function new(r : flash.MovieClip) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		
		root = r ;
		mc = root.createEmptyMovieClip("mc", 1) ;
		mc._x = 9 ;
		mc._y = 11 ;
		mdm = new mt.DepthManager(mc) ;
		
		initMc() ;
		initData() ;
	
		show(AVG) ;
	}
	
	
	public function initMc() {
		var bg = mdm.attach("bg", DP_BG) ;
		//mcGraph = mdm.empty(DP_GRAPH) ;
		
		
		var fg = root.attachMovie("fg", "fg", 2) ;
		
		mcTip = cast mdm.attach("tooltip", DP_TIP) ;
		mcTip._visible = false ;
		
		tfd = new flash.TextFormat(null, null, COL_BUTTON_DISABLED) ;
		tfa = new flash.TextFormat(null, null, COL_BUTTON_ACTIVE) ;
		
		mcMoreInfos = cast mdm.attach("moreInfos", DP_BUTTON) ;
		mcMoreInfos._y = 25 ;
		mcMoreInfos._field.text = "" ;
		
		var x = 0 ;
		buttons = new Array() ;
		for (i in 0...3) {
			var mcb : {state: Int, mc : {>flash.MovieClip, _cupName : flash.TextField}} = {state : 1, mc : cast mdm.attach("button", DP_BUTTON)} ;
			mcb.mc._x = x ;
			mcb.mc._y = 0 ;
			
			if (i != 0) {
				mcb.state = 3 ;
				mcb.mc._cupName.setNewTextFormat(tfd) ;
			}
				
			switch(i) {
				case 0 : mcb.mc._cupName.text = "Coupe des écoles" ;
				case 1 : mcb.mc._cupName.text = "Coupe des supers balèzes" ;
				case 2 : mcb.mc._cupName.text = "Coupe des gros tas de points" ;
				
			}
			mcb.mc.gotoAndStop(if (i == 0) 1 else 3) ; 
			
			mcb.mc.onRollOver = callback(buttonOver, cast mcb) ;
			mcb.mc.onRollOut = callback(buttonOut, cast mcb) ;
			mcb.mc.onRelease = callback(show, i) ;
			mcb.mc.onReleaseOutside = mcb.mc.onRelease ;
			
			x += 100 ;
			buttons.push(cast mcb) ;
		}
		
		
	}
	
	
	public function initData() {
		var dat : {_sc: Array<String>, _infos : List<List<{_sc : Int, _avg : Int, _best : Int, _all : Int}>>} = haxe.Unserializer.run(Base64.decode(Reflect.field(flash.Lib._root,"d"))) ;
		scNames = dat._sc ;
		byTypeInfos = [] ;
		
		for (t in 0...3) {
			
			var min = 10000000 ;
			var max = -10000000 ;
			
			byTypeInfos[t] = {min : 0.0, ratio : 1.0, values : new Array()} ;
			for (sc in 0...4) {
				var sct = new Array() ;
				for (d in dat._infos) {
					for (sd in d) {
						if (sd._sc -1 != sc)
							continue ;
						var v = null ;
						switch(t) {
							case AVG : v = sd._avg ;
							case BEST : v = sd._best ;
							case ALL : v = sd._all ;
						}
						
						sct.push(v) ;
						
						if (v < min && v > 0)
							min = v ;
						if (v > max)
							max = v ;
						break ;
					}
				}
				byTypeInfos[t].values[sc] = sct ;
			}
			
			var diff : Float = max - min ;
			diff *= 1.2 ;
			if (diff == 0)
				diff = 1.0 ;
			byTypeInfos[t].ratio = G_HEIGHT / diff ;
			byTypeInfos[t].min = min ;
			
			//trace(min + " # " + byTypeInfos[t].ratio) ;
		}
		
		
		infos = 	[Reflect.field(flash.Lib._root,"inf0"),
				Reflect.field(flash.Lib._root,"inf1"),
				Reflect.field(flash.Lib._root,"inf2")] ;

	}
	
	
	public function selectButton(g : Int) {
		for (i in 0...3) {
			var b = buttons[i] ;
			if (i == g) {
				/*b.mc.gotoAndStop(1) ; 
				b.mc._cupName.setNewTextFormat(tfa) ;*/
				b.mc._cupName.text = b.mc._cupName.text ;
				b.state = 1 ;
			} else {
				b.mc.gotoAndStop(3) ; 
				b.mc._cupName.setNewTextFormat(tfd) ;
				b.mc._cupName.text = b.mc._cupName.text ;
				b.state = 3 ;
			}
		}
		
	}
	
	
	public function show(g : Int) {
		selectButton(g) ;
		
		mcMoreInfos._field.text = infos[g] ;
		
		if (mcGraph != null)
			mcGraph.removeMovieClip() ;
		mcGraph = mdm.empty(DP_GRAPH) ;
		var gdm = new mt.DepthManager(mcGraph) ;
		var lmc = gdm.empty(0) ;
		var tr = [0, 1, 2, 3] ;
		for (j in 0...4) {
			var i = tr[Std.random(tr.length)] ;
			tr.remove(i) ;
		
			var sd = byTypeInfos[g].values[i] ;
			var x = G_START.x ;
			var y = G_START.y ;
			
			lmc.lineStyle(2, COLORS[i][0]) ;
			lmc.moveTo(x, y) ;
						
			for (d in sd) {
				x += DELTA_DAY ; 
				y = if (d == 0)
						G_START.y
					else
						G_START.y - 10 - (d - byTypeInfos[g].min) * byTypeInfos[g].ratio ;
				
				var dot = gdm.attach("dot", 2 + j) ;
				dot.onRollOver = callback(showTip, x, y, i, d, dot) ;
				dot.onRollOut = callback(hideTip, dot) ;
				dot.onReleaseOutside = dot.onRollOut ;
				
				Col.setPercentColor(dot, 100, COLORS[i][0]) ;
				dot._x = x ;
				dot._y = y ;
				lmc.lineTo(x, y) ;
			}
		}
	}
	
	
	public function update() {
		
	}
	
	
	public function showTip(x : Float, y : Float, sc : Int, pts : Int, mcDot : flash.MovieClip) {
		mcTip._school.textColor = COLORS[sc][0] ;
		mcTip._school.text = scNames[sc] ;
		
		mcTip._points.text = Std.string(pts) + " points" ;
		var px = 0.0 ;
		var py = 0.0 ;
		var delta = 10 ;
		
		for (i in 0...4) {
						
			switch(i) {
				case 0 :
					px = x + delta ;
					py = y - delta - mcTip._height ;
					if (px + mcTip._width < WIDTH && py > 0)	
						break ;
					else 
						continue ;
				case 1 :
					px = x + delta ;
					py = y + delta ;
					if (px + mcTip._width < WIDTH && py + mcTip._height < HEIGHT)	
						break ;
					else 
						continue ;
				case 2 :
					px = x - delta - mcTip._width ;
					py = y - delta - mcTip._height ;
					if (px > 0 && py > 0)	
						break ;
					else 
						continue ;
				
				case 3 :
					px = x - delta - mcTip._width ;
					py = y + delta ;
					if (px > 0 && py + mcTip._height < HEIGHT)	
						break ;
					else 
						continue ;
				
			}
		}
		
		mcTip._x = px ;
		mcTip._y = py ;
		mcTip._visible = true ;
		
		Filt.glow(mcDot, 5, 5, 0x000000) ;
		
	}
	
	
	public function hideTip(mcDot : flash.MovieClip) {
		mcTip._visible = false ;
		mcDot.filters = [] ;
	}

	
	
	public function buttonOver(b : {state: Int, mc : {>flash.MovieClip, _cupName : flash.TextField}}) {
		b.mc.gotoAndStop(2) ; 
		b.mc._cupName.setNewTextFormat(tfa) ;
		b.mc._cupName.text = b.mc._cupName.text ;
	}
	
	public function buttonOut(b : {state: Int, mc : {>flash.MovieClip, _cupName : flash.TextField}}) {
		b.mc.gotoAndStop(b.state) ; 
		b.mc._cupName.setNewTextFormat(if (b.state == 1) tfa else tfd) ;
		b.mc._cupName.text = b.mc._cupName.text ;
	}
	
	public static function main(){
		var sc = new SchoolCup(flash.Lib.current) ;
		flash.Lib.current.onEnterFrame = sc.update ;
	}
}
