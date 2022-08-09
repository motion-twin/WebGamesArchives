import mt.bumdum.Lib;
import mt.bumdum.Phys;


enum State {
	Moving;
	Convert;
	Branch;
}


class Element extends Phys {//}


	var flHereWeGo:Bool;

	var action:Void->Void;
	var aura:Float;
	public var state:State;

	public var size:Float;

	public var speedBonus:Float;
	var ray:Float;
	var px:Int;
	var py:Int;

	//public var boum:{x:Float,y:Float};

	public var col:Int;
	var lvl:Int;
	var coef:Float;
	var boost:Float;

	public var parent:Element;
	public var branch:flash.MovieClip;


	public function new(){
		Game.me.elements.push(this);
		var mc = Game.me.dm.attach("mcElement",Game.DP_ELEMENTS);
		super(mc);
		ray = 4;
		aura = 0;
		x = (Math.random()*Cs.mcw-4*ray);
		y = (Math.random()*Cs.mch-4*ray);
		updatePos();
		root.stop();
		root.smc.gotoAndPlay(Std.random(2)+1);


		vr = (Math.random()*2-1)*20;

	}

	override function update(){

		super.update();

		action();

	}

	// MOVE
	public function initMove(a,speed){
		//speed = 0.5+Math.random()*3;
		state = Moving;
		action = updateMove;
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
		flHereWeGo = true;


		/*
		var recalCoef = 5;
		while(true){
			x -= vx*recalCoef;
			y -= vy*recalCoef;
			if( Cs.isOut(x,y,-ray) )break;
		}
		boost = Math.random()*20;
		*/



	}
	public function updateMove(){

		checkBounds();
		updateGridPos();

	}
	public function checkBounds(){

		// NEIGHBOOR;

		if(Cs.CEL_COL){
			for( el in Game.me.grid[px][py] ){
				if(el!=this){
					var dx = el.x - x;
					var dy = el.y - y;
					var dist = ray*2 - Math.sqrt(dx*dx+dy*dy);
					if( dist > 0 ){
						var a = Math.atan2(dy,dx);
						var rx = Math.cos(a)*dist*0.5;
						var ry = Math.sin(a)*dist*0.5;
						el.x += rx;
						el.y += ry;
						x -= rx;
						y -= ry;

					}

				}
			}
		}


		// BORD
		if( x < ray || x > Cs.mcw-ray ){
			vx *= -1 ;
			x = Num.mm(ray,x,Cs.mcw-ray);
		}
		if( y < ray || y > Cs.mch-ray ){
			vy *= -1 ;
			y = Num.mm(ray,y,Cs.mch-ray);
		}
	}

	// CONVERT
	public function convert(c:Int){

		px = Cs.getPX(x);
		py = Cs.getPX(y);
		vx = 0;
		vy = 0;
		size = 0;
		state = Convert;
		action = updateConvert;
		col = c;
		coef = 0;
		lvl = 0;
		//root._xscale = 100;
		root.gotoAndStop(col+11);

		//root._xscale = root._yscale = 0;


		if( col>0 && Game.me.lvl>5 ){
			speedBonus = 0.02*(Game.me.lvl-5);
		}

		/*
		// FX
		var mc = Game.me.dm.attach("mcOnde",Game.DP_FX);
		mc._x = x;
		mc._y = y;
		*/


	}
	public function updateConvert(){
		var spc = Cs.CEL_SPEED;
		if( speedBonus != null )spc += speedBonus;
		if( Game.FL_TURBO && col==0 )spc = 1;
		coef = Math.min(coef+spc*mt.Timer.tmod,1);
		aura =  Cs.CEL_AURA*coef;

		if(coef==1){
			action = seek;

		}else{
			seek();
		}
	}

	// SEEK
	public function seek(){
		var list = Game.me.grid[px][py];

		for( el in list ){

			if( el != this && el.state == Moving ){
				var dx = el.x-x;
				var dy = el.y-y;
				var dist = Math.sqrt(dx*dx+dy*dy);
				if( dist < aura ){
					el.convert(col);

					// BRANCH
					var layer = Game.me.hunters[col].layer;
					var mc = layer.dm.attach("mcBranch",0);
					mc._x = x;
					mc._y = y;
					mc._xscale = dist;
					mc._rotation = Math.atan2(dy,dx)/0.0174;

					Reflect.setField( mc,"_endAnim",callback(layer.draw,mc) );



					//Reflect.setField( mc,"_endAnim",function(){haxe.Log.trace("!!!!!");} );

					//mc.gotoAndStop(Std.random(mc._totalframes)+1);

					// LINK
					el.parent = this;
					el.branch = mc;
					el.lvl = lvl+1;
					grow(1);

					//
					Game.me.newInflux(el);
					Game.me.influxMax++;

					// SCORE
					if(col==0){
						var sc = KKApi.cadd( Cs.SCORE_CEL_BASE, KKApi.cmult(Cs.SCORE_CEL_MULTI,KKApi.const(el.lvl))  );
						KKApi.addScore(sc);
						Game.me.fxScore(el.x,el.y,KKApi.val(sc));
					}



				}
			}
		}
	}
	public function grow(inc){
		parent.grow(inc);
		size += inc;
		//branch._yscale = 100+size*2;
		//root._xscale = root._yscale = size*10;

	}

	// BLAST
	public function vanish(){
		action = updateVanish;
		coef = 0;
	}
	public function updateVanish(){
		if(size>0)return;
		coef = Math.min(coef+0.25*mt.Timer.tmod,1);

		root._xscale = root._yscale = (1-coef)*100;
		branch._yscale = (1-coef)*100;

		if(coef==1){
			parent.grow(-1);
			kill();
		}


	}


	// GRID
	function updateGridPos(){

		var npx = Cs.getPX(x);
		var npy = Cs.getPY(y);
		if( npx!=px || npy!=py ){
			removeFromGrid();
			px = npx;
			py = npy;
			insertInGrid();
		}
	}
	function insertInGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				Game.me.grid[gx][gy].push(this);
			}
		}
	}
	function removeFromGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				Game.me.grid[gx][gy].remove(this);
			}
		}
	}


	// KILL
	override function kill(){
		removeFromGrid();
		Game.me.elements.remove(this);
		super.kill();
	}


//{
}






































