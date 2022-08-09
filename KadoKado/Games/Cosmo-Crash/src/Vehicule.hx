import mt.bumdum.Lib;

class Vehicule extends Element {//}


	public var flShoot:Bool;
	public var type:Int;
	public var sens:Int;
	public var tx:Float;
	public var cana:Float;

	public var canonSpeed:Float;
	public var canonDist:Float;
	public var cadence:Float;
	public var shotSpeed:Float;
	public var canonAngleLim:Float;

	public var cooldown:Float;
	public var width:Float;
	public var wray:Float;
	public var acc:Float;

	var wheels:Array<flash.MovieClip>;

	public var dm:mt.DepthManager;
	public var car:flash.MovieClip;
	public var car2:flash.MovieClip;
	public var canon:flash.MovieClip;



	public function new(){
		super(Game.me.dm.empty(Game.DP_VEHICULE)) ;
		dm = new mt.DepthManager(root);

		car = dm.attach("mcJeep",2);
		car2 = dm.attach("mcJeep",0);
		setType( Game.me.dif < 3600 ?0:1 );

		cooldown = 0;
		cana = -1.57;


		canon = dm.attach("mcCanon",1);
		canon._x = width*0.5;
		canon._y = -10;
		canon._rotation = cana/0.0174;



		x = Game.me.getFarAwayX();
		tx = Math.random()*Cs.lw;
		vx = 0.5;

		frict = 0.95;
		Game.me.vehicules.push(this);
		Filt.glow(root,2,4,0);


	}

	public function setType(t){
		type = t;
		switch(type){
			case 0 :
				wray = 5;
				width = 20;
				acc = 0.05;
				canonSpeed = 0.05;
				cadence = 50;
				canonDist = 10;
				shotSpeed = 2.5;
				canonAngleLim = 1.2;
				initWheels(3);

			case 1 :
				wray = 5;
				width = 18;
				acc = 0.1;
				canonSpeed = 0.1;
				cadence = 10;
				canonDist = 16;
				shotSpeed = 4;
				canonAngleLim = 1.8;
				initWheels(2);



		}

		car.gotoAndStop(type*2+1);
		car2.gotoAndStop(type*2+2);


	}
	public function initWheels(max){
		// WHEELS
		wheels = [];
		for( i in 0...max ){
			var mc = dm.attach("mcWheel",1);
			mc._x = i/(max-1)*width;
			wheels.push(mc);
		}
	}


	override function update(){
		flShoot = false;
		sens = vx>0?1:-1;
		//car._xscale = sens*100;
		//car2._xscale = sens*100;

		updateSkin();
		checkBehaviour();





		super.update();
	}

	// BEHAVIOUR
	public function checkBehaviour(){


		if( Game.me.hero== null ){
			move();
			return;
		}
		var hdx = Game.me.getHeroDX(x+width*0.5);
		if( Math.abs(hdx)<100 ){
			var v = getNearestVehicule();
			if( v==null || ( Math.abs(v.x-x) > 36 || !v.flShoot ) ){
				shoot();
				return;
			}
		}
		move();
	}

	function shoot(){
		flShoot = true;


		var ty = y+canon._y;
		var dx = Game.me.getHeroDX(x+canon._x);
		var dy = Game.me.hero.y - ty;

		var ta = Math.atan2(dy,dx);
		var da = Num.hMod(ta-cana,3.14);
		var lim = canonSpeed;
		cana += Num.mm(-lim,da*0.2,lim);

		recalCanon();


		//var dr = Num.hMod(canon._rotation-(car._rotation-90),180);
		//if( dr > 90 ) canon._rotation  -= dr-90;
		//if( dr < -90 ) canon._rotation -= dr+90;



		if(cooldown-->0)return;


		cooldown = cadence;

		canon.smc.play();
		var p = Geom.getParentCoord(canon.smc,root);

		var ca = Math.cos(cana);
		var sa = Math.sin(cana);
		var shot = new Shot();
		shot.x = p.x;
		shot.y = p.y;
		shot.vx  = ca*shotSpeed;
		shot.vy  = sa*shotSpeed;
		shot.root.gotoAndStop(type+1);

		shot.updatePos();

	}

	function recalCanon(){
		var csta = car._rotation*0.0174 - 1.57;
		var lim = canonAngleLim;
		cana = Num.mm( csta-lim ,cana,  csta+lim );
		canon._rotation = cana/0.0174;
	}

	function move(){
		if( tx ==null || x ==null ){
			trace("BLUUUUUUUUUUUUURGH");
			return;
		}
		var dx = Num.hMod(tx-x,Cs.lw*0.5);
		if( Math.abs(dx) < 100 ){
			tx = Math.random()*Cs.lw;
		}else{
			vx += Math.abs(dx)/dx*acc;
		}

	}



	public function updateSkin(){

		var wx = x;
		y = Game.me.getGY(x)-wray;
		var ys = 0.0;

		var last = null;
		var id = 0;

		var an  = null;

		for( mc in wheels ){
			wx = x+mc._x;
			var wy = Game.me.getGY(wx);
			mc._y = (wy-wray) - y;
			ys += mc._y;
			id++;
			if( id == wheels.length ) an = Math.atan2(mc._y,mc._x);
			var last = mc;
		}

		car._rotation = an/0.0174;
		recalCanon();


		an -= 1.57;
		car._x  = width*0.5;
		car._y  = ys/wheels.length;
		canon._x = car._x + Math.cos(an)*canonDist ;
		canon._y = car._y + Math.sin(an)*canonDist ;

		car2._x = car._x;
		car2._y = car._y;
		car2._rotation = car._rotation;


	}

	public function getNearestVehicule(){
		var trg = null;
		var dist = 9999.0;
		for( v in Game.me.vehicules ){
			var d =  Math.abs(x-v.x);
			if( d<dist && v!= this ){
				dist = d;
				trg = v;
			}
		}
		return trg;
	}

//{
}











