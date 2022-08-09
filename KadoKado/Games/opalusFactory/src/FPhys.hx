import mt.bumdum.Phys ;

class FPhys extends Phys {
	
	public var onEnd : Void -> Void ;
	
	
	public function new(?mc:flash.MovieClip){
		super(mc);
		
	}
	
	public override function kill(){
		super.kill();
		
		if (onEnd != null)
			onEnd() ;
	}
	
}