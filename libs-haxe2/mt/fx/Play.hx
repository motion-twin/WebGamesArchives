package mt.fx;
import mt.bumdum9.Lib;

class Play extends mt.fx.Fx{

	var frames : IntIter;
	var mc : MC;

	public var startFrame : Null<Int>;
	public var endFrame : Null<Int>;

	public function new(mc : MC, ?frames : IntIter, ?untilLabel : String ) {
		super();
		if( mc == null )
			throw "mc null";
		this.mc = mc;
		if( frames == null ){
			startFrame = mc.currentFrame;
			endFrame = untilLabel==null ? mc.totalFrames : getLabelFrame(untilLabel);
			frames = new IntIter(startFrame,endFrame);
		}
		this.frames = frames;
	}

	function getLabelFrame( label : String ){
		for( l in mc.currentLabels )
			if( l.name == label )
				return l.frame;
		throw "Label not found: "+label;
	}
	
	override function update() {
		if( frames.hasNext() )
			mc.gotoAndStop(frames.next());
		else
			kill();
	}
	
}
