import mt.bumdum.Sprite;
import mt.bumdum.Lib;

class Pad extends Sprite{//}

	public static var SIDE = 14;
	public static var SPEED = 10;
	static var DY = 1;

	public var ray: mt.flash.Volatile<Float>;
	public var type: mt.flash.Volatile<Int>;
	public var moveFactor:Int;


	public var flGo: mt.flash.Volatile<Bool>;
	public var flStop:Bool;
	public var flProtect:Bool;
	public var flMouse:Bool;
	public var padec:Float;

	public var power:mt.flash.Volatile<Float>;
	public var recovery:mt.flash.Volatile<Float>;

	var skin:{>flash.MovieClip,side0:flash.MovieClip,side1:flash.MovieClip,mid:flash.MovieClip};
	var mcProtection:flash.MovieClip;

	public function new(mc){
		super(mc);
		skin = cast root;

		y = Cs.getY(Cs.YMAX+DY);
		x = Cs.mcw*0.5;

		flMouse = false;

	}

	public function init(){
		flGo = false;
		flStop = false;
		flProtect = false;
		power = null;
		moveFactor = 1;
		setRay(36);
		setType(Cs.PAD_STANDARD);
	}


	override public function update(){


		move();
		if(power!=null)updatePower();
		if(Game.me.flPress)salve();

		switch(type){
			case Cs.PAD_AIMANT:
				for( b in Game.me.balls ){
					if( b.vy>0 && b.type!=Cs.BALL_KAMIKAZE && b.type!=Cs.BALL_SHADE && b.y<y ){
						var a = Math.atan2(b.vy,b.vx);
						var dx = x - b.x;
						var dy = y - b.y;
						var ta = Math.atan2(dy,dx);
						var dist = Math.sqrt(dx*dx+dy*dy);
						a +=  Num.hMod(ta-a,3.14)*0.25;
						b.vx = Math.cos(a)*b.speed;
						b.vy = Math.sin(a)*b.speed;

						if( dist<150 && Math.random()*dist<30 ){
							var p = new fx.Attract(Game.me.dm.attach("partLine",Game.DP_PARTS));
							var ec = 12;
							p.x = b.x+(Math.random()*2-1)*ec;
							p.y = b.y+(Math.random()*2-1)*ec;
							p.dx = (Math.random()*2-1)*ray;
							Filt.glow(p.root,8,2,0xFFFFFF);
						}
					}
				}
				queue("mcGreenBar",100);
			case Cs.PAD_SHAKE:
				x += (Math.random()*2-1)*14;
				queue("mcPinkBar",15);

		}

		// SIDE RECAL
		if(!flGo){
			var r = ray+Cs.SIDE-1;
			x = Num.mm(r,x,Cs.mcw-r);
		}

		//
		super.update();

	}
	function move(){

		if(flGo){
			x += 3;
			if( x > Cs.mcw+ray+2 )Game.me.leaveLevel();
			if( flProtect )removeProtection();
			return;
		}

		if( Game.PLAY_AUTO ){
			if(padec==null)padec = (Math.random()*2-1)*0.5;
			x += ((Game.me.getLowestBall().x+padec*ray)-x)*0.5;
		}else{

			var inc = null;
			if( flash.Key.isDown(flash.Key.LEFT) )inc = -1;
			if( flash.Key.isDown(flash.Key.RIGHT) )inc = 1;

			if(inc!=null){
				flMouse = false;
				x += inc*SPEED*moveFactor*mt.Timer.tmod;
			}

			if(flMouse){
				var c = (Game.me.root._xmouse/Cs.mcw)*2-1;
				x = Cs.mcw*(0.5+moveFactor*c*0.5);
			}

		}

		// AUTO-PROTECT
		if(flProtect){
			power = Math.max(power-0.04,0);
			displayPowerBar();
			if(power==0){
				removeProtection();
				skin.mid.smc._alpha = 50;
			}
		}

		/*
		// GLUE
		for( b in Game.me.balls){
			if(b.gluePoint!=null){
				b.x = x+b.gluePoint;
				b.y = y-b.ray;
			}
		}
		*/


	}
	//
	function initPower(){
		power = 1;
		displayPowerBar();
		skin.mid.smc._alpha = 100;
	}
	function updatePower(){
		if(power<1){
			power = Math.min(power+recovery*mt.Timer.tmod,1);
			displayPowerBar();
			if(power==1)skin.mid.smc._alpha = 100;
		}
	}
	function displayPowerBar(){
		skin.mid.smc._xscale = 100*power;

	}
	//
	//
	public function action(){

		switch( type ){
			case Cs.PAD_TIME :
				if(power==1)flStop=true;
			case Cs.PAD_PROTECTION :
				if(power==1)initProtection();

			case Cs.PAD_LASER :
				var cost = 0.2;
				if(power>cost){
					power-=cost;
					for( i in 0...2 ){
						var shot = new shot.Laser( Game.me.dm.attach("mcLaser",Game.DP_PARTS) );
						shot.moveTo( x+(i*2-1)*(ray-9), y);
						shot.setVit(18);
						shot.updatePos();
					}
				}

		}
	}
	public function release(){
		switch( type ){
			case Cs.PAD_TIME :
				if(flStop){
					flStop = false;
					skin.mid.smc._alpha = 50;
				}
		}
	}
	public function salve(){
		for( b in Game.me.balls )b.gluePoint = null;
		switch( type ){
			case Cs.PAD_GLUE :


			case Cs.PAD_TIME :
				if(flStop){
					power = Math.max(power-0.03,0);
					displayPowerBar();
					if(power==0)release();
				}
			case Cs.PAD_PROTECTION :

		}
	}

	//
	function initProtection(){
		flProtect = true;
		mcProtection = Game.me.dm.attach("mcProtection",Game.DP_PAD);
		mcProtection._y = y+5;
		Game.me.dm.under(mcProtection);
	}
	function removeProtection(){
		flProtect = false;
		mcProtection.gotoAndPlay("remove");
	}
	//
	public function setType(n){
		//
		switch(type){
			case Cs.PAD_GLUE:
				for( b in Game.me.balls )b.gluePoint = null;
			case Cs.PAD_TIME:
				flStop = false;
			case Cs.PAD_PROTECTION:
				removeProtection();
		}

		//
		type = n;
		skin.mid.gotoAndStop(type+1);
		skin.side0.gotoAndStop(type+1);
		skin.side1.gotoAndStop(type+1);
		//
		switch(type){
			case Cs.PAD_GLUE:
			case Cs.PAD_TIME :
				recovery = 0.01;
				initPower();
			case Cs.PAD_LASER :
				recovery = 0.007;
				initPower();
			case Cs.PAD_SHAKE :
			case Cs.PAD_PROTECTION :
				recovery = 0.01;
				initPower();

		}
	}
	public function setRay(r){
		ray = r;
		var w = r-SIDE;
		skin.mid._xscale = w*2;
		skin.mid._x = -w;
		skin.side0._x = -r;
		skin.side1._x = r;
	}

	// FX
	public function powerUp(){
		// PARTS
		for( i in 0...24 ){
			var p = new fx.LineUp(Game.me.dm.attach("partLineUp",Game.DP_PARTS));
			p.x = x + (Math.random()*2-1)*ray;
			p.y = y;
			p.sleep = Math.random()*5;
			p.timer = 10+Math.random()*20;
			p.weight = -(0.1+Math.random()*0.3);
			p.root.blendMode = "add";
			p.factor = 3;
			Filt.glow(p.root,10,2,0xFFFFFF);
			//p.fadeType = 0;
		}
	}
	public function queue(link,alpha){
		var  brush = Game.me.dm.attach(link,0);
		brush._height = 12;
		brush._width = ray*2;
		brush._x = x-ray;
		brush._y = y;
		brush._alpha = alpha;
		Game.me.plasmaDraw(brush);
		brush.removeMovieClip();
	}

//{
}













