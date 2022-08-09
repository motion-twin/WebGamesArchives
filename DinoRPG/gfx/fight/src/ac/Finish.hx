package ac ;

import Fighter.Mode ;
import Fight;

import Fighter.Mode ;

class Finish extends State {//}

	var bh0:_EndBehaviour;
	var bh1:_EndBehaviour;

	public function new( bh0:_EndBehaviour, bh1:_EndBehaviour ) {
		super();
		this.bh0 = bh0;
		this.bh1 = bh1;
		for (f in Main.me.fighters){
			if(f.mode!=Dead)addActor(f);
		}
		if(casting.length==0 || casting==null)redirect();
	}

	override function init(){
		//trace("finish - init()");
		releaseCasting();
		for (f in Main.me.fighters){
			var bh = bh0;
			if( !f.side )bh = bh1;
			switch(bh){
				case _EBRun :
					//trace("run!");
					var m = 50;
					var tx = -m;
					var ty = f.y+(Math.random()*2-1)*20;
					if( f.side )tx+= Cs.mcw+2*m;
					new ac.Goto(f,tx,ty).flEnding = true;


				case _EBEscape :
					//trace("escape!");
					var m = 50;
					var tx = -m;
					var ty = f.y;
					if( !f.side )tx+= Cs.mcw+2*m;
					var ac = new ac.Goto(f,tx,ty);
					ac.flEnding = true;

				case _EBStand :

				case _EBGuard :
					//trace("!");
					var m = f.ray+10;
					var tx = m;
					var ty = f.y;
					if( f.side )tx+= Scene.WIDTH-2*m;
					var ac = new ac.Goto(f,tx,ty);
					ac.flSpin = true;

					/*
					var mx = Scene.WIDTH*0.5;
					var tx += mx + f.intSide*( mx-(ray+5));
					var ty = f.y;
					var dist = a.getDist({x:tx,y:ty});
					spc = a.runSpeed / dist ;
					a.moveTo(tx,ty);
					*/






			}
		}

		//
		if(Main.DATA._debrief!=null){
			redirect();
		}

	}

	public function redirect(){
		flash.Lib.getURL(Main.DATA._debrief);
	}



	public override function update() {
		super.update();


		if(castingWait)return;
	}




//{
}