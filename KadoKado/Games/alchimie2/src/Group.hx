import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import anim.Anim.AnimType ;
import anim.Transition ;
import Stage.TempEffect ;
import Game.GameStep ;
import GameData.ArtefactId ;


enum Hint {
	BottomArrow ;
}


class Group  {
	
	public var objects : mt.flash.PArray<StageObject> ;
	public var col : Int ;
	public var r : Int ;
	public var depthr : Int ;
	var targetR : Float ;
	public var isMoving : Bool ;
	public var isRotating: Bool ;
	public var currentMove : anim.Anim ;
	public var randomCol : Bool ;
	public var noMove : Bool ;
		
	public var mc : flash.MovieClip ;
	public var dm : mt.DepthManager ;
	public var mcHints : Array<{mc : flash.MovieClip, d : Int, sx : Float, sy : Float}> ;
		
	
	public function new(?e : ArtefactId, ?hide : Bool = false) {
		r = 0 ;
		depthr = 0 ;
		targetR = null ;
		isMoving = false ;
		isRotating = false ;
		col = null ;
		randomCol = false ;
		
		mc = Game.me.mdm.empty(Const.DP_NEXT_GROUP) ;
		
		mc._y = -100 ;
		dm = new mt.DepthManager(mc) ;
		
		initObjects(e) ;
		
		mc._x = getNextPosX() ;
		mc._y = if (!hide) getNextPosY() else -50 ;
			
		if (!hide)
			mc.setMask(Game.me.gui._group_mask) ;
		
		
		
		var c = 0 ;
		var dy = 0.0 ;
		var cx = if (objects.length == 2) 0.5 else 1.0 ;
		
		for (o in objects) {	
			o.place(Math.floor(c), Math.floor(dy), (c - cx) * Const.ELEMENT_SIZE, (dy) * Const.ELEMENT_SIZE) ;
			
			if (dy > 0)
				o.swapTo(1) ;
			
			c = Const.sMod(c + 1, 2) ;
			if (c == 0)
				dy-- ;
		}
		
	}
	
	
	public function getNextPosX() : Float {
		if (objects.length > 2)
			return Const.NEXTPOS.x  + 15 ;
		else if (objects.length == 1)
			return Const.NEXTPOS.x  + 30 ;
		
		return Const.NEXTPOS.x  ;
	}
	
	
	public function getNextPosY() : Float {
		if (objects.length > 2)
			return Const.NEXTPOS.y  + 15 ;
		
		return Const.NEXTPOS.y  ;
	}
	
	
	public function initObjects(?e : ArtefactId) {
		objects = new mt.flash.PArray() ;
		
		if (e == null)
			e = Game.me.mode.getNext() ;
				
		switch(e) {
			case Elts(n, p) :
				var parasit = p ;
			
				switch(parasit) {
					case Block(level) : 
						if (Game.me.mode.level < 5) {
							var n = Std.int(Math.max(1, level - 2)) ;
							if (n == 1 && Std.random(2) == 0)
								n++ ;
						
							parasit = Block(n) ;
						} else if (Game.me.mode.level < 7) 
							parasit = Block(Std.int(Math.max(1, level - 1))) ;
							
							
					default : //nothing to do
				}
			
				var laste = null ;
			
				var constElement = Game.me.mode.getRandomElement() ;
			
				if (Game.me.stage.hasEffect(FxJeseleet3))
					n = 3 ;
				else if (Game.me.stage.hasEffect(FxJeseleet4))
					n = 4 ;
				
				var countParasit = 0 ;
				for (i in 0...n) {
					var depth = n + 1 - i ;
					var r = Game.me.mode.getRandomElement(parasit != null, countParasit) ;
					
					if (r >= 0 && Game.me.stage.hasEffect(FxDaltonian))
						r = constElement ;
					
					if (n > 2 && r >= 0 && i == n - 1 && countParasit == 0) { //big group, no parasit and last element chosen
						var c = 0 ;
						while (laste == r && c < 10) {
							r = Game.me.mode.getRandomElement(parasit != null, countParasit) ;
							c++ ;
						}
					}
					laste = r ;
					
					var o = if (r < 0)
						cast StageObject.get(parasit, dm, depth) ;
					else
						cast new Element(r, dm, depth) ;
					if (r < 0)
						countParasit++ ;
						
					objects.push(o) ; 
				}
				
				
				
			default :
				var o = StageObject.get(e, dm, 2) ;
				objects.push(o) ;
				/*if (o.autoFall)
					noMove = true ;*/
					//randomCol = true ;
		}
	}
	
	
	
	public function canFall() {
		return !isMoving && !isRotating ;
	}
	
	
	function moveY( mc : flash.MovieClip , ty  : Float ) {
		var p = Math.pow(0.7,mt.Timer.tmod) ;
		mc._y = cast mc._y * p + (1 - p) * ty ;
	}
	
	
	public function isVertical() : Bool {
		return objects.length == 2 && Const.sMod(r, 2) != 0 ;
	}
	
	
	public function update() {
		var ty = Const.GROUP_Y - (if (objects.length > 2 && r >= 2) 25 else 0) ;
		moveY(mc,ty) ;

		isMoving = false ;
		if (targetR != null && mc._rotation != targetR * 1.0) {
			var dr = targetR - mc._rotation ;
			while(dr > 180) dr -= 360 ;
			while(dr <= -180) dr += 360 ;
			mc._rotation += dr * 0.48 * mt.Timer.tmod ;
			isMoving = Math.abs(dr) > 7 ;
			isRotating = Math.abs(dr) > 8 ;
			
			if (depthr < 45)
				updateDepths() ;
			
			if (mc._rotation == targetR) {
				targetR = null ;
			}
		
			for (o in objects) {
				o.omc.mc._rotation = -mc._rotation ;
				
			}
		}

		var dx =getDeltaX() ;
		var calcx = Std.int((mc._x - Stage.X) / Const.ELEMENT_SIZE) + dx ;
		
		var bigx = Math.round((mc._x - Stage.X) / Const.ELEMENT_SIZE) + Std.int(dx) ;
				
		var maxx = getMaxWidth() ;
			

		if( col == null )
			col = calcx;

		if( calcx < 0 )
			calcx = 0;
		else if( calcx > maxx )
			calcx = maxx;
		if( col > maxx )
			col = maxx;
		else if( col < 0 )
			col = 0;
		
		
		var s = Math.min(7 * mt.Timer.tmod,20) ;
		var ds = 0.0 ;
		if(!noMove && Game.me.pLeft && bigx > 0 ) {
			col = bigx - 1;
			ds = -s ;
			isMoving = true;
		} else if(!noMove && Game.me.pRight && calcx < maxx ) {
			col = calcx + 1;
			ds = s;
			isMoving = true;
		} else { //recal
			var px = 0.0 ;			
			var py = null ;
			if (objects.length == 2) {
				px =  (col + (if (Const.sMod(r, 2) != 0) 0.0 else 0.5)) * Const.ELEMENT_SIZE + Stage.X ;
			} else {
				px = (col + (if (r == 1) 0 else if (r == 0) 1.0 else if (r == 2) 0.0 else 1.0)) * Const.ELEMENT_SIZE + Stage.X ;
				/*if (r < 2)
					py = 60 ;
				else 
					py = 25 ;*/
			}
			var p = Math.pow(0.7,mt.Timer.tmod) ;
			isMoving = (Math.abs(mc._x - px) > 6) ;
			mc._x = mc._x * p + px * (1 - p) ;
			
		}
		
		mc._x += ds ;
		
		updateHints() ;
	}
	
	
	function addHint(h : Hint) { 
		var nh = null ;
		switch(h) {
			case BottomArrow :
				nh = {mc : dm.attach("bottomArrow", 5),
					d : 2,
					sx : -15.0,
					sy : mc._height - 7} ;
				nh.mc._x = nh.sx ;
				nh.mc._y = nh.sy ;
		
		}
		
		if (nh != null)
			mcHints.push(nh) ;
	}
	
	
	function updateHints() {
		if (mcHints.length == 0)
			return ;
		
		
	}
	
	
	function updateDepths() {
		if (depthr == r)
			return ;
		
		depthr = r ;
		
		switch(objects.length) {
			case 1 : return ;
			case 2 : 
				if (r == 1 || r == 2) {
					objects[0].swapTo(1) ;
					objects[1].swapTo(2) ;
				} else {
					objects[0].swapTo(2) ;
					objects[1].swapTo(1) ;
				}
					
				
			case  3 : 
				switch(r) {
					case 0 : 
						objects[0].swapTo(3) ;
						objects[1].swapTo(2) ;
						objects[2].swapTo(1) ;
					case 1 : 
						objects[0].swapTo(1) ;
						objects[1].swapTo(2) ;
						objects[2].swapTo(3) ;
					case 2 : 
						objects[0].swapTo(1) ;
						objects[1].swapTo(2) ;
						objects[2].swapTo(3) ;
					case 3 : 
						objects[0].swapTo(2) ;
						objects[1].swapTo(1) ;
						objects[2].swapTo(3) ;
				}
			
			case 4 : 
				switch(r) {
					case 0 : 
						objects[0].swapTo(4) ;
						objects[1].swapTo(3) ;
						objects[2].swapTo(2) ;
						objects[3].swapTo(1) ;
					case 1 : 
						objects[0].swapTo(2) ;
						objects[1].swapTo(4) ;
						objects[2].swapTo(1) ;
						objects[3].swapTo(3) ;
					case 2 : 
						objects[0].swapTo(1) ;
						objects[1].swapTo(2) ;
						objects[2].swapTo(3) ;
						objects[3].swapTo(4) ;
					case 3 : 
						objects[0].swapTo(3) ;
						objects[1].swapTo(1) ;
						objects[2].swapTo(4) ;
						objects[3].swapTo(2) ;
				}
		
		}
	}
	
	public function getObjectCol(index) : Float {
		
		switch(objects.length) {
			case 1 : 
				return col ;
			case 2 :
				if (r == 1 || r == 3)
					return col ;
				else {
					if (r == 0)
						return col + index ;
					else 
						return col + 1 - index ;
				}
			default :
				switch(r) {
					case 0 : 
						return if (Const.sMod(index, 2) == 0) col else col + 1 ;
					case 1 : 
						return if (index < 2) col else col + 1 ;
					case 2 : 
						return if (Const.sMod(index, 2) == 0) col + 1 else col ;
					case 3 : 
						return if (index < 2) col + 1 else col ;
					default : 
						throw "getObjectCol error : " + r ;
						return null ;
					
				}
		}
		
	}
	
	
	function getMaxWidth() : Int {
		var c = 1 ;
		switch(objects.length) {
			case 1 : 
				c = 1 ;
			case 2 : 
				c = if (r == 0 || r == 2) 2 else 1 ;
			case 3 : 
				c = 2 ;
			case 4 : 
				c = 2 ;
			default : 
				c = 1 ;
		}
		
		return Stage.WIDTH - c ;
	}
	

	
	public function toStage(?f) {
		mc.setMask(null) ;
		Game.me.mdm.swap(mc, Const.DP_GROUP) ;
		col = if (!randomCol)
				2 ;
			else  {
				var c  = Game.me.stage.chooseFreeColumn() ;
				if (c == null) //game over, no more place
					Std.random(Stage.WIDTH) ;
				else 
					c ;
			}
		var cx = if (objects.length == 2) 0.5 else 1.0 ;
			
		for (o in objects)
			o.onStage() ;
		
		//Game.me.stage.effectCheckFall() ;
		
		var func = callback(function(t : Group, f : Void -> Void) {
			if (f != null)
				f() ;
			var a = false ;
			for (o in t.objects) {
				a = a || o.autoFall ;
			}
			
			if (a) {
				t.addHint(BottomArrow) ;
				//Game.me.stage.startFall() ;
			}
		}, this, f) ;
		
		move(Stage.X+ (col + cx) * Const.ELEMENT_SIZE, -100, true) ;
		move(mc._x, Const.GROUP_Y - 30, false, func, Linear, 0.1) ;
		
	}
	
	
	public function toNextBox() {
		mc.setMask(Game.me.gui._group_mask) ;
		move(mc._x, getNextPosY()) ;
	}

	
	public function move(nx : Float, ny : Float, ?instant : Bool = false, ?f : Void -> Void, ?tf : {c : Float, f : Void -> Void}, ?t : Transition, ?s : Float) {
		
		if (instant) {
			mc._x = nx ;
			mc._y = ny ;
		} else {
			isMoving = true ;

			if (currentMove != null)
				currentMove.kill() ;
			currentMove = new anim.Anim(mc, Translation, if (t == null) Quart(-1) else t, {x : nx, y : ny, speed : if (s == null) 0.05 else s}) ;
			currentMove.onEnd = callback(function(g : Group, func : Void -> Void) {
										g.currentMove = null ;
										g.isMoving = false ;
										if (f != null)
											f() ;
									}, this, f) ;
			if (tf != null)
				currentMove.addOnCoef(tf.c, tf.f) ;
				
			currentMove.start() ;
		}
	
	}
	
	
	public function startRotate() {
		if (/*isMoving ||*/ isRotating || objects.length <= 1)
			return ;
		
		isRotating = true ;
		
		r = Const.sMod(r + 1, 4) ;		
		switch(r) {
			case 0 : 
				targetR = 0 ;
			case 1 :
				targetR = 90 ;
				dm.over(objects[0].omc.mc) ;
			case 2 : 
				targetR = 180 ;
			case 3 :
				targetR = -90 ;
				dm.over(objects[1].omc.mc) ;
		}
		
		var i = 0 ;
		while (i < objects.length) {
			var e = objects[i] ;
			switch(r) {
				case 0 : 
					e.x = if (Const.sMod(i, 2) == 0) 0 else 1 ;
					e.y = if (i > 1) -1 else 0 ;
				case 1 :
					e.x = if (i <= 1) 0 else 1 ;
					e.y = if (Const.sMod(i, 2) == 0) -1 else 0 ;
				case 2 : 
					e.x = if (Const.sMod(i, 2) != 0) 0 else 1 ;
					e.y = if (i <= 1) (if (objects.length > 2) -1 else 0) else 0 ;
				case 3 :
					e.x = if (i > 1) 0 else (if (objects.length > 2) 1 else 0) ;
					e.y = if (Const.sMod(i, 2) != 0) -1 else 0 ;					
			}
			
			i++ ;
		}
	}
	
	
	function getDeltaX() {
		return if (objects.length == 2)
					0
				else {
					switch(r) {
						case 0 : -1 ;
						case 1 : 0 ;
						case 2 : 0 ;
						case 3 : -1 ;
					}
				}
	}
	
	
	public function kill() {
		mc.setMask(null) ;
		
		for (o in objects) {
			o.kill() ;
		}
		
		for (h in mcHints) {
			if (h.mc != null)
				h.mc.removeMovieClip() ;
		}
		mcHints = [] ;
		
		if (currentMove != null)
			currentMove.kill() ;
		
		if (mc != null)
			mc.removeMovieClip() ;
	}
	
	
	static public function forceNext(g : Group) {
		
		g.mc.setMask(Game.me.gui._force_group_mask) ;
		g.move(g.getNextPosX(), g.getNextPosY() + 100, true) ;
		
		var n = Game.me.stage.nexts.first() ;
		if (n != null)
			n.move(n.getNextPosX(), n.getNextPosY() - 100, false) ;
		
		var f = callback(function(og : Group, ng : Group) {
			//Game.me.setStep(Play) ;
			if (og != null) {
				og.move(og.getNextPosX(), -50, true) ;
				og.mc.setMask(null) ;
			}
			g.mc.setMask(Game.me.gui._group_mask) ;
			
		}, n, g) ;
		
		Game.me.stage.nexts.push(g) ;
		g.move(g.getNextPosX(), g.getNextPosY(), false, f) ;
		
		//Game.me.setStep(Wait) ; 
	}
	
}