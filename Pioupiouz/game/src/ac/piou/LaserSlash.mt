class ac.piou.LaserSlash extends ac.Piou{//}

	static var FRAME_MAX = 39
	static var BASE_FRAME = 20
	
	var body:MovieClip;
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		flExclu= true;
		piou.root.gotoAndStop("laserSlash")
		body = downcast(piou.root).sub
		body.stop();
	}
	
	function update(){
		super.update();
		
		body.nextFrame();
		
		var cf = body._currentframe
	
		if( cf > BASE_FRAME && cf<= BASE_FRAME+3 )dig();
		if( cf == FRAME_MAX )endAction();
	}	
	
	function dig(){
		Level.holeSecure("mcHoleLaserSlash",piou.x,piou.y,piou.sens,1,0,downcast(piou.root).sub._currentframe-BASE_FRAME)
	}
	
	function endAction(){
		go();
		kill();
	}
	
	
//{
}