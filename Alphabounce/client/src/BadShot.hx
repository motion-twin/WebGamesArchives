import mt.bumdum.Lib;
import mt.bumdum.Phys;

class BadShot extends Phys{//}

	public var height:Float;

	var type:Int;
	var yLim:Float;
	var impact:Float;
	var ray:Float;
	var flUp:Bool;
	var queue:String;

	public var bl:Block;

	public function new(mc){
		super(mc);

		flUp = true;
		ray = 2;

		yLim = Cs.mch+10;
		height = 0;

	}

	override public function update(){
		var ox = x;
		var oy = y;
		super.update();

		if( flUp && y+ray > Game.me.pad.y ){
			impact = x;
			flUp = false;
		}

		if(impact!=null){
			if( Math.abs(Game.me.pad.x-impact)< Game.me.pad.ray+ray ){
				hit();
			}
			if( y-Game.me.pad.y > ray+height ){
				impact = null;
			}

		}

		if( queue != null ){
			var mc = Game.me.dm.attach(queue,Game.DP_PAD);
			mc._x = ox;
			mc._y = oy;
			var dx = x-ox;
			var dy = y-oy;
			mc._rotation = Math.atan2(dy,dx)/0.0174;
			mc._xscale = Math.sqrt(dx*dx+dy*dy);
		}



		switch(type){
			case 2:
				if(sleep==null && vy==0 ){
					root.stop();
					directShot(bl,8);
				}
		}

		if( y> yLim+height )kill();

	}


	// API
	public function setType(n){
		type = n;
		root.gotoAndStop(n+1);
		switch(type){
			case 0:
				queue = "mcQueueReduc";
			case 1:
				queue = "mcQueueNut";
			case 4:
				queue = "mcQueueDrone";
		}

	}
	public function directShot(bl,?speed:Float,?prec:Float){
		if(speed==null)speed = 6;
		if(prec==null)prec = 0;
		x = Cs.getX(bl.x+0.5);
		y = Cs.getY(bl.y+0.5);

		var dx = Game.me.pad.x-x;
		var dy = Game.me.pad.y-y;
		var a = Math.atan2(dy,dx) + (Math.random()*2-1)*prec;

		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
	}
	public function frontShot(bl,?speed){
		if(speed==null)speed = 6;
		x = Cs.getX(bl.x+0.5);
		y = Cs.getY(bl.y+0.5);
		vy = speed;
	}


	//
	function hit(){
		switch(type){
			case 0:
				Game.me.pad.setRay(Math.max(Game.me.pad.ray-8,Pad.SIDE+1));
				Game.me.pad.setFlash(10);
			case 1:	Game.me.killPad();
			case 2:	Game.me.killPad();
			case 4:	Game.me.killPad();
			case 3:
				Game.me.pad.glueCount++;
				Game.me.pad.moveFactor *= 0.5;
				var max = 16;
				var cr = 4;
				for( n in 0...max ){
					var p = new Phys(Game.me.dm.attach("mcGlue",Game.DP_PARTS));
					var a = Math.random()*6.28;
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var sp = 0.1+Math.random()*5;
					p.x = x + ca*cr*sp;
					p.y = y + sa*cr*sp;
					p.vx = ca*sp;
					p.vy = -Math.abs(sa)*sp*0.5;
					p.fadeType = 0;
					p.weight = 0.05+Math.random()*0.15;
					p.timer = 10+Math.random()*10;
					p.setScale(10+Math.random()*20);
				}
				Filt.glow( Game.me.pad.root,6,2,0xFFFF00 );


		}

		kill();
	}




//{
}













