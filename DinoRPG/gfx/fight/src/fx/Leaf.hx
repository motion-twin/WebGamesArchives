package fx;
import mt.bumdum.Lib;
using mt.kiroukou.motion.Tween;

class Leaf extends State {
	var caster:Fighter;
	var link : String;
	var parts : Array<part.Leaf>;
	var count : Int;
	
	public function new(f, link) {
		super();
		this.caster = f;
		this.link = link;
		addActor(caster);
	}
	
	override function init() {
		super.init();
		parts = [];
		spc = 0.01;
		count = 0;
		caster.playAnim("dead");
		caster.mode = Fighter.Mode.Dead;
	}
	
	public override function update() {
		super.update();
		if( castingWait ) return;
		
		if( Std.random(2) == 0 && coef < 0.35 ) {
			for( i in 0...1 ) {
				count++;
				var p = new part.Leaf( Scene.me.dm.attach(this.link, Scene.DP_FIGHTER), i, 10 + Std.random(30) );
				
				p.x = caster.x - (caster.side?0:.0) * caster.body._width;
				p.y = caster.y - 20;
				p.z = -1.5 * Scene.HEIGHT;
				
				p.vx = 0;
				p.vy = .1 * (Math.random() * 2 - 1);
				p.vz = 1 + 2*Math.random() + Math.random();
				p.setScale( 100-p.vz*10 );
			
				p.onEnd = onLeafEnd;
				p.updatePos();
				parts.push(p);
			}
		}
		for( p in parts )
			p.update();
		
		//if( coef == 1 ) onLeafEnd();
	}
	
	function onLeafEnd(?p) {
		count --;
		if( count == 0 ) {
			for( p in parts )
				p.root.tween().to(0.5, _alpha = 0 );
			haxe.Timer.delay( end, 1000);
		}
	}

	override function end() {
		caster.resurect();
		for( p in parts )
			p.dispose();
		super.end();
	}
}