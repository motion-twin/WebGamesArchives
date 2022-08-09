package;
import mt.kiroukou.debug.Stats;
import flash.display.MovieClip;
import flash.Lib;

using mt.kiroukou.motion.Tween;
class Motion extends MovieClip
{
	public function new() {
		super();
		benchmark();
		//test();
	}
	
	static function main()	{
		Lib.current.addChild( new Motion() );
	}
	
	static private var RADIUS = 320;
	static private var COUNT = 5000;
	static private var TIME = 0.5;
	function benchmark() {
		var s:Star, i;
		for (i in 0...COUNT ) {
			s = new Star();
			Lib.current.addChild(s);
			tween(s, Math.random());
		}
		Lib.current.addChild(new Stats());
	}

	function tween(star:MovieClip, progress:Float) {
		star.x = 262; //center
		star.y = 215; //center
		var scale = Math.random() * 2.5 + 0.5;
		star.scaleX = star.scaleY = 0.05;
		var random = Math.random();
		var angle = random * Math.PI * 2;
		var delay = Math.random() * TIME;
		if (progress != 0) {
			star.x += Math.cos(angle) * RADIUS * progress;
			star.y += Math.sin(angle) * RADIUS * progress;
			star.scaleX = star.scaleY = scale * progress;
			delay = 0;
		}
		_tween(	star, 									//target
				TIME * (1 - progress), 					//duration
				262 + Math.cos(angle) * RADIUS,			//x
				215 + Math.sin(angle) * RADIUS,			//y
				scale, 									//scaleX
				scale,									//scaleY
				random * rotation,						//rotation
				delay,									//delay
				tween,									//onComplete
				[star, 0.]);							//onCompleteParams
	}
	
	function _tween(target:MovieClip, duration, x, y, scaleX, scaleY, rotation, delay, ponComplete : Star->Float->Void, onCompleteParams) {
		target.tween().delay(delay).to(duration, x = x, y = y, scaleX = scaleX, scaleY = scaleY, rotation = rotation).onComplete( function(_) { Reflect.callMethod(ponComplete, ponComplete, onCompleteParams); } );
		//com.eclecticdesignstudio.motion.Actuate.tween( target, duration, { x:x, y:y, scaleX:scaleX, scaleY:scaleY, rotation:rotation } ).delay(delay).onComplete( ponComplete, onCompleteParams );
	}
	
			
	static function test () {
		var m = new Star();
		m.x = 200;
		m.y = 200;
		flash.Lib.current.addChild(m);
		var s = new Stats();
		s.x = flash.Lib.current.stage.stageWidth - s.width - 10;
		flash.Lib.current.addChild(s);
		
		var m1 = new Star();
		m1.x = 400;
		m1.y = 200;
		flash.Lib.current.addChild(m1);
		
		//mt.kiroukou.motion.Tween.tween( m ).from( 1.0, x = 0, y = 0, alpha = 1 ).apply().to( 1, x = 400 ).to( 3, x = 100, alpha = 0 ).loop(3).onComplete( function(t) { trace("fin de mouvement"); } );
		m.tween( mt.kiroukou.motion.easing.Elastic.easeInOut )
			.from( 1.0, x = 0, y = 0, alpha = 1 )
			.chain(m1).delay(1)
			.to( 1.0, x=230, scaleX=2, scaleX=5).ease( mt.kiroukou.motion.easing.Bounce.easeOut )
			.chain(m)
			.to( 1, x = 400 ).ease( mt.kiroukou.motion.easing.Quint.easeIn)
			.to( 1, x = 100, alpha = 0 ).loop(2).onComplete( function(t) { if( !t.backward ) t.reverse(); } );
	}
}

class Star extends flash.display.MovieClip {
	public function new() {
		super();
		draw();
	}
	
	function draw() {
		var g = this.graphics;
		g.beginFill(Std.random(0xFFFFFF));
		g.drawCircle(0,0,2.5);
		g.endFill();
	}
}