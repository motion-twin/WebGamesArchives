class Game {//}

	static var DP_BG = 1
	static var DP_SCORE = 2
	static var DP_GROUND = 3

	static var DP_PIECES = 5
	static var DP_PARTS = 6
	static var DP_HAND = 8
	static var SIZE = 15

	static var DIR=[{x:1,y:0},{x:0,y:1},{x:-1,y:0},{x:0,y:-1}]



	//GFX
	static var VANISH_SPEED = 8

	static var PIECE_LIST = [
		[ [0,0], [0,1],	[1,0], [1,1] ],
		[ [0,0], [0,1] ],
		[ [0,0], [1,0] ],
		[ [0,-1], [0,0], [0,1] ],
		[ [-1,0], [0,0], [1,0] ]
	]


	var flPress:bool;
	var flTurnRelease:bool;
	var flGameOver:bool;

	volatile var pieceTimer:float;
	volatile var pieceBoost:float;
	volatile var shake:float;
	volatile var blink:float
	volatile var mainTimer:float;
	volatile var flashHorloge:float;
	volatile var life:int;

	var grid:Array<Array<MovieClip>>

	var dm : DepthManager;

	var bg:{>MovieClip,ray:MovieClip,horloge:{>MovieClip ha:MovieClip}};
	var ground:MovieClip;
	var hand:Piece

	var formList:Array<{x:int,y:int,list:Array<Cub>}>
	var pieceList:Array<Piece>
	var destroyList:Array<{t:float,x:int,y:int}>
	var pList:Array<{>MovieClip,vx:float,vy:float,ft:int,weight:float,frict:float,t:float,scale:float,flQueue:bool}>
	var timeLightList:Array<{>MovieClip,vx:float,vy:float,ft:int,weight:float,frict:float,t:float,scale:float,flQueue:bool}>
	var flashLightList:Array<{mc:MovieClip,prc:float}>

	var root:MovieClip;
	var butEndGame:MovieClip;

	var stats:{$p:int,$c:Array<{$s:int,$m:int,$t:int}>}

	function new(mc) {
		dm = new DepthManager(mc);
		root = mc;
		bg = downcast(dm.attach("bg",DP_BG))
		ground = dm.empty(DP_GROUND)

		grid = new Array();
		for( var x=0; x<20; x++ ){
			grid[x] = new Array();
			for( var y=0; y<20; y++ ){
				grid[x][y] = null

			}
		}
		formList = new Array();
		pieceList = new Array();
		destroyList = new Array();
		pList = new Array();
		timeLightList = new Array();
		flashLightList = new Array();
		//
		flGameOver = false;
		flTurnRelease = false;
		pieceTimer = 0
		pieceBoost = 30
		mainTimer = Cs.TIMER_MAX

		//
		stats = {
			$p:0
			$c:[]
		}

		//for( var i=0; i<500; i++ )updatePieces();
		//
		/*
		var list = [
			{x:0,y:0,n:1,mc:null}
			{x:0,y:1,n:1,mc:null}
			{x:1,y:0,n:1,mc:null}
			{x:1,y:1,n:1,mc:null}
		]
		createHand(list)
			*/
		initMouse()
	}

	function initMouse(){
		var me = this;
		var lst = {
			onMouseDown : fun(){me.flPress = true}
			onMouseUp : fun(){me.flPress = false}
			onMouseWheel:null
			onMouseMove:null
		}
		Mouse.addListener(lst)
	}

	function main() {

		if( hand!=null ){
			hand.root._x = Manager.root_mc._xmouse ;
			hand.root._y = Manager.root_mc._ymouse ;
			//hand.root._x = Math.round((Manager.root_mc._xmouse-hand.dx)/SIZE)*SIZE ;
			//hand.root._y = Math.round((Manager.root_mc._ymouse-hand.dy)/SIZE)*SIZE ;
			if(shake!=null){
				shake*=0.7
				hand.root._x += Math.random()*shake
				hand.root._y += Math.random()*shake
				if(shake<0.5)shake = null;

			}
			if(flPress)handDown();
			if(Key.isDown(Key.SPACE)){
				if(flTurnRelease){
					turnHand();
				}
				flTurnRelease = false;
			}else{
				flTurnRelease = true;
			}
		}
		if(!flGameOver){
			mainTimer-=Timer.tmod
			var c = mainTimer/Cs.TIMER_MAX
			var frame = int(166 - c*165)
			bg.horloge.ha.gotoAndStop(string(frame))

			if(c<0.15){
				if(blink==null)blink = 0
				blink =(blink+67)%628
				Cs.setPercentColor( bg.horloge.ha, (Math.cos(blink/100)+1)*30, 0xFF0000 )
			}

			if(c<0)	gameOver();
		}

		for( var i=0; i<flashLightList.length; i++ ){
			var o = flashLightList[i]
			var prc = o.prc
 			o.prc *= 0.9;
			if(o.prc<1){
				flashLightList.splice(i--,1)
				prc=0
			}
			Cs.setPercentColor(o.mc,prc,0xFFFFFF)

		}

		updatePieces();
		updateDestroy();
		updateParts();
		updateTimeLight();



	}

	function updatePieces(){
		/*
		if(pieceBoost>0){
			pieceBoost *= Math.pow(0.9,Timer.tmod);
			if(pieceBoost<0.1)pieceBoost = 0;
		}
		*/





		pieceTimer -= pieceBoost*Timer.tmod;
		if(pieceTimer<0 && !flGameOver){
			pieceTimer += Cs.PIECE_INTERVAL
			createPiece();
		}

		for( var i=0; i<pieceList.length; i++ ){
			var p = pieceList[i]
			p.root._x -= pieceBoost*Timer.tmod;
			if(p.root._x<-40){
				p.kill();
				pieceList.splice(i--,1)
			}
		}

		bg.ray._x -= pieceBoost*Timer.tmod;
		while(bg.ray._x<-20)bg.ray._x+=20;


		//
		var d = (Cs.PIECE_SPEED/(pieceList.length+1)) - pieceBoost
		pieceBoost += d*0.1*Timer.tmod;

		//
		if(flGameOver && pieceList.length == 0){
			if( butEndGame == null ){
			
				butEndGame = dm.attach("butEndGame",4)
				butEndGame._alpha = 0;
				Cs.makeButton(butEndGame.smc);
				butEndGame.smc.onPress = callback(this,endGame);
				KKApi.registerButton(butEndGame.smc);
				
			}else{
			
				if(butEndGame._alpha<100)butEndGame._alpha += 1
				
			}
			if( bg.ray._visible ){
				bg.ray._alpha -= 0.01
				//Log.print(bg.ray._alpha)
				//if(bg.ray._alpha == 0 )bg.ray._visible = false;
			}
		}



	}

	function updateDestroy(){
		for( var i=0; i<destroyList.length; i++ ){
			var o = destroyList[i]
			o.t -= Timer.tmod;
			if(o.t<=VANISH_SPEED){
				var mc = grid[o.x][o.y]
				mc._xscale = o.t*(100/VANISH_SPEED)
				mc._yscale = mc._xscale

				if(o.t<=VANISH_SPEED*0.5){
					for( var n=0; n<1; n++ ){
						var p = newPart("partLight")
						p._x = mc._x
						p._y = mc._y
						var a = Math.random()*6.28
						var sp = 0.2+Math.random()*2.5
						p.vx = Math.cos(a)*sp
						p.vy = Math.sin(a)*sp
						p.t = 10+Math.random()*10
						p.scale = 50+Math.random()*100
						p._xscale = p.scale;
						p._yscale = p.scale;
						p.ft = 0;
					}
				}
				if(o.t<=0){
					if( mc._currentframe>3 && !flGameOver ){
						var p = newPart("partLight")
						p._x = mc._x
						p._y = mc._y

						var dx = p._x - bg.horloge._x;
						var dy = p._y - bg.horloge._y;

						var a = Math.atan2(dy,dx)// Math.random()*6.28
						var sp = 4+Math.random()*10
						p.vx = Math.cos(a)*sp
						p.vy = Math.sin(a)*sp
						p.scale = 200
						p._xscale = p.scale;
						p._yscale = p.scale;
						p.flQueue = true;
						p.frict = 0.9
						timeLightList.push(p)
					}

					mc.removeMovieClip();
					destroyList.splice(i--,1);
					grid[o.x][o.y] = null;




				}
			}
		}
	}

	function updateTimeLight(){
		for( var i=0; i<timeLightList.length; i++ ){
			var p = timeLightList[i]

			var dx = bg.horloge._x - p._x;
			var dy = bg.horloge._y - p._y;

			var lim = 1.5
			var coef = 0.1
			p.vx += Math.min(Math.max(-lim,dx*coef),lim)
			p.vy += Math.min(Math.max(-lim,dy*coef),lim)

			if(Math.abs(dx)+Math.abs(dy)<20 && !flGameOver ){
				p.t = 0
				for(var n=0; n<10; n++ ){
					var pp = newPart("partLight")
					var a = Math.random()*6.28
					var ray = 6
					var sp = 2+Math.random()*5
					pp._x = p._x+Math.cos(a)*ray
					pp._y = p._y+Math.sin(a)*ray
					pp.vx = Math.cos(a)*sp
					pp.vy = Math.sin(a)*sp
					pp.t = 10+Math.random()*10
					pp.frict = 0.92
				}
				mainTimer = Math.min(mainTimer+400,Cs.TIMER_MAX)
				flashHorloge = 80
			}
			if(flGameOver && p.t ==null)p.t = 10;

		}

		if(flashHorloge!=null){
			bg.horloge._alpha = 20+flashHorloge
			flashHorloge*=0.6
			if(flashHorloge<1){
				flashHorloge = null
				bg.horloge._alpha = 20
			}
		}
	}

	// MOVE
	function createPiece(){
		stats.$p++
		var pl = getPieceShape()
		var list = new Array()
		var col = Std.random(3)

		for( var i=0; i<pl.length; i++ ){
			var pos = pl[i]
			var o  = {
				x:pos[0],
				y:pos[1],
				n:col,
				s:null,
				mc:null
			}
			if(Std.random(30)==0)o.n+=3;
			list.push(o)
		}
		var p = new Piece(dm.empty(DP_PIECES),list)
		p.build(true)
		p.root._x = Cs.mcw + 50
		p.root._y = SIZE*2.5
		p.root.onPress = callback(this, takePiece, p)
		KKApi.registerButton(p.root);
		pieceList.push(p)

	}

	function getPieceShape(){
		//return [[0,0],[1,0],[0,1],[1,1],[2,0],[0,2],[2,2],[2,1],[1,2]]
		var mg = new Array()
		for( var x=0; x<Cs.SHAPE_VOLUME; x++ ){
			mg[x] = new Array();
			for( var y=0; y<Cs.SHAPE_VOLUME; y++ ){
				mg[x][y]=false
			}
		}
		var size = Std.random(Cs.SHAPE_SIZE)
		var px=0
		var py=0
		mg[px][py] = true;
		while(size>0){
			var d = DIR[Std.random(DIR.length)]
			var nx = px+d.x;
			var ny = py+d.y;
			if(mg[nx][ny]==false){
				mg[nx][ny] = true;
				size--
				px = nx
				py = ny

			}


		}

		var pl = new Array();
		for( var x=0; x<Cs.SHAPE_VOLUME; x++ ){
			for( var y=0; y<Cs.SHAPE_VOLUME; y++ ){
				if(mg[x][y])pl.push([x,y])
			}
		}
		return pl
	}

	function takePiece(p){
		if( hand != null)return;
		flPress = false
		createHand(p.list)
		p.kill();
		pieceList.remove(p)
	}

	function takeCub(form){
		if(hand!=null)return;
		flPress = false
		destroyCubs(form)
		createHand(form.list)
	}

	function createHand(list){
		hand = new Piece(dm.empty(DP_HAND),list)
		hand.build(false);
		hand.root._x = Manager.root_mc._xmouse;
		hand.root._y = Manager.root_mc._ymouse;
		hand.game = this;
		life = 5

	}

	function handDown(){
		flPress = false;

		var x = Math.floor((hand.root._x/SIZE)-hand.dx)
		var y = Math.floor((hand.root._y/SIZE)-hand.dy)

		if( formFit(x,y,hand.list) ){
			put(x,y)

		}else{
			if( Key.isDown(Key.CONTROL) ){
				var form = checkSwap(x,y,hand.list);
				if(form!=null){
					var list = hand.list;
					emptyHand();
					takeCub(form)
					// EMULE put(x,y)
					var info = { x:x, y:y, list:list}
					for( var i=0; i<list.length; i++ ){
						var o = list[i]
						o.mc = newCube(o.x+x,o.y+y,o.n,o.s)
						o.mc.onPress = callback(this,takeCub,info)
						KKApi.registerButton(o.mc);
						downcast(o.mc).form = info
					}
					formList.push(info)
					checkCombo();

				}
			}else{
				for( var i=0; i<4; i++ ){
					var d = DIR[i];
					var nx = x+d.x
					var ny = y+d.y
					if( formFit(nx,ny,hand.list) ){
						put(nx,ny)
						break
					}
				}
				shake = 10
				life--
				if(life==0){
					hand.burst();
					emptyHand();
				}
			}
		}
	}

	function put(x,y){
		// PART
		var mc = dm.attach("partRound",DP_SCORE)
		mc._x = Math.round(hand.root._x/SIZE)*SIZE//x*SIZE
		mc._y = Math.round(hand.root._y/SIZE)*SIZE//y*SIZE
		mc._alpha = 50
		//


		var info = { x:x, y:y, list:hand.list}
		for( var i=0; i<hand.list.length; i++ ){
			var o = hand.list[i]
			o.mc = newCube(o.x+x,o.y+y,o.n,o.s)
			o.mc.onPress = callback(this,takeCub,info)
			KKApi.registerButton(o.mc);
			downcast(o.mc).form = info
		}
		formList.push(info)
		emptyHand();
		checkCombo();
	}

	function emptyHand(){
		hand.kill();
		hand = null;
		/*
		var list = [
			{x:0,y:0,n:1,mc:null}
			{x:0,y:1,n:1,mc:null}
			{x:1,y:0,n:1,mc:null}
			{x:1,y:1,n:1,mc:null}
		]
		createHand(list)
		*/
	}

	function newCube(x,y,n,s){
		var d = x*100 + y
		var mc = Std.attachMC(ground,"cube",d)
		mc._x = (x+0.5)*SIZE;
		mc._y = (y+0.5)*SIZE;
		grid[x][y] = mc;
		mc.gotoAndStop(string(n+1))
		downcast(mc).sub.gotoAndStop(s)

		flashLightList.push({mc:mc,prc:100})

		return mc;
	}

	function formFit(x,y,list){
		for( var i=0; i<list.length; i++ ){
			var o = list[i];
			var tx = x + o.x;
			var ty = y + o.y;
			var m = 1
			if( ty<5+m || ty>19-m || tx<m || tx>19-m || grid[tx][ty]!=null  ){
				return false
			}
		}
		return true
	}

	function checkSwap(x,y,list){
		var form:{x:int,y:int,list:Array<Cub>} = null
		for( var i=0; i<list.length; i++ ){
			var o = list[i];
			var tx = x + o.x;
			var ty = y + o.y;
			var m = 1

			if(grid[tx][ty]!=null){
				var f = downcast(grid[tx][ty]).form
				if( form==null){
					form = f
				}else{
					if(form!=f)return null
				}

			}


		}
		return form;
	}

	//*
	function turnHand(){
		hand.destroy();
		var mx = 9999
		var my = 9999
		for( var i=0; i<hand.list.length; i++ ){
			var cub = hand.list[i];
			var x = cub.x;
			var y = cub.y;
			cub.x = -y;
			cub.y = x;
			mx = int(Math.min(cub.x,mx))
			my = int(Math.min(cub.y,my))
		}

		for( var i=0; i<hand.list.length; i++ ){
			var cub = hand.list[i];
			cub.x -= mx;
			cub.y -= my;
		}


		hand.sortList()
		hand.build(false);


	}
	//*/

	// DESTROY
	function destroyCubs(form){
		for( var i=0; i<form.list.length; i++ ){
			var o = form.list[i]
			o.mc.removeMovieClip();
			grid[form.x+o.x][form.y+o.y] = null
		}
		formList.remove(form)
	}

	function destroySquare(info){
		var id = Std.random(5)
		for( var x=info.x; x<info.x+info.max; x++ ){
			for( var y=info.y; y<info.y+info.max; y++ ){
				var o = {
					x:x
					y:y
					t:getVanishTime( id, x-info.x, y-info.y, info.max)
				}
				destroyList.push(o)
			}
		}
	}

	function getVanishTime(id,x,y,max){
			switch(id){

				case 0 : // ROND
					var dx = (max-1)*0.5 - x
					var dy = (max-1)*0.5 - y
					return VANISH_SPEED+Math.sqrt(dx*dx+dy*dy)*5

				case 1 : // DIAGONAL
					return VANISH_SPEED+(x+y)*3
				case 2 : // HORLOGE
					var cx = (max-1)*0.5
					var cy = (max-1)*0.5
					return VANISH_SPEED + (Math.atan2(cy-y,cx-x)+1)*5
				case 3 : // CHAINE 1
					return VANISH_SPEED + x*max+y
				case 4 : // CHAINE 2
					return VANISH_SPEED + y*max+x
			}
			return 12
	}

	// CHECK
	function checkCombo(){
		//Log.clear()
		//Log.trace("checkCombo!")
		var dl = new Array();
		var di = null
		for( var i=0; i<formList.length; i++ ){

			var info = formList[i]
			var sx = info.x+info.list[0].x
			var sy = info.y+info.list[0].y
			for( var n=Cs.COMBO_MIN; n<15; n++ ){
				var test = checkSquare(sx,sy,n)
				if(test!=null && test.length > dl.length ){
					dl = test;
					di = { x:sx, y:sy, max:n }
				}
			}
		}

		if( dl.length > 0 ){
			var color = [0,0,0]
			for( var i=0; i<dl.length; i++){
				var f = dl[i]
				var col = f.list[0].n
				if(col>2)col-=3;
				color[col]++
				formList.remove(f)
			}
			destroySquare(di)
			// SCORE
			var multi = 1
			for( var i=0; i<color.length; i++ )if(color[i]==0)multi++;
			var score = Math.round(Math.pow(di.max,2.5)*0.1)*KKApi.val(Cs.C100)
			KKApi.addScore(KKApi.const(score*multi))
			//
			var p = downcast(dm.attach("scoreSquare",DP_SCORE))
			p._x = di.x*SIZE
			p._y = di.y*SIZE
			p.vx = 0
			p.vy = 0
			var mc = downcast(p)
			mc.bg._xscale = di.max*SIZE
			mc.bg._yscale = di.max*SIZE
			mc.score = score*multi
			mc.sf._x = di.max*SIZE*0.5
			mc.sf._y = di.max*SIZE*0.5
			mc.sf._xscale = Math.min(di.max*20,100)
			mc.sf._yscale = mc.sf._xscale
			p.t = 100
			pList.push(p)
			// STATS
			stats.$c.push({$s:score,$m:multi,$t:Math.round((mainTimer/Cs.TIMER_MAX)*100)})

			// INTERFACE
			if(multi>1){
			var sc = downcast(dm.attach("mcScore",DP_HAND))
			sc._x = Cs.mcw;
			sc._y = Cs.mch;
				sc.score.gotoAndStop(string(multi-1))
			}
		}


	}

	function checkSquare(sx,sy,max){
		for( var x=sx; x<sx+max; x++ ){
			for( var y=sy; y<sy+max; y++ ){
				if(grid[x][y]==null)return null;
			}
		}
		var fl = new Array();
		for( var i=0; i<formList.length; i++ ){
			var o = formList[i]
			var flOut = null
			for( var n=0; n<o.list.length; n++ ){
				var p = o.list[n]
				var px = o.x+p.x
				var py = o.y+p.y
				if( px>=sx && px<sx+max && py>=sy && py<sy+max ){
					if(flOut==true)return null;
					flOut = false
				}else{
					if(flOut==false)return null;
					flOut = true
				}
			}
			if(!flOut){
				fl.push(o)
			}
		}
		return fl;
		

	}

	//
	function endGame(){

		KKApi.gameOver({})
		butEndGame.removeMovieClip();
	}

	// PARTS
	function updateParts(){
		for( var i=0; i<pList.length; i++ ){
			var p = pList[i]
			if( p.weight != null ){
				p.vy += p.weight*Timer.tmod;
			}
			if( p.frict != null ){
				p.vx *= p.frict
				p.vy *= p.frict
			}

			var ox = p._x
			var oy = p._y

			p._x += p.vx*Timer.tmod;
			p._y += p.vy*Timer.tmod;

			if(p.flQueue){
				var dx = ox - p._x
				var dy = oy - p._y
				var a = Math.atan2(dy,dx)
				var d = Math.sqrt(dx*dx+dy*dy)
				var q = newPart("partQueue")
				q._x = p._x;
				q._y = p._y;
				q._rotation = a/0.0174
				q._xscale = d;
			}


			if(p.t!=null){
				p.t-=Timer.tmod;
				if(p.t<0){
					p.removeMovieClip();
					pList.splice(i--,1)
				}else if(p.t<10){
					switch(p.ft){
						case 0:
							p._xscale = p.scale*(p.t/10);
							p._yscale = p._xscale;
							break;
						default:
							p._alpha = p.t*10
							break;
					}
				}
			}
		}
	}

	function newPart(link){
		var p = downcast(dm.attach(link,DP_PARTS))
		p.vx = 0
		p.vy = 0
		p.frict=0.95
		p.scale = 100
		pList.push(p)
		return p;
	}

	//
	function gameOver(){

		//KKApi.gameOver(stats)
		flGameOver = true;
	}


//{
}









