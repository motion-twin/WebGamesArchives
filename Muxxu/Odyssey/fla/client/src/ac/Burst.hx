package ac;
import Protocole;
import mt.bumdum9.Lib;



class Burst extends Action {//}
	

	
	var work:Array<Ball>;
	var extra:Array<BallType>;
	//public var blast:Array<Ball>;
	
	var board:Board;

	public function new(b,a,gen) {
		super();
		board = b;
		work = a;
		spc = 0.15;
		extra = gen;
		
		// BLAST
		/*
		blast = [];
		for ( b in board.balls ) b.flag = 0;
		for ( b in work ) b.flag = 1;
		for ( b in work ) {
			for ( nei in b.nei ) {
				if ( nei.flag == 1 ) continue;
				nei.flag = 1;
				blast.push(nei);
			}
		}
		*/
		
	}

	override function init() {
		super.init();
		for ( b in work ) board.dm.over(b);
	}
	
	
	// UPDATE
	override function update() {
		super.update();
		
		switch(step) {
			
			case 0 :
				var c = coef;
				for ( b in work ) {
					//*
					Col.setColor(b, 0, Std.int(coef * 255));
					b.filters = [];
					Filt.glow(b, c * 8, c * 2, 0xFFFFFF);
					Filt.glow(b, c * 32, c * 1 , 0xFFFFFF);
					b.blendMode = flash.display.BlendMode.ADD;
					
					// FX
					if ( coef == 1 ) {
						var ec = 6;
						for ( i in 0...4 ) {
							var p = Game.me.getPart( new FxFluo() );
							var pos = b.getGlobalPos(Math.random(),Math.random());
							p.setPos(pos.x, pos.y);
							Col.setColor(p.root, 0, -255);
							p.weight = -Math.random() * 0.1;
							p.fadeLimit = 10 + Std.random(20);
							p.timer = p.fadeLimit;
							p.fadeType = 2;
							p.setScale(1+i*0.5 + Math.random() * 3);
						}
					}
					
				}

				if ( coef == 1 ) {

					// FX
					for ( b in work ) {
						for( i in 0...2 ){
							var p = new mt.fx.Spinner(new FxFluo(),Math.random()*12);
							Game.me.dm.add(p.root, Game.DP_FX);
							//Col.setColor(p.root, 0, -255);
							p.twist(24,0.98);
							p.weight = -(0.1+Math.random() * 0.25);
							p.mc.scaleX = p.mc.scaleY = 0.4;
							p.fadeLimit = 10 + Std.random(10);
							p.timer = p.fadeLimit;
							p.fadeType = 2;
							var pos = b.getGlobalPos(Math.random(),Math.random());
							//p.launch( -1.57,4,0.25);
							p.setPos(pos.x, pos.y);
						}
					}
					
					
					
					// COMBINE
					var explo = [];
					for ( b in work ) {
						Col.setColor(b, 0, 0);
						b.filters = Ball.FILTERS;
						if ( b.combine() ) {
							// DESTRUCTION HERE
							new part.Breath(b.board, b.px, b.py);
							explo.push(b);
							
						}
					}
					
					// BLAST
					var blast = [];
					for ( b in board.balls ) b.flag = 0;
					for ( b in work ) b.flag = 1;
					for ( b in explo ) {
						for ( nei in b.nei ) {
							if ( nei.flag == 1 ) continue;
							nei.flag = 1;
							blast.push(nei);
						}
					}
					for ( b in blast ) b.blast();
					
					
					// GENERATE
					if ( extra.length > 0 )
						generate();
					else
						kill();
					
				}
				
			case 1 :

				if ( coef == 1 ) kill();
			
				
		
		}
		
		
	}

	function generate() {
		work.sort( orderWork );
		var id = 0;
		while ( id < work.length && id < extra.length ) {
			var pos = work[id];
			var type = extra[id];
			var ball = board.addBall(type, pos.px, pos.py);
			board.killBreathAt(pos.px, pos.py);
			ball.fxSpawn();
			id++;
		}
		nextStep();
		
	}
	
	function orderWork(a:Ball, b:Ball) {
		if ( a.y * 100 + a.x > b.y * 100 + b.x ) return -1;
		return 1;
	}
	
	
	
	
//{
}