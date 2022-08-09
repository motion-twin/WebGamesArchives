class ac.piou.Flower extends ac.Piou{//}

	static var FRAME_MAX = 16;
	var flower:MovieClip;

	
	function new(x,y){
		super(x,y)
	}
			
	function init(){
		super.init();
		flower = attachBuilder("mcFlower",piou.x,piou.y,false)
		flower.stop();
		piou.initStep(Piou.FLY)
		piou.vy = -6
		piou.y -= 2
	}
	
	function update(){
		super.update();

		flower.nextFrame();

		var b = downcast(flower).bulbe
		var c = b._xscale/100
		
		var px = flower._x
		var py = flower._y + b._y
		//Log.trace(py)
		var xMin = int(px-4*c)
		var xMax = int(px+5*c)
		var yMin = int(py-5*c)
		var yMax = int(py)-1		
		if( !Level.isZoneFree(xMin,xMax,yMin,yMax) || flower._currentframe == FRAME_MAX ){
			traceMe(flower)
			kill();
		}
	

	}	
	
	
//{
}