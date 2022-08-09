class Game {//}




	static var DP_FRUIT = 2;
	static var DP_PART = 3;

	static var BLAST_TIME = 6
	static var FALL_WAIT = 20
	static var HAND_SPEED_COEF = 0.3

	static var FL_ENLIGHT = true;


	var step:int;
	var turn:KKConst;
	var bonus:KKConst;
	var timer:float;
	var glowDec:float;

	var zlim:{xmin:float,xmax:float,ymin:float,ymax:float}

	var zone:Array<{x:int,y:int}>
	var sel:Array<Array<{x:int,y:int}>>
	var dList:Array<{x:int,y:int}>

	var dm:DepthManager;
	var gdm:DepthManager;

	var pList:Array<MovieClip>;
	var glow:Array<MovieClip>;
	var fList:Array<Part>;
	var sList:Array<Sprite>;
	var bg:MovieClip;
	var map:MovieClip;
	var blob:Blob;

	var stats:{}

	var grid:Array<Array<{>MovieClip,flDead:bool}>>


	function new(mc) {
		Cs.init();
		Cs.game = this

		gdm = new DepthManager(mc);
		map = gdm.attach("mcWallpaper",1)


		dm = new DepthManager(map);
		bg = gdm.attach("mcBg",0)

		sList = new Array();
		pList = new Array();
		fList = new Array();
		glow = new Array();
		zone = new Array();

		glowDec = 0

		initGrid();
		turn = Cs.TURN;

		zlim = {xmin:99,ymin:99,xmax:-99,ymax:-99}

		var mid = int(Cs.GRID_MAX*0.5)

		var zm = 0
		for( var x=mid-zm; x<=mid+zm; x++ ){
			for( var y=mid-zm; y<=mid+zm; y++ ){
				free(x,y)
			}
		}


		blob = new Blob(gdm.attach("mcBlob",3));
		blob.x = (mid+0.5)*Cs.SIZE
		blob.y = (mid+0.5)*Cs.SIZE
		blob.updateSize();

		map.setMask(blob.root)

		initStep(0)



	}

	function initGrid(){
		grid = new Array();
		for( var x=0; x<Cs.GRID_MAX; x++ ){
			grid[x] = new Array();
			for( var y=0; y<Cs.GRID_MAX; y++ ){
				var mc = downcast(dm.attach("mcFruit",DP_FRUIT));
				mc._x = (x+0.5)*Cs.SIZE;
				mc._y = (y+0.5)*Cs.SIZE;
				mc.flDead = false;
				grid[x][y] = mc;
				var id = getRandomId();
				mc.gotoAndStop(string(id+1))


				/*
				var bmp = new flash.display.BitmapData(Cs.SIZE,Cs.SIZE,true,0x00000000);
				var base = dm.attach("mcFruit",0)
				var m = new flash.geom.Matrix()
				m.tx = Cs.SIZE*0.5
				m.ty = Cs.SIZE*0.5
				bmp.draw(base,m, null, null, null, null )
				mc.attachBitmap(bmp,1)
				*/
			}
		}



	}

	function initStep(s:int){
		step = s;

		switch(step){
			case 0: // CHOICE
				initSel();
				break;

			case 1:	// DESTROY
				timer = Cs.TIME_EXPLODE
				break;

			case 2: // ISOLATE

				if(dList.length==0){
					initStep(0);
					break
				}else{
					timer = Cs.TIME_FALL
					dList = getIsolateList();
					for( var i=0; i<dList.length; i++ ){
						var pos = dList[i]
						var mc = grid[pos.x][pos.y]
						var p = new Part(gdm.attach("mcFruit",8));
						p.x = mc._x
						p.y = mc._y
						p.weight = 0.4 + Math.random()*0.4
						p.root.gotoAndStop(string(mc._currentframe))
						free(pos.x,pos.y)
						fList.push(p)
					}
				}




				break;

			case 9: // ENDGAME
				timer = 4
				blob.tsx = 0
				blob.tsy = 0
				break


		}

	}

	function main() {
		timer-=Timer.tmod;
		switch(step){
			case 0: // CHOICE
				break;

			case 1: // DESTROY
				var prc = (1-timer/Cs.TIME_EXPLODE)*100
				var list = new Array();

				for( var i=0; i<dList.length; i++ ){

					var p = dList[i];
					var mc = grid[p.x][p.y]
					if(prc<100){
						Cs.setPercentColor(mc,prc,0xFFFFFF);
						mc._xscale = 100-prc
						mc._yscale = 100-prc
					}else{
						addChain(p.x,p.y,list)
						var ball = grid[p.x][p.y]
						blast(ball)
						KKApi.addScore(KKApi.cadd(Cs.SCORE_BALL,bonus))
						free(p.x,p.y)
					}
				}
				if(timer<0){
					blob.updateSize();
					if(list.length>0){
						dList = list;
						bonus = KKApi.cadd(Cs.SCORE_BONUS,bonus)
						initStep(1)
					}else{
						initStep(2)
					}
				}
				break;
			case 2: // ISOLATE
				/*
				var prc = (timer/Cs.TIME_FALL)*100
				for( var i=0; i<dList.length; i++ ){
					var p = dList[i];
					var mc = grid[p.x][p.y]
					if(prc>0){
						mc._xscale = prc
						mc._yscale = prc
					}else{
						var ball = grid[p.x][p.y]
						blast(ball)
						//KKApi.addScore(Cs.SCORE[ball._currentframe-1])
						free(p.x,p.y)
					}
				}
				*/


				if(timer<0){
					if(KKApi.val(turn)>0){
						initStep(0)
					}else{
						initStep(9)
					}
				}
				break;
			case 9:
				if(timer<0 && fList.length==0){
					KKApi.gameOver(stats)
					initStep(10)
				}
				break;

		}

		// SPRITES
		var list = sList.duplicate();
		for( var i=0; i<list.length;i++){
			list[i].update();
		}

		// FALL
		for( var i=0; i<fList.length; i++ ){
			var p = fList[i]
			if(p.y>Cs.mch+Cs.SIZE){
				p.kill();
				fList.splice(i--,1)
				KKApi.addScore(Cs.SCORE_FALL)
			}
		}

		// GLOW
		glowDec = (glowDec+47)%628
		var prc = 50+Math.cos(glowDec/100)*30
		for( var i=0; i<glow.length; i++ ){
			var mc = glow[i]
			Cs.setPercentColor(mc,prc,0xFFFFFF)
		}

	}

	function initSel(){
		var done = new Array()
		for( var x=0; x<Cs.GRID_MAX; x++ )done[x] = new Array();
		sel = new Array();
		for( var i=0; i<10; i++ )sel[i] = new Array();
		for( var i=0; i<zone.length; i++ ){
			var p = zone[i];
			for( var n=0; n<Cs.DIR.length; n++ ){
				var d = Cs.DIR[n]
				var nx = d[0] + p.x
				var ny = d[1] + p.y
				if( done[nx][ny] == null ){
					done[nx][ny] = true;
					var mc = grid[nx][ny]
					if(  mc != null ){
						var id = mc._currentframe-1
						sel[id].push({x:nx,y:ny})
						mc.onPress = callback(this,select,id)
						mc.onRollOver = callback(this,enlight,id);
						mc.onRollOut = callback(this,delight,id);
						mc.onDragOut = callback(this,delight,id);
						mc.useHandCursor = true;
						KKApi.registerButton(mc);
					}
				}
			}
		}
	}

	function emptySel(){
		while(sel.length>0){
			var list = sel.pop()
			while(list.length>0){
				var p = list.pop();
				var mc = grid[p.x][p.y]
				mc.onPress = null
				mc.onRollOver = null
				mc.onRollOut = null
				mc.onDragOut = null
				mc.useHandCursor = false;
				KKApi.registerButton(mc);


			}
		}
		sel = new Array();
	}

	function select(id){
		dList = sel[id].duplicate();
		for( var i=0; i<dList.length; i++ ){
			var p = dList[i]
			grid[p.x][p.y].flDead = true
		}
		/*
		for( var i=0; i<dList.length; i++ ){
			var p = dList[i]
			free(p.x,p.y)
		}
		*/
		emptySel();
		turn = KKApi.cadd(turn, Cs.DEC_TURN)
		blob.panel.field.text = string(KKApi.val(turn))
		//blob.turnList.pop().removeMovieClip();;
		bonus = KKApi.const(0)
		initStep(1)

	}

	function enlight(id){
		var list = sel[id]
		for( var i=0; i<list.length; i++ ){
			var p = list[i]
			var mc = grid[p.x][p.y]
			glow.push(mc)
		}

	}

	function delight(id){
		for( var i=0; i<glow.length; i++ ){
			var mc = glow[i]
			Cs.setPercentColor(mc,0,0xFFFFFF)
			glow.splice(i--,1)
		}
	}

	//
	function addChain(x,y,list){
		var base = grid[x][y]
		for( var i=0; i<Cs.DIR.length; i++ ){
			var d = Cs.DIR[i]
			var nx = x+d[0]
			var ny = y+d[1]
			var mc = grid[nx][ny]
			if( mc._currentframe == base._currentframe && !mc.flDead ){
				list.push({x:nx,y:ny})
				mc.flDead = true;
			}
		}
	}

	function free(x,y){
		zone.push({x:x,y:y})
		zlim.xmin = Math.min( zlim.xmin, x )
		zlim.ymin = Math.min( zlim.ymin, y )
		zlim.xmax = Math.max( zlim.xmax, x )
		zlim.ymax = Math.max( zlim.ymax, y )
		grid[x][y].removeMovieClip();
		grid[x][y] = null;

	}

	function getRandomId(){
		var rnd = Std.random(Cs.PROB_SUM)
		var sum = 0
		for( var i=0; i<Cs.PROB.length; i++ ){
			sum +=Cs.PROB[i]
			if(sum>=rnd)return i;
		}
		Log.trace("RANDOM ID ERROR")
		return null;
	}

	//
	function eat(base){

		/*
		var max = Math.min( 50/dList.length, 12 )
		for( var i=0; i<max; i++ ){
			var p = new Part(dm.attach("partRotSpark",DP_PART))
			var a  = Math.random()*6.28
			var sp = 2+Math.random()*3
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var ray = Cs.SIZE*0.4
			p.x = base._x + ca*ray
			p.y = base._y + sa*ray
			p.vx = ca*sp;
			p.vy = sa*sp;
			p.vr = (Math.random()*2-1)*30
			p.timer = 10+Math.random()*10
			p.frict = 0.92
			downcast(p.root).sub._x = Math.random()*10
		}
		*/
	}

	function blast(base){
		var max = Math.min( 60/dList.length, 12 )
		for( var i=0; i<max; i++ ){
			var p = new Part(dm.attach("partRotSpark",DP_PART))
			var a  = Math.random()*6.28
			var sp = 2+Math.random()*3
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.vr = (Math.random()*2-1)*30
			p.timer = 10+Math.random()*10
			p.frict = 0.92
			var dist = Math.random()*10
			downcast(p.root).sub._x = dist
			var na = Math.random()*6.28
			p.root._rotation = na/0.0174
			p.x = base._x  - Math.cos(na)*dist
			p.y = base._y  - Math.sin(na)*dist
		}
	}

	//
	function getIsolateList(){
		var safe = new Array()
		for( var x=0; x<Cs.GRID_MAX; x++ ){
			safe[x] = new Array();
			for( var y=0; y<Cs.GRID_MAX; y++ ){
				if( grid[x][y] !=null && ( x==0 || x==Cs.GRID_MAX-1 || y==0 || y==Cs.GRID_MAX-1 ) && grid[x][y]!=null ){
					safe[x][y] = true
				}

			}
		}

		for( var x=1; x<Cs.GRID_MAX-1; x++ ){
			for( var y=1; y<Cs.GRID_MAX-1; y++ ){
				if(safe[x][y]==null){
					var list = []
					var verdict = findWay(x,y,safe,list)
					for( var i=0; i<list.length; i++ ){
						var p = list[i]
						safe[p.x][p.y] = verdict;
					}

				}

			}
		}

		var list = []
		for( var x=1; x<Cs.GRID_MAX-1; x++ ){
			for( var y=1; y<Cs.GRID_MAX-1; y++ ){
				if(safe[x][y] == false )list.push({x:x,y:y});
			}
		}

		return list
	}

	function findWay(x:int,y:int,safe:Array<Array<bool>>,list:Array<{x:int,y:int}>):bool{
		var st = safe[x][y]
		if( st )return true
		if( st == false || grid[x][y] == null) return false
		for( var i=0; i<list.length; i++ ){
			var p = list[i]
			if( p.x == x && p.y == y )return false;
		}
		list.push({x:x,y:y})
		for( var i=0; i<Cs.DIR.length; i++ ){
			var d = Cs.DIR[i]
			var nx = x+d[0]
			var ny = y+d[1]
			if(findWay(nx,ny,safe,list))return true
		}
		return false;

		/*
		var list = [{x:x,y:y}]
		for( var i=0; i<Cs.DIR.length; i++ ){
			var d = Cs.DIR[i]
			var nx = x+d[0]
			var ny = y+d[1]
			if()
			if ( grid[nx][ny]!=null && ( safe[nx][ny] || findWay(nx,ny,safe) ) ){
				for( var n=0; n<list.length; n++){
					var p = list[n]
					safe[p.x][p.y] = true
				}
				return true
			}

		}

		return false;
		*/
	}


//{
}









