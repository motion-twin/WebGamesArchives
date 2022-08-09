import mt.bumdum9.Lib ;


enum ExitEffect {
	Ex_Play_2 ;
	Ex_Play_3 ;
	Ex_Play_5 ;
	Ex_Play_8 ;
	Ex_Points_1 ;
	Ex_Points_2 ;
	Ex_Points_3 ;
}



class Exit {

	public static var EXIT_DELTA = 65 ;
	public static var EXIT_HIDE = 150 ;
	public static var FX_WEIGHTS = [390, 122, 15, 1, 390, 82, 2] ;
	public static var FX_VALUES = [2, 3, 4, 6, 1500, 3000, 7000] ;


	public var dir : Array<Int> ;
	public var mc : {>MC, smc : MC, _text : TF} ;
	public var fx : ExitEffect ;
	public var slot : Slot ;

	public function new() {
		mc = cast new gfx.Exit() ;
		randomTube() ;
		Game.me.dm.add(mc, Game.DP_EXIT) ;

		setEffect(getRandomEffect()) ;
	}


	function randomTube() {
		mc.smc.gotoAndStop( 1 + Std.random(3) ) ;
	}


	public function setPos(x : Int, y : Int) {
		var pos = Slot.getStonePos(x, y) ;
		if (y == Game.STAGE_SIZE - 1) { //bottom
			mc.x = pos.x ;
			mc.y = pos.y + EXIT_DELTA ;
			dir = [0, 1] ;
		} else {
			mc.x = pos.x + EXIT_DELTA * (if (x == 0) -1 else 1 ) ;
			mc.y = pos.y ;
			dir = [if (x == 0) -1 else 1, 0] ;
		}
	}


	public function setEffect(effect : ExitEffect) {
		fx = effect ;
		var idx = Type.enumIndex(fx) ;

		randomTube() ;
		mc.gotoAndStop(idx + 1) ;
		mc._text.text = Std.string(FX_VALUES[idx]) ;
	}


	public function getRandomEffect() : ExitEffect {
		return Type.createEnumIndex(ExitEffect, Game.randomProbs(FX_WEIGHTS) ) ;
	}


	public function switchSlot() {
		var slots = Game.me.getFreeExitSlots() ;
		var s = slots[Game.me.rand(slots.length)] ;
		slot.exit = null ;
		slot = s ;
		s.exit = this ;
		setPos(s.x, s.y) ;
		mc.y += EXIT_HIDE ;
	}


	public function proc() {
		var idx = Type.enumIndex(fx) ;

		if (idx < 4)
			Game.me.addPlay(FX_VALUES[idx]) ;
		else
			Game.me.addScore(FX_VALUES[idx]) ;

		//rerollEffect
		var nfx = getRandomEffect() ;

		var anim = new mt.fx.Tween(mc, mc.x, mc.y + EXIT_HIDE, 0.05) ;
		anim.curveIn(3) ;
		anim.onFinish = callback(function(x : Exit, nfx : ExitEffect) {
									x.switchSlot() ;
									Game.me.waitDone() ;
		 							x.setEffect(nfx) ;
		 							x.mc.scaleX = 1 ; // tweak for mal branled mt.fx
		 							x.mc.scaleY = 1 ;
		 							var a = new mt.fx.Tween(x.mc, x.mc.x, x.mc.y - EXIT_HIDE, 0.05) ;
									a.curveInOut() ;
									
									#if sound
									var snd = Game.me.sound;
									snd(new sound.Pipe()).play();
									#end
									//a.onFinish = Game.me.waitDone ;
		 						}, this, nfx ) ;

		var grow = new mt.fx.Grow(mc, 0.1, 0.5) ;
		grow.curveIn(5) ;
	}

}