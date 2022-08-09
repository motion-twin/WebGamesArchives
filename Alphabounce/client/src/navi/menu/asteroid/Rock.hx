package navi.menu.asteroid;
import mt.bumdum.Lib;
import mt.bumdum.Phys;


class Rock extends Rel{//}


	public var speed:Float;
	public var angle:Float;
	public var life:Float;


	public function new(mc){
		super(mc);
		game.rocks.push(this);
		speed = 0;
		angle = Math.random()*6.28;
		vr = (Math.random()*2-1)*1.5;
		life = 1;

	}

	public function initPos(){
		if(Std.random(2)==0){
			x = Math.random()*Cs.mcw;
			y = Cs.mch*0.5 + (Std.random(2)*2-1)*(Cs.mch*0.5+ray);
		}else{
			y = Math.random()*Cs.mch;
			x = Cs.mcw*0.5 + (Std.random(2)*2-1)*(Cs.mcw*0.5+ray);
		}
	}
	public function setSpeed(n){
		speed = n;
		vx = Math.cos(angle)*speed;
		vy = Math.sin(angle)*speed;
	}



	override public function update(){
		root.filters = [];
		super.update();
		checkCols();
	}


	public function checkCols(){
		var list = game.shots.copy();
		for( shot in list ){
			var dx = shot.x-x;
			var dy = shot.y-y;
			var rr = shot.ray+ray;
			if( Math.abs(dx)<rr && Math.abs(dy)<rr ){
				var dist = Math.sqrt( dx*dx + dy*dy );
				if( dist < rr ){
					shot.kill();
					damage(shot.damage);
					return;
				}
			}
		}
	}


	public function damage(n:Float){
		life-=n;
		if( life<=0 ){
			explode();
		}else{
			Filt.glow(root,10,2,0xFFFFFF);
		}

	}

	public function explode(){


		// DIVISION
		if( ray > 10 ){
			var pa = angle+1.57;
			var dx = Math.cos(pa)*ray*0.5;
			var dy = Math.sin(pa)*ray*0.5;
			for( i in 0...2 ){
				var sens = i*2-1;
				var rock  = game.newRock();
				rock.x = x+dx*sens;
				rock.y = y+dy*sens;
				rock.angle = angle+1.57*sens + (Math.random()*2-1)*0.1;
				rock.setRay(ray*0.5);
				rock.setSpeed(speed);
			}
			// OPTS
			if( Std.random(4) == 0 )game.newOpt(x,y);
		}

		// PARTS
		var max = Std.int(ray*0.4);
		var cr = 4;
		for( i in 0...max ){
			var sp = 0.5+Math.random()*4;
			var a = i/max * 6.28;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var p = new Phys(game.gdm.attach("astTriangle",2));
			p.x = x + ca*cr*sp;
			p.y = y + sa*cr*sp;
			p.vx = ca*sp ;
			p.vy = sa*sp ;
			p.frict = 0.97;
			p.timer = 10+Math.random()*20;
			p.fadeType = 0;
			p.setScale( 50+Math.random()*100 );
			p.root._rotation = Math.random()*360;
			p.vr = (Math.random()*2-1) * 5;
			p.fr = 0.97;
			p.root._alpha = 50;
		}

		//
		kill();

	}



	public function setRay(n){
		ray = n;
		setScale(ray*2);
		life = ray*0.1;
	}

	override public function kill(){
		game.rocks.remove(this);
		super.kill();
	}

//{
}








