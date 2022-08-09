package mt.fx;

class Play extends Fx
{
	var frames : IntIterator;
	var mc : flash.display.MovieClip;

	public var startFrame : Null<Int>;
	public var endFrame : Null<Int>;

	public function new(mc : flash.display.MovieClip, ?frames : IntIterator, ?untilLabel : String ) {
		super();
		if( mc == null )
			throw "mc null";
		this.mc = mc;
		if( frames == null ){
			startFrame = mc.currentFrame;
			endFrame = untilLabel==null ? mc.totalFrames : getLabelFrame(untilLabel);
			frames = new IntIterator(startFrame,endFrame);
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
