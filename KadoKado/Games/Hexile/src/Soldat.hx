import Game;
import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;



class Soldat extends Phys {//}


	public var flSuicide:Bool;
	public var flDec:Bool;
	public var id:Int;
	public var team:Int;
	public var step:Int;

	var hex:Socle;

	public var jh:Float;
	var coef:Float;

	var dx:Float;
	var dy:Float;

	var sx:Float;
	var sy:Float;
	var ex:Float;
	var ey:Float;

	var wait:Float;
	var ty:Float;
	var speed:Float;

	var shade:flash.MovieClip;



	public function new(team){
		var mc = Game.me.dm.attach( "mcSoldat", Game.DP_SOLDAT );
		super(mc);

		Game.me.soldats.push(this);
		setTeam(team);

		jh = 80;

		// initStartPos();
		// updatePos();

	}
	public function setTeam(n){
		this.team = n;
		root.gotoAndStop(team+1);
		root.smc.stop();
	}


	override function update(){


		switch( step ){
			case 0: updatePlay();
			case 1: updateJump();
			case 2: updateLand();
			case 3: updateBack();

		}

		super.update();

	}

	// PLAY
	public function initStartPos(){
		step = 0;
		var ray = 9.0;
		while(true){
			ray -= 0.1;
			var flBreak = true;
			var cx = (Math.random()*2-1);
			x = Cs.mcw*0.5 + cx*(10+id*5);
			ty = Cs.mch - ( 12+Math.random()*(10+(1-Math.abs(cx))*20) );
			for( sol in Game.me.soldats ){
				var dx = sol.x-x;
				var dy = sol.ty-ty;
				if( sol!=this && Math.sqrt(dx*dx+dy*dy) < ray ){
					flBreak = false;
					break;
				};
			}
			if(flBreak)break;
		}

		y = Cs.mch+30;
		speed = 2+Math.random()*3;
		wait = 0;


	}
	function updatePlay(){
		if(wait!=null){
			wait+= mt.Timer.tmod;
			if(wait>id*2)wait = null;
		}else{
			y -= speed*mt.Timer.tmod;
			if( y <= ty ){
				y = ty;
				//step = -1;
			}
		}
	}

	// JUMP
	public function initJump(flag,?trg){

		if(trg==null)trg = Game.me.hex;
		hex = trg;

		flSuicide = flag;

		flDec = true;

		coef = -id*0.1;
		step = 1;

		var h = trg;

		sx = x;
		sy = y;

		var tx:Float = Cs.getX(h.x,h.y);
		var ty:Float = Cs.getY(h.x,h.y) - h.height;
		if(flSuicide){

			jh = 30;

			var dirs = [[1,0],[1,1],[0,1],[-1,0],[0,-1]];
			var d = dirs[Std.random(dirs.length)];

			tx = Cs.getX(Game.CX+d[0],Game.CY+d[1]) + (Math.random()*2-1)*Cs.WW*0.5;
			ty = Cs.getY(Game.CX+d[0],Game.CY+d[1]) + (Math.random()*2-1)*Cs.HH*0.5;
		}

		dx = tx - sx;
		dy = ty - sy;

		shade = Game.me.sdm.attach("mcShade",0);
		shade._x = -100;


		root.smc.gotoAndStop(4);

		//root.smc.gotoAndPlay(2);
		//Filt.glow(root,2,4,0);

	}
	function updateJump(){

		if(coef>0 && flDec ){
			flDec = false;
			Game.me.castle.base.prevFrame();
		}


		coef = Math.min(coef+0.05*mt.Timer.tmod,1);
		var c = Math.max(0,coef);


		var ox = x;
		var oy = y;

		x = sx+c*dx;
		y = sy+c*dy;

		shade._x = x;
		shade._y = y;



		y -= Math.sin(c*3.14)*jh;
		if( coef==1 ){
			shade.removeMovieClip();
			if(!flSuicide){
				land(hex);
			}else{
				fxPlouf();
				kill();
			}
		}


		// QUEUE
		var dx = x-ox;
		var dy = y-oy;
		var mc = Game.me.rdm.attach("mcRay",0);
		mc._x = ox;
		mc._y = oy;
		mc._xscale = Math.sqrt(dx*dx+dy*dy);
		mc._rotation = Math.atan2(dy,dx)/0.0174;


	}

	// BACK
	public function goBack(){
		step = 3;
	}
	function updateBack(){
		y += speed;
		if( y > Cs.mch+20 )kill();
	}

	// LAND
	public function land(hex:Socle){
		step = 2;
		Game.me.grid[hex.x][hex.y].incSoldat(1);
		kill();


	}
	function updateLand(){
	}


	function fxPlouf(){

		var max = 18;
		for( i in 0...max ){
			var a = -Math.random()*3.14;
			var sp = 0.3+Math.random()*1;
			var cr = 3;
			var p = new Phys( Game.me.dm.attach("partDrip",Game.DP_PARTS) );
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp ;
			p.x = x + p.vx*cr;
			p.y = y + p.vy*cr;
			p.timer = 10+Math.random()*30;
			p.frict = 0.9;
			p.updatePos();
		}

		var mc = Game.me.dm.attach("mcOnde",Game.DP_BG);
		mc._x = x;
		mc._y = y;



	}

	//
	override function kill(){
		Game.me.soldats.remove(this);
		super.kill();
	}

	//



//{
}

