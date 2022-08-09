package mode ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;


class IceAttack extends GameMode {
	
	static var ICE_LIMIT = 7 ;
	static var ICE_STD = 3 ;
	static var ICE_ALPHA = 40 ;
	static var DELTA_Y_MC = [15.0, 20.0] ;
	static var DELTA_X_COL = 17 ;
	static var MC_POS = {x : 222.0, y : 118.0} ;
	static var UP_SPEED = 1.2 ;
	static var DOWN_SPEED = 1.3 ;
	
	var iceStep : mt.flash.Volatile<Int> ; 
	var oldStep : mt.flash.Volatile<Int> ;
	var mcIceSteps : Array<flash.MovieClip> ;
	var idm : mt.DepthManager ;
	var mcIcePanel : flash.MovieClip ;
	var lastSound : Int ;
	var transformCount : mt.flash.Volatile<Int> ;
	
	var toWarm : Array<Int> ;
	var timer : Float ;
	
	var anims : Array<{mc : flash.MovieClip, timer : Float, wait : Float, speed : Float, fPost: Void -> Void}> ;
	
	
	
	public function new() {
		super() ;
		hideSpirit = true ;
		iceStep = ICE_STD ;
		transformCount = 0 ;
		lastSound = 0 ;
		toWarm = new Array() ;
		anims = new Array() ;
		initMc() ;
	}
	
	
	function initMc() {
		mcIcePanel = Game.me.mdm.attach("iceScreen", Const.DP_ICE) ;
		mcIcePanel._x = Stage.X - 2 ;
		mcIcePanel._y = Stage.BY ;
		mcIcePanel.gotoAndStop(ICE_STD) ;
		mcIcePanel._alpha = 90 ;
		
		
		mcIceSteps = new Array() ;
		
		var x = MC_POS.x ;
		var y = MC_POS.y ;
		
		for (i in 0...ICE_LIMIT) {
			var m = Game.me.mdm.attach("iceStep", Const.DP_INVENTORY + (if (i < ICE_STD) 1 else 0)) ;
			m.gotoAndStop(1) ;
			if (i >= ICE_STD) {
				m._alpha = ICE_ALPHA ;
				m._xscale = m._yscale = 125 ;
			} else
				m._xscale = m._yscale = 100 ;
			
			m._x = x ;
			m._y = y ;
			y -= DELTA_Y_MC[if (i < ICE_STD) 0 else 1] ;
			mcIceSteps.push(m) ;
			
			
			if (i == ICE_STD - 1) {
				x += DELTA_X_COL ;
				y = MC_POS.y - 3 ;
			}
		}
	}
	
	
	
	
	override public function updateEffect() {
		if (anims.length == 0)
			return ;
			
		var a = anims[0] ;
		
		if (a.wait > 0) {
			a.wait = Math.max(a.wait - 60 * mt.Timer.tmod, 0) ;
			return ;
		}
			
		a.timer =  Math.min((a.timer * Math.pow(a.speed, mt.Timer.tmod)) + 2, 100) ;
		Col.setPercentColor(a.mc,100 - a.timer,0xFFFFFF) ;
		
		if (a.timer == 100) {
			anims.remove(a) ;
			if (a.fPost != null)
				a.fPost() ;
		}
		
	}
	
	
	
	
	
	override public function onRelease() {
		if (Game.me.stage.lastNextSize < 2)
			return ;
		oldStep = iceStep ;
		iceStep++ ;
		return ;
	}
	
	
	override public function onTransform() {
		oldStep = iceStep ;
		iceStep = if (iceStep <= ICE_STD) Std.int(Math.max(iceStep - 1, 0)) else ICE_STD ;
		
		transformCount++ ;
		
		
		updateIceMc() ;
	}
	
	override public function checkFallEnd() {
		if (Game.me.stage.lastNextSize < 2)
			return false ;
		
		if (transformCount == 0) {
			Game.me.stage.setShake(2, 2, true) ;
			updateIceMc() ; 
		}
		
		transformCount = 0 ;
				
		return false ;
	}
	
	
	function updateIceMc() {
		
		
		switch(oldStep) {
			case iceStep : 
				return ;
			
			case iceStep - 1 : //up
				var mc = mcIceSteps[oldStep] ;
			
				Col.setPercentColor(mc,100,0xFFFFFF) ;
				mc._alpha = 100 ;
				anims.push({mc : mc, timer : 0.0, wait : 0.0, speed : UP_SPEED, fPost : null}) ;
				
				Game.me.sound.play("congelation" + (if (lastSound > 0) "2" else "")) ;
				lastSound = (lastSound + 1) % 2 ;
				mcIcePanel.gotoAndStop(iceStep) ;
				
			default : //down of one or more
				if (iceStep == ICE_STD)
					oldStep-- ;
			
			
				for (i in 0...oldStep - iceStep) {
					
					var index = oldStep - i - 1 ;
					
					var f = callback(function(m : IceAttack, mc : flash.MovieClip, pan : flash.MovieClip, j : Int) {
								for(ii in 1...3) {
									var pmc = Game.me.mdm.attach("icePart", Const.DP_PART) ;
									pmc.gotoAndStop(ii) ;
									pmc._x = mc._x ;
									pmc._y = mc._y ;
									var sp = new Phys(pmc) ;
									sp.frict = 0.55 ;
									sp.weight = 0.2 ;
									sp.vr = (0.2  + Math.random() * 4.5) * (if (ii == 1) -1 else 1) ;
									sp.vx = Math.random() * 7 + 7 * (if (ii == 1) -1 else 1) ;
									sp.vy = -3 - Math.random() * 7 ;
									sp.fadeType = 6 ;
									sp.timer = 14 + Std.random(7) ;
									
								}
								
								if (pan != null)
									pan.gotoAndStop(j) ;
								mc._alpha = ICE_ALPHA ;
							}, this, mcIceSteps[index], if (i == oldStep-iceStep - 1) null else mcIcePanel, index - 1) ;
					
					//anims.push({mc :mcIceSteps[index], timer : 100.0, wait : if (i == 0) 0.0 else 100.0, fPost : f}) ;
					anims.push({mc :mcIcePanel, timer : 0.0, wait : /*if (i == 0) 0.0 else 100.0*/0.0, speed : DOWN_SPEED, fPost : f}) ;
					
				}
				mcIcePanel.gotoAndStop(oldStep - 1) ;
			
		}
	}
	
	
	override public function checkEnd() {
		return iceStep > ICE_LIMIT ;
	}
	
}