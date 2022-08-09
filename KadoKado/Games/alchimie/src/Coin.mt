class Coin {//}

	var pList:Array<sp.Part>
	var trg:Coin;
	var timer:float;
	var prc:float;
	var step:int;
	
	var nextId:int;
	
	var id : int;
	var game : Game;
	var mc : MovieClip;
	var group : Array<Coin>;
	var dy : float;

	var x : int;
	var y : int;

	function new(g,x,y) {
		game = g;
		dy = 0;
		mc = game.dmanager.attach("coin",Const.PLAN_COIN);
		mc._x = x * Const.COIN_SIZE + Const.POS_X;
		mc._y = y * Const.COIN_SIZE + Const.POS_Y;
		mc._xscale = 100 * 30 / 24;
		mc._yscale = 100 * 30 / 24;
		//
		pList = new Array();
	}

	function setId(id) {
		this.id = id;
		mc.gotoAndStop(string(id+1));
	}

	function gravityInit() {
		dy += Const.COIN_SIZE;
	}

	function gravityUpdate() {
		if( dy <= 0 )
			return false;
		var s = Math.min(20 * Timer.tmod,Const.COIN_SIZE/2);
		dy -= s;
		mc._y += s;
		return (dy > 0);
	}

	function recall() {
		mc._y += dy;
		dy = 0;
	}

	function explodeInit(c) {
		trg = c
		prc = 100
		step = 0
		/*
		for( var i=0; i<8; i++ ){
			var sp = game.newPart("partLightFlip")
			var a = Math.random()*6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var p = getPos()
			var speed = 4+Math.random()*8
			sp.x = p.x + ca*4;
			sp.y = p.y + sa*4;
			sp.vitx = ca*speed
			sp.vity = sa*speed
			sp.friction = 0.9
			sp.scale = 70+Math.random()*50
			sp.init();
			trg.pList.push(sp)
		}
		*/
		/*
		var i;
		for(i=0;i<10;i++)
			game.particules.add(mc._x,mc._y);
		*/
		
	}

	function explodeUpdate() {
		/*
		mc._alpha -= 10 * Timer.tmod;
		if( mc._alpha <= 0 ) {
			mc.removeMovieClip();
			return false;
		}
		*/
		
		switch( step ){
			case 0:
				//prc = Math.max( (prc*Math.pow(0.5,Timer.tmod))-5, 0 )
				prc = Math.max(prc-20*Timer.tmod,0)
				Mc.setPercentColor(mc,100-prc,0xFFFFFF)
				if( prc == 0 ){
					
					var p = getPos();

					// BIG EXPLO
					var explo = game.newPart("partExplosion")
					explo.x = p.x;
					explo.y = p.y;
					explo.scale = 80
					explo.init();
					explo.skin._rotation = Math.random()*360

					// SMALL PARTS
					for( var i=0; i<6; i++ ){	//6
						var sp = game.newPart("partLightFlip")
						var a = Math.random()*6.28;
						var ca = Math.cos(a);
						var sa = Math.sin(a);
						
						var speed = 4+Math.random()*8;
						sp.x = p.x + ca*4;
						sp.y = p.y + sa*4;;
						sp.vitx = ca*speed
						sp.vity = sa*speed;
						sp.friction = 0.9;
						sp.scale = 50+Math.random()*50;
						sp.init();
						trg.pList.push(sp);
					}

					if(this==trg){
						step = 1
						timer = 24
					}else{
						step = 10
					}
				}
				break;
			case 1:
				
				mc._alpha = Math.max( mc._alpha-20*Timer.tmod, 0);
				timer -= Timer.tmod;	
				if( timer < 20 ){
					for( var i=0; i<pList.length; i++ ){
						var sp = pList[i]
						var p = trg.getPos();
						sp.towardSpeed(p,0.1,0.8)
					}
				}
				
				if(timer<=0){
					
					var p = getPos();
					
					// HALO
					var explo = game.newPart("partLightCircle")
					explo.x = p.x;
					explo.y = p.y;
					explo.scale = 10
					explo.vits = 30
					explo.timer = 10
					explo.fadeTypeList = [1]
					explo.init();
					
					// PART GO HOME
					for( var i=0;i<pList.length; i++ ){
						var sp = pList[i]
						var a = sp.getAng(p)
						var d = sp.getDist(p)
						var c = Math.max( 1, 16-d)
						sp.vitx = -Math.cos(a) * c
						sp.vity = -Math.sin(a) * c
						sp.timer = 10+Math.random()*10
					}
					setId(nextId);
					mc._alpha = 100
					prc = 0
					step = 2
				}
				
				break;
			case 2:
				prc =  Math.min(  (prc*Math.pow(1.2,Timer.tmod))+2, 100 )
				Mc.setPercentColor(mc,100-prc,0xFFFFFF)
				if( prc == 100 )return false;
				break;
			case 10:
				mc._alpha = Math.max( mc._alpha-20*Timer.tmod, 0);
				if(mc._alpha == 0){
					mc.removeMovieClip();
					return false;
				}
				break;			
		}
		

		
		
		/*
		if(trg != this){
			for( var i=0; i<pList.length; i++ ){
				var sp = pList[i]
				var p = trg.getPos();
				sp.towardSpeed(p,0.1,0.8)
				sp.update();
			}
		}else{
			timer -= Timer.tmod
		
		}
		*/
		
		return true;
	}

	function transmuteInit(nextid) {
		
		setId(nextid);
	}

	function transmuteUpdate() {
		
		
		return false;
	}

	function getPos(){
		return {
			x:mc._x+Const.COIN_SIZE*0.5
			y:mc._y+Const.COIN_SIZE*0.5
		}
	}
	
//{
}














