class ac.piou.Crystal extends ac.Piou{//}
	
	static var FRAME_MAX = 24;
	var crystal:MovieClip;
	
	function new(x,y){
		super(x,y)
	}
			
	function init(){
		super.init();	
		crystal = attachBuilder("mcCrystal",piou.x+piou.sens,piou.y+2,false)
		crystal.stop();
		crystal._xscale = piou.sens*100
		piou.root.gotoAndStop("freeze")
		
	}
	
	function update(){
		super.update();
		if(timer==null){
			
			var flCol = false;
			if(crystal!=null){
				crystal.nextFrame();
				
				//
				var mc = downcast(crystal).sub;
				var nx = crystal._x + mc._x*piou.sens;
				var ny = crystal._y + mc._y - 1;
				if( Level.isFree(int(nx),int(ny)) ){
					piou.x = nx
					piou.y = ny
				}else{
					flCol = true;
				}
				// PARTS
				for( var i=0; i<1; i++ ){
					var dx = (Math.random()*2-1)*14
					var p = Cs.game.newDebris(crystal._x+dx,crystal._y);
					var sp = 0.5+Math.random()*2
					p.vx = sp*piou.sens
					p.vy = -sp
					p.updatePos();
				}
				
				// SMOKE
				if( Math.random()/Timer.tmod < 0.5 ){
					var dx = (Math.random()*2-1)*14
					var px = crystal._x + dx
					var py = crystal._y
					//var color = Level.bmp.getPixel32(int(px),int(py))
					var p = Cs.game.newPart("mcNuage")
					p.x = px
					p.y = py
					p.setScale(150-Math.abs(dx)*5)
					p.vy = -Math.random()
					p.vr = dx
					Cs.game.dm.under(p.root)
				}
				
				// DEBRIS TOMBENT
				for( var i=0; i<1; i++ ){
					var dx = (Math.random()*2-1)*14
					var p = Cs.game.newDebris(crystal._x+dx,crystal._y);
					var pos = Math.random()*mc._x
					p.x = crystal._x + (10+pos)*piou.sens
					p.y = 2+crystal._y - pos
					p.vy = 1
					p.updatePos();
					p.timer += 40
					p.bouncer = new Bouncer(p)
				}
				
			}else{
				timer = 10;
			}
			
			// CHECK INTERRUPTION
			var r = 2
			var xMin = int(piou.x-r)
			var xMax = int(piou.x+r)
			var yMin = int(piou.y-2*r)
			var yMax = int(piou.y)		
			if( flCol || !Level.isZoneFree(xMin,xMax,yMin,yMax) || crystal._currentframe == FRAME_MAX ){
				flSameIsOk = true;
				timer = 10
				piou.y++;
				traceMe(crystal)
			}else{
				Level.drawMC(crystal)
			}
	
			
			
			
			
		}else{
			if( timer <0){
				go()
				kill();
			}
		}

		
		
	}
	
	function interrupt(){
		//Log.clear()
		//Log.trace("interrpupt!("+timer+")")
		super.interrupt();
		traceMe(crystal)
	}
	
	function onReverse(){
		traceMe(crystal)
		go()
		kill();
	}
		
	
	
//{
}