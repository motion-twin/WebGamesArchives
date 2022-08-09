package fx;
import mt.bumdum9.Lib;

class Play extends mt.fx.Fx{

	var frames : IntIter;
	var mc : MC;

	public function new(mc : MC, ?frames : IntIter, ?untilLabel : String ) {
		super();
		if( mc == null )
			throw "mc null";
		this.mc = mc;
		if( frames == null ){
			if( untilLabel == null ){
				frames = new IntIter(mc.currentFrame,mc.totalFrames);
			}else{	
				frames = new IntIter(mc.currentFrame,getLabelFrame(untilLabel));
			}
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
