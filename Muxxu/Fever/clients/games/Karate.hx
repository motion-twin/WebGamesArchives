import mt.bumdum9.Lib;
import Protocole;

typedef KarateBad = {>Phys, type:Int, shade:flash.display.MovieClip, frm:Float, h:Int,  hit:Array<Bool>, state:Int, sens:Int};

class Karate extends Game{//}

	static var HH = 87;
	static var HIGH = 55;
	static var LOW = 80;

	var dist:Float;
	var ecmin:Float;
	var ecrnd:Float;
	var speed:Float;
	var cooldown:Int;
	var hero:flash.display.MovieClip;
	var shade:flash.display.MovieClip;

	var bads:List<KarateBad>;


	override function init(dif:Float){
		gameTime =  320;
		super.init(dif);
		speed = 0.8+dif*1.6;

		dist = 60;
		ecmin = 32;
		ecrnd = 20;
		bads = new List();
		attachElements();
		box.scaleX = box.scaleY = 4;

		dist = 0;

	}

	function attachElements(){

		bg = dm.attach("karate_bg",0);

		// HERO
		hero = dm.attach("karate_hero",2);
		hero.x = 69;
		hero.y = HH;

		shade = dm.attach("karate_shade",0);
		shade.x = 69;
		shade.y = HH;

	}

	override function update(){

		dist -= speed;
		if(dist<=0){
			dist = ecmin + Math.random()*ecrnd;
			addBad();
		}

		if(step==1)updateHero();
		updateBads();
		super.update();
	}

	function updateHero(){
		if(cooldown>0){
			cooldown--;
			return;
		}

		var ym = box.mouseY;

		if( ym>LOW ) hero.gotoAndStop("crouch");
		else if( ym<HIGH ) hero.gotoAndStop("up");
		else hero.gotoAndStop("stand");


		if( click ){
			var st:Null<Int> = null;
			if( ym>LOW ){
				hero.gotoAndPlay("kick");
				cooldown = 10;
				st = 0;

			}else if(ym<HIGH){
				hero.gotoAndPlay("jump");
				cooldown = 16;
				st = 1;

			}else{
				hero.gotoAndPlay("punch");
				cooldown = 8;
				st = 2;
			}

			if(st!=null)strike(st);
		}
	}

	function strike(st){
		var bad = null;
		for( b in bads ) if( b.state == 0 ) bad = b;
		if( bad == null ) return;
		if( !bad.hit[st] ) return;


		var dist = [17,11,15];
		var ray =  [8,8,9];

		var dx = bad.x-(hero.x-dist[st]);
		if( Math.abs(dx) < ray[st] ){

			getSmc(bad.root).gotoAndPlay("strike");
			bad.state = 1;
			bad.vx = - Math.random()*5;
			bad.vy = - (2+Math.random()*3);
			bad.weight = 1;
			bad.frict = 0.9;

			var mc = dm.attach("karate_spark",3);
			mc.x = hero.x - dist[st];
			mc.y = hero.y - [2,20,15][st];
			mc.rotation = Std.random(4)*90;


			switch(st){
				case 1:
					bad.vy -= 5;
					bad.vx *= 0.5;
				case 0:
					bad.vy = -2;
					bad.y -= 5;
					bad.vx *= 0.25;

			}

		}
	}


	// BADS
	function addBad(){
		if(win)return;

		var btmax = 1;
		if( dif>0.15 )btmax++;
		if( dif>0.35 )btmax++;

		var bad:KarateBad = cast new Phys( dm.attach("karate_bad",1) );
		bad.type = Std.random(btmax);
		bad.frm = 0;
		bad.root.gotoAndStop(bad.type + 1);
		new mt.fx.GotoAndStop(bad.root, untyped __unprotect__("smc"), 1 );
		//getSmc(bad.root).stop();
		
		bad.x = -10;
		bad.state = 0;
		bad.hit = [true,true,true];
		bad.shade = dm.attach("karate_shade",0);
		bad.shade.gotoAndStop(bad.type+1);
		bad.h = 0;
		bad.sens = 1;

		bad.shade.x= -100;
		bad.shade.y = HH;

		switch(bad.type){
			case 0:
				bad.h = 0;
			case 1:
				bad.h = -10;
				if( dif>0.45 && Std.random(2)==0 ){
					bad.h -= 8;
					bad.hit[2] = false;
				}
				bad.hit[0] = false;
			case 2:
				bad.h = 0;
				bad.hit[1] = false;
				bad.hit[2] = false;
		}

		bad.y = HH+bad.h;


		bads.push(bad);

	}

	function updateBads(){
		for( bad in bads ){
			switch(bad.state){
				case 0:	updateWalk(bad);

				case 1: updateFall(bad);

			}


			bad.shade.x = bad.x;
			bad.root.x = Std.int(bad.x);
			bad.root.y = Std.int(bad.y);

		}

	}

	function updateWalk(bad:KarateBad){
		bad.x += speed * bad.sens;
		var smc = getSmc(bad.root);
		switch(bad.type){
			case 0:
				bad.frm = (bad.frm+speed)%16;
				if(smc!=null)smc.gotoAndStop(Std.int(bad.frm)+1);

			case 1:
				bad.frm = (bad.frm+speed)%20;
				if(smc!=null)smc.gotoAndStop(Std.int(bad.frm)+1);

			case 2:
				bad.frm = (bad.frm+speed)%18;
				if(smc!=null)smc.gotoAndStop(Std.int(bad.frm)+1);


		}

		// GRIMPE
		if( bad.x > 72 && win==null){
				hero.gotoAndPlay("gameover_"+bad.type);
				setWin(false,40);
				step = 2;
				if( bad.type != 0 ){
					bad.kill();
					bads.remove(bad);
				}
		}


		var lim = 75;
		if( bad.x > lim){
				bad.y = HH+bad.h - (bad.x-lim);
				bad.shade.visible = false;
		}



	}
	function updateFall(bad:KarateBad){

		if(bad.vy>0)getSmc(bad.root).gotoAndStop("fall");

		if( bad.y > HH ){
			bad.y = HH;
			bad.weight = 0;
			bad.vy = 0;
			bad.frict = 0.75;
			getSmc(bad.root).gotoAndPlay("rebond");
		}

	}

	//
	override function outOfTime(){
		setWin(true,12);
		for( b in bads ){
			if( b.state == 0 ){
				b.sens = -1;
				b.root.scaleX = -1;
			}
		}
	}

//{
}

