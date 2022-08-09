class ac.piou.Seed extends ac.Piou{//}

	static var FRAME_MAX = 20;
	
	var leaf:{>MovieClip,mire:MovieClip};
	var seed:MovieClip;
	var sens:int;
	var x:float;
	var y:float;
	
	function new(x,y){
		super(x,y)
	}
			
	function init(){
		super.init();
		x = piou.x;
		y = piou.y+1;
		var seed = attachBuilder("mcSeed",x,y,false)
		sens = piou.sens;
		traceMe(seed)
		piou.y -= 2
		go();
		timer= 45
		
	}
	
	function update(){
		super.update();
		if(timer<0){
			if(leaf==null){
				leaf = downcast(attachBuilder("mcSeedPlant",piou.x,piou.y,false))
				leaf.stop();
				leaf.mire._visible = false;
				leaf._x = x;
				leaf._y = y;
				leaf._xscale= sens*100;
				leaf._yscale= gs*100;
			}else{
				leaf.nextFrame();
				var px = (leaf._x + leaf.mire._x*sens)
				var py = (leaf._y + leaf.mire._y*gs)
				if( !Level.isFree(px,py) || leaf._currentframe == FRAME_MAX ){
					traceMe(leaf)
					kill();
				}
				
			}
		}
	}	
	
	function onReverse(){
		super.onReverse();
		y = Cs.gry(y)
		
	}
	
//{
}