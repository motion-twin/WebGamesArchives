package result ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import mt.bumdum.Sprite ;
import anim.Anim.AnimType ;
import anim.Transition ;
import CauldronData.CauldronResult ;
import Cauldron.Step ;
import GameData._ArtefactId ;
import result.Result.ResultStep ;
import Inventory.InvObject ;




class Add extends Result {
	
	
	public var object : InvObject ;
	var io : InvObject ;
	var emptyTarget : {r : Float, recal : Int} ;
		
	public var posy : Float ;
	var exitMove : anim.Tween ;
	var isBackFire : Bool ;
	
	var invQty : Int ;
	var questQty : Int ;
	
		
	
	public function new(o : _ArtefactId, qty : Int, questQty : Int, gotRank : String, ?isBF = false) {
		super(gotRank) ;
		
		step = Prepare ;
		
		mc._visible = false ;
		
		invQty = qty ;
		this.questQty = questQty ;
		isBackFire = isBF ;
		
		object = {o : o,
				qty : qty,
				omc : new ObjectMc(o, Cauldron.me.mdm, Cauldron.DP_DIALOG, null, null, null, null, Result.OBJECT_SCALE),
				mcQty : null,
				drops : 0,
				isElement : true,
				r : null,
				rr : null
			} ;
		object.qty = qty ;
		object.drops = 0 ;

		
		/*object.omc.mc._b._xscale = Result.OBJECT_SCALE ;
		object.omc.mc._b._yscale = object.omc.mc._b._xscale ;*/
		
		object.omc.mc._visible = true ;
		
		initMcs() ;			
		
	}
	
	
	override function initMcs() {
		super.initMcs() ;
		super.initMcResult(if (!isBackFire) 5 else 6) ;
		
		mc.onRelease = initOut ;
		
		mcResult._result._field.text = Std.string(invQty) ;
		
		object.omc.mc._x = Result.OBJECT_X + 10 ;
		object.omc.mc._y = Result.OBJECT_Y - 10 ;
		
		posy = Math.random() * Const.RAD ;
		
		makeClouds(mcResult._x, mcResult._y) ;
		
		mc._visible = true ;
		Cauldron.me.updateSprites() ;
		object.omc.mc._visible = true ;
		mcResult._visible = true ;

		mcMask.gotoAndPlay(1) ;
		
		step = Wait ;
	}

	
	override public function loop() {
		
		switch(step) {
			case Prepare : 
				
			case Wait : 
				/*posy = (posy - 0.05) % Const.RAD ;
				object.omc.mc._y =  (Math.cos(posy) * 10) + Result.OBJECT_Y  ;*/
			
			case GoOut :
				coef = Num.mm(0,coef + spc * mt.Timer.tmod, 1) ;
						
				exitMove.update(coef) ;
				var cc = Math.sin((Const.RAD / 2) * coef) * 160 ;
				object.omc.mc._y -= cc ;
			
				object.omc.mc._b._xscale = 50 + (50) * (1.0 - coef) ;
				object.omc.mc._b._yscale = object.omc.mc._b._xscale ;
			
				if (emptyTarget != null && emptyTarget.recal != null) {
					Cauldron.me.inventory.recal(emptyTarget.recal, coef) ;
				}
					
					
				if (coef == 1.0) {
					step = Exit ;
					makeParts(if (io == null) object.omc.mc else io.omc.mc) ;
				}
		
			case Exit : 
				if (invQty - questQty > 0) {
					object.qty = invQty - questQty ;
			
					if (io == null) {
						var old = object.omc ;
						object.omc = new ObjectMc(object.o, Cauldron.me.mdm, Cauldron.DP_DIALOG) ;
						object.omc.mc._x = old.mc._x ;
						object.omc.mc._y = old.mc._y ;
						old.kill() ;
						io = object ;
						object = null ;
						io.r = emptyTarget.r ;
						Cauldron.me.inventory.addObject(io, emptyTarget.recal) ;
					} else {
						if (io.qty <= 0 && object.qty > 0) {
							Col.setPercentColor(io.omc.mc._b, 0, 0xCCCCCC) ;
							io.omc.mc._b._alpha = 100 ;
						}
						io.qty += object.qty ;
						io.mcQty._field.text = Std.string(io.qty) ;
					}
				}
				
				kill() ;
				//Cauldron.me.setStep(Default) ;
				Cauldron.me.postResult() ;
		}
	}
	
	
	
	function makeParts(m : flash.MovieClip) { //### TODO
		var nb = 20 ;
		var px = 15 ;
		var py = 15 ;
		var vr = 0 ;
		
		for (i in 0...nb) {
			var mc = m.attachMovie("part_0", "part" + i, 3 + i) ;
			
			mc._xscale = 120 + Std.random(50) ;
			mc._yscale = mc._xscale ;
			
			mc.blendMode = "add" ;

			var dx = (Math.random() * 2 -1) * 10 + 2 ;
			var dy = (Math.random() * 2 -1) * 10 + 2 ;

			var s = new Phys(mc) ;
			s.x = px + dx ;
			s.y = py + dy ;
			
			mc._x = s.x ;
			mc._y = s.y ;
			
			s.weight = 0.1 ;
			//s.alpha = 95 ;
			s.frict = 0.95 ;
			s.vx = dx / 1.5 ;
			s.vy = dy / 1.5 ;
			s.vr = (Math.random() * 2 -1) * 20 ;
			s.fadeType = 6 ;
			s.timer =  15 + Std.random(6) ;
		}
	}
	
	
	public function initOut() {
		if (Cauldron.me.dialog != null)
			return ;
		
		mc.onRelease = null ;
		Cauldron.me.resetSubmitAnim() ;
		resultOut() ;
		
		var m = new anim.Anim(mcResult, Alpha(-1), Quint(-1), {x : 0, y : 0, speed : 0.05}) ;
		m.start() ;
		
		
		if (invQty - questQty > 0) { //go to user inventory 
			io = Cauldron.me.inventory.getObject(object.o) ;
			
			var e = null ;
			if (io == null) {
				emptyTarget = Cauldron.me.inventory.getEmptyRad() ;
				e = Cauldron.me.inventory.getCirclePos(emptyTarget.r) ;
				if (emptyTarget.recal != null)
					Cauldron.me.inventory.initRecal(emptyTarget.r, emptyTarget.recal) ;
			} else
				e = {x : io.omc.mc._x, y : io.omc.mc._y} ;
				
			step = GoOut ;
			
			if (Cauldron.me.inventory.isOnBg(if (io != null) io.r else emptyTarget.r))
				Cauldron.me.mdm.swap(object.omc.mc, Cauldron.DP_ELEMENTS_BG) ;
			
			exitMove = new anim.Tween(object.omc.mc._x, object.omc.mc._y, e.x, e.y, object.omc.mc) ;
			coef = 0.0 ;
			spc = 0.08 ;
		} else { //all is collected for quest
			var m = new anim.Anim(object.omc.mc, Alpha(-1), Quint(-1), {x : 0, y : 0, speed : 0.05}) ;
			m.onEnd = callback(function(w : result.Add) {
						w.step = Exit ;	
				}, this) ;
			m.start() ;
		}
	}
	
	override public function kill() {
		super.kill() ;
		if (mc != null)
			mc.removeMovieClip() ;
		if (object != null)
			object.omc.kill() ;
		
		super.kill() ;
	}
	
	
}