package ent;

import Common;

class Hero extends Entity {
	
	public var lock : Bool;
	
	public var angle : mt.flash.Volatile<Float>;
	public var viewZ : mt.flash.Volatile<Float>;
	public var angleZ : Float;
	public var recalAngleZ : Bool;
	
	public var gravity : mt.flash.Volatile<Float>;
	public var maxGravity : mt.flash.Volatile<Float>;

	public var walking : Bool;
	public var walkingSlow : Bool;
	public var cheating : Bool;
	public var swimming : Bool;
	public var invincible : Bool;
	public var pushPower : Float;
	
	public var actionPause : Float;
	
	public var oxygen : mt.flash.Volatile<Float>;
	
	public var jetpack : mt.flash.Volatile<Float>;
	public var life : mt.flash.Volatile<Float>;
	public var standingBlock : Block;
	public var inWaterBlock : Block;
	
	public var enteringShip : Float;
	
	public var healRecover : Float;
	public var damageRecover : Float;
	public var oldSpeedX : Float;
	public var oldSpeedY : Float;
	
	public var stun : Float;
	
	public var angleSpeed : Float;
	public var miningPower(default,setMiningPower) : Float; // 1.0 par défaut

	var jetSound	: Null<flash.media.SoundChannel>;
	var footCD		: Float;
	
	public function new() {
		super();
		viewZ = 1.5;
		angleZ = 0;
		recalAngleZ = false;
		pushPower = 0;
		gravity = 0;
		maxGravity = 0.9;
		actionPause = 0;
		oldSpeedX = oldSpeedY = 0;
		jetpack = 0;
		stun = 0;
		miningPower = 1.0;
		footCD = 0;
		swimming = false;
		enteringShip = -1;
		damageRecover = 0;
		healRecover = 0;
		angleSpeed = 1;
		oxygen = 100;
	}
	
	public function setMiningPower(f:Float) {
		if( game.interf!=null )
			game.interf.setStatus("power", f>1);
		miningPower = f;
		return f;
	}
	
	public inline function onGround() {
		return standingBlock!=null;
	}
	
	public function hit(dmg:Float) {
		if( !invincible )
			life -= dmg;
		stun = 10;
		if( life <= 0 ) {
			life = 0;
			game.api.forcePosSave();
			game.returnToShip(false);
		} else if( game.fadeFX == null ) {
			var pow = dmg/100;
			game.fadeFX = { t:0., speed : 3+10*(1-pow), col : 0xFF0000, done : function() {}, getAlpha : function(t) return (1-t)*(0.5+pow*0.5), dz : 0.1 };
		}
	}
	
	public function heal(v:Float) {
		if( life<=0 )
			return;
		life += v;
		if( life > 100 )
			life = 100;
		if( game.fadeFX == null )
			game.fadeFX = { t:0., speed : 10., col : 0x00C5E8, done : function() {}, dz : 0. , getAlpha : function(t) {
				return Math.sin(t*3.14)*0.35;
			}};
	}

	public function gotoShip( inside = true ) {
		var ship = game.ship;
		if( ship == null )
			return;
		enteringShip = -1;
		x = ship.x + 0.5;
		y = ship.y + 0.5;
		z = inside && ship.start != null ? ship.start.z : ship.z;
		// recal view
		for( i in 0...4 ) {
			var a = i * Math.PI / 2;
			if( !collide(x + Math.cos(a), y + Math.sin(a), z + 1.5) ) {
				angle = a;
				break;
			}
		}
	}
	
	public function updateAngleView() {
		// update point-of-view
		var move = false;
		var targetZ = 1.5;
		if( game.fadeFX != null )
			targetZ -= game.fadeFX.t * game.fadeFX.dz;
		else if( enteringShip > 0 )
			targetZ += enteringShip * 0.2 * (z > Const.SIZE ? -1 : 1);
		else if( lock )
			targetZ = viewZ;
		if( viewZ != targetZ ) {
			var p = Math.pow((viewZ < targetZ) ? 0.8 : 0.9,mt.Timer.tmod);
			viewZ = viewZ * p + targetZ * (1-p);
			if( Math.abs(viewZ-targetZ) < 0.01 )
				viewZ = targetZ;
			move = true;
		}
		
		// update drag-n-view
		var defAZ = -Math.atan2(1 + 7 * 7 * game.planet.curve, 7);
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
	
	public function update( dt : Float ) {
		if( damageRecover > 0 )
			damageRecover -= dt;
		else {
			var blocks = [];
			var maxHit = 0.;
			blocks.push(standingBlock);
			blocks.push(game.level.get(Std.int(x), Std.int(y), Std.int(z + 0.1)));
			blocks.push(game.level.get(Std.int(x), Std.int(y), Std.int(z + viewZ + 0.15)));
			for( b in blocks ) {
				if( b == null ) continue;
				for( f in b.flags )
					switch( f ) {
					case BFDamage(v): if( v > maxHit ) maxHit = v;
					default:
					}
			}
			if( maxHit > 0 ) {
				hit(maxHit);
				damageRecover = 10.;
			}
			if( swimming && oxygen<=0 ) {
				damageRecover = 4;
				hit(1);
			}
		}
		
		if( healRecover > 0 )
			healRecover -= dt;
		else {
			var blocks = [];
			blocks.push(standingBlock);
			blocks.push(game.level.get(Std.int(x), Std.int(y), Std.int(z + 0.1)));
			for( b in blocks ) {
				if( b == null ) continue;
				for( f in b.flags )
					switch( f ) {
					case BFHeal(v):
						heal(v);
						healRecover= 20.;
					default:
					}
			}
		}
		
		inWaterBlock = null;
		if( swimming )
			inWaterBlock = game.level.get(Std.int(x), Std.int(y), Std.int(z + viewZ));
		if( inWaterBlock != null && !inWaterBlock.hasProp(PLiquid) )
			inWaterBlock = null;
	}
	
	public function inWater( ?dz, isRealWater = false ) {
		if( dz == null ) dz = viewZ;
		var b = game.level.get(Math.floor(x), Math.floor(y), Std.int(z + dz));
		return b != null && b.hasFlag(BFLiquid) && (!isRealWater || b.type == BTWater);
	}
	
	public function onWater() {
		return inWater(0.01);
	}
	
	public function doMove( dt : Float, speed : Float, strafe : Float, useJetpack : Bool ) {
		
		if( stun>0 )
			stun -= dt;
	
		if( actionPause > 0 )
			actionPause -= dt;
			
		var waterBlock = game.level.get(Math.floor(x), Math.floor(y), Std.int(z + 0.1));
		if( waterBlock != null && !waterBlock.hasFlag(BFLiquid) )
			waterBlock = null;
		if( waterBlock != null )
			switch( waterBlock.k ) {
			case BMarsQuickSand:
				if( game.level.get(Math.floor(x), Math.floor(y), Std.int(z + viewZ)) == waterBlock && Std.random(20) == 0 )
					hit(dt * 5);
				dt *= 0.3;
				speed *= 0.6;
				strafe *= 0.6;
			default:
			}
			
		swimming = inWater();
		
		if( swimming ) {
			if( oxygen>0 ) oxygen-=dt*0.1;
			if( oxygen<0 ) oxygen = 0;
		}
		else {
			if( oxygen<100 ) oxygen+=dt*0.5;
			if( oxygen>100 ) oxygen = 100;
		}
		
		z -= gravity * dt * (cheating && gravity > 0 ? 0.01 : 1);
		//gravity = gravity * Math.pow(0.95, dt);
		
		if( footCD>0 )
			footCD-=dt;
			
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
			foots.push({ px : x + Math.cos(a+da)*0.1, py : y + Math.sin(a+da)*0.1 });

		// foot collision
		var col = false;
		for( f in foots )
			if( collide(f.px,f.py,z-0.01) ) {
				col = true;
				break;
			}

		// head collision
		if( gravity < 0 && !col ) {
			var found = false;
			var d = viewZ + 0.13;
			var recal = 0.;
			for( f in foots )
				while( recal < 0.5 && collide(f.px, f.py, z + d) ) {
					z -= 0.01;
					recal += 0.01;
				}
			if( recal > 0 && recal < 0.5 )
				gravity = 0;
		}
			
		if( useJetpack && swimming ) {
			if( gravity > -0.1 )
				gravity -= 0.03 * dt;
			useJetpack = false;
		}
		
		var jconsume = 0.02;
		var autoJump = pushPower>0.4 && game.mouseControls();
		if( (!useJetpack || jetpack<=0) && jetSound!=null ) {
			jetSound.stop();
			jetSound = null;
		}
		if( !col ) {
			footCD = 9;
			standingBlock = null;
			//swimming = false;
			var jhud = game.render.hud[Game.H_JETPACK];
			jhud.visible = false;
			if( useJetpack || autoJump ) {
				if( cheating )
					gravity = -0.200;
				else if( jetpack>0 ) {
					if( jetSound==null ) {
						Sfx.play(Sfx.LIB.jetpackStart, 0.2);
						jetSound = Sfx.play(Sfx.LIB.jetpack, 0.07, 9999);
					}
					if( game.hudOn )
						jhud.visible = true;
					jhud.alpha = 0.3 + Math.random()*0.7;
					jetpack -= jconsume * dt;
					if( gravity>-0.05 )
						gravity += -(0.025/Math.pow(1 + Math.abs(gravity),2))  * dt; // falling
					else
						gravity += -0.005 * dt; // going up
				}
			}
			else {
				if( swimming )
					jetpack += jconsume * 0.7 * dt;
				else
					jetpack += jconsume * 0.2 * dt;
			}
			if( swimming ) {
				gravity += 0.005 * dt;
				if( gravity > 0.07 ) gravity *= Math.pow(0.95,dt);
			} else {
				gravity += 0.014 * dt;
				if( gravity > maxGravity ) gravity = maxGravity;
			}
		} else {
			// recall foots
			if( gravity >= 0 ) {
				var h = Std.int(z * 32) / 32;
				game.level.collideEmpty = false;
				while( true ) {
					var found = false;
					for( f in foots )
						if( collide(f.px, f.py, h) ) {
							found = true;
							break;
						}
					if( !found ) break;
					h += 1/32;
				}
				game.level.collideEmpty = true;
				z = h;
			}
			if( jetpack<1 )
				jetpack += jconsume*7 * dt;
			var feet;
			if( collide(x, y, z - 0.02) )
				feet = game.level.get(Std.int(x), Std.int(y), Std.int(z - 0.02));
			else
				feet = null;
			if( feet == null )
				for( f in foots )
					if( collide(f.px, f.py, z - 0.02) ) {
						feet = game.level.get(Std.int(f.px), Std.int(f.py), Std.int(z - 0.02));
						break;
					}
			if( feet != standingBlock ) {
				standingBlock = feet;
				var threshold = 0.4;
				var hitPow = gravity/maxGravity;
				if( hitPow > threshold && !cheating ) {
					Sfx.play(Sfx.LIB.landHard, 1.5);
					Sfx.play(Sfx.LIB.hit, 0.7);
					var hitPow = (hitPow-threshold) / (1-threshold);
					game.shake += 0.4 * hitPow;
					var dmg = 1 + Math.pow(hitPow*15, 2);
					if( dmg > life ) dmg = life;
					this.hit(dmg);
					game.bobbingY = dmg + 20;
				}
				else
					game.shake += 0.7 * hitPow*hitPow;
			}
			if( speed>0 && footCD<=0 && !onWater() ) {
				footCD = 9;
				if( Std.random(100)<70 )
					Sfx.play(Sfx.LIB.footstep1, 0.3);
				else
					Sfx.play(Sfx.LIB.footstep2, 0.3);
			}
			if( gravity>0 ) {
				Sfx.play(Sfx.LIB.land);
				pushPower = 0;
				autoJump = false;
				if( jetpack<1 )
					jetpack+=0.3;
				else if( gravity>=0.25 )
					game.bobbingY = 15;
				else
					game.bobbingY = 5;
				gravity = 0;
			}
			if( (useJetpack || autoJump) && stun<=0 ) {
				gravity = -0.23;
				Sfx.play(Sfx.LIB.jump, 0.5);
				//pushPower = 0;
			}
		}
		
		if( jetpack>1 )
			jetpack = 1;
		//if( jump && cheating )
			//gravity = -0.27;

		// move
		var dist = speed * dt;
		var ox = x, oy = y;
				
		if( standingBlock != null )
			for( f in standingBlock.flags )
				switch(f) {
					case BFJump(p) :
						if( gravity >= 0 ) gravity = -p;
					default:
				}
		
		if( standingBlock != null && standingBlock.hasFlag(BFSlippy) ) {
			var p = Math.pow(0.96, dt);
			dist *= 0.005;
			oldSpeedX *= p;
			oldSpeedY *= p;
			oldSpeedX += dist * Math.cos(a);
			oldSpeedY += dist * Math.sin(a);
			dist = Math.sqrt(oldSpeedX * oldSpeedX + oldSpeedY * oldSpeedY);
			a = Math.atan2(oldSpeedY, oldSpeedX);
		} else {
			oldSpeedX = dist * Math.cos(a);
			oldSpeedY = dist * Math.sin(a);
		}
		x += oldSpeedX;
		y += oldSpeedY;

		// enable small recal
		if( dist == 0 ) dist = 0.01;

		// recall position
		var old = pushPower;
		for( dz in swimming ? [0, 0.5, 0.9] : (walkingSlow ? [ -0.2, 0, 0.5, 1, 1.3] : [0, 0.5, 1, 1.3]) ) {
			var pz = z + dz;
			var recal = 20;
			while( --recal > 0 ) {
				var r = false;
				for( k in 0...16 ) {
					var a2 = a + ((k & 1) * 2 - 0.99) * (k >> 1) * Math.PI / 8;
					var px2 = x + Math.cos(a2) * 0.45, py2 = y + Math.sin(a2) * 0.45;
					if( collide(px2,py2,pz) == (dz < 0) )
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

		x = real(x);
		y = real(y);
		
		if( walkingSlow || pushPower == old || dist > speed * dt * 0.5 )
			pushPower = 0;
	}

}