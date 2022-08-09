package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;


class Drone extends Event{//}

	//public static var TRG:Array<Block> = [];
	//public static var BONUS:Array<Block> = [];

	var transformSpeed:Float;
	var jumpSpeed:Float;

	var flConverter:Bool;

	var bl:Block;
	var step:Int;
	var c:Float;
	var sx:Float;
	var sy:Float;
	var ex:Float;
	var ey:Float;
	var speed:Float;
	var frame:Float;

	public var sparkTimer:Float;

	public var root:flash.MovieClip;

	public function new(){
		super();

		root = Game.me.dm.attach("mcDrone",Game.DP_DRONE);
		frame = 0;

		transformSpeed = 0.0022;
		jumpSpeed = 6;

		if(Cs.pi.shopItems[ShopInfo.DRONE_PERFO]==1) transformSpeed = 0.005;
		if(Cs.pi.shopItems[ShopInfo.DRONE_SPEED]==1) jumpSpeed = 18;
		if(Cs.pi.gotItem(MissionInfo.MODE_DIF)) transformSpeed *= 0.33;

		flConverter = Cs.pi.shopItems[ShopInfo.DRONE_CONVERTER]==1;


		//trace(BONUS.length);
		//transformSpeed = 0.1;

	}

	override public function update(){
		super.update();

		switch(step){
			case 0: updateJump();
			case 1: updateBlock();
			case 2: updateCancel();
			default: findTrg();
		}


		if(sparkTimer>0){
			sparkTimer -= mt.Timer.tmod;
			var max = Std.int(sparkTimer*0.25);
			var ray = 8;
			for( i in 0...max ){
				var p = new Phys( Game.me.dm.attach("partSparkTwinkle",Game.DP_PARTS) );
				p.x = root._x + (Math.random()*2-1)*ray;
				p.y = root._y + (Math.random()*2-1)*ray;
				p.fadeType = 0;
				p.timer = 10+Math.random()*10;
				p.root.gotoAndPlay(1+Std.random(p.root._totalframes));
			}


			if(sparkTimer<=0)sparkTimer = null;
		}

	}

	function followPath(){
		// OLD POS
		var ox = root._x;
		var oy = root._y;

		// MOVE
		c = Math.min(c+speed*mt.Timer.tmod,1);
		root._x = sx*(1-c) + ex*c;
		root._y = sy*(1-c) + ey*c - Math.sin(c*3.14)*(2/speed);

		// QUEUE
		var mc = Game.me.dm.attach("mcQueueDrone",Game.DP_PARTS2);
		mc._x = ox;
		mc._y = oy;
		var dx = root._x-ox;
		var dy = root._y-oy;
		mc._rotation = Math.atan2(dy,dx)/0.0174;
		mc._xscale = Math.sqrt(dx*dx+dy*dy);

		// ROTATION
		root._rotation = Math.atan2(dy,dx)/0.0174;

	}
	function setTrg(x,y){
		sx = root._x;
		sy = root._y;
		ex = x;
		ey = y;

		var dx = ex-sx;
		var dy = ey-sy;
		speed = jumpSpeed / Math.sqrt(dx*dx+dy*dy);
	}

	// JUMP
	public function findTrg(){

		bl = getBlock();

		if(bl==null){
			initCancel();
			return;
		}


		c = 0;
		setTrg( Cs.getX(bl.x+Math.random()), Cs.getY(bl.y+Math.random()) );


		step = 0;

		root.stop();
		root.filters = [];

	}
	function updateJump(){


		followPath();
		// CHECK END JUMP
		if(c==1)initBlock();


	}

	public static function getBlock(){
		var bl = getRandomSentiBlock();
		if(bl==null && Cs.pi.shopItems[ShopInfo.DRONE_COLLECTOR]==1 ) bl = getRandomBonusBlock();
		/*
		if( TRG.length==null && flCollector )bl = getRandomBonusBlock();
		var bl = getRandomTrgBlock();
		var flCollector = Cs.pi.shopItems[ShopInfo.DRONE_COLLECTOR]==1;
		*/

		return bl;
	}
	/*
	public static function getRandomTrgBlock(){
		if(TRG.length==0)return null;
		return TRG[Std.random(TRG.length)];
	}
	*/
	public static function getRandomBonusBlock(){
		var list = [];
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var bl = Game.me.grid[x][y];
				if(Block.isBonus(bl.type))list.push(bl);
			}
		}
		return list[Std.random(list.length)];
	}
	public static function getRandomSentiBlock(){
		var list = [];
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var bl = Game.me.grid[x][y];
				if(Block.isSentinelle(bl.type))list.push(bl);
			}
		}
		return list[Std.random(list.length)];
	}

	// BLOCK
	function initBlock(){
		step = 1;
		findBlockTrg();

		var fl = new flash.filters.DropShadowFilter();
		fl.blurX = 0;
		fl.blurY = 0;
		fl.distance = 2;
		fl.color = 0;
		fl.alpha = 0.5;

		root.filters = [fl];

	}
	function updateBlock(){

		// MOVE
		var c = 0.1;
		var dx = ex-root._x;
		var dy = ey-root._y;
		root._x += dx*c;
		root._y += dy*c;

		var move = Math.abs(dx)+Math.abs(dy);
		if( Std.random(Std.int(14/mt.Timer.tmod))==0 || move<1 ){
			findBlockTrg();
		}


		// ROT
		root._rotation = Math.atan2(dy,dx)/0.0174;

		// FRAME
		frame = (frame+move*0.25)%12;
		root.gotoAndStop(Std.int(frame)+1);

		// SPARK
		if( mt.Timer.tmod>1.5 && Std.random(3) == 0 ){
			var p = new fx.Spark( Game.me.dm.attach("partLine",Game.DP_PARTS) );
			p.x = root._x;
			p.y = root._y;
			p.vx = (Math.random()*2-1)*2;
			p.vy = -Math.random()*1.5;
			p.weight = 0.1+Math.random()*0.1;
			p.timer = 10+Math.random()*10;
			p.coef = 2;
			p.root._yscale = 150 ;
			Filt.glow(p.root,10,3,0xFFFF00);
			p.root.blendMode = "add";

		}


		// TRANSFORM
		var become = 0;
		if( flConverter ) become = Block.BONUS;
		if( bl.type != Block.LURE ) bl.incTransform(transformSpeed*mt.Timer.tmod, become);
		if( bl.transform == 1 || bl.flDeath || ( !Block.isSentinelle(bl.type) && !Block.isBonus(bl.type) )  ){
			bl.transform = 0;
			for( drone in Game.me.pad.drones ){
				if(drone.bl==bl)drone.findTrg();
			}



		}





	}
	function findBlockTrg(){
		ex = Cs.getX(bl.x+Math.random());
		ey = Cs.getY(bl.y+Math.random());




	}

	// CANCEL
	function initCancel(){
		step = 2;
		c = 0;
		jumpSpeed = 16;
		setTrg(Game.me.pad.x,Game.me.pad.y);
	}
	function updateCancel(){

		ex = Game.me.pad.x;
		ey = Game.me.pad.y;

		followPath();
		if(c==1){
			Game.me.pad.drones.remove(this);
			kill();
		}

	}

	// DIE
	public function explode(){
		var mc = Game.me.dm.attach("partExplode",Game.DP_PARTS);
		mc._x = root._x - Cs.BW*0.5;
		mc._y = root._y - Cs.BH*0.5;
		Col.setColor( mc, 0xFCF0B0, -220 );

		var mc =  Game.me.dm.attach("fxDroneMiniExplosion",Game.DP_PARTS);
		mc._x = root._x;
		mc._y = root._y;
		mc._xscale = mc._yscale = 100+Math.random()*100;
		mc.gotoAndPlay(Std.random(3)+1);
		mc.blendMode = "add";

		kill();
	}
	override public function kill(){

		root.removeMovieClip();
		super.kill();
	}



//{
}













