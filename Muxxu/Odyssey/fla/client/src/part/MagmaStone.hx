package part;
import Protocole;
import mt.bumdum9.Lib;



class MagmaStone extends Stone{//}
	
	var burn:Int;
	var sock:mt.fx.Sock;
	
	public function new() {

		super();
		var e = new mt.fx.Flash(root, 0.01);
		e.curveIn(4);
		
		burn = 0;
		
		
		//var sock = new mt.fx.Sock(this, 8, 2, 0.2);
		sock = new mt.fx.Sock(this, 4, 3, 0.15);
		sock.rndCoef = 0.15;
		sock.frict = 0.9;
		sock.setGrav( -0.02);
		Scene.me.dm.add( sock.canvas, Scene.DP_BG );

	}

	// UPDATE
	override function update() {
		super.update();

		sock.ray = (root.width + root.height) * 0.25;
		
		if ( sock.timer > 50 )
			sock.fadeOut(0.02);
		
		
			
		// SMOKE
		var lim = 36;		
		if ( burn++ < lim ) {
			
			var p = new Cloud();
			p.setPos(x, y);
		
			p.vx += ( Math.random() * 2 - 1) * 0.8;
			p.vy += ( Math.random() * 2 - 1) * 0.8;

			var sc = 0.5 - burn * 0.01;			
			p.setScale( sc);
			
			new mt.fx.Spawn(p.root, 0.15,false,true);
			
		}
		
		
		// SPARK
		if( Std.random(sock.timer) < 5 ){
			var p = new mt.fx.Spinner(new FxSpark(),10+Std.random(50));
			var a = Math.atan2(vy, vx);
			var speed = Math.sqrt(vy*vy+vx+vx)*0.5;
			p.launch(a, speed, 0.5+Math.random()*4);
			p.setPos(x, y);
			p.frict = 0.99;
			p.timer = 20 + Std.random(80);
			Scene.me.dm.add(p.root, Scene.DP_FX);
		}
		
		
		
	}


	
	
//{
}