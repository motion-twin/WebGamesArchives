class Level{//}

	static var BASE_COLOR = 0x00000000//0xFF223344
	static var TOLERANCE = 80//30//80
	
	static var did:int;
	
	static var baseColor:int
	static var lc:{r:int,g:int,b:int}
	
	static var bmp:flash.display.BitmapData
	static var bg:flash.display.BitmapData
	static var iron:flash.display.BitmapData
	
	static var tracer:flash.display.BitmapData
	static var traceTimer:int;
	
	static function init(){
		var w = Cs.game.level.size[0]
		var h = Cs.game.level.size[1]
		if(Cs.cacheLevel!=null){
			bmp = Cs.cacheLevel.clone();
			iron = Cs.cacheLevelIron
		}else{
			bmp = new flash.display.BitmapData(w,h, true, BASE_COLOR )
			iron = new flash.display.BitmapData(w,h, true, BASE_COLOR  )
		}
		
		/*
		if( Cs.game.permanentHelp!=null ){
			tracer = new flash.display.BitmapData(w,h, false, 0x000000 )
			traceTimer = 0
			var mc = Cs.game.dm.empty(Game.DP_PART)
			mc.attachBitmap(tracer,0)
			mc._alpha = 50
		}
		*/
		
		bg = new flash.display.BitmapData(w,h, true, BASE_COLOR )
		lc = Cs.colToObj(BASE_COLOR)
		did = Cs.game.level.did;
	}
	
	// GEN
	static function drawLink(link,x,y,sx,sy,b,fr){
		var mc = Cs.game.dm.attach(link,10)
		if(fr!=null)mc.gotoAndStop(string(fr));
		var m = new flash.geom.Matrix();
		m.scale(sx,sy)
		m.translate(x,y)
		bmp.draw( mc, m, null, b, null, null )
		if(b==BlendMode.ERASE){
			mc._x = x;
			mc._y = y;
			mc._xscale = sx*100
			mc._yscale = sy*100
			mc.gotoAndStop(string(fr))
			Cs.game.blast(mc);
		}
		mc.removeMovieClip();
	}
	
	static function holeSecure(link,x,y,sx,sy,rot,fr){
		var mc = Cs.game.dm.attach(link,10)
		if(fr!=null)mc.gotoAndStop(string(fr));
		mc._x = x;
		mc._y = y;
		mc._xscale = sx*100
		mc._yscale = sy*100
		mc._rotation = rot
		var o = Lib.getBitmap(mc)
		var fp = new flash.geom.Point(0,0)
		var sp = new flash.geom.Point(int(mc._x+o.x),int(mc._y+o.y) )

		var flSecure = !iron.hitTest( fp, TOLERANCE, o.bmp, sp, TOLERANCE )

		
		Cs.game.blast(mc);
		

		if(!flSecure){
			var mc3 = Cs.game.mdm.empty(Game.DP_BASE)
			var mir = new flash.display.BitmapData( o.bmp.width, o.bmp.height, true, 0x00000000 );
			mc3.attachBitmap(iron,0)
			var m = new flash.geom.Matrix();
			m.translate(-(x+o.x),-(y+o.y))	
			o.bmp.draw( mc3, m, null, BlendMode.ERASE, o.bmp.rectangle, null )
			mc3.removeMovieClip();
		}
		
		// 
		var mc2 = Cs.game.mdm.empty(Game.DP_BASE)
		mc2.attachBitmap(o.bmp,0)
		var m = new flash.geom.Matrix();
		m.translate(x+o.x,y+o.y)
		bmp.draw( mc2, m, null, BlendMode.ERASE, null, null )
		o.bmp.dispose();
		
			
		// 
		mc2.removeMovieClip();
		mc.removeMovieClip();
		

		//*/
		
		
		//Cs.traceBmp(o.bmp)
		//Log.trace("=")
		
		return flSecure;
		
	}
	
	static function drawTile(x,y,fr){
		var mc = Cs.game.dm.attach("mcTile",Game.DP_BASE)
		mc.gotoAndStop(string(Level.did+1));
		mc.smc.gotoAndStop(string(fr));
		var m = new flash.geom.Matrix();
		m.translate(x,y)
		bmp.draw( mc, m, null, null, null, null )
		if( fr>Lib.IRON_LIMIT[0] && fr<=Lib.IRON_LIMIT[1] ){
			iron.draw( mc, m, null, null, null, null )
		}
		
		
		mc.removeMovieClip();
	}
		
	static function genHole(x,y,r){
		var sc  = (2*r)/100
		drawLink("mcHole",x,y,sc,sc,BlendMode.ERASE,null)
	}

	static function drawMC(mc){
		var m = new flash.geom.Matrix();
		
		m.scale(mc._xscale/100, mc._yscale/100)
		m.rotate(mc._rotation*0.0174)
		m.translate(mc._x,mc._y)
		
		var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, -255 + mc._alpha*2.55)
		//ct.alphaOffset = -255 + mc._alpha*2.55
		
		var b = mc.blendMode
		
		bmp.draw( mc, m, ct, b, null, false )
	}
	
	static function drawPlatform(x,y,w,rid,rot){
		
		var flGrass = Cs.game.gameMode != 2
		
		var plat = Lib.getPlatform(w,rid,rot,Level.did,flGrass)
		var m = new flash.geom.Matrix();
		m.translate(x,y)
		bmp.draw( plat, m, null, null, null, null )
		
		// BG
		/*
		var mct = Lib.dm.attach("mcTextBack",0)
		mct.gotoAndStop(string(Level.did+1))
		var platBack = Lib.getTexturizedShape(mct,plat)
		mct.removeMovieClip();
		//var s = -90
		//var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, s, s, s, 0)
		bg.draw(platBack, m, null, null, null, null )
		*/
		
	}
	
	static function drawArtwork(x,y,sc,rot,fr){
		var mc = Cs.game.dm.attach("mcDecor",Game.DP_BASE)
		mc.gotoAndStop(string(fr))
		var m = new flash.geom.Matrix();
		m.scale(sc/100,sc/100)
		m.rotate(rot*0.0174)
		m.translate(x,y)
		bmp.draw( mc, m, null, null, null, null )
		mc.removeMovieClip();
		
	}
	
	static function drawLine(x,y,w,list){
		var line = Lib.getLine(w,list,Level.did,true);
		var m = new flash.geom.Matrix();
		m.translate(x,y)
		bmp.draw( line, m, null, null, null, null )
	}
	
	static function setBitmap(bitmap){
		bmp = bitmap
		Cs.game.mcDecor.attachBitmap(bmp,0)
	}
	//
	static function updateTracer(){
		if(traceTimer++>200){
		
		}
		Log.print(traceTimer)
		for( var i=0; i<Cs.game.pList.length; i++ ){
			var piou = Cs.game.pList[i];
			var col = tracer.getPixel(int(piou.x),int(piou.y))
			if( col < 0xFFFFFF ){
				traceTimer = 0;
				tracer.setPixel(int(piou.x),int(piou.y),col+160)
			}
		}
		
	}
	
	// RECAL
	static function scanRecal(x,y){
		var ray = 1
		var dir = 0
		var t = 0
		while(true){
			var d = Cs.DIR[dir]
			x+= d[0]*ray
			y+= d[1]*ray
			dir++
			if(dir==1)ray++;
			if(dir==3)ray++;
			if(dir==4)dir=0;
			
			if( Level.isFree(x,y) || t++>500 ){
				return [x,y]
			}
		}
		
		
	}
	
	// FX
	static function reverse(){
		var bmp2 = new flash.display.BitmapData( bmp.width, bmp.height, true, BASE_COLOR )
		var m = new flash.geom.Matrix()
		m.scale(1,-1)
		m.translate(0,bmp.height)
		bmp2.draw(bmp,m,null,null,null,null)
		setBitmap(bmp2);
		
		

		
		// MOVE SPRITES
		for( var i=0; i<Cs.game.sList.length; i++ ){
			var sp = Cs.game.sList[i]
			sp.y = Cs.gry(sp.y)
			sp.updatePos();
			// HACK PIOU
			if(downcast(sp).py!=null){
				downcast(sp).py = int(sp.y)
			}
		}
		
		// MOVE OUT
		for( var i=0; i<Cs.game.outList.length; i++ ){
			var mc = Cs.game.outList[i]
			mc._y = Cs.gry(mc._y)
		}
		
		// MOVE MAP
		Cs.game.map._y =  Cs.mch - (bmp.height +Cs.game.map._y)
		
		// BLAST ALL
		for( var i=0; i<Cs.game.blastList.length; i++ ){
			var sp = Cs.game.blastList[i]
			sp.onBlast(0,0);
		}
		
		// UPDATE ACTION
		for( var i=0; i<Cs.game.bList.length; i++ )Cs.game.bList[i].onReverse();

		// BUILDER
		var a = [Cs.game.bdm,Cs.game.budm]
		for( var i=0; i<a.length; i++ ){
			var list = a[i].plans[0].tbl
			for( var n=0; n<list.length; n++){
				var mc = list[n]
				mc._y = Cs.gry(mc._y);
				mc._yscale*=-1;
				/*
				var a = mc._rotation*0.0174
				var dx = Math.cos(a)
				var dy = Math.sin(a)
				var a = Math.atan2(-dy,dx)
				mc._rotation = a
				*/
			}
		}
		
		
	}

	// CHECK
	static function isFree(x,y){
		return isBg( bmp.getPixel32(int(x),int(y)) );
	}

	static function isIron(x,y){
		return !isBg( iron.getPixel32(int(x),int(y)) );
	}
	
	static function isZoneFree(xMin,xMax,yMin,yMax){
		for( var x=xMin; x<=xMax; x++ ){
			for( var y=yMin; y<=yMax; y++ ){
				if(!isFree(x,y))return false;
			}
		}
		return true;
	}
	
	static function isSquareFree(x,y,ray){
		var xMin = int(x-ray)
		var xMax = int(x+ray)
		var yMin = int(y-ray)
		var yMax = int(y+ray)
		return isZoneFree(xMin,xMax,yMin,yMax)
	}
	
	static function isBg(col){
		var pc = Cs.colToObj32(col)
		//var dif = Math.abs(pc.r-lc.r) + Math.abs(pc.g-lc.g) + Math.abs(pc.b-lc.b)
		return pc.a <= TOLERANCE// && pc.a >=0
	}
	
	
//{
}
