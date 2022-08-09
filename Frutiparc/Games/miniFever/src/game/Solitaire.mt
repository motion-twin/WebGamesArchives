class game.Solitaire extends Game{//}
	
	
	
	// CONSTANTES
	static var DIR = [{x:1,y:0},{x:0,y:1},{x:-1,y:0},{x:0,y:-1}]
	static var ECART = 17
	static var ZOOM = 1.8
	// VARIABLES
	var trg:{x:float,y:float}
	var nx:int;
	var ny:int;
	var grid:Array<Array<{c:MovieClip,p:MovieClip}>>
	var pList:Array<MovieClip>
	var cList:Array<{c:MovieClip,di:int}>
	// MOVIECLIPS

	
	function new(){
		super();
	}

	function init(){
		gameTime = 350+dif*2
		super.init();
		attachElements();
	};
	
	function attachElements(){
		var c = 6
		
		// CASES
		var m = (Cs.mcw-(c-1)*ECART*ZOOM)*0.5
		grid = new Array();
		for( var x=0; x<c; x++ ){
			grid[x] = new Array();
			for( var y=0; y<c; y++ ){
				var mc = dm.attach( "mcSolitaireCase", Game.DP_SPRITE )
				mc._x = m + x*ECART*ZOOM
				mc._y = m + y*ECART*ZOOM
				mc._xscale = ZOOM*100
				mc._yscale = ZOOM*100
				mc.stop();
				mc.onPress = callback(this,validate,x,y)
				grid[x][y] = { c:mc, p:null }
			}
		}
		
		// PIONS
		pList = new Array();
		var mid = int(c*0.5)
		var list = [{x:mid,y:mid}]
		newPion(mid,mid)
		var max = 2+dif*0.08

		for( var i=0; i<max; i++){
			var flBreak = false;
			//var to = 0;
			while(true){
				var index = Std.random(list.length);
				var p = list[index]
				var dir = Std.cast(Tools.shuffle)(DIR.duplicate());
				var o0 = grid[p.x][p.y];
				for( var n=0; n<dir.length; n++ ){
					var d = dir[n];
					var o1 = grid[p.x+d.x][p.y+d.y];
					var o2 = grid[p.x+d.x*2][p.y+d.y*2];
					if( o1.p == null && o2.p == null && o1!=null && o2!=null ){
						list.splice(index--,1);
						o1.p = o0.p;
						o1.p._x = o1.c._x
						o1.p._y = o1.c._y
						o0.p = null;
						newPion(p.x+d.x*2,p.y+d.y*2);
						list.push({x:p.x+d.x,y:p.y+d.y});
						list.push({x:p.x+d.x*2,y:p.y+d.y*2});
						flBreak = true;
						break;
					}
					
				}
				if(flBreak)break;
				/*
				if(to++>100){
					Log.trace("infini!")
					break;
				}
				*/
				
			}
		}

	}
	
	function newPion(x,y){
		var o = grid[x][y]
		var mc = dm.attach( "mcSolitairePion", Game.DP_SPRITE );
		mc._x = o.c._x;
		mc._y = o.c._y;
		mc._xscale = ZOOM*100
		mc._yscale = ZOOM*100
		pList.push(mc);
		o.p = mc;
	}
	
	function update(){
		
		for( var i=0; i<pList.length; i++){
			var mc = pList[i]
			if(i==0 && step>1){
				if(step==2){
					var dx = _xmouse - mc._x
					var dy = _ymouse - mc._y
					var a = Math.atan2(dy,dx)
					var ta = Math.round(a/1.57)*1.57
					var da = ta - (mc._rotation*0.0174)
					da = Cs.round(da,3.14)
					mc._rotation += (da/0.0174)*0.2*Timer.tmod;
					if(mc._currentframe <15)mc.nextFrame();
				}else if(step==3){
					var dx = trg.x - mc._x
					var dy = trg.y - mc._y
					//var dist = Math.sqrt(dx*dx+dy*dy)
					//var a = Math.atan2(dy,dx)
					
					mc._x += dx*0.5*Timer.tmod;
					mc._y += dy*0.5*Timer.tmod;
					var lim = 1
					if( Math.abs(dx)<lim && Math.abs(dy)<lim ){
						mc._x = trg.x;
						mc._y = trg.y;
						step = 1
						validate(nx,ny)
					}
					
				}
			}else{
				mc.prevFrame();
				mc._rotation *= 0.5
			}
		}
		//Log.print(pList.length)
		if(pList.length==1)setWin(true);
		

		super.update();
	}
	
	function validate(x,y){
		
		var o =  grid[x][y]
		if( step != 3 && o.p!=null ){
			if( step == 2){
				while(cList.length>0)cList.pop().c.gotoAndStop("1")
				if( o.p==pList[0] ){
					step = 1
					return;
				}
				
			}
			step = 2
			cList = new Array();
			for( var i=0; i<DIR.length; i++ ){
				var d = DIR[i]
				var flValidate = true;
				var no = null
				for(var n=0; n<2; n++){
					var nx = x+d.x*(n+1);
					var ny = y+d.y*(n+1);
					no = grid[nx][ny];
					if( n==0 && no.p==null ){
						flValidate = false;
						break;
					}
					if( n==1 && no.p!=null ){
						flValidate = false;
						break;
					}
				}

				if( flValidate ){
					no.c.gotoAndStop("2")
					cList.push({c:no.c,di:i})
				}
			}
			pList.remove(o.p)
			pList.unshift(o.p)
		}
		
		if( step == 2 &&  o.c._currentframe == 2 ){
			
			step = 3
			
			// CLEAN

			for( var i=0; i< cList.length; i++ ){
				var info = cList[i]
				info.c.gotoAndStop("1")
				if( info.c == o.c ){
					var d = DIR[info.di]
					var o2 = grid[x-d.x][y-d.y]
					pList.remove(o2.p)
					var pmax = 8
					for( var n=0; n<pmax; n++ ){
						var a = 6.28*n/pmax
						var ca = Math.cos(a)
						var sa = Math.sin(a)
						var p = newPart("mcSolitairePion")
						var ray = ECART*0.75
						var speed = 2
						p.x = o2.p._x// + ca*ray
						p.y = o2.p._y// + sa*ray
						p.vitx = ca*speed
						p.vity = sa*speed
						p.flPhys = false;
						p.scale = 50
						p.timer = 10+Math.random()*5
						p.timerFadeType = 1
						p.init();
					}
					o2.p._rotation = pList[0]._rotation
					o2.p.gotoAndPlay("destroy")
					o2.p = null
					
					o2 = grid[x-d.x*2][y-d.y*2]
					o.p = o2.p
					o2.p = null
					
					
				}

			}
			
			// TRG
			trg = { 
				x:o.c._x,
				y:o.c._y
			}
			nx = x;
			ny = y;
			
		}		
	}
	
	
//{	
}
















