package game.viewer;

class Star extends flash.display.Shape {
	public var lineColor : Null<UInt>;
	public var fillColor : Null<UInt>;
	public var lineSize : Null<Float>;
	public var internalRadius : Float;
	public var controlRadius : Float;
	public var corners : Int;

	public function new(internalRadius:Float, ctrlRadius:Float, corners:Int ){
		super();
		this.lineSize = 1;
		this.lineColor = 0xFFFFFF;
		this.fillColor = 0xCCCCCC;
		this.internalRadius = internalRadius;
		this.controlRadius = ctrlRadius;
		this.corners = corners;
		draw();
	}

	public function draw(){
		var a = 2*Math.PI/ corners;
		var gfx = graphics;
		gfx.clear();
		if (lineSize != null && lineSize != 0 && lineColor != null)
			gfx.lineStyle(lineSize, lineColor);
		if (fillColor != null)
			gfx.beginFill(fillColor);
		var ctr = new geom.PVector3D(0, -controlRadius);
		var pt1 = new geom.PVector3D(0, -internalRadius);
		ctr.rotateZ(a/2);
		var pt2 = pt1.clone().rotateZ(a);
		gfx.moveTo(pt1.x, pt1.y);
		for (i in 0...corners-1){
			gfx.curveTo(ctr.x, ctr.y, pt2.x, pt2.y);
			ctr.rotateZ(a);
			pt2.rotateZ(a);
		}
		gfx.curveTo(ctr.x, ctr.y, pt1.x, pt1.y);
		gfx.endFill();
	}
}