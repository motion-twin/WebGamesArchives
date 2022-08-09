package el;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;

class Ball extends Element{//}

	static var ANGLE_MAX = 1.2;


	public var flReady:Bool;
	public var flPierce:Bool;
	public var flUp:Bool;
	public var flImmortal:Bool;
	public var flBounce:Bool;
	public var type:Int;

	public var fam:Int;
	public var pdec:Float;
	public var speed:Float;
	public var angle:Float;

	public var damage:Float;
	public var baseDamage:Float;
	public var pierceDamage:Float;

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
		speed = 5;
		flUp = true;
		flImmortal = false;
		damage = 1;

		flReady = true;

		//
		initFamily();
		//
		setType(Cs.BALL_STANDARD);

		if(Cs.PREF_BOOLS[3])Filt.glow(root,2,2,0);



	}
	function initFamily(){
		fam = 0;
		if(Cs.pi.gotItem(MissionInfo.BALL_DRILL)) fam = 1;
		if(Cs.pi.gotItem(MissionInfo.BALL_SOLDAT)) fam = 2;
		if(Cs.pi.gotItem(MissionInfo.BALL_POWER)) fam = 3;
		if(Cs.pi.gotItem(MissionInfo.BALL_BLACK)) fam = 4;
		#if test
		fam = 1;
		#end

		if( fam >= 3 )damage += 1;
		if( fam >= 4 ){
			damage += 1;
			flPierce = true;
			pierceDamage = damage;
		}



		baseDamage = damage;
	}

	override public function update(){



		flBounce = false;
		if(gluePoint!=null){

			var nx = Game.me.pad.x+gluePoint;
			if( nx<ray || nx>Cs.mcw-ray  ){
				if( flReady )gluePoint = null;
			}else{
				if(!flReady)flReady = true;
				y = Game.me.pad.y-ray;
				x = nx;
				moveTo(x,y);
				updatePos();
				if(type == Cs.BALL_FIRE )root.smc._rotation = 90;
				return;
			}
		}else{
			if(Game.me.flFirstBall )Game.me.flFirstBall = false;
		}

		if(sleep!=null){
			sleep -= mt.Timer.tmod;
			if(sleep<0)sleep = null;
			return;
		}

		super.update();
		// CHECK PAD
		checkPad();

		// CHECK DEATH;
		if( !flUp && y>Cs.mch+10 && !flImmortal ){

			if( Game.me.balls.length == 1 && Game.me.levelTimer<600 && Game.me.flSafe && type!=Cs.BALL_SHADE ){
				moveTo(x,Cs.mch+10);
				vy*=-1;
				flUp = true;
				Game.me.newTitle("SAUVETAGE !",0xFF0000,true);
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

			case Cs.BALL_VOLT:
				//
				if(mt.Timer.tmod<1.5 && Std.random(5)==0 ){
					var mc = Game.me.dm.attach("mcBolt",Game.DP_PARTS);
					mc._xscale = mc._yscale = 50+Math.random()*100;
					Filt.glow( mc,10,1,0xFFFF00 );
					mc.blendMode = "add";
					mc._x = x;
					mc._y = y;
					mc._rotation =  Math.random()*360;
				}

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
				if(trg==null || trg.flDeath || !Block.isSoft(trg.type)){
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

					if(Math.random()*60/mt.Timer.tmod<1)trg = null;

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
	function checkPad(){
		if( flUp && vy>0 && y > Game.me.pad.y-ray ){
			var cx = (x-Game.me.pad.x)/Game.me.pad.ray;
			if(Math.abs(cx)<1 && Game.me.pad.missileCoef==null ){
				if(type==Cs.BALL_SHADE){
					destroy();
					return;
				}
				colPad(cx);

			}else{
				flUp = false;
			}
		}
	}

	public function colPad(cx:Float){

		Game.me.pad.bounceBall(this);
		pdec = null;
		Sound.play("bank.wav",50);


		// RECAL
		moveTo( x, Game.me.pad.y-ray );
		updatePos();

		// CALCUL DU REBOND
		var  a = -1.57 + cx*ANGLE_MAX;
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
		Game.me.pad.newPadec(); // AUTO PLAY




		// HALO
		if( type == Cs.BALL_HALO ){
			setGhost(true);

		// GLUE
		}else if( Game.me.pad.type == Cs.PAD_GLUE ){
			Game.me.autoLaunchTimer = 0;
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


		if( flPierce ){
			root.smc.smc._xscale = root.smc.smc._yscale = 100;
			pierceDamage = damage;
		}
	}

	//
	override public function setGhost(fl){
		super.setGhost(fl);
		if(!flGhost){

			Game.me.hit(px,py,this);
		}
	}

	//
	public function setType(n){
		if(type!=n && type!=null )fxPowerUp();
		if(type==Cs.BALL_SHADE)	return;




		//
		type = n;
		root.gotoAndStop(type+1);
		damage = baseDamage;

		if(type==0)root.smc.gotoAndStop(1+fam);

		//
		switch(type){
			case Cs.BALL_STANDARD:
				ray = 4;
			case Cs.BALL_FIRE:
				damage += 1;
				ray = 5;
			case Cs.BALL_VOLT:
				damage = 0.1;
				ray = 5;
			case Cs.BALL_ICE:
				ray = 4;
			case Cs.BALL_DRUNK:
				ray = 4;
				va = 0;
			case Cs.BALL_KAMIKAZE:
				ray = 5;
				va = 0;
			case Cs.BALL_HALO:
				ray = 4;
		}

	}
	public function setSpeed(n){
		speed = n;
		var a = Math.atan2(vy,vx);
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
	}
	public function setAngle(a){
		angle = a;
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
	}

	//
	override function onBounce(px,py){


		flBounce = true;
		if( flPierce ){
			if( pierceDamage>0 ){
				var bl = Game.me.grid[px][py];
				if( bl.life !=null ){
					pierceDamage -= bl.life;
					if( pierceDamage>0 && type != Cs.BALL_ICE )flBounce = false;
				}
			}else{
				root.smc.smc._xscale = root.smc.smc._yscale = 60;
			}
		}


		Game.me.hit(px,py,this);

		//
		if( type == Cs.BALL_SHADE && px>0 && px<Cs.XMAX )destroy();

		//
		super.onBounce(px,py);
		if(!flBounce){
			if(this.px!=px)vx*=-1;
			if(this.py!=py)vy*=-1;
		}

	}
	override function onEnterSquare(sx,sy){


		var mon =  Game.me.monsterGrid[px][py][0];
		if( mon !=null ){
			var mp = mon.getPos();
			var bp = getPos();
			var dx = bp.x - mp.x;
			var dy = bp.y - mp.y;
			var dist = Math.sqrt(dx*dx+dy*dy);
			if( dist < mon.ray+3 ){
				setAngle( Math.atan2(dy,dx) );
				mon.damage(this);
			}

		}


		if( type == Cs.BALL_VOLT ){
			var r = 2;
			var max = r*2+1;
			for( dx in 0...max ){
				for( dy in 0...max ){
					var nx = px+dx-r;
					var ny = py+dy-r;
					var bl = Game.me.grid[nx][ny];
					if( bl!=null  && bl.life!=null ){
						bl.damage(this);
						bl.fxBolt();
					}

				}
			}
		}

		/*
		var list = [];
		for( dx in 0...3 ){
			for( dy in 0...3 ){
				var nx = px+dx-1;
				var ny = py+dy-1;
				for( mon in Game.me.monsterGrid[nx][ny] )list.push(mon);
			}
		}

		for( mon in list ){
			var mp = mon.getPos();
			var bp = getPos();
			var dx = bp.x - mp.x;
			var dy = bp.y - mp.y;
			var dist = Math.sqrt(dx*dx+dy*dy);

			if( dist < 14 ){
				setAngle( Math.atan2(dy,dx) );
				mon.damage(this);
				break;
			}
		}
		*/




	}

	public function unglue(){
		if( x > Cs.SIDE && x<Cs.mcw-Cs.SIDE )gluePoint = null;
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
				p.root.blendMode = "add";
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
	public function fxLight(){
		var max = 24;
		var dm = new mt.DepthManager(root);
		for( i in 0...max ){
			var a = Math.random()* 6.28;
			var sp = new Phys(dm.attach("mcUltraRay",0));
			sp.root._rotation = a/0.0174;
			sp.root._yscale = 5;
			sp.root._xscale = 50+Math.random()*50;
			sp.root.blendMode = "add";
			sp.vr = Math.random()*2-1;
			sp.updatePos();
			if(i>8){
				sp.sleep = Math.random()*10;
				sp.root._visible = false;
				sp.root.stop();

			}


		}
	}
	public function fxPowerUp(){
		new mt.DepthManager(root).attach("fxBallPowerUp",0);
	}

	//
	public function destroy(){
		kill();
		if( Game.me.balls.length == 0 ){
			Game.me.killPad();
		}
	}
	override public function kill(){
		Game.me.balls.remove(this);
		super.kill();
	}

//{
}













