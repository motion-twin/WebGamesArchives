package iso;

import Iso;
import Common;

class Einstein extends Iso {
	var mc				: lib.Einstein;
	var sleeping		: Bool;
	var talking			: Bool;
	
	public function new() {
		super();
		
		talking = sleeping = false;
		glowClick = false;
		setStandPoint(1,0);
		headY = 10;
		cx = 0;
		cy = 9;
		
		mc = new lib.Einstein();
		sprite.addChild(mc);
		mc.y = 30;
		
		collides = true;
		man.teacher.setInCasePos(getStandPoint(), 0.9, 0.7);
		
		setShadow(true);
		
		setClick(4,16,11, Tx.AskEinstein, function() {
			man.gotoAndDo(this, function() {
				if( cd.has("talkClick") || talking )
					return;
				if( sleeping )
					man.fx.symbols(this, Tx.SleepingNoiseShort, 6, true, 8,-7);
				else {
					ambiant(man.tg.m_einstein(), false);
					setTalk(true);
					cd.set("talkClick", 30*2);
				}
			});
		});
		
		setTalk(false);
		setSleep(false);
	}
	
	public function setSleep(b:Bool) {
		sleeping = b;
		mc.gotoAndStop(b ? "sleep" : "awake");
		setTalk(false);
	}
	
	public function setTalk(b:Bool) {
		talking = b;
		if( !sleeping ) {
			var smc : flash.display.MovieClip = Reflect.field(mc._sub, "_sub");
			smc.gotoAndStop(1);
		}
	}
	
	public override function update() {
		super.update();
		
		if( talking ) {
			if( !cd.has("mouth") ) {
				var mouth : flash.display.MovieClip = Reflect.field(mc._sub, "_sub");
				mouth.gotoAndStop( Std.random(mouth.totalFrames)+1 );
				cd.set("mouth", Std.random(2)+3);
			}
			
			if( bubbles.length==0 ) {
				setSleep(true);
				setTalk(false);
			}
		}
	}
}

