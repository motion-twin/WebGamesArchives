class ac.piou.Platform extends ac.Piou{//}


	
	static var WW = 50
	static var HH = 50
	
	var bmp:flash.display.BitmapData;
	var mask:flash.display.BitmapData;
	
	var top:float;
	
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("incantation")

		
		//updateBmp();
		
		
	}
	
	function updateBmp(){
		
		if(bmp!=null)bmp.dispose();
		
		var x = int(piou.x-WW*0.5)
		var y = int(piou.y-HH*0.5)
		
		mask = new flash.display.BitmapData(WW,HH,true,0x00FF0000)
		var mcMask = Cs.game.dm.attach("mcPlatformMask",Game.DP_BASE)
		mask.drawMC(mcMask,0,0)
		mcMask.removeMovieClip();
		
		
		bmp = new flash.display.BitmapData(WW,HH,true,0x00FF0000)
		bmp.copyPixels( Level.bmp, new flash.geom.Rectangle( x, y, WW, HH ),new flash.geom.Point(0,0), mask, new flash.geom.Point(0,0), true )
		
	
		for(var py=0; py<HH; py++ ){
			for( var px=0; px<WW; px++){
				var pc = Cs.colToObj32(bmp.getPixel32(int(px),int(py)))
				if(pc.a>Level.TOLERANCE){
					top = py
					break;
				}
			}
			if(top!=null)break;
		}
		
		mask.dispose();
		
	}
	
	
	function update(){
		super.update();
		
		updateBmp();
		if(!checkGround(null,null)){
			freePiou()
			kill();
			return;
		}
		
		
		var x = int(piou.x-WW*0.5)
		var y = int(piou.y-HH*0.5)	

		// MOVE ELEMENTS
		for( var i=0; i<Cs.game.eList.length; i++ ){
			var e = Cs.game.eList[i]
			if( e.step==1 && Math.abs(piou.x-e.x) < WW*0.5 && Math.abs(piou.y-e.y) < HH*0.5 ){
				e.y--;
				e.updatePos();
				e.checkLim();
			}
		}		
		
		// MOVE PLAT
		if( !Level.isZoneFree(x,x+WW,y,y) ){
			go();
			kill();
			return;
		}
		Level.drawLink("mcPlatformMask",x,y+1.5,1,1,BlendMode.ERASE,null)
		
		//Level.bmp.copyPixels( new flash.display.BitmapData(WW,HH,true,0xFFFF0000), new flash.geom.Rectangle( 0, 0, WW, HH ),new flash.geom.Point(x,y), bmp, new flash.geom.Point(0,0), true )
		y--
		Level.bmp.copyPixels( bmp, new flash.geom.Rectangle( 0, 0, WW, HH ),new flash.geom.Point(x,y), bmp, new flash.geom.Point(0,0), true )
		

		// MOVE PIOUS
		for( var i=0; i<Cs.game.pList.length; i++ ){
			var p = Cs.game.pList[i]
			if( Math.abs(piou.x-p.x) < WW*0.5 && Math.abs(piou.y-p.y) < HH*0.5 ){
				p.y--;
				p.py--;
				p.updatePos();
				if( piou != p)	p.noSelection = 3;
			}
		}
		
		// PART
		if( Std.random(1) == 0 ){
			var p = Cs.game.newDebris( x+Math.random()*WW, piou.y+Math.random()*HH*0.5 )
			p.bouncer = null;
		}
		
		// PART LIGHT
		if( Std.random(2) == 0 ){
			var p = Cs.game.newPart( "partLightFlip" )
			p.x = piou.x + (Math.random()*2-1)*Piou.RAY*1.2
			p.y = piou.y - Math.random()*Piou.RAY*2
			p.vy = -(1+Math.random())
			p.weight = -Math.random()*0.5
			p.timer = 10+Math.random()*10
		}		
	

		if(piou.flDeath){
			kill();
		}
		

	}	
	
	function interrupt(){
		super.interrupt();
	}
	
	function kill(){
		bmp.dispose();
		mask.dispose();
		super.kill()
	}
	
//{
}