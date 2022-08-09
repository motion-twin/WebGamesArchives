package fx;
import mt.bumdum9.Lib;


/**
 * animated mask for timer
 *
 */
class CMState {
	var mc : MC;
	public var ratio : Float;
	public var fx : Null<fx.CircleMask>;

	public function new( mc : MC ){
		this.mc = mc;
		this.ratio = 0;
	}

	public function update(){
		var g = mc.graphics;
		var r = 62;
		var a = -Math.PI/2 + ratio * 2  * Math.PI;

		g.clear();
		g.beginFill(0);
		g.moveTo(0,0);
		g.lineTo(0,-r);
		g.lineTo(r,-r);
		if( ratio >= 0.25 )
			g.lineTo(r,r);
		if( ratio >= 0.50 )
			g.lineTo(-r,r);
		if( ratio >= 0.75 )
			g.lineTo(-r,-r);
		g.lineTo(Math.cos(a) *r ,Math.sin(a) *r);
		g.lineTo(0,0);
		g.endFill();
	}

	public function reset(){
		if( fx != null ){
			if( !fx.dead )
				fx.kill();
			fx = null;
		}
		ratio = 0;
		update();
	}

}

class CircleMask extends mt.fx.Fx{//}
	var state : CMState;
	var speed : Float;
	var from : Float;
	var to : Float;

	public function new(state, speed, to) {
		super();
		this.state = state;
		this.speed = speed;
		this.from = state.ratio;
		if( state.fx != null && !state.fx.dead )
			state.fx.kill();
		state.fx = this;
		this.to = Math.max(Math.min(to,1),0);

		update();
	}
	
	override function update() {
		coef = Math.min(coef+speed,1);

		state.ratio = from + (to-from) * curve(coef);
		state.update();

		if( coef == 1 )
			kill();
	}

	
	
//{
}
