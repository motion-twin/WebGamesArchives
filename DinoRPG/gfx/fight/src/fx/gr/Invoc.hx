package fx.gr;

import mt.bumdum.Lib;
import Fight;

typedef SpeedRay = { > Phys, coef:Float };

class Invoc extends fx.GroupEffect {
	var invoc : Part;
	var anim : String;
	var z : Float;
	var speed:Int;
	
	var lines : Array<Part>;
	var parts : Array<Part>;
	var sparts : Array<{function dispose() : Void;}> ;
	var listMc : Array<flash.MovieClip>;
	
	public function new( f, list, anim ) {
		super(f, list);
		this.anim = anim;
		spc = 0.05;
		speed = 0;
		var mc = Scene.me.dm.attach("mcInvocs", Scene.DP_BGFRONT);
		mc.gotoAndStop(anim);
		mc._visible = false;
		invoc = new Part( mc );
		
		var pos3D = Sprite.get3D( Cs.mcw / 2, Cs.mch / 2 );
		invoc.x = pos3D.x;
		invoc.y = pos3D.y;
		invoc.z = -1000;
		z = pos3D.z;
		
		invoc.setScale(100);
		invoc.ray = 100;
		invoc.dropShadow();
		invoc.updatePos();
	}

	public override function update() {
		super.update();
		switch( step ) {
			case 0:
				invoc.root._visible = true;
				updateAura(4, caster.skinBox);
				if( coef == 1 ) {
					nextStep();
					spc = 0.02;
					Scene.me.fxShake(4, 1.0, 10.0);
					switch( anim ) {
						case "vulcan": initLava(4);
						case "bluewh": initBubbles(40);
						case "yggdra": initLeaves(50);
						case "fairy": initFirefly(20);
						case "goku":  initTornade();
						default:
					}
				}
			case 1:
				switch( anim ) {
					case "goku":
					default:
				}
				for( i in 0...10 ) {
					var x =  invoc.x;
					var y =  Scene.getY(invoc.y);
					var p = Scene.me.genGroundPart(x, y);
					var s = (10 + coef * 10);
					var s2 = (2 + coef * 5);
					p.vx = (Math.random() * 2 - 1) * s;
					p.vz = (Math.random() * 2 - 1) * s;
					p.z  = -Math.random() * (20 + coef * 80) ;
					p.vr = (Math.random() * 2 - 1) * s2;
					p.timer += Math.random() * 5;
					p.friction = 0.97;
					p.setScale(p.scale * 1.5);
				}
				invoc.z += (z - invoc.z) * 0.1;
				if( coef == 1 ) {
					caster.skinBox.filters = [];
					nextStep();
					spc = 0.035;
					Scene.me.shakeFrict = 0.8;
				}
			case 2:
				switch( anim ) {
					case "goku":
					default:
				}
				updateAura(4, invoc.root, coef);
				if( coef == 1 ) {
					damageAll(_LLightning);
					nextStep();
					spc = 0.1;
				}
			case 3:
				switch( anim ) {
					case "goku":
					default:
				}
				fade(coef);
				if( coef == 1 ) {
					nextStep();
					spc = 0.5;
				}
			case 4:
				invoc.setAlpha((1-coef) * 100);
				if( coef == 1 ) {
					for( mc in listMc ) mc.gotoAndPlay("endAnim");
					for( p in sparts ) p.dispose();
					for( p in parts ) p.kill();
					for( p in lines ) p.kill();
					invoc.kill();
					end();
				}
		}
	}
	
	static var SHADE = 255;
	function fade(c:Float){
		var inc = Std.int(SHADE * c);
		Col.setColor(invoc.root, 0, inc);
	}
	
	function initTornade(){
		// TORNADE
		var tornade = new Phys(Scene.me.dm.attach("mcTornade", Scene.DP_FIGHTER));
		tornade.x = Cs.mcw * 0.5;
		tornade.y = Scene.getPYMiddle();
		tornade.ray = 30;
		tornade.dropShadow();
		tornade.updatePos();
		Filt.blur(tornade.root, 10, 0);
		parts = [cast tornade];
	}
	
	function initFirefly(count) {
		parts = [];
		for( o in 0...count ){
			var p = new Part( Scene.me.dm.attach("partWind", Fighter.DP_FRONT) );
			p.setScale(400);
			p.x  = Math.random() * Cs.mcw;
			p.y = Scene.getRandomPYPos();
			p.timer = 100 + Math.random() * 40;

			p.vr = (Math.random() * 2 - 1) * 20;
			p.root.smc._x = Math.random() * 30;
			p.root._rotation = Math.random() * 360;

			p.freeze = Math.random() * 40;
			p.root.stop();
			p.root._visible = false;
			p.updatePos();

			Filt.glow(p.root, 10, 1, 0xFFFFFF);
			parts.push(p);
		}
	}
	
	function initBubbles(count) {
		sparts = [];
		for( i in 0...count ) {
			var p = new part.Bubbles(150, -10, 0.003, 0);
			sparts.push(p);
		}
	}
	
	function initLeaves(count) {
		sparts = [];
		for( i in 0...count ) {
			var d = Fighter.DP_FRONT;
			if( Std.random(2) == 0 ) d = Fighter.DP_BACK;
			var p = new part.Leaf( Scene.me.dm.attach("feuilles", Scene.DP_FIGHTER), i, 10 + Std.random(30) );
			
			p.x = Math.random() * Cs.mcw;
			p.y = Scene.getRandomPYPos();
			p.z = -1.5 * Scene.HEIGHT;

			p.defaultVx = 0;
			p.defaultVy = 1 * (Math.random() * 2 - 1);
			p.defaultVz = 1 + 1.5 * Math.random();
			p.defaultVz *= 14;
			p.init();

			sparts.push(p);
		}
	}
	
	function initLava(count) {
		listMc = [];
		for ( i in 0...count ) {
			haxe.Timer.delay( function() {
				var mc = Scene.me.dm.attach( "mcLava", Fighter.DP_FRONT );
				mc._x = invoc.x + Std.random(250) - Std.random(250);
				mc._y = invoc.y;
				listMc.push( mc );
			}, Std.random(1500) );
		}
	}
}
