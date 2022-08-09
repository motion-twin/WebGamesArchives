class Action{//}
	
	var id:int;
	
	
	
	var tx:float;
	var ty:float;

	var step:int;
	var gs:int;
	var timer:float;

	function new(x,y){
		tx = x;
		ty = y;
	}

	function isAvailable(){
		return true;
	}
	
	function init(){
		Cs.game.bList.push(this)
		gs = 1
	}
	
	function update(){
		if(timer!=null)timer-=Timer.tmod;
	};

	// BUILDER
	function attachBuilder(link,x,y,flUnder){
		var dm = Cs.game.bdm;
		if(flUnder){
			dm = Cs.game.budm;
		}
		var mc = dm.attach(link,0)
		mc._x = x;
		mc._y = y;
		downcast(mc).obj = this;
		return mc;
	}
	
	function traceMe(mc){
		Level.drawMC(mc)
		mc.removeMovieClip();
	}
	
	function traceMeUnder(mc:MovieClip){
		var patchMargin = 2
		var r = mc.getBounds(Cs.game.map);
		r.xMin -= patchMargin
		r.yMin -= patchMargin
		r.xMax += patchMargin
		r.yMax += patchMargin
		r.xMin = int(r.xMin)
		r.yMin = int(r.yMin)
		r.xMax = int(r.xMax)
		r.xMax = int(r.xMax)
		var x = r.xMin;
		var y = r.yMin;
		var patch = new flash.display.BitmapData( int(r.xMax-r.xMin), int(r.yMax-r.yMin), true, 0x00000000 );

		var m = new flash.geom.Matrix();
		m.translate(-x, -y);
		patch.draw(Level.bmp,m,null,null,null,null)
		//
		traceMe(mc)
		//
		m = new flash.geom.Matrix();
		m.translate(x,y)
		Level.bmp.draw(patch,m,null,null,null,null)
		patch.dispose();

	}
	
	//
	function onReverse(){
		gs*=-1
	}
	
	//
	function interrupt(){
		kill();
	}
	
	function isFree(x,y){
		return Level.isFree(x,y)
	}
	
	//
	function kill(){
		Cs.game.bList.remove(this)
	}
	
	
//{
}