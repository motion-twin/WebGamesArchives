import mt.bumdum.Lib ;
import GameData._ArtefactId ;
import flash.Key ;
import anim.Anim.AnimType ;
import anim.Transition ;
import Cauldron.Drop ;
import Cauldron.Step ;


typedef InvObject = {o : _ArtefactId, drops : mt.flash.Volatile<Int>, qty : mt.flash.Volatile<Int>, omc : ObjectMc, mcQty : {>flash.MovieClip, _field : flash.TextField},  isElement : Bool, r : Float, rr : {from : Float, d : Float}} ;


class Inventory {
	
	static public var DP_OBJECTS = 2 ;
	static public var DP_ARROW = 4 ;
		
	static var ARROW_NEED = 12 ;
	static var CIRCLE_LIMIT = 22 ; /* old one : 24 */
	
	static public var SCALE_OVER = 100 ;
	
	static public var DX = 0 ;
	static public var ARROW_Y = 300 ; /*30 ;*/
	//static public var OBJECT_Y = 260 ; /*20 ;*/
	static public var OBJECT_START_X = 50 ;
	static public var OBJECT_DELTA_X = 42 ;
		
	
	static var CIRCLE_CENTER_X = [230,240] ;
	static var CIRCLE_CENTER_Y = [220, 212] ;
	static var CIRCLE_RAY = [170, 160] ;

	
	static var OBJECT_SPEED = 0.052 ;
	static var DEC_SPEED = 0.0015 ;
	static var SPEED_NULL = 0.005 ;


	
	public var objects : Array<InvObject> ;
	public var waitZone : Array<InvObject> ;
	public var drops : Array<InvObject> ;
	
	public var dm : mt.DepthManager ;
	public var mc : flash.MovieClip ;
	
	public var mcLeft : flash.MovieClip ;
	public var mcRight : flash.MovieClip ;
		
	public var speed : Float ;
	public var speedSide : Int ;
	public var slowInfos : {timer : Float, from : Float} ;
	public var isMoving : Bool ;
	public var countLoad : Int ;
	public var cp : Float ;
	var total : Int ;
	public var countDrop : Int ;
	
	
	
	public function new() {
		countLoad = 0 ;
		cp = 0.0 ;
		drops = new Array() ;
		countDrop = 0 ;
		initMcs() ;
	}
	
	
	function initMcs() {
		mc = Cauldron.me.mdm.empty(Cauldron.DP_ELEMENTS) ;
		dm = new mt.DepthManager(mc) ;
		
		var isElement = true ;
		objects = new Array() ;
		waitZone = new Array() ;
		total = Cauldron.me.data._elements.length + Cauldron.me.data._objects.length ;
	
		var i = 0 ;

		for (t in [Cauldron.me.data._elements, Cauldron.me.data._objects]) {
			for (e in t) {
					
				var over = true ;
				var ii = i ;
				if (i >= CIRCLE_LIMIT) {
					ii = i - CIRCLE_LIMIT ; 
					over = false ;
				}
					
				var o : InvObject = {
					o : e._o,
					qty : e._qty,
					drops : 0,
					omc : new ObjectMc(e._o, Cauldron.me.mdm, if (i < CIRCLE_LIMIT) Cauldron.DP_ELEMENTS else Cauldron.DP_ELEMENTS_BG/*, f*/),
					mcQty : null,
					isElement : isElement,
					r : null,
					rr : null
				};
				o.qty = e._qty ;
				o.drops = 0 ;
				
				o.mcQty = cast o.omc.mc.attachMovie("mcQty", "mcQty_" + i, 2) ;
				o.mcQty._x = -17 ;
				o.mcQty._y = 13 ;
				o.mcQty._field.text = Std.string(o.qty) ;
				
				
				if (over) {
					o.omc.mc.onRollOver = callback(onRollOver, cast o.omc.mc, o.mcQty) ;
					o.omc.mc.onRelease = callback(drop, i) ;
				}
				o.omc.mc.onRollOut = callback(onRollOut, cast o.omc.mc, o.mcQty) ;		
				o.omc.mc.onReleaseOutside = o.omc.mc.onRollOut ;
				
			
				if (countLoad == null)
					return ;
				
				countLoad++ ;
				
				if (i < CIRCLE_LIMIT)
					objects.push(o) ;
				else
					waitZone.push(o) ;
				
				if (countLoad >= total) {
					countLoad = null ;
					initObjects() ;
				}
				

				i++ ;
			}
			isElement = false ;
		}
		
		//if (needArrows())
			initArrows() ;

	}
	
	
	function needArrows() {
		return objects.length >= ARROW_NEED ;
	}
	
	
	public function initObjects() {
		
		var x = if (needArrows()) OBJECT_START_X else ((Cauldron.WIDTH - objects.length * OBJECT_DELTA_X) / 2) ;
			
		var p = 1.0 ;
		var l = objects.length ;
		var n = if (secure.Utils.sMod(objects.length, 2) == 0)
					-l / 2 + 0.5 ;
				else
					-(l - 1) / 2 ;

		for (i in 0...objects.length) {
			var o = objects[i] ;
			
			o.r = (( n * Const.RAD ) / CIRCLE_LIMIT) % Const.RAD ;
			if (o.r < 0.0)
				o.r += Const.RAD ;
			
			var b = isOnBg(o.r) ;
			if (b)
				switchPlan(o, i, b) ;
			
			setPos(o) ;
			n += p ;
			
			objectRender(o.omc.mc);
		}
		
		dpSort() ;
	}
	
	
	function setPos(o : InvObject) {
		var cc = getCirclePos(o.r) ;
		
		o.omc.mc._x = cc.x ;
		o.omc.mc._y = cc.y ;
	}
	
	
	public function getCirclePos(r : Float) : {x : Float, y : Float} {
		var rr : Float = (r + cp) * 2 ;
		if (rr < 0.0)
			rr += Const.RAD ;
		
		return {x : (Math.sin(r) * CIRCLE_RAY[Cauldron.me.cIdx]) + CIRCLE_CENTER_X[Cauldron.me.cIdx],
				y : ( Math.cos(r) * 35) + CIRCLE_CENTER_Y[Cauldron.me.cIdx] /*+ Math.sin(rr) * 8*/} ;
	}
	
	
	function initArrows() {
		mcLeft = dm.attach("arrow", DP_ARROW) ;
		mcLeft._x = DX ;
		mcLeft._y = ARROW_Y ;
		mcLeft.gotoAndStop(1) ;
		
		
		mcRight = dm.attach("arrow", DP_ARROW) ;
		//mcRight._rotation = 180 ;
		mcRight._xscale = -100 ;
		mcRight._x = Cauldron.WIDTH - DX ;
		mcRight._y = ARROW_Y ;
		mcRight.gotoAndStop(1) ;
		
		mcLeft.onPress = function() {Cauldron.me.inventory.mcLeft.gotoAndStop(2) ; Cauldron.me.inventory.setSpeed(-1) ;} ;
		mcRight.onPress = function() {Cauldron.me.inventory.mcRight.gotoAndStop(2) ; Cauldron.me.inventory.setSpeed(1) ;} ;
		mcLeft.onMouseUp = function() {Cauldron.me.inventory.mcLeft.gotoAndStop(1) ; Cauldron.me.inventory.slow() ;} ;
		mcRight.onMouseUp = function() {Cauldron.me.inventory.mcRight.gotoAndStop(1) ; Cauldron.me.inventory.slow() ;} ;
		
		initKeyListener() ;
	}
	
	
	public function getObject(id : _ArtefactId) : InvObject {
		for (t in [waitZone, objects]) {
			for (o in t) {
				if (Type.enumEq(id, o.o))
					return o ;

			}
		}
		return null ;
	}
	
	
	public function getEmptyRad() : {r : Float, recal : Int} {
		if (total < CIRCLE_LIMIT)
			return {r : objects[objects.length - 1].r + Const.RAD / CIRCLE_LIMIT, recal : null} ;
		else {
			var i = getRadIndex(0.0) ;
			var p = if (i == 0) objects[objects.length - 1] else objects[i - 1] ;
			
			return {r : (p.r + Const.RAD / (CIRCLE_LIMIT * 2)) % Const.RAD, recal : i} ;
		}
	}
	
	
	public function initRecal(r : Float, index : Int) {
		var p = Const.RAD / (CIRCLE_LIMIT * 2) ;
		
		if (r < Const.RAD / 2)
			r += Const.RAD ;
		
		for (i in  0...objects.length) {
			var o = objects[i] ;
			var rr = o.r ;
			if (rr < Const.RAD / 2)
				rr += Const.RAD ;
			
			if (rr <= r) {
				o.rr = {d : -p, from : o.r} ;
			} else 
				o.rr = {d : p, from : o.r} ;
			
			//trace(o.o + " > " + o.rr + " (" + r + ") # " + o.rr.d) ;
		}
	}
	
	
	public function recal(rIndex : Int, c : Float) {
		for (i in 0...objects.length) {
			var o = objects[i] ;
			
			var dr = o.rr.d * Math.pow(c, 5) ;
			o.r = o.rr.from ;
			move(o, i, dr, true) ;
		}
		dpSort() ;
		
		
	}
	
	
	public function isOnBg(r : Float) {
		return r >= Const.RAD / 4 && r <= 3 * Const.RAD / 4 ;
	}
	
	public function isHidden(r : Float) {
		return r >= 4 * Const.RAD / 8 && r <= 4 * Const.RAD / 8 ;
	}
	
	
	function onWaitZone(old : Float, n : Float) : Int {
		if (old >= Const.RAD / 2 && n < Const.RAD  / 2 && n > Const.RAD / 4)
			return -1 ;
		else if (old < Const.RAD / 2 && n >= Const.RAD  / 2 && n < Const.RAD * 3  /4)
			return 1 ;
		else 
			return 0 ;
		
	}
	
	
	public function loop() {
		if (speed != null) {
			moveObjects() ;
			
			/*if (!isMoving) {
				speed = speedSide * (Math.abs(speed) - DEC_SPEED * mt.Timer.tmod) ;
				if (Math.abs(speed) < SPEED_NULL)
					stop() ;
			}*/
			
			if (slowInfos != null) {
				slowInfos.timer = Math.min(slowInfos.timer + 0.055 * mt.Timer.tmod, 1) ;
				var delta = 1 - anim.TransitionFunctions.quart(1 - slowInfos.timer) ;
				
				var s = slowInfos.from * (1 - delta) ;
				speed = speedSide * s ;
				
				//trace(slowInfos.timer + " # from : " + slowInfos.from  + " # speed : " + speed) ;
				
				if (slowInfos.timer == 1) {
					slowInfos = null ;
					speed = null ;
				}
				
			}
		}
		
	}
	
	
	function moveObjects() {
		cp = (cp + 0.2 * -speedSide) % Const.RAD ;
		if (cp < 0.0)
			cp += Const.RAD ;
		
		for (i in 0...objects.length) {
			move(objects[i], i, speed * mt.Timer.tmod) ;
		}
		
		dpSort() ;
	}
	
	
	
	function move(o : InvObject, index : Int, dr : Float, ?noWaitOut : Bool) {
		if (noWaitOut == null)
			noWaitOut  = false ;
		
		var oldR = o.r ;
		o.r = (o.r + dr) % Const.RAD ;
		if (o.r < 0)
			o.r += Const.RAD ;
		
		var wz = onWaitZone(oldR, o.r) ;
			
		if (waitZone.length > 0 && wz != 0) {
			var wo = null ;
			if (wz > 0) {
				wo = if (!noWaitOut) waitZone.pop() else null ;
				waitZone = [o].concat(waitZone) ;
			} else {
				wo = if (!noWaitOut) waitZone.shift() else null ;
				waitZone.push(o) ;
			}
			
			if (wo != null)
				wo.r = o.r ;
			o.r = Const.RAD / 2 ;
			o.omc.mc._visible = false ;
			setPos(o) ;
			
			if (wo != null) {
				wo.omc.mc._visible = true ;
				setPos(wo) ;
				objects[index] = wo ;
			} else
				objects.remove(o) ;
					
		} else 
			setPos(o) ;
		
		var onBg = isOnBg(o.r) ;
		if (onBg != isOnBg(oldR)) {
			/*if (Type.enumEq(o.o, Elt(5)) || Type.enumEq(o.o, Elt(6)))
				trace("swap " + o.o  + " > " + o.r  + " # " + onBg) ;*/
			switchPlan(o, index, onBg) ;
		}
		
	}
	
	
	function switchPlan(o : InvObject, index : Int, onBg : Bool) {
		Cauldron.me.mdm.swap(o.omc.mc, if (onBg) Cauldron.DP_ELEMENTS_BG else Cauldron.DP_ELEMENTS) ;
		Cauldron.me.mdm.under(o.omc.mc) ;
		
		o.omc.mc.useHandCursor = !onBg ;
		
		if (onBg) {
			o.omc.mc.onRelease = null ;
			o.omc.mc.onRollOver = null ;
		} else {
			o.omc.mc.onRelease = callback(this.drop, index) ;
			o.omc.mc.onRollOver = callback(onRollOver, cast o.omc.mc, o.mcQty) ;
		}
	}
	
	
	function dpSort() {
		var dps = objects.copy() ;
		
		dps.sort(function(a, b) {
			if (Math.abs(Const.RAD / 2 - a.r) < Math.abs(Const.RAD / 2 - b.r))
				return -1 ;
			else 
				return 1 ;
		}) ;
		
		for (o in dps) {
			Cauldron.me.mdm.over(o.omc.mc) ;

			if (!isHidden(o.r)) {
				var opa = 80 -(Math.abs(Const.RAD / 2 - o.r) / 3.14) * 80 ;
				Col.setPercentColor(o.omc.mc, opa , 0x2B2524) ;
			}
		}
	}
	
	
	//### PLOUF 
	public function drop(index : Int) {
		if (Cauldron.me.step != Default || Cauldron.me.dialog != null)
			return ;
		
		var o = objects[index] ;
		
		if (o == null || o.qty <= 0)
			return ;
		
		if (o.drops == 0)
			drops.push(o) ;
		
		countDrop++ ;
		
		o.qty -- ;
		o.mcQty._field.text = Std.string(o.qty) ;
		o.drops++ ;
		
		Cauldron.me.enableSubmit(true) ;
		
		
		if (o.qty == 0) {
			Col.setPercentColor(o.omc.mc._b, 70, 0xCCCCCC) ;
			o.omc.mc._b._alpha = 90 ;
		}
		
		var d = {omc : null,
			cOmc : null,
			rOmc : null,
			sOmc : null,
			cMask : null,
			rMask : null,
			sMask : null,
			timer : 0.0,
			x : o.omc.mc._x,
			y : o.omc.mc._y,
			sx : o.omc.mc._x,
			sy : o.omc.mc._y,
			ex : Cauldron.me.mcCauldron._x + Cauldron.me.mcCauldron._soupe._x + Const.DROP_RECAL_X[Cauldron.me.cIdx] + (Std.random(2) * 2 -1) * Std.random(Const.DROP_RD_X[Cauldron.me.cIdx]), 
			ey : Cauldron.me.mcCauldron._y + Cauldron.me.mcCauldron._soupe._y + Const.DROP_RECAL_Y[Cauldron.me.cIdx] - Std.random(Const.DROP_RD_Y[Cauldron.me.cIdx]), 
			zf : 90.0 + Std.random(80),
			vr : (Std.random(2) * 2 - 1) * Math.random() * 10,
			h : Std.random(25) * 1.0,
			step : 0,
			sp : 0.038,
			weight : 0.002,
			frict : 0.96,
			back : null,
			rDecal : 0.0
		} ;
		
		var param = if (o.omc.infos.length > 2) o.omc.infos[2] else null ;

		d.omc = new ObjectMc(o.o, Cauldron.me.mdm, Cauldron.DP_DROPS, null, null, param) ;
		d.cOmc = new ObjectMc(o.o, Cauldron.me.ddm, 3, null, null, param) ;
		d.rOmc = new ObjectMc(o.o, Cauldron.me.ddm, 2, null, null, param) ;
		d.sOmc = new ObjectMc(o.o, Cauldron.me.ddm, 1, null, null, param) ;
				
		var mLim = d.ey ;
		
		d.cMask = Cauldron.me.ddm.attach("drop_mask", 5) ;
		d.cMask._x = 120 ;
		d.cMask._y = mLim ;
		d.cMask._alpha = 0 ;
		d.cMask._yscale = -300 ;
		
		
		d.rMask = Cauldron.me.ddm.attach("drop_mask", 6) ;
		d.rMask._x = 120 ;
		d.rMask._alpha = 0 ;
		d.rMask._y = mLim ;
		
		d.sMask = Cauldron.me.ddm.attach("drop_mask", 4) ;
		d.sMask._x = 120 ;
		d.sMask._alpha = 0 ;
		d.sMask._y = mLim ;
		
		d.back = 0.1 + 1.7 / 25 * d.h ;
		d.rDecal = 6.0 +  3 / 25 * d.h ;
		d.ey += d.rDecal ;
		
		
		//var f = callback(function(d : Drop) {
			d.omc.mc._x = d.x ;
			d.omc.mc._y = d.y ;
			d.omc.mc._xscale = SCALE_OVER ;
			d.omc.mc._yscale = d.omc.mc._xscale ;
			Cauldron.me.drops.push(d) ;
			
			//d.omc.mc.smc.smc.smc.smc.gotoAndStop(1) ;
			
			d.cMask._y -= d.omc.mc._b._y ;
			d.rMask._y -= d.omc.mc._b._y ;
			d.sMask._y -= d.omc.mc._b._y ;
		//}, d) ;
		
		//var cf = callback(function(d : Drop) {
			d.cOmc.mc._x = -100 ;
			d.cOmc.mc._y = -100 ;
			d.cOmc.mc._xscale = SCALE_OVER;
			d.cOmc.mc._yscale = d.cOmc.mc._xscale ;
			d.cOmc.mc._visible = false ;
			
			//d.cOmc.mc.smc.smc.smc.smc.gotoAndStop(1) ;
			
			d.cOmc.mc.setMask(d.cMask) ;
	//	}, d) ;
		
	//	var rf = callback(function(d : Drop) {
			d.rOmc.mc._x = -100 ;
			d.rOmc.mc._y = -100 ;
			d.rOmc.mc._xscale = SCALE_OVER ;
			d.rOmc.mc._yscale = d.omc.mc._xscale * -1 * 1.15 ;
			d.rOmc.mc._alpha = 30 ;
			
			d.rOmc.mc.smc.smc.smc.smc.gotoAndStop(1) ;
			
			d.rOmc.mc.setMask(d.rMask) ;
		//}, d) ;
		
		//var sf = callback(function(d : Drop) {
			d.sOmc.mc._x = -100 ;
			d.sOmc.mc._y = -100 ;
			d.sOmc.mc._xscale = SCALE_OVER ;
			d.sOmc.mc._alpha = 80 ;
			
			d.sOmc.mc._xscale = 95 ;
			d.sOmc.mc._b._x += 1 ;
			d.sOmc.mc._b._y += 1 ;
			d.sOmc.mc._yscale = d.sOmc.mc._xscale ;
			
			//d.sOmc.mc.smc.smc.smc.smc.gotoAndStop(1) ;
			
			Col.setPercentColor(d.sOmc.mc, Const.SOUP_OPACITY[Cauldron.me.cIdx], Const.SOUP_COLOR[Cauldron.me.cIdx]) ;
			
			d.sOmc.mc.setMask(d.sMask) ;
		//}, d) ;
		
		/*d.omc = new ObjectMc(o.o, Cauldron.me.mdm, Cauldron.DP_DROPS, f) ;
		d.cOmc = new ObjectMc(o.o, Cauldron.me.ddm, 3, cf) ;
		d.rOmc = new ObjectMc(o.o, Cauldron.me.ddm, 2, rf) ;
		d.sOmc = new ObjectMc(o.o, Cauldron.me.ddm, 1, sf) ;*/
	}
	
	
	public function resetDrops() {
		for (o in drops) {
			o.drops = 0 ;
		}
		drops = new Array() ;
	}
	
	
	public function cancelDrops() : Bool {
		var td = getDrops() ;
		
		if (td.length == 0)
			return false ;
		
		for (t in [objects, waitZone]) {
			for (o in t) {
				if (o.drops <= 0)
					continue ;
				
				
				
				if (o.qty <= 0) {
					Col.setPercentColor(o.omc.mc._b, 0, 0xCCCCCC) ;
					o.omc.mc._b._alpha = 100 ;
				}
				o.qty += o.drops ;
				o.drops = 0 ;
				o.mcQty._field.text = Std.string(o.qty) ;
				
			}
		}
		
		resetDrops() ;
		return true ;
		
	}
	
	
	public function addObject(no : InvObject, ?rIndex : Int) {
		
		no.r = no.r % Const.RAD ;
		if (no.r < 0)
			no.r += Const.RAD ;
		
		no.omc.mc.smc.smc._xscale = 100 ;
		no.omc.mc.smc.smc._yscale = no.omc.mc._xscale ;
		
		if (no.mcQty == null) {
			no.mcQty = cast no.omc.mc.attachMovie("mcQty", "mcQty_0", 2) ;
			no.mcQty._x = -17 ;
			no.mcQty._y = 13 ;
			no.mcQty._field.text = Std.string(no.qty) ;
		}
		
		
		
		no.mcQty._xscale = 100 ;
		no.mcQty._yscale = no.mcQty._xscale ;
				
		var i = if (rIndex != null) rIndex else /*getRadIndex(no.r)*/objects.length ;
	
		if (rIndex != null)
			objects.insert(i, no) ;
		else
			objects.push(no) ;
		
		if (!isOnBg(no.r)) {
			no.omc.mc.onRollOver = callback(onRollOver, cast no.omc.mc, no.mcQty) ;
			no.omc.mc.onRelease = callback(drop, i) ;
		}
		no.omc.mc.onRollOut = callback(onRollOut, cast no.omc.mc, no.mcQty) ;					
		no.omc.mc.onReleaseOutside = no.omc.mc.onRollOut ;
		
		no.mcQty._field.text = Std.string(no.qty) ;
		
		if (rIndex != null) {
			for (i in 0...objects.length) {
				var o = objects[i] ;
				if (o == null)
					continue ;
				o.omc.mc.onRelease = callback(this.drop, i) ;
			}
		}
	}
	
	
	public function getRadIndex(r : Float) : Int {
		if (r <= 0.0)
			r += Const.RAD ;
		
		if (objects.length < 2) {
			return objects.length ;
		}

		for(i in 0...objects.length - 1) {
			var p = if (i == 0) objects[objects.length - 1] else objects[i - 1] ;
			var n = objects[i] ;
			
			var nr = if (n.r < p.r) n.r + Const.RAD else n.r ;
			
			//trace(i + " # " + p.r + " > " + r + " > " + n.r + " (" + nr + ")") ;
			
			if (p.r <= r && nr > r) {
				//trace("FOUND") ;
				return i ;
			}
		}
		
		trace("radIndex not found ! for " + r) ;
		return null ;
	}
	
	public function getDrops() : Array<{_o : _ArtefactId, _qty : Int}> {
		var res : Array<{_o : _ArtefactId, _qty : Int}> = new Array() ;
		
		for (o in drops) {
			if (o.drops == 0)
				continue ;
			
			var found = false ;
			for (r in res) {
				if (!Type.enumEq(r._o, o.o))
					continue ;
				
				found = true ;
				r._qty += o.drops ;
				break ;
			}
			
			if (!found)
				res.push({_o : o.o, _qty : o.drops}) ;
		}
		
		return res ;
	}
	

	
	function setSpeed(s : Int) {
		if (Cauldron.me.step != Default)
			return ;
		
		speedSide = s ;
		speed = OBJECT_SPEED * speedSide ;
		isMoving = true ;
		slowInfos = null ;
	}
	
	
	public function slow() {
		isMoving = false ;
		slowInfos = {timer : 0.0, from : Math.abs(speed) } ;
		
		if (slowInfos.from < OBJECT_SPEED) {
			slowInfos.timer = slowInfos.from / OBJECT_SPEED ;
			//trace("slow timer : " + slowInfos.timer) ; 
		}
		
	}
	
	public function stop() {
		isMoving = false ;
		speed = null ;
	}
	
	
	//### KEYS
	function initKeyListener() {
		var kl = {
			onKeyDown:callback(onKeyPress),
			onKeyUp:callback(onKeyRelease)
		}
		Key.addListener(kl) ;
	}
	
	
	function onKeyRelease() {
		var n = Key.getCode() ;
		
		switch(n) {
			case Key.LEFT : Cauldron.me.inventory.mcLeft.gotoAndStop(1) ; Cauldron.me.inventory.slow() ;
			case Key.RIGHT : Cauldron.me.inventory.mcRight.gotoAndStop(1) ; Cauldron.me.inventory.slow() ;
		}
	}
	
	
	function onKeyPress() {
		var n = Key.getCode() ;
		switch(n) {
			case Key.LEFT : if (!Key.isDown(Key.RIGHT)) {
							Cauldron.me.inventory.mcLeft.gotoAndStop(2) ;
							setSpeed(-1) ;
			}			else {
							if (isMoving)
								Cauldron.me.inventory.slow() ;
						}
							
			case Key.RIGHT : if (!Key.isDown(Key.LEFT)) {
								Cauldron.me.inventory.mcRight.gotoAndStop(2) ;
								setSpeed(1) ;
							} else {
								if (isMoving)
									Cauldron.me.inventory.slow() ;
							}
				
		}
	}
	
	
	//### ROLLS
	static function onRollOver(m : {>flash.MovieClip, _b : flash.MovieClip}, mcQty : flash.MovieClip) {
		if (Cauldron.me.step != Default)
			return ;
		objectHoverRender(m);
		m._b._xscale = SCALE_OVER ;
		m._b._yscale = m.smc.smc._xscale ;
		mcQty._xscale = 115 ;
		mcQty._yscale = mcQty._xscale  ;
		
	}
	
	
	static function onRollOut(m : {>flash.MovieClip, _b : flash.MovieClip}, mcQty : flash.MovieClip) {
		objectRender(m);
		m._b._xscale = 100 ;
		m._b._yscale = m.smc.smc._xscale ;
		mcQty._xscale = 100 ;
		mcQty._yscale = mcQty._xscale  ;
	}
	
	
	static function objectRender(m : flash.MovieClip) {
		m.filters = [
			new flash.filters.GlowFilter(0x7A97AD, 2,3,3,3),
			new flash.filters.DropShadowFilter(5,110,0x1E272B,1,5,5,0.4)
		] ;
	}
	
	static function objectHoverRender(m : flash.MovieClip) {
		m.filters = [
			new flash.filters.GlowFilter(0xD9EFFF, 2,6,6,5),
			new flash.filters.DropShadowFilter(5,110,0x1E272B,1,5,5,0.4)
		] ;
	}		
	
	
	
}