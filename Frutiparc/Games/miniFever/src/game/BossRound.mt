class game.BossRound extends Game{//}
	
	
	
	// CONSTANTES
	static var SPEED = 3
	static var SRAY = 112
	// VARIABLES
	var density:float
	var angle:float;
	var cooldown:float;
	var timer:float;
	var dec:Array<float>
	var wList:Array<Array<{>Sprite,ray:float,a:float,op:{x:float,y:float}}>>;
	var sList:Array<sp.Phys>;
	
	
	// MOVIECLIPS
	var boss:MovieClip;
	var ship:MovieClip;

	function new(){
		super();
	}

	function init(){
		gameTime = 480
		super.init();
		sList = new Array();
		cooldown = 0;
		density = 23-dif*0.12//14
		attachElements();
	};
	
	function attachElements(){
		
		// BOSS
		boss = dm.attach("mcRoundBoss",Game.DP_SPRITE)
		boss._x = Cs.mcw*0.5;
		boss._y = Cs.mch*0.5;
		
		
		// WAVES
		wList = new Array();
		dec = new Array();
		for( var i=0; i<2; i++ ){
			wList[i] = new Array();
			dec[i] = 0;
			var ray = 44+i*28;
			var max = int((6.28*ray)/density);
			for( var n=0; n<max; n++ ){
				var sp = downcast(newSprite("mcBossRoundSmall"))
				sp.a = (n/max)*6.28;
				sp.x = boss._x + Math.cos(sp.a)*ray;
				sp.y = boss._y + Math.sin(sp.a)*ray;
				sp.ray = ray;
				sp.init();
				wList[i].push(sp);
			}			
		}
		
		// SHIP
		ship = dm.attach("mcBossRoundShip",Game.DP_FRONT);
		ship._x  = boss._x;
		ship._y  = boss._y + SRAY;
		
		
	}
	
	function update(){

		moveWaves();
		moveShip();

		
		if(timer!=null){
			timer-=Timer.tmod;
			if(timer<0){
				setWin(true)
				//timer = null
			}
			for( var i=0; i<wList.length; i++ ){
				var list = wList[i]
				for( var n=0; n<list.length; n++ ){
					var sp = list[n]
					sp.ray += 10-i*3
					sp.ray *= 1.1
				}
				
				
				
			}
			
			
		}else{
			for( var i=0; i<sList.length; i++ ){
				var sp = sList[i]
				if( sp.getDist({x:boss._x,y:boss._y}) < 22 ){
					boss.gotoAndPlay("death");
					timer = 16
					flTimeProof = true;
				}
			}
		}
		
		super.update();
	}
	
	function moveWaves(){
		for( var i=0; i<wList.length; i++ ){
			var list = wList[i]
			var d = dec[i]
			dec[i] = (d+(SPEED/(1+i*0.8))*(i*2-1))%628
			for( var n=0; n<list.length; n++ ){
				
				// DEPLACEMENT
				var sp = list[n]
				var a = sp.a + d/100;
				sp.x = boss._x + Math.cos(a)*sp.ray
				sp.y = boss._y + Math.sin(a)*sp.ray
				
				for( var k=0; k<sList.length; k++ ){
					var shot = sList[k]
					var dist = shot.getDist(sp)
					if(dist<8){
						
						// VIT
						var vx = sp.x - sp.op.x
						var vy = sp.y - sp.op.y
						
						// PARTS
						for( var b=0; b<10; b++ ){
							var p = newPart("partBossRoundSmall");
							var ang =Math.random()*6.28;
							var ca = Math.cos(ang);
							var sa = Math.sin(ang);
							var r = 3;
							var speed = 0.2+Math.random()*1.5;
							p.x = sp.x + ca*r;
							p.y = sp.y + sa*r;
							p.vitx = ca*speed + vx;
							p.vity = sa*speed + vy;
							p.vitr = (Math.random()*2-1)*16
							p.flPhys = false;
							p.timer = 12+Math.random()*12;
							p.friction = 0.97
							p.timerFadeType = 1
							p.init();
							p.skin.gotoAndStop(string(b+1))
							
						}
						
						
						// CLEAN
						sList.splice(k--,1)
						shot.kill();
						wList[i].splice(n--,1)
						sp.kill();
						break;
					}
					
				}
				// OLD POSITIONS
				sp.op = { x:sp.x, y:sp.y }
				
				
			}
			
			
			
		}
	}

	function moveShip(){
		var c = Cs.mm(0,_xmouse/Cs.mcw,1)
		var a = 1.57 - (c*2-1)*1.2
		ship._x = boss._x + Math.cos(a)*SRAY
		ship._y = boss._y + Math.sin(a)*SRAY
		ship._rotation = a/0.0174

		if(cooldown>0){
			cooldown-=Timer.tmod;
		}else{
			if(base.flPress){
				//Log.trace("---")
				a -= 3.14
				cooldown = 16
				var sp = newPhys("mcBossRoundShot")
				sp.x = ship._x
				sp.y = ship._y
				var speed = 4
				sp.vitx = Math.cos(a)*speed
				sp.vity = Math.sin(a)*speed
				sp.flPhys = false;
				sp.init();
				sp.skin._rotation = a/0.0174
				sList.push(sp)
			}
		}	
	}
	

	
//{	
}

