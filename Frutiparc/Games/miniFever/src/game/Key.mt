class game.Key extends Game{//}


	var key:Sprite;
	var keyHole:MovieClip;
	var time:float;
	var speed:float;
	var doorFront:Sprite;
	var cadence:float;
	var flEndGame:bool;
	var flVictory:bool;
	var accy:float;
	var htserr:float;
	var bsserr:float;
	var margin:float;
	var speedKey:float;
	
	function new(){
		
		super();
	}

	function init(){
		gameTime = 520;
		super.init();
		time=0;
		speed=0;
		cadence=0;
		speedKey=0.5+dif*0.10;
		accy=0.6;
		htserr=100;
		bsserr=122;
		margin=5;
		attachElements();
	}
	
	function attachElements(){
		
			
		keyHole = dm.attach("mcKeyHole",Game.DP_SPRITE);
		keyHole._x=213;
		keyHole._y=119;
		
		key = newSprite("mcKey");
		key.x=0;
		key.y=90;
		key.init();
		
		doorFront = newSprite("mcDoorFront");
		doorFront.x=224.3;
		doorFront.y=119.8;
		doorFront.init();
		
		
	}
	
	function update(){
			
		var m = 50
		
		if(key.y<m){
			key.y=m
		}
		if(key.y>Cs.mch-m){
			key.y=Cs.mch-m
		}
		
		
		if( cadence<speedKey ){
			cadence=cadence+0.08
		}else{
			cadence=speedKey
		}
		

		if( (!flEndGame || flVictory) && key.x<220 ){
			key.x=key.x+cadence
			key.y=key.y+speed
		}
		speed *= 0.9
		
		if(_ymouse > Cs.mch*0.5){
			speed=speed+accy
		}
		if(_ymouse < Cs.mch*0.5){
			speed=speed-accy
		}		
		
		if (key.x>170){
			if(flEndGame){
				if(flVictory){
					if(key.y<htserr+margin){
						key.y=htserr+margin
					}
					if(key.y>bsserr){
						key.y=bsserr
					}
					if(key.x>keyHole._x){
						speed=0
						accy=0
						setWin(true)						
					}
					
				}
			}else{
				flEndGame = true
				if(key.y>htserr&&key.y<bsserr){
					flVictory = true;
				}else{
					speed=0
					accy=0
					setWin(false)
				}
			}
		
		}

		
		
		
		
		
		super.update();
	}	
		
			
		
		
		
			
//{	

}


