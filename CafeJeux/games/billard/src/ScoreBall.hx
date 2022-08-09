import mt.bumdum.Lib;
import mt.bumdum.Phys;



class ScoreBall extends Phys{//}


	static var ACC = 1;
	static var FRICT = 0.95;

	public var angle:Float;
	public var color:Int;
	var ca:Float;
	var turn:Float;
	var speed:Float;
	public var trg:flash.MovieClip;

	var decal:Float;
	var speedDecal:Float;
	var ecart:Float;




	public function new(mc) {
		super(mc);

		angle = Math.random()*6.28;
		ca = 0.1;
		turn = 0.1;
		speed = 0;
		frict = 0.94;

		decal = Math.random()*6.28;
		//speedDecal = 10+Math.random()*10;
		//acart = 10+Math.random()*10;

	}

	public function update() {

		var ox = x;
		var oy = y;

		// ONDULE
		decal = (decal+64)%628;
		angle += Math.cos(decal*0.01)*0.15;

		// FOLLOW
		var dx = trg._x - x;
		var dy = trg._y - y;
		var da = Num.hMod( Math.atan2(dy,dx)-angle, 3.14 ) ;
		angle += Num.mm(-turn,da*ca,turn);
		x += Math.cos(angle)*speed;
		y += Math.sin(angle)*speed;
		speed += ACC;
		speed *= FRICT;
		ca = Math.min(ca+0.01,1);
		turn = Math.min(turn+0.01,1);





		// UPDATE
		super.update();

		/*
		var dx = trg._x - x;
		var dy = trg._y - y;
		var dist = Math.sqrt(dx*dx+dy*dy);
		var lim = 80;
		if(dist<lim){
			var c = 1-dist/lim;
			x += c*dx;
			y += c*dy;
		}
		*/

		// QUEUE
		if(root._visible){
			var dx = x-ox;
			var dy = y-oy;
			var mc = Game.me.dm.attach("mcQueue",Game.DP_PARTS);
			mc._x = ox;
			mc._y = oy;
			mc._rotation = Math.atan2(dy,dx)/0.0174;
			mc._xscale = Math.sqrt(dx*dx+dy*dy);
			Filt.glow(mc,10,2,color);
			mc.blendMode = "add";
		}
		// TWINKLE
		var max = 1;
		for( n in 0...max ){
			var p = newPart();
			p.x = x +(Math.random()*2-1)*14;
			p.y = y +(Math.random()*2-1)*14;
		}

		// CHECK DEATH
		var dx = trg._x - x;
		var dy = trg._y - y;
		if( Math.sqrt(dx*dx+dy*dy)< 12 ){
			var mc = Game.me.dm.attach("mcScoreBang",Game.DP_PARTS);
			mc._x = trg._x;
			mc._y = trg._y;
			x += (trg._x-x)*0.5;
			y += (trg._y-y)*0.5;
			trg._visible = true;
			var max = 10;
			var cr = 1;
			for( n in 0...max){
				var a = (n+Math.random())/max * 6.28;
				var ca = Math.cos(a);
				var sa = Math.sin(a);
				var sp = Math.random()*6;
				var p = new Phys(Game.me.dm.attach("partLight",Game.DP_PARTS));
				p.x = trg._x+ca*sp*cr;
				p.y = trg._y+sa*sp*cr;
				p.vx = ca*sp;
				p.vy = sa*sp;
				p.frict = 0.7;
				p.setScale(50+Math.random()*75);
				p.timer = 10+Math.random()*10;
				p.fadeType = 0;
				p.root.blendMode = "add";
				p.root.gotoAndPlay(Std.random(2)+1);
				p.root._alpha = 50;

			}
			kill();

		}



	}

	function newPart(){
		var p = new Phys(Game.me.dm.attach("partTwinkle",Game.DP_PARTS));
		p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
		p.timer = 10+Math.random()*25;
		p.setScale(50+Math.random()*100);
		p.fadeType = 0;
		return p;
	}








//{
}