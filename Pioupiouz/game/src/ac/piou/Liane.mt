class ac.piou.Liane extends ac.Piou{//}

	static var SPEED = 7;
	
	static var FRAME_MAX = 6

	var flEnd:bool;
	
	var frame:int;
	var x:float;
	var y:float;
	var a:float;
	var freeTimer:float;
	var dropTimer:float;
	
	var sens:int;
	var dec:float;
	
	var list:Array<MovieClip>;
	
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("freeze")
		timer = 25;
		x = piou.x;
		y = piou.y;
		sens = piou.sens;
		frame=0;
		initAngle();
		list = new Array();
	}
	
	function update(){
		super.update();
		if(timer<0){
			timer = null
			go()
		}
		
		var ta = -1.57+0.6*sens//0.4*sens
		var da = Cs.hMod(ta-a,3.14)
		a += da*0.06
		dec = (dec+73)%628
		var na = a+Math.sin(dec/100)*0.2
		

			

		
		//mc.gotoAndStop(string(frame+1));
		//frame = (frame+1)%mc._totalframes;
		if(flEnd!=true){
			var mc = attachBuilder("mcLiane",x,y,false).smc;
			mc._rotation = na/0.0174;
			mc.stop();
			list.push(mc);
		
			var vx = Math.cos(na)*SPEED;
			var vy = Math.sin(na)*SPEED;
			var st = 6;
			for( var i=0; i<st; i++ ){
				x += vx/st
				y += vy/st
				if(freeTimer==null){
					if(!Level.isFree(x,y)){
						mc._xscale = (i/st)*100
						mc._yscale = mc._xscale
						
						if(dropTimer>0){
							go()
							flEnd = true;
						}else{
							sens *= -1
							y++
							x -= vx/st
							y -= vy/st
							initAngle();
						}
						break;
					}			
				}
			}
		}
		
		for( var i=0; i<list.length; i++){
			var mc = list[i]
			mc.nextFrame();
			if( mc._currentframe == FRAME_MAX ){
				traceMe(mc._parent)
				list.splice(i--,1)
			}
		}	

		if(freeTimer==null){
			dropTimer--
		}else{
			freeTimer-- 
			if(freeTimer==0){
				freeTimer = null;
				if(dropTimer==null){
					dropTimer = -1
				}else{
					dropTimer = 3
				}
			}
		}
		
		if(x<0 || x>Level.bmp.width || y<0 || y>Level.bmp.height ){
			go();
			flEnd = true;
		}
		
		if(flEnd && list.length==0){
			kill();
		}

		
		

	}	
	
	function initAngle(){
		a = -1.57+1.4*sens
		freeTimer = 1//2
		dec = 157+sens*157		
	}
	
	function interrupt(){
		freePiou();
	}
	
	function onReverse(){
		y = Cs.gry(y)
	}
	
//{
}