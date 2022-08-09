package fx;

import flash.MovieClip;
import haxe.Timer;
import mt.bumdum.Lib;

class Env extends State {

	public var id:Int;
	private var mc:MovieClip;
	var parts:Array<Sprite>;
	var t:Timer;
	public function new( id:Int ) {
		super();
		this.id = id;
		mc = switch(id) {
		case 2,3,4: Scene.me.dm.attach("mcniveau7", Scene.DP_BG);
		default: Scene.me.dm.attach("mcniveau7", Scene.DP_BGFRONT);
		}
		mc.gotoAndStop(id);
		parts = [];
		
		t = haxe.Timer.delay( checkCasting, 2000 );
	}

	public function dispose() {
		if(  t != null ) t.stop();
		var me = this;
		for (p in me.parts)
			untyped p.dispose();
		var t = new haxe.Timer(30);
		t.run = function() {
			me.mc._alpha -= 5;
			if(  me.mc._alpha <= 0 ) {
				me.mc.removeMovieClip();
				t.stop();
			}
		}
	}

	override function init() {
		switch(id) {
			case 1:
				for( i in 0...15 ){
					var p = new part.Ashes2( Scene.me.dm.attach("animcendres", Scene.DP_FIGHTER) );
					p.x = Math.random()*Scene.WIDTH;
					p.y = Scene.getRandomPYPos();
					p.z = 0;
					p.updatePos();
					parts.push(p);
				}
			case 2:
				for( i in 0...15 ){
					var p = new part.Bubbles();
					parts.push(p);
				}
			case 3:
				for( i in 0...20 ){
					var d = Fighter.DP_FRONT;
					if( Std.random(2)==0 ) d = Fighter.DP_BACK;
					var p = new part.Leaf( Scene.me.dm.attach("feuilles", Scene.DP_FIGHTER), i, 10 + Std.random(30) );
					
					p.offsetX = Math.random()*Scene.WIDTH;
					p.y = Scene.getRandomPYPos();
					p.z = -1.5*Scene.HEIGHT;

					p.vx = 0;
					p.vy = .1*(Math.random() * 2 - 1);
					p.vz = 1 + 1.5 * Math.random();
					p.setScale( 100-p.vz*10 );
				
					p.updatePos();
					parts.push(p);
				}
			case 4:
				var p = new part.Lightning();
				parts.push(p);
		}
	}

	public override function update() {
		if(  castingWait ) return;
		super.update();
		end();
	}
}
