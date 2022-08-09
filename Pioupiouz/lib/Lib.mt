class Lib{//}
	
	static var DP_TEST = 10;
	
	static var CROUTE_LIMIT = 8
	static var ARTWORK_MAX = 100
	
	static var IRON_LIMIT = [10,20]
	static var FRONT_LIMIT = [10,20]
	
	
	static var root:MovieClip;
	static var dm:DepthManager;
	
	static function setRoot(mc){
		root = mc;
		dm = new DepthManager(mc);
	}
	
	static function getPlatform(w,rid,rot,did,flCroute){
		var rnd = new Random(rid) 
		
		// MASK
		var mcMask = dm.empty(DP_TEST);
		var mcCont = Std.createEmptyMC(mcMask,0)
		var ddm = new DepthManager(mcCont);
		var max = 2+w*0.2
		var sc = Math.min(w*0.1,80)
		for( var i=0; i<max; i++ ){
			var mc = ddm.attach("mcForm",0);
			mc._rotation = rnd.rand()*360;
			mc._x = rnd.rand()*w
			var c = 1-Math.abs((mc._x-w*0.5)/(w*0.5))
			mc._y = ((rnd.rand()*2-1)-0.6)*(w*0.1)*c;
			mc._xscale = 15+c*sc;
			mc._yscale = mc._xscale;
			mc.gotoAndStop(string(did+1))
			downcast(mc).sub.gotoAndStop(string(rnd.random(downcast(mc).sub._totalframes)+1))
		}
		mcCont._rotation = rot
		var b = mcMask.getBounds(root);
		var mcw = int(b.xMax-b.xMin);
		var mch = int(b.yMax-b.yMin);
		var mask = new flash.display.BitmapData(mcw,mch,true,0x00000000)
		var m = new flash.geom.Matrix();
		m.rotate(rot*0.0174)
		m.translate(-b.xMin,-b.yMin)
		mask.draw(mcCont,m,null,null,null,null)
		mcMask.removeMovieClip();

		
		// TEXTURE
		
		
		var mct = dm.attach("mcText",0)
		mct.gotoAndStop(string(did+1))
		var ts = int(mct._width)
		var rect = new flash.geom.Rectangle(0,0,ts,ts)
		var text = new flash.display.BitmapData(ts,ts,true,0x50000000)
		text.drawMC(mct,0,0)
		if(ts==0){
			Log.trace("plateforme error! ")
			Log.trace(Level.did)
			return null
		}
		
		mct.removeMovieClip();
		

		// MAPPING
		var map = new flash.display.BitmapData(mcw,mch,true,0x00000000)
		for( var x=0; x<mcw; x+=ts ){
			for( var y=0; y<mch; y+=ts ){
				map.copyPixels(text,rect,new flash.geom.Point(x,y),null,null,null);
			}
		}
		text.dispose();
		
		
		
		// ELEMENT SUP
		var emax = Math.sqrt(mcw*mch)*0.05
		var list = new Array();
		for( var i=0; i<emax; i++ ){
			var mc = dm.attach("mcDirtElement",0)
			mc.gotoAndStop(string(did+1))
			var frame = int(rnd.rand()*(downcast(mc).sub._totalframes))+1
			downcast(mc).sub.gotoAndStop( string(frame) )
	
			mc._rotation = rnd.rand()*360
			var mw = mc._width*0.5
			var mh = mc._height*0.5
			var x = mw+rnd.rand()*(mcw-mw*2)
			var y = mh+rnd.rand()*(mch-mh*2)
			m = new flash.geom.Matrix();
			m.rotate(mc._rotation*0.0174)
			m.translate(x,y)
			var flPut = true
			for( var n=0; n<list.length; n++ ){
				var o = list[n];
				if( Math.abs(x-o.x) < o.mw+mw && Math.abs(y-o.y) < o.mh+mh ){
					flPut = false;
					break;
				}
			}
			if(flPut){
				map.draw(mc,m,null,null,null,null)
				list.push({x:x,y:y,mw:mw,mh:mh})
			}
			mc.removeMovieClip();
		}

		
		
		// BASE FINAL
		var bmp = new flash.display.BitmapData(mcw,mch,true,0x00000000)
		bmp.copyPixels( map, new flash.geom.Rectangle(0,0,mcw,mch),new flash.geom.Point(0,0),mask,null,true )
		
		map.dispose();
		mask.dispose();
		if(flCroute)encroute(bmp,did);
		
		return bmp;
	}
		
	static function getLine( w, lst, did, flCroute ){
		
		var mcMask = dm.empty(DP_TEST);
		var list = lst.duplicate();
		list.unshift( [0,0] )
		var lp = null
		
		for( var i=0; i<list.length; i++){
			var p = list[i];
			var mc = Std.attachMC( mcMask, "mcLineRound", i );
			mc._x = p[0];
			mc._y = p[1];
			mc._xscale = w
			mc._yscale = w
			if(lp!=null){
				mc._x += lp.x
				mc._y += lp.y
			}
			var np = {x:mc._x,y:mc._y}
			if(lp!=null){
				var line = Std.attachMC( mcMask, "mcLineBody", 100+i );
				line._x = mc._x
				line._y = mc._y
				line._xscale = Cs.getDist(lp,np)
				line._yscale = w
				line._rotation = Cs.getAng(lp,np)/0.0174
			}

			lp = np
		
		}
		
		//
		var b = mcMask.getBounds(root);
		var mcw = int(b.xMax-b.xMin);
		var mch = int(b.yMax-b.yMin);
		var mask = new flash.display.BitmapData(mcw,mch,true,0x00000000)
		
		var m = new flash.geom.Matrix();
		m.translate(-b.xMin,-b.yMin)
		mask.draw(mcMask,m,null,null,null,null)
		mcMask.removeMovieClip();

		//Cs.traceBmp(mask);
		//return mask
		//Cs.game.bg.attachBitmap(mask,10000)
		
		

		//
		var mct = dm.attach("mcText",0)
		mct.gotoAndStop(string(did+1))
		var bmp = getTexturizedShape(mct,mask)
		mct.removeMovieClip();
		
		//Cs.traceBmp(bmp)
		
		if(flCroute)encroute(bmp,did);
		return bmp
		
	}
		
	static function encroute(bmp:flash.display.BitmapData,did){
		
		
		// CROUTE
		var mct = dm.attach("mcCroute",0)
		mct.gotoAndStop(string(did+1))
		var croute = new flash.display.BitmapData(int(mct._width),int(mct._height),true,0x00000000)
		
		croute.drawMC(mct,0,0)
		mct.removeMovieClip();
		
		var cx = 0
		var sy = 0
		var pile = new Array();
		for( var x=0; x<bmp.width; x++){
			var flLast = x==bmp.width-1
			var ry = null
			for( var y=sy; y<bmp.height; y+=1 ){
				if(bmp.hitTest(new flash.geom.Point(0,0),80,new flash.geom.Point(x,y),null,null)){
					ry = y
					break;
				}
			}	
			ry--
			var py = pile[pile.length-1]
			if( ( pile.length==0 || Math.abs(py-ry) < CROUTE_LIMIT) && !flLast && ry!=null){
				var dy = ry
				if(pile.length>0)dy = ry*0.5 + py*0.5;
				pile.push(dy)
				sy = dy-(CROUTE_LIMIT)
			}else{
				
				if(pile.length>5){
					var dx = x
					var cMax = 0.1
					while(pile.length>0){
						cMax = Math.min(1,cMax+0.2)
						var cBot = pile.length*0.1
						var c = Math.min(cMax,cBot)
						dx--
						var dy = pile.pop();
						var r =  new flash.geom.Rectangle(cx,0,1,croute.height*c)
						var dest =  new flash.geom.Point(dx,dy)
						bmp.copyPixels(croute, r , dest, null,null,null)
						cx = (cx+1)%croute.width								
					}
						
				}
				pile= new Array();
				py = null
				sy = 0
			}
		}	
	}
	
	static function getTexturizedShape(mct,mask){

		var mcw = mask.width
		var mch = mask.height
		
		// TEXTURE
		var tw = int(mct._width)
		var th = int(mct._height)
		var rect = new flash.geom.Rectangle(0,0,tw,th)
		var text = new flash.display.BitmapData(tw,th,true,0x50000000)
		text.drawMC(mct,0,0)

		
		
		// MAPPING
		var map = new flash.display.BitmapData(mcw,mch,true,0x00000000)
		for( var x=0; x<mcw; x+=tw ){
			for( var y=0; y<mch; y+=th ){
				map.copyPixels(text,rect,new flash.geom.Point(x,y),null,null,null);
			}
		}
	
		
		
		var bmp = new flash.display.BitmapData(mcw,mch,true,0x00000000)
		bmp.copyPixels( map, new flash.geom.Rectangle(0,0,mcw,mch),new flash.geom.Point(0,0),mask,null,true )
		text.dispose();
		map.dispose();
		return bmp;
		
	}	
	
	// BMP
	
	static function getBitmap(mc){
		var b = mc.getBounds(mc._parent);
		var b2 = mc.getBounds(mc);
		var mcw = int(b.xMax-b.xMin);
		var mch = int(b.yMax-b.yMin);
		var bmp = new flash.display.BitmapData(mcw,mch,true,0x00000000);
		var m = new flash.geom.Matrix();
		var sx = mc._xscale/100
		var sy = mc._yscale/100
		m.scale(sx,sy)
		m.rotate(mc._rotation*0.0174)
		m.translate(mc._x-b.xMin,mc._y-b.yMin)
		bmp.draw(mc,m,null,null,null,null);
		return { x:b.xMin-mc._x, y:b.yMin-mc._y, bmp:bmp }
	}
	

	
	//
	static function cellShadeMc(mc,n,s){
		var fl = new flash.filters.GlowFilter();
		fl.blurX = n
		fl.blurY = n
		fl.strength = s
		fl.color = 0x000000
		mc.filters = [fl]	
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
//{	
}