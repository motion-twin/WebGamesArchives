import mt.bumdum9.Lib;

typedef PacBumper = {>Phx, power:Float, bx:Float, by:Float, link:flash.display.MovieClip };
typedef PacPiou = {>Phx, ctimer:Int };

class Pachinko extends Game{//}

	static var DIST_MAX = 60;

	static var PROP_PIOU = new phx.Properties( 0.999, 0.999, 0.75, 1e99, 0.5 );
	static var MAT_PIOU = new phx.Material(0,0.1,0.5);
	static var MAT_BUMPER = new phx.Material(0.75,0.1,0.5);

	var bmax:Int;
	var drag:PacBumper;
	var piouz:List<PacPiou>;
	var bumpers:List<PacBumper>;
	var timer:Int;

	override function init(dif:Float){
		gameTime =  700-100*dif;
		super.init(dif);
		timer = 0;
		bmax = 2 + Std.int(dif*3);
		piouz = new List();
		attachElements();


	}

	function attachElements(){


		bg = dm.attach("pachinko_bg",0);

		// WORLD
		initWorld();
		var aabb = new phx.col.AABB(0,0,Cs.mcw,Cs.mch);
		world = new phx.World( aabb, new phx.col.BruteForce() );
		world.gravity.set(0,0.3);

		// BUMPER
		var ma = 40;
		bumpers = new List();
		var px = Cs.mcw*0.5 + 30;
		var py = 135-bmax*10;
		for( i in 0...bmax ){
			var mc = dm.attach("pachinko_bumper",1);
			mc.stop();
			var bumper:PacBumper = cast new Phx(mc);
			bumper.game = this;
			//var x = ma+(i/(bmax-1))*(Cs.mcw-2*ma);
			//var y = 150+(i%2)*40;
			var x = Std.int(px/10)*10;
			var y = py;
			do{
				px += (Math.random()*2-1)*200;

			}while( px<ma || px>Cs.mcw-ma || Math.abs(px-x)<30 );

			py+= 116-bmax*9;


			bumper.material = MAT_BUMPER;
			bumper.setPos( x, y );
			bumper.setCirc(15);
			bumper.setStatic(true);
			
			var me = this;
			bumper.root.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, function(e) { me.startDrag2(bumper); } );
			//bumper.root.addEventListener( flash.events.MouseEvent.MOUSE_UP, function(e) { me.stopDrag2(); } );
			//sbumper.root.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(e) { if(!me.click)me.stopDrag2(); } );
			
			//bumper.root.onPress = callback(startDrag,bumper);
			//bumper.root.onRelease = stopDrag;
			//bumper.root.onReleaseOutside = stopDrag;
			
			getSmc(bumper.root).stop();
			
			
			
			bumper.power = 0;
			bumper.bx = x;
			bumper.by = y;
			addPhxCheck(bumper,callback(colBumper,bumper));
			bumpers.push(bumper);

			var axe = dm.attach("pachinko_axe",0);
			axe.x = x;
			axe.y = y;
			axe.gotoAndStop(Std.random(axe.totalFrames)+1);

			//var dx = x - Cs.mcw*0.5;
			//var dy = y - Cs.mch*0.5;
			//axe.rotation = Math.atan2(dy,dx)/0.0174;

		}

		// CEILING
		var mc = dm.attach("pachinko_ceiling",2);

	}

	override function update(){
		world.step(1,2);
		updatePhxCols();

		updateDrag();

		// GENERATOR
		if(timer--==0){
			newPiou();
			timer = 10;
		}

		// PIOUZ
		for( p in piouz ){
			getSmc(p.root).rotation = -p.root.rotation;
			if(p.ctimer>0)p.ctimer--;
			if(p.y>Cs.mch+10){
				p.kill();
				piouz.remove(p);
			}
		}

		// BUMPER
		var flWillWin = true;
		for( b in bumpers ){
			if(b.power>0 && win==null )b.power -= 0.025;
			getSmc(b.root).gotoAndStop(1+Std.int(b.power));
			var flOk = b.power>=18;
			b.root.gotoAndStop(flOk?2:1);
			if(!flOk)flWillWin = false;

		}
		if(flWillWin)setWin(true,20);





		super.update();
	}

	function newPiou(){
		var piou:PacPiou = cast new Phx(dm.attach("pachinko_pearl", 1));
		piou.game = this;
		piou.body.properties = PROP_PIOU;
		piou.setPos(Cs.mcw*0.5+1,-10);
		piou.setAngle(0.1);
		//piou.body.w = (Math.randzom()*2-1)*0.3;
		piou.ctimer = 0;
		piou.setCirc(6);
		piouz.push(piou);
	}

	// BUMPER
	function startDrag2(bumper){
		drag = bumper;
		if(bumper.link==null){
			bumper.link = dm.attach("pachinko_link",0);
			getSmc(bumper.link).scaleX = 0;
			Filt.glow(bumper.link,10,1,0xFFFFFF);
			bumper.link.blendMode = flash.display.BlendMode.ADD;
			bumper.link.x = bumper.bx;
			bumper.link.y = bumper.by;
			bumper.link.scaleY = 0.4;
		}
		//bumper.root.gotoAndStop(2);
	}
	function stopDrag2(){
		drag = null;
	}
	function updateDrag() {
		if(!click) 	stopDrag2();
		if( drag == null ) return;
		
		var mp = getMousePos();
		var dx = mp.x - drag.bx;
		var dy = mp.y - drag.by;
		var dist = Math.sqrt(dx*dx+dy*dy);
		var a = Math.atan2(dy,dx);
		if( dist > DIST_MAX ){
			dist = DIST_MAX;
			mp.x = drag.bx + Math.cos(a)*DIST_MAX;
			mp.y = drag.by + Math.sin(a)*DIST_MAX;
		}

		getSmc(drag.link).scaleX = dist*0.01;
		drag.link.rotation = a/0.0174;

		drag.setPos(mp.x,mp.y);
	}

	function colBumper(bumper:PacBumper,w:Phx){
		if(drag==bumper)return;
		var piou:PacPiou = cast w;
		if(piou.ctimer==0){
			new mt.fx.Flash(w.root);
			piou.ctimer = 6;
			bumper.power+=2.5;
			if(bumper.power>30)bumper.power = 24;
			getSmc(bumper.root).gotoAndStop(1+Std.int(bumper.power));
		}

	}


//{
}















