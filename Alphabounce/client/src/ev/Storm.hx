package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Storm extends Event {//}

	static public var TOTAL = 0;

	public var bl:Block;
	var timer:Float;

	var root:flash.MovieClip;
	var dm:mt.DepthManager;



	public function new(){
		super();

		TOTAL++;
		
		root = Game.me.dm.empty(Game.DP_PARTS);
		dm = new mt.DepthManager(root);
		root.blendMode = "add";
		Filt.glow(root,2,4,0xFFFF00);
		Filt.glow(root,14,2,0xFFFF00);

		timer = 40;
		Game.me.pad.freeze++;

	}

	override public function update(){
		super.update();

		if(Game.me.pad==null){
			kill();
			return;
		}

		//
		root.clear();
		var max =  Std.int(1+Math.min( timer/10, 3));


		for( k in 0...max ){
			var sx = Cs.getX(bl.x+0.5);
			var sy = Cs.getY(bl.y+0.5);
			var ex = Game.me.pad.x + (Math.random()*2-1)*Game.me.pad.ray ;
			var ey = Game.me.pad.y;

			var max = 10;
			var ec = 10;

			var list = [];
			for( i in 0...max ){
				var c = (i+1)/max;
				var x = sx*(1-c) + ex*c + (Math.random()*2-1)*ec;
				var y = sy*(1-c) + ey*c + (Math.random()*2-1)*ec;

				if( i==max-1 ){
					x = ex;
					y = ey;
				}

				list.push([x,y]);
			}




			root.moveTo(sx,sy);
			root.lineStyle(2.5,0xFFFFFF,50);
			for( p in list ){
				root.lineTo(p[0],p[1]);
			}


		}

		//
		timer -= mt.Timer.tmod;
		if( timer < 0 )kill();


		//
		Game.me.pad.setFlash(2);
		//if( Game.me.pad.flh == null ) Game.me.pad.flh = 0;
		//Game.me.pad.flh += 100;


	}

	override public function kill(){
		TOTAL--;
		root.removeMovieClip();
		Game.me.pad.freeze--;
		super.kill();
	}


//{
}













