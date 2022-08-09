import Game;
import mt.bumdum.Phys;
import mt.bumdum.Lib;



class Car extends Tracker{//}



	static public var PNEU_COEF = 1;

	var colors:Array<Int>;

	public var flPlayer:Bool;
	public var flGrass:mt.flash.Volatile<Bool>;

	public var acc:Float;
	public var wd:Float;
	public var paintTimer:Float;

	var poum:{vx:Float,vy:Float};


	public var life:mt.flash.Volatile<Float>;


	public var brakeFrict:Float;
	public var grassFrict:Float;
	public var redFlash:Float;

	public var box:Array<Array<Float>>;
	public var opp:Array<Array<Float>>;
	public var normals:Array<Array<Float>>;


	public var cps:mt.flash.Volatile<Int>;
	public var pid:mt.flash.Volatile<Int>;


	public function new( mc ){
		super(mc);
		Game.me.cars.push(this);


		brakeFrict = 0.93;
		grassFrict = 0.7;

		cps = 0;



	}

	public function setPlayer(id){
		pid = id;
		flPlayer = pid==0;
		root.gotoAndStop(pid+1);
		switch(pid){
			case 0:

				flControl = true;

				life = Cs.LIFE_MAX;
				groundFrict = 0.96;
				decalMax = 0;

				wd = 1;
				acc = 0.3;
				turnCoef = 0.1;
				turnLimit = 0.5;
				//colors = [0x222F5E,0x384E9C];
				colors = [0xA74403,0xFF9900];
			case 1:
				wd = 1;
				acc = 0.1;
				turnCoef = 0.06;
				turnLimit = 0.2;
				colors = [0x449210,0x89DE07];
			case 2:
				wd = 5;
				acc = 0.15;
				turnCoef = 0.1;
				turnLimit = 0.5;
				colors = [0x0939AA,0x457BF5];
			case 3:
				wd = 20;
				acc = 0.22;
				turnCoef = 0.14;
				turnLimit = 0.65;
				colors = [0xA00162,0xFF0080];
		}


		goto(pid*2);

		/*
		var dcm  = decalMax;
		dcm = 0;
		goto(0);
		x += -(60-(Std.int(pid/2)*30 + (pid%2)*8 ));
		y += ((pid%2)*2-1)*5;
		decalMax= dcm;
		*/


	}

	// UPDATE
	public function update(){
		flGrass = Game.me.map.race.hitTest( x*Game.SC + Game.me.map._x, y*Game.SC + Game.me.map._y,true);// && pid==0;
		//flGrass = false;
		if(flGrass){
			if(paintTimer==null)paintTimer=0;
			paintTimer = Math.min(paintTimer+3*mt.Timer.tmod,24);
		}



		if( flGrass ){
			if( flPlayer) Game.me.flPerfect = false;
			speed *= Math.pow(grassFrict,mt.Timer.tmod);
		}
		updateFlash();

		updateBox();
		control();
		move();
		updateCols();
		updatePneuFx();

		//trace(cps);
	}
	function control(){
		if( flPlayer ){
			if(Game.me.flPress && Game.me.step == Play ){
				speed += acc*mt.Timer.tmod;
				if(!flGrass)KKApi.addScore(Cs.SCORE_ACCEL);
			}else{
				speed *= Math.pow(brakeFrict,mt.Timer.tmod);
			}
		}else{

			var c = 1-Math.min(Math.abs(da),1);
			speed += acc*c*mt.Timer.tmod;
		}
		speed = Math.max(1,speed);

	}

	//
	function nextWayPoint(){
		super.nextWayPoint();
		cps++;
		if( cpi == 1 && pid == 0 )Game.me.incLap();
	}
	public function goto(n){
		super.goto(n);
		cps = n;
	}


	//
	function updateFlash(){
		if(redFlash!=null){
			var prc = redFlash;
			redFlash*=0.8;
			if(redFlash<1){
				redFlash = null;
				prc = 0;
			}
			Col.setPercentColor(root,prc,0xFF0000);
		}
	}

	// COLLISIONS
	function updateCols(){


		for( car in Game.me.cars ){
			if(car!=this){
				// COLS
				//checkColPhys(car);
				// DEPASSEMENT
				if( pid==0 ){
					if( cps>= car.cps){
						var dist0 = getDist(wp);
						var dist1 = car.getDist(wp);

						if(dist0<dist1)car.pass(this);

					}

				}
			}


		}




	}

	public function checkColPhys(car:Car){



		// COEFFICIENT DE POIDS
		var coef = car.wd/(wd+car.wd);
		if( pid==0 || car.pid==0 )coef = 0.5;


		// COLLISION
		var rec = checkCol(car,1);
		if(rec==null)return;

		x -= rec[0]*coef;
		y -= rec[1]*coef;
		car.x += rec[0]*(1-coef);
		car.y += rec[1]*(1-coef);


		var a = getAng(car);
		var da = Num.hMod(angle-a,3.14);
		var c = Math.abs(da)/3.14;

		var dx = vx-car.vx;
		var dy = vy-car.vy;
		var force = Math.sqrt(dx*dx+dy*dy);

		bang(c,force);
		car.bang(1-c,force);

		//speed *= c;
		//car.speed *= (1-c);


	}
	function checkCol(car:Car,sc){

		// INIT
		var bn = null;
		var ndif = 9999999999;
		var sens = 1;

		// BUILD NORMAL LIST
		var nl = [];
		for( n in normals )nl.push(n);
		for( n in car.normals )nl.push(n);

		// SEEK
		for( n in nl ){
			var p0 = getProj(n,sc);
			var p1 = car.getProj(n,sc);

			var min = Math.max(p0[0],p1[0]);
			var max = Math.min(p0[1],p1[1]);
			if( max > min ){
				var dif = max-min;
				if(dif<ndif){
					bn = n;
					ndif = dif;
					sens = if(min==p0[0]) -1 else 1;
				}
			}else{
				return null;
			}
		}



		return [bn[0]*ndif*sens,bn[1]*ndif*sens];
	}
	function getProj(n:Array<Float>,sc:Float){
		var distMin:Float =  9999999;
		var distMax:Float = -9999999;
		for( p in box ){
			var px = x+p[0]*sc;
			var py = y+p[1]*sc;
			var ps = n[0]*px + n[1]*py;
			distMin = Math.min( distMin, ps );
			distMax = Math.max( distMax, ps );
		}
		return [distMin,distMax];
	}
	function updateBox(){

		opp = [];
		for( p in box )	opp.push([ p[0]*PNEU_COEF+x, p[1]*PNEU_COEF+y ]);

		//
		var a = root._rotation*0.0174;
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		var rw = 6;
		var rh = 3;
		box = [
			rotate( -rw,  -rh, ca, sa ),
			rotate( rw,   -rh, ca, sa ),
			rotate( rw,   rh,  ca, sa ),
			rotate( -rw,  rh,  ca, sa )
		];
		normals = [ [-sa,ca], [-ca,-sa]  ];
	}
	function rotate(x:Float,y:Float,ca:Float,sa:Float){
		return [x*ca-y*sa, x*sa+y*ca];
	}

	function pass(c:Car){
		if(Game.me.step!=Play)return;

		// PANEL
		var sc = Cs.SCORE_OVERTAKE[pid-1];
		KKApi.addScore(sc);
		cps+=Game.me.checkpoints.length;
		var p = new Phys(Game.me.mdm.attach("mcScore",Game.DP_INTER));
		p.x = x;
		p.y = y;
		p.vy = -5;
		p.frict = 0.7;
		p.timer =  40;
		p.fadeType = 0;

		Filt.glow(p.root,2,4,colors[0]);
		var field:flash.TextField = (cast p.root).field;
		field.text = Std.string(KKApi.val(sc));

		// PARTS
		for( i in 0...40 ){
			var a = Math.random()*6.28;
			//var p = new Luciole(Game.me.mdm.attach("mcLuciole",Game.DP_CAR));
			var p = new Luciole(Game.me.mdm.attach("partLine",Game.DP_CAR));
			p.setWayPoint(cpi);
			var ray  = Math.random()*20;
			p.x = x + Math.cos(a)*ray;
			p.y = y + Math.sin(a)*ray;
			p.vx = c.vx*2;
			p.vy = c.vy*2;
			//p.setScale(50+Math.random()*50);
			p.angle = angle;
			p.flLine = true;
			Filt.glow(p.root,10,2,colors[1]);

		}


	}
	function bang(c:Float,force:Float){

		//if(pid==0)
		//c = Math.pow(c,0.5);
		if(c<0.5)speed*=c;

		force*=(1-c);

		var max = Std.int(force);
		for( n in 0...max ){

			var p = getPart(0.6);
			var a = n/max * 6.28 + Math.random()*0.2;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = 0.2+Math.random()*2;
			p.x = x+(Math.random()*2-1)*3;
			p.y = y+(Math.random()*2-1)*3;
			p.vx = ca*sp + vx*(0.1+Math.random()*0.4);
			p.vy = sa*sp + vy*(0.1+Math.random()*0.4);

		}

		if(pid!=0)return;

		if(flPlayer) Game.me.flPerfect = false;
		if(force>1.5){
			redFlash = 100;
			updateFlash();
			life = Math.max(life-force*10,0);
			Game.me.updateLife(life);
			if(life==0)explode();
		}



	}

// FX
	public function updatePneuFx(){
		if(paintTimer==null)return;

		//var flAllDirt = true;
		var maxDirt = Std.int(Math.sqrt(vx*vx+vy*vy));
		var dda = Math.abs(da);
		//if(state==10)dda = 2;
		//if(dda<0.1)return;


		var mc = Game.me.mdm.attach("mcPneuFx",Game.DP_PARTS);
		var bmp = Game.me.map.bmp;
		for( i in 0...box.length ){
			var wp = [ box[i][0]*PNEU_COEF+x, box[i][1]*PNEU_COEF+y ];
			var x = opp[i][0];
			var y = opp[i][1];
			var dx = wp[0] - x;
			var dy = wp[1] - y;
			var dist = Math.sqrt(dx*dx+dy*dy);
			var a = Math.atan2(dy,dx);
			var m = new flash.geom.Matrix();
			var sc = bmp.pq;
			m.scale(dist*0.01*sc,sc);
			m.rotate(a);
			m.translate(x*sc,y*sc);

			var prc = dda*5;
			//prc = 100;
			prc = Math.min(paintTimer*4 + dda*20 ,100);


			var ct = new flash.geom.ColorTransform(1,1,1,0,0,0,0,prc*2.55);
			bmp.draw(mc,m,ct);

		}

		mc.removeMovieClip();


		paintTimer -= mt.Timer.tmod;
		if(paintTimer<=0)paintTimer = null;

		//mc2.removeMovieClip();

	}

	//
	function explode(){
		Game.me.initGameOver(20);

		//

		var p =  new Part(Game.me.mdm.attach("partCarcasse",Game.DP_PARTS));
		p.x = x;
		p.y = y;
		p.vx = vx*0.2;
		p.vy = vy*0.2;
		p.root._rotation = root._rotation;
		p.vr = da*10;
		p.frict = 0.93;
		p.fr = 0.95;
		p.bhl = [0];


		//
		var max = 36;
		var cr = 1;
		for( n in 0...max ){
			var p = getPart();

			var a = n/max * 6.28 + Math.random()*0.2;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = 0.5+Math.random()*3;
			p.x = x + ca*cr*sp;
			p.y = y + sa*cr*sp;
			p.vx = ca*sp + vx*(0.3+Math.random()*0.3);
			p.vy = sa*sp + vy*(0.3+Math.random()*0.3);
			//if(Std.random(3)==0)p.bhl = [0];

		}


		kill();
	}
	function getPart(?sc:Float){
		if(sc==null)sc = 1;
		var p = new Part();
		p.vr = (Math.random()*2-1)*24;
		p.root._rotation = Math.random()*360;
		p.zw = 0.1+Math.random()*0.1;
		p.frict = 0.95;
		p.timer = 10+Math.random()*70;
		p.setScale((50+Math.random()*100)*sc);
		p.fadeType = 2;
		p.vz = -1+Math.random()*10;
		p.initShade();
		Col.setPercentColor(p.root.smc,100,colors[Std.random(colors.length)]);
		return p;

	}


	public function kill(){
		Game.me.cars.remove(this);
		root.removeMovieClip();
	}





//{
}






