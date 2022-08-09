import flash.display.Sprite;
import Protocole;
import mt.bumdum9.Lib;

typedef QPos = { x:Float, y:Float, vx:Float, vy:Float };
typedef QRing = { x:Float, y:Float, pos:Float,size:Float };


typedef FaceElement = {
	x:Float, y:Float,
	size:Float,
	color:Int, line:Int, ray:Float,
	front:Bool
};

class Snake {//}
	
	public static var DRAW_QUEUE_EC = 3;
	public static var STOMACH_RAY = 32;
	public static var QUEUE_RAY = 5;
	public static var HEAD_RAY = 3;
	public static var MINIMUM_LENGTH = 10;
	
	// A PASSER DANS LES STATUS :
	public var rainbow:Bool;
	
	//
	public var invicible:mt.flash.Volatile<Bool>;
	public var freeze:mt.flash.Volatile<Bool>;
	public var thrusting:Bool;
	public var dead:Bool;
	
	public var realSpeed:Float;
	
	public var speed:Float;
	var thrust:Float;
	public var boost:Float;
	
	public var currentThrust:Float;
	public var angle:Float;
	var turnEase:Float;
	
	public var length:mt.flash.Volatile<Float>;
	public var rlength:mt.flash.Volatile<Float>;
	var lance:Float;
	
	public var trq:Array<QPos>;
	public var queue:Array<QRing>;
	public var stomach:Array < { pos:Float, cal:Float, type:Null<Int>, sens:Int, speed:Float } > ;
	public var pal:Array<Int>;
	
	public var tongue:fx.Tongue;

	public var x:Float;
	public var y:Float;
	public var mcq:SP;
	public var root:SP;
	
	public var queueType:QueueType;
	
	
	public function new() {
	
		x = Cs.mcw * 0.5;
		y = Cs.mch * 0.5;
		
		root = new SP();
		Stage.me.dm.add(root, Stage.DP_SNAKE);
		
		mcq = new SP();
		root.addChild(mcq);
	
		
		
		invicible = false;
		thrusting = false;
		rainbow = false;
		currentThrust = 0;
		

		speed = 	Cs.SNAKE_SPEED;
		thrust = 	Cs.SNAKE_THRUST;
		realSpeed = 0;
		rlength = 	0;
		lance = 0;
		turnEase = 0;
		boost = 0;
		queueType = Q_STANDARD;

		
		x = 10;
		init();
		//
		setPalette(0);
		//
		freeze = false;
		dead = false;
		//
		glowCoef = 1;
		
	
		//
		//var root = Gfx.fx.getAnimLib(200);
		//Stage.me.dm.add(root,8);
		//
		//Rush.setup(mcq);
		//new mt.fx.Rainbow( mcq, 0.1);
			
		
	}
	
	public function init() {
		length = Cs.SNAKE_DEFAULT_LENGTH;
		if( Game.me.training ) 	length = 50;
		trq = [];
		stomach = [];
		
		angle = Math.atan2(Stage.me.height * 0.5 - y, Stage.me.width * 0.5 - x);
		var ray = HEAD_RAY + 1;
		x = Num.mm( ray, x, Stage.me.width - ray);
		y = Num.mm( ray, y, Stage.me.height - ray);
		
	}
	
	public function update() {
		if( !freeze )move();
			//Filt.glow(mcq, 2, 4, 0);
		//
		drawAll();
		if( Game.me.have(POTION_ORANGE) ){
			for ( p in trq ) {
				var fr = 0.98;
				p.vx *= fr;
				p.vy *= fr;
				p.x += p.vx;
				p.y += p.vy;
				var pos = Stage.me.clamp(p.x, p.y, 4);
				p.x = pos.x;
				p.y = pos.y;
			}
		}
		
		//
		checkCols();
		digest();
		
		if( glowCoef != null ) majGlow();
		
		Game.me.gameLog.lengthMax = Std.int( Math.max( Game.me.gameLog.lengthMax, length ) );
		


	}
	
	//
	public var lastTurn:Null<Int>;
	public function turn(sens) {
		angle += getTurnSpeed() * sens;
		lastTurn = sens;
		
	}
	public function getTurnSpeed() {
		var turnSpeed = Cs.SNAKE_TURN_SPEED;
		if( Game.me.have( RING ) ) turnSpeed *= 1.5;
		turnSpeed *= 1 - turnEase;
		
		if( fx.Soap.ACTIVE ) turnSpeed *= 0.1;
		
		return turnSpeed;
	}
	
	function move() {
		
		var sp = speed;
		
		var targetThrust = 0.0;
		if ( thrusting ) {
			targetThrust += thrust;
			if( Game.me.have(ROLLER) ) targetThrust *= 2;
			thrusting = false;
			if ( Game.me.gtimer % 4 == 0  && Game.me.have(CLOUD, true ) ) {
				Game.me.incScore(20);
				Game.me.incShield(0.02);
			}
		}
		var dif = targetThrust - currentThrust;
		currentThrust += dif * 0.25;
		sp += (Game.me.speed / 100) * Cs.SNAKE_SPEED_PENALTY;
		sp += boost;
		if ( Game.me.have(FEATHER) ) 	sp *= 0.7;
		if ( Game.me.have(SOCKS) ) 		sp *= 0.85;
		sp += currentThrust;
		if ( fx.Chausson.ACTIVE ) 		sp *= fx.Chausson.coef;
		if ( fx.Battery.ACTIVE ) 		sp *= fx.Battery.coef;
		if ( fx.Brake.ACTIVE ) 			sp *= fx.Brake.coef;
		if ( fx.Soap.ACTIVE )			sp *= fx.Soap.speedCoef;
		
		
		boost *= 0.8;
		realSpeed = sp;
		
		x += Snk.cos(angle) * sp;
		y += Snk.sin(angle) * sp;

		var vx = 0.0;
		var vy = 0.0;
		
		//
		var da = Num.hMod(angle-lance * 0.01, 3.14);
		lance += da*100 * 0.1;
		var acc = 0.4 ;
		var an = lance * 0.01;
		vx = Snk.cos(an) * acc;
		vy = Snk.sin(an) * acc;
		
		
		//
		if ( test == null ) test = 0;
		test = (test + 2) % 628;
		var c = 0.75+Math.cos(test*0.01)*0.75;
		trq.unshift( { x:x, y:y, vx:vx*c, vy:vy*c } );
				
	}

	var test:Null<Float>;
	
	// COLS
	function checkCols() {
		
		var ray = HEAD_RAY;
		var rect = new flash.geom.Rectangle( x-ray, y-ray, ray*2, ray*2 );
		
		
		
		// FRUITS
		for ( fr in Game.me.fruits ) if( fr.hitTest2(rect) && fr.edible ) eat(fr);
		
		// BONUS
		for ( b in Game.me.bonus ) if( b.hitTest2(rect) ) 	b.trig();
		
		// QUEUE
		for ( id in 10...queue.length ) {
			var p = queue[id];
			var dx = p.x - x;
			var dy = p.y - y;
			var bray = 5;
			var ray = bray + bray * p.size - 4;
			if ( Math.sqrt(dx * dx +dy * dy ) < ray ) {
				queueCollide();
				break;
			}
		}
		
		// OBSTACLES
		for( obs in Game.me.obstacles ) {
			var dx = x - obs.x;
			var dy = y - obs.y;
			if( Math.sqrt(dx * dx + dy * dy) < HEAD_RAY + obs.ray ) {
				if(obs.collide != null) obs.collide();
				headCollide();
				return;
			}
		}
		
		// BORDER
		var ray = HEAD_RAY;
		if ( x <= ray || x > Stage.me.width - ray || y <= ray || y > Stage.me.height - ray ) {
			wallCollide();
		
		}
		
	}
	function wallCollide() {
		
		if( Game.me.have(RESSORT, true, true) ) {
			var card = Game.me.getCard(RESSORT);
			card.setCooldoown(card.data.time);
			new fx.BounceSnake();
			if ( Game.me.have(POTION_PINK) )
				for ( i in 0...3 ) Game.me.specialSpawn(Pink);
			return;
		}
		
		if( Game.me.have(POTION_YELLOW)) {
			var card = Game.me.getCard(POTION_YELLOW);
			card.flip();
			new fx.BounceSnake();
			new fx.PotionYellow();
			return;
		}
			
		headCollide();
				
		
	}
	function queueCollide() {
		if( invicible ) return;
		if( Game.me.have(POTION_BLUE) ) {
			var card = Game.me.getCard(POTION_BLUE);
			card.flip();
			new fx.Invisibility();
			return;
		}
		headCollide();
	}
	public function headCollide() {
		Game.me.shake(0, realSpeed*3, 0.75);
		dead = true;
		Game.me.gameover();
	}

	// GFX
	public function majQueue() {
		queue = [];
		var parc = 0.0;
		var id = 0;
		var cur = trq[0];
		while (id<trq.length) {
			
			var p = trq[id];
			var nx = p.x;
			var ny = p.y;
			var dx = cur.x - p.x;
			var dy = cur.y - p.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if ( parc + dist > length ) {
				var rdist = length - parc;
				var coef  = rdist / dist;
				nx = cur.x - coef * dx;
				ny = cur.y - coef * dy;
			}
			
			
			parc += dist;
			queue.push({x:nx,y:ny,size:1.0, pos:parc});
			cur = p;
			//
			id += DRAW_QUEUE_EC;
			/*
			if ( id >= trq.length ) {
				if( !fx.BlackHole.ACTIVE ) fxQueueSpark();
				break;
			}
			*/
			rlength = parc;
			if ( rlength >=   length ) break;
		}
		if ( rlength < length &&  !fx.BlackHole.ACTIVE ) fxQueueSpark();
		
		
	}
	public function drawAll() {
		
		// BUILD
		//var a = [];
		majQueue();
		
		if (queue.length <2) return;
		
		// STOMACH
		for ( fr in stomach ) {
			for ( p in queue ) {
				var dif = p.pos -fr.pos;
				var calCoef = 0.3;
				var ray = STOMACH_RAY * (1 + (fr.cal - 10) * 0.1 * calCoef);
				ray = Math.min(ray, 80);
				var sizeMax = Math.min( 2.5 + p.pos * 0.05, 7 );
				if ( p.pos > fr.pos + ray ) break;
				if ( p.pos > fr.pos - ray ) {
					var c = dif / ray;
					p.size += (1 - Math.abs(c)) * (fr.cal / 10) * 0.65;
					if ( p.size > sizeMax ) p.size = sizeMax;
				}
			}
		}
		
		// EYES
		var size = queue[0].size;
		var eyes = [];
		var edist = 4 + 3 * (size-1);
		var eca = 1.57;
		var hdist = -2; // distance avant ou arrière sur le visage
		var hdx = Snk.cos(angle) * hdist;
		var hdy = Snk.sin(angle) * hdist;
		var h = - 3;
		
		for ( i in 0...3) {
			var an = angle + eca * (i* 2 - 1);
			an  = Num.hMod(an, 3.14);
			var dx = hdx;
			var dy = hdy + h;
			var eray = 1.7 + (size-1) * 0.5;
			//var color = 0xFFFFFF;
			//var line = 0xAAAAAA;
			var color = 0x000000;
			var line = 0x222222;
			
			if ( i == 2 ) {
				an = Num.hMod(angle,3.14);
				dx = 0;
				dy = 0;
				eray = (size-1) * 6;
				color = 0xAA0000;
				line = 0x206600;
			}
			var o:FaceElement = {
				x: x + Snk.cos(an) * edist + dx,
				y: y + Snk.sin(an) * edist + dy,
				size:size,
				front:an >= 0,
				ray:eray,
				color:color,
				line:line,
			}
			eyes.push(o);
		}
		
		// DRAW
		var gfx = mcq.graphics;
		gfx.clear();
		
		// TONGUE
		if ( tongue != null ) {
			//trace(tongue.length);
			var cur = queue[0];
			gfx.lineStyle(2, 0xFF8888);
			gfx.moveTo(x,y);
			/*
			var tx = cur.x + Snk.cos(angle) * tongue.length;
			var ty = cur.y + Snk.sin(angle) * tongue.length;
			*/
			gfx.lineTo(tongue.x,tongue.y);
		}

		
		// EYES A
		for ( o in eyes ) if (!o.front) drawEye(o);
		
		// QUEUE
		drawQueue(queue,gfx);

		// EYES B
		for ( o in eyes ) if (o.front) drawEye(o);
		
		// CLEAN QUEUE
		while ( trq.length > 1600 ) trq.pop();
		
	}
	function drawEye(fe:FaceElement) {
		var gfx = mcq.graphics;
		gfx.beginFill(fe.color);
		gfx.lineStyle(1, fe.line,1);
		var h = (1 - fe.size) * 5;
		if ( fe.color != 0xFFFFFF ) h += 2;
		gfx.drawCircle(fe.x, fe.y+h, fe.ray);
		gfx.endFill();
	}
	static public function drawQueue( a:Array < QRing > , gfx:flash.display.Graphics, size = 1.0 ) {
		
		if( !Game.me.willDraw ) return;
		var sn = Game.me.snake;
		var pal = sn.pal;
		if (a.length == 0 ) return;
		var q = a.copy();
		var cur = q.shift();
		for ( i in 0...3 ) {
			var th = (10 - 4 * i)*size;
			var color = (i == 0)?pal[2]:pal[1];
			var dy = -i * 1.0;
			
			if ( i == 2 ) {
				th = 1*size;
				dy = -4;
				color = pal[0];
			}
			dy *= size;
			
			var h = (1 - cur.size) * 5;
			h = 0;	// REMOVE HEIGHT TEST
			gfx.moveTo(cur.x, cur.y+dy+h);
			gfx.lineStyle(th, color);
			
			
		
			switch(sn.queueType) {
				case Q_STANDARD :
					for ( p in q ) {
						gfx.lineStyle(th * p.size, color,1);
						gfx.lineTo(p.x, p.y + dy);
					}
				case Q_RAINBOW(spc, alpha):
					var k = 0.0;
					for ( p in q ) {
						var color = Col.mergeCol( Col.getRainbow2(k), color, alpha);
						k = k + spc % 1;
						gfx.lineStyle(th * p.size, color,1);
						gfx.lineTo(p.x, p.y + dy);
					}
				case Q_BONES:
				
					var index = 0;
					var last = a[index];
					var sub = [24,8];
					var parc = 0;
					var k = 0;
					gfx.moveTo(last.x, last.y + dy);
					
					while( true ) {
						
						parc += sub[k];
						if( parc >= sn.rlength ) break;
						var p = sn.getRingData(parc).ring;
						if( k == 0 ) gfx.lineTo(p.x, p.y + dy);
						if( k == 1 ) gfx.moveTo(p.x, p.y + dy);
						k = (k + 1) % 2;
						
					}
				
					/*
					var index = 0;
					var last = a[index];
					var sub = [24,8];
					var parc = 0;
					var k = 0;
					
					gfx.moveTo(last.x, last.y + dy);
					
					while(index < a.length ) {
						var p = a[index];
						if( p.pos > parc + sub[k] ) {
							parc += sub[k];
							
							//gfx.moveTo(last.x, last.y + dy);
							
							if( k == 0 ) gfx.lineTo(p.x, p.y + dy);
							if( k == 1 ) gfx.moveTo(p.x, p.y + dy);
							k = (k + 1) % 2;
							
						}
						index++;
					}
					*/
					
					
				
			}

		}
	
	}
	public function setPalette(n) {
		switch(n) {
			case 0 :
				pal = [Gfx.col("snake_0"), Gfx.col("snake_1"), Gfx.col("snake_2")];
				root.blendMode = flash.display.BlendMode.NORMAL;
				var fl = new flash.filters.DropShadowFilter(2, 90, 0x005533, 0.5, 4, 4, 1);
				mcq.filters = [fl];
				
			case 1 :
				pal = [Gfx.col("blue_0"), Gfx.col("blue_1"), Gfx.col("blue_2")];
				root.blendMode = flash.display.BlendMode.HARDLIGHT;
				mcq.alpha = 2;
				mcq.filters = [];
				
			
		}
	}
	
	// EAT
	function digest() {
		var dspeed = 6;
		var a = stomach.copy();
		
		var inc = 1;
		if ( Game.me.have(PRUNE) ) {
			inc = 4;
			dspeed *= 2;
		}
		
		for ( o in a ) {
			o.pos += dspeed*o.sens*o.speed;
			if ( o.pos > length + STOMACH_RAY * 0.5 ) {
				
				o.cal -= inc;
				length += inc;
				if( o.cal <= 0 ) stomach.remove(o);
				switch(o.type) {
					case 0:
						var fr = Fruit.get(180);
						var pos = getRingData(rlength).ring;
						fr.x = pos.x;
						fr.y = pos.y;
						o.type = null;
					default:
				}
			}
			if( o.pos < -STOMACH_RAY ) {
				o.cal -= inc;
				if( o.cal <= 0 ) stomach.remove(o);
				
				var sp = 2 + Math.random()*2;
				var a = angle + ((Math.random() * 2 - 1) * 0.3);
				var p = part.BloodDrop.get();
				//p.setColor(Col.shuffle(0xCCBB00,30));
				p.setColor(Col.shuffle(0x887700,30));
				//p.setColor(0x00FFFF);
				p.x = x;
				p.y = y;
				p.vx = Snk.cos(a) * sp;
				p.vy = Snk.sin(a) * sp;
				p.vz = -3;
			}
			
		}
		var log = Game.me.gameLog;
		
	}
	public function eat(fr:Fruit ) {
			
		
		fr.kill();
		
		// VITAMINES
		Game.me.incFrutipower(fr.getVit());
		
		// CALORIE
		var stomachObj = null;
		
		var digesting = true;
		if ( stomach.length >= 2 && Game.me.have(BELT, false, true) ){
			var card = Game.me.getCard(BELT,true);
			card.setCooldoown(card.data.time);
			digesting = false;
			
			//for ( o in stomach ) o.speed += 0.5;
			
			
		}
		
		if ( digesting ) {
		
			
			var type:Null<Int> = null;
			var cal = fr.getCal();
			if( Game.me.have(POO) && !fr.has(Shit) ) {
				type = 0;
				cal *= 0.4;
			}
			stomachObj = { pos: -STOMACH_RAY * 0.25, cal:cal, type:type, sens:1, speed:1.0 };
			stomach.push( stomachObj );
		}
	

		// SCORE
		var score = fr.getScore();
		if ( score < 0 && Game.me.have(GLOTTIS,true,true) ) {
			var card = Game.me.getCard(GLOTTIS);
			card.setCooldoown(card.data.time);
			if( stomachObj != null ) stomachObj.sens *= -1;
		}else{
			Game.me.incScore(score,fr.x, fr.y-14);
		}
		
		// BONUS
		if( !fr.has(Sugar) && Game.me.have(WOOL, true) ) 	new fx.Reduce(8,2);
		if( fr.has(Flower) && Game.me.have(THORNS, true) ) 	new fx.Reduce(50*Game.me.numCard(THORNS),2);
		
		// CARDS
		if( fr.has(Courge) && Game.me.have(CAULDRON,true) ) 					new fx.ShieldBoost();
		if( Game.me.have(MAGIC_POWDER) ) 										new fx.MagicPowder( Game.me.numCard(MAGIC_POWDER) );
		if( (fr.has(Poire) || fr.has(Apple)) && Game.me.have(BRANDY, true) ) 	new fx.Brandy();
		if( Game.me.have(BOUNTY) ) 	fx.Bounty.me.onEat(fr);
		if ( Game.me.have(SHOOTING_STAR) && Game.me.fruits.length > 0 && !fr.star )			new fx.ShootingStar(fr);
		
		// LOG
		var max = 1 +Game.me.numCard(MAGNIFIER);
		if( fr.etheral ) max = 0;
		for( i in 0...max ) Game.me.gameLog.fruits.push(fr.gid);
		
		
		//
		new fx.Eaten(fr);
		
		/*
		// FX
		var inc = 200;
		var m = [
			0, 0, 1, 0, inc,
			1, 0, 0, 0, inc,
			0, 1, 0, 0, inc,
			0, 0, 0, 1, 0.0
		];
	
		new fx.FlashScreen(0.02, m);
		*/
		
	}
	
	// COMMANDS
	public function cut(n:Float,fxFlash=false,fxBlood=false) {
	

		// FX
		var q = new fx.QueueDeath( length - n, length);
		
		if( fxFlash ){
			var o = getRingData(length - n);
			var p = Part.get();
			p.sprite.drawFrame( Gfx.fx.get(0, "slash") );

			var an = o.a + 1.57;
			p.sprite.rotation = an / 0.0174 ;
			p.vx = Snk.cos(an) * 5;
			p.vy = Snk.sin(an) * 5;
			p.frict = 0.95;
			p.x = o.ring.x - p.vx*3;
			p.y = o.ring.y - p.vy * 3;
			p.sprite.blendMode = flash.display.BlendMode.ADD;
		
			p.timer = 10;
			p.fadeType = 1;
			p.sprite.scaleX = 2;
			Stage.me.dm.add(p.sprite, Stage.DP_FX);
		}
		
		
		//
		length -= n;
		if ( length < 10 ) length = 10;
		majQueue();
		
		// RE-FX
		if ( fxBlood ) {
			new fx.AssBlood(12/ n);
			var sc = 0.5 + Math.min(n / 50, 1) * 1.5;
			fxBloodSpot(length,sc);
		}
			
		return q;
			
	}
	public function death() {
		if ( queue.length == 0 ) return;
		mcq.graphics.clear();
		var ring = queue.shift();
		drawQueue(queue, mcq.graphics);
		fxSplorch(ring.x,ring.y,4,2);
		
	}
	public function explode(n) {
		
		length -= n;
		
		if( length - n < 5 ) length = 0;

		while (true) {
			var p = queue.pop();
			if ( queue.length == 0 || p.pos < length ) break;
			else fxSplorch(p.x, p.y);

		}
		drawAll();
		if( length == 0 ) 	Game.me.gameover();
		
	}
	public function back() {
		
		trq.shift();
		rehead();
		majQueue();
	}
	public function reverse() {
		
		
		var sum = 0.0;
		var px = x;
		var py = y;
		var id = 0;
		for( p in trq ) {
			var dx = px - p.x;
			var dy = py - p.y;
			sum += Math.sqrt(dx * dx + dy * dy);
			if( sum > length ) break;
			px = p.x;
			py = p.y;
			id++;
		}
		
		//trace( "slice from " + id + " to " + (trq.length - 1));
		trq = trq.slice(0,id);
		
		trq.reverse();
		rehead();
		majQueue();
	}
	public function incLength(inc) {
		length += inc;
		if( length < 20 ) length = 20;
	}
	
	function rehead() {
		
		if( trq.length < 2 ) return;

		
		var p = trq[0];
		var p2 = trq[1];
		x = p.x;
		y = p.y;
		var dx = p.x - p2.x;
		var dy = p.y - p2.y;
		angle = Math.atan2(dy, dx);
				
	}
	
	// UTILS
	public function getRingData(n:Float) {
		var ring:QRing = { x:x, y:y, pos:0.0, size:1.0 };
		if( queue == null ) return { ring:ring, a:0.0 };
		
		var prev:QRing = null;
		for ( r in queue ) {
			if ( r.pos >= n || r == queue[queue.length - 1] ) {
				ring = r;
				if( prev != null ) {
					var c = (n - prev.pos) / (r.pos - prev.pos);
					ring = {
						pos:	prev.pos + (r.pos-prev.pos)*c,
						size:	prev.size + (r.size-prev.size)*c,
						x:		prev.x + (r.x-prev.x)*c,
						y:		prev.y + (r.y-prev.y)*c,
					}
					
				}
				break;
			}
			prev = r;
		}
		
		/*
		if( ring == null ) {
			trace("!!!!");
			ring = queue[queue.length - 1];
			prev = queue[queue.length - 2];
		}
		*/
		
		
		// ANGLE
		var a = 0.0;
		if ( prev != null) {
			var dx = ring.x - prev.x;
			var dy = ring.y - prev.y;
			a = Math.atan2(dy, dx);
		}
		
		
		return { ring:ring, a:a };
				
	}
	public function getNearestFruit() {
		var near:Fruit = null;
		var min = 99999.9;
		for( fr in Game.me.fruits ) {
			var dx = fr.x - x;
			var dy = fr.y - y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if( dist < min ) {
				min = dist;
				near = fr;
			}
		}
		
		return near;
		
	}
	public function isRingIn(r:QRing) {
		return ( r.x != x || r.y != y ) && r.pos < rlength;
	}
	
	// FX
	var glowCoef:Null<Float>;
	public function fxSplorch(px, py, spotMax = 10, partMax = 2) {
		
		// BODY
		var p = Stage.me.getPart("body_explode");
		p.setPos(Std.int(px), Std.int(py));
		p.sprite.scaleX = Std.random(2) * 2 - 1;
		p.sprite.scaleY = Std.random(2) * 2 - 1;
		Stage.me.sendToDepth(p.sprite, Stage.DP_SNAKE);
		
		
		
		// PARTS
		for ( i in 0...partMax ) {
			var pa = Part.get();
			Stage.me.dm.add(pa.sprite, Stage.DP_FX);
			pa.ray = 2;
			//pa.mark(0x008800);
			//pa.dropShade(false);
			pa.sprite.drawFrame( Gfx.fx.get(Std.random(6), "snake_parts"));
			pa.dropShade(true);
			pa.x = px;
			pa.y = py;
			var spe = Math.random() * 6;
			pa.vz = - Math.random() * 8;
			pa.vx =  (Math.random() * 2-1)*spe;
			pa.vy =  (Math.random() * 2-1)*spe;
			pa.weight = 0.4;
			pa.frict = 0.92;
			pa.timer = 30 +Std.random(15);
			pa.updatePos();
		}
		if( !Game.me.goreSpots ) return;
		
		spotMax = 1;
		// SPOTS
		var brush  = new pix.Element();
		for ( i in 0...spotMax ) {
			brush.drawFrame(Gfx.fx.get(Std.random(5), "blood_mini_spot"));
			var bmp = Stage.me.gore.bitmapData;
			var m = new flash.geom.Matrix();
			var x  = px + (Math.random() * 2 - 1) * 8;
			var y  = py + (Math.random() * 2 - 1) * 8;
			m.translate(Std.int(x), Std.int(y));
			bmp.draw(brush, m);
		}
		brush.kill();
		var n = 16;
		Stage.me.renderBg(new flash.geom.Rectangle(px-n,py-n,n*2,n*2));
		

	

		// BLOOD
		fxBloodDrop(px,py,10,4);

		
		
	}
	public function fxBloodSpot(n,sc=2.0) {
		if(!Game.me.goreSpots ) return;
		var px = 0.0;
		var py = 0.0;
		for ( r in queue ) {
			px = r.x;
			py = r.y;
			if ( r.pos >= n ) break;
		}
		if (n == 0) {
			px = x;
			py = y;
		}
		
		//
		
		//sc = 8.0;
		var p = new pix.Element();
		p.drawFrame(Gfx.fx.get(0, "blood"));
		p.x = px;
		p.y = py;
		Stage.me.ground.addChild(p);
		var bmp = Stage.me.gore.bitmapData;
		var m = new flash.geom.Matrix();
		var mx = Std.random(2)*2-1;
		var my = Std.random(2)*2-1;
		m.scale(sc*mx, sc*my);
		m.translate(px, py);
		bmp.draw(p, m);
		Stage.me.renderBg(p.getBounds(Stage.me.bg));
		p.kill();
	}
	public function fxBloodDrop(px,py,max=6,proj=5) {
		if(!Game.me.goreSpots ) return;
		for ( i in 0...max ) {
			var p = part.BloodDrop.get();
			var a = Math.random() * 6.28;
			var sp = Math.random() * proj;
			p.vx = Snk.cos(a) * sp;
			p.vy = Snk.sin(a) * sp;
			p.x = px + p.vx*2;
			p.y = py + p.vy*2;
			p.z = -4;
			p.vz = sp - proj * 0.5;
			if ( Math.random() < 0.2 ) p.vz -= Math.random() *4;
		}
	}
	public function fxQueueSpark() {

		var ring = queue[queue.length - 1];
		var p = part.Line.get();
		p.launch(Math.random() * 6.28, 1 +Math.random() * 2, -Math.random());
		p.x = ring.x + p.vx;
		p.y = ring.y + p.vy;
		p.color = 0xFFFFFF;
		p.timer = 10 + Std.int(20);
		p.multi = 2;
		p.glowCoef = 1;
		p.updatePos();
		Stage.me.dm.add(p.sprite, Stage.DP_FX);
		p.sprite.blendMode = flash.display.BlendMode.ADD;
		p.updatePos();
		
		//
		if( Game.me.gtimer%3 == 0 ){
			var p = Stage.me.getPart("pulse");
			p.x = ring.x;
			p.y = ring.y;
			p.updatePos();
			p.sprite.blendMode = flash.display.BlendMode.ADD;
			p.sprite.alpha = 0.5;
		}
		
		
	}
	function majGlow() {
		glowCoef = Math.max(glowCoef - 0.025, 0);
		var c = Math.pow(glowCoef,0.5);
		//var root = mcq;
		root.filters = [];
		Filt.glow(root, 10 * c, c, 0xFFFFFF);
		Filt.glow(root, 2, c, 0xFFFF00);
		Col.setColor(root, 0, Std.int(c*255));
		if( glowCoef == 0 ) glowCoef = null;
		
	}
	public function fxGlow(n) {
		glowCoef = n;
		majGlow();
	}
	public function fxAllSparkDust() {
		var ec = 3;
		for( ring in queue ) {
			for( i in 0...3 ) {
				
				var p = Part.get();
				p.sprite.setAnim( Gfx.fx.getAnim("spark_dust"), true );
				p.x = ring.x + Std.random(9)-4;
				p.y = ring.y + Std.random(9)-4;
				p.timer = 10 + Std.random(20);
				p.weight = -(0.05 + Math.random() * 0.3);
				p.frict = 0.9;
				p.sprite.anim.gotoRandom();
				Stage.me.dm.add(p.sprite, Stage.DP_FX);
				p.setSleep( i*ec + Std.random(ec));
								
				var p2 = Stage.me.getPart("spark_dust_blow");
				p2.x = p.x;
				p2.y = p.y;
				p2.setSleep(i*ec + Std.random(ec));
				p2.sprite.anim.stop();
				p2.sprite.blendMode = flash.display.BlendMode.ADD;
				p2.sprite.alpha = 0.5;
				Filt.glow(p2.sprite, 9, 1, 0xFFFFFF);
				
				p.updatePos();
				p2.updatePos();
				
			}
		}
	}
	
	//
	public function burn() {
		Game.me.gameover();
	}
	public function kill() {
		mcq.parent.removeChild(mcq);
		Game.me.snake = null;
	}
	
	
//{
}












