class ac.piou.Acid extends ac.Piou{//}


	static var FRAME_MAX = 29
	
	static var DIR = [[1,0],[0,1],[-1,0],[0,-1]]
	static var DIR2 = [[1,-1],[1,1],[-1,1],[-1,-1]]
	
	var pList:Array<{x:int,y:int,t:int}>;
	var grid:Array<Array<bool>>
	
	var body:MovieClip;
	
	var index:int;
	
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		
		piou.root.gotoAndStop("acid")
		
		body = downcast(piou.root).sub
		body.stop();
		
		timer = 200
		index = 0
		step  = 0
	}
	
	function update(){
		
		super.update();
		if(step==2){
			for( var i=0; i<50; i++ ){
				index = (index+1)%pList.length;
				var p = pList[index]
				p.t++
				var list = null
				if(p.t==3){
					list = DIR;
				}else if(p.t==4){
					list = DIR2;
					Level.bmp.setPixel32(p.x,p.y,0x00000000)
					grid[p.x][p.y] = null;
					pList.splice(index--,1)	
				}else{
					if(Std.random(20)==0){
						var goutte = Cs.game.newDebris(p.x,p.y);
					}
				}
				if(timer<0)list = null;
				for( var n=0; n<list.length; n++ ){
						var d = list[n]
						var nx = p.x+d[0];
						var ny = p.y+d[1];
						if(!Level.isFree(nx,ny) ){
							if(grid[nx][ny] == null){
								var tt = 0
								if(Level.isIron(nx,ny))tt-=20
								
								pList.push({x:nx,y:ny,t:tt})
								Level.bmp.setPixel32(nx,ny,0xFF00FF00)
								grid[nx][ny] = true;
							}
						}else{
							Level.bmp.setPixel32(nx,ny,0x00000000)
						}
				}
			}
			if(pList.length==0){
				kill();
			}
		}
		body.nextFrame();
		if( body._currentframe == FRAME_MAX )endAnim();
		
		if( piou!=null ){
			if(step==0){
				if( !checkGround(2,0)){
					kill();
				}
			}
		}
	}	
	
	function dropGoutte(){
		var sp = new Phys(Cs.game.dm.attach("mcAcidGoutte",Game.DP_PART))
		var nx = piou.x+(Piou.RAY+3)*piou.sens
		var ny = piou.y-(Piou.RAY*2)
		
		sp.x = nx
		sp.y = ny
		sp.weight = 0.2
		sp.bouncer = new Bouncer(sp)
		sp.bouncer.onBounceGround = callback(this,hitGround,sp);
		if(sp.isOut(0)){
			sp.kill();
			go()
			kill();
		}
		step = 1
	}
	
	function hitGround(sp){
		step  = 2
		pList = [ { x:sp.bouncer.px, y:sp.bouncer.py+1, t:0 }]
		sp.kill();
		grid = new Array();
		for( var x=0; x<Level.bmp.width; x++ )grid[x] = new Array();
	}
	
	function endAnim(){
		go()
	}
	
	function onReverse(){
		for( var i=0; i<pList.length; i++ ){
			var p = pList[i]
			p.y = Cs.gry(p.y)
		}
	}
	
//{
}