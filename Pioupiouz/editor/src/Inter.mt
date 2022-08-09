class Inter{//}

	//
	static var CI_DECOR = 	50
	static var CI_ACTION = 	100
	
	static var CI_ART = 	300
	static var CI_AVATAR = 	1000
	static var ART_MAX = 3
	static var CAISSE_MAX = 3
	
	//
	static var DP_MENU = 0
	static var DP_TILE = 1
	static var DP_BUT = 2
	static var DP_MINIMAP = 4
	
	static var UP_MARGIN = 22
	static var LEFT_MARGIN = 2// 80
	static var SS = 32
	
	static var PLAT_TIMER = 200
	static var ACTION_MAX = 10
	
	static var flButWait:bool;
	static var linePointList:Array<Array<int>>
	
	static var pageTile:int;
	static var pageDecor:int;
	static var palXMax:int;
	static var palYMax:int;
	static var platNum:int;
	static var artNum:int;
	static var lineColor:int;
	
	static var blurDecal:float;
	
	static var root:{>MovieClip,titleField:TextField,butTitle:MovieClip};
	static var dm:DepthManager;
	static var pList:Array<MovieClip>
	static var hand:{>MovieClip,dx:float,dy:float,w:int,rid:int,rot:int,bmp:flash.display.BitmapData,mc:MovieClip,list:Array<Array<int>>};
	static var minimap:{>MovieClip, timer:int, bmp:flash.display.BitmapData, screen:MovieClip };
	
		
	static var action:Array<{id:int,num:int}>
	static var lim:{
		action:Array<int>,
		decor:Array<int>,
		artwork:Array<int>,
		piou:int
		out:int
		tiles:int
		dim:int
		plat:int
		art:int
		caisse:int
		line:int
	}
	
	/*
	static var cLine:{
		w:int,
		list:Array<Array<int>>
	}
	*/
	
	static var platMode:int;
	static var snap:int;
	static var mode:int;
	static var chap:int;
	static var mcSelect:MovieClip;
	
	static var mcInit:{>MovieClip, 
		fieldDim:TextField,
		mcDecor:{>MovieClip, inside:MovieClip},
		butDimLeft:Button,
		butDimRight:Button,
		butDecLeft:Button,
		butDecRight:Button,
		butValidate:Button,
		indexDim:int,
		indexDec:int,
		$field0:TextField,
		$field1:TextField
	};
		
	static var cross:MovieClip;
	static var currentPlat:{>MovieClip,bmp:flash.display.BitmapData, w:int, rid:int, rot:int };

	static var mcSnap:{>MovieClip,field:TextField};
	static var mcArrowScroller:{>MovieClip, up:Button, down:Button}

	static var butList:Array<{>MovieClip, id:int, txt:String}>
	static var tabList:Array<{>MovieClip, txt:String}>;
	
	
	static function init(){
		root = downcast(Cs.game.mdm.attach("mcInterface",Game.DP_INTER));
		dm = new DepthManager(root);
		root._y = Cs.mch-Cs.INTERFACE_MARGIN;
		if(Cs.CAB)root.cacheAsBitmap = true;
		downcast(root).obj = Inter
		snap = SS
		//
		initRoot();

		flButWait = false;
		//
		action = new Array();
		for( var i=0; i<ACTION_MAX; i++){
			var id = 0
			var num = 0
			if(i<7){
				id=i;
				num=1;
			}
			action.push({id:id,num:num})
		}
		//
		lineColor = 0xFFFFFF
		//
		pageTile = 0;
		pageDecor = 0;
		
		platNum = 0
		artNum = 0
		mode = 4
		
		palXMax = int( (Cs.mcw-LEFT_MARGIN)/SS );
		palYMax = int( (Cs.INTERFACE_MARGIN-36)/SS );
		
		
		//
		blurDecal = 0
	}
	
	static function initRoot(){
		root.butTitle.onPress = callback(Inter,incMode)
		setInfo(root.butTitle,"changer de mode")
		
		// BUTTONS
		for( var i=0; i<4; i++ ){
			
			var mc = downcast(dm.attach("mcButStandard",DP_BUT))
			mc._x = Cs.mcw - (105*(i+1))
			mc._y = Cs.INTERFACE_MARGIN -19
			mc.txt = Lang.interButName[i]
			mc.id = i
			if(i!=2){
				mc.onPress = callback(Inter,activeBut,mc)
				mc.onRollOver = callback(mc,gotoAndStop,"2")
				mc.onRollOut = callback(mc,gotoAndStop,"1") 
				mc.onReleaseOutside = callback(mc,gotoAndStop,"1") 
				mc.onRelease = callback(mc,gotoAndStop,"2") 
				
			}else{
				mc._alpha = 50
			}
			mc.stop();
		}
		
		// TABS
		tabList = new Array();
		for( var i=0; i<5; i++ ){
			var mc = downcast( dm.attach("butTab",DP_BUT) )
			mc._x = i*59
			mc.txt = Lang.MODE[i]
			mc.stop();
			tabList.push(mc)
		}
		//updateTabs();
		
	}
	
	static function updateTabs(){
		for( var i=0; i<tabList.length; i++ ){
			var mc = tabList[i];
			if(i==mode){
				mc.onPress = null
				mc.onRollOver = null
				mc.onRollOut = null
				mc.onReleaseOutside = null
				mc.onRelease = null
				mc.useHandCursor = false;
				mc.gotoAndStop("3")
			}else{
				mc.onPress = callback(Inter,initMode,i)
				mc.onRollOver = callback(mc,gotoAndStop,"2")
				mc.onRollOut = callback(mc,gotoAndStop,"1") 
				mc.onReleaseOutside = callback(mc,gotoAndStop,"1") 
				mc.onRelease = callback(mc,gotoAndStop,"2")
				mc.useHandCursor = true;	
				mc.gotoAndStop("1")
			}
		}
	}
	
	static function activeBut(mc){
		//Log.trace("activeBut bordel!("+flButWait+")")
		if(flButWait)return;
		mc.gotoAndStop("3")
		switch(mc.id){
			case 0:
				Cs.game.redirect( downcast(Std.getRoot()).$exitUrl )
				flButWait = true;
				break;
			case 1:
				if( Cs.game.saveData( Level.buildDaBigString() ) ){	
					Cs.game.saveData( Level.buildDaBigString() )
					Cs.game.flGotoTestMode = true;
				}else{
					Cs.game.redirect( downcast(Std.getRoot()).$testUrl );
				}
				flButWait = true;
				break;
			case 2:
				Cs.game.redirect( downcast(Std.getRoot()).$selfUrl )
				flButWait = true;
				break;
			case 3:
				if( Cs.game.saveData( Level.buildDaBigString() ) ){
					flButWait = true;
				}
				break;
		}
		
		
		
	}
	//
	static function displayDecor(){
		
		pList = new Array();

		var x = 0
		var y = 0
		for( var i=0; i<lim.artwork.length; i++ ){
			
			var bmc = dm.attach("mcEditSquare",DP_TILE)
			bmc._x = LEFT_MARGIN + x*SS;
			bmc._y = UP_MARGIN + y*SS;
			
			var mc = Std.attachMC(bmc,"mcDecor",0);
			var frame = int(lim.artwork[i])+1
			mc.gotoAndStop(string(frame))
			//
			formatMc(mc)
			

			
			//
			bmc.onPress = callback(Inter,selectDecor,mc)
			setInfo(bmc,"sélectionner ce décor")
			pList.push(bmc)
			//
			downcast(bmc).sub = mc;
			x++
			if(x==palXMax){
				x=0
				y++
			}
		}
		
		dm.over(mcSelect)
		

	}
	
	static function displayTiles(){
		
		
		
		Level.drawGrid();
		//
		var idMap = getTilesIdMap(); 
		
		//
		pList = new Array();
		var id = pageTile*palXMax;
		for( var y=0; y<palYMax; y++ ){
			for( var x=0; x<palXMax; x++ ){
				
				var bmc = dm.attach("mcEditSquare",DP_TILE)
				bmc._x = LEFT_MARGIN + x*SS;
				bmc._y = UP_MARGIN + y*SS;
				
				var mc =  Std.attachMC(bmc,"mcTile",0);//dm.attach("mcTile",DP_TILE);
				mc.gotoAndStop(string(Level.did+1))
				mc.smc.gotoAndStop(string(idMap[id]+1))
				

				downcast(bmc).sub = mc;
				id++;
				var max = int(Math.min( mc.smc._totalframes, getTileMax() ))

				if(mc.smc._width==0 && mc.smc._height==0 ){
					x--;
					bmc.removeMovieClip();
				}else{
					formatMc(mc)
					bmc.onPress = callback(Inter,setTile,mc.smc._currentframe);
					setInfo(bmc,"sélectionner cette case");
					pList.push(bmc);
				}
				
				if(id==max)return;
			}
		}
	}
	

	static function formatMc(mc){
		var c = SS / mc._width
		if( mc._height > mc._width ) c = SS / mc._height;
		
		c = Math.min(c,1)
		
		mc._xscale = c*100
		mc._yscale = c*100
		
		var b = mc.getBounds(mc._parent);
		
		mc._x = -b.xMin
		mc._y = -b.yMin	
		
		mc._x += (SS-mc._width)*0.5
		mc._y += (SS-mc._height)*0.5
		
	}
	
	static function cleanPal(){
		while(pList.length>0)pList.pop().removeMovieClip();
	}
	
	//
	static function setTile(fr){
		if(mode==0){
			if(Level.tiles.length<lim.tiles){
				setHand("mcTile",Level.did+1,fr)
				Cs.game.waitPress = callback(Level,paintTile)
				Level.deactivateList(Level.tiles)
			}else{
				Inter.traceInfo("maximum atteint !")
			}
		}

	}
	
	static function setPlat(w,rid,rot,bmp){
		hand = downcast(Level.dm.empty(Level.DP_HAND))
		hand.attachBitmap(bmp,0)
		var b = hand.getBounds(hand);
		hand.dx = -(b.xMin+b.xMax)*0.5
		hand.dy = -(b.yMin+b.yMax)*0.5
		hand.w = w;
		hand.rid = rid
		hand.rot = rot
		hand.bmp = bmp;
		hand._x = Cs.game.root._xmouse+hand.dx
		hand._y = Cs.game.root._ymouse+hand.dy
		Cs.game.waitPress = callback(Level,paintPlat)
		Cs.game.waitRelease = null
		
	}
	
	static function setArtwork(sc,rot,fr){
		hand = downcast(Level.dm.attach("mcDecor",Level.DP_HAND))
		var b = hand.getBounds(hand);
		hand.dx = -(b.xMin+b.xMax)*0.5
		hand.dy = -(b.yMin+b.yMax)*0.5
		hand._rotation = rot;
		hand._xscale = sc;
		hand._yscale = sc;
		hand.gotoAndStop(string(fr))
		hand._x = Cs.game.root._xmouse+hand.dx
		hand._y = Cs.game.root._ymouse+hand.dy
		Cs.game.waitPress = callback(Level,paintPlat)
		Cs.game.waitRelease = null
	}
	
	static function setLine(w,list,bmp){
		hand = downcast(Level.dm.empty(Level.DP_HAND))
		hand.attachBitmap(bmp,0)
		var b = hand.getBounds(hand);
		hand.dx = -(b.xMin+b.xMax)*0.5
		hand.dy = -(b.yMin+b.yMax)*0.5
		hand.w = w;
		hand.list = list
		hand._x = Cs.game.root._xmouse+hand.dx
		hand._y = Cs.game.root._ymouse+hand.dy
		Cs.game.waitPress = callback(Level,paintPlat)
		Cs.game.waitRelease = null
	}
	
	static function selectDecor(mc){

		var fr = mc._currentframe-1

		platMode = fr;
		
		Cs.game.waitPress = callback(Inter,startPlat,null,null)
		mcSelect._x = mc._parent._x
		mcSelect._y = mc._parent._y
	}
	
	static function setHand(link,fr,fr2){
		emptyHand();
		hand = downcast(Level.dm.attach(link,Level.DP_HAND));
		hand.gotoAndStop(string(fr))
		hand.smc.gotoAndStop(string(fr2))
		var b = hand.getBounds(hand);
		hand.dx = -(b.xMin+b.xMax)*0.5
		hand.dy = -(b.yMin+b.yMax)*0.5
		hand._y = -1000
		hand._y = -1000		
	}
	
	static function emptyHand(){
		//hand.bmp.dispose();
		hand.removeMovieClip();
		hand = null
	}
	
	//
	static function update(){

		if(lineColor==0xFFFFFF){
			lineColor=0x88FF88
		}else{
			lineColor=0xFFFFFF
		}
		//
		Level.mcDraw.clear();
		Level.pbmp.dispose();
		Level.pbmp = null;
		
		// GLOW
		blurDecal = (blurDecal+33*Timer.tmod)%628;
		if( hand!=null ){
			var px = Math.round((Level.root._xmouse + hand.dx)/snap)*snap
			var py = Math.round((Level.root._ymouse + hand.dy)/snap)*snap
			hand._x = px
			hand._y = py
			
			var n = Math.abs(Math.cos(blurDecal/100)*5)
			var fl = new flash.filters.GlowFilter();
			fl.blurX = n
			fl.blurY = n
			fl.color = 0xFFFFFF
			hand.filters = [fl]
		}
		
		// CROSS
		if( cross!=null && Cs.game.pressTimer > PLAT_TIMER ){
			updatePlat();
		}
		
		// MINIMAP
		if(minimap!=null)updateMinimap();
		
		
	}
	
	// PLATFORM
	static function startPlat(px,py){
		if( Cs.game.root._ymouse < Cs.mch-Cs.INTERFACE_MARGIN || Key.isDown(17) ){
			if(px==null)px=Level.root._xmouse;
			if(py==null)py=Level.root._ymouse;
			cross = Level.dm.attach("mcCross",Level.DP_ICON)
			cross._x = px
			cross._y = py
			cross._visible = false;
			Cs.game.waitRelease = callback(Inter,endPlat,false);
		}
	}
	
	static function updatePlat(){
	
		if( currentPlat==null ){
			switch(platMode){
				case 0:
					if(platNum==lim.plat){
						traceInfo("maximum atteint !")
						break;
					}
					currentPlat = downcast(Level.pdm.empty(2))
					currentPlat.rid = Cs.ARTWORK_MAX+Std.random(1000)
					cross._visible = true;
					break;
				case 1 :
					if(platNum==lim.plat){
						traceInfo("maximum atteint !")
						break;
					}
					currentPlat = downcast(Level.pdm.empty(2))
					currentPlat._x = cross._x
					currentPlat._y = cross._y
					if(linePointList==null){
						linePointList = [[int(cross._x),int(cross._y)]];
					}else{
						//cross._x = linePointList[0][0]
						//cross._y = linePointList[0][1]
					}
					cross._visible = true;
					break;
				default:
					if(artNum==lim.art){
						traceInfo("maximum atteint !")
						break;
					}
					currentPlat = downcast(Level.pdm.attach("mcDecor",2))
					currentPlat.gotoAndStop(string(platMode+1))
					currentPlat._x = cross._x
					currentPlat._y = cross._y
					cross._visible = true;
					break;
			}
			
		}
		
		if( currentPlat!=null ){
			var o = {x:cross._x,y:cross._y}
			var o2 = {x:Level.root._xmouse,y:Level.root._ymouse}
			var w = int(Cs.getDist(o,o2))*2
			var a = Cs.getAng(o,o2)
			
			w = int(Cs.mm(30,w,600))
			switch(platMode){
				case 0:
					
					currentPlat.bmp.dispose();
					var rot = int(a/0.0174)
					currentPlat.bmp = Lib.getPlatform(w,currentPlat.rid,rot,Level.did,false);
					currentPlat.attachBitmap(currentPlat.bmp,0)
					currentPlat._x = cross._x - currentPlat._width*0.5
					currentPlat._y = cross._y - currentPlat._height*0.5// - currentPlat._height*0.5
					currentPlat.w = w;
					currentPlat.rot = rot;
					
					break;
				case 1:
					if( w!= currentPlat.w  ){
						currentPlat.w = w;
					}
					break;
				default:
					var sc = -w*0.2
					currentPlat.rot = int(a/0.0174)
					currentPlat._rotation = currentPlat.rot
					currentPlat._xscale = sc
					currentPlat._yscale = sc
					currentPlat.w = w;
					break;
			}
			
			// GUIDE
			var dx = -Math.cos(a)*w*0.5
			var dy = -Math.sin(a)*w*0.5
			if( platMode == 1 ){
				for( var n=0; n<2; n++ ){
					var p = linePointList[0].duplicate();
					Level.mcDraw.lineStyle(7-n*5,lineColor,20+n*55)
					Level.mcDraw.moveTo( p[0],p[1] )
					for( var i=1; i<linePointList.length; i++ ){
						var m = linePointList[i]
						p[0] += m[0]
						p[1] += m[1]
						Level.mcDraw.lineTo(p[0]p[1])
					}
				}
				
				Level.mcDraw.lineStyle(7,lineColor,20)
				Level.mcDraw.moveTo(currentPlat._x,currentPlat._y)
				Level.mcDraw.lineTo(currentPlat._x+dx,currentPlat._y+dy)
				Level.mcDraw.lineStyle(2,lineColor,75)
				Level.mcDraw.moveTo(currentPlat._x,currentPlat._y)
				Level.mcDraw.lineTo(currentPlat._x+dx,currentPlat._y+dy)
				
			}else{	
				Level.mcDraw.lineStyle(7,lineColor,20)
				Level.mcDraw.moveTo(cross._x-dx,cross._y-dy)
				Level.mcDraw.lineTo(cross._x+dx,cross._y+dy)
				Level.mcDraw.lineStyle(2,lineColor,75)
				Level.mcDraw.moveTo(cross._x-dx,cross._y-dy)
				Level.mcDraw.lineTo(cross._x+dx,cross._y+dy)
			}

			

		}
	}

	static function endPlat(flKey:bool){
		
	
		cross.removeMovieClip();
		cross = null
		if( Cs.game.pressTimer<=PLAT_TIMER && !flKey ){
	
			Level.clickForPlat();
		}else{
			if(currentPlat.w!=null){
				
				if(platMode==0){
					Level.addPlat( currentPlat._x, currentPlat._y, currentPlat.w, currentPlat.rid, currentPlat.rot, null );
					
				}else if(platMode==1){

					var o = {x:currentPlat._x,y:currentPlat._y}
					var o2 = {x:Level.root._xmouse,y:Level.root._ymouse}
					var a = Cs.getAng(o2,o)
					var px = currentPlat._x + Math.cos(a)*currentPlat.w*0.5
					var py = currentPlat._y + Math.sin(a)*currentPlat.w*0.5
					var lastLinePoint = linePointList[0].duplicate();
					
					for( var i=1; i<linePointList.length; i++){
						lastLinePoint[0] += linePointList[i][0]
						lastLinePoint[1] += linePointList[i][1]
					}
					var x = px - lastLinePoint[0]
					var y = py - lastLinePoint[1]
					linePointList.push([int(x),int(y)])
					
					if(!flKey || linePointList.length >  lim.line){
						var first = linePointList.shift();
						var w = 36
						var mx = -w*0.5
						var my = -w*0.5
						var p = [0,0]
						for( var i=0; i<linePointList.length; i++ ){
							var m = linePointList[i]
							p[0] += m[0];
							p[1] += m[1];	
							mx = Math.min(mx,(p[0]-w*0.5) )
							my = Math.min(my,(p[1]-w*0.5) )
						
						}
						
						
						Level.addLine( first[0]+mx, first[1]+my, w, linePointList );
						linePointList = null;
					}else{
						Inter.startPlat(px,py);
					}
				}else{
					Level.addArtwork( currentPlat._x, currentPlat._y, currentPlat._xscale, currentPlat._rotation, currentPlat._currentframe )
				}
			}
			currentPlat.removeMovieClip();
			currentPlat = null
		}
		Inter.traceInfo("")
	}
	

	// OBJ
	static function displayObj(){
		pList = new Array();
		var xMax = int((Cs.mcw-LEFT_MARGIN)/SS);
		var yMax = int(Cs.mch/SS);
		var id = 1;
		for( var y=0; y<yMax; y++ ){
			for( var x=0; x<xMax; x++ ){
				var flAttach = true;
				if( (id==1 || id==2) && Level.piouList.length == lim.piou ) flAttach = false;
				if( id==3 && Level.outList.length == lim.out ) flAttach = false;
				if(flAttach){
					var mc = dm.attach("mcObj",DP_TILE);
					mc._x = LEFT_MARGIN + x*SS;
					mc._y = UP_MARGIN + y*SS;
					mc.gotoAndStop(string(id+1))
					mc.onPress = callback(Inter,selectObj,mc)
					pList.push(mc)
				}else{
					x--
				}
				id++;
				if(id==4)return;
			}
		}
	}
	
	static function selectObj(mc){
		switch(chap){
			case 0:	// QUIT DELETE
				/*
				Level.deactivateList(Level.piouList)
				Level.deactivateList(Level.outList)
				*/
				break;
			case 1: // QUIT PIOU
			case 2: // QUIT PIOU
				traceInfo("")
				break;
			case 3: // QUIT SORTIE
				traceInfo("")
				break;			
		}
		emptyHand();
		chap = mc._currentframe-1;
		Cs.game.waitPress = null;
		switch(chap){
			case 0:	// DELETE
				/*
				Level.activateList(Level.piouList,callback(Level,removeElement,Level.piouList),"détruire ce piou-piou")
				Level.activateList(Level.outList,callback(Level,removeElement,Level.outList),"détruire cette sortie")
				*/
				break;
			case 1:
			case 2:
				if( Level.piouList.length < lim.piou ){
					setPiou((chap-1)*2-1);
				}else{
					traceInfo("plus assez de piou disponible !")
				}
				break;
			case 3:
	
				setOut();

				break;	
		}
		//mcSelect._x = mc._x;
		//mcSelect._y = mc._y;
	}
	
	static function setPiou(sens){
		//Log.trace("setPiou!")
		setHand("mcPiou",1,null)
		hand._xscale = sens*100
		Cs.game.waitPress = callback(Level,paintPiou,sens)
		traceInfo("placer un nouveau piou")	
	}

	static function setOut(){
		setHand("mcOut",1,null)
		Cs.game.waitPress = callback(Level,paintOut)
		traceInfo("placer un nouvelle sortie")
	}
	
	// ACTION
	static function displayAction(){
		pList = new Array();
		var xMax = int((Cs.mcw-LEFT_MARGIN)/SS);
		var yMax = int(Cs.mch/SS);
		var ss = 50
		var m = ((Cs.mcw-10)-(ACTION_MAX*50))/(ACTION_MAX-1)
		for( var i=0; i<ACTION_MAX; i++ ){
			var mc = dm.attach("mcActionSelector",DP_TILE);
			mc._x = 3+LEFT_MARGIN + i*(ss+m);
			mc._y = UP_MARGIN+8
			var mmc = downcast(mc)
			mmc.obj = Inter;
			mmc.id = i;
			mmc.img = Std.attachMC(mc,"mcActionSlot",0)
			mmc.img._x = 10
			mmc.mcCaisse.onPress = callback(Inter,setCaisse,mmc)
			updateActionSlot(mmc)
			pList.push(mc)
		}
	
	}
	
	static function updateActionSlot(mc){
		var o = action[mc.id]
		mc.img.gotoAndStop(string(o.id+1))
		mc.img.txt = o.num
		if(o.num>0){
			mc.gotoAndStop("2")
			mc.mcCaisse.onPress = callback(Inter,setCaisse,mc)
			mc.mcCaisse.useHandCursor = true;
		}else{
			mc.gotoAndStop("1")
			mc.mcCaisse.onPress = null
			mc.mcCaisse.useHandCursor = false;
		}
	}
	
	static function incActionType(mc,inc){
		var o = action[mc.id]
		
		
		for( var i=0; i<Level.caisseList.length; i++){
			var c = Level.caisseList[i]
			if( c.id == mc.id ){
				traceInfo("caisse présente!")
				return;
			}
		}
		
		o.id = getNextAvailableAction(o.id,inc)
		o.num = int(Math.min( o.num, o.num+getActionLim(o.id) ))
		updateActionSlot(mc)
	}
	
	static function incActionNum(mc,inc){
		var o = action[mc.id]
		o.num = int(Cs.mm( 0, o.num+inc, o.num+getActionLim(o.id) ) )
		updateActionSlot(mc)
	}
	
	static function getNextAvailableAction(id,inc){
		var t = 0
		
		while(true){
			id = Cs.sMod(id+inc,lim.action.length)
			if( lim.action[id]>0 ) return id;
			if(t++>100){
				Log.trace("getNextAvailableAction ERROR !")
				break;
			}
		}
		return null;
	}
	
	static function getActionLim(id){
		var lim = lim.action[id]
		for( var i=0; i<Level.caisseList.length; i++){
			var o = Level.caisseList[i]
			if( action[o.id].id == id ){
				lim -= o.num;
			}
		}
		for( var i=0; i<action.length; i++){
			if( action[i].id == id ){
				lim -= action[i].num;
			}
		}		
		return lim;
	}
	
	static function setCaisse(mc){
		if(Level.caisseList.length == lim.caisse ){
			traceInfo("maximum atteint!")
			return;
		}
		
		setHand("mcCaisse",1,null)
		hand.mc = mc
		
		Cs.game.waitPress = callback(Level,paintCaisse)
		Level.deactivateList(Level.caisseList)
	}
	
	// MODES
	static function initMode(n:int){
		emptyHand();
		Cs.game.waitPress = null;
		Cs.game.waitRelease = null;
		switch(mode){
			case 0: // QUIT TILE
				cleanPal();
				mcSnap.removeMovieClip();
				mcArrowScroller.removeMovieClip();
				snap = 1				Level.deactivateList(Level.tiles)
				//
				fadeOut(Level.mcDecor.tile)
				fadeOut(Level.mcDecor.tileFront)
				break;
			
			case 1: // QUIT PLAT EDIT
				mcSelect.removeMovieClip();
				mcArrowScroller.removeMovieClip();
				cleanPal();
				fadeOut(Level.mcDecor.plat)		
				break;
			
			case 2:	// QUIT OBJ
				//mcSelect.removeMovieClip();
				selectObj(null)
				cleanPal();
				Level.deactivateList(Level.piouList)
				Level.deactivateList(Level.outList)				
				fadeOut( Level.mcDecor.element )
				fadeOut( Level.mcDecor.out )
				break;
			case 3: // QUIT ACTION
				Level.deactivateList(Level.caisseList)
				cleanPal();
				fadeOut( Level.mcDecor.caisse )	
				break;
			case 4: // QUIT GENERAL
				fadeOut(Cs.game.bg)
				fadeOut(Level.mcDecor.tile)
				fadeOut(Level.mcDecor.tileFront)
				fadeOut(Level.mcDecor.plat)
				fadeOut( Level.mcDecor.element )
				fadeOut( Level.mcDecor.out )			
				fadeOut( Level.mcDecor.caisse )	
				break;
		}
		mode = n
		switch(mode){
			case 0:// MODE TILE
				initSnap();
				initArrowScroller();
				displayTiles();
				snap = 1
				multiSnap(1);
				Level.activateList(Level.tiles,callback(Level,clickTile),"déplacer cette case")
				fadeIn(Level.mcDecor.tile)			
				fadeIn(Level.mcDecor.tileFront)			
				break;
			
			case 1: // MODE PLAT EDIT
				initArrowScroller();	
				displayDecor();
				mcSelect = dm.attach("mcSelect",DP_TILE);
				selectDecor(downcast(pList[0]).sub)
				fadeIn(Level.mcDecor.plat)	
				break;
			
			case 2:	// MODE OBJ
				displayObj()
				//mcSelect = dm.attach("mcSelect",DP_TILE);
				//selectObj(pList[0])
				Level.activateList(Level.piouList,callback(Level,clickPiou),"déplacer ce piou")
				Level.activateList(Level.outList,callback(Level,clickOut),"déplacer cette sortie")
				fadeIn( Level.mcDecor.element )
				fadeIn( Level.mcDecor.out )
				break
			
			case 3:	// MODE ACTION
				displayAction()
				Level.activateList(Level.caisseList,callback(Level,removeElement,Level.caisseList),"détruire cette caisse")
				fadeIn( Level.mcDecor.caisse )					
				break
			case 4: // MODE GENERAL
				fadeIn(Cs.game.bg)
				fadeIn(Level.mcDecor.tile)
				fadeIn(Level.mcDecor.plat)
				fadeIn(Level.mcDecor.tileFront)	
				fadeIn( Level.mcDecor.element )
				fadeIn( Level.mcDecor.out )	
				fadeIn( Level.mcDecor.caisse )
				break;
		}	
		
		//
		updateTabs()
		traceInfo("")
		Level.drawGrid();
	}
	
	static function incMode(){
		initMode( (mode+1)%Lang.MODE.length )
	}
	
	static function fadeOut(mmc){
		var mc = Std.cast(mmc)
		if(mc.fade==null)mc.fade = 0;
		mc.sens = 1
		Cs.game.fadeList.remove(mc)
		Cs.game.fadeList.push(mc)
	}
	
	static function fadeIn(mmc){
		var mc = Std.cast(mmc)
		if(mc.fade==null)mc.fade = 1;
		mc.sens = -1
		Cs.game.fadeList.remove(mc)
		Cs.game.fadeList.push(mc)
	}	
	
	// SNAP
	static function initSnap(){
		mcSnap = downcast(dm.attach("mcSnap",DP_MENU))
		mcSnap.onPress = callback(Inter,multiSnap,2)
		mcSnap._x = Cs.mcw-40
		mcSnap._y = 2.5
	}
	
	static function multiSnap(mul){
		snap*=mul
		if(snap==128)snap=1;
		if(snap==2)snap=8;
		mcSnap.field.text = "$x".substring(1)+string(snap);
		mcSnap.play();
		Level.drawGrid();
	}

	static function initArrowScroller(){
		mcArrowScroller = downcast( dm.attach("mcArrowScroller",DP_MENU) )
		mcArrowScroller.up.onPress = callback(Inter,incPage,-1)
		mcArrowScroller.down.onPress = callback(Inter,incPage,1)
		var dec = -100
		if(mode==1)dec = -50
		mcArrowScroller._x = Cs.mcw+dec
		mcArrowScroller._y = 2.5
	}
	
	static function incPage(inc){
		cleanPal();
		switch(mode){
			case 0:

				pageTile = int( Cs.mm( 0, pageTile+inc, Math.ceil(getTileMax()/palXMax)-palYMax ))
				displayTiles();
				//Log.trace(int(tileMax/palXMax))
				break;
			case 1:
				pageDecor = int(Cs.mm( 0, pageDecor+inc,  int(lim.decor.length/palXMax)-palYMax ))
				displayDecor();
				break;
		}
		
	}
	
	// INFOS
	static function setInfo(mc,str){
		mc.onRollOver = callback(Inter,traceInfo,str)
		mc.onRollOut = callback(Inter,traceInfo,"")
		mc.onDragOut = mc.onRollOut
	
	}
	
	static function traceInfo(str){
		if(str.length>1)str = " - "+str
		str=""
		root.titleField.text = getTitle()+str
	}
	
	static function getTitle(){
		var title = ""//Lang.MODE[mode]	
		switch(mode){
			case 0:
				title += Lang.wordEditor[0]+"("+Level.tiles.length+"/"+lim.tiles+")"
				break;
			case 1:
				title += Lang.wordEditor[1]+"("+platNum+"/"+lim.plat+") -"+Lang.wordEditor[2]+"("+artNum+"/"+lim.art+")"
				break;
			case 2:
				title += Lang.wordEditor[3]+"("+Level.piouList.length+"/"+lim.piou+") -"+Lang.wordEditor[4]+"("+Level.outList.length+"/"+lim.out+")"
				break;
			case 3:
				title += Lang.wordEditor[5]+"("+Level.caisseList.length+"/"+lim.caisse+")"
				break;
		}
		return title;
	}
	

	// MINIMAP
	static function initMinimap(){

		minimap = downcast(dm.empty(DP_MINIMAP))
		minimap.bmp = Level.getSnapshot().clone()
		
		var ws = Std.attachMC(minimap,"mcWhiteSquare",0)
		ws._xscale = minimap.bmp.width;
		ws._yscale = minimap.bmp.height;
		ws._alpha = 60
		
		
		minimap.attachBitmap( minimap.bmp, 1 )
		minimap.screen = Std.attachMC(minimap,"mcScreenCadre",2)

		var m = 5;
		minimap._width = 150;
		minimap._yscale = minimap._xscale;
		minimap._x = m;
		minimap._y = -( minimap._height + m );
		
	}
	
	static function updateMinimap(){
		minimap.timer--
		if(minimap.timer<0){
			minimap.bmp.dispose();
			minimap.removeMovieClip();
			minimap = null;
			
		}else if(minimap.timer<10){
			minimap._alpha = minimap.timer*10;
		}
		
		minimap.screen._x = -Level.root._x
		minimap.screen._y = -Level.root._y
		
	}
	
	// LIMITES
	static function initLim(cards){
		
		lim = {
			action:[]
			decor:[]
			artwork:[0,1]
			tiles:0
			piou:0
			out:0
			dim:0
			plat:0
			art:3
			caisse:3
			line:4
		}
		
		for( var i=0; i<cards.length; i++ ){
			var a = cards[i]
			var id = a[0]
			var n = a[1]
			
			if( id < CI_DECOR ){
				
				if(id==0)lim.piou += n;
				if(id==1)lim.out += n;
				if(id==2)lim.tiles += n;
				if(id==3)lim.dim += n;
				if(id==4)lim.plat += n;
			}else if( id < CI_ACTION ){
				lim.decor[id-CI_DECOR] = n

			}else if( id < CI_ART ){
				lim.action[id-CI_ACTION] = n
				
			}else if( id< CI_AVATAR ){
				lim.artwork.push((id-CI_ART)+9)
			}
			
			
		}
	}
	
	static function getTileMax(){
		return 120+lim.decor[Level.did]*15
	}
	
	// ID MAP
	static function getTilesIdMap(){
		var a = new Array()
		switch( Level.did ){
			case 0:
				pushIdMap(a,0,19);	// START
				pushIdMap(a,169,179)	// PIERRE JAUNES	
				pushIdMap(a,102,114);	// PLANCHE AVANCEES
				pushIdMap(a,137,156)	// RACINES 1
				pushIdMap(a,180,212)	// RACINES 2
				pushIdMap(a,79,101)	// DECO 1
				pushIdMap(a,157,161)	// DECO 2
				pushIdMap(a,75,78)	// MINI FALAISES
				pushIdMap(a,134,136)	// ARBRES 
				pushIdMap(a,220,223);	// ONE WAY HERB
				pushIdMap(a,131,133);	// PIERRE GRISES 1
				pushIdMap(a,162,168);	// PIERRE GRISES 2
				pushIdMap(a,224,227);	// PIERRE GRISES 3
				pushIdMap(a,115,130);	// TEMPLE JAUNE
				pushIdMap(a,213,219);	// FLEURS GEANTES
				pushIdMap(a,228,229);	// TOILE ARRAIGNEE
				pushIdMap(a,230,243);	// DEATH
				pushIdMap(a,20,74)	// PLANCHE SET
				pushIdMap(a,20,74)	// PLANCHE SET
				pushIdMap(a,244,248)	// SAUCISSON
				pushIdMap(a,249,251)	// PAIN DE MIE
				pushIdMap(a,252,255)	// NAPPE
				while(a.length<300)	a.push(9);
				break;
			default:
				for( var i=0; i<300; i++)a[i]=i;
				break;
		}
		return a 
	}
	
	static function pushIdMap(a,start,end){
		for( var i=start; i<=end; i++ )a.push(i);
	}
		
	
	// INIT
	static function initPanel(){
		mcInit = downcast(Cs.game.mdm.attach("mcInterfaceInit",1));
		mcInit.indexDim = 0;
		mcInit.indexDec = 0;
		mcInit.butDimLeft.onPress = callback(Inter,incDim,-1)
		mcInit.butDimRight.onPress = callback(Inter,incDim,1)
		mcInit.butDecLeft.onPress = callback(Inter,incDec,-1)
		mcInit.butDecRight.onPress = callback(Inter,incDec,1)
		mcInit.butValidate.onPress = callback(Inter,initLevel)

		for( var i=0; i<2; i++ ){
			var field = Std.getVar(mcInit,"$field"+i)
			field.text = Lang.initEditor[i]
		}
		
		
		incDim(0)
		incDec(0)
		
	}
	
	static function incDim(inc){
		mcInit.indexDim = Cs.sMod(mcInit.indexDim+inc,lim.dim)
		var d = Cs.DIM[mcInit.indexDim].duplicate();
		
		for( var i=0; i<d.length; i++ )d[i] = Math.ceil(d[i]/150)
		mcInit.fieldDim.text = d[0]+"$x".substring(1)+d[1]
		
	}
	
	static function incDec(inc){
		var a = new Array();
		for( var i=0; i<lim.decor.length; i++ ){
			if( lim.decor[i] != null )a.push(i)
		}
		
		
		mcInit.indexDec = Cs.sMod(mcInit.indexDec+inc,a.length)
		
		var pan = mcInit.mcDecor.inside
		var did = a[mcInit.indexDec]
		
		var dec = Std.attachMC(pan,"bg",0)
		dec.gotoAndStop(string(did+1))
		
		var plat = Std.createEmptyMC(pan,1)
		var bmp = Lib.getPlatform(140,12345,0,did,true)
		plat.attachBitmap(bmp,0)
		plat._y = 70 - plat._height*0.5

	}
	
	static function initLevel(){
		var a = new Array();
		for( var i=0; i<lim.decor.length; i++ ){
			if( lim.decor[i] != null )a.push(i)
		}
		
		Level.did = a[mcInit.indexDec]
		var d = Cs.DIM[mcInit.indexDim].duplicate();
		Cs.game.level = {
			tiles:[],
			platforms:[],
			piou:[],
			out:[],
			caisse:[],
			action:[],
			size:d,
			did:Level.did
		}
		
		Cs.game.initStep(1)
		mcInit.removeMovieClip();
	}
	
	
	/*
		GRISAGE ON / OFF
		SCROLL ON / OFF
		
	*/
	

//{
}


