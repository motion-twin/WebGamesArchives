import mt.bumdum.Lib;

class Plat {//}

	public var step:Int;
	public var nextTimer:Int;
	public var capacity:mt.flash.Volatile<Int>;
	public var shuttleLevel:mt.flash.Volatile<Int>;

	static var SIDE = 10;
	public var flUp:Bool;

	public var x:Float;
	public var y:Float;
	public var ray:Float;

	var nextFolk:Folk;


	public var skin:{
		>flash.MovieClip,
		base:flash.MovieClip,
		left:flash.MovieClip,
		right:flash.MovieClip,
		pil0:flash.MovieClip,
		pil1:flash.MovieClip,
		shade:flash.MovieClip,
		rampe:{>flash.MovieClip,digit:flash.MovieClip,shuttle:flash.MovieClip},
	};


	public function new(x,y,ray){
		this.x = x;
		this.y = y;
		this.ray = ray;
		//ray = 20+Math.random()*50;
		skin = cast Game.me.dm.attach("mcPlat",Game.DP_PLAT);
		Reflect.setField(skin,"_launch", launch);

		// PLATEFORME
		skin.base._xscale  = ray*2 - 2*SIDE;
		skin.right._x = ray-SIDE;
		skin.left._x = SIDE-ray;

		// PILLIER
		var pr = ray-15;
		skin.pil0._x = -pr;
		skin.pil1._x = pr;

		// SHADE
		var sdm = new mt.DepthManager(skin.shade);
		skin.shade.smc._xscale = skin.base._xscale;

		/*
		// STRUCT
		for( k in 0...2 ){
			var sens = k*2-1;
			var p = { x:pr*sens, y:4.0 }
			for( i in 0...3 ){
				var ns = ((k+i+1)%2 )*2-1;
				var nx = pr*ns;
				var ny = p.y+30 ;//+(Math.random()*2-1)*10;
				var mc = sdm.attach("mcPlatBar",0);

				var dx = nx-p.x;
				var dy = ny-p.y;
				mc._x = p.x;
				mc._y = p.y;
				mc._xscale = Math.sqrt(dx*dx+dy*dy);
				mc._rotation = Math.atan2(dy,dx)/0.0174;

				p.x = nx;
				p.y = ny;
			}
		}
		//*/

		// RAMPE
		skin.rampe._x = 8+Game.me.seed.random(Std.int(ray*2-38))  - ray ;
		skin._x = x;
		skin._y = y;
		Game.me.plats.push(this);

		shuttleLevel = 0;

		newShuttle();


	}



	public function getWaypoint(folk:Folk):Float{
		if( step==0 ){
			if( nextFolk == folk ){

				// SC
				var sc = Cs.SCORE_FOLK[folk.type];
				Game.me.fxScore( x+skin.rampe._x+10, y-25, KKApi.val(sc) );
				KKApi.addScore(sc);
				skin.rampe.gotoAndPlay("close");
				skin.rampe.smc.gotoAndPlay("_face");
				folk.applySkin(skin.rampe.smc);
				folk.kill();
				nextFolk = null;
				incCapacity(-1);
				if( capacity == 0 )takeOf();
				return null;
			}
			if( nextFolk == null ){
				skin.rampe.gotoAndPlay("open");
				nextFolk = folk;

				return skin.rampe._x+10;
			}
		}

		return (Math.random()*2-1)*ray;
	}

	public function takeOf(){
		step = 1;
		skin.rampe.gotoAndPlay("takeOf");
		skin.rampe.shuttle.gotoAndPlay("open");

	}


	public function incCapacity(inc){
		capacity += inc;
		skin.rampe.digit.gotoAndStop(capacity+1);
		//skin.rampe.field.text = Std.string(capacity);

	}

	public function launch(){


		shuttleLevel++;
		if(shuttleLevel>5)shuttleLevel = 5;
		var sc = KKApi.cmult( KKApi.const(shuttleLevel), Cs.SCORE_SHUTTLE );

		var p = Geom.getParentCoord(skin.rampe.shuttle, skin);
		var shuttle = new Shuttle();
		shuttle.x = p.x;
		shuttle.y = p.y;
		shuttle.setAngle( skin.rampe.shuttle._rotation*0.0174 );
		shuttle.updatePos();
		Reflect.setField(shuttle.root,"_lvl",shuttleLevel-1);

		Game.me.fxScore( shuttle.x+15, y-52, KKApi.val(sc) );
		KKApi.addScore(sc);


		var shuttle = new Shuttle();
		shuttle.setPlat(this);
		shuttle.wait = 300 + shuttleLevel*200;
		Reflect.setField(shuttle.root,"_lvl",shuttleLevel);

		//


	}

	public function newShuttle(){
		step = 0;
		skin.rampe.gotoAndStop(1);
		Reflect.setField(skin.rampe.shuttle,"_lvl",shuttleLevel);
		skin.rampe.shuttle.gotoAndPlay("close");
		capacity = Cs.SHUTTLE_CAPACITY + shuttleLevel;
		incCapacity(0);

	}


//{
}










