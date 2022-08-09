class game.Tapette extends Game{//}
	
	// CONSTANTES
	static var TRAY = 24
	
	// VARIABLES
	var toKill:int;
	var timer:float;
	var fList:Array<{>sp.Phys,trg:{x:float,y:float}}>
	
	// MOVIECLIPS
	var tap:sp.Phys;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 350
		super.init();
		airFriction = 0.95
		attachElements();
	};
	
	function attachElements(){
			

		
		// FLYS
		fList = new Array();
		toKill = 1+Math.floor(dif*0.12)
		for( var i=0; i<toKill; i++ ){
			var sp = downcast(newPhys("mcTapFly"))
			newTrg(sp)
			sp.x = sp.trg.x
			sp.y = sp.trg.y
			sp.flPhys = false;
			sp.weight = 1;
			sp.init();
			fList.push(sp)
		}
		
		// TAPETTE
		tap = newPhys("mcTapette")
		tap.x = Cs.mcw*0.5
		tap.y = Cs.mch*0.5
		tap.flPhys = false;
		tap.init();
	}
	
	function update(){
		
		// MOVE TAPETTE
		var mp = {x:_xmouse,y:_ymouse-60}
		var ox = tap.x
		tap.toward(mp,0.2,null)
		var dx = tap.x-ox
		tap.skin._rotation = -dx*1.5
		
		
		// MOVE FLYS
		for( var i=0; i<fList.length; i++ ){
			var sp = fList[i]
			if(!sp.flPhys){
				var dist = sp.getDist(sp.trg)
				
				if( dist<20 || Math.random()/Timer.tmod < 0.04 ){
					newTrg(sp)
				}
				
				sp.towardSpeed(sp.trg,0.1,0.8)
				
				// ESQUIVE
				var ray = dif
				var td = sp.getDist(tap)
				if( td < ray ){
					var a = tap.getAng(sp)
					var d = ray-td
					var c = 0.04
					sp.x += Math.cos(a)*d*c
					sp.y += Math.sin(a)*d*c					
					//sp.vitx += Math.cos(a)*d*c
					//sp.vity += Math.sin(a)*d*c
					
				}
				
				// ORIENT
				var a = sp.getAng(sp.trg)
				var fr = int((a/6.28)*40)
				if(fr<0)fr+=40;
				sp.skin.gotoAndStop(string(fr+1))
			}
		}		
		
		
		switch(step){
			case 2:
				timer -= Timer.tmod;
				if(timer<0){
					setWin(true);
				}
				break;
		}
		
		super.update();
	}
	
	function click(){
		
		var flFlash = false;
		for( var i=0; i<fList.length; i++ ){
			var sp = fList[i]
			if(!sp.flPhys){
				
				var dx = sp.x - tap.x;
				var dy = sp.y - tap.y;
				if( Math.abs(dx)<TRAY && Math.abs(dy)<TRAY ){
					sp.flPhys = true;
					sp.vitx = 0
					sp.vity = 0
					toKill--;
					if(toKill==0){
						step=2
						timer = 12
					}
					sp.skin.gotoAndStop("death")
					sp.skin._rotation = Math.random()*360
					
					var mc = dm.attach("mcFlyTache",Game.DP_SPRITE2)
					mc._x = sp.x;
					mc._y = sp.y;
					mc._rotation = Math.random()*360
					mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
					
					flFlash = true;
					
				}
			}
		}
		
		tap.skin.gotoAndPlay("2")
		downcast(tap.skin).flash._visible = flFlash;
		
		
		
	}
	
	function newTrg(sp){
		var m = 30
		sp.trg = {
			x: m+Math.random()*(Cs.mcw-2*m)
			y: m+Math.random()*(Cs.mch-2*m)
		}
	}
	
	
	
	
//{	
}

