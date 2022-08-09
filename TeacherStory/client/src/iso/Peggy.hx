package iso;

import Iso;
import Common;

class Peggy extends Iso {
	var mc				: lib.Peggy;
	var talking			: Bool;
	var usedReplicas	: Hash<Bool>;
	var flip			: Bool;
	
	public function new() {
		super();
		
		usedReplicas = new Hash();
		talking = false;
		glowClick = false;
		headY = 10;
		
		var rseed = new mt.Rand(0);
		rseed.initSeed(man.cinit._solverInit._seed);
		var pos = [{cx:5, cy:5, f:false}, {cx:2, cy:7, f:true}, {cx:1, cy:2, f:true}, {cx:5, cy:7, f:false}, {cx:5, cy:9, f:false}];
		var pt = pos[rseed.random(pos.length)];
		cx = pt.cx;
		cy = pt.cy;
		flip = pt.f;
		if( flip )
			setStandPoint(0,1);
		else
			setStandPoint(1,0);
		
		mc = new lib.Peggy();
		sprite.addChild(mc);
		mc.scaleX = flip ? 1 : -1;
		mc.x = 0;
		mc.y = 22;
		mc.gotoAndStop("stand");
		
		setShadow(true);
		collides = true;
		
		setClick(0,10,10, Tx.AskPeggy, function() {
			man.gotoAndDo(this, function() {
				if( cd.has("talk") || talking )
					return;
				if( countReplicas()<=2 ) {
					var r = man.tg.m_peggy();
					while( usedReplicas.exists(r) )
						r = man.tg.m_peggy();
					ambiant(r, false);
					usedReplicas.set(r, true);
				}
				else
					ambiant(man.tg.m_peggyend(), false);
				setTalk(true);
				cd.set("talk", 30*2);
			});
		});
		
		setTalk(false);
	}
	
	inline function getMouthMc() {
		var smc : flash.display.MovieClip = Reflect.field(mc._sub, "_sub");
		return smc;
	}
	
	public function countReplicas() {
		var n = 0;
		for(k in usedReplicas.keys())
			n++;
		return n;
	}
	
	public function setTalk(b:Bool) {
		talking = b;
		if( talking )
			getMouthMc().play();
		else
			getMouthMc().gotoAndStop(1);
	}
	
	public override function update() {
		super.update();
		
		if( talking ) {
			var mouth = getMouthMc();
			mc.scaleX = flip ? -1 : 1;
			if( !cd.has("mouth") ) {
				var last = mouth.currentFrame;
				var f = 0;
				do {
					f = Std.random(mouth.totalFrames)+1;
				} while( f==last );
				mouth.gotoAndStop(f);
				cd.set("mouth", Std.random(2)+3);
			}
			if( bubbles.length==0 )
				setTalk(false);
		}
		else
			mc.scaleX = flip ? 1 : -1;
	}
}

