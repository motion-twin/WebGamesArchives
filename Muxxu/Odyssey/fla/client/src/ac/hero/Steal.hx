package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class Steal extends Action {//}
	
	
	var agg:Hero;
	var vic:Monster;
	var elements:Array<BallType>;
	var balls:Array<part.Ball>;

	
	public function new(agg,vic,max) {
		super();
		this.agg = agg;
		this.vic = vic;
		
		var a = vic.data.balls;
		
		this.elements = [];
		for ( i in 0...max ) elements.push(a[Std.random(a.length)]);

		
	}
	override function init() {
		super.init();
		balls = [];
		
		var freePos = agg.board.getFreePos();
		
		for ( type in elements ) {
			if ( freePos.length == 0 ) break;
			var pos = freePos.shift();
			var p = new part.Ball(type);
			p.initFolkPos( vic.folk);
			p.gotoBoard( agg.board, pos.x, pos.y);
			p.asp = 3 + Math.random()*10;
			p.an = (Math.random() * 2 - 1) * 0.5;
			
		}
		
	}
	
	override function update() {
		super.update();
		
		if ( part.Ball.WAIT == 0 ) kill();
		
		
	}
	
	

	
	//
	


	
	
//{
}