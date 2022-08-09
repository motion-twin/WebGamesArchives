package ui;
import mt.gx.MathEx;
import mt.gx.MathEx;

/**
 * ...
 * @author 01101101
 */

class UIWrapper extends gfx.Ui {
	
	var total:Int;
	var globalOffset:Int;
	var speedOffset:Int;
	var fluct:Int;
	var targetOD:Int;
	
	var blinkOD:Int;
	var blinkOH:Int;
	
	public function new () {
		super();
		
		total = this._needle.totalFrames;
		//globalOffset = Std.int(this._needle.totalFrames / 3);
		globalOffset = Std.int(total / 3);
		speedOffset = 10;
		fluct = 3;
		
		blinkOD = blinkOH = 0;
		
		update();
	}
	
	public function update (speed:Float = 0, overheat:Float = 0, overdrive:Float = 0) {
		setSpeed(speed);
		setOverheat(overheat);
		setOverdrive(overdrive);
		this._needle3.gotoAndStop(this._needle3.currentFrame + Math.floor((targetOD - this._needle3.currentFrame) * 0.1));
		
		if (blinkOD > 0) {
			blinkOD--;
			if (blinkOD == 0)			this._needle3.visible = true;
			else if (blinkOD % 2 == 0)	this._needle3.visible = !this._needle3.visible;
		}
		if (blinkOH > 0) {
			blinkOH--;
			if (blinkOH == 0)			this._needle2.visible = true;
			else if (blinkOH % 3 == 0)	this._needle2.visible = !this._needle2.visible;
		}
	}
	
	public function shake () {
		if (y > Game.SIZE.height)		y = Game.SIZE.height - 1;
		else if (y < Game.SIZE.height)	y = Game.SIZE.height + 1;
		else							y = Game.SIZE.height + Std.random(2) * 2 - 1;
	}
	
	function setSpeed (v:Float = 0) {
		v = MathEx.clamp(v, 0, 1);
		var r = MathEx.ratio(Game.RATIO, 1, 3);
		var go = r * (total - globalOffset);
		var so = v * speedOffset;
		var f = globalOffset + go + so + Std.random(fluct) - fluct / 2;
		f = this._needle.currentFrame + (f - this._needle.currentFrame) * 0.4;
		f = Std.int(f);
		this._needle.gotoAndStop(f);
	}
	
	function setOverheat (v:Float = 0) {
		v = MathEx.clamp(v, 0, 1);
		var f = Std.int(this._needle2.totalFrames * v) + 1;
		if (f != this._needle2.currentFrame) {
			if (f > this._needle2.currentFrame && blinkOH == 0)	blinkOH = 31;
			this._needle2.gotoAndStop(f);
		}
	}
	
	function setOverdrive (v:Float = 0) {
		v = MathEx.clamp(v, 0, 1);
		var tOD = MathEx.floori(this._needle3.totalFrames * v * 1.1);
		if (tOD != targetOD) {
			if (tOD > targetOD)	blinkOD = 20;
			targetOD = tOD;
		}
	}
	
}










