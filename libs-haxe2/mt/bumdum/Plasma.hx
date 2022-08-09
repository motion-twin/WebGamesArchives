package mt.bumdum;
import mt.bumdum.Lib;

class Plasma extends Bmp {//}



	public static var TEST_BOX = false;
	static public var list:Array<Plasma>= new Array();

	public var ct:flash.geom.ColorTransform;
	public var filters:Array<flash.filters.BitmapFilter>;
	public var timer:Float;
	public var fadeLimit:Float;

	public function new(mc:flash.MovieClip,?w:Int,?h:Int,?q:Float){
		super(mc,w,h,true,0,q);
		list.push(this);
		filters = [];
		fadeLimit = 10;

		if(TEST_BOX){
			var m = 2;
			fillRect(rectangle,0xFFFF0000);
			fillRect(new flash.geom.Rectangle(m,m,w-2*m,h-2*m),0);
		}
	}

	public function update(){

		if(ct!=null) colorTransform( rectangle, ct );
		for(fl in filters){
			applyFilter(this, rectangle, new flash.geom.Point(0,0), fl );
		}

		if(timer!=null){
			timer -= mt.Timer.tmod;
			if(timer<fadeLimit){
				var c = timer/fadeLimit;
				root._alpha = c*100;
				if(timer<=0){
					kill();
				}
			}
		}

		if( root._visible == null ){
			//trace("plasma suicide!");
			kill();
		}



	}

	override function kill(){
		list.remove(this);
		dispose();

	}

	//
	static public function updateAll(){
		for( pl in list )pl.update();
	}



//{
}

