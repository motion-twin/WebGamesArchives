class Ground{//}

	static var SPEED = 8//8;
	static var SPECIAL_PROBA = [0,0,0,0,0,1,2,2]

	
	//var dm:DepthManager;
	var ty:float;
	var cMove:float;
	var sens:int;
	var step:int;
	var dx:int;
	
	var y:float;
	var timer:float;

	var pList:Array<{>MovieClip,step:int,t:float}>;
	var bList:Array<{x:int,b:Ball}>
	var gList:Array<{>Part,px:int,py:int}>
	
	var special:int;
	
	var portrait:MovieClip;
	var bomb:Phys;
	
	function new(){
		
		y = Cs.MD
		dx = 0;
		cMove = 0;
		sens= 0;
		initPinguins();
		y = Cs.mch
		ty = y
	}
	
	function initPinguins(){
		pList = new Array();
		for( var x=0; x<Cs.XMAX; x++ ){
			var mc = downcast(Cs.game.dm.attach("mcPinguin",Game.DP_GROUND))
			mc._x = Cs.ML+(x+0.5)*Cs.SQ
			mc._y = Cs.mcw
			pList.push(mc)
		}
	}	
	
	function initLoad(){
		fill();
		launchAnim("take");
		step=1
		timer = 4
		ty = Cs.FILL_LEVEL
		y = Cs.FILL_LEVEL
	}
	
	function loading(){
		move();

		switch(step){
			case 0:
				if( Math.abs(ty-y)<0.5 ){
					fill();
					launchAnim("take");
					step++
					timer = 4
				}
				break;
			case 1:
				timer -= Timer.tmod;
				if(timer<0){
					ty = Cs.PLAY_LEVEL
					step++
				}
				break;
			case 2:
				if( Math.abs(ty-y)<0.5 ){
					Cs.game.initStep(3)
				}
				break;
		}

	}
	
	function move(){
		var dy = ty-y
		dy = Cs.mm(-SPEED,dy,SPEED)
		y += Math.min(dy,dy*0.9*Timer.tmod);
		updateBallPos();
	}
	
	function control(){

		switch(step){
			case 0:
				if( Key.isDown(Key.UP) || Key.isDown(Key.SPACE) || Cs.game.playTimer<0 ){
					validate();
					
					return;
				}
			
				sens = checkInput();			
				if(sens!=0){
					cMove = 0
					step = 1
					launchAnim("pass");
				}
				
				
				break;
			case 1:
				cMove += Cs.GROUND_CONTROL_SPEED*Timer.tmod
				if(cMove>1){
					dx += sens
					cMove--;
					while(dx>Cs.XMAX)dx-=Cs.XMAX;
					while(dx<0)dx+=Cs.XMAX;
					sens = checkInput()
					if(sens==0 || Cs.game.playTimer<0){
						step = 0;
						cMove = 0;
						launchAnim("catch");
					}else{
						launchAnim("pass");
					}
					
				}
				updateBallPos();				
				break;
				
			case 2:
				move();
				var dy = Math.abs(ty-y)
				if( dy < Cs.SQ ){
					for( var i=0; i<bList.length; i++ ){
						var o = bList[i]
						var x = Cs.sMod(o.x+dx, Cs.XMAX)
						
						for( var y=0; y<Cs.YMAX; y++ ){
							var b = Cs.game.grid[x][y]
							b.dy = -(Cs.SQ-dy)
							b.updatePos();
						}
						
					}
				}
				
				if( dy<0.5 ){
					updateGrid();
					Cs.game.initStep(0)
				}
				break;
				
			case 3: // BURN
				var x = getX(bList[0].x)
				for( var i=0; i<4; i++ ){
					var p = new Part(Cs.game.dm.attach("partFlame",Game.DP_PART));
					p.x = Cs.ML+(x+0.7)*Cs.SQ + (Math.random()*2-1)*2
					p.y = Cs.PLAY_LEVEL-(24+Math.random()*10)
					p.vx = (Math.random()*2-1)
					p.vy = -(8+Math.random()*16)
					p.frict = null
					p.timer = 10+Math.random()*20
					p.scale = 100 +Math.random()*50
					p.root._xscale = p.scale;
					p.root._yscale = p.scale;
				}
				timer-=Timer.tmod
				var lim = 20
				if(timer<lim){
					var c = timer/lim
					for( var y=0; y<Cs.YMAX; y++ ){
						var b = Cs.game.grid[x][y]
						if(b!=null){
							b.root._xscale = c*100
							b.root._yscale = b.root._xscale
							if(timer<0){
								b.kill();
							}
						}
					}
					if(timer<0){

						portrait.play();
						launchAnim("peace")
						Cs.game.initStep(0)
					}
				}
				break;
			case 4: // BOMB
				if(bomb.vy>0){
					var x = getX(bList[0].x)
					var y = int((Cs.MD-bomb.y)/Cs.SQ)
					var b = Cs.game.grid[x][y]
					if(b!=null || y<1){
						nuke(x,y)
						
						bomb.kill();
						portrait.play();
						Cs.game.initStep(1)
					}
				}
				
				break;
			case 5: // GRENADES
				updateGrenades();

				break;
				
		}	
		
		for( var i=0; i<pList.length; i++ ){
			var p  = pList[i]
			p._rotation *= Math.pow(0.8,Timer.tmod)
		}
	}
	

	function launchAnim(label){
		for( var i=0; i<bList.length; i++ ){
			var o = bList[i]
			var x = getX(o.x)
			var p = pList[x];
			p.gotoAndPlay(label);
			if(label=="pass"){
				p._rotation = sens*30
			}
			if(label=="catch"){
				p._rotation = -sens*30
			}
		}
	}
		
	function validate(){
		
		if(special!=null){
			spawnPortrait(special);
			step = 3+special
		}
		var ball = bList[0].b
		switch(special){
			case 0: // FLAME
				// 
				launchAnim("burn")
				ball.kill();
				timer = 40
				break;
			
			case 1: // BOMB
				launchAnim("launch")
				bomb = new Phys(Cs.game.dm.attach("mcBomb",Game.DP_PART));
				bomb.weight = 0.5;
				bomb.x = ball.root._x;
				bomb.y = ball.root._y;
				bomb.vy = -28
				ball.kill();
				break
			
			case 2:	// GRENADE
				launchAnim("launch")
				gList = new Array();
				for( var i=0; i<3; i++ ){
					var g = downcast(new Part(Cs.game.dm.attach("mcGrenade",Game.DP_PART)))
					g.weight = 0.5+Math.random()*0.2
					g.x = ball.root._x
					g.y = ball.root._y;
					g.vx = (Math.random()*2-1)*8
					g.vy = -(14+Math.random()*6)
					g.vr = (Math.random()*2-1)*12
					g.frict = 1
					gList.push(g)
				}
				ball.kill();	
				break;
			default:
				launchAnim("launch");
				step = 2
				ty = Cs.MD
				break;
		}

	}
	
	function spawnPortrait(n){
		var frame = n*10+1
		var mc = Cs.game.dm.attach("mcPyro",Game.DP_CACHE)
		var x = getX(bList[0].x)
		var sens = (x<Cs.XMAX*0.5)?1:0
		mc._x = sens*Cs.mch
		mc._y = Cs.mch
		mc._xscale = (sens*2-1)*100
		portrait = mc;
		if(downcast(pList[x]).piou)frame++;
		downcast(mc).sub.gotoAndStop(string(frame))
		
		
	}
	
	function updateBallPos(){
		
		for ( var i=0; i<bList.length; i++ ){
			var o = bList[i];
			var b = o.b;

			var px = Cs.sMod((dx+o.x+cMove*sens),Cs.XMAX)+0.5
			b.root._x = Cs.ML + px*Cs.SQ
			b.root._y = y - ( Cs.SQ*0.5 + Math.cos((1-cMove)*3.14)*4)
			if(downcast(pList[getX(o.x)]).piou){
				b.root._y += 7
			}
			// CLONES
			if( px >= Cs.XMAX-0.5 ){
				if( b.cl==null ){
					//Log.clear()
					//Log.trace("-- INSERT --")
					b.genClone();
				}
				b.cl._x = b.root._x - Cs.XMAX*Cs.SQ
				b.cl._y = b.root._y
			}else{
				
				if( b.cl!=null ){
					//Log.trace("-- REMOVE --")
					b.removeClone();
				}
			}
		
		}
	}
		
	function checkInput(){
		if(Key.isDown(Key.LEFT)){
			return -1
		}
		if(Key.isDown(Key.RIGHT)){
			return 1
		}
		return 0;
	}
	
	function fill(){
		special = null
		bList = new Array()
		
		/* HACK
		if(Key.isDown(Key.ENTER)){
			special = 0
			var b = new Special();
			b.sid = special
			b.setSkin(b.root)
			bList.push({x:Std.random(Cs.XMAX),b:b})	
			return;
		}
		//*/
		// SPECIAL
		if(Std.random(25)==0){
			special = SPECIAL_PROBA[Std.random(SPECIAL_PROBA.length)]
			var b = new Special();
			b.sid = special
			b.setSkin(b.root)
			bList.push({x:Std.random(Cs.XMAX),b:b})
			return;
		}

		
		// NORMAL
		var max = 3//Math.min( 3+int(Math.pow(Cs.game.play,1.5)/300), Cs.XMAX)
		if(Std.random(20)==0)max = 1;
		if(Std.random(1000)==0)max = Cs.XMAX;
		
		for ( var i=0; i<max; i++ ){
			var b = new Gem();
			var x = null;
			while(true){ 
				var flBreak = true;
				x=Std.random(Cs.XMAX)
				for( var n=0; n<bList.length; n++ ){
					if(bList[n].x==x){
						flBreak = false;
						break;
					}
				}
				if(flBreak)break;
			}
			bList.push({x:x,b:b});
		}
	}
	
	function updateGrid(){
		while(bList.length>0 ){
			var o = bList.pop();
			var x = Cs.sMod(o.x+dx, Cs.XMAX)
			for( var y=Cs.YMAX-1; y>=0; y-- ){
				var b = Cs.game.grid[x][y]
				
				if(b!=null){
					b.setPos(b.x,b.y+1)
					b.dy = 0
					b.updatePos();
				}

			}
			Cs.game.grid[x][0] = o.b
			o.b.setPos(x,0)
			o.b.updatePos();
			
		}
	}
	
	function getX(x){
		return Cs.sMod(x+dx,Cs.XMAX)	
	}
	
	function initBlastPinguin(){
		for( var x=0; x<pList.length; x++ ){
			var p = pList[x]
			p.t = 10+x*7
			p.step = 0
		}
	}
	
	function blastPinguin(){
		for( var x=0; x<pList.length; x++ ){
			var pg = pList[x]
			pg.t-=Timer.tmod;
			if(pg.t<0){
				switch(pg.step){
					case 0:
						pg.gotoAndPlay("hoNo");
						pg.t = 30;
						pg.step++
						break;
					case 1:
						var mc = Cs.game.dm.attach("mcOnde",Game.DP_PART)
						mc._x = pg._x;
						mc._y = pg._y;
						//
						for( var i=0; i<32; i++ ){
							var p = new Part( Cs.game.dm.attach("partPixel",Game.DP_PART));
							var a = -Math.random()*3.14
							var ca = Math.cos(a);
							var sa = Math.sin(a);
							var sp = 0.5+Math.random()*5
							var ray = 8
							p.x = pg._x+ca*ray
							p.y = pg._y+sa*ray	
							p.vx = ca*sp
							p.vy = sa*sp*2
							p.weight = 0.1+Math.random()*0.2
							
							p.timer = 10+Math.random()*30
							p.root.gotoAndStop(string(Std.random(p.root._totalframes)+1));
							//p.scale = 50+Math.random()*100
							//p.root._xscale = p.scale;
							//p.root._yscale = p.scale;
							p.fadeType = 0
						}
						
					
						//
						pg.removeMovieClip();
						pList.splice(x--,1);
						if(pList.length==0)Cs.game.initStep(11);
						break;
				}
			}
		}
	}
	
	function updateGrenades(){
		for( var i=0; i<gList.length; i++ ){
			var g = gList[i]
			var r = 5
			
			var nx = int((g.x-Cs.ML)/Cs.SQ)
			var ny = int((Cs.MD-g.y)/Cs.SQ)			
			
			if(g.x<Cs.ML+r || g.x>Cs.mcw-(r+Cs.ML)){
				g.x = Cs.mm(Cs.ML+r,g.x,Cs.mcw-(r+Cs.ML))
				g.vx *= -1
				g.vr = (Math.random()*2-1)*12
			}
			

			
			if(g.vy>0){

				
				if(g.px!=nx && Cs.game.grid[nx][ny] != null ){
					g.vx*=-1
					g.vr = (Math.random()*2-1)*12
				}
				
				if(g.py!=ny && Cs.game.grid[nx][ny] != null ){
					if( Std.random(1)==0){
						blast(g.px,g.py)
						g.kill();
						gList.splice(i--,1)

					}else{
						g.vy*=-0.8
						g.vr = (Math.random()*2-1)*12
					}
					
				}

			}
			
			g.px = nx;
			g.py = ny;
			
			if(g.y>Cs.mch+r){
				g.kill();
				gList.splice(i--,1)
			}
			
			
			
		}	
		if(gList.length==0){
			portrait.play();
			Cs.game.initStep(1)
		}		
	}
	
	function blast(x,y){
		for( var dx=-1; dx<=1; dx++ ){
			for( var dy=-1; dy<=1; dy++ ){
				var b  = Cs.game.grid[x+dx][y+dy]
				if(b!=null){
					b.kill();
				}
			}	
		}
		
		// BLAST
		var mc = Cs.game.dm.attach("mcExplode",Game.DP_PART)
		mc._x = (Cs.ML+x*Cs.SQ)
		mc._y = (Cs.MD-y*Cs.SQ)	
		mc._xscale = 50;
		mc._yscale = 50;
	
	}
	
	function nuke(x,y){
		for( var i=0; i<Cs.game.bList.length; i++ ){
			var b = Cs.game.bList[i];
			var dx = b.x - x;
			var dy = b.y - y;
			var dist = Math.sqrt(dx*dx+dy*dy);
			if( dist<2.8 ){

				for( var n=0; n<3; n++){
					var p = new Part(Cs.game.dm.attach("partIce",Game.DP_PART));
					var sp = 2
					p.x = b.root._x+(Math.random()*2-1)*10
					p.y = b.root._y+(Math.random()*2-1)*10
					//
					var ddx = p.x - (Cs.ML+x*Cs.SQ)
					var ddy = p.y - (Cs.MD-y*Cs.SQ)
					var a = Math.atan2(ddy,ddx)
					var ca = Math.cos(a)
					var sa = Math.sin(a)				
					//
					p.vx = ca*dist*sp
					p.vy = sa*dist*sp
					p.root.gotoAndPlay(string(Std.random(19)+1))
					p.timer = 10+Math.random()*50
					p.root._xscale = dist*40
					p.root._rotation = 90+a/0.0157
				}
				
				//
				b.kill();
				i--
			}
		}
		//
		var mc = Cs.game.dm.attach("mcExplode",Game.DP_PART)
		mc._x = (Cs.ML+x*Cs.SQ)
		mc._y = (Cs.MD-y*Cs.SQ)		
	}
		
	
//{	
}