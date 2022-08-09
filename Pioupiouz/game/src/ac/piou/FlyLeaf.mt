class ac.piou.FlyLeaf extends ac.Piou{//}

	static var FRAME_MAX = 8;
	static var ACC = 0.14;
	
	
	var dec:float;
	var flower:MovieClip;
	var root:MovieClip;
	
	function new(x,y){
		super(x,y)
	}
	
	function isSelectable(p:Piou){
		return  Level.isFree(p.x,p.y+1)
	}
	
	
	function init(){
		super.init();
		piou.root.gotoAndStop("flyLeaf")
		root =  downcast(piou.root).sub
		if(piou.sens==-1){
			root.gotoAndStop(string(1+FRAME_MAX))
			piou.reverse();
		}
		piou.weight = Piou.WEIGHT
		dec = 0;
	}
	
	function update(){
		super.update();
		
		
		
		
		var dx = piou.root._xmouse
		var fm = FRAME_MAX*0.5
		var tf =  fm - Cs.mm(-fm,(dx*0.05)*fm,fm)
		

		if(tf>root._currentframe-1)root.nextFrame();
		if(tf<root._currentframe-1)root.prevFrame();
		
		var cf = (FRAME_MAX-(root._currentframe-1))/FRAME_MAX
		cf = 1-Math.abs(cf*2-1)
		piou.vy += cf*1.5
		
		if( dx>0 )piou.vx+=ACC*(1-cf);
		if( dx<0 )piou.vx-=ACC*(1-cf);
		
		//
		dec = (dec+13)%628
		var cp = Math.cos(dec/100)
		piou.vy += cp*0.2
		piou.root._rotation = cp*5
		
		piou.vy *= Math.pow(0.6,Timer.tmod)
		piou.vx *= Math.pow(0.97,Timer.tmod)
		
		//
		if(!Level.isSquareFree(piou.x,piou.y,1) ){
			piou.fall();
			kill();
		}
		
		
	}	
	
	
//{
}