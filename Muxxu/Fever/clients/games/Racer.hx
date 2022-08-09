import mt.bumdum9.Lib;

//typedef RacerLCar = { >RacerCar, cur:RacerCheckPoint };
typedef RacerCheckPoint = { x:Float, y:Float, an:Float };
class RacerLCar extends RacerCar {
	
	public var control:Bool;
	
	public var id:Int;
	public var next:Int;
	public var dec:Float;
	public var speed:Float;
	public var an:Float;
	public var dist:Float;
	public var invincible:Int;
	
	public var acc:Float;
	public var brake:Float;
	public var turn:Float;
	public var speedCoef:Float;
	
	public var pop:Array<flash.geom.Point>;
	public var tireTimer:Int;
	public var tireTrace:Float;
	
	
	public function new() {
		super();
		control = false;
		speed = 0;
		an = 0;
		dist = 0;
		invincible = 0;
		
		acc = 0.1;
		brake = 0.2;
		turn = 0.1;
		speedCoef = 1;
		pop = [];
		tireTimer = 0;
		tireTrace = 0;
			
	}
}

class Racer extends Game{//}

	static var DEC = 15;
	
	var cars:Array<RacerLCar>;
	var path:Array<RacerCheckPoint>;
	var main:RacerBg;
	var liner:flash.display.Bitmap;

	override function init(dif:Float){
		gameTime =  700;
		super.init(dif);
		
		attachElements();
	
	}

	function attachElements(){
	
		main = new RacerBg();
		addChild(main);
		
		// PATH
		path = [];
		main.path.visible = false;
		for( fr in 1...main.path.totalFrames ) {
			main.path.gotoAndStop(fr);
			var cur = main.path.cursor;
			path.push( { x:cur.x, y:cur.y, an:(cur.rotation+90)*0.0174 } );
		}
		
		//
		liner = new flash.display.Bitmap();
		liner.bitmapData = new flash.display.BitmapData(Cs.mcw, Cs.mch, true, 0);
		addChild(liner);
		// CARS
		cars = [];
		for( i in 0...3 ) {
			var car = new RacerLCar();
			car.id = i;
			cars.push(car);
			addChild(car);
			car.dec =  i - 1;
			car.next = 1;
			var pos = getPos(0, car.dec);
			car.x = pos.x;
			car.y = pos.y;
			car.rotation = -18;
			car.skin.gotoAndStop(i + 1);
			
			if( i == 1 ) {
				car.control = true;
				car.turn = 0.07;
			}else {
				car.speedCoef = 0.4+dif*0.75;
			}
			
		}
		
	
		
	}

	override function update(){
		super.update();
		switch(step) {
			case 1 :
				updateCars();
		}
		
	}
	
	function updateCars() {
		
		var brush  = new RacerBlackLine();
		for( car in cars ) {
			
			if( car.invincible > 0 ) car.invincible--;
			
			//ORIENT
			var trg = getPos(car.next, car.dec);
			var dx = trg.x - car.x;
			var dy = trg.y - car.y;
			var ta = Math.atan2(dy, dx);
			var da = Num.hMod(ta - car.an, 3.14);
			var lim = 0.1;
			if( da > lim ) car.an += car.turn;
			else if( da < -lim ) car.an -= car.turn;
			else car.an = ta;
			
			// SPEED
			var spd = (4 - Math.abs(da * 2)) * car.speedCoef;
			if( car.control ){
				spd = 0;
				if( click ) spd = 7;
			}
			if( car.speed < spd ) car.speed += car.acc;
			if( car.speed > spd ) car.speed -= car.brake;
			
			// GROUND
			var pos = main.road.localToGlobal(new flash.geom.Point(car.x, car.y));
			if( !main.road.hitTestPoint(pos.x, pos.y, true) ) {
				car.speed *= 0.8;
			}
			
			
			// MOVE
			car.x += Math.cos(car.an) * car.speed;
			car.y += Math.sin(car.an) * car.speed;
			car.rotation = car.an / 0.0174;
			
			// PNEU
			car.tireTimer++;
			car.tireTrace = Math.max(car.tireTrace*0.95, Math.abs(da) * 0.1);
			if( car.tireTimer > 2 ) {
				car.tireTimer = 0;
				var a = [ car._w1, car._w2, car._w3, car._w4 ];
				var id = 0;
				for( mc in a ) {
					var p = mc.localToGlobal(new flash.geom.Point(0, 0));
					p = box.globalToLocal(p);
					var op = car.pop[id];
					car.pop[id] = p;
					if( op == null ) continue;
					var dx = p.x - op.x;
					var dy = p.y - op.y;
					var m = new flash.geom.Matrix();
					
					m.scale(Math.sqrt(dx * dx + dy * dy) * 0.01, 1);
					m.rotate(Math.atan2(dy, dx));
					m.translate(op.x,op.y);
					liner.bitmapData.draw(brush, m, new flash.geom.ColorTransform(1,1,1,car.tireTrace,0,0,0,0));
					id++;
					
				}
			}
		
			
			// NEXT
			car.dist = Math.sqrt( dx * dx + dy * dy );
			var nn = (car.next + 1) % path.length;
			if( car.dist  < 10 || getCarDist(car,nn)<car.dist ) {
				if( car.next == 0 ) endRace(car.id);
				car.next = nn;
				car.dec += (Math.random() * 2 - 1) * 0.2;
				car.dec = Num.mm( -1, car.dec, 1);
				car.dist = 100;

			}
		
		}
		
		// COLLISION
		var ray = 6;
		for( car in cars ) {
			for( car2 in cars ) {
				if( car == car2 ) continue;
				var dx = car.x - car2.x;
				var dy = car.y - car2.y;
				var dif = ray*2 - Math.sqrt(dx * dx + dy * dy);
				if( dif > 0 ) {
					var a = Math.atan2(dy, dx);
					var ddx = Math.cos(a) * dif * 0.5;
					var ddy = Math.sin(a) * dif * 0.5;
					car.x += ddx;
					car.y += ddy;
					car2.x -= ddx;
					car2.y -= ddy;
					
					var a = getRank(car);
					var b = getRank(car2);
					var bump = a < b?car2:car;
					var save = a < b?car:car2;
					if( car.invincible == 0 ) bump.speed *= 0.6;
					new mt.fx.Flash( bump, 0xFF0000 );
					save.invincible = 10;
				}
			}
		}
		
		
	}
	function getRank(car:RacerLCar) {
		return car.next * 1000 - car.dist;
	}
	function getCarDist(car:RacerLCar,n:Int) {
		var pos = getPos(n, car.dec);
		var dx = car.x - pos.x;
		var dy = car.y - pos.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	//
	
	function endRace(id) {
		if( win != null ) return;
		setWin(id == 1, 10);
		new mt.fx.Flash(this);
	}
	
	//
	function getPos(n,dec:Float) {
		var cp = path[n];
		var x = cp.x + Math.cos(cp.an) * dec * DEC;
		var y = cp.y + Math.sin(cp.an) * dec * DEC;
		return { x:x, y:y };
	}
	
	
//{
}

