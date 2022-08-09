import mt.bumdum9.Lib;
typedef EntSheep = {>Phys,a:Float,ta:Float,sp:Float,pd:Float,flIn:Bool};

class Sheep extends Game{//}

	static var mcw = 240;
	static var mch = 240;

	// CONSTANTES
	static var SHEEP_RAY = 10;
	static var SHEEP_TURN = 0.1;
	static var DOG_TURN = 0.2;
	static var WALK = 0.8; //0.6;
	static var FEAR_RAY = 80;
	static var BARK_RAY = 50;
	static var DOOR_RAY = [47,33,19];


	// VARIABLES
	var di:Int;
	var sList:Array<EntSheep>;

	// MOVIECLIPS
	var bar:flash.display.MovieClip;
	var dog:{>Phys,a:Float,ta:Float,pd:Float};

	override function init(dif:Float){
		gameTime = 480;
		super.init(dif);
		di = Std.int(dif*2);
		if(di>2)di = 2;
		attachElements();

		zoomOld();

	}

	function attachElements(){

		bg = dm.attach("sheep_bg",0);

		// BARRIER
		bar = dm.attach("mcSheepBarrier",Game.DP_SPRITE);
		bar.gotoAndStop(1+di);

		// SHEEP
		sList = [];
		var m = 20;
		var max = Math.round(1+dif*15-di*2);
		for( i in 0...max ){
			var sp:EntSheep = cast newPhys("mcSheep");
			sp.x = m + Std.random(mcw-2*m);
			sp.y = m + Std.random(mch-2*m);
			if( i<2 ) sp.y = mcw*0.75;
			sp.a = Math.random()*6.28;
			sp.ta = sp.a;
			sp.sp = WALK;
			sp.pd = Math.random()*628;
			sp.flIn = false;
			sp.updatePos();
			sp.root.stop();
			sList.push(sp);

			Reflect.setField(sp.root, "_leg",0 );
			Reflect.setField(sp.root, "_register", callback(registerLeg,sp.root) );


		}

		// DOG
		dog = cast newPhys("mcSheepDog");
		dog.x = mcw*0.5;
		dog.y = mch*0.5;
		dog.a = 0;
		dog.ta = 0;
		dog.pd = 0;
		Reflect.setField(dog.root, "_leg",0 );
		Reflect.setField(dog.root, "_register", callback(registerLeg,dog.root) );
		dog.updatePos();

	}
	function registerLeg(mc:flash.display.MovieClip,patte:flash.display.MovieClip){
		var n = Std.int( Reflect.field(mc, "_leg") );
		Reflect.setField(mc,"p"+n,patte);

		n++;
		Reflect.setField(mc, "_leg",n );

		//trace("--- "+n);
		//trace(mc._name);
		//trace( Reflect.field(mc,"p"+n) );


		//


	}

	override function update(){

		switch(step){
			case 1:

				// DOG
				moveDog();

				// SHEEP
				var f = function(a:EntSheep,b:EntSheep){
					if(a.y>b.y)return 1;
					if(a.y<b.y)return -1;
					return 0;
				}
				sList.sort(f);
				var flDog = true;
				for( sp in sList ){
					moveSheep(sp);
					if( flDog && sp.y>dog.y  )dm.over(dog.root);
					dm.over(sp.root);
				}

				// CHECK WIN
				var fl = true;

				for( sp in sList ){
					if(!sp.flIn){
						fl=false;
						break;
					}
				}
				if(fl)setWin(true,20);

		}
		//
		super.update();
	}

	function moveDog(){

		// TURN
		var m = getMousePos();
		dog.ta = dog.getAng(m);
		var da = dog.ta - dog.a;
		while(da>3.14)da-=6.28;
		while(da<-3.14)da+=6.28;
		dog.a += da*DOG_TURN;

		// UPDATE SPEED
		var sp = Num.mm( 0, (dog.getDist(m)-10)*0.1 , 5);

		// MOVE
		dog.vx = Math.cos(dog.a)*sp;
		dog.vy = Math.sin(dog.a)*sp;


		// BODY TURN
		var c = dog.a/6.28 - 0.25;
		while(c<0)c+=1;
		while(c>1)c-=1;
		dog.root.gotoAndStop(1+Std.int(c*58));

		// PATTES
		/*
		dog.pd = (dog.pd+sp*30);
		for( n in 0...4 ){
			var mc = Reflect.field(dog.root,"p"+n);
			mc.y = Math.cos((dog.pd+(n/4)*628)/100);
		}
		*/


	}

	function moveSheep(sp:EntSheep){

		// ORIENT
		var dd = sp.getDist(dog);
		if(sp.flIn){
			sp.ta = -1.57;
			sp.sp = 2;
		}else if( dd < FEAR_RAY ){
			sp.ta = dog.getAng(sp);
			sp.sp += (1-dd/FEAR_RAY)*0.5;
		}else{
			if(Std.random(80)==0 && sp.sp < 0.8 ){
				sp.ta = Math.random()*6.28;
				sp.sp = WALK;
			}
		}
		// PATTES
		sp.pd = (sp.pd+sp.sp*30);
		/*
		for( n in 0...4 ){
			var mc = Reflect.field(sp.root,"p"+n);
			mc.y = Math.cos( (sp.pd+(n/4)*628)/100 )*1.5;
		}
		*/

		// DECREMENTE SPEED
		sp.sp *= 0.9;

		// BOUND
		if(!sp.flIn)checkBounds(sp);

		/* DEBUG ANGLE
		var s = Std.cast(sp)
		s.mca.rotation = sp.ta/0.0174
		//*/

		// SHEEP_TURN
		var da = sp.ta - sp.a;
		while(da>3.14)da-=6.28;
		while(da<-3.14)da+=6.28;
		sp.a += da*SHEEP_TURN;

		// MOVE
		sp.vx = Math.cos(sp.a)*sp.sp;
		sp.vy = Math.sin(sp.a)*sp.sp;

		// BODY TURN
		var c = sp.a/6.28 - 0.25;
		while(c<0)c+=1;
		while(c>1)c-=1;
		sp.root.gotoAndStop(1+Std.int(c*58));

		// COL
		checkCol(sp);

	}

	override function onClick(){
		for( sp in sList ){
			if( dog.getDist(sp) < BARK_RAY )sp.sp = 8;
			getSmc(dog.root).play();
			getSmc(dog.root).rotation = dog.a/0.0174;
		}
	}

	function checkCol(sp){
		for(spo in sList ){
			if( sp != spo ){
				var dist = sp.getDist(spo);
				if( dist < SHEEP_RAY*2 ){
					var d = (SHEEP_RAY*2-dist)*0.5;
					var a = sp.getAng(spo);
					sp.x -= Math.cos(a)*d;
					sp.y -= Math.sin(a)*d;
					spo.x += Math.cos(a)*d;
					spo.y += Math.sin(a)*d;
				};
			}
		}
	}

	function checkBounds(sp:EntSheep){
		var m = SHEEP_RAY;

		if( sp.x < 0+m || sp.x >mcw-m ){
			  sp.x = Math.min( Math.max(m, sp.x ), mcw-m );
			evade(sp);
		}


		var flEnter = Math.abs((mcw*0.5)-sp.x) < DOOR_RAY[di] ;

		if( sp.y < 10+m ){
			if( !flEnter ){
				sp.y = Math.max ( 10+m,  sp.y );
				evade(sp);
			}
		}
		if( flEnter && sp.y < 20+m ){
			sp.flIn = true;
		}

		if( sp.y >mch-m ){
			sp.y = Math.min( sp.y, mch-m );
			evade(sp);
		}
	}

	function evade (sp:EntSheep){


		var wa:Null<Float> = null;
		var bda = 30000.0;
		//Log.prInt("evade! "+Int(sp.ta*10))
		for( i in 0...2 ){
			var x =  sp.x+Math.cos(sp.ta)*20;
			var y =  sp.y+Math.sin(sp.ta)*20;
			var a = sp.ta;
			var sens = i*2-1;
			while( isOut(x,y) ){
				a += 0.01*sens;
				x = sp.x+Math.cos(a)*20;
				y = sp.y+Math.sin(a)*20;
			}
			var da = a-sp.ta;
			while(da>3.14)da-=6.28;
			while(da<-3.14)da+=6.28;

			if( Math.abs(da) < Math.abs( bda) ){
				bda = da;
				wa = a;
			}
		}

		sp.ta = wa;


	}

	function isOut(x:Float,y:Float){
		var fl = y<10 && Math.abs(mcw*0.5-x) > DOOR_RAY[di];
		return x<0 || x>mcw || y>mch || fl;
	}



//{
}










