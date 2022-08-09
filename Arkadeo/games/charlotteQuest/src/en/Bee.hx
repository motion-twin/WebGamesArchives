package en;

import Entity;
import mt.flash.Volatile;

class Bee extends Enemy {
	public static var MIN_DIFF = 25; // TODO akconst ?
	var target		: {x:Float, y:Float};
	var cadency		: Volatile<Float>;
	var dir			: Int;
	
	public function new() {
		super();
		
		dir = 1;
		radius = 30;
		followScroll = true;
		color = 0xFFCB2D;
		alertOutside = true;
		autoKillOutsider = true;
		autoKill = LeaveScreen;
		frictX = frictY = 0.90;
		initLife(30);
		pullable = false;
		cadency = 15;
		
		if( waveCount()>1 )
			setCD("wait", 30*3*(waveCount()-1));
		
		var a = rseed.rand() * 6.28;
		setPosScreen(
			Game.WID*0.5 + Math.cos(a)*Game.WID*1.3,
			Game.HEI*0.5 + Math.sin(a)*Game.HEI*0.8
		);
		
		var mc = new lib.Guepe();
		spr.addChild(mc);
		
		animMC = cast mc;
		cacheAnims("bee", 1);
		cachedAnimMC.x -= 10;
		cachedAnimMC.y -= 5;
		setAnim("right");
		
		newTarget();
		var base = 3.142 * 0.25;
		var q = 3.142 * 0.5;
		if( a>=base && a<=base+q )
			target.y = Game.HEI*0.9 - rseed.rand()*Game.HEI*0.05;
			
		if( a>=base+q*1 && a<=base+q*2 )
			target.x = Game.WID*0.1 + rseed.rand()*Game.WID*0.05;
			
		if( a>=base+q*2 && a<=base+q*3 )
			target.y = Game.HEI*0.1 + rseed.rand()*Game.HEI*0.05;

		if( a>=base+q*3 && a<=base+q*4 )
			target.x = Game.WID*0.9 - rseed.rand()*Game.WID*0.05;
	}
	
	public override function toString() { return super.toString()+"[Bee]"; }

	function newTarget() {
		var pt = getScreenPoint();
		do {
			target = {
				x	: Game.WID*0.2 + rseed.rand()*Game.WID*0.6,
				y	: Game.HEI*0.2 + rseed.rand()*Game.HEI*0.6,
			}
		} while( Math.abs(pt.x-target.x)<=180 && Math.abs(pt.y-target.y)<=150 );
	}
	
	public override function onDie() {
		super.onDie();
		if( waveKilled() )
			dropReward(2);
		for( i in 0...5 ) {
			var it = dropReward(1);
			it.dy -= rseed.range(0.01, 0.06);
			it.dx = rseed.range(0.05, 0.15, true);
		}
	}
	
	public override function update() {
		if( !hasCD("wait") ) {
			if( animDone() )
				setAnim("right");
				
			if( target!=null ) {
				var pt = getScreenPoint();
				if( Math.abs(target.x-pt.x)>=30 || Math.abs(target.y-pt.y)>=30 ) {
					var a = Math.atan2(target.y-pt.y, target.x-pt.x);
					dx += Math.cos(a)*0.03;
					dy += Math.sin(a)*0.03;
				}
				else {
					target = null;
					setCD("beePause", 30*4);
				}
			}
			else if( !hasCD("beePause") )
				newTarget();
				
			if( Math.abs(dx)<=0.05 && Math.abs(dy)<=0.05 && hasCD("beePause") && !hasCD("shoot") ) {
				dx = dy = 0;
				setAnim("right");
				setAnim("shoot", false);
				setCD("shoot", cadency);
				new bullet.Bad(this, 0xF45B2F).toPlayer(0.20);
			}
			
			if( dx<0 && dir==1 || dx>0 && dir==-1 ) {
				setAnim("turn", false);
				spr.scaleX *= -1;
			}
			dir = if(dx>0) 1 else if(dx<0) -1 else dir;
		}
		
		super.update();
	}
}
