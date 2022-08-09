import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;

class Ball extends Element{//}

	static var ANGLE_MAX = 1.2;

	public var flUp:Bool;
	public var flBounce:Bool;
	public var type:mt.flash.Volatile<Int>;
	public var speed:Float;
	public var damage:Float;
	public var gluePoint:Float;
	public var ray:Float;
	public var va:Float;
	public var ca:Float;
	public var sleep:Float;
	public var trg:Block;

	public function new(mc){
		super(mc);
		Game.me.balls.push(this);
		ox = 0;
		oy = 0;
		px = Std.int(Cs.XMAX*0.5);
		py = Std.int(Cs.YMAX-3);
		vx  = (Math.random()*2-1);
		vy  = -(4+Math.random()*2);
		speed = 6;
		flUp = true;
		setType(Cs.BALL_STANDARD);
	}

	override public function update(){

		flBounce = false;

		if(gluePoint!=null){
			y = Game.me.pad.y-ray;
			x = Game.me.pad.x+gluePoint;
			moveTo(x,y);
			updatePos();
			if(type == Cs.BALL_FIRE )root.smc._rotation = 90;
			return;
		}

		if(sleep!=null){
			sleep -= mt.Timer.tmod;
			if(sleep<0)sleep = null;
			return;
		}

		super.update();
		// CHECK PAD
		if( flUp && vy>0 && y > Game.me.pad.y-ray ){
			var cx = (x-Game.me.pad.x)/Game.me.pad.ray;
			if(Math.abs(cx)<1){
				if(type==Cs.BALL_SHADE){
					destroy();
					return;
				}
				colPad(cx);

			}else if( Game.me.pad.flProtect ){
				colProtect();

			}else{
				flUp = false;
			}
		}

		// CHECK DEATH;
		if( !flUp && y>Cs.mch+10 ){

			if( Game.me.balls.length == 1 && Game.me.levelTimer<600 && Game.me.flSafe && type!=Cs.BALL_SHADE ){
				moveTo(x,Cs.mch+10);
				vy*=-1;
				flUp = true;
				Game.me.newTitle("SAUVETAGE !",0xFF0000,true);
				if( Game.me.lvl == 0 )setSpeed(3);
			}else{
				destroy();
			}
		}

		//

		switch(type){
			case Cs.BALL_FIRE:
				var a = Math.atan2(vy,vx);
				root.smc._rotation = a/0.0174;
				genSparks(1,20);


			case Cs.BALL_ICE:
				genSparks(2,10);
				genIceShards();
				Game.me.plasmaDraw(root);

			case Cs.BALL_DRUNK:
				var a = Math.atan2(vy,vx);
				va += (Math.random()*2-1)*0.03*(speed/6)*mt.Timer.tmod;
				va *= Math.pow(0.95,mt.Timer.tmod);

				a += va*mt.Timer.tmod;
				vx = Math.cos(a)*speed;
				vy = Math.sin(a)*speed;

				genBubbles();
				Game.me.plasmaDraw(root);

			case Cs.BALL_KAMIKAZE:
				if(trg==null || trg.flDeath ){
					trg = Game.me.blocks[Std.random(Game.me.blocks.length)];
					ca = 0.01;
				}
				if(trg!=null){
					var a = Math.atan2(vy,vx);
					var dx = Cs.getX(trg.x+0.5) - x;
					var dy = Cs.getY(trg.y+0.5) - y;
					var ta = Math.atan2(dy,dx);

					ca = Math.min(ca+0.002*mt.Timer.tmod,1);

					va += Num.hMod(ta-a,3.14)*ca;
					va *= Math.pow(0.8,mt.Timer.tmod);

					a += va;//*mt.Timer.tmod;

					vx = Math.cos(a)*speed;
					vy = Math.sin(a)*speed;
				}
				Game.me.plasmaDraw(root);

			case Cs.BALL_YOYO:
				var sp = speed*4*(1-(y/(Cs.mch+15)));
				var a = Math.atan2(vy,vx);
				vx = Math.cos(a)*sp;
				vy = Math.sin(a)*sp;
				Game.me.plasmaDraw(root);

			case Cs.BALL_HALO:
				Game.me.plasmaDraw(root);

			case Cs.BALL_SHADE:
				Game.me.plasmaDraw(root);

			default :
				Game.me.plasmaDraw(root);

		}

		//
		if( flBounce ){

			for( i in 0...2 ){
				var a = Math.atan2(vy,vx);
				var ba = i*3.14;
				var da = Num.hMod(ba-a,3.14);
				var la = 1.57-ANGLE_MAX;
				if( Math.abs(da) < la ){
					var dif = la-Math.abs(da);
					var sens = Math.abs(da)/da;
					if(da==0)sens=1;
					a -= dif*sens;
					setAngle(a);
				}

			}

		}

	}

	public function colPad(cx:Float){
		// RECAL
		//var r = vy/vx;
		//var dy = Game.me.pad.y-y;
		//var dx = dy*r;
		moveTo( x, Game.me.pad.y-ray );
		updatePos();

		// CALCUL DU REBOND
		var  a = -1.57 + cx*ANGLE_MAX;
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
		Game.me.pad.padec = null; // AUTO PLAY

		// GLUE
		if( Game.me.pad.type == Cs.PAD_GLUE ){
			gluePoint = x-Game.me.pad.x;
			var max = 10;
			for( i in 0...max ){
				var a = - i/max * 3.14;
				var ca = Math.cos(a);
				var sa = Math.sin(a);
				var sp = 0.5+Math.random()*3;
				var cr = 4;
				var p = new Phys(Game.me.dm.attach("partGlue",0));
				p.x = x+ca*sp*cr;
				p.y = y+sa*sp*cr;
				p.vx = ca*sp;
				p.vy = sa*sp;
				p.weight = 0.1+Math.random()*0.15;
				p.timer = 10+Math.random()*10;
				p.setScale(p.weight*400);
				p.fadeType = 0;
			}
		}

		// TRIPLE
		if( type == Cs.BALL_HALO ){
			var max = 5;
			for( i in 0...max ){
				var b = clone();
				b.sleep = (i+1)*3 -1;
				b.setType(Cs.BALL_SHADE);
				b.root._alpha = 50;
				Game.me.dm.under(b.root);
			}
		}
	}
	public function colProtect(){
		moveTo( x, Game.me.pad.y-ray );
		updatePos();
		vy*=-1;

		//PARTS
		var max = Std.int( 2+12*Cs.getPerfCoef());
		var cr = 3;
		for( i in 0...max ){
			var a = (i/max-1)*3.14 + (Math.random()*2-1)*0.2;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = 0.5+Math.random()*4;
			var p = new fx.Spark(Game.me.dm.attach("partLine",Game.DP_PARTS));
			p.x = x + ca*sp*cr;
			p.y = y + sa*sp*cr + 5;
			p.vx = ca*sp;
			p.vy = sa*sp;
			p.weight = 0.1+Math.random()*0.1;
			p.timer= 10+Math.random()*20;
			p.root._yscale = 200;
			Filt.glow(p.root,15,5,0xFF00FF);
		}

	}
	//
	public function setType(n:Int){

		if(type==Cs.BALL_SHADE)	return;

		//
		type = n;
		root.gotoAndStop(type+1);

		//
		switch(type){
			case Cs.BALL_STANDARD:
				damage = 1;
				ray = 4;
			case Cs.BALL_FIRE:
				damage = 2;
				ray = 5;

			case Cs.BALL_ICE:
				damage = 1;
				ray = 4;
			case Cs.BALL_DRUNK:
				damage = 1;
				ray = 4;
				va = 0;
			case Cs.BALL_KAMIKAZE:
				damage = 1;
				ray = 5;
				va = 0;
			case Cs.BALL_HALO:
				damage = 1;
				ray = 4;
		}
	}
	public function setSpeed(n){
		//FIX(yota): Zele do creates infinite loops with Kamikaze
		if (n > 30.0 && type == Cs.BALL_KAMIKAZE)
			setType(Cs.BALL_STANDARD);

		speed = n;
		var a = Math.atan2(vy,vx);
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
	}
	public function setAngle(a){
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
	}


	//
	override function onBounce(px,py){
		Game.me.hit(px,py,this);
		flBounce = true;
		//
		if( type == Cs.BALL_SHADE && px>0 && px<Cs.XMAX ){
			destroy();
		}

	}

	//
	public function clone(){
		var ball = Game.me.newBall();
		ball.moveTo(x,y);
		ball.updatePos();
		ball.speed = speed;
		ball.flUp == flUp;
		ball.setType(type);
		ball.vx = vx;
		ball.vy = vy;
		ball.gluePoint = gluePoint;
		return ball;
	}

	// FX
	function genSparks(fr,turn){
		if( Std.random(Sprite.spriteList.length) < 20){
			for( i in 0...1 ){
				var p = new Phys(Game.me.dm.attach("partSpark",Game.DP_UNDERPARTS));
				p.x = x;
				p.y = y;
				var c = 0.3+Math.random()*0.5;
				p.vx = c*vx;
				p.vy = c*vy;
				p.vr = (Math.random()*2-1)*turn;
				p.root._rotation = Math.random()*360;
				p.timer = 10+Math.random()*30;
				p.root.gotoAndStop(fr);
				p.root.smc._x = Math.random()*15;
				p.frict = 0.95;
			}
		}
	}
	function genIceShards(){
		if( Std.random(Sprite.spriteList.length) < 15){

			var p = new Phys(Game.me.dm.attach("partIceShard",Game.DP_UNDERPARTS));
			p.x = x+(Math.random()*2-1)*4;
			p.y = y+(Math.random()*2-1)*4;
			var c = 0.7+Math.random()*0.3;
			p.vx = c*vx;
			p.vy = c*vy;
			p.vr = (Math.random()*2-1)*8;
			p.root._rotation = Math.atan2(vy,vx)/0.0174;
			p.timer = 10+Math.random()*10;
			p.fadeType = 0;
			p.weight = 0.1+Math.random()*0.1;

		}
	}
	function genBubbles(){
		if( Std.random(Sprite.spriteList.length) < 15){

			var p = new Phys(Game.me.dm.attach("partBubble",Game.DP_UNDERPARTS));
			p.x = x+(Math.random()*2-1)*4;
			p.y = y+(Math.random()*2-1)*4;
			var c = 0.1+Math.random()*0.2;
			p.vx = c*vx;
			p.vy = c*vy;
			p.timer = 10+Math.random()*20;
			p.fadeType = 0;
			p.weight = -(0.1+Math.random()*0.2);
			p.setScale(50+Math.random()*100);

		}
	}
	//
	function destroy(){
		kill();
		if( Game.me.balls.length == 0 ){
			Game.me.initGameOver();
		}
	}
	override public function kill(){
		Game.me.balls.remove(this);
		super.kill();
	}

//{
}













