class game.Bibli extends Game{//}
	
	
	
	// CONSTANTES
	static var RAY = 9;
	static var DIR = [
		{ x:1,	y:0	}
		{ x:0,	y:1	}
		{ x:-1,	y:0	}
		{ x:0,	y:-1	}
	]
	
	
	// VARIABLES
	var speed:float;
	var aList:Array<{>sp.Phys,pos:{x:int,y:int},t:float}>
	var grid:Array<Array<bool>>
	var last:Array<int>
	
	// MOVIECLIPS

	function new(){
		super();
	}

	function init(){
		gameTime = 400;
		super.init();
		airFriction = 1;
		speed = 2+dif*0.04
		last = new Array();
		grid = new Array();
		for( var x=0; x<3;x++ ){
			grid[x] = new Array();
			for( var y=0; y<3; y++ ){
				grid[x][y] = ( x==1 && y==1 )			
			}
		}
		
		
		attachElements();
	};
	
	function attachElements(){
		
		// ATOMES
		aList = new Array();
		for( var i=0; i<9; i++ ){
			var sp = downcast(newPhys("mcAtome"));
			sp.x = RAY+Math.random()*(Cs.mcw-2*RAY);
			sp.y = RAY+Math.random()*(Cs.mch-2*RAY);
			sp.flPhys = false;
			if(i==0){
				sp.skin.gotoAndStop("1");
				sp.pos = {x:0,y:0}
			}else{
				sp.skin.gotoAndStop("3");
				var a = Math.random()*6.28
				sp.vitx = Math.cos(a)*speed
				sp.vity = Math.sin(a)*speed				
			}
			sp.init();
			aList.push(sp)
		}
		
		
	}
	
	function update(){
		
		for( var i=0; i<aList.length; i++ ){
			var sp = aList[i]
			if( sp.x<RAY || sp.x>Cs.mcw-RAY ){
				sp.x = Cs.mm(RAY,sp.x,Cs.mcw-RAY)
				sp.vitx *= -1
			}
			if( sp.y<RAY || sp.y>Cs.mch-RAY ){
				sp.y = Cs.mm(RAY,sp.y,Cs.mch-RAY)
				sp.vity *= -1
			}
			
			if(sp.t!=null){
				sp.t-=Timer.tmod;
				if(sp.t<0)sp.t = null;
			}
			
			if(sp.pos!=null){
				//Log.print(sp.pos.x*RAY*2+":"+sp.pos.y*RAY*2)
				var p = {
					x:_xmouse + sp.pos.x*RAY*2
					y:_ymouse + sp.pos.y*RAY*2
				}
				//Log.print("--->"+p.x+":"+p.y)
				sp.toward(p,0.15,null)	
				//Log.print("dist")
				for( var n=0; n<aList.length; n++){
					var spo = aList[n]
					if(spo.pos==null && spo.t == null ){
						var dist = sp.getDist(spo)
						//Log.print(dist)
						if( dist<RAY*2 ){
							/*
							var dx = spo.x - sp.x
							var dy = spo.y - sp.y
							var pdx = int(dx/Math.abs(dx))
							var pdy = int(dy/Math.abs(dy))
							*/
							/*
							var a = sp.getAng(spo)
							var index = (int(Cs.mm(0,(a/6.28)*8+4,7))+4)%8
							var d = DIR[index]
							*/
							/*
							var a = sp.getAng(spo)
							if(a<0)a+=6.28;
							var index = Math.floor((a/6.28)*4)
							var d = DIR[index]
							var nx = sp.pos.x+d.x
							var ny = sp.pos.y+d.y
							*/
							var dx = spo.x - sp.x
							var dy = spo.y - sp.y
							var d = null
							if(Math.abs(dx)<Math.abs(dy)){
								d = {
									x:0
									y:int(dy/Math.abs(dy))
								}
							}else{
								d = {
									x:int(dx/Math.abs(dx))
									y:0
								}
							}
							var nx = sp.pos.x+d.x
							var ny = sp.pos.y+d.y
							if( grid[nx+1][ny+1] != true ){
								grid[nx+1][ny+1] = true;
								spo.pos = {x:nx,y:ny}
								spo.vitx = 0
								spo.vity = 0
								last.push(n)
								if( Math.abs(nx)<2 && Math.abs(ny)<2 ){
									spo.skin.gotoAndStop("2");
								}else{
									spo.skin.gotoAndStop("4");
								}
							}
						}
					}
				}
				
			}
			
			
		}
		
		
		switch(step){
			case 1:
				break;
		}
		super.update();
	}

	function click(){
		super.click()
		if(last.length>0){
			var sp = aList[last.pop()]
			grid[sp.pos.x+1][sp.pos.y+1] = false
			var a = Math.atan2(sp.pos.y,sp.pos.x)
			sp.vitx = Math.cos(a)*speed;
			sp.vity = Math.sin(a)*speed;
			sp.pos = null
			sp.t = 10
			sp.skin.gotoAndStop("3");
		}
	}
	
//{	
}

