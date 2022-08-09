import Common;

typedef Position = {
	var px : Float;
	var py : Float;
	var pz : Float;
	var a : Float;
	var az : Float;
	var fly : Bool;
	var chk : String;
}

class Hero extends Entity {
	
	public var angle : mt.flash.Volatile<Float>;
	public var viewZ : mt.flash.Volatile<Float>;
	public var angleZ : Float;
	public var recalAngleZ : Bool;
	
	public var gravity : mt.flash.Volatile<Float>;

	public var walking : Bool;
	public var flying : Bool;
	public var swimming : mt.flash.Volatile<Bool>;
	public var pushPower : Float;
	
	public var actionPause : Float;
	
	public var power : mt.flash.Volatile<Int>;
	public var standingBlock : BlockKind;
	
	var save : flash.net.SharedObject;
	var lastSave : { x : Float, y : Float, need : Bool, lock : Bool };
	
	public function new() {
		super();
		
		viewZ = 1.5;
		angleZ = 0;
		recalAngleZ = true;
		pushPower = 0;
		gravity = 0;
		actionPause = 0;
		swimming = false;
		
		save = flash.net.SharedObject.getLocal("pos");
		var k : Position = save.data;
		var DATA = Kube.DATA;
		if( DATA == null ) {
			if( Math.isNaN(k.px) ) {
				var mid = (kube.planetSize - 1) / 2;
				x = mid;
				y = mid;
				angle = 0.0;
			} else {
				x = k.px;
				y = k.py;
				z = k.pz;
				flying = k.fly;
				angle = k.a;
				angleZ = k.az;
				if( flying ) recalAngleZ = false;
			}
			power = Const.POWER * 100;
		} else {
			if( k.chk != makeCheck(k) )
				DATA._force = true;
			x = DATA._x / Const.PREC;
			y = DATA._y / Const.PREC;
			z = DATA._z / Const.PREC;
			power = DATA._pow;
			angle = k.a;
			if( Math.isNaN(angle) ) angle = 0;
			var rx = k.px;
			var ry = k.py;
			var dx = rx - x, dy = ry - y;
			if( Math.sqrt(dx*dx+dy*dy) < Const.SAVE_DIST && !DATA._force ) {
				x = rx;
				y = ry;
				z = k.pz;
			}
		}
		
		x %= kube.planetSize;
		y %= kube.planetSize;
		if( x < 0 ) x += kube.planetSize;
		if( y < 0 ) y += kube.planetSize;
		
		lastSave = { x : x, y : y, need : false, lock : false };
	}

	function makeCheck( k : Position ) {
		var infos = [k.px,k.py,k.pz];
		return haxe.Md5.encode(haxe.Serializer.run(infos)).substr(2,6);
	}

	public function updateAngleView() {
		// update point-of-view
		var move = false;
		var targetZ = swimming ? ((gravity < 0) ? 0.9 : 0.2) : 1.5;
		if( kube.fadeFX != null )
			targetZ -= kube.fadeFX.t * kube.fadeFX.dz;
		if( viewZ != targetZ ) {
			var p = Math.pow((viewZ < targetZ) ? 0.8 : 0.9,mt.Timer.tmod);
			viewZ = viewZ * p + targetZ * (1-p);
			if( Math.abs(viewZ-targetZ) < 0.01 )
				viewZ = targetZ;
			move = true;
		}
		
		// update drag-n-view
		var defAZ = -Math.atan2(1 + 7 * 7 * kube.getPlanetCurve(), 7);
		if( recalAngleZ && angleZ != defAZ ) {
			angleZ -= defAZ;
			angleZ = angleZ * Math.pow(0.8,mt.Timer.tmod);
			move = true;
			if( Math.abs(angleZ) < 0.0001 )
				angleZ = 0;
			angleZ += defAZ;
		}
		return move;
	}
	
	public function doMove( dt : Float, speed : Float, strafe : Float, jump : Bool ) {
	
		if( actionPause > 0 )
			actionPause -= dt;
		
		z -= gravity * dt * (flying && gravity > 0 ? 0.01 : 1);

		// update angle with strafe
		var a = angle;
		if( speed != 0 || strafe != 0 ) {
			var s = Math.sqrt(speed*speed+strafe*strafe);
			a += Math.atan2(strafe / s,speed / s);
			speed = s;
		}

		// foot collide points
		var foots = new Array();
		for( da in [0,Math.PI*2/3,-Math.PI*2/3] )
			foots.push({ ix : kube.real(Math.floor(x + Math.cos(a+da)*0.1)), iy : kube.real(Math.floor(y + Math.sin(a+da)*0.1)) });

		// head collision
		if( gravity < 0 ) {
			var found = false;
			var iz = Std.int(z+1.51);
			for( f in foots )
				if( kube.level.collide(f.ix,f.iy,iz) ) {
					found = true;
					break;
				}
			if( found ) {
				z = iz - 1.51;
				gravity = -gravity;
			}
		}

		// foot collision
		var col = false;
		for( f in foots )
			if( kube.level.collide(f.ix,f.iy,Std.int(z-0.01)) ) {
				col = true;
				break;
			}

		if( !col ) {
			standingBlock = null;
			gravity += 0.03 * dt;
			if( gravity > 0.9 ) gravity = 0.9;
		} else {
			// recall foots
			var h = Std.int(z);
			while( true ) {
				var found = false;
				for( f in foots )
					if( kube.level.collide(f.ix,f.iy,h) ) {
						found = true;
						break;
					}
				if( !found ) break;
				h++;
			}
			z = h;
			var old = swimming;
			var feet = kube.level.get(Std.int(x),Std.int(y),h-1);
			if( feet != null )
				swimming = (feet == BWater);
			if( feet != standingBlock )
				standingBlock = feet;
			gravity = 0;
			if( (jump || pushPower > 1.4) && power > 0 && kube.fadeFX == null ) {
				gravity = swimming ? -0.35 : -0.27;
				pushPower = 0;
			}
		}
		
		if( jump && flying )
			gravity = -0.27;

		// move
		var dist = speed * dt;
		var ox = x, oy = y;
		x += dist * Math.cos(a);
		y += dist * Math.sin(a);

		// enable small recal
		if( dist == 0 ) dist = 0.01;

		// recall position
		var old = pushPower;
		for( dz in swimming ? [0,0.5,0.9] : (walking ? [-0.2,0,0.5,1,1.3] : [0,0.5,1,1.3]) ) {
			var iz = Std.int(z + dz);
			var recal = 20;
			while( --recal > 0 ) {
				var r = false;
				for( k in 0...16 ) {
					var a2 = a + ((k & 1) * 2 - 0.99) * (k >> 1) * Math.PI / 8;
					var px2 = x + Math.cos(a2) * 0.45, py2 = y + Math.sin(a2) * 0.45;
					var ix = kube.real(Math.floor(px2));
					var iy = kube.real(Math.floor(py2));
					if( kube.level.collide(ix,iy,iz) == (dz < 0) )
						continue;
					x -= Math.cos(a2) * dist / 20;
					y -= Math.sin(a2) * dist / 20;
					pushPower += dist / 20;
					r = true;
				}
				if( !r ) break;
			}
		}
		
		ox -= x;
		oy -= y;
		dist = Math.sqrt(ox*ox+oy*oy);

		x %= kube.planetSize;
		y %= kube.planetSize;
		if( x < 0 ) x += kube.planetSize;
		if( y < 0 ) y += kube.planetSize;
		
		if( walking || pushPower == old || dist > speed * dt * 0.5 )
			pushPower = 0;
	}
	
	public function savePosition(move) {
		var dx = (x - lastSave.x + kube.planetSize) % kube.planetSize;
		var dy = (y - lastSave.y + kube.planetSize) % kube.planetSize;
		var dist = Math.sqrt(dx*dx+dy*dy);
		if( dist > Const.SAVE_DIST )
			lastSave.need = true;
		if( !lastSave.need ) {
			if( move && !swimming )
				return;
			if( Std.random(30) != 0 )
				return;
		}
		angle = angle % (Math.PI * 2);
		var pos : Position = {
			px : x,
			py : y,
			pz : z,
			a : angle,
			az : angleZ,
			fly : flying,
			chk : null,
		};
		pos.chk = makeCheck(pos);
		for( f in Reflect.fields(pos) )
			save.setProperty(f,Reflect.field(pos,f));
		if( lastSave.need && !lastSave.lock ) {
			lastSave = { x : x, y : y, need : false, lock : true };
			
			var px = Std.int(lastSave.x*Const.PREC);
			var py = Std.int(lastSave.y*Const.PREC);
			var pz = Std.int(z*Const.PREC);
			kube.command(CSavePos(px,py,pz));
		}
	}
}