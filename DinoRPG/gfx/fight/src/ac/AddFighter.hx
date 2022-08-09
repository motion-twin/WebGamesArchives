package ac ;

import Fight;
import mt.bumdum.Lib;

class AddFighter extends State {//}

	var f : Fighter ;

	var fxt : _AddFighterEffect;
	//var speedCoef:Float;
	var rdx : Float ;
	var rdy : Float ;
	var sp:Array<Array<Float>> ;
	var holeMask:flash.MovieClip;

	public function new(f : Fighter, fxt:_AddFighterEffect) {
		super();
		this.f = f ;
		this.fxt = fxt;

		spc = 0.03;
		
		endTimer = 5;

		f.setSkin() ;

		addActor(f);
		checkCasting();
		Scene.me.addSlot(f);
	}

	override function init(){
		var w = Scene.WIDTH * 0.5 ;
		var m = 10 ;
		var ex = w + (-f.intSide) * (w - (30 + Math.random() * 100)) ;
		var ey = Scene.getRandomPYPos();

		switch(fxt){
			case _AFPos(x,y,afx):
				ex = x;
				ey = y;
				fxt = afx;
			default:
		}

		f.x = ex;
		f.y = ey;

		var dsx = -f.intSide * (w + 50 );

		switch(fxt){

			case _AFStand:
			case _AFGrow:
			case _AFFall:
				f.z = -800;
				f.playAnim("fall");

			case _AFRun:
				f.x += dsx;
				f.moveTo(ex,ey);

			case _AFGround:
				f.updatePos();
				holeMask = Scene.me.dm.attach("mcHoleMask",Scene.DP_FIGHTER);
				f.root.setMask(holeMask);
				holeMask._x = f.root._x;
				holeMask._y = f.root._y;

				f.playAnim("stand");
				f.bounceFrict = null;
				f.updateShadeSize(0);

			case _AFAnim(anim):
				f.playAnim(anim);
				
			default:
				f.x += dsx;
				f.moveTo(ex,ey,2);
		}

	}

	public override function update()  {
		super.update();
		if(f.skinLoaded<2)return;

		switch(fxt){
			case _AFStand:
				//coef = 1;
			case _AFGrow:
				var c = Math.pow(coef,0.5);
				f.root._xscale = 100*c;
				f.root._yscale = f.root._xscale;
				f.updateShadeSize(c);

			case _AFFall:
				f.z = -800*(1-coef);
				f.updateShadeSize(coef);
			case _AFGround:
				holeMask._xscale = holeMask._yscale = (f.ray+20)*2;
				holeMask._xscale *= 3 ;

				f.z = (f.height*2 + 50)*(1-coef);
				if(coef>0.8)f.updateShadeSize((coef-0.8)/0.2);
				if(coef==1){
					f.bounceFrict =0.5;
					holeMask.removeMovieClip();
				}
				f.fxLand(1,1,20);

			case _AFAnim(anim):
			
			default:
				f.updateMove(coef);
		}


		f.skin._visible = true;
		f.updatePos();

		if(  coef == 1 ) {
			switch(fxt){
				case _AFFall:
					f.playAnim("land");
				default:

			}
			if(fxt != _AFFall && fxt != _AFJump && fxt!=null ){
				f.backToDefault();
			}
			f.lockTimer = 20;
			if( !f.isDino || !f.side )f.showName();
			kill();
		}
	}
}








































