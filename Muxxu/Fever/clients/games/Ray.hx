class RayElement {
	public var mc:McRayElement;
	public var x:Int;
	public var y:Int;
	public var id:Int;
	public var dl:Array < { x:Int, y:Int }>;
	
	public function new(x, y, id=0) {
		this.x = x;
		this.y = y;
		this.id = id;
		mc=null;
		dl=[];
	}
}




class Ray extends Game{//}

	// CONSTANTES
	var mDir:Array<Array<Null<Int>>>;
	var dir:Array<{x:Int,y:Int}>;
	var mx:Float;
	var my:Float;
	var xMax:Int;
	var yMax:Int;
	var size:Float;

	// VARIABLES
	var depthRun:Int;
	var rh:Float;
	var ball:{x:Int,y:Int,id:Int};
	var baz:{x:Int,y:Int,id:Int};
	var mList:Array<RayElement>;
	var grid:Array<Array<Dynamic>>;
	var iList:Array<flash.display.MovieClip>;

	// MOVIECLIPS
	var ray:flash.display.MovieClip;
	var frontRay:flash.display.MovieClip;
	var mcBall:flash.display.MovieClip;
	var mcBase:flash.display.MovieClip;

	override function init(dif){
		gameTime = 500;
		super.init(dif);

		mDir = [
			[ null,	null,	1,	0 ],
			[ 1,	null,	null,	2 ],
			[ 3,	2,	null,	null ],
			[ null,	0,	3,	null ]

		];
		dir = [
			{x:0,y:-1},
			{x:1,y:0},
			{x:0,y:1},
			{x:-1,y:0}

		];

		xMax = 8;
		yMax = 8;
		size = 22;
		rh = 15*size/100;
		mx = (Cs.omcw-xMax*size)*0.5;
		my = (Cs.omch-yMax*size)*0.5;

		iList = new Array();

		genLevel();
		shuffleLevel();
		#if dev
		//userLevel();
		//gameTime = 200000;
		#end
		
		attachElements();

		traceLight();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("ray_bg",0);

		// DAMIER
		for( x in 0...xMax ){
			for( y in 0...yMax ){
				var mc = dm.attach( "mcRayCase", Game.DP_SPRITE );
				mc.x = getX(x);
				mc.y = getY(y);
				mc.scaleX = size*0.01;
				mc.scaleY = size*0.01;
				mc.gotoAndStop(Std.random(mc.totalFrames)+1);
			}
		}
		// RAY
		ray = dm.empty(Game.DP_SPRITE);

		// MIRROR
		grid = new Array();
		for( x in 0...xMax ){
			grid[x] = new Array();
			for( y in 0...yMax )grid[x][y] = null;
		}
		var i = 0;
		for( o in mList ){
			var mc = cast(getElement(o.x, o.y));
			var mmc:flash.display.MovieClip = cast mc;
			mmc.gotoAndStop(o.id+1);
			mc.id = o.id;
			initButton(cast mc);
			mList[i].mc = cast(mc);
			grid[o.x][o.y] = cast mc;
			i++;
		}

		// BALL
		mcBall = getElement(ball.x,ball.y);
		mcBall.gotoAndStop("5");
		grid[ball.x][ball.y] = cast(mcBall);

		// BASE
		mcBase = getElement(baz.x,baz.y);
		mcBase.gotoAndStop("6");

		// REORDONNE
		for( x in 0...xMax ){
			for( y in 0...yMax ){
				var mc = grid[x][y];
				if(mc!=null) dm.over(mc);
			}
		}

		// RAY
		frontRay = dm.empty(Game.DP_SPRITE);

	}

	function getElement(x,y){
		var mc = dm.attach("McRayElement",Game.DP_SPRITE);
		mc.scaleX = size*0.01;
		mc.scaleY = size*0.01;
		mc.x = getX(x);
		mc.y = getY(y);
		return mc;
	}

	function genLevel(){


		var a = Std.random(4);//3//mDir[mList[0].id][3]
		var x = 0;
		var y = 0;
		switch(a){
			case 0:
				x=Std.random(xMax);
				y=yMax;

			case 1:
				x=-1;
				y=Std.random(yMax);

			case 2:
				x=Std.random(xMax);
				y=-1;

			case 3:
				x=xMax;
				y=Std.random(yMax);

		}
		//a = 3
		var re = new RayElement(x,y);
		mList = [re];



		getRange(a, Std.int(5+dif*10) );

		var o = mList.pop();
		ball = {x:o.x,y:o.y,id:o.id}

		var o2 = mList.shift();
		baz = {x:o2.x,y:o2.y,id:o2.id}

		var m = mList[0];
		for( i in 0...o.dl.length) m.dl.push(o.dl[i]);	// GROS GROS HACK CRASSEUX
		for( i in 0...o2.dl.length ) m.dl.push(o2.dl[i]);// GROS GROS HACK CRASSEUX

	}

	function shuffleLevel(){
		for( o in mList )o.id = Std.random(4);

		var free = getFreePosList();
		var max =  Math.ceil(free.length*0.2*dif);
		for( i in 0...max ){
			var index = Std.random(free.length);
			var p = free[index];
			free.splice(index, 1);
			
			var re = new RayElement(p.x, p.y, Std.random(4));
			mList.push(re);

		}

	}

	function getFreePosList(){
		var list = new Array();
		for( x in 0...xMax ){
			list[x] = new Array();
			for( y in 0...yMax )list[x][y] = true;
		}

		for( o in mList ){
			list[o.x][o.y] = false;
			for( p in o.dl )list[p.x][p.y] = false;
		}

		list[ball.x][ball.y] = false;

		var fl = new Array();

		for( x in 0...xMax ){
			for( y in 0...yMax ){
				if(list[x][y])fl.push({x:x,y:y});
			}
		}

		return fl;
	}


	function getRange(a:Int,max:Int):Bool{

		//Log.trace("-")
		var last = mList[mList.length-1];
		var cList = new Array();
		var n = 0;
		var d = dir[a];
		while(true){
			n++;
			var c = { x:last.x+n*d.x, y:last.y+n*d.y };

			var flPush = true;
			var flBreak = c.x >= xMax || c.y >= yMax || c.x < 0 || c.y < 0;
			for( m in mList ){
				if( m.x == c.x && m.y == c.y ){
		
					flBreak = true;
					break;
				}

				for( dc in m.dl ){
					if( dc.x == c.x && dc.y == c.y ){
						flPush = false;
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
				//trace("ERROR cList");
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
		var pList = new Array();
		for( p in cList )pList.push({x:p.x,y:p.y});
		//

		var t = 0;
		//var tv = cList.length
		while( pList.length > 1 ){

			var index = 1+Std.random((pList.length-1));
			var dl = new Array();
			var c = pList[index];
			var im = 0;
			while( true){
				dl.push(cList[im]);
				im++;
				if(cList[im].x == c.x && cList[im].y == c.y )break;
			}

			pList.splice(index,1);

			var ta = Std.random(2);
			for( i in 0...2 ){
				if(i==1)ta = 1-ta;

				/*
				var o = {
					x:c.x,
					y:c.y,
					id:getMod(a+ta+1),
					dl:dl,
					mc:null,
				}
				*/
				var o = new RayElement(c.x, c.y, getMod(a + ta + 1));
				o.dl = dl;

				mList.push(o);

				if( mList.length == max ){
					o.id = getMod(a+2);
					return true;
				}else{
					if( getRange(getMod(a-(ta*2-1)), max ) ){
						return true;
					}else{
						mList.pop();
					}
				}
			}

			if(t++>10){
				//trace("loop infinie : erreur de test de position!");
				return false;
			}

		}
		//*/

		return false;


	}

	function getMod(id){
		while(id<0)id+=4;
		while(id>=4)id-=4;
		return id;
	}


	override function update(){
		super.update();
	}

	function traceLight(){

		depthRun = 0;

		ray.graphics.clear();
		while(iList.length > 0) {
			var mc = iList.pop();
			mc.parent.removeChild(mc);
		}

		ray.graphics.lineStyle(4,0xFFFFFF,50);
		ray.graphics.moveTo(getX(ball.x+0.5),getY(ball.y+0.5)-rh );
		traceRay( ball.x, ball.y, ball.id );

	}

	function traceRay(x:Int,y:Int,di:Int){

		var d = dir[di];
		do{
			x += d.x;
			y += d.y;
		}while(  inBound(x, y, 0)  && grid[x][y] == null );
		

		if( x == baz.x && y == baz.y) {
			var mc:McRayElement = cast mcBase;
			if( mc.smc != null ) {
				mc.smc.play();
				setWin(true, 20);
			}
		}else if( !inBound(x,y, 0) ){
			x += d.x * 4;
			y += d.y * 4;
		}

		var px = getX(x+0.5);
		var py = getY(y+0.5)-rh;


		var link = ray;
		var ppr = di*90+90;
		var ppxs =  20;
		var ppys =  20;

		var flCenter = false;

		if( di == 0)link = frontRay;

		
		
		var mc = null;
		if( inBound(x, y, 0) ) mc = grid[x][y];
		var tr = null;
		var ndi:Null<Int> = null;
		
		if(  mc!=null && mc.id < 4 ){
			ndi = mDir[mc.id][di];
			if( ndi != null ){

				var indi = (ndi+2)%4;
				var dif = indi-di;

				if(dif>2)dif-=4;
				if(dif<-2)dif+=4;

				ppr += dif*45;
				ppxs = 10;
				ppys = 50;
				flCenter = true;
				if( indi == 0)link = frontRay;
			}
		}
		

		if(!flCenter){
			px-=(d.x*size*0.5);
			py-=(d.y*size*0.5);
		}
		ray.graphics.lineTo(px,py);


		var de = depthRun++;
		var p = new mt.DepthManager(link).attach("mcLightImpact",de);
		p.x = px;
		p.y = py;
		p.scaleX = ppxs*0.01;
		p.scaleY = ppys*0.01;
		p.rotation = ppr;
		iList.push(p);

		if(ndi!=null && !( x == ball.x && y == ball.y ) )traceRay(x,y,ndi);


	}


	function select(mc){
		mc.id = (mc.id + 1) % 4;
		var mmc:flash.display.MovieClip = cast mc;
		mmc.gotoAndStop(mc.id+1);
		traceLight();
	}

	function initButton(mc){
		var me = this;
		var mmc:flash.display.MovieClip = cast mc;
		mmc.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(e) { me.select(mc); } );
		
	}

	function inBound(x,y,m){
		return x >= m && x<xMax-m && y >= m && y <yMax-m;
	}

	function getX(x:Float){
		return mx + x*size;
	}

	function getY(y:Float){
		return my + y*size;
	}

	//
	#if dev
	function userLevel() {
		
		var lvl = [
			0, 1, 0, 0, 0, 0, 0, 0,
			1, 0, 1, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 1, 0, 0,
			1, 0, 0, 1, 0, 0, 0, 0,
			1, 0, 0, 0, 1, 0, 0, 0,
			0, 1, 0, 1, 0, 0, 0, 0,
			1, 0, 0, 1, 0, 0, 0, 0,
			0, 1, 0, 0, 1, 0, 0, 0,
		];
		
		mList = [];
		for( i in 0...xMax * yMax) {
			var x = i % xMax;
			var y = Std.int(i / xMax);
			var e = new RayElement(x, y);
			if(lvl[i]==1)mList.push(e);
		}
		
		ball = { x:2, y:4, id:0 };
		
		
	}
	#end
	
	
//{
}













