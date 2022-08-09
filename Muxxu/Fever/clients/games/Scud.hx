import mt.bumdum9.Lib;

typedef SCExplode = {>Sprite,vs:Float};
typedef SCScud = {>Phys,d:Float};

class Scud extends Game{//}

	// CONSTANTES
	static var GUN_SIZE = 16;
	static var MIS_SPEED = 2;
	static var FB_SPEED = 1.5;

	// VARIABLES
	var ammo:Int;
	var rot:Float;
	var boum:Float;
	var fTimer:Float;
	var intv:Float;
	var fList:Array<Phys>;
	var sList:Array<SCScud>;
	var eList:Array<SCExplode>;
	var aList:Array<flash.display.MovieClip>;
	// MOVIECLIPS
	var gun:flash.display.MovieClip;



	override function init(dif){
		gameTime = 420;
		super.init(dif);
		rot = 0;
		fTimer = 30;
		intv = 30 - dif*25;
		if(intv<1)intv = 1;
		boum = 0.7;
		sList = new Array();
		fList = new Array();
		eList = new Array();
		ammo = 8;
		displayAmmo();
		attachElements();
		zoomOld();
	}

	function attachElements(){
		bg = dm.attach("scud_bg",0);

		gun = cast(bg).gun;

	}

	override function update(){

		switch(step){
			case 1:
				// TURN CANON
				var mp = getMousePos();
				var dx = mp.x - gun.x;
				var dy = mp.y - gun.y;
				rot = Num.mm(-3.14,Math.atan2(dy,dx),0);

				var grot = rot/0.0174;
				gun.rotation = if( grot == 0 ) ( if( dx < 0 ) 180 else 0 ) else grot;

				// SHOOT
				if( click && ammo > 0){
					step = 2;
					var sp:SCScud = cast newPhys("mcScud");
					var srot = if( rot == 0 ) (if(dx<0) 180 * 0.0174 else 0 ) else rot;
					var ca =  Math.cos(srot);
					var sa =  Math.sin(srot);
					sp.x = gun.x + ca*GUN_SIZE;
					sp.y = gun.y + sa*GUN_SIZE;
					sp.vx = ca*MIS_SPEED;
					sp.vy = sa*MIS_SPEED;
					sp.d = Math.sqrt( dx*dx + dy*dy )-GUN_SIZE;
					sp.updatePos();
					sp.root.rotation = srot/0.0174;
					sList.push(sp);
					sp.frict = 1;

					ammo--;
					displayAmmo();

				}
			case 2:
				if(!click)step=1;
		};

		// FIREBALL
		fTimer--;
		while(fTimer<0){
			fTimer += intv;
			intv *= 1.2;
			addFireBall();
		}

		// UPDATES
		updateShots();
		updateExplos();
		updateFireBalls();
		super.update();
	}

	function updateShots(){
		var a = sList.copy();
		for( sp in a ){
			sp.d -= MIS_SPEED;
			if(sp.d<0){
				explode(sp.x,sp.y,boum);
				sp.kill();
				sList.remove(sp);
			}
		}
	}

	function updateExplos(){
		var frict = 0.5;
		var a = eList.copy();
		for(sp in a ){
			sp.vs *= frict;
			sp.root.scaleX += sp.vs;
			sp.root.scaleY = sp.root.scaleX;

			// CHECK COL
			var b = fList.copy();
			for( fb in b ){
				var ray = sp.root.scaleX*50;
				var dist =sp.getDist(fb);
				if( dist < ray ){
					explode(fb.x,fb.y,boum*0.75);
					fb.kill();
					fList.remove(fb);
				}
			}


			// DEATH
			if( sp.vs < 0.001 ){
				sp.kill();
				eList.remove(sp);
			}



		}
	}

	function updateFireBalls(){
		var a = fList.copy();
		for( sp in a ){

			if(sp.y>Cs.omch-2){
				var mc = dm.attach( "mcScudFire", Game.DP_SPRITE );
				mc.x = sp.x;
				mc.y = Cs.omch;
				sp.kill();
				fList.remove(sp);
				setWin(false,20);
			}
		}
	}

	function explode(x,y,vs){
		var sp:SCExplode = cast newSprite("mcScudExplosion");
		sp.x = x;
		sp.y = y;
		sp.vs = vs;
		sp.updatePos();
		sp.root.scaleX = 0.06;
		sp.root.scaleY = 0.06;
		eList.push(sp);
	}

	function addFireBall(){
		var sp = newPhys("mcFireBall");
		sp.x = Math.random()*Cs.omcw;
		sp.y = -10;

		var p = {x:Math.random()*Cs.omcw,y:Cs.omch*1.0}
		var a = sp.getAng(p);

		sp.vx = Math.cos(a)*FB_SPEED;
		sp.vy = Math.sin(a)*FB_SPEED;
		sp.frict = 1;
		sp.updatePos();
		sp.root.rotation = a/0.0174;
		fList.push(sp);
	}

	override function outOfTime(){
		setWin(true);
	}

	function displayAmmo(){
		if(aList != null) while(aList.length > 0) {
			var mc = aList.pop();
			mc.parent.removeChild(mc);
		}
		aList = new Array();
		for( i in 0...ammo ){
			var mc = dm.attach("mcScudAmmo",Game.DP_SPRITE2);
			mc.x = (Cs.omcw-(ammo*2 + (ammo-1)*1 ))*0.5 + i*(2+1);
			mc.y = Cs.omch - 4;
			aList.push(mc);
		}

	}


//{
}















