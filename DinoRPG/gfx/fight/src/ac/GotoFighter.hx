package ac ;

import Fighter.Mode ;
import Fight ;

class GotoFighter extends State {


	var a : Fighter ;
	var t : Fighter ;
	var fxt : _GotoEffect ;

	public function new(f : Fighter, t : Fighter, ?fxt:_GotoEffect ) {
		super();
		this.a = f ;
		this.t = t ;
		this.fxt = fxt ;
		addActor(a);
		addActor(t);

	}


	override function init() {

		//a.playAnim("run");
		a.saveCurrentCoords();

		var p:{x:Float,y:Float} = null;
		switch(fxt){
			case _GOver:
				p = cast t;
				a.removeStatus(_SFly);
			default:	p = a.getBrawlPos(t);

		}


		var dist = a.getDist(p);
		spc = a.runSpeed / dist ;
		a.moveTo( p.x,p.y,getMoveBehaviour() );

		// FIX
		if(fxt==_GOver)p.x -= t.intSide*2;
	}


	public override function update() {
		super.update();
		if(castingWait)return;

		switch(fxt){
			case _GSpecial(col,col2):
				var p = new part.Shade(a,col,col2);
				spc += 0.005;
			case _GOver:
				spc += 0.01;
			default:

		}

		a.updateMove(coef);
		if(coef==1 )end();
	}

	function getMoveBehaviour(){

		switch(fxt){
			case _GOver: 		return 1;
			default:		return null;

		}
	}

}