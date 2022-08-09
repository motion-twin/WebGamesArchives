import KKApi;
import mt.bumdum.Lib;
import Protocol;

typedef Move = {
	x:Int,
	y:Int,
	fire:Bool
}

enum State {
	Birth;
	Play;
	Death;
}

enum Control {
	Keyboard;
	Replay;
	Follow;
}

class Hero extends Phys{//}

	static var SPEED = 4.5;
	static var INCLINE_MAX = 5;

	var flStand:Bool;

	var cooldown:Int;
	public var id:Int;
	var timer:Int;
	var incline:Int;
	var smokeLoop:Float;

	var state:State;

	var control:Control;
	var destiny:Array<Move>;
	var oldPos:Array<{x:Float,y:Float}>;

	var decal:Move;
	var move:Move;

	public function new(id){
		this.id = id;

		Game.me.heros.push(this);
		super(Game.me.dm.attach("mcHero",Game.DP_HERO));
		root.gotoAndStop(id+1);
		root._xscale = root._yscale = 90;
		root.smc.gotoAndStop(6);

		//Filt.glow(root,2,4,0);

		ray = 8;
		incline = 0;
		smokeLoop = 0;


		control = Keyboard;
		destiny = [];

	}


	//
	public function update(){

		switch(state){
			case Birth:	updateBirth();
			case Play:	updatePlay();
			case Death:
		}
		super.update();
		fxQueue();
	}

	// BIRTH
	public function birth(){
		state = Birth;
		timer = 18;
		x = Cs.mcw*0.5 + (id*2-1)*30;
		y = Cs.mch+10 ;
		cooldown = 0;
		root._visible = true;
		oldPos = [];
		updatePos();

		//
		setLabel(0xFFFFFF,["Wallis","Futuna"][id],60);
		mcLabel.sy = 1;
		mcLabel.dec = 14;


	}
	public function updateBirth(){
		y -= Math.min(6,timer*0.5);
		if( timer-- < 0 )initPlay();
	}

	// PLAY
	public function initPlay(){
		state = Play;

	}
	public function updatePlay(){
		if(cooldown>0)cooldown--;
		fly();
		recal();
		updateSkin();
		checkCols();
		//if( flash.Key.isDown( flash.Key.ENTER ) ) death();


	}
	public function updateSkin(){
		var lim = INCLINE_MAX;
		incline = Std.int( Num.mm(-lim,incline-move.x,lim) );
		if( move.x==0 && incline!=0 )incline += incline>0?-1:1;
		root.smc.gotoAndStop( lim+1+incline );
	}

	// COLS
	function checkCols(){
		var bx = Cs.getPX(x);
		var by = Cs.getPY(y);


		for( nx in 0...3 ){
			for( ny in 0...3 ){
				var px = bx+nx-1;
				var py = by+ny-1;
				// SHOTS
				var list = Game.me.sgrid[px][py];
				for( shot in list ){
					var dx = shot.x - x;
					var dy = shot.y - y;
					var dist = Math.sqrt(dx*dx+dy*dy);
					if( dist < ray+shot.ray ){
						if( Game.me.robertId == null ){
							Game.me.robertId = shot.owner;
							Game.me.shotId = shot.bsid;
						}
						shot.kill();
						death();
					}
				}

				// BADS
				var list = Game.me.bgrid[px][py];
				for( b in list ){
					var dx = b.x - x;
					var dy = (b.y - y)/b.scy;
					var dist = Math.sqrt(dx*dx+dy*dy);
					if( dist < ray+b.ray ){
						if( Game.me.robertId == null )Game.me.robertId = b.rid;
						b.explode(true);
						death();
					}
				}
			}
		}

	}
	function recal(){
		if( x<ray || x>Cs.mcw-ray ) x = Num.mm( ray, x, Cs.mcw-ray );
		if( y<ray || y>Cs.mch-ray ) y = Num.mm( ray, y, Cs.mch-ray );

	}

	// ACTION
	public function fly(){
		// BUILD MOVE
		move = { x:0, y:0, fire:false };
		switch(control){
			case Keyboard :
				if( flash.Key.isDown( flash.Key.LEFT ) )	move.x -= 1;
				if( flash.Key.isDown( flash.Key.RIGHT ) )	move.x += 1;
				if( flash.Key.isDown( flash.Key.UP ) )		move.y -= 1;
				if( flash.Key.isDown( flash.Key.DOWN ) )	move.y += 1;
				if( flash.Key.isDown( flash.Key.SPACE ) )	move.fire = true;
				if( flash.Key.isDown( flash.Key.ENTER ) )	move.fire = true;
				if( flash.Key.isDown( flash.Key.CONTROL ) )	move.fire = true;
				if( !Game.me.flTwinMode ) destiny.push(move);

			case Replay :
				move = destiny.shift();
				if( destiny.length == 0 ){
					control = Follow;
				}

			case Follow :
				var h = getTwin();

				if( h.move.x !=0 || h.move.y!=0 )decal = h.move;
				var coef = 0.2;
				if(decal!=null){

					var wpx = h.x - decal.x*ray*2;
					var wpy = h.y - decal.y*ray*2;

					var dx = wpx - x;
					var dy = wpy - y;
					x += dx*coef;
					y += dy*coef;
				}

				move.fire = true;

				//move = h.destiny[h.destiny.length-10];
				//trace(h.destiny[h.destiny.length-10]);


				/*
				var dx = h.x-x;
				var dy = h.y-y;
				if( Math.abs(dx) > ray*2 ) move.x = Std.int( dx/Math.abs(dx) );
				if( Math.abs(dy) > ray*2 ) move.y = Std.int( dy/Math.abs(dy) );
				*/

		}

		var coef =1.0;

		var fls = move.x==0 && move.y==0;
		if( flStand && !fls )coef = 0.5;
		flStand = fls;


		//
		x += move.x*SPEED*coef;
		y += move.y*SPEED*coef;

		if( move.fire )fire();


	}
	public function fire(){
		if(cooldown>0)return;

		cooldown = 4;

		switch(id){
			case 0:
				for( i in 0...2 ){
					var sens = i*2-1;
					var shot = new HeroShot(Game.me.dm.attach("mcHeroShot",Game.DP_SHOTS));
					var a =  - 1.57 + sens*0.2;
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var sp = 20;
					shot.x = x + ca*ray + sens*10;
					shot.y = y + sa*ray - 5;
					shot.vx = ca*sp;
					shot.vy = sa*sp;
					shot.root._xscale = shot.root._yscale = 70;
					shot.root._rotation = a/0.0174 + 90;
					shot.updatePos();
				}

			case 1:
				for( i in 0...2 ){
					var sens = i*2-1;
					var shot = new HeroShot(Game.me.dm.attach("mcHeroShot",Game.DP_SHOTS));
					var a =  - 1.57;
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var sp = 20;
					shot.x = x + ca*ray + sens*5;
					shot.y = y + sa*ray - 5;
					shot.vx = ca*sp;
					shot.vy = sa*sp;
					shot.root._xscale = shot.root._yscale = 70;
					shot.root._rotation = a/0.0174 + 90;
					shot.updatePos();
				}


		}



	}

	//
	public function death(){
		if(!Game.me.isPlaying())return;
		mcLabel.removeMovieClip();
		root._visible = false;
		if( !Game.me.flTwinMode ){
			control = Replay;
			Game.me.initBomb(this,Reverse);
			state = Death;
		}else{
			if( control == Keyboard  ){
				if( Game.me.heros.length>1 ){
					var h = getTwin();
					h.control = Keyboard;
					Game.me.initBomb(this,Transfert);
				}else{
					Game.me.initGameOver();
				}
			}else{
					Game.me.initBomb(this,Standard);
			}
			kill();
		}

		fxExplode();

	}
	public function kill(){
		Game.me.heros.remove(this);
		super.kill();
	}

	// TOOLS
	public function getTwin(){
		for( h in Game.me.heros )if(h!=this)return h;
		return null;
	}

	// FX
	public function fxExplode(){
		for( i in 0...10 ){
			var p = new mt.bumdum.Phys( Game.me.dm.attach("mcExplosion",Game.DP_FRONT_FX) );
			p.x = x + (Math.random()*2-1)*6*i;
			p.y = y + (Math.random()*2-1)*6*i;
			p.root._rotation = Math.random()*360;

			p.vx = (Math.random()*2-1)*3;

			Filt.blur(p.root,12,12);
			p.updatePos();
			p.sleep = i*0.5;
			p.root.stop();
			p.setScale(100+Math.random()*100);
			p.root._visible = false;

			//p.root.blendMode = "lighten";


		}
	}
	public function fxQueue(){
		// return;




		var speed = Scroller.HIGHSPEED;
		var length = 800;

		var dist = 0.0;
		var ec = 6;
		var size = 35;
		var my = 10;
		var max = 2;

		if(id==0){
			ec = 0;
			size = 50;
			my = 8;
			max = 1;
		}


		for( i in 0...max ){

			var ox =  oldPos[i].x ;
			var oy =  oldPos[i].y + speed ;
			if(oldPos[i]==null){
				ox = x;
				oy = y;
			}

			var nx = x + (i*2-1)*( ec - Math.abs(incline)*0.5 ) + incline*(ec/6);
			var ny = y + my;

			var dx = ox-nx;
			var dy = oy-ny;
			dist = Math.sqrt(dx*dx+dy*dy);

			/*
			var p = new Part( Game.me.dm.attach("mcQueueSmoke",Game.DP_UNDER_FX) );
			p.x = nx;
			p.y = ny;
			p.root._rotation = Math.atan2(dy,dx)/0.0174;
			var mask:flash.MovieClip = cast (p.root).mask;
			mask._xscale = dist;
			p.root.smc._x = (smokeLoop+i*length*0.5)%length ;
			p.root._yscale = size;
			p.updatePos();
			p.vy = speed;
			p.root.stop();
			p.timer = 8;
			p.fadeLimit = 8;
			p.flGrow = true;
			*/
			var p = new Part( Game.me.dm.attach("mcQueueHero",Game.DP_UNDER_FX) );
			p.x = nx;
			p.y = ny;
			p.root._rotation = Math.atan2(dy,dx)/0.0174;
			p.root._xscale = dist;
			p.root.smc._x = (smokeLoop+i*length*0.5)%length ;
			p.root._yscale = size;
			p.updatePos();
			p.vy = speed;
			p.timer = 10;
			p.fadeLimit = 0;
			oldPos[i] = {x:nx,y:ny};

		}


		smokeLoop = (smokeLoop+dist)%length;


	}


	// TOOLS


//{
}







