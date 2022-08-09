class Level{//}
	
	static var DP_DRAW = 0;
	static var DP_BG = 1;
	static var DP_DECOR = 3;
	//static var DP_TILE = 2;
	//static var DP_PLAT = 3;
	static var DP_PIOU = 5;
	static var DP_ICON = 6;
	static var DP_HAND = 7;
	
	static var BASE_COLOR = 0x00000000;
	static var TOLERANCE = 40;
	static var lc:{r:int,g:int,b:int};
	
	static var GRID_COLOR = 0x30FFFFFF;
	

	static var width:int;
	static var height:int;
	static var did:int;

	
	static var tiles:Array<MovieClip>;
	static var platforms:Array<{>MovieClip,bmp:flash.display.BitmapData,w:int,rid:int,rot:int,list:Array<Array<int>>}>;
	static var piouList:Array<MovieClip>;
	static var outList:Array<MovieClip>;
	static var caisseList:Array<{>MovieClip,id:int,num:int}>;
	static var root:MovieClip;
	static var mcDraw:MovieClip;
	static var mcDecor:{>MovieClip, out:MovieClip, tile:MovieClip, plat:MovieClip, element:MovieClip, caisse:MovieClip, tileFront:MovieClip};
	static var dm:DepthManager;
	static var tdm:DepthManager;
	static var tfdm:DepthManager;
	static var pdm:DepthManager;
	static var edm:DepthManager;
	static var odm:DepthManager;
	static var cdm:DepthManager;
	
	static var grid:flash.display.BitmapData;
	static var pbmp:flash.display.BitmapData;
	
	static function init(){
		//bmp = new flash.display.BitmapData(w,h, true, BASE_COLOR )
		lc = Cs.colToObj(BASE_COLOR)
		width  = Cs.game.level.size[0];
		height  = Cs.game.level.size[1];
		did  = Cs.game.level.did;
		
		if(width<Cs.mcw){
			var mask = Cs.game.mdm.attach("mcSideMask",Game.DP_INTER)
			
			mask._xscale = Cs.mcw-width
			mask._x = Cs.mcw-mask._xscale
			mask._yscale = Cs.mch-Cs.INTERFACE_MARGIN
		}
		
		// HACK
		/*
		if(did==null){
			did = 0
			width = 800
			height = 1000
		}
		*/
		
		root = Cs.game.mdm.empty(Game.DP_MAP)
		dm = new DepthManager(root);
		mcDraw = dm.empty(DP_ICON)
		mcDecor = downcast(dm.empty(DP_DECOR))
		var ddm = new DepthManager(mcDecor);
		
		mcDecor.tile = ddm.empty(1)
		mcDecor.plat = ddm.empty(2)
		mcDecor.tileFront = ddm.empty(3)
		mcDecor.out = ddm.empty(4)
		mcDecor.element = ddm.empty(5)
		mcDecor.caisse = ddm.empty(6)
		
		odm = new DepthManager(mcDecor.out);
		tdm = new DepthManager(mcDecor.tile);
		pdm = new DepthManager(mcDecor.plat);
		tfdm = new DepthManager(mcDecor.tileFront);
		edm = new DepthManager(mcDecor.element);
		cdm = new DepthManager(mcDecor.caisse);
		
		
		
		if(Cs.CAB)root.cacheAsBitmap = true;
		//
		tiles = new Array();
		platforms = new Array();
		piouList = new Array();
		outList = new Array();
		caisseList = new Array();
		//
		var mc = dm.empty(DP_BG)
		grid = new flash.display.BitmapData(width,height,true,0x00000000)
		mc.attachBitmap(grid,1)

	}
	
	// GENERIC
	static function activateList(list,f,str:String){
		for( var i=0; i<list.length; i++ ){
			var mc = list[i]
			mc.onPress = make(f,mc);
			mc.useHandCursor = false
			var info = str
			var infoSup = downcast(mc).str
			if(infoSup!=null)info += infoSup;
			Inter.setInfo(mc,info)
		}
	}
	
	static function make(f,mc) {
		return fun() { f(mc) };
	}
	
	static function deactivateList(list){
		for( var i=0; i<list.length; i++ ){
			var mc = list[i]
			mc.onPress = null
			mc.onRollOver = null
			mc.onRollOut = null
			mc.onDragOut = null
			mc.useHandCursor = false
		}
	}
	
	static function removeElement(list,mc){
		list.remove(mc)
		mc.removeMovieClip();
		downcast(mc).bitmap.dispose();
		Inter.traceInfo("")
		if(Inter.mode == 2 )Inter.initMode(2);
		
	}
	
	// TILE
	static function addTile(x,y,id){
		//var depth = 1
		var dm = tdm
		if(id>=Lib.FRONT_LIMIT[0] && id<Lib.FRONT_LIMIT[1])dm = tfdm;
		
		var mc = dm.attach("mcTile",0)
		mc.gotoAndStop(string(did+1))
		mc.smc.gotoAndStop(string(id+1))
		mc._x = x
		mc._y = y
		tiles.push(mc)
		Inter.traceInfo("")
		mapUpdate();
	}
	
	static function paintTile(){
		if(Cs.game.root._ymouse < Cs.mch-Cs.INTERFACE_MARGIN ){
			addTile(Inter.hand._x,Inter.hand._y,Inter.hand.smc._currentframe-1)
			if(!Key.isDown(17) || tiles.length==Inter.lim.tiles ){
				endPaint();
			}
		}
	}
	
	static function clickTile(mc){
		
		Inter.traceInfo("")
		
		takeTile(mc)
		/*
		if(Key.isDown(46)){
			removeTile(mc)
		}else{
			takeTile(mc)
		}
		*/

	}
	
	static function removeTile(mc){
		tiles.remove(mc)
		mc.removeMovieClip();
		Inter.traceInfo("")
		mapUpdate();
	}
	
	static function takeTile(mc){
		var dx = Level.root._xmouse - mc._x ;
		var dy = Level.root._ymouse - mc._y;		
		
		Inter.setTile(mc.smc._currentframe)
		
		Inter.hand.dx = -dx
		Inter.hand.dy = -dy		
		
		if(!Key.isDown(17) ||  tiles.length==Inter.lim.tiles )removeTile(mc);
	}
	/*
	static function activateTiles(){
		for( var i=0; i<tiles.length; i++ ){
			var mc = tiles[i]
			mc.onPress = callback(Level,clickTile,mc)
			mc.useHandCursor = false
			Inter.setInfo(mc,"déplacer cette case")
		}
	}
	
	static function deactivateTiles(){
		for( var i=0; i<tiles.length; i++ ){
			var mc = tiles[i]
			mc.onPress = null
			mc.onRollOver = null
			mc.onRollOut = null
			mc.onDragOut = null
			mc.useHandCursor = false
		}
	}	
	*/
	// PLAT
	static function paintPlat(){

		if(Cs.game.root._ymouse < Cs.mch-Cs.INTERFACE_MARGIN ){
			
			var flMax = Inter.lim.plat == Inter.platNum+1
			if(Inter.hand.rid!=null){
				addPlat( Inter.hand._x, Inter.hand._y, Inter.hand.w, Inter.hand.rid, Inter.hand.rot, Inter.hand.bmp )
			}else if(Inter.hand.list!=null){
				addLine( Inter.hand._x, Inter.hand._y, Inter.hand.w, Inter.hand.list )
			}else{
				addArtwork(Inter.hand._x, Inter.hand._y,Inter.hand._xscale, Inter.hand._rotation,Inter.hand._currentframe)	
				flMax = Inter.artNum==3
			}
			if( !Key.isDown(17)  || flMax ){
				endPaint();
			}	
		}
	}

	static function addPlat(x,y,w,rid,rot,bmp){
		
		if(bmp==null)bmp = Lib.getPlatform(w,rid,rot,Level.did,true);
		var mc = downcast(pdm.empty(2))
		mc.attachBitmap(bmp,0)
		mc.bmp = bmp
		mc._x = int(x)
		mc._y = int(y)
		mc.w = w;
		mc.rid = rid;
		mc.rot = rot
		platforms.push(mc)
		Inter.platNum++;
		Inter.traceInfo("")
		mapUpdate();

	}

	static function removePlat(mc){
		if( mc.rid!=null || mc.list!=null ){
			Inter.platNum--;
		}else{
			Inter.artNum--;
			
		}
		platforms.remove(mc)
		mc.removeMovieClip();
		Inter.traceInfo("")
		mapUpdate();
	}
	
	static function takePlat(mc){
		var dx = Level.root._xmouse - mc._x ;
		var dy = Level.root._ymouse - mc._y;
		
		var flMax = Inter.lim.plat == Inter.platNum
		
		if(mc.rid!=null){
			Inter.setPlat(mc.w,mc.rid,mc.rot,mc.bmp)
		}else if( mc.list!=null){
			Inter.setLine(mc.w,mc.list,mc.bmp)
		}else{
			Inter.setArtwork( mc._xscale, mc._rotation, mc._currentframe )
			flMax = Inter.artNum==3
		}
		Inter.hand.dx = -dx
		Inter.hand.dy = -dy
		
		if(!Key.isDown(17) ||  flMax  )removePlat(mc);
		//platforms.remove(mc)
		//mc.removeMovieClip();
	}

	static function clickForPlat(){
		if(Cs.game.root._ymouse < Cs.mch-Cs.INTERFACE_MARGIN ){
			for( var i=0; i<platforms.length; i++ ){
				var mc = platforms[i];
				var xm  = mc._xmouse;
				var ym  = mc._ymouse;
	
				var flHit = null;
				if(mc.rid!=null || mc.list!=null ){
					flHit = mc.bmp.hitTest(new flash.geom.Point(0,0),1,new flash.geom.Point(xm,ym),null,null)
				}else{
					var p = Tools.localToGlobal(mc,xm,ym)
					flHit = mc.hitTest(p.x,p.y,true)
				}
				
				if( flHit ){
					if(Key.isDown(46)){
						removePlat(mc)
					}else{
						takePlat(mc)
					}
					break;
				}
			}
		}
	}
	
	// ARTWORK
	static function addArtwork(x,y,sc,rot,fr){
		var mc = downcast(pdm.attach("mcDecor",2))
		mc._x = int(x)
		mc._y = int(y)
		mc._xscale = sc;
		mc._yscale = sc;
		mc._rotation = rot
		mc.gotoAndStop(string(fr))
		platforms.push(mc)
		Inter.artNum++;
		Inter.traceInfo("")
		mapUpdate();
	}

	
	// ADDLINE
	static function addLine(x,y,w,list){
		var mc = downcast( pdm.empty(2) )
		var bmp = Lib.getLine(w,list,Level.did,true);
		mc.bmp = bmp
		mc.attachBitmap(bmp,0)
		mc.w = w
		mc.list = list
		mc._x = x
		mc._y = y
		platforms.push(mc)
		Inter.platNum++;
		Inter.traceInfo("")
		mapUpdate();
	}
	
		
	// PIOU
	static function addPiou(x,y,sens){
		
		var ny = getGround(x,y,null);
		if( ny == null )return false;
		
		var mc = edm.attach("mcPiou",DP_PIOU);
		mc._x = x;
		mc._y = ny
		mc._xscale = sens*100
		piouList.push(mc);
		Inter.traceInfo("")
		return true;
	}
	
	static function paintPiou(sens){
		//Log.trace("paint!")
		if(Cs.game.root._ymouse < Cs.mch-Cs.INTERFACE_MARGIN ){
			
			if( !addPiou(int( root._xmouse ),int( root._ymouse ),sens) )return;
			
			if( piouList.length == Inter.lim.piou ){
				Inter.initMode(Inter.mode)
			}else{
			
				if(!Key.isDown(17) || Inter.lim.piou == piouList.length ){
					endPaint();
				}
			}
		}		
	}
	
	static function clickPiou(mc){
		//Inter.traceInfo("")
		takePiou(mc)
	}
	
	static function takePiou(mc){

		var sens = int(mc._xscale/100)
		if( !Key.isDown(17) || Inter.lim.piou == piouList.length )removeElement(piouList,mc);
		Inter.setPiou(sens)
		
	}
	
	
	// OUT
	static function addOut(x,y){
		for( var i=0; i<outList.length; i++ ){
			var out = outList[i]
			if(  Math.abs(out._x-x) < 50 && Math.abs(out._y-y) < 50)return false
		}
		
		
		var mc = odm.attach("mcOut",DP_DECOR);
		var lim = 20
		mc._x = Cs.mm(lim,x,Level.width-lim);
		mc._y = Cs.mm(lim,y,Level.height-lim);
		outList.push(mc);
		Inter.traceInfo("")
		return true;
	}
	
	static function paintOut(){
		
		if(Cs.game.root._ymouse < Cs.mch-Cs.INTERFACE_MARGIN ){
			if( !addOut(int( root._xmouse ),int( root._ymouse )))return;
			
			if( outList.length == Inter.lim.out ){
				Inter.initMode(Inter.mode)
			}else{
			
				if(!Key.isDown(17) || Inter.lim.out == outList.length ){
					endPaint();
				}
			}			
		}
		
	}

	static function clickOut(mc){
		Inter.traceInfo("")
		takeOut(mc)
	}
	
	static function takeOut(mc){
		
		if( !Key.isDown(17) || Inter.lim.out == outList.length )removeElement(outList,mc);
		Inter.setOut()
	}	

	
	// CAISSE
	static function addCaisse(x,y,id,num){
		
		var ny = getGround(x,y,null);
		if( ny == null )return false;
		
		var mc = downcast(cdm.attach("mcCaisse",DP_PIOU));
		mc._x = x;
		mc._y = ny;
		mc.id = id;
		mc.num = num
	
		caisseList.push(mc);
		downcast(mc).str = " ( "+mc.num+"x "+Lang.actionName[mc.id]+")"
		//Log.trace(  "( "+mc.num+"x "+Lang.actionName[Inter.action[mc.id].id]+")" )
		
		// Inter.setInfo(mc," ( "+mc.num+"x "+Lang.actionName[mc.id]+")")
		
		return true;
	}
	
	static function paintCaisse(){
		if(Cs.game.root._ymouse < Cs.mch-Cs.INTERFACE_MARGIN ){
			var mmc = downcast(Inter.hand.mc)
			var o = Inter.action[mmc.id]
			addCaisse( int( root._xmouse ), int( root._ymouse ), mmc.id, o.num)
			o.num = 0
			Inter.updateActionSlot(mmc)
			endPaint();
		}
	}
	
	// 
	static function endPaint(){
		//Log.trace("endPaint!")
		Inter.traceInfo("")
		Inter.emptyHand();
		Cs.game.waitPress = null;
		Cs.game.waitRelease = null;
		switch(Inter.mode){
			case 0:
				activateList(tiles,callback(Level,clickTile),"déplacer cette case");
				break;
			case 1:
				Cs.game.waitPress = callback(Inter,startPlat,null,null);
				break;
			case 2:
				activateList(piouList,callback(Level,clickPiou),"déplacer ce piou")
				activateList(outList,callback(Level,clickOut),"déplacer cette sortie")			
				break;
			case 3:
				Level.activateList(Level.caisseList,callback(Level,removeElement,Level.caisseList),"détruire cette caisse")
				break;
		}
	}
	
	// CHECK
	static function isFree(x,y){
		var b = getSnapshot();
		return isBg( b.getPixel32(int(x),int(y)) )
		
	}
	
	static function getSnapshot(){
		if(pbmp==null){
			Inter.hand._visible = false;
			mcDecor.element._visible = false;
			mcDecor.out._visible = false;
			mcDecor.caisse._visible = false;
			pbmp = new flash.display.BitmapData(width,height,true,0x00000000);
			pbmp.drawMC(mcDecor,0,0)
			Inter.hand._visible = true;
			mcDecor.element._visible = true;
			mcDecor.out._visible = true;		
			mcDecor.caisse._visible = true;		
		}
		return pbmp
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
		return pc.a <= TOLERANCE
	}
		
	// RECAL ITEM
	static function mapUpdate(){
		recalItems();
	}

	static function getGround(x,y,me){
		var dy = 0
		while(isFree(x,y+dy+1)){
			dy++
			if(dy>40){
				dy = null
				break;
			}
		}
		if(dy!=null){
			while(!isFree(x,y+dy)){
				dy--
				if(dy<-60){
					dy = null
					break;
				}
			}
		}
		if(dy==null)return null;
		y+=dy	
		for( var i=0; i<piouList.length; i++ ){
			var piou = piouList[i]
			if( piou!=me && Math.abs(piou._y-y)<4 && Math.abs(piou._x-x)<4 )return null;
		}
		
		
			
		return y
	}

	static function recalItems(){
		for( var i=0; i<piouList.length; i++ ){
			var piou = piouList[i]
			var ny = getGround(piou._x,piou._y,piou)
			if(ny==null){
				piouList.splice(i--,1)
				piou.removeMovieClip();
			}else{
				piou._y = ny
			}
		}
		for( var i=0; i<caisseList.length; i++ ){
			var caisse = caisseList[i]
			var ny = getGround(caisse._x,caisse._y,caisse)
			if(ny==null){
				caisseList.splice(i--,1)
				caisse.removeMovieClip();
			}else{
				caisse._y = ny
			}			
			
		}	
	}
	
	// SHORTCUT
	static function moveAll(dx,dy){
		if(!Key.isDown(Key.SHIFT))return;
		/*
		static var tiles:Array<MovieClip>;
		static var platforms:Array<{>MovieClip,bmp:flash.display.BitmapData,w:int,rid:int,rot:int,list:Array<Array<int>>}>;
		static var piouList:Array<MovieClip>;
		static var outList:Array<MovieClip>;
		static var caisseList:Array<{>MovieClip,id:int,num:int}>;
		*/
		var mList:Array<Array<MovieClip>> = new Array()//[tiles,platforms,piouList,outList,caisseList]
		mList.push(Std.cast(tiles))
		mList.push(Std.cast(platforms))
		mList.push(Std.cast(piouList))
		mList.push(Std.cast(outList))
		mList.push(Std.cast(caisseList))
		for( var n=0; n<mList.length; n++ ){
			var list = mList[n]
			for( var i=0; i<list.length; i++ ){
				var mc = list[i]
				mc._x += dx
				mc._y += dy
			}
		}
	}
	
	// SAVE
	static function buildDaBigString(){
		var level = {
			tiles:[],
			platforms:[],
			piou:[],
			out:[],
			action:[],
			caisse:[],
			size:[width,height],
			did:did
		}


		for( var i=0; i<tiles.length; i++ ){
			var mc = tiles[i]
			level.tiles.push({x:Math.ceil(mc._x),y:Math.ceil(mc._y),id:mc.smc._currentframe-1})
		}
		
		for( var i=0; i<platforms.length; i++ ){
			var mc = platforms[i]
			
			if(mc.rid!=null){
				level.platforms.push( { x:Math.ceil(mc._x), y:Math.ceil(mc._y), w:mc.w, list:null, rid:mc.rid, rot:mc.rot } )
			}else if(mc.list!=null){
				level.platforms.push( { x:Math.ceil(mc._x), y:Math.ceil(mc._y), w:mc.w, list:mc.list, rid:null, rot:null } )
			}else{
				level.platforms.push( { x:Math.ceil(mc._x), y:Math.ceil(mc._y), w:int(mc._xscale),  list:null, rid:mc._currentframe, rot:int(mc._rotation) } )
			}
		}
		
		for( var i=0; i<piouList.length; i++ ){
			var mc = piouList[i]
			level.piou.push([Math.ceil(mc._x),Math.ceil(mc._y),int(mc._xscale/100)])
		}
		
		for( var i=0; i<outList.length; i++ ){
			var mc = outList[i]
			level.out.push( [Math.ceil(mc._x),Math.ceil(mc._y)] )
		}
		
		for( var i=0; i<Inter.action.length; i++ ){
			var o = Inter.action[i]
			level.action.push( [o.id,o.num] )
		}
		
		for( var i=0; i<caisseList.length; i++ ){
			var mc = caisseList[i]
			level.caisse.push( [Math.ceil(mc._x),Math.ceil(mc._y),mc.id,mc.num] )
		}		
		
		
		return new PersistCodec().encode(level)
		
		
		
		
	}
	
	static function drawGrid(){
		grid.fillRect(new flash.geom.Rectangle(0, 0, width, height), 0x00000000);
		if(Inter.snap==1)return;
		for( var x=0; x<width; x+=Inter.snap){
			grid.fillRect(new flash.geom.Rectangle(x, 0, 1, height), GRID_COLOR);
		}
		for( var y=0; y<height; y+=Inter.snap){
			grid.fillRect(new flash.geom.Rectangle(0, y, width, 1), GRID_COLOR);
		}
	}
	
	static function testText(){
		
		
		// TEXTURE
		var ts = 64
		var rect = new flash.geom.Rectangle(0,0,ts,ts)
		var text = new flash.display.BitmapData(ts,ts,true,0x50000000)
		var mct = dm.attach("mcText",0)
		text.drawMC(mct,0,0)
		mct.removeMovieClip();
		

		
		
		// MAPPING
		var map = new flash.display.BitmapData(width,height,true,0x00000000)
		for( var x=0; x<width; x+=ts ){
			for( var y=0; y<height; y+=ts ){
				map.copyPixels(text,rect,new flash.geom.Point(x,y),null,null,null);
			}
		}
		
		// MASK
		var mask = new flash.display.BitmapData(width,height,true,0x00FFFFFF)
		for( var i=0; i<40; i++ ){
			var mc = dm.attach("mcForm",0)
			mask.drawMC(mc,Std.random(width),Std.random(height))
			mc.removeMovieClip();
		}
		
		//
		
		grid.copyPixels( map, new flash.geom.Rectangle(0,0,width,height),new flash.geom.Point(0,0),mask,null,true )

	}		
	
	
	
	
//{
}