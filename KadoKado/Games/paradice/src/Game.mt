class Game {//}

	static var DP_BG = 1;
	static var DP_BALL = 2;
	static var DP_GROUND = 3;
	static var DP_PART = 4;
	static var DP_CACHE = 5;
	
	static var CDIR = [[0,1],[-1,0]]
	

	var flIceFall:bool;
	
	var step:int;
	var dm:DepthManager;
	
	var grid:Array<Array<Ball>>
	var bList:Array<Ball>
	var fList:Array<Ball>
	var dList:Array<Ball>
	var pList:Array<MovieClip>
	var sList:Array<Sprite>
	var sbList:Array<ScoreBubble>
	
	var spawnBubbleList:Array<{x:float,y:float,sc:int,col:int}>
	
	var timerList:Array<{>MovieClip,t:MovieClip}>
	var ground:Ground;
	
	var bg:{>MovieClip,base:MovieClip};
	var cache:MovieClip;

	volatile var timer:float;
	volatile var cTimer:float;
	volatile var playTimer:float;
	volatile var trgTimer:float;
	
	var nextScore:KKConst;
	volatile var multi:int;
	volatile var play:int;
	
	var pan:{>MovieClip,score:String}
	
	function new(mc) {
		Cs.init();
		Cs.game = this
		dm = new DepthManager(mc);
		bList = new Array();
		sList = new Array();
		sbList = new Array();
		
		bg = downcast(dm.attach("mcBg",DP_BG))
		cache = dm.attach("mcCache",DP_CACHE)
		var gl = dm.attach("mcGroundLimit",DP_BG)
		gl._y = Cs.MD
		
		flIceFall = false;
		
		cTimer = 1  
		trgTimer = 1  
		multi = 1
		play = 0
		
		while(true){
			var flBreak = true;
			initGrid();
			var groups = getGroups();
			for(var i=0; i<groups.length; i++){
				//Log.trace(g[i].length)
				var g = groups[i]
				while( g!=null && g.length>=Cs.COMBO_SIZE){
					var index = Std.random(g.length)
					var b:Gem = downcast(g[index])
					b.flIce = true;
					b.setSkin(b.root)
					g.splice(index,1)
				}
				
				
			}
			if(flBreak)break;
		}
		initGround();
		initStep(1)
		
		if(Cs.FL_DISPLAY_TIMER)initPlayTimers();
		
		bg.base._height = Cs.mch-Cs.MD
				
	}
	
	function initGround(){
		ground = new Ground();
		
	}
		
	function initPlayTimers(){
		timerList = new Array();
		for( var i=0; i<2; i++ ){
			var mc = downcast(dm.attach("mcTimer",DP_CACHE))
			mc._x = i*(Cs.mcw-30)
			mc.stop();
			timerList.push(mc)
		}
	}
	
	function initStep(s:int){
		step = s;
		//Log.trace("<"+s+">")
		switch(step){
			case 0: // CHECK GROUP ---> DESTROY
				var list = getGroups()
				dList = new Array();
				spawnBubbleList = new Array();
				nextScore = Cs.C0;
				for( var i=0; i<list.length; i++ ){
					var g = list[i]
					if(g.length>=Cs.COMBO_SIZE && g!=null){
						
						var sc = int(Math.pow(g.length*3,2)*0.1)*25*multi
						
						//
						var b = {
							xmin:99999
							xmax:0
							ymin:99999
							ymax:0
						}
						for( var n=0; n<g.length; n++ ){
							var ball = g[n]
							b.xmin = Math.min(b.xmin,ball.root._x)
							b.ymin = Math.min(b.ymin,ball.root._y)
							b.xmax = Math.max(b.xmax,ball.root._x)
							b.ymax = Math.max(b.ymax,ball.root._y)							
							dList.push(ball)
						}
						
						spawnBubbleList.push({
							x:(b.xmin+b.xmax)*0.5,
							y:(b.ymin+b.ymax)*0.5,
							sc:sc,
							col:g[0].col
						})
						// BUBBLE
						/*
						var p = new ScoreBubble( dm.attach("mcScoreBubble",DP_PART) )
						p.x = (b.xmin+b.xmax)*0.5
						p.y = (b.ymin+b.ymax)*0.5
						p.timer = 40
						p.vy = -0.2
						p.setScore(sc)
						*/
						//
						nextScore = KKApi.cadd(nextScore,KKApi.const(sc));
					}
					
					
				}
		
				//step = 99
				//break;
				
				if(dList.length>0){
					timer = Cs.DESTROY_TIMER
					multi++;
					if(pan!=null)pan.gotoAndPlay("leave");
				}else{
					multi = 1
					if( checkEnd() ){
						initStep(10)
					}else{
						if(flIceFall){
							iceFall();
							initStep(1)
						}else{
							initStep(2)
						}

					}
				}
				break;
			
				break;
			case 1:	// FALLING
				fList = new Array();
				for( var x=0; x<Cs.XMAX; x++){
					for( var y=0; y<Cs.YMAX; y++){
						var b = grid[x][y]
						if( b!=null && isFree(x,y-1) ){
							b.setPos(x,y-1)
							b.dy-= Cs.SQ
							fList.push(b)
						}
					}
				}
				break;
			case 2: // LOADING
				ground.initLoad();
				//ground.y = Cs.FILL_LEVEL
				//ground.ty = Cs.FILL_LEVEL
				//ground.step = 0;
				break;
			case 3: // PLAYING
				play++;
				ground.step = 0;
				playTimer = Cs.PLAY_TIMER
				break;
				
			case 10: // BLAST PINGUIN
				ground.initBlastPinguin();
				break;
			case 11: // GAMEOVER
				timer = 30
				break;
				
		}
		
	}
	
	function checkEnd(){
		for( var x=0; x<Cs.XMAX; x++ ){
			if( grid[x][Cs.LIMIT_GAMEOVER] != null ) return true;
		}
		return false;
	}
	
	function initGrid(){
		grid = new Array();
		for( var x=0; x<Cs.XMAX; x++ ){
			grid[x] = new Array();
			for( var y=0; y<Cs.YMAX; y++ ){
				grid[x][y] = null
				//*
				if( y<4 ){
					var b = new Gem();
					b.setPos(x,y);
					b.updatePos();
				}
				//*/
			}
		}
	}
	
	function main() {
		
		switch(step){
			case 0:
				timer-=Timer.tmod;
				var prc = Math.min(100*(1-timer/Cs.DESTROY_TIMER),100)
				var flDestroy = timer<0 
				for( var i=0; i<dList.length; i++ ){
					var b = dList[i]
					if(flDestroy){
						b.explode();
						b.checkBlast();
					}else{
						Cs.setPercentColor(b.root, prc,0xFFFFFF)
					}
				}
				if(flDestroy){
					spawnBubble();
					KKApi.addScore(nextScore);
					if(multi>=3)spawnMultiPanel();
					initStep(1);
				}
				break;
			case 1:	//FALLING
				for( var i=0; i<fList.length; i++ ){
					var b = fList[i];
					b.dy += 10*Timer.tmod;
					while(b.dy>0){
						if( isFree(b.x,b.y-1) ){
							b.setPos(b.x,b.y-1);
							b.dy-= Cs.SQ;
						}else{
							b.dy = 0;
							fList.splice(i--,1)
						}
					}
					b.updatePos();
				}
				if(fList.length==0){
					if(flIceFall){
						initStep(0);
					}else{
						initStep(2);
					}
				}
				break;
			case 2: //LOADING
				flIceFall = true;
				ground.loading();
				break;
			case 3: // PLAYING
				
				ground.control();
				playTimer -= Timer.tmod
				trgTimer = playTimer/Cs.PLAY_TIMER
				break;
			
			case 10: 
				ground.blastPinguin();
				break;
			case 11: // GAMEOVER
				timer-=Timer.tmod;
				if(timer<0)KKApi.gameOver({})
				break;				
		}
		
		// BLINK
		if( Math.random()/Timer.tmod < 0.02 ){
			var b = bList[Std.random(bList.length)]
			if(b.col!=null)	b.root.play();
		} 
		
		
		// SCOREBUBBLE
		updateScoreBubble();
		
		// SPRITES
		for( var i=0; i<sList.length;i++){
			sList[i].update();
		}
		
		// TIMER
		if(Cs.FL_DISPLAY_TIMER){
			var dc = trgTimer-cTimer
			cTimer += dc*0.1*Timer.tmod;
			for( var i=0; i<timerList.length; i++ ){
				var mc = timerList[i]
				mc.gotoAndStop(string(1+int(cTimer*19)))
			}
		}

	}
	
	//
	function iceFall(){
		//Log.trace("iceFall!")
		
		
		
		var a:Array<{x:int,y:int}> =new Array();
		for( var x=0; x<Cs.XMAX; x++ ){
			for( var y=0; y<Cs.XMAX; y++ ){
				if(grid[x][y]==null){
					for( var i=0; i<=a.length; i++ ){
						var o = a[i]
						if(o.y>y || i == a.length){
						
							a.insert(i,{x:x,y:y})
							break;
						}
					}
					break;
				}
			}
		}
		
		var max = 1+int(Math.sqrt(Cs.game.play*0.1)) //3;
		for( var i=0; i<max; i++){
			var p = a[i]
			
			if(p.y<Cs.LIMIT_GAMEOVER-1){
				var b = new Gem();
				
				b.setPos(p.x,Cs.LIMIT_GAMEOVER);
				b.flIce = true;
				b.setSkin(b.root)
				b.updatePos();
			}
		}
		
		flIceFall = false;
		
	}
	
	function spawnBubble(){
		for( var i=0; i<spawnBubbleList.length; i++ ){
			var o = spawnBubbleList[i]
			var p = new ScoreBubble( dm.attach("mcScoreBubble",DP_PART) );
			p.x = o.x
			p.y = o.y
			p.timer = 28;
			p.fadeType = 0
			p.fadeLimit = 6
			p.vy = -0.2
			p.setScore(o.sc,o.col);
		}
	}
	
	// 
	function getGroups(){
	
		var gList = new Array();
		for( var i=0; i<bList.length; i++ ){
			bList[i].gid = null;
		}
		
		for( var i=0; i<bList.length; i++ ){
			var b = bList[i]
			if( !b.flIce ){
				if( b.gid == null ){
					b.gid = gList.length;
					gList.push([b])
				}
			
				for( var n=0; n<CDIR.length; n++ ){
					var nx = b.x + CDIR[n][0]
					var ny = b.y + CDIR[n][1]
					var b2 = grid[nx][ny]
					
					if( b.col == b2.col && b.col!=null && !b2.flIce){
						if(b2.gid==null){
							b2.gid = b.gid
							gList[b.gid].push(b2)
						}else if(b2.gid==b.gid){
							
						}else{
							var kgid = b2.gid
							var list = gList[kgid]//.duplicate();
							//break;
							for( var g=0; g<list.length; g++){
								var b3 = list[g]
								b3.gid = b.gid
								gList[b.gid].push(b3)
							}
							gList[kgid] = null
							
						}
					}
				}
			}
		}
		/*//TRACE
		for( var i=0; i<bList.length; i++ ){
			var b = bList[i]
			downcast(b.root).test = b.gid;
		}		
		//*/
		return gList;
	}
	
	function updateTimer(){


	}
	
	function updateScoreBubble(){
		var max = 32
		for( var i=0; i<sbList.length; i++ ){
			var sb = sbList[i]
			for( var n=i+1; n<sbList.length; n++ ){
				var sb2 = sbList[n]
				var dist = sb.getDist(sb2);
				if(dist<max){
					var d = (max-dist)*0.5;
					var a = sb.getAng(sb2);
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					sb.x -= ca*d;
					sb.y -= sa*d;
					sb2.x += ca*d;
					sb2.y += sa*d;
				}
			}
		}
	}
	//
	function isFree(x,y){
		
		return grid[x][y] == null && y>=0 
	}
	
	//
	function spawnMultiPanel(){
		pan = downcast(dm.attach( "mcMultiPanel", DP_CACHE ))
		pan.score = "$x".substring(1)+string(multi-1)
	}
	
//{
}









