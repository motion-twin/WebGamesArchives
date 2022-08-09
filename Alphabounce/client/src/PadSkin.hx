import mt.bumdum.Phys;
import mt.bumdum.Lib;

class PadSkin extends Phys{//}

	public static var SIDE = 12;
	public static var HEIGHT = 10;


	public var ray:Float;
	public var type:Int;

	public var skinId:Int;

	var dm:mt.DepthManager;
	public var skin:{>flash.MovieClip,side0:flash.MovieClip,side1:flash.MovieClip,mid:{>flash.MovieClip,bar:flash.MovieClip}};
	var mcReactor:flash.MovieClip;



	public function new(mc){
		super(mc);
		skin = cast root;
		dm = new mt.DepthManager(root);
		skinId = 0;

		if( Cs.pi.gotItem(MissionInfo.MEDAL) )skinId = 1;

	}



	public function setType(n:Int){
		type = n;
		skin.mid.gotoAndStop(type+1);
		skin.side0.gotoAndStop(type+1);
		skin.side1.gotoAndStop(type+1);

		skin.mid.smc.gotoAndStop(skinId+1);
		skin.side0.smc.gotoAndStop(skinId+1);
		skin.side1.smc.gotoAndStop(skinId+1);

	}
	public function setRay(r){
		ray = r;
		var w = (r-SIDE)+0.2;
		skin.mid._xscale = w*2;
		skin.mid._x = -w;
		skin.side0._x = -r;
		skin.side1._x = r;
	}

	public function setReactor(fl){
		if(fl){
			mcReactor = dm.attach("mcReactor",0);
			//mcReactor.smc._xscale = mcReactor.smc._yscale = 0;
			mcReactor.smc._visible = true;
			mcReactor._y = 10.5;
		}else{
			mcReactor.removeMovieClip();
			mcReactor = null;

		}
	}

	public function explode(bmc){

		var dm = new mt.DepthManager(bmc);
		var sp = new mt.bumdum.Phys(bmc);
		sp.x = x;
		sp.y = y;
		sp.updatePos();
		sp.timer = 100;
		sp.root._rotation = root._rotation;



		var max = Std.int(2*ray/Cs.BW);
		var inc = ((2*ray)%max)/max;

		for( i in 0...max ){
			var mc = dm.attach("partExplode",0);
			var px = -ray+i*(Cs.BW+inc);
			mc._x = px;
			mc._y = 0;
			Col.setColor( mc, 0xFCF0B0, -220 );
			for( n in 0... 10 ){
				var p = new Phys(dm.attach("mcPart",0));
				p.root.gotoAndStop(Std.random(p.root._totalframes));
				p.x = px+Math.random()*(Cs.BW+inc);
				p.y = Math.random()*12;
				p.vy = 0.75- Math.random()*1.5;
				p.vx = (p.x/ray)*3;
				Col.setColor( p.root, 0xFCF0B0, -(200+Std.random(50)) );
				//p.weight = 0.1+Math.random()*0.15;
				p.timer = 10+Math.random()*20;
				p.fadeType = 0;
				p.setScale(50+Math.random()*70);
				p.root._rotation = Std.random(360);
				p.updatePos();
			}
		}


		var mc = dm.attach("fxPadExplosion",0);
		mc._y = HEIGHT*0.5;
		mc.smc.smc._xscale = ray*2;
		mc.smc.smc.blendMode = "add";

		for( i in 0...4 ){
			var mc = dm.attach("fxPadMiniExplosion",Game.DP_PARTS);
			mc._x = (Math.random()*2-1)*ray*0.8;
			mc._y = HEIGHT*0.5+ (Math.random()*2-1)*2;
			mc._xscale = mc._yscale = 100+Math.random()*100;
			mc.gotoAndPlay(Std.random(4)+1);
			mc.blendMode = "add";
		}


		//
		kill();

	}



//{
}
























