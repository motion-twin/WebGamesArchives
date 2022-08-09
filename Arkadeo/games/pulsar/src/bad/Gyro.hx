package bad;
import mt.bumdum9.Lib;


class Gyro extends Arrow  {//}
	

	var step:Int;
	var sleep:Int;
	
	var sk:gfx.Gyro;

	public function new() {
		super(GYRO);
		setFamily();
		ray = 7;
		sk = cast setSkin(new gfx.Gyro(), 8);
		sk.stop();
		speed = 2;
		setFloat( 8, 8, 13);
		angle = (rnd(100)/100) * 6.28;
		step  = 0;
		setFloat( 4, 4, 7);
		sleep = 160 + rnd(250);
		
		if ( have(GYRO_FAST_OPEN) ) sleep >>= 3;
		skin.scaleX = skin.scaleY = 1.2;
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0:
				if (timer > sleep) {
					step++;
					timer = 0;
					vx = Math.cos(angle) * speed;
					vy = Math.sin(angle) * speed;
					speed = 0;
					//play("gyro_open", false);
					//skin.anim.onFinish = launch;
					sk.gotoAndPlay(2);
				}
			
			case 1 :
				if( timer == 23 ) launch();
				
			case 2 :
				follow(hero.x, hero.y,  have(GYRO_SPEED)?0.09:0.05);
				sk.rotation = angle / 0.0174 + 90;
		}

		// LIGHT
		var fr = Std.int(Num.sMod(-sk.rotation,360));
		sk._left.gotoAndStop(fr);
		sk._right.gotoAndStop(fr);
		
	}
	
	function launch() {
		speed = have(GYRO_SPEED)?6:3.5;
		step++;
		vy -= 2;
		angle = -1.57;
	}
}
