import mt.bumdum.Phys;
import mt.bumdum.Lib;

class Bloc {//}

	public static var OPTIONS = [false,false];

	public static var ANIMS:Array<Bloc> = [];

	
	public var option:Int;
	var ref:Int;
	public var gid:Int;
	
	var tx:Float;
	var ty:Float;
	
	public var x:Int;
	public var y:Int;
	public var id:Int;
	public var root:flash.MovieClip;
	
	public var bm:BlocManager;
	
	public var dm:mt.DepthManager;
	
	public function new(px,py,col,bm){
		setManager(bm);
		x = px;
		y = py;
		id = col;
		
		
		var opt = Std.random(OPTIONS.length);
		var starProba = Std.int(Game.FREQ_OPTIONS/Math.pow(Game.me.colorMax,2));
		if(!Bloc.OPTIONS[opt] && Std.random(starProba) == 0 && Game.me.step!=null ){
			Bloc.OPTIONS[opt] = true;
			option = opt;
		}
		display(px,py);
	
	}
	
	public static function goto(b:Bloc,x,y){
		if(b.tx==null)ANIMS.push(b);
		b.tx = x;
		b.ty = y;
	}
	public static function updateAnims(){
		var list = ANIMS.copy();
		for( b in list ){
			//var tx = Game.getX(b.x);
			//var ty = Game.getY(b.y);
			var dx = b.tx - b.root._x;
			var dy = b.ty - b.root._y;
			b.root._x += dx*0.5*mt.Timer.tmod;
			b.root._y += dy*0.5*mt.Timer.tmod;
			
			if( Math.abs(dx)+Math.abs(dy) < 2 ){
				b.root._x = b.tx;
				b.root._y = b.ty;
				b.tx = null;
				b.ty = null;
				ANIMS.remove(b);
			}
		}
	}
	
	//
	public function setManager(bbm){
		bm = bbm;
		bm.list.push(this);	
	}
	
	//
	public function display(px,py){
		root = bm.dm.attach("mcBloc",0);
		root.gotoAndStop(id+1);	
		dm = new mt.DepthManager(root);
		root._xscale = root._yscale = Game.SIZE/20 * 100;
		setPos(px,py);
		if(option!=null){
			var mc = dm.attach("mcStar",0);
			mc.gotoAndStop(option+1);
			mc.blendMode = "add";
		}
	}
	public function setPos(px,py,?flAnim){
		bm.removeFromGrid(this);
		x = px;
		y = py;
		bm.insertInGrid(this);
		if(flAnim==null){
			root._x = Game.getX(x);
			root._y = Game.getY(y);
		}else{
			goto(this,Game.getX(x),Game.getX(y));
		}
	}

	//
	public function explode(){
		// OPTIONS
		/*
		switch(option){
			case 0:	Game.me.activeStar(id);
			case 1:	Game.me.activeShaker();
		}
		*/
		// PART
		var max = 16;
		for( i in 0...max){
			var a = (i/max)*6.28 + (Math.random()*2-1)*0.2;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = 0.5+Math.random()*3;
			var ray = 6;
			var p = new Phys(Game.me.dm.attach("partSquare",Game.DP_PARTS));
			p.x = Game.getX(x+Game.me.stamp.x) + ca*ray ;
			p.y = Game.getY(y+Game.me.stamp.y) + sa*ray ;
			p.vx += ca*sp; 
			p.vy += sa*sp;
			p.weight = 0.1+Math.random()*0.1;
			p.timer = 10+Math.random()*10;
			p.fadeType = 0;
		}
		KKApi.addScore( Game.SCORE_BURST[id] );
		Game.me.stats._b[id]++;

		//
		kill();
	}
	public function fall(){
		var p = new Phys(Game.me.dm.attach("mcBloc",Game.DP_PARTS));
		p.x = Game.getX(x+Game.me.stamp.x);
		p.y = Game.getY(y+Game.me.stamp.y);
		p.vx = (Math.random()*2-1)*2;
		p.vy = 0;
		p.weight = 0.1+Math.random()*0.2;
		p.vr = (Math.random()*2-1)*5;
		p.timer = 20+Math.random()*10;
		p.fadeType = 0;
		p.root.gotoAndStop(root._currentframe);
		p.updatePos();
		p.setScale(Game.SIZE/20*100);
		Filt.glow(p.root);
		//
		kill();
		KKApi.addScore(Game.SCORE_FALL);
		Game.me.stats._f++;
		//
		return p;
	}
	public function discard(){
		if(tx!=null){
			ANIMS.remove(this);
			tx = null;
			ty = null;			
		}
		bm.list.remove(this);
		bm.removeFromGrid(this);	
		root.removeMovieClip();
	}
	public function kill(){
		if(option!=null)OPTIONS[option] = false;
		discard();
	}


//{
}