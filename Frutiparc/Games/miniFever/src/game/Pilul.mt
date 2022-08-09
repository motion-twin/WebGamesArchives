class game.Pilul extends Game{//}
	
	// CONSTANTES
	static var RAY = 12;
	static var FEAR_RAY = 60
	static var POS = [
		{x:11,y:213}
		{x:24,y:210}
		{x:97,y:67}
	]
	
	// VARIABLES
	var sens:int;
	var mList:Array<sp.Phys>
	
	// MOVIECLIPS
	var decor:MovieClip;
	var p:{>MovieClip,p:MovieClip};
	
	function new(){
		super();
	}

	function init(){
		gameTime = 600;
		super.init();
		sens = 1
		airFriction = 1
		attachElements();
	};
	
	function attachElements(){
		
		// LEVEL
		var lvl = Math.round(dif*0.03)
		gotoAndStop(string(lvl+1))
		
		// MICROBES
		mList = new Array()
		for( var i=0; i<4; i++ ){
			var mc = Std.getVar(this,"$m"+i)
			mc.gotoAndPlay(string(Std.random(5)+1))
			mc._alpha = 80
			
			var sp = newPhys("mcEmpty")
			sp.blastSkin(mc)
			sp.x = mc._x;
			sp.y = mc._y;
			sp.flPhys = false;
			sp.init();
			mList.push(sp)
		}

		
		/*
		// DECOR
		decor = dm.attach("mcPilulDecor",Game.DP_SPRITE)
		decor.gotoAndStop(string(lvl+1))
		
		
		// PILUL
		p = downcast(dm.attach("mcPilul",Game.DP_SPRITE))
		p._x = POS[lvl].x
		p._y = POS[lvl].y
		*/
		
		

	}
	
	function update(){
		super.update();
		switch(step){
			case 1:
				var a = p._rotation*0.0174
				var dx = _xmouse-p._x	
				var dy = _ymouse-p._y
				var da = Math.atan2(dy,dx) - p._rotation*0.0174
				while(da>3.14)da-=6.28;
				while(da<-3.14)da+=6.28;
				a += da*0.2*Timer.tmod;
				p._rotation = a/0.0174
				//
				var x = p._x + Math.cos(a)*RAY*sens
				var y = p._y + Math.sin(a)*RAY*sens
				if(decor.hitTest(x,y,true)){
					do{
						var lim = 0.1
						a -= Cs.mm(-lim, da*0.01, lim )
						x = p._x + Math.cos(a)*RAY*sens
						y = p._y + Math.sin(a)*RAY*sens
					}while(decor.hitTest(x,y,true))
					p._rotation = a/0.0174
					//
					sens *= -1
					p._x = x;
					p._y = y;
					p.p._x = 6*sens 
				}
				
				//
				var flDone = true;
				var pos ={x:p._x,y:p._y}
				for( var i=0; i<mList.length; i++ ){
					var sp = mList[i]
					var dist = sp.getDist(pos)
					if(dist<FEAR_RAY){
						var c = (FEAR_RAY-dist)/FEAR_RAY
						var s = 0.5
						var pa = sp.getAng(pos)
						sp.vitx -= Math.cos(pa)*c*s
						sp.vity -= Math.sin(pa)*c*s
						
						

					}
					var m = 10	
					if( sp.x<-m || sp.x>Cs.mcw+m || sp.y<-m || sp.y>Cs.mch+m ){
						sp.kill()
						mList.splice(i--,1)
					}					
					if(sp.vitx==0 && sp.vity==0)flDone = false;
					
					
				}
								
				if(flDone)flTimeProof=true;
				if(mList.length == 0)setWin(true);
				
				
				break;
		}
		
		
		
	}

//{	
}

