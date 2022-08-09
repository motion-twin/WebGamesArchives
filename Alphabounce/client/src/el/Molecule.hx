package el;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;


typedef Mol = {>Sprite,trg:{x:Float,y:Float}}

class Molecule extends Element{//}


	var flDeath:Bool;
	var type:Int;
	var decal:Float;
	var speed:Float;
	var angle:Float;
	public var ray:Float;
	var yLim:Int;

	var list:Array<Mol>;
	var dm:mt.DepthManager;

	public static var SUM = 0;
	public static var INFOS = [
		{ pb:15, 	mols:[0,1,2]},	// SPEEDER
		{ pb:2,		mols:[0,3,3]},	// BUILDER
		{ pb:5,		mols:[4,5,4]},	// CLEANER
		{ pb:7,		mols:[5,1,5]},	// SPACER
		{ pb:5,		mols:[6,2,1]},	// ARMORER
		{ pb:40,	mols:[2,3,6]},	// FIXER
		{ pb:10,	mols:[2,5,2]},	// LIGHTER
	];

	public static var SPEEDER = 0;
	public static var BUILDER = 1;
	public static var CLEANER = 2;
	public static var SPACER =  3;
	public static var ARMORER = 4;
	public static var FIXER =   5;
	public static var LIGHTER = 6;



	public function new(mc){
		mc = Game.me.dm.empty(Game.DP_MONSTER);
		Game.me.molecules.push(this);
		super(mc);

		ray  = 12;
		decal = Std.random(628);

		speed = 1;
		var a = Math.random()*6.28;
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
		//

		yLim = Std.int(Math.min(Game.me.level.ymax+2,Cs.YMAX-1));
		setSpeed(1);

	}

	// TYPE
	public function setType(n){
		type = n;
		switch(type){
			case CLEANER:
				setSpeed(1.5);
		}

		// SPEED


		// MOLS
		dm = new mt.DepthManager(root);
		list = [];
		var mols = INFOS[type].mols;
		for( n in mols ){
			var sp:Mol = cast new Sprite( dm.attach("mcSpeederBall",0) );
			sp.root.gotoAndStop(n+1);
			newTrg(sp);
			list.push(sp);
		}

	}

	//
	override public function update(){
		super.update();

		switch(type){
			case SPACER:
				for( b in Game.me.balls ){
					var dist = getDist(b);
					var lim = 100;
					if(dist<lim){
						var c = 1-dist/lim;
						var a = b.getAng(this);
						var ba = Math.atan2(b.vy,b.vx);
						var da = Num.hMod(ba-a,3.14);

						b.setAngle( Num.hMod(ba+da*0.1*c,3.14) );

					}

				}

		}

		// LIST
		for( sp in list ){
			var dx = sp.trg.x - sp.x;
			var dy = sp.trg.y - sp.y;
			if( Math.abs(dx)+Math.abs(dy)<0.2 || Std.random(20)==0 )newTrg(sp);
			sp.toward(sp.trg,0.5,1);
		}

		// GLOW
		decal = (decal+35)%628;
		var c = 1+Math.cos(decal*0.01)*0.5;
		root.filters = [];
		Filt.glow(root,2+5*c,1+2*c,0xFFFFFF);

	}

	// TRG
	function newTrg(sp:Mol){
		var  a = Math.random()*6.28;
		var ray = Math.pow(Math.random(),0.5)*6;
		sp.trg = {
			x:Math.cos(a)*ray,
			y:Math.sin(a)*ray
		}
		for( sp2 in list ){
			if(sp!=sp2){
				if(sp.getDist(sp2)<6)return;
			}
		}
		dm.over(sp.root);



	}

	// ON
	public function damage(ball:el.Ball){
		switch(type){
			case SPEEDER:
				ball.setSpeed(ball.speed+2);
			case FIXER:
				ball.setType(Cs.BALL_STANDARD);
			case LIGHTER:
				if(Cs.pi.shopItems[ShopInfo.SUNGLASSES]!=1){
					Game.me.setFlash(1.4,-0.05);
				}else{
					Game.me.setFlash(0.7,-0.07);
				}

		}
		if( ball.fam >= 2 )explode();

		for( sp in list ){
			var a = Math.atan2(sp.y,sp.x);
			ray = 12;
			sp.x=Math.cos(a)*ray;
			sp.y=Math.sin(a)*ray;
			/*
			sp.trg ={
				x:Math.cos(a)*ray,
				y:Math.sin(a)*ray
			}
			sp.toward(sp.trg,0.5,1);
			*/
			sp.updatePos();
		}

	}
	override function onEnterSquare(sx,sy){
		if(flDeath)return;
		//Game.me.monsterGrid[px-sx][py-sy].remove(this);
		//Game.me.monsterGrid[px][py].push(this);

		removeFromGrid(px-sx,py-sy);
		insertInGrid(px,py);

		if(py>=yLim)vy=-Math.abs(vy);

		switch(type){
			case BUILDER:
				if(py+1<yLim){
					var x = px-sx;
					var y = py-sy;
					if( Game.me.grid[x][y] == null ){
						var bl = new Block(x,y,0);
						bl.fxBlink();
					}
				}
		}

	}
	override function onBounce(px,py){

		switch(type){
			case CLEANER:
				for( dx in 0...3 ){
					for( dy in 0...3 ){
						var x = px+dx-1;
						var y = py+dy-1;
						var bl = Game.me.grid[x][y];
						if(bl!=null)bl.explode();
					}
				}
			case ARMORER:
				var bl = Game.me.grid[px][py];
				if(bl.life<5 && bl.type < 5 ){
					bl.setLife(bl.life+1);
					bl.fxBlink();
				}

		}
		super.onBounce(px,py);

	}


	// SETTER
	public function setSpeed(n){
		speed = n;
		var a = Math.atan2(vy,vx);
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
	}
	public function setAngle(a){
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
	}


	// REGISTER
	function insertInGrid(x,y){
		for( dx in 0...3 ){
			for( dy in 0...3 ){
				var nx = x+dx-1;
				var ny = y+dy-1;
				Game.me.monsterGrid[nx][ny].push(this);
			}
		}
	}
	function removeFromGrid(x,y){
		for( dx in 0...3 ){
			for( dy in 0...3 ){
				var nx = x+dx-1;
				var ny = y+dy-1;
				Game.me.monsterGrid[nx][ny].remove(this);
			}
		}



	}


	public function explode(){
		var mc = Game.me.dm.attach("fxMonsterKill",Game.DP_MONSTER);
		var p = getPos();
		mc._x = p.x;
		mc._y = p.y;
		mc._xscale = mc._yscale = 70;
		mc.blendMode = "add";
		kill();
	}
	override public function kill(){
		flDeath = true;
		Game.me.molecules.remove(this);
		removeFromGrid(px,py);
		super.kill();
	}

	// TOOLS
	static public function getRandomMolType(seed){
		if(SUM==0)for(o in INFOS)SUM+=o.pb*10;
		var rnd = seed.random(SUM);
		var sum = 0;
		var id = 0;
		for( o in INFOS ){
			sum+=Std.int(o.pb*10);
			if(sum>rnd)return id;
			id++;
		}
		return null;

	}


//{
}













