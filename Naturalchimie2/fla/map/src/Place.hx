import mt.bumdum.Lib ;
import Map.Bounds ;


class Place {

	public var map : ScrollMap ;
	public var mc : flash.MovieClip ;
	public var id : String;
	public var px : Float;
	public var py : Float;
	public var target : Bool;
	public var confirm : Bool;
	public var text : String;
	public var pa : Int ;
	public var from : Place ;
	public var road : Array<Array<Float>> ;
	public var known : Bool ;
	public var chain : Array<Int> ;
	public var objects : Bool ;
	public var valid : Bool ;
	public var gColor : Int ;
		
	public var mcQuest : flash.MovieClip ;
	public var mcCup : flash.MovieClip ;
	

	public function new(m, p, dm) {
		id = p._id ;
		map = m ;
		target = false ;
		var depth = 3 ;
		
		if (id == "current")
			mc = dm.attach("city",depth) ;
		else {
			mc = dm.attach(id, depth) ;
			if (mc == null)
				mc = dm.attach("city",depth) ;
		}
		
		mc._xscale = Map.COORD_SCALE ;
		mc._yscale = mc._xscale ;
		
		known = p._known ;
		chain = p._chain ;
		objects = p._objects ;
		valid = p._valid ;
		var inf = p._inf.split(":") ;
		if( inf == null ) {
			// hack
			var r = new mt.Rand(id.charCodeAt(0)+id.charCodeAt(1)+id.charCodeAt(3)) ;
			inf = cast [
				50 + r.random(500),
				50 + r.random(300)
			];
		}
		
		text = /*if (!known) "Zone inconnue" else*/ p._name ;
		
		px = Std.parseFloat(inf[0]) * Map.COORD_SCALE / 100 ;
		py = Std.parseFloat(inf[1]) * Map.COORD_SCALE / 100 ;
		mc._x = px ;
		mc._y = py ;
		
		if (inf[2] == null || inf[2] == "")
			inf[2] = "default" ;
	
			
		mc.gotoAndStop(inf[2]);
		//if (id != "current") {
			mc.onRollOver = callback(map.show,this) ;
			mc.onRollOut = mc.onReleaseOutside = callback(map.hideText) ;
			mc.useHandCursor = false;
		
			mc._visible = false ;
		//}
		
		if (p._quests > 0) { 
			var qb = mc.getBounds(Map.me.bg) ;
			var xqpc = -6 ;
			var yqpc = 106 ;
			var qx = qb.xMin + (qb.xMax - qb.xMin) * xqpc / 100 ;
			var qy = qb.yMin + (qb.yMax - qb.yMin) * yqpc / 100 ;
			mcQuest = dm.attach("questico", 4) ;
			//mcQuest.gotoAndStop(4) ;
			//mcQuest._alpha = 75 ;
			mcQuest._xscale = mcQuest._yscale = 75 ;
			mcQuest._x = qx ;
			mcQuest._y = qy ;
		}
				
		if (p._schoolCup) {
			var qb = mc.getBounds(Map.me.bg) ;
			var xqpc = 106 ;
			var yqpc = 106 ;
			var qx = qb.xMin + (qb.xMax - qb.xMin) * xqpc / 100 ;
			var qy = qb.yMin + (qb.yMax - qb.yMin) * yqpc / 100 ;
			mcCup = dm.attach("cupico", 4) ;
			mcCup._xscale = mcCup._yscale = 85 ;
			//mcCup.gotoAndStop(4) ;
			//mcCup._alpha = 75 ;
			mcCup._x = qx ;
			mcCup._y = qy ;
		}
		
		initChain() ;
		
		/*if (!valid)
			mc.gotoAndStop(5);*/
		
		/*if (!known) //jamais visité
			Col.setPercentColor(mc,70,0x888888) ;*/
	}
	
	
	function initChain() {
		
		
	}
	

	public function selectAsCurrent() {
		setDefaultGlow(mc, Map.HIGHLIGHT_PLACE_COL) ;
		//map.showUser(this) ;
		//Map.me.showUser(this) ;
		Map.me.currentPlace = this ;
		
		mc._visible = true ;
		
		this.text = (if (!known) this.text else text) ;
		
		mc.onRelease = Map.me.exit ;
		
		/*mc.onRollOver = null ;
		mc.onRollOut = mc.onReleaseOutside = null ;*/
	}
	
	
	static public function setDefaultGlow(m : flash.MovieClip, ?c) {
		if (c==null) {c = Map.PLACE_COL;}

		if (c == Map.PLACE_COL) {
			//m.filters = [new flash.filters.GlowFilter(c,0.6,6.4,6.4,2, 2, false, true)] ;
			m.filters = [
				new flash.filters.GlowFilter(c,0.6,1.3,1.3,4, 2, true, true),
				new flash.filters.GlowFilter(c,0.7,4.4,4.4,3, 2, false, false)
				] ;

		} else 
			//m.filters = [new flash.filters.GlowFilter(c,0.8,3,3,10, 2, false, true)] ; 
			m.filters = [
				new flash.filters.GlowFilter(c,0.9,1.3,1.3,10, 2, true, true),
				new flash.filters.GlowFilter(c,0.6,6.4,6.4,2, 2, false, false)
				] ;

			 
	}

	
	
	public function getBounds() : Bounds {
		return {
			xMin : px,
			xMax : px,
			yMin : py,
			yMax : py
		} ;
	}

	
	public function selectAsTarget(text,confirm, p, f) {
		if (id == "current")
			return ;

		if (p <= Map.me.data._pamax) {
			gColor = Map.HIGHLIGHT_PLACE_COL ;
			setDefaultGlow(mc, gColor) ;
			
			target = true ;
			this.confirm = confirm;
			this.text = /*(if (pa != null) "(" + pa + ") " else "") +*/ /*(if (!known) this.text else text) ;*/ text ;
			mc.useHandCursor = true;
			mc.onRelease = callback(map.goto,this,confirm) ;
		} else {
			setDefaultGlow(mc) ;
			this.text = /*(if (pa != null) "(" + pa + ") " else "") + */ /*(if (!known) this.text else text) ;*/ text ;
		}
		pa = p ;
		from = f ;
		
		
		
		mc._visible = true ;
		
		
		//map.blinks.push( {mc:mc,t:0.0} );
	}
	
	
	public function kill() {
		if (mc != null /*&& id == "current"*/)
			mc.removeMovieClip() ;
		if (mcQuest != null)
			mcQuest.removeMovieClip() ;
		if (mcCup != null)
			mcCup.removeMovieClip() ;
	}

}