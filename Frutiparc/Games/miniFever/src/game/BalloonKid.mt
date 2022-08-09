class game.BalloonKid extends Game{//}
	
	// CONSTANTES
	static var MOD = [120,360,480]
	
	// VARIABLES
	var bal:int;
	var speed:float
	var timer:float
	var cList:Array<MovieClip>;
	var sList:Array<Sprite>;
	
	// MOVIECLIPS
	var hero:sp.Phys;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 370
		super.init();
		speed = 1+dif*0.022
		sList = new Array();
		timer = 0;
		bal = 3-Math.round(dif*0.01)
		attachElements();
		
		for( var i=0; i<50/speed; i++ )moveSpikes();		
	};
	
	function attachElements(){
		// CLOUD
		cList = new Array();
		for( var i=0; i<3; i++ ){
			var mc = dm.attach("mcCloudBar",Game.DP_SPRITE)
			mc._x = 0
			mc._y = Cs.mch
			mc.gotoAndStop(string(3-i))
			cList.push(mc)
		}
		
		// HERO
		hero = newPhys("mcBananaBalloon")
		hero.weight = 0.1
		hero.x = Cs.mcw*0.8
		hero.y = Cs.mch*0.5
		hero.init();
		updateBalloons();
		
	}
	
	function update(){
		
		moveClouds();
		moveSpikes();
		
		if(bal>0){
			if(hero.y>Cs.mch)drop();
			if(hero.y<0)drop();
		}
		
		var dx = _xmouse - hero.x
		var lim = 1.5
		hero.x += Cs.mm(-lim,dx*0.05,lim)*Timer.tmod;
		
		//
		super.update();
		

		
	}
	
	function addSpike(){
	
		var sp = newSprite("mcBouletteKipic")
		var m = 20
		sp.x = -20
		sp.y = m+Math.random()*(Cs.mch-(2*m))
		sp.init();
		sList.push(sp)
	}
	
	function moveSpikes(){
		// ADD
		timer -= Timer.tmod;
		if(timer<0){
			timer = 30/speed
			addSpike();
		}
		// MOVE
		for( var i=0; i<sList.length; i++ ){
			
			var sp = sList[i];
			sp.x += speed*Timer.tmod;
			var flDeath = sp.x > Cs.mcw+16
			
			if(bal>0 && base.flWin == null ){
				var pos = { x:hero.x, y:hero.y-22 }
				var dist = sp.getDist(pos)
				if( dist < 20 ){
					flDeath = true;
					bal--;
					updateBalloons();
				}
				pos = { x:hero.x, y:hero.y+10 }
				dist = sp.getDist(pos)
				if( dist < 16 ){
					hero.vity = -6
					hero.vitr = 20
					drop()

					
				}				
			}
			
			if(flDeath){
				sList.splice(i--,1)
				sp.kill()
			}
		}		
	}
	
	function drop(){
		for( var n=0; n<bal; n++ ){
			var p = newPart("mcKidBalloon")
			p.x = hero.x+(n-1)*8;
			p.y = hero.y-22;
			p.vitx = hero.vitx + ((Math.random()*2-1)+(n-1))*0.8
			p.vity = hero.vity + (Math.random()*2-1)*0.3
			p.init();
			p.weight = -0.1
		}
		bal = 0;
		updateBalloons();	
	}	
	
	function moveClouds(){
		for( var i=0; i<cList.length; i++ ){
			var mc = cList[i];
			mc._x = ( mc._x+(i+0.5)*speed*0.3*Timer.tmod )%MOD[i]
		}
	}
	
	function updateBalloons(){
		if(bal>0){
			downcast(hero.skin).bg.gotoAndStop(string(bal))
		}else{
			hero.skin.gotoAndPlay("fall")
			setWin(false)
		}
		hero.weight = 0.35 - bal*0.08
	}
	
	function click(){
		if(bal>0){
			hero.vity -= 2;
			hero.skin.gotoAndPlay("throw")
		}
	}
	
	function outOfTime(){
		setWin(true)
	}
	
	
//{	
}

