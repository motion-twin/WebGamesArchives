import mt.bumdum.Phys;
import mt.bumdum.Lib;





class Ghost extends Phys{//}

	static var RAY = 6;

	var turnCol:Int;
	var angle:Float;
	var va:Float;
	var speed:Float;
	var speedFloat:Float;
	var float:Float;


	public function new( mc : flash.MovieClip ){
		super(mc);
		Game.me.ghostList.push(this);


		angle = Math.random()*6.28;
		va = 0;
		speed = 1 + Math.random()*1;
		speedFloat = 20 + Math.random()*20;
		float = Math.random()*628;

		var p = getFreePos();
		x = (p[0]+0.5)*Game.SIZE;
		y = (p[1]+0.5)*Game.SIZE;

	}

	override function update(){



		va += (Math.random()*2-1)*0.05;
		va *= Math.pow(0.92,mt.Timer.tmod);
		angle = Num.hMod( angle+va, 3.14 );

		//GFX
		var fr = Std.int(Num.sMod(angle,6.28)/6.28 *80)+1;
		root.smc.gotoAndStop(fr);
		float = (float+speedFloat*mt.Timer.tmod)%628;
		root.smc._y = Math.cos(float*0.01)*4 -8;

		vx = Math.cos(angle)*speed;
		vy = Math.sin(angle)*speed;

		super.update();
		checkCols();
		updatePos();

	}

	function checkCols(){

		var px = getPos(x);
		var py = getPos(y);

		if(!Game.isFree(px,py)){
			explode();
			return;
		}

		var flCol = false;
		for( d in Game.DIR ){
			var nx = getPos(x+d[0]*RAY);
			var ny = getPos(y+d[1]*RAY);

			if(!Game.isFree(nx,ny) ){
				var rr = RAY;
				if( d[0] != 0 ){
					x = Num.mm( px*Game.SIZE+rr, x, (px+1)*Game.SIZE-rr );
					vx*=-1;
				}else{
					y = Num.mm( py*Game.SIZE+rr, y, (py+1)*Game.SIZE-rr );
					vy*=-1;
				}
				var da = Num.hMod(Math.atan2(vy,vx)-angle,3.14);
				if(turnCol==null)turnCol = Std.random(2)*2-1;
				va += 0.05*turnCol*mt.Timer.tmod;
				flCol = true;
			}
		}
		if(!flCol)turnCol=null;
	}

	//
	public function explode(){
		var max = 12;
		for( i in 0...max ){
			var p = new Phys(Game.me.dm.attach("partCloud",Game.DP_PARTS));
			var sp = 0.2+Math.random()*0.5;
			var r = sp*10;
			var a = i/max * 6.28;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			p.x = x+ca*r;
			p.y = y+sa*r - 6;
			p.vx = ca*sp;
			p.vy = sa*sp;
			p.frict = 0.95;
			p.timer = 10+Math.random()*20;
			p.sleep  = Math.random()*8;
			p.setScale(100+Math.random()*100);
			p.fadeType = 0;
			p.root.blendMode = "add";
			p.weight = -Math.random()*0.3;
			p.vr = (Math.random()*2-1)*10;
			p.root._rotation = Math.random()*360;
			//if(Std.random(2)==0)Col.setColor(p.root,0xCCCC00,-255);
		}

		kill();
	}

	// TOOLS
	function getFreePos(){
		var x = null;
		var y = null;
		var to = 0;
		do{
			x = Std.random(Game.me.xmax);
			y = Std.random(Game.me.ymax);
			if(to++>100){
				trace("noFreePos!");
				break;
			}
		}while(!Game.isFree(x,y));
		return [x,y];
	}

	function getPos(n:Float):Int{
		return Std.int(n/Game.SIZE);
	}

	override function kill(){
		Game.me.ghostList.remove(this);
		super.kill();
	}

//{
}













