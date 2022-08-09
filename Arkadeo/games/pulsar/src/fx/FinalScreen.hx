package fx;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import Protocol;
import api.AKApi;

typedef GameOverElement = { > flash.display.MovieClip,
	var _titre : flash.text.TextField;
}


using mt.flash.Event;
@:build(mt.kiroukou.macros.IntInliner.create([
	IN_STEP,
	WAIT_STEP,
	OUT_STEP,
	FADE_STEP,
]))
class FinalScreen extends mt.fx.Sequence {

	function autosize(tf:flash.text.TextField)
	{
		//You set this according to your TextField's dimensions
		var f:flash.text.TextFormat = tf.getTextFormat();
		//decrease font size until the text fits
		while( tf.textWidth > ow || tf.textHeight > oh ) {
			f.size = Std.int(f.size) - 1;
			tf.setTextFormat(f);
		}
	}

	var ow:Float;
	var oh:Float;
	
	var wait : Int;
	var mc : gfx.GameOver;
	public function new( waitTime:Int, title : String, desc : String )
	{
		super();
		this.spc = 0.06;
		this.wait = waitTime;
		this.mc = new gfx.GameOver();
		mc.y = 0.80 * Game.HEIGHT - mc.height / 2;
		mc.gotoAndStop(1);
		mc.onClick( callback(setStep, OUT_STEP, 0.3 ) );
		Game.me.dm.add( mc, Game.DP_TOP);
		
		// init texts
		var e : GameOverElement = cast mc._ptsMc;
		ow = e._titre.width;
		oh = e._titre.height;
		
		e._titre.text = desc;
		autosize( e._titre );
		
		var e : GameOverElement = cast mc._titreMc;
		e._titre.text = title;
		
		setStep(IN_STEP);
	}
	
	override function update() {
		super.update();
		switch( step )
		{
			case IN_STEP:
				if( mc.currentFrame == mc.totalFrames ) nextStep();
				else mc.gotoAndStop( Std.int(coef * mc.totalFrames) );// mc.nextFrame();
			case WAIT_STEP:
				wait --;
				if( wait == 0 ) nextStep();
			case OUT_STEP:
				if( mc.currentFrame == 1 ) nextStep();
				else mc.gotoAndStop( mc.totalFrames - Std.int(coef * mc.totalFrames) );//mc.prevFrame();
			case FADE_STEP:
				mc.alpha = 1 - this.coef;
				if( coef == 1 ) nextStep();
			default : kill();
		}
	}
	
	override function kill() {
		mc.parent.removeChild(mc);
		super.kill();
	}
}
