package navi.menu.asteroid;
import navi.menu.asteroid.Shot;
import mt.bumdum.Lib;
import mt.bumdum.Phys;


class Ship extends Rel{//}

	var angle:Float;
	var acc:Float;
	var fireRate:Float;
	var cooldown:Float;

	var optSpeed:Int;
	var optSize:Int;
	var optRate:Int;

	public function new(mc){
		super(mc);

		frict = 0.995;
		acc = 0.25;
		ray = 10;
		fireRate = 10;

		x = Cs.mcw*0.5;
		y = Cs.mch*0.5;
		angle = 0;
		cooldown = 0;

		optSpeed = 0;
		optSize = 0;
		optRate = 0;

	}


	// UPDATE
	override public function update(){


		if(cooldown>0)cooldown-=mt.Timer.tmod;

		super.update();

		checkCols();



	}

	public function fxThrust(){
		for( i in 0...2 ){
			var p = new Phys( game.gdm.attach("astSpark",3) );
			var a = (Math.random()*2-1)*0.5 + angle-3.14;
			var sp = 0.5+Math.random()*5;
			p.x = x - Math.cos(angle)*ray;
			p.y = y - Math.sin(angle)*ray;
			p.vx = Math.cos(a)*sp + vx;
			p.vy = Math.sin(a)*sp + vy;
			p.timer = 10+Math.random()*10;
			p.fadeType = 0;
			p.updatePos();
			p.vr = (Math.random()*2-1)*10;
			p.root._rotation = Math.random()*360;
		}
	}


	public function checkCols(){
		var list = game.rocks.copy();
		for( rock in list ){
			var dx = rock.x-x;
			var dy = rock.y-y;
			var rr = rock.ray+ray;
			if( Math.abs(dx)<rr && Math.abs(dy)<rr ){
				var dist = Math.sqrt( dx*dx + dy*dy );
				if( dist < rr ){
					rock.explode();
					kill();
					game.initGameOver();
					return;
				}
			}
		}

		var list = game.options.copy();
		for( opt in list ){
			var dx = opt.x-x;
			var dy = opt.y-y;
			var rr = opt.ray+ray;
			if( Math.abs(dx)<rr && Math.abs(dy)<rr ){
				var dist = Math.sqrt( dx*dx + dy*dy );
				if( dist < rr ){
					applyOption(opt.type);
					opt.kill();
				}
			}
		}
	}

	public function applyOption(id){
		switch(id){
			case 0 : optSpeed++;
			case 1 : optSize++;
			case 2 : optRate++;
		}

		if(optSpeed>3)optSpeed = 3;
		if(optSize>3)optSize = 3;
		if(optRate>3)optRate = 3;


	}


	// CONTROL
	public function control(){

		if( mt.flash.Key.isDown(39) ) turn(1);
		if( mt.flash.Key.isDown(37) ) turn(-1);
		if( mt.flash.Key.isDown(38) ) thrust(1);
		if( mt.flash.Key.isDown(40) ) bomb();
		if( mt.flash.Key.isDown(17) ) fire(angle);

	}
	function turn(sens){
		angle = Num.hMod(angle+sens*0.1*mt.Timer.tmod,3.14);
		orient();
	}
	function thrust(sens){
		vx += Math.cos(angle)*acc*sens;
		vy += Math.sin(angle)*acc*sens;

		fxThrust();


	}
	function bomb(){

	}
	function fire(a){
		if(cooldown>0)return;
		if(cooldown<=0){
			cooldown = fireRate*(1-optRate*0.25);
			var sp = 4+optSpeed*2;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var shot = new Shot(game.gdm.attach("astBullet",1));
			shot.damage = 1+optSize;
			shot.x = x + ca*ray;
			shot.y = y + sa*ray;
			shot.vx = ca*sp + vx;
			shot.vy = sa*sp + vy;
			shot.setScale(100+50*optSize);
			shot.timer = 60;
		}
	}



	override public function kill(){
		var max = 128;
		var cr = 4;
		for( i in 0...max ){
			var sp = Math.random()*7;
			var a = i/max * 6.28;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var p = new Phys(game.gdm.attach("astPoint",2));
			p.x = x + ca*cr*sp;
			p.y = y + sa*cr*sp;
			p.vx = ca*sp + vx;
			p.vy = sa*sp + vy;
			p.frict = 0.97;
			p.timer = 10+Math.random()*20;
			p.fadeType = 0;
			p.setScale( 50+Math.random()*100 );
			p.root._rotation = Math.random()*360;
			p.vr = (Math.random()*2-1) * 5;
			p.fr = 0.97;
		}

		//
		game.ship = null;
		super.kill();
	}

	// TOOLS
	function orient(){
		root._rotation = angle/0.0174;
	}



//{
}








