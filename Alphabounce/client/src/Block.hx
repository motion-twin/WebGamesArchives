import mt.bumdum.Phys;
import mt.bumdum.Sprite;
import mt.bumdum.Lib;

class Block {//}

	public static var MIN_GREEN = 	new mt.flash.VarSecure(1);
	public static var MIN_BLUE = 	new mt.flash.VarSecure(5);
	public static var MIN_PINK = 	new mt.flash.VarSecure(25);

	public static var BONUS_MAX =		3;
	public static var MOLECULE_MAX =	10;

	public static var BONUS = 		10;
	public static var BALL = 		13;
	public static var BOOM = 		14;
	public static var SPACE = 		15;
	public static var REDUC = 		16;
	public static var STEEL = 		17;
	public static var PUSHER = 		18;
	public static var JUMPER = 		19;
	public static var STORM = 		20;
	public static var ITEM = 		21;
	public static var CAGE =		22;
	public static var GENERATOR =		32;
	public static var LURE =		42;
	public static var DRAGON_LEFT =		43;
	public static var DRAGON_RIGHT =	44;
	public static var INSECT =		45;
	public static var SWAP =		46;
	public static var MISSILE =		47;
	public static var DOOR =		48;
	public static var DEPLETED =		49;

	public static var NUT =			50;
	public static var KILL =		51;
	public static var LIFE =		52;
	public static var DEATH =		53;
	public static var GLUE =		54;
	public static var GUARDIAN =		55;
	public static var MINE =		56;

	var flStandard:Bool;
	var flEdit:Bool;
	public var flIce:Bool;
	public var flDeath:Bool;
	public var root:flash.MovieClip;
	public var x:Int;
	public var y:Int;
	public var molType:Int;
	public var type:Int;
	public var life:Float;
	public var transform:Float;
	public var lastShot:Float;
	public var color:Array<Int>;

	var explodeTimer:Float;

	public var event:Event;
	public var update:Void->Void;
	public var respawnTimer:Float;
	public var onDamage:el.Ball->Void;
	public var dm:mt.DepthManager;

	var blink:flash.MovieClip;

	public function new(px,py,?t,?mc,?flEdit){

		this.flEdit = flEdit;

		x = px;
		y = py;
		register();

		flIce = false;
		transform = 0;

		//
		root = mc;
		if(root==null)root = Game.me.bdm.attach("mcBlock",0);
		if(px!=null)root._x = Cs.getX(x);
		if(py!=null)root._y = Cs.getY(y);



		//root._width = Cs.BW;
		//root._height = Cs.BH;

		//
		if(t!=null)setType(t);
		//

	}

	public function setType(t){

		//if(t!=0 && t!=1 && t!=2 && t!=3 && t!=4 && t!=10 && t!=STEEL)trace("!"+t +">BOOM =("+BOOM+")  >BALL= ("+BALL+")");

		type = t;


		//if(t==5)root._alpha = 20;
		if(event!=null)event.kill();
		molType = null;
		life = 0;

		if(type<BONUS){
			if(type==0)setStandard();
			life = Math.min(type,5);
			color = [ Game.me.level.bmpPaint.getPixel(x,y) ];
			if( life >= 1 )color = [0x885533];

		}else if(type<=BONUS+3){

			var id = type-10;
			life = 0;
			color = [[0xB3FD02,0x0BCDFD,0xFF5599][id]];

		}else if( type>=CAGE && type<CAGE+MOLECULE_MAX  ){
			molType = type-CAGE;

		}else if( type>=GENERATOR && type<GENERATOR+MOLECULE_MAX  ){
			molType = type-GENERATOR;
			event = new ev.Generator(this);
			color = [0x663399,0x950DD0,0xFF55EE];
			if(flEdit){
				var dm = new mt.DepthManager(root);
				for( i in 0...3 ){
					var mc = dm.attach("mcSpeederBall",1);
					mc._x = i*3 + 10;
					mc._y = Cs.BH-2;
					mc.gotoAndStop(el.Molecule.INFOS[molType].mols[i]+1);
					mc._xscale = mc._yscale = 75;
					if(i==1)mc._y-=2;
				}
			}

		}

		switch(type){
			case BALL:
				//color = [0xFFFFFF];
			case BOOM:
				//color = [0xFFDD00];
			case SPACE:
				color = [0x7711FF];
			case REDUC:
				color = [0x759BA4,0x759BA4,0x00F0FF];
				life = null;
				onDamage = shootReduc;
			case STEEL:
				color = [0x759BA4];
				life = null;
			case PUSHER:
				color = [0x78D816,0xFF0000];
				life = 6;
				onDamage = shootGenerator;
			case JUMPER:
				color = [0xFFCC00,0xFF0000];
				life = 3;
				onDamage = shootJumper;
			case STORM:
				color = [0x759BA4,0x759BA4,0xFFFF00];
				life = null;
				onDamage = shootStorm;
			case ITEM:
				setStandard();
				color = [0x69B43D];
			case LURE:
				color = [0x759BA4];
			case DRAGON_LEFT:
				color = [0x376617,0x5EAC28];
			case DRAGON_RIGHT:
				color = [0x376617,0x5EAC28];
			case INSECT:
				color = [ Game.me.level.bmpPaint.getPixel(x,y) ];
				dm = new mt.DepthManager(root);
				var ma = 2;
				for( i in 0...8 ){
					var mc = dm.attach("mcInsectBlock",0);
					mc._x = ma+Math.random()*(Cs.BW-2*ma);
					mc._y = ma+Math.random()*(Cs.BH-2*ma);
					mc.stop();
					mc.smc.stop();
				}
			case SWAP:
				color = [0xCCFFCC,0x0C7C2D];
				life = null;
				onDamage = shootSwap;
			case MISSILE:
				color = [0x444466];
			case DOOR:
				//color = [0xE82A18,0xF266D6,0x35A926,0xFFD97F];
				color = [0xF2C204];
			case DEPLETED:
				color = [0x5D684C];
			case NUT:
				color = [0xF1D89E,0xFAE8C0];
				life = 1;
			case KILL:
				color = [0x759BA4,0x759BA4,0xFF0000];
				life = null;
				onDamage = shootKill;
			case LIFE:
				color = [0xFFFFFF,0xFF0000];
			case DEATH:
				color = [0x423968,0x141221,0xFFFFFF];
			case GLUE:
				color = [0x759BA4,0x759BA4,0xFF8800];
				life = null;
				onDamage = shootGlue;
			case GUARDIAN:
				color = [0x996699,0x6B476B,0xFF9122];
			case MINE:
				color = [ Game.me.level.bmpPaint.getPixel(x,y) ];

		}

		if(life!=null)life += 0.9;

		setSkin(root);

	}
	public function setStandard(){
		if(flStandard)return;
		Game.me.block++;
		flStandard = true;
	}

	public function setColor(col){
		color = col;
		Col.setColor(root.smc.smc,color[0]);
	}
	public function setLife(n){
		life = n;
		if(root.smc!=null)root.smc.gotoAndStop(Std.int(life)+1);
		if(color!=null)setColor(color);
	}
	public function setSkin(mc){
		if(type<=5){
			mc.gotoAndStop(1);

		}else if(type<=12){
			var id = type-10;
			mc.gotoAndStop(id+2);
		}else{
			mc.gotoAndStop(type-8);
		}
		if(mc.smc!=null)mc.smc.gotoAndStop(Std.int(life)+1);
		Col.setColor(mc.smc.smc,color[0]);

		if(molType!=null){
			var o = el.Molecule.INFOS[molType];
			var id = 0;
			for( n in o.mols ){
				var mc = Reflect.field(root,"_mc"+id);
				mc.gotoAndStop(n+1);
				id++;
			}
		}

	}

	public function incTransform(n:Float,?nt){
		if(flDeath)return;
		if(nt==null)nt = 0;
		transform = Math.min(transform+n*mt.Timer.tmod,1);
		if(transform==1){
			if( isBonus(type) ){
				explode();
			}else{
				dm.clear(0);
				onDamage = null;
				setType(nt);
			}
		}
	}

	//
	public function damage(ball:el.Ball){

		// DESTROY ICE
		if(flIce){
			explode();
			return;
		}

		// ICE BLOCK
		if( ball.type == Cs.BALL_ICE ){
			iceIt();
			return;
		}

		//
		var ol = Std.int(life);
		if( ball.type != Cs.BALL_VOLT )onDamage(ball);

		// WEAK && INDESTRUCTIBLE
		if( (ball.fam==0 && life>=1) || life==null){
			if( ball.damage == 100 ){
				explode();
			}else{
				fxBlink();
			}
			return;
		}


		// DEATH
		if( type == DEATH )ball.destroy();

		// STANDARD DAMAGE
		var n = ball.damage;
		if(life>=n){

			setLife(life-n);
			if(ol!=Std.int(life))fxBlink();

		}else{
			explode();
		}
	}
	function iceIt(){
		type = 0;
		flIce = true;
		var mc = new mt.DepthManager(root).attach("mcIce",0);
		mc.gotoAndStop(Std.random(mc._totalframes)+1);
		var nx = Std.random(2);
		var ny = Std.random(2);
		mc._xscale = (nx*2-1)*100;
		mc._yscale = (ny*2-1)*100;
		mc._x = (1-nx)*Cs.BW;
		mc._y = (1-ny)*Cs.BH;

	}

	public function explode(){

		// SPACE
		if( type == SPACE ){
			unregister();
			setUpdate(fadeOut);
			respawnTimer = 600;
			return;
		}
		if( type == DOOR ){
			unregister();
			setUpdate(fadeOutVert);
			return;
		}

		// PARTS
		var max = Std.int( Num.mm( 2, 18-Sprite.spriteList.length*0.25, 16 )*Cs.PREF_GFX );
		if(type>=BONUS && type<=BONUS+BONUS_MAX){
			fxTwinkle(max);
		}else{
			fxExplode(max);

		}

		// OPTION
		if( flStandard && type!=ITEM ){
			var opt = Game.me.level.bonusTable[x][y];
			if( opt !=null && Game.me.options.length< Cs.MAX_OPTION ){
				Game.me.level.bonusTable[x][y] = null;
				Game.me.newOption(opt,Cs.getX(x+0.5),Cs.getY(y+0.5));
			}
		}

		// EFFECT
		switch(type){
			case BONUS:		Game.me.incMinerai(MIN_GREEN);
			case BONUS+1:		Game.me.incMinerai(MIN_BLUE);
			case BONUS+2:		Game.me.incMinerai(MIN_PINK);
			case DRAGON_LEFT:	new ev.Dragon(this,-1);
			case DRAGON_RIGHT:	new ev.Dragon(this,1);
			case BALL:
				var b = Game.me.newBall();
				b.moveTo( root._x+Cs.BW*0.5,root._y+Cs.BH*0.5);
				b.setAngle(Math.random()*6.28);
				fxGlass(max);

			case BOOM:
				explodeTimer = 4;
				setUpdate(updateExplode);
				fxBoom();

			case MINE:
				fxBoom();
				var ray = 1;
				for( dx in 0...(ray*2+1) ){
					for( dy in 0...(ray*2+1) ){
						var nx = x+dx-ray;
						var ny = y+dy-ray;
						var bl = Game.me.grid[nx][ny];
						if( bl !=null && bl!=this && bl.flDeath!=true ){
							bl.flDeath = true;
							bl.explode();
						}
					}
				}

				/*
				explodeTimer = 4;
				setUpdate(updateExplode);
				var sp = new fx.Tracer( Game.me.dm.attach("partBoom",Game.DP_PARTS) );
				sp.x = Cs.getX(x+0.5);
				sp.y = Cs.getY(y+0.5);
				sp.root.blendMode = "add";
				sp.timer = 5;
				sp.fadeType = -1;
				sp.updatePos();
				*/

			case INSECT:

				for( i in 0...10 ){
					var a = Math.random()*6.28;
					var speed = 0.5+Math.random()*6;
					var sp = new fx.Fly(null);
					sp.x = Cs.getX(x+Math.random());
					sp.y = Cs.getY(y+Math.random());
					sp.vx = Math.cos(a)*speed;
					sp.vy = Math.sin(a)*speed;
					if( i>1 )sp.timer = 10+Math.random()*20;
				}

			case MISSILE:
				if(Cs.pi.missileMax>0)Game.me.newOption(26,Cs.getX(x+0.5),Cs.getY(y+0.5));

			case NUT :
				var shot = new BadShot( Game.me.dm.attach("mcBadShot",Game.DP_PARTS) );
				shot.vr = 37;
				shot.setType(1);
				shot.frontShot(this,-5);
				shot.weight = 1;
				shot.vx = (Math.random()*2-1)*0.8;
				Filt.glow(shot.root,2,4,0xFFFFFF);
				Filt.glow(shot.root,10,1,0xFFFFFFF);

			case LIFE :
				Game.me.newLife(Game.me.life.get(),true);
				Game.me.life.addValue(1);
				fxSparks(24,3,8,100);

			case GUARDIAN :
				var shot = new BadShot( Game.me.dm.attach("mcBadShot",Game.DP_PARTS) );
				shot.directShot(this,36);
				shot.height = Math.abs(shot.vy);
				shot.setType(4);

		}
		if(molType!=null){

			var max = 0;
			if( type<GENERATOR ){
				max = 1;
				fxGlass(max);
			}
			for( i in 0...max )genMolecule();


		}

		// PART ICE
		if(flIce){
			for( n in 0...Std.int(max*0.5) ){
				var p = new Phys( Game.me.dm.attach("partIceShard",Game.DP_PARTS) );
				initExplode(p);
				p.weight*=0.5;
				p.root._rotation = Math.atan2(p.vy,p.vx)/0.0174;
				p.vr = (Math.random()*2-1)*6;

			}
		}

		// ITEM
		if( type == ITEM ){
			var opt = new Option(Game.me.dm.attach("optItem",Game.DP_OPTION));
			opt.x = Cs.getX(x+0.5);
			opt.y = Cs.getY(y+0.5);
			opt.setItem(Game.me.level.itemId);
		}

		//
		kill();

	}


	// SPECIALS
	function shootReduc(ball){
		if( Game.me.pad == null)return;
		if( Game.me.pad.ray == Pad.SIDE+1 )return;

		// FX
		var mc = Game.me.dm.attach("fxReduc",Game.DP_PARTS);
		mc._x = Cs.getX(x+0.5);
		mc._y = Cs.getY(y+0.5);

		// SHOT
		var shot = new BadShot( Game.me.dm.attach("mcBadShot",Game.DP_PARTS) );
		shot.directShot(this,12);
		shot.setType(0);
		shot.height = Math.abs(shot.vy*10);
		//trace(shot.height);



	}
	function shootGenerator(ball){
		if(ball==null)return;

		var dx = (x-ball.px);
		var dy = (y-ball.py);

		var n = 0;
		var list = [];
		var flAbort = false;
		while(true){
			n++;
			var nx = x+dx*n;
			var ny = y+dy*n;
			if( nx<0 || nx>=Cs.XMAX || ny<0 || ny>=Cs.YMAX ){
				flAbort = true;
				break;
			}

			var bl = Game.me.grid[nx][ny];
			if( bl == null )break;
			list.unshift(bl);
		}

		/*
		if(list.length>0){
			trace(list.length);
		}
		*/
		if(!flAbort){
			for( bl in list ){
				bl.unregister();
				bl.setPos( bl.x+dx, bl.y+dy );
				bl.register();
			}

			var bl = new Block( x+dx, y+dy, 0 );

		}




		//trace(dx+";"+dy);

	}
	function shootJumper(ball:el.Ball){
		if(life-ball.damage<0 )return;

		unregister();
		root._visible = false;
		//
		var sp = new fx.Jumper(Game.me.dm.attach("mcJumper",Game.DP_PARTS));
		sp.x = Cs.getX(x+0.5);
		sp.y = Cs.getY(y+0.5);
		sp.bl = this;
		sp.root.gotoAndStop(life);
		sp.seekTrg();
	}
	function shootStorm(ball){
		if( Game.me.pad == null || ev.Storm.TOTAL >= 3 )return;
		if( flash.Lib.getTimer()-lastShot < 1000 )return;
		var ev = new ev.Storm();
		ev.bl = this;
		lastShot = flash.Lib.getTimer();

	}
	function shootSwap(ball){
		Game.me.swapScreen();
	}
	function shootKill(ball){
		if( Game.me.pad == null)return;
		if( flash.Lib.getTimer()-lastShot < 1000 )return;

		// FX
		var mc = Game.me.dm.attach("fxKill",Game.DP_PARTS);
		mc._x = Cs.getX(x+0.5);
		mc._y = Cs.getY(y+0.5);

		// SHOT
		for( i in 0...8 ){
			var shot = new BadShot( Game.me.dm.attach("mcBadShot",Game.DP_PARTS) );
			//shot.directShot(this,6);
			shot.bl = this;
			shot.sleep = i*4;
			shot.setType(2);
		}

		lastShot = flash.Lib.getTimer();
		//trace(shot.height);



	}
	function shootGlue(ball){
		if( Game.me.pad == null)return;

		var shot = new BadShot( Game.me.dm.attach("mcBadShot",Game.DP_PARTS) );
		shot.directShot(this,8+Math.random()*4,0.3);
		shot.setType(3);

		shot.root.smc.gotoAndPlay(Std.random(10));


	}



	function updateExplode(){
		explodeTimer--;
		var ray = Std.int(2-explodeTimer*0.5);
		for( dx in 0...(ray*2+1) ){
			for( dy in 0...(ray*2+1) ){
				var nx = x+dx-ray;
				var ny = y+dy-ray;
				var bl = Game.me.grid[nx][ny];
				if( bl !=null ){
					bl.explode();
				}
			}
		}

		if(explodeTimer==0)removeUpdate();

	}
	public function genMolecule(){
		var mon = new el.Molecule(null);
		mon.setType(molType);
		mon.moveTo( root._x+Cs.BW*0.5,root._y+Cs.BH*0.5);

	}

	// CRAWLERS
	function setUpdate(f){
		if(update!=null)Game.me.crawlers.remove(this);
		update = f;
		Game.me.crawlers.push(this);
	}
	public function removeUpdate(){
		update = null;
		Game.me.crawlers.remove(this);
	}
	function fadeOut(){

		if(root._alpha>0)root._alpha -= 10;
		respawnTimer -= mt.Timer.tmod;
		if(respawnTimer <=0 ){
			if( Game.me.grid[x][y] == null ){
				register();
				setUpdate(fadeIn);
			}
		}

	}
	function fadeIn(){
		if(root._alpha<100){
			root._alpha += 10;
		}else{
			removeUpdate();
		}
	}

	function fadeOutVert(){
		if(root._yscale>0)root._yscale *= 0.75;

		var flOk = false;
		for( b in Game.me.balls ){
			if( b.py < y ){
				flOk = true;
				break;
			}
		}
		if(!flOk)return;

		if( Game.me.grid[x][y] == null ){
			register();
			setUpdate(fadeInVert);
		}



	}
	function fadeInVert(){
		if(root._yscale<100){
			root._yscale = Math.min(root._yscale+10,100);
		}else{
			removeUpdate();
		}
	}


	//
	public function register(){
		flDeath = false;
		Game.me.blocks.push(this);
		Game.me.grid[x][y] = this;
	}
	public function unregister(){
		flDeath = true;
		Game.me.blocks.remove(this);
		Game.me.grid[x][y] = null;
	}
	public function setPos(px,py){
		x = px;
		y = py;
		root._x = Cs.getX(x);
		root._y = Cs.getY(y);
	}

	//FX
	public function fxBlink(){

		var mc = Game.me.dm.attach("mcBlink",Game.DP_BLOCK);
		mc._x = root._x;
		mc._y = root._y;
		blink = mc;
		mc.blendMode ="add";
		Filt.glow(mc,10,1,0xFFFFFF);
	}
	public function fxGlass(max){
		for( n in 0...max ){
			var p = new fx.Part( Game.me.dm.attach("partGlass",Game.DP_PARTS) );
			initExplode(p);
			p.bouncer.setPos(p.x,p.y);
			p.root._rotation = Math.random()*2-1;
			p.vr = (Math.random()*2-1)*12;
			p.setScale(p.scale*(1+Math.random()*0.6));
			p.root.gotoAndStop(Std.random(p.root._totalframes)+1);
			p.updatePos();
		}
	}
	public function fxSparks(max,?cr,?spMax,?randSize){
		if(cr==null)cr = 3;
		if(spMax==null)cr = spMax;
		if(randSize==null)randSize = 0;
		for( i in 0...max ){
			var a = ((i+Math.random())/max)*6.28;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = Math.random()*spMax;
			var p = new Phys(Game.me.dm.attach("partSpark",Game.DP_PARTS));
			p.x = root._x+Cs.BW*0.5 + ca*sp*cr*1.5;
			p.y = root._y+Cs.BH*0.5 + sa*sp*cr;
			p.vx = ca*sp*1.5;
			p.vy = sa*sp;
			p.timer = 10+Math.random()*10;
			p.fadeType = 0;
			p.updatePos();
			p.root.gotoAndStop(3);
			p.root.smc.gotoAndPlay(Std.random(2)+1);
			p.frict = 0.9;
			p.setScale(100+Math.random()*randSize);
			//Filt.glow(p.root,10,2,0xCC88FF);
			//p.root.blendMode = "add";

		}
	}
	public function fxBolt(){
		var mc = Game.me.dm.attach("mcBolt",Game.DP_PARTS);
		mc._xscale = mc._yscale = 50+Math.random()*100;
		Filt.glow( mc,10,1,0xFFFF00 );
		mc.blendMode = "add";
		mc._x = Cs.getX( x+Math.random() );
		mc._y = Cs.getY( y+Math.random() );
		mc._rotation =  Math.random()*360;
	}
	public function fxTwinkle(max){
		var ma = -0.5;
		for( i in 0...max ){
			var p = new Phys( Game.me.dm.attach("partTwinkle",Game.DP_PARTS) );
			var a = i/max * 6.28;
			var ray = 5+Math.random()*20;
			p.x = Cs.getX(x+0.5) + Math.cos(a)*ray ;
			p.y = Cs.getY(y+0.5) + Math.sin(a)*ray ;

			p.timer = 10+Math.random()*10;
			p.fadeType = 0;
			p.setScale(50+Math.random()*100);
			p.sleep = Math.random()*(ray-5);
			p.vy -= Math.random();
			p.root.blendMode = "add";
			p.root.gotoAndPlay(Std.random(2)+1);
			p.updatePos();
		}
	}
	public function fxExplode(max){
		// BASE
		var mc = Game.me.dm.attach("partExplode",Game.DP_PARTS);
		mc._x = root._x;
		mc._y = root._y;
		mc._xscale = Cs.BW/30 *100;
		mc._yscale = Cs.BH/10 *100;
		if(color!=null)Col.setColor(mc,color[0]);

		// PARTS
		for( n in 0...max ){
			var p = new fx.Part( Game.me.dm.attach("mcPart",Game.DP_PARTS) );
			initExplode(p);
			p.bouncer.setPos(p.x,p.y);
			p.updatePos();
			if(color!=null)	Col.setColor( p.root, color[Std.random(color.length)] );
		}
	}
	public function fxFrout(max){

		for( i in 0...max ){
			var p = new Phys(Game.me.dm.attach("mcPart",Game.DP_PARTS));
			p.x = Cs.getX(x+Math.random());
			p.y = Cs.getY(y+Math.random());
			p.weight = p.weight = 0.07+Math.random()*0.1;
			p.fadeType = 0;
			p.frict = 0.98;
			p.setScale(p.weight*700);
			p.timer = 10+Math.random()*10;
			if(color!=null)	Col.setColor( p.root, color[Std.random(color.length)] );
		}
	}
	public function fxBoom(){
		var sp = new fx.Tracer( Game.me.dm.attach("partBoom",Game.DP_PARTS) );
				sp.x = Cs.getX(x+0.5);
				sp.y = Cs.getY(y+0.5);
				sp.root.blendMode = "add";
				sp.timer = 5;
				sp.fadeType = -1;
				sp.updatePos();
	}

	/*
	public function fxSpark(max){
		fxFrout(max);
	}
	*/


	function initExplode(p){

		var cx = root._x + Cs.BW*0.5;
		var cy = root._y + Cs.BH*0.5;

		p.x = Cs.getX(x+Math.random());
		p.y = Cs.getY(y+Math.random());
		var dx = p.x-cx;
		var dy = p.y-cy;
		var a = Math.atan2(dy,dx);
		var sp = Math.sqrt(dx*dx+dy*dy)*0.2;
		p.vx = Math.cos(a)*sp;
		p.vy = Math.sin(a)*sp;
		//
		p.timer = 10+Math.random()*20;
		p.weight = 0.07+Math.random()*0.1;
		p.fadeType = 0;
		p.frict = 0.98;
		p.setScale(p.weight*700);
	}


	// KILL
	public function kill(){
		if(event!=null)event.kill();

		unregister();
		if( flStandard )Game.me.removeBlock();
		if(blink._visible)blink.removeMovieClip();
		root.removeMovieClip();
	}

	// EXTERNAL TOOLS
	public static function isSoft(n){
		return n!=STEEL && n!=SWAP && n!=DOOR && !isSentinelle(n);
	}
	public static function isSentinelle(n){
		return n==REDUC || n==STORM || n==KILL || n==GLUE || n==LURE;
	}
	public static function isBonus(n){
		n-=BONUS;
		return n >= 0 && n<3;
	}
	public static function isBasic(n){
		return  n==STEEL || n==DOOR || n==DRAGON_LEFT || n==MISSILE || n==BOOM || n==PUSHER || n<BONUS+3 || n==INSECT || n==REDUC;
	}



	//{
}













