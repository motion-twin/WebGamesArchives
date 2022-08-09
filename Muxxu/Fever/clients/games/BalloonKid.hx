import mt.bumdum9.Lib;
import Protocole;

class BalloonKid extends Game{//}

	// CONSTANTES
	static var MOD = [120,360,480];

	// VARIABLES
	var bal:Int;
	var speed:Float;
	var timer:Float;
	var cList:Array<flash.display.MovieClip>;
	var sList:Array<Sprite>;

	// MOVIECLIPS
	var hero:Phys;

	override function init(dif){
		gameTime = 360;
		super.init(dif);

		speed = 1+dif*2.2;
		sList = new Array();
		timer = 0;
		bal = 3-Math.round(dif);
		attachElements();

		var max = Std.int(50/speed);
		for( i in 0...max )moveSpikes();
		zoomOld();

	}

	function attachElements(){

		bg = dm.attach("balloonKid_bg",0);

		// CLOUD
		cList = new Array();
		for( i in 0...3 ){
			var mc = dm.attach("mcCloudBar",Game.DP_SPRITE);
			mc.x = 0;
			mc.y = Cs.omch;
			mc.gotoAndStop(3-i);
			cList.push(mc);
		}

		// HERO
		hero = newPhys("mcBananaBalloon");
		hero.weight = 0.1;
		hero.x = Cs.omcw*0.8;
		hero.y = Cs.omch*0.5;
		hero.vy = -3;
		hero.updatePos();
		updateBalloons();
		
		//

	}

	override function update(){

		moveClouds();
		moveSpikes();

		if(bal>0){
			if(hero.y>Cs.omch)drop();
			if(hero.y<0)drop();
		}

		var mp = getMousePos();
		var dx = mp.x - hero.x;
		var lim = 1.5;
		hero.x += Num.mm(-lim,dx*0.05,lim);

		//
		super.update();



	}

	function addSpike(){

		var sp = newSprite("mcBouletteKipic");
		var m = 20;
		sp.x = -20;
		sp.y = m+Math.random()*(Cs.omch-(2*m));
		sp.updatePos();
		sList.push(sp);
	}

	function moveSpikes(){
		// ADD
		timer--;
		if(timer<0){
			timer = 40/speed;
			addSpike();
		}
		// MOVE
		var a  = sList.copy();
		for( sp in a ){
			sp.x += speed;
			var flDeath = sp.x > Cs.omcw+16;
			if(bal>0 && win == null ){
				var pos = { x:hero.x, y:hero.y-22 };
				var dist = sp.getDist(pos);
				if( dist < 20 ){
					flDeath = true;
					bal--;
					updateBalloons();
				}
				pos = { x:hero.x, y:hero.y+10 };
				dist = sp.getDist(pos);
				if( dist < 16 ){
					hero.vy = -6;
					hero.vr = 20;
					drop();
				}
			}

			if(flDeath){
				sList.remove(sp);
				sp.kill();
			}
		}
	}

	function drop(){
		for( n in 0...bal ){
			var p = newPhys("mcKidBalloon");
			p.x = hero.x+(n-1)*8;
			p.y = hero.y-22;
			p.vx = hero.vx + ((Math.random()*2-1)+(n-1))*0.8;
			p.vy = hero.vy + (Math.random()*2-1)*0.3;
			p.updatePos();
			p.weight = -0.1;
		}
		bal = 0;
		updateBalloons();
	}

	function moveClouds(){
		var i = 0;
		for( mc in cList ){
			mc.x = ( mc.x+(i+0.5)*speed*0.3 )%MOD[i];
			i++;
		}
	}

	function updateBalloons(){
		if(bal > 0) {
			getMc(hero.root,"bg").gotoAndStop(bal);
		
		}else{
			hero.root.gotoAndPlay("fall");
			setWin(false,40);
		}
		hero.weight = 0.3 - bal*0.08;
	}

	override function onClick(){
		if(bal>0){
			hero.vy -= 3;
			hero.root.gotoAndPlay("throw");
		}
	}

	override function outOfTime(){
		setWin(true);
	}


//{
}

