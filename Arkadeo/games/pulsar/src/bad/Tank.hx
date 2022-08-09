package bad;
import mt.bumdum9.Lib;

class Tank extends Bad  {
	var di:Int;
	var k:Float;
	var sens:Int;
	var speedMax:Float;
	var step:Int;
	var shot:Int;
	var shotMax:Int;
	var moveFrame:Float;
	var coef:Float;
	var sk:gfx.SideShooter;
	
	public function new() {
		super(TANK);
		sk = cast setSkin(new gfx.SideShooter(),0);
		Game.me.dm.add(root, Game.DP_BORDER);
		moveFrame = 0;
		ray = 10;
		sens = rnd(2) * 2 - 1;
		
		step = 0;
		coef = 0;
		
		shotMax = have(TANK_ULTRA_FIRE)?8:4;
		speedMax = 6 + rnd(60)*0.1;
	}
	
	override function setBorderPos(di,n) {
		this.di = di;
		k =  n;
		root.rotation = di * 90;
		updatePos();
	}
	
	override function updatePos() {
		var pos = Game.me.borderToPos(di, k);
		var ma = ray;
		x = pos.x + Game.DIR[di][0] * ma;
		y = pos.y + Game.DIR[di][1] * ma - zh;
		super.updatePos();
	}
		
	override function update() {
		var speed = 0.0;
		switch(step) {
			case 0 :
				coef = Math.min(coef + 0.005, 1);
				speed = Math.pow(Math.sin(coef * 3.14),2) * speedMax;
				if ( coef == 1 ) {
					step++;
					coef = 0;
					shot = shotMax;
					timer = 0;
				}
			case 1 :
				if ( timer++ > 6 ) {
					if ( shot--> 0 ) {
						var an = di * Math.PI*0.5;
						if ( have(TANK_ARC) ) an += (shot - (shotMax >> 1)) * 0.25;
						fire(an, 8);
						sk.gotoAndPlay(2);
						timer = 0;
						#if sound
						Sfx.play(13,0.5);
						#end
					} else {
						step = 0;
						coef = 0;
					}
				}
		}
		
		// MOVE
		k += sens * speed;
		var ma = ray;
		if ( k < ray ) {
			di--;
			if ( di < 0 ) di += 4;
			k += getBorderLength() - 2*ray;
			root.rotation = di * 90;
		}
		
		if ( k > getBorderLength()-ray ) {
			k += 2 * ray -getBorderLength();
			di++;
			if ( di >= 4 ) di -= 4;
			root.rotation = di * 90;
		}
		//
		moveFrame = (moveFrame + speed ) % 6;
		sk._chenilles.gotoAndStop(Std.int(moveFrame)+1);
		
		// BOLTS
		if( 3-Math.random()*speed < 0 && Game.me.have(ELECTRIC_WALLS) ){
			var el = Game.me.setFx("volt_a", x , y );
			el.anim.goto(3);
			Game.me.dm.add(el, Game.DP_BORDER);
			var ma = 12;
			el.x -= Game.DIR[di][0] * ma;
			el.y -= Game.DIR[di][1] * ma;
			el.shuffleDir();
			el.blendMode = flash.display.BlendMode.ADD;
			Filt.glow(el, 4, 1, 0xFFFF44);
		}
		
		super.update();
		
	}

	public function getBorderLength() {
		if ( di % 2 == 0 ) return Game.HEIGHT - Game.BORDER_Y * 2;
		return Game.WIDTH - Game.BORDER_X * 2;
	}
}
