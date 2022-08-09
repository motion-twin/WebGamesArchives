package mt.bumdum;
import mt.bumdum.Lib;
import mt.bumdum.Phys;
import mt.bumdum.Bmp;


enum PartBehaviour {
	BhHoriLine;
	BhVertiLine;

}
class Part extends Phys {//}


	public var bhl:Array<PartBehaviour>;
	public var coef:Float;
	public var bmp:Bmp;

	public function new(?mc:flash.MovieClip){
		super(mc);
		bhl = [];
		coef = 1;


	}


	override function update(){
		for( bh in bhl ){
			switch(bh){
				case BhHoriLine:
					root._xscale = vx*100*coef;
				case BhVertiLine:
					root._yscale = vy*100*coef;
			}
		}

		if(bmp!=null)bmp.drawMc(root);
		super.update();
	}



//{
}

