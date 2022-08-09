class game.Ray extends Game{//}
	
	// CONSTANTES
	var mDir:Array<Array<int>>
	var dir:Array<{x:int,y:int}>
	var mx:float;
	var my:float;
	var xMax:int;
	var yMax:int;
	var size:float;
	
	//var loop_t:int;
	
	// VARIABLES
	var depthRun:int;
	var rh:float;
	var ball:{x:int,y:int,id:int}
	var baz:{x:int,y:int,id:int}
	var mList:Array<{mc:MovieClip,x:int,y:int,id:int,dl:Array<{x:int,y:int}>}>
	var grid:Array<Array<{>MovieClip,id:int}>>
	var iList:Array<MovieClip>
	
	// MOVIECLIPS
	var ray:MovieClip;
	var frontRay:MovieClip;
	var mcBall:MovieClip;
	var mcBase:MovieClip;

	function new(){
		super();
	}

	function init(){
		gameTime = 500
		super.init();
		
		mDir = [
			[ null,	null,	1,	0 ],
			[ 1,	null,	null,	2 ],
			[ 3,	2,	null,	null ],
			[ null,	0,	3,	null ]
		
		]
		dir = [
			{x:0,y:-1},
			{x:1,y:0},
			{x:0,y:1},
			{x:-1,y:0}
		
		]
			
		xMax = 8
		yMax = 8
		size = 24
		rh = 15*size/100
		mx = (Cs.mcw-xMax*size)*0.5
		my = (Cs.mch-yMax*size)*0.5			
		
		iList = new Array();
			
		genLevel();
		shuffleLevel();
		attachElements();
			
		traceLight();
	};
	
	function attachElements(){
		
		// DAMIER
		for( var x=0; x<xMax; x++){
			for( var y=0; y<yMax; y++){
				var mc = dm.attach( "mcRayCase", Game.DP_SPRITE )
				mc._x = getX(x)
				mc._y = getY(y)
				mc._xscale = size
				mc._yscale = size
			}		
		}
		// RAY
		ray = dm.empty(Game.DP_SPRITE)			

		// MIRROR
		grid = new Array();
		for( var x = 0; x<xMax; x++){
			grid[x] = new Array();
			for( var y = 0; y<yMax; y++){
				grid[x][y] = null
			}
		}
		for( var i=0; i<mList.length; i++ ){
			var o = mList[i]
			var mc = downcast(getElement(o.x,o.y))
			mc.gotoAndStop(string(o.id+1))
			mc.id = o.id
			initButton(mc)	
			
			if( i<mList.length-1){

			}else{

			}
			mList[i].mc = upcast(mc);
			grid[o.x][o.y] = mc
		}

		// BALL
		mcBall = getElement(ball.x,ball.y)
		mcBall.gotoAndStop("5")
		grid[ball.x][ball.y] = downcast(mcBall)

		// BASE
		mcBase = getElement(baz.x,baz.y)
		mcBase.gotoAndStop("6")
	
		// REORDONNE
		for(var x=0; x<xMax; x++ ){
			for(var y=0; y<yMax; y++ ){
				var mc = grid[x][y]
				if(mc!=null) dm.over(mc);
			}		
		}
		
		// RAY
		frontRay = dm.empty(Game.DP_SPRITE)	
		

		
	}
	
	function getElement(x,y){
		var mc = dm.attach("mcRayElement",Game.DP_SPRITE)
		mc._xscale = size
		mc._yscale = size
		mc._x = getX(x)
		mc._y = getY(y)	
		return mc;
	}
	
	function genLevel(){
	
		
		var a = Std.random(4)//3//mDir[mList[0].id][3]
		var x = null
		var y = null
		switch(a){
			case 0:
				x=Std.random(xMax)
				y=yMax
				break;
			case 1:
				x=-1
				y=Std.random(yMax)
				break;
			case 2:
				x=Std.random(xMax)
				y=-1
				break;
			case 3:
				x=xMax
				y=Std.random(yMax)			
				break;			
		}
		//a = 3 
		mList = [
			{ x:x, y:y, id:0, mc:null, dl:[] }
		]			
		
	

		getRange(a, int(5+dif*0.1) )
		
		var o = mList.pop()
		ball = {x:o.x,y:o.y,id:o.id}
		
		var o2 = mList.shift();
		baz = {x:o2.x,y:o2.y,id:o2.id}
	
		var m = mList[0]
		for( var i=0; i<o.dl.length; i++ ) m.dl.push(o.dl[i]);	// GROS GROS HACK CRASSEUX
		for( var i=0; i<o2.dl.length; i++ ) m.dl.push(o2.dl[i]);// GROS GROS HACK CRASSEUX

	}
	
	function shuffleLevel(){
		for( var i=0; i<mList.length; i++ ){
			var o = mList[i]
			o.id = Std.random(4)
		}
		
		var free = getFreePosList()
		var max =  Math.ceil(free.length*0.2*(dif*0.01))
		for( var i=0; i<max; i++ ){
			var index = Std.random(free.length)
			var p = free[index]
			free.splice(index,1)
			mList.push({mc:null,x:p.x,y:p.y,id:Std.random(4),dl:[]})
			
		}
		
	}
	
	function getFreePosList(){
		var list = new Array()
		for( var x = 0; x<xMax; x++){
			list[x] = new Array();
			for( var y = 0; y<yMax; y++){
				list[x][y] = true
			}
		}
		
		for(var i=0; i<mList.length; i++ ){
			var o = mList[i]
			list[o.x][o.y] = false;
			for( var n=0; n<o.dl.length; n++ ){
				var p = o.dl[n]
				list[p.x][p.y] = false;
				//var mc = dm.attach("mcMark",20)
				//mc._x = getX(p.x+0.5)
				//mc._y = getY(p.y+0.5)
			}
		}
		
		list[ball.x][ball.y] = false;
		
		var fl = new Array();
		
		for( var x = 0; x<xMax; x++){
			for( var y = 0; y<yMax; y++){
				if(list[x][y])fl.push({x:x,y:y});
			}
		}
		
		return fl;
	}
	
	
	// deadList:Array<{x:int,y:int}>
	
	function getRange(a:int,max:int):bool{

		//Log.trace("-")
		var last = mList[mList.length-1]
		var cList = new Array();
		var n = 0
		var d = dir[a]
		while(true){
			n++
			var c = { x:last.x+n*d.x, y:last.y+n*d.y }  
			//Log.trace(c.x+";"+c.y)
			var flPush = true
			var flBreak = c.x >= xMax || c.y >= yMax || c.x < 0 || c.y < 0
			for( var i=0; i<mList.length; i++ ){
				var m = mList[i]
				if( m.x == c.x && m.y == c.y ){
					///Log.trace("bam!")
					flBreak = true
					break;
				}

				for( var k=0; k<m.dl.length; k++ ){
					var dc = m.dl[k]
					if( dc.x == c.x && dc.y == c.y ){
						//Log.trace("bam!")
						flPush = false
						break;
					}
				}
			}
			if(flBreak){
				break;
			}else{
				if(flPush)cList.push(c);
			}
			
			if(n>10){
				Log.trace("ERROR cList")
				break;
			}
			
		}
		//*
		
		if( cList.length == 0 ){
			//Log.trace("XXX ")
			return false;
		}
		
		//var index = Math.floor(cList.length*0.5)+Std.random(Math.ceil(cList.length*0.5))
		
		// DUPLICATE var pList = cList.duplicate();
		var pList = new Array()
		for(var i=0; i<cList.length; i++ ){
			var p = cList[i]
			pList[i] = {x:p.x,y:p.y}
		}
		//
		
		var t = 0
		//var tv = cList.length
		while( pList.length > 1 ){
		
			var index = 1+Std.random((pList.length-1))
			var dl = new Array();
			var c = pList[index]
			var im = 0;
			while( true){
				dl.push(cList[im])
				im++
				if(cList[im].x == c.x && cList[im].y == c.y )break;
			}			
			
			pList.splice(index,1)
			
			var ta = Std.random(2)//*2-1
			for( var i=0; i<2; i++ ){
				if(i==1)ta = 1-ta
				
				var o = {
					x:c.x
					y:c.y
					id:getMod(a+ta+1)
					dl:dl
					mc:null
				}
				
				mList.push(o)
				
				if( mList.length == max ){
					o.id = getMod(a+2)
					//Log.trace("last pos!")
					return true
				}else{
					if( getRange(getMod(a-(ta*2-1)), max ) ){
						return true;
					}else{
						mList.pop();
						//Log.trace(c.x+";"+c.y+" : retired ("+ta+")")
					}
				}
			}
			
			if(t++>10){
				Log.trace("loop infinie : erreur de test de position!")
				return false;
			}
			
		}
		//*/
		
		return false;
		

	}
	
	function getMod(id){
		while(id<0)id+=4
		while(id>=4)id-=4
		return id;
	}
	
	
	function update(){
		switch(step){
			case 1:

				break;
		}
		
		super.update();
	}
	
	function traceLight(){
		
		depthRun = 0
		
		ray.clear();
		while(iList.length>0){
			iList.pop().removeMovieClip();
		}
		
		ray.lineStyle(4,0xFFFFFF,50)
		ray.moveTo(getX(ball.x+0.5),getY(ball.y+0.5)-rh )
		traceRay( ball.x, ball.y, ball.id )
		
	}
	
	function traceRay(x:int,y:int,di:int){
		//Log.trace("traceRay! ("+x+","+y+")")	
		var d = dir[di]
		do{
			x += d.x
			y += d.y
		}while( grid[x][y] == null && inBound(x,y,0) )
		
		if( x == baz.x && y == baz.y)setWin(true);
		
		var px = getX(x+0.5)
		var py = getY(y+0.5)-rh
		/*
		if( !inBound(x,y,0) ){
			px-=(d.x*size*0.5)
			py-=(d.y*size*0.5)
		}
		*/
		
		

		var link = ray
		var ppr = di*90+90
		var ppxs =  20
		var ppys =  20
		
		var flCenter = false;
		
		if( di == 0)link = frontRay;

		var mc = grid[x][y]
		var tr = null
		var ndi = null
		if( mc.id < 4 ){
			ndi = mDir[mc.id][di]
			if( ndi != null ){
							
				var indi = (ndi+2)%4
				var dif = indi-di
				
				if(dif>2)dif-=4;
				if(dif<-2)dif+=4;
				
				ppr += dif*45
				ppxs = 10
				ppys = 50
				flCenter = true
				if( indi == 0)link = frontRay;
			}
		}
		
		if(!flCenter){
			px-=(d.x*size*0.5)
			py-=(d.y*size*0.5)
		}
		ray.lineTo(px,py)
		
		
		var de = depthRun++
		var p = Std.attachMC(link,"mcLightImpact",de)
		p._x = px
		p._y = py
		p._xscale = ppxs
		p._yscale = ppys
		p._rotation = ppr
		//p._alpha = 50
		iList.push(p)
		
		if(ndi!=null)traceRay(x,y,ndi);
		
		
	}
	
	
	function select(mc){
		mc.id = (mc.id+1)%4
		mc.gotoAndStop(string(mc.id+1))
		traceLight();
	}

	function initButton(mc){
		var me = this;
		mc.onPress = fun(){
			me.select(mc)
		}	
	}
	
	/*
	function setWin(flag){
		for( var i=0; i<mList.length; i++ ){
			mList[i].mc.onPress = null;
		}
		super.setWin(flag)
	}
	*/
	function inBound(x,y,m){
		return x >= m && x<xMax-m && y >= m && y <yMax-m
	}
	
	function getX(x){
		return mx + x*size
	}
	
	function getY(y){
		return my + y*size
	}	
	
//{	
}













