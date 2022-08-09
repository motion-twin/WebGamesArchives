import mt.bumdum9.Lib;

class McCollineMonster extends CollineMonster {
	public var dec:Float;
	public var spd:Float;
	public var by:Float;
	public function new() {
		super();
		dec = Math.random() * 6.28;
		spd = 0.1 + Math.random() * 0.1;
	}
	public function update() {
		dec = (dec + spd) % 6.28;
		y = by + Math.cos(dec) * 20;
	}
}

class Colline extends Game{//}

	// CONSTANTES
	static var MARGIN = 6;
	static var SMARGIN = 2;
	//static var GL = 216;
	static var GL = 186;
	static var BRAY = 11;

	// VARIABLES
	var flFall:Bool;
	var max:Int;
	var ec:Float;
	var dList:Array<Phys>;

	// MOVIECLIPS
	var colline:flash.display.MovieClip;
	var ball:Phys;
	var mons:Array<McCollineMonster>;

	override function init(dif){
		gameTime = 220;
		super.init(dif);
		flFall = false;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("colline_bg",0);

		
		//
		var max = 48;
		mons = [];
		for( i in 0...max ) {
			var c = Math.pow( i / max, 2);
			var mon = new McCollineMonster();
			mon.by = Cs.omch+c*30 - 20;
			mon.y = mon.by;
			mon.scaleX = mon.scaleY = 0.75 + c * 0.5;
			mon.x = Math.random() * Cs.omcw;
			mon.gotoAndPlay(Std.random(60) + 1);
			bg.addChild(mon);
			mons.push(mon);
			Col.setPercentColor(mon, (1 - c) * 0.5, 0xFFAFAF);
		}
		
		// DALLES
		dList = new Array();
		max = Std.int(16-Math.min(dif,1)*9);
		ec = ( Cs.omcw - ( 2*MARGIN + SMARGIN*(max-1) ) )/max;
		for(  i in 0...max ){
			var p = newPhys("McCollineDalle");
			p.x = MARGIN + (ec+SMARGIN)*i;
			p.y = GL;
			p.updatePos();
			var mc:McCollineDalle = cast(p.root);
			mc.d.scaleX = ec*0.01;
			dList.push(p);
		}

		// BALL
		ball = newPhys("mcCollineBall");
		ball.x = Cs.omcw*0.5;
		ball.y = 30;
		ball.updatePos();
		ball.weight= 1;

	}

	override function update(){
		super.update();
		moveBall();
		
		for( m in mons )  m.update();

	}

	function moveBall(){

		
		var dx = getMousePos().x - ball.x;

		// REBOND
		if( !flFall && ball.y > GL-BRAY ){
			var index = Std.int( (ball.x-MARGIN) / (ec+SMARGIN) );
			var p = dList[index];

			// CHERCHE LES BORDS
			if(p==null){
				for( i in 0...2 ){
					var sens = i*2-1;
					index = Std.int( (ball.x+(BRAY*sens)-MARGIN) / (ec+SMARGIN) );
					var cp = dList[index];
					if( cp != null ){
						p = cp;
						break;
					}
				}
			}

			if( p != null ){
				p.weight = 1;
				p.timer = 10;
				p.fadeType = 3;
				dList[index] = null;
				//p.root.alpha = 0.5;

				// REBOND;
				ball.y = GL-BRAY;
				ball.vx += dx*0.04;
				ball.vy = -20;
			}else{
				flFall = true;
				timeProof = true;
			}
		}

		// DEATH
		if( ball.y > Cs.omch+20 ){
			timeProof = false;
			setWin(false);
		}

		// FOLLOW
		var lim = 0.15;
		ball.vx += Num.mm(-lim,dx*0.05,lim);

		// MUR
		if( ball.x < MARGIN+BRAY || ball.x > Cs.omcw-(MARGIN+BRAY) ){
			ball.x = Num.mm( MARGIN+BRAY, ball.x, Cs.omcw-(MARGIN+BRAY) );
			ball.vx *= -1;
		}

		// ROLL
		ball.root.rotation += ball.vx*4;

		// UPDATE
		ball.root.x = ball.x;
		ball.root.y = ball.y;
	}

	override function outOfTime(){
		setWin(true);
	}




//{
}

