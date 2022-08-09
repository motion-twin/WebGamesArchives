package anim ;

import mt.bumdum.Lib ;
import anim.Transition ;


enum AnimType {
	Translation ;
	Scale ;
	Alpha(s : Int) ;
	Color(c : Int, s : Int) ;
}


class Anim {
	
	static public var onStage : Array<Anim> = new Array() ;
	
	public var mc : flash.MovieClip ;
	var sx : Float ;
	var sy : Float ;
	var ex : Float ;
	var ey : Float ;
	
	var cx : Float ;
	var cy : Float ;
	
	public var type : AnimType ;
		
	public var coef : Float ;
	var delta : Float ;
	var speed : Float ;
	var endTimer : Float ;
//	var p  : Int ;
	var transition :  Float -> Float ;
	public var tp : Float ;
	
	public var sleep : Float ;
	
	public var onEnd : Void -> Void ;
	public var onStart : Void -> Void ;
	public var onCoef : Array<{c : Float, f : Void -> Void}> ;
	
	
	
	public function new(m : flash.MovieClip, t : AnimType, f : Transition, params : Dynamic) {
		mc = m ;
		type = t ;
		switch(type) {
			case Translation : 
				sx = mc._x ;
				sy = mc._y ;
				ex = params.x ;
				ey = params.y ;
			case Scale :
				sx = mc._xscale ;
				sy = mc._yscale ;
				ex = params.x ;
				ey = params.y ;
			case Alpha(s) : 
				//nothing to do
			case Color(c, s) :
				//nothing to do
		}
		
		speed = if (params.speed != null) params.speed else 1.0 ;
		coef = 0.0 ;
//p = if (params.p != null) params.p else -1 ;
		tp = if (params.tp != null) params.tp else null ;
		transition = TransitionFunctions.get(f) ;
	}
	
	
	public function setTransition(t : Transition) {
		transition = TransitionFunctions.get(t) ;
	}

	
	static public function getTransitionFunction(t : Transition) {
		return TransitionFunctions.get(t) ;
	}
	
	
	public function start() {
		onStage.push(this) ;
		if (onStart != null)
			onStart() ;
	}

	
	public function update() {
		if (sleep != null && sleep > 0.0) {
			sleep -= mt.Timer.tmod ;
			return ;
		}
		
		updateCoef() ;
		
		//trace("coef : " + coef + " # delta : " + delta + " # tmod : " + mt.Timer.tmod) ;
		
		switch (type) {
			case Translation : 
				cx = sx * (1 - delta) + ex * delta ;
				cy = sy*(1 - delta) + ey * delta ;
				mc._x = cx ;
				mc._y = cy ;
			
			case Scale : 
				/*mc._xscale = 100 * delta ;
				mc._yscale = 100 * delta ;*/
			
				mc._xscale = sx + (ex - sx) * delta ;
				mc._yscale = sy + (ey - sy) * delta ;
			
			case Alpha(s) : 
				if (s > 0)
					mc._alpha = 100 * delta ;
				else
					mc._alpha = 100 - 100 * delta ;
				
			case Color(c, s) : 
				if (s > 0)
					Col.setPercentColor(mc, 100 * delta, c) ;
				else
					Col.setPercentColor(mc, 100 - 100 * delta, c) ;
				
		
		}
				
		if (isDone())
			end() ;
	}
	
	
	function updateCoef() {
		coef = Num.mm(0, coef + speed * mt.Timer.tmod, 1) ;
		delta = transition(coef) ; 
		
		
		if (onCoef != null) {
			for (o in onCoef) {
				if (o.c < coef) {
					var fc = o.f ;
					onCoef.remove(o) ;
					fc() ;
				} else 
					break ;
			}
		}
			
		
		if (endTimer!=null) {
			endTimer -= mt.Timer.tmod ;
			if(endTimer<=0)
				end() ;
		}
	}
	
	
	function isDone() : Bool {
		return  endTimer == null && coef == 1 ;
	}
	
	
	public function addOnCoef(cc : Float, fc : Void -> Void) {
		if (cc < coef)
			return ;
		if (onCoef == null)
			onCoef = new Array() ;
		
		onCoef.push({c : cc, f : fc}) ;
		onCoef.sort(function(a, b) {
			if (a.c < b.c)
				return 1 ;
			else 
				return -1 ;
		}) ;
		
	}
	
	
	public function end() {
		kill() ;
		endTimer = null ;
		
		if (onEnd != null)
			onEnd() ;
	}
	
	public function kill() {
		onStage.remove(this) ;
	}
	
	
	public static function getValue(t : Transition, c : Float) : Float {
		return TransitionFunctions.get(t)(c) ;
	}
	
}