class game.WalkFlower extends Game{//}
	
	// CONSTANTES
	var fRay:float;
	
	// VARIABLES
	var iMouse:int;
	var iCo:int;
	var fList:Array< { top:MovieClip, tige:MovieClip, h:float } >
	var bList:Array<MovieClip>
	var speed:float;
	var cPos:float;
	var tension:float;
	var timer:float;
	
	
	// MOVIECLIPS
	var co:sp.Phys;
	var present:sp.Phys;
	var liane:MovieClip

	function new(){
		super();
	}

	function init(){
		gameTime = 650-dif*2;
		super.init();
		iMouse = 0;
		iCo = 0;
		fRay = 25//27
		cPos = -1
		tension = 90 - (Math.random()*2-1)*(dif*0.4)
		speed = 0.01 + dif*0.0004
		attachElements();
	};
	
	function attachElements(){
		
		// FLOWER
		fList = new Array();
		var max = 4
		var m = 20
		var ec = (Cs.mcw-2*m)/max
		for(var i=0; i<max; i++){
			var h = 40
			var x = m+(i+0.5)*ec;
			
			var tige = dm.attach( "mcTige", Game.DP_SPRITE )
			tige._x = x
			tige._y = Cs.mch
			tige._yscale = h
			
			var top = dm.attach( "mcFlowerTop", Game.DP_SPRITE )
			top._x = x
			top._y = Cs.mch-h;
			
			fList.push({top:top,tige:tige,h:h})		
		}
		// LIANE
		liane = downcast(dm.attach("mcLiane"Game.DP_SPRITE))
		liane._x = Cs.mcw-12;
		liane._y = 0
		var l = downcast(liane)
		bList = [l.b0,l.b1,l.b2,l.b3]

		
		// COCCINELLE
		co = newPhys("mcCocci")
		co.flPhys = false;
		co.init();
		
		// PRESENT
		present = newPhys("mcPresent");
		present.x  = Cs.mcw-12;
		present.y = 0
		present.vitx = (Math.random()*2-1)*3
		present.weight = 0.5
		present.init();
		

		

		

	}
	
	function update(){
		movePresent();
		switch(step){
			case 1:
				moveFlower();
				moveCocci();
				break;
			case 2:
				co.towardSpeed(present,0.1,1)
				timer-=Timer.tmod;
				if(timer<0){
					setWin(true)
				}
				break;
		}
		
		super.update();
	}
	
	function movePresent(){
		var p = {x:Cs.mcw-12,y:0}
		var dist = present.getDist(p)
		var a = present.getAng(p);
		if( dist > tension ){
			var c = (dist-tension)/tension;
			
			var power = 2;
			present.vitx += Math.cos(a)*c*power*Timer.tmod
			present.vity += Math.sin(a)*c*power*Timer.tmod
		}
		var r = 5
		if( present.x > Cs.mcw-r ){
			present.x = Cs.mcw-r
			present.vitx *= -0.8
		}
		
		
		// LIANE
		liane._x = present.x
		liane._y = present.y
		liane._xscale = dist;
		liane._rotation = a/0.0174
		for( var i=0; i<bList.length; i++){
			var mc = bList[i]
			mc._xscale = 10000/liane._xscale
		}

		
	}
	
	function moveCocci(){
		speed *= 1.002
		var cur = fList[iCo]
		cPos += speed*Timer.tmod
		co.x = cur.top._x + (cPos*fRay)
		co.y = (Cs.mch - cur.h)+(Math.random()*2-1)*0.3
	
		if(cPos>1){
			iCo++
			var next =  fList[iCo]
			var dif = Math.abs(cur.h - next.h)
			if( dif < 16 && iCo<4 ){
				cPos -= 2
				
			}else{
				flyAway();
			}
		}
		
		// CHECK PRESENT
		var dist = co.getDist(present)
		if( dist < 30 ){
			step = 2
			timer = 10;
			co.skin.gotoAndPlay("fly");
		}
		
		
	}
	
	function moveFlower(){
		var cur = fList[iMouse]
		var vity = -((_ymouse/Cs.mch)*2-1)*14
		cur.h = Math.min(Math.max(20,cur.h+vity*Timer.tmod),200)
		cur.top._y = Cs.mch-cur.h
		cur.tige._yscale = cur.h	
	}	
	
	function click(){
		super.click();
		if(iMouse<4)iMouse++;
	}
	
	function flyAway(){
		step = 3
		setWin(false)
		co.skin.gotoAndPlay("angry");
	}
	
	
	
//{	
}

