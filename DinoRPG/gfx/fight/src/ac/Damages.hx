package ac ;

import Fighter.Mode ;
import Fight ;

enum DamageStep {
	Approach;
	Hit;
	JumpBehind;
	Fall;
}

class Damages extends State {
	var lfxt : _LifeEffect ;
	var fxt : _Effect ;
	var a : Fighter ;
	var t : Fighter ;
	var damages : Int ;
	var frame : Int ;
	var step : DamageStep ;

	public function new(f : Fighter, t : Fighter, life : Int, lfxt:_LifeEffect, ?fxt:_Effect ) {
		super();
		a = f ;
		this.t = t ;
		this.fxt = fxt ;
		this.lfxt = lfxt ;
		damages = life ;
		addActor(f);
		addActor(t);
	}

	override function init() {
		coef = 0;
		spc = 0.15;
		if( fxt == _EDrop && a.z == 0 ) {
			fxt = null;
		}
		
		switch(fxt){
			case _EBack:
				var p = a.getBrawlPos(t,-1);
				var dist = a.getDist(p);
				spc = a.runSpeed / dist ;
				a.moveTo(p.x, p.y,0);
				step = JumpBehind;

			case _EDrop:
				a.playAnim("air");
				step = Fall;
	
			default:
				if( Damages.atRange(a, t) ) {
					attack();
				} else {
					step = Approach;
					var p = a.getBrawlPos(t);
					var dist = a.getDist(p);
					spc = a.runSpeed / dist ;
					a.moveTo(p.x,p.y);
					a.setSens(1);
				}
		}
	}

	function attack() {
		step = Hit;
		coef = null;
		a.bind(hit, "_hit");
		if(damages == null) {
			if(t.haveStatus(_SFly)) {
				t.vx += -t.intSide * 5;
			} else {
				t.dodge(a) ;
			}
		}
		switch(fxt){
			case _EBack :		a.playAnim("big") ;
			case _EDrop :		a.playAnim("land");
			case _EEject:		a.playAnim("big") ;
			default : 			a.playAnim("attack") ;
		}
		frame = 1;
	}

	public override function update() {
		super.update();
		if( castingWait ) return;
		
		switch(step){
			case Approach:
				a.updateMove(coef);
				if(coef == 1) attack();

			case JumpBehind:
				a.updateMove(coef);
				if(coef == 1) {
					a.setSens(-1);
					attack();
					a.lockTimer = 25;
				}
			case Fall:
				a.vz += 5;
				if(a.z == 0) {
					a.vz = 0;
					attack();
				}
			case Hit:
				frame++;

			default:
		}
	}

	public function hit( lock=5, ?lock2 ) {
		if( damages != null )
			t.hit(a, damages, lfxt);
		a.lockTimer = lock;
		t.lockTimer = lock;
		if( lock2 != null )
			t.lockTimer = lock2;
		end();
	}

	override function end(){
		super.end();
		a.bind(null, "_hit");
	}

	public static function atRange(a : Fighter, t : Fighter) : Bool {
		return a.getDist({x : t.x, y : t.y}) <=  (a.range + a.ray + t.ray) ;
	}

}
