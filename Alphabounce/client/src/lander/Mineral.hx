package lander;

import mt.bumdum.Lib;
import mt.bumdum.Phys;

class Mineral{//}

	public var flDeath:Bool;
	public var root:flash.MovieClip;
	//var skinId:Int;
	var life:Float;
	public var val:mt.flash.VarSecure;

	public function new(seed:mt.OldRandom) {
		flDeath = false;
		lander.Game.me.minerals.push(this);
		root = lander.Game.me.gdm.attach("mcCrystal",lander.Game.DP_MINERALS);
		life = 100;
		root.smc._rotation = seed.rand()*360;


	}


	public function setValue(n){
		var skinId = 0;
		if( n > 35 )skinId++;
		if( n > 200 )skinId++;

		val = new mt.flash.VarSecure(n);
		life = 30+n*10;
		root.smc._xscale = root.smc._yscale = 60+n*(5/(skinId*7+1));

		root.smc.gotoAndStop(skinId+1);

	}

	public function dropToSurface(){
		root._y =  lander.Game.me.getGround(root._x);

	}
	public function consume(n){
		life -= n;
		if(life<=0)collect();
	}



	//
	public function collect(){

		//lander.Game.me.incMinerai(val);

		var max = Std.int( Num.mm( 3,val.get(),50));
		var ma = -0.5;
		for( i in 0...max ){
			var pos = getPosModifier();

			var p = new Phys( lander.Game.me.bdm.attach("partTwinkle",lander.Game.DP_PARTS) );
			//var a = i/max * 6.28;
			//var ray = 5+Math.random()*20;
			//p.x = Cs.getX(x+0.5) + Math.cos(a)*ray ;
			//p.y = Cs.getY(y+0.5) + Math.sin(a)*ray ;
			p.x = root._x + pos.x;
			p.y = root._y + pos.y;


			p.timer = 10+Math.random()*10;
			p.fadeType = 0;
			p.setScale(50+Math.random()*100);
			p.sleep = Math.random()*5;
			p.vy -= Math.random();
			p.root.blendMode = "add";
			p.root.gotoAndPlay(Std.random(2)+1);
			p.updatePos();
		}
		kill();
	}


	public function kill(){
		flDeath = true;
		lander.Game.me.minerals.remove(this);
		lander.Game.me.pad.minList.remove(this);
		root.removeMovieClip();
	}


	public function getPosModifier(){


		var to = 0;
		while(true){

			var mc = lander.Game.me.base;

			var b = root.getBounds(mc);
			var x = (Math.random()-0.5)*(b.xMax-b.xMin);
			var y = -Math.random()*(b.yMax-b.yMin)*0.5;

			var px = x + root._x + mc._x;
			var py = y + root._y + mc._y;


			if( root.smc.hitTest( px, py, true  ) ){
				return { x:x, y:y};
			}

			if( to++>20 )return { x:0.0, y:0.0};

		}
		return null;
	}



//{
}











