import mt.bumdum.Lib;

class Folk extends Element{//}

	var flDrop:Bool;
	public var flBounce:Bool;

	var walkSpeed:Float ;

	public var step:Int;
	var sens:Int;
	var wait:Int;
	public var type:Int;
	public var color:Int;
	public var coef:Float;
	public var ptx:Float;
	public var frame:Int;
	public var plat:Plat;

	public var jump:Tween;


	public function new(){
		super(Game.me.dm.attach("mcFolk",Game.DP_FOLK));
		Game.me.folks.push(this);
		sens = 1;
		x = Math.random()*Cs.lw;
		walkSpeed = 0.5+Math.random()*0.5;
		land();

		//color = Col.objToCol(Col.getRainbow());

		type = 0;
		while( Std.random(Cs.BONUS_RARITY)==0 && type<3 )type++;
		color = [0xFFFFFF,0x66FF00,0x8888FF,0xFF44CC][type];

		applySkin(root);
		Reflect.setField(root,"_colorMe",colorMe);


	}



	override function update(){
		switch(step){
			case 0: updateFly();
			case 1: updateGround();
			case 2: // ride
			case 3: updateJump();
			case 4: updatePlat();

		}

		super.update();

	}

	// GROUND
	public function land(){
		flDrop = false;
		step = 1;
		wait = 0;
		vx = 0;
		vy = 0;
		weight = 0;
		root.gotoAndStop(1);
		updateGround();
		frame = 0;


	}
	public function updateGround(){

		if( wait-- < 0 ){
			wait = Std.random(500);
			setSens(Std.random(3)-1);
			if(sens==0){
				var a = ["_face","_hello","_seat"];
				//root.gotoAndStop( a[Std.random(a.length)] );
				if(Std.random(3)==0)	root.gotoAndPlay( "_jump" );
				else 			root.gotoAndStop( a[Std.random(a.length)] );
				applySkin(root);

			}

		}

		var lim = 50;

			var dx = Game.me.getHeroDX(x);
			if( Math.abs(dx) < lim && Game.me.hero.isFree() ){
				var ty = Game.me.hero.y;
				var ady = Math.abs(ty-y);
				if( ady < lim ){
					fly();
					var c = dx /lim;
					vx = c*2;
					var jp = Math.pow(ady,0.22);
					vy = -( jp + Math.random()*0.4 + Math.abs(c)*0.5 ) ;
					if( Std.random(50)==0 )	root.gotoAndPlay("_jump2");
					else			root.gotoAndStop("jump");
					return;
				}
			}



		if( sens != 0 ){
			x += sens*walkSpeed;
			animWalk();
		}

		y = Game.me.getGY(x);




	}

	// FLY
	public function fly(){
		root.gotoAndStop("jump");

		weight = 0.1;
		step = 0;

	}
	function updateFly(){

		//root._rotation *= 0.9;
		setSens(vx>0?1:-1);

		var dx = Game.me.hero.x - x;
		var dy = Game.me.hero.y - (y-6);

		if( !flDrop && Math.abs(dx)+Math.abs(dy)*0.6 < 15 &&  Game.me.hero.isFree() ){
			ride();
			return;
		}

		var gy = Game.me.getGY(x);
		if( y > gy ){
			if(flBounce){
				vy*=-0.5;
				y = gy;
				if(Std.random(2)==0)flBounce = false;
				return;
			}
			land();
			return;
		}


	}

	// RIDE
	public function ride(){
		Game.me.hero.board(this);
		vx = 0;
		vy = 0;
		weight = 0;
		y = 10000;
		root._visible = false;
		step = 2;
	}
	public function unride(){

		var h = Game.me.hero;
		flDrop  = true;
		var coef = 0.3+Math.random()*0.4;
		vx = h.vx*coef;
		vy = h.vy*coef;
		x = h.x;
		y = h.y;
		//root._rotation = h.root._rotation;
		root._visible = true;
		fly();
//
	}

	// JUMPTO
	public function jumpTo(pl){
		step  = 3;
		plat = pl;
		var ray = 15;
		var xMin = x-ray;
		var xMax = x+ray;
		if( xMin < plat.x-plat.ray ) xMin = plat.x-plat.ray;
		if( xMax > plat.x+plat.ray ) xMax=  plat.x+plat.ray;

		jump = new Tween();
		jump.sx = x;
		jump.sy = y;
		jump.ex = xMin + Math.random()*(xMax-xMin);
		jump.ey = plat.y;

		vx = 0;
		vy = 0;
		weight = 0;

		coef = 0;

		root.gotoAndStop("jump");


	}
	function updateJump(){
		coef = Math.min(coef+0.05,1);
		var p = jump.getPos(coef);
		x = p.x;
		y = p.y - Math.sin(coef*3.14)*16;
		if( coef == 1 ){
			root.gotoAndStop(1);
			step = 4;

		}


	}

	// UPDATE PLAT
	public function updatePlat(){
		if(ptx==null)ptx = plat.getWaypoint(this);
		var dx = ptx - (x-plat.x);
		setSens(dx>0?1:-1);
		x += walkSpeed*sens;
		animWalk();
		if( Math.abs(dx) < walkSpeed ){
			ptx = null;
		}



	}

	//
	override function kill(){
		super.kill();
		Game.me.folks.remove(this);

	}

	//
	public function setSens(n){
		sens = n;
		if(sens!=0)root._xscale = n*100;
	}

	//
	function animWalk(){
		frame = (frame+1)%16;
		root.gotoAndStop(frame+1);
	}
	public function applySkin(mc){
		Col.setColor(mc.smc,color,-340);
	}
	public function colorMe(mc){
		Col.setColor(mc,color);

	}

//{
}








































