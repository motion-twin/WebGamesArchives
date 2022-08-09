package mt.bumdum9;
import mt.bumdum9.Lib;

class Plasma extends Bmp {//}

	public var dead:Bool;

	public static var TEST_BOX = false;
	static public var list:Array<Plasma>= new Array();

	public var ct:flash.geom.ColorTransform;
	public var filters:Array<flash.filters.BitmapFilter>;
	public var timer:Null<Float>;
	public var fadeLimit:Float;

	public function new(mc:flash.display.MovieClip,?w:Int,?h:Int,?q:Float){
		super(mc, w, h, true, 0, q);
		dead = false;
		list.push(this);
		filters = [];
		fadeLimit = 10;

		if(TEST_BOX){
			var m = 2;
			fillRect(rect,0xFFFF0000);
			fillRect(new flash.geom.Rectangle(m,m,w-2*m,h-2*m),0);
		}
	}

	public function update(){
		if(dead) return;
		if(ct!=null) colorTransform( rect, ct );
		for(fl in filters){
			applyFilter(this, rect, new flash.geom.Point(0,0), fl );
		}

		if(timer!=null){
			timer -= mt.Timer.tmod;
			if(timer<fadeLimit){
				var c = timer/fadeLimit;
				root.alpha = c;
				if(timer<=0){
					kill();
				}
			}
		}

		if( root == null ){
			trace("plasma suicide!");
			kill();
		}



	}

	override function kill(){
		dead = true;
		list.remove(this);
		dispose();

	}

	//
	public function updateAll(){
		for( pl in list )pl.update();
	}



//{
}

