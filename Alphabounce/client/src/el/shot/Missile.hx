package el.shot;
import mt.bumdum.Lib;
import mt.bumdum.Phys;

class Missile extends el.Shot{//}

	public var splash:Int;



	public function new(mc){
		super(mc);
		damage = 2;
		frict = 0.98;

	}

	public function setType(n){
		root.gotoAndStop(n+1);
		switch(n){
			case 1:
				splash = 1;

			case 2:
				splash = 1;
				damage = 100;

			case 3:
				splash = 2;
				damage = 100;

		}
	}

	override public function update(){
		super.update();

		vy -= 1*mt.Timer.tmod;

		var p = new Phys(Game.me.dm.attach("mcSmoke",Game.DP_PARTS2));
		p.x = x;
		p.y = y+8;
		p.vy = -Math.random();
		p.frict = 0.92;
		p.timer = 14+Math.random()*4;
		p.root._rotation = Math.random()*360;
		p.vr = (Math.random()*2-1)*5;
		p.setScale(100+Std.random(40));
		Filt.blur(p.root,8,8);


	}

	override function onBounce(px,py){


		if(splash!=null){
			var max = splash*2+1;
			for(dx in 0...max){
				for(dy in 0...max){
					var x = px+dx-splash;
					var y = py+dy-splash;
					Game.me.hit(x,y,cast this);
					Game.me.killZone(x,y);
				}
			}
		}else{

			Game.me.hit(px,py,cast this);
		}

		//
		hit();

		//
		super.onBounce(px,py);

	}





//{
}













