import mt.bumdum9.Lib;
import Protocol;
import Bad;
import api.AKApi;

using mt.Std;
class Hero extends SP {
	
	static var SPEED = 14;//12;
	static var CROSS_DIST = 45;// 48;//36;

	public var invincible:Bool;
	public var shooting:Bool;
	public var electric:Bool;
	public var cross:EL;
	public var skin:gfx.Ship;
	public var zh:Float;
	
	public var powers:Array<{type:PowerUp, life:Null<Int>}>;
	
	public var onCollideWall:Void->Void;
	public var slowCoef:Float;
	
	var shade:gfx.ShipShade;
	var cooldown:Float;
	var angle:Float;
	var bursterAngle:Float;
	var floatCoef:Float;
	var moveHeight:Float;
	var ray:Int;
	var bop: { x:Float, y:Float };
	var moveArrow:gfx.MoveArrow;
	
	public var noFollow : Bool;
	
	public function new() {
		super();
		
		shade = new gfx.ShipShade();
		Game.me.shadeLayer.addChild(shade);

		skin = new gfx.Ship();
		addChild(skin);
		
		electric = false;
		slowCoef = 0;
		
		//filters = Game.FILTER_MAIN;
		powers = [];
		x = Game.WIDTH >> 1;
		y = Game.HEIGHT >> 1;
		
		cross = new EL();
		cross.goto("cross");
		
		cross.x = x;
		cross.y = y;
		
		Game.me.dm.add(cross, Game.DP_UFX);
		Game.me.dm.add(this, Game.DP_HERO);
		
		cooldown = 0;
		floatCoef = 0;
		moveHeight = 0;
		bursterAngle = 0;
		
		zh = 0;
		ray = 10;
		
		invincible = false;
		electric = false;
		shooting = true;
		
		if( Cs.MOVE_ARROW && !AKApi.isReplay() ) initMoveArrow();
	}
	
	
	public function update() {
		var maxSpeed =  SPEED*1.0;
		if ( Game.me.have( STICKY_SLIME ) && Game.me.slime.isSticky(x, y) ) maxSpeed = 2;
		slowCoef *= 0.96;
		maxSpeed *= Math.max(0, 1 - slowCoef);
		
		// MOVE
		var mp = Game.me.getMousePos(1);
		var mx = mp.x - x;
		var my = mp.y - y;
		var a = Math.atan2(my, mx);
		var dist = Math.sqrt(mx * mx + my * my);
		
		if( noFollow )
			mx = my = a = dist = 0;
		
		if( dist > maxSpeed ) dist = maxSpeed;
		x += Math.cos(a) * dist;
		y += Math.sin(a) * dist;
		
		// BURSTER
		var flameCoef =  Math.min(0.25 + dist * 0.05, 1);
		bursterAngle += Num.hMod(a - bursterAngle, 3.14) * 0.1;
		skin.burster.rotation = bursterAngle / 0.0174 -skin.rotation;
		skin.burster.flame.scaleX = skin.burster.flame.scaleY = flameCoef;
		
		
		// BURSTER LINE
		var bdist = 16;
		var nbop = { x:x-Math.cos(bursterAngle)*bdist, y:y+zh-Math.sin(bursterAngle)*bdist };
		if( bop != null ) {
			var dx = nbop.x - bop.x;
			var dy = nbop.y - bop.y;
			var an = Math.atan2(dy, dx);
			if( Game.me.needRedraw && !Game.me.lowQuality )
			{
				var mc = new SP();
				mc.graphics.lineStyle(6*flameCoef, 0x88CCFF);
				mc.graphics.moveTo(0, 0);
				mc.graphics.lineTo(dx, dy);
				var m = new MX();
				m.translate(bop.x, bop.y);
				Game.me.plasma.draw(mc, m);
			}
		}
		bop = nbop;
		
		
		// RECAL
		var ma = Game.BORDER_X + ray;
		if( x < ma || x > Game.WIDTH - ma ) {
			x = Num.mm(ma, x, Game.WIDTH - ma);
			if( onCollideWall != null ) onCollideWall();
		}
		
		var ma = Game.BORDER_Y + ray;
		if( y < ma || y > Game.HEIGHT - ma ) {
			y = Num.mm(ma, y, Game.HEIGHT - ma);
			if ( onCollideWall != null ) onCollideWall();
		}
		
		// Z HEIGHT
		//moveHeight += (dist - moveHeight) * 0.2;
		floatCoef = (floatCoef + 0.2) % 6.28;
		zh = -Math.ceil(2 + (0.5 + Math.cos(floatCoef) * 0.5) * 6 + moveHeight);
		skin.y = zh;
		
		// SHOOT
		cooldown--;
		while ( cooldown <= 0 ) {
			var inc = 3.0;
			inc *= Math.pow( 0.75, numHave(FIRERATE) );
			inc *= Math.pow( 1.2, numHave(POWER) );
			cooldown += inc;
			if( shooting && !electric ) shoot();
		}
		
		// COL
		if( !invincible ) checkCols();
		
		// CROSS
		var dx = cross.x - x;
		var dy = cross.y - y;
		if( !AKApi.isClicked() ) {
			angle = Math.atan2(dy, dx);
			var dist = Math.sqrt(dx * dx + dy * dy);
			if( dist > CROSS_DIST ) {
				cross.x = Std.int( x + Math.cos(angle) * CROSS_DIST );
				cross.y = Std.int( y + Math.sin(angle) * CROSS_DIST);
			}
			orient(angle);
			cross.goto(0,"cross");
		} else {
			cross.x = Std.int( x + Math.cos(angle) * CROSS_DIST );
			cross.y = Std.int( y + Math.sin(angle) * CROSS_DIST);
			cross.goto(1,"cross");
		}
		x = Std.int(x);
		y = Std.int(y);
		// SHADE
		shade.x = x;
		shade.y = y;
		//
		if( moveArrow != null ) updateMoveArrow();
		//BONUS
		for( power in powers.copy() ) {
			if( power.life != null ) {
				power.life--;
				if ( power.life <= 0 ) {
					
					powers.remove(power);
					Game.me.stykades.onPower();
				}
			}
		}
	}
	
	function checkCols() {
		for ( b in Game.me.bads ) {
			var dx = x - b.x;
			var dy = y - b.y;
			var ma = b.ray + 6;
			if ( Math.abs(dx) < ma && Math.abs(dy) < ma ) {
				hit();
				return;
			}
		}
		
		for ( b in Game.me.shots ) {
			if ( b.type != 1 ) continue;
			var dx = x - b.x;
			var dy = y - b.y;
			var ma = 12;
			if ( Math.abs(dx) < ma && Math.abs(dy) < ma ) {
				hit();
				return;
			}
		}
	}
	
	function hit() {
		if( numHave(BOMB) > 0 ) {
			removePower(BOMB);
			new fx.Bomb(160);
		} else {
			Game.me.gameOver();
		}
	}
	
	inline public function orient(a:Float) {
		skin.rotation = a / 0.0174;
		shade.rotation = skin.rotation;
	}
	
	public function shoot() {
		#if sound
		Sfx.play(1, 0.1 + Math.random() * 0.3);
		#end
		var a = angle + (Game.me.seed.rand() * 2 - 1 ) * 0.15;
		var sh = getShot(a);
		for( i in 0...numHave(SIDES) ) {
			var ec = 0.6 + i * 0.4;
			for( k in 0...2 ) {
				var an = a + (k * 2 - 1) * ec;
				var sh = getShot(an);
				sh.life = Std.int(sh.life*(0.2+Game.me.seed.rand()*0.25));
			}
		}
	}
	
	function getShot(a) {
		var speed = 10 + Game.me.seed.rand() * 2;
		var sh = new Shot(0);
		var vx = Math.cos(a);
		var vy = Math.sin(a);
		sh.x = x + vx * 8;
		sh.y = y + zh + vy * 8;
		sh.vx = vx * speed;
		sh.vy = vy * speed;
		sh.life = 50 + numHave(LONG) * 50;
		sh.orient(angle);
		sh.scaleX = sh.scaleY = sh.power = 1 + numHave(POWER);
		return sh;
	}
	
	public function kill() {
		parent.removeChild(this);
		shade.parent.removeChild(shade);
	}
	
	public function addPower(pw) {
		if( powers.size() >= 2 ) powers.removeLast();
		
		var bonusLife = switch(pw) {
			case MULTI: 30 * 40;//30 seconds
			default: null;
		}
		var bonusData = { type:pw, life:bonusLife };
		powers.addFirst(bonusData);
		Game.me.stykades.onPower(pw);
	}
	
	public function removePower(pw : PowerUp) {
		for( power in powers ) {
			if( power.type == pw ) {
				powers.remove(power);
				break;
			}
		}
		Game.me.stykades.onPower();
	}
	
	public function numHave( p : PowerUp ) {
		var sum = 0;
		for( pw in powers )
			if( pw.type == p )
				sum++;
		return sum;
	}
	
	// MOVE ARROW
	function initMoveArrow() {
		moveArrow = new gfx.MoveArrow();
		Game.me.dm.add(moveArrow, Game.DP_TOP);
		flash.ui.Mouse.hide();
		
		Filt.glow(moveArrow, 6, 0.5, 0x44FF00);
		moveArrow.blendMode = flash.display.BlendMode.ADD;
	}
	
	function updateMoveArrow() {
		moveArrow.x = Game.me.mouseX;
		moveArrow.y = Game.me.mouseY;
		
		var dx = moveArrow.x - x;
		var dy = moveArrow.y - y;
		var co = Num.mm(0, (Math.sqrt(dx * dx + dy * dy) - 10) / 30, 1);
		
		moveArrow.rotation = Math.atan2(dy, dx) / 0.0174;
		moveArrow.scaleX = moveArrow.scaleY = co;
	}
	
	public function removeMoveArrow() {
		if( moveArrow == null ) return;
		moveArrow.visible = false;
	}
}
