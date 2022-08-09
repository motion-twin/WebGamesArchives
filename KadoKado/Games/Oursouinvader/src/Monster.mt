class Monster extends Phys {//}

	var flKamikaze:bool;
	
	var tx:float;
	var ty:float;
	
	var ray:float;
	var flDeath:bool;
	var mType:int;

	var diff:float;
	var shield:int;
	var nextShot:int;
	
	var coolDownOcto:int;
	var coolDownBomber:int;
	var coolDownOyster:int;
	
	var step:int;
	
	//Oyster param
	var isClosed:bool;
	var nextOpeningTimer:int;
	var openTimer:int;
	var openingCoolDown:int;
	var openCoolDown:int;
	
	
	
	var introSpeedMax:float;
	var introSpeedCoef:float;
	
	var score :KKConst;


	function new(mc,type2Monstre){

		Cs.game.monsterList.push(this)
		super(mc);
		mType = type2Monstre;
	
		flKamikaze = false;
		frict = 0.92
	
		var m = 20
		introSpeedMax = 0.4 + Math.random()*0.9
		introSpeedCoef = 0.05 + Math.random()*0.01
	
		switch(Std.random(3)){
			case 0:
				x = Math.random()*Cs.mcw
				y = -m		
				break;
			case 1:
				x = -m
				y = Math.random()*Cs.mch*0.5			
				break;
			case 2:
				x = Cs.mcw+m
				y = Math.random()*Cs.mch*0.5				
				break;			
		}
		//
		initState();
	
		
		step = 0
		
	}
	
	function initState(){
	
		
		// HellCrabe
		if (mType ==1 ){
			ray = 13;
			diff = 1;
			shield = 0;
			score = Cs.SCORE_CRABE;
			
			var flt = new flash.filters.GlowFilter();
			flt.color = 0xEC4F0A;
			flt.alpha = 0.1;
			flt.blurX = 10;
			flt.blurY = 10;
			flt.strength = 2;
			root.filters = [flt];
		}

		// Octopussy
		if (mType == 2 ){
			ray = 12;
			diff = 2;
			shield = 1;
			score = Cs.SCORE_OCTO;
			coolDownOcto = 90;
			nextShot = coolDownOcto + 3*Std.random(coolDownOcto);
			
			var flt = new flash.filters.GlowFilter();
			flt.color = 0xD230FD;
			flt.alpha = 0.4;
			flt.blurX = 5;
			flt.blurY = 5;
			flt.strength = 2;
			root.filters = [flt];
		}

		// Bomber
		if (mType == 3 ){
			ray = 12;
			diff = 4;
			shield = 3;
			score = Cs.SCORE_BOMBER;
			coolDownBomber = 80;
			nextShot = coolDownBomber + 3*Std.random(coolDownBomber);
			
			var flt = new flash.filters.GlowFilter();
			flt.color = 0x3BCF40;
			flt.alpha = 0.4;
			flt.blurX = 15;
			flt.blurY = 15;
			flt.strength = 1;
			root.filters = [flt];
		}

		// Oyster
		if (mType == 4 ){
			ray = 12;
			diff = 8;
			shield = 1;
			score = Cs.SCORE_OYSTER;
			coolDownOyster = 40;
			nextShot = coolDownOyster + 3*Std.random(coolDownOyster);
			
			isClosed = true;
			openingCoolDown = 60;
			openCoolDown = 50;
			nextOpeningTimer = openingCoolDown + 3*Std.random(openingCoolDown);
			
			var flt = new flash.filters.GlowFilter();
			flt.color = 0x246CD4;
			flt.alpha = 0.4;
			flt.blurX = 15;
			flt.blurY = 15;
			flt.strength = 1;
			root.filters = [flt];
		}
		
		// Mega Octopussy
		if (mType == 5 ){
			ray = 30;
			diff = 2;
			shield = 80;
			score = Cs.SCORE_BOSS;
			coolDownOcto = 12;
			nextShot = coolDownOcto + 3*Std.random(coolDownOcto);
			root._xscale = 200;
			root._yscale = 200;			
			

			
			var flt = new flash.filters.GlowFilter();
			flt.color = 0xD230FD;
			flt.alpha = 0.4;
			flt.blurX = 20;
			flt.blurY = 20;
			flt.strength = 2;
			root.filters = [flt];
		}
		//root.filters = []
		
	}


	function update () {
		super.update()
		

		switch(step){
			case 0:
				var trg = {x:tx,y:ty}
				speedToward(trg,introSpeedCoef,introSpeedMax)
				
				if(getDist(trg)<8){
					vx = 0
					vy = 0		
					Cs.game.nbIntro++
					step = 10
				}
			
				break;
			case 1:
				move();
				
				if(flKamikaze ){
					speedToward(Cs.game.hero,introSpeedCoef,introSpeedMax*0.5)
					
				}else{
					if(y>Cs.game.mcLim._y){
						vx = Cs.game.direction*Cs.game.mSpeed
						flKamikaze = true;
					}
				}
				
				break;
			case 10:
				var trg = {x:tx,y:ty}
				toward(trg,0.1,1)
				break;
		}	

	}

	function move(){
		checkMonster();
		
		// Crabe
		if (mType == 1 ){
			downcast(root).cEyeI.mcEyeAnim._rotation = (Math.atan2((y - Cs.game.hero.root._y ), (x - Cs.game.hero.root._x))) / (Math.PI / 180) + 90;
		}
		// Octopussy
		if (mType == 2 ){
			downcast(root).mcOctoEye.mcOctoEyeAnim._rotation = (Math.atan2((y - Cs.game.hero.root._y ), (x - Cs.game.hero.root._x))) / (Math.PI / 180) + 90;
			if ( nextShot == 0 ){
				newShot(mType);
				nextShot = coolDownOcto + 3*Std.random(coolDownOcto);	
			}else{
				nextShot--;	
			}
			
		}

		// Bombers
		if (mType == 3 ){
			if ( nextShot == 0 ){
				newShot(mType);
				nextShot = coolDownBomber + 3*Std.random(coolDownBomber);	
			}else{
				nextShot--;	
			}
			
		}

		//Oyster
		if (mType == 4 ){
			if ( nextOpeningTimer == 0 ){
				if (isClosed){
					openTimer = openCoolDown + Std.random(openCoolDown);
					isClosed = false;
					root.gotoAndPlay("opening");
					} 
				else {
					if (openTimer == 0) {
						root.gotoAndPlay("close");
						nextOpeningTimer = openingCoolDown + Std.random(openingCoolDown);
						isClosed = true;
					}
					else {
						if ( nextShot == 0 ){
							newShot(mType);
							nextShot = coolDownOyster + 3*Std.random(coolDownOyster);	
							isClosed = true;
						}else{
							nextShot--;
							openTimer-- ;	
						}						
					}
				}
			}
			else {
				nextOpeningTimer-- ;
			}
		}
		
		// MEGA Octopussy
		if (mType == 5 ){
			downcast(root).mcOctoEye.mcOctoEyeAnim._rotation = (Math.atan2((y - Cs.game.hero.root._y ), (x - Cs.game.hero.root._x))) / (Math.PI / 180) + 90;
			if ( nextShot == 0 ){
				newShot(mType);
				nextShot = coolDownOcto + 3*Std.random(coolDownOcto);	
			}else{
				nextShot--;	
			}
			
		}	
	}
	
/************************************************************************ SHOOT  */
	function newShot(type){
		// Octopussy
		if (type == 2) {
			var shot = new Shot(null,type);	
			shot.vy = shot.sShot;
			shot.x = x;		
			shot.y = y - (ray/2);
			root.gotoAndPlay("shoot");		
		}
		//bomber
		if (type == 3) {
			var shot = new Shot(null,type);	
			shot.vy = shot.sShot;
			shot.x = x;		
			shot.y = y - (ray/2);
			root.gotoAndPlay("shoot");		
		}		
		//Oyster
		if (type == 4) {
			var shot = new Shot(null,type);	
			shot.vy = shot.sShot;
			shot.x = x;		
			shot.y = y - (ray/2);
			root.gotoAndPlay("shoot");		
		}		
		//BOSS
		if (type == 5) {
			var shot = new Shot(null,type);	
			shot.vy = shot.sShot;
			shot.x = x;		
			shot.y = y - (ray/2);
			root.gotoAndPlay("shoot");		
		}	
	}

	function checkMonster() {
		if(y> (260 - (ray+10))){
			isKilling()
		}
	}
	
	
	function isKilling(){
		var hero = Cs.game.hero ;
		var xminHero = hero.x - hero.hWidth;
		var xmaxHero = hero.x + hero.hWidth;
		var yminHero = hero.y - hero.hHeight;
		var ymaxHero = hero.y + hero.hHeight;
		
		var xminMonster = x - ray;
		var xmaxMonster = x + ray;
		var yminMonster = y - ray;
		var ymaxMonster = y + ray;
		
		if 	(( ymaxMonster >= yminHero) &&( ymaxMonster <= ymaxHero )) {
			if 	(( xminMonster <= xminHero) &&( xminMonster >= xmaxHero ))  {
					//explode();
					Cs.game.hero.shooted(this);
			}
			if 	(( xmaxMonster >= xminHero) &&( xmaxMonster <= xmaxHero ))  {
					//explode();
					Cs.game.hero.shooted(this);
			}
			
		}
	}

	function shooted(){
		if (shield == 0){
			explode();
		}
		else {
			// Crabe
			if (mType == 1 ){
			}
			// Octopussy
			if (mType == 2 ){
				shield--;
				root.gotoAndPlay("ouch");
				if(Std.random(2) == 0){root._xscale = -100;}
			}
	
			// Bombers
			if (mType == 3 ){
				shield--;
				root.gotoAndPlay("ouch");
				if(Std.random(2) == 0){root._xscale = -100;}
			}
	
			//Oyster
			if ( (mType == 4 ) && !isClosed){
				shield--;
				root.gotoAndPlay("ouch");
				if(Std.random(2) == 0){root._xscale = -100;}
				isClosed = true;
			}
			// Octopussy
			if (mType == 5 ){
				shield--;
				root.gotoAndPlay("ouch");
				if(Std.random(2) == 0){root._xscale = -200;}
			}
		}
	}

	function explode(){
		vx = Cs.game.direction*Cs.game.mSpeed
		
		if( Std.random(10)==0 ){
			var b = new Bonus(null);
			b.x = x;
			b.y = y;
			b.updatePos();
		}
		KKApi.addScore(score);
		Cs.game.dispScore(score,x,y)
		eAnim();
		root.gotoAndPlay("die");
		root = null
		kill();
	}

	function eAnim(){
		flDeath = true;
		if ( mType != 5) {
			if (Std.random(2) == 0){root._xscale = -100;} 
		}else {
			if (Std.random(2) == 0){
				root._xscale = -200;} 
			}
		
	}

	function kill(){
		Cs.game.monsterList.remove(this)
		super.kill();
	}
//{
}
