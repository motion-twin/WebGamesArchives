package result ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import anim.Anim.AnimType ;
import anim.Transition ;
import CauldronData.CauldronResult ;
import Cauldron.Step ;


enum ResultStep {
	Prepare ;
	Wait ;
	GoOut ;
	Exit ;
}



class Result {
	
	static var OBJECT_SCALE = 200 ;
	static var OBJECT_X = 250 ;
	static var OBJECT_Y = 100 ;
	
	static var NB_CLOUDS = 15 ;

	static var DP_OBJECTS = 2 ;
	
	
	public var dm : mt.DepthManager ;
	public var mc : flash.MovieClip ;
	public var mcResult : {>flash.MovieClip, _result : {>flash.MovieClip, _field : flash.TextField, _lvlup : {>flash.MovieClip, _field : flash.TextField}}} ;
	public var mcMask : flash.MovieClip ;
	public var gotRank : String ;
	
	public var coef : Float ;
	public var spc : Float ;
		
	public var step : ResultStep ;
	
	
	public function new(?gotRank : String) {
		mc = Cauldron.me.mdm.empty(Cauldron.DP_EFFECT) ;
		dm = new mt.DepthManager(mc) ;
		this.gotRank = gotRank ;
		
	}
	
	
	public function initMcs() {
		mc.beginFill(1, 0) ;
		mc.moveTo(0, 0) ;
		mc.lineTo(Cauldron.WIDTH, 0) ;
		mc.lineTo(Cauldron.WIDTH, Cauldron.HEIGHT) ;
		mc.lineTo(0, Cauldron.HEIGHT) ;
		mc.lineTo(0, 0) ;
		mc.endFill() ;
	}
	
	
	public function initMcResult(f : Int) {
		mcResult = cast dm.attach("created", Result.DP_OBJECTS) ; 
		mcResult._visible = false ;
		mcResult._result.gotoAndStop(f) ;
		if (gotRank == null)
			mcResult._result._lvlup._visible = false ;
		else 
			mcResult._result._lvlup._field.text = gotRank ;
		
		mcResult._x = Result.OBJECT_X ;
		mcResult._y = Result.OBJECT_Y ;
		
		mcMask = cast dm.attach("resultMask", Result.DP_OBJECTS + 1) ;
		mcMask._x = Result.OBJECT_X ;
		mcMask._y = Result.OBJECT_Y ;
		mcMask.gotoAndStop(1) ;
		mcResult.setMask(mcMask) ;
		
	}
	
	public function resultOut() {
		if (mcMask == null)
			return ;
		mcMask.gotoAndPlay(13) ;
	}
	
	
	public function makeClouds(sx : Float, sy : Float) {
		for(i in 0...NB_CLOUDS) {
			var mc = Cauldron.me.mdm.attach("cloud", Cauldron.DP_CLOUDS) ;
			mc.gotoAndStop(Std.random(4) + 1) ;
			
			mc._xscale = 400 ;
			mc._yscale = mc._xscale ;
			
			var sp = new Phys(mc) ;
			var a = Math.random() * Const.RAD ;
			var ca = Math.cos(a) ;
			var sa = Math.sin(a) ;
			
			var speed = 2 + Math.random() * 4 ;
			sp.x = sx + ca * 30 ;
			sp.y = sy + sa * 30 ;
			sp.vx = ca * speed ;
			sp.vy = sa * speed ;
			sp.weight = -0.3 - Math.random() * 0.35 ;
			sp.frict = 0.98 ;
			
			sp.vsc = 0.9 ;
			sp.vr = Math.random() * 10 ;
			sp.fadeType = 6 ;
			sp.timer = 20 + Math.random() * 10 ;
			Filt.blur(sp.root, 2, 2) ;
		}
		
	}
	
	public function loop() {
	}
	
	public function kill() {
		if (Cauldron.me.result == this)
			Cauldron.me.result = null ;
		if (mcMask != null)
			mcMask.removeMovieClip() ;
		if (mcResult != null)
			mcResult.removeMovieClip() ;
		/*if (Cauldron.me.dialog != null)
			Cauldron.me.dialog.exit() ;*/
	}
	
	
}