package iso;

import Iso;
import Common;

class Eddy extends Iso {
	var mc				: lib.Eddy;
	var talking			: Bool;
	var usedReplicas	: Hash<Bool>;
	
	public function new() {
		super();
		
		usedReplicas = new Hash();
		talking = false;
		glowClick = false;
		setStandPoint(-1,0);
		headY = 10;
		cx = 3;
		cy = 4;
		zpriority = 2;
		
		mc = new lib.Eddy();
		sprite.addChild(mc);
		mc.scaleX = -1;
		mc.x = 8;
		mc.y = 22;
		
		collides = true;
		
		setClick(2,8,11, Tx.AskEddy, function() {
			man.gotoAndDo(this, function() {
				if( cd.has("talk") || talking )
					return;
				if( countReplicas()<=2 ) {
					var r = man.tg.m_eddy();
					while( usedReplicas.exists(r) )
						r = man.tg.m_eddy();
					ambiant(r, false);
					usedReplicas.set(r, true);
				}
				else
					ambiant(man.tg.m_eddyend(), false);
				setTalk(true);
				cd.set("talk", 30*2);
			});
		});
		
		setTalk(false);
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
			mc._sub.play();
		else
			mc._sub.gotoAndStop(1);
	}
	
	public override function update() {
		super.update();
		
		if( talking ) {
			if( !cd.has("mouth") ) {
				var last = mc._sub.currentFrame;
				var f = 0;
				do {
					f = Std.random(mc._sub.totalFrames)+1;
				} while( f==last );
				mc._sub.gotoAndStop(f);
				cd.set("mouth", Std.random(2)+3);
			}
			if( bubbles.length==0 )
				setTalk(false);
		}
	}
}

