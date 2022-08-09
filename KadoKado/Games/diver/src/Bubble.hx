import Game;
import mt.bumdum9.Lib;
class Bubble
{//}
	public var mc			: MC;
	public var diam			: Float;
	public var dx			: Float;
	public var dy			: Float;
	public var rebond		: Int;
	public var size 		: Size;
	public var d			: Float;
	var inc					: Float;
	public var range		: Float;
	public var x			: Float;
	public var pacmanable	: Bool;
	
	public function new( size : Size){
		mc = new McBubble();
		mc.stop();
		pacmanable = false;
		Game.me.bub.push(this);
		Filt.glow(mc, 4, 1, 0xFFFFFF);
		mc.blendMode = flash.display.BlendMode.ADD;
		Game.me.dm.add(mc,5);
		this.size = size;
		setSize();
		this.d = 0;
		this.range = Math.random() * 15 + Game.me.level*2;
		setInc();
		setSpeed(Game.me.level);
	}
	
	public function setSpeed(level : Int) {
		this.dx	= 1.0;
		var r = Math.random();
		this.dy	= - ((Math.random() * Game.me.level + 1.0 +r))*0.7;
		return true;
	}
	
	private function setSize() {
		switch(this.size) {
			case LITTLE :
				diam = 10.0;
				rebond = 2;
			case MEDIUM :
				diam = 30.0;
				rebond = 4;
			case BIG 	:
				diam = 60.0;
				rebond = 8;
		}
		mc.scaleX = mc.scaleY = diam / 100;
	
	}
	
	public function incre() {
		d += inc;
	}
	
	private function setInc() {
		if (range < 15 ) {
			inc = Math.random()*0.3;
		}
		else{
			inc = Math.random() / 10 + 0.05;
		}
		
	}

	public function burst() {
		
		// ONDE
		var mcp = new FxOnde();
		Game.me.dm.add(mcp, 5);
		var p = new mt.bumdum9.Phys(mcp);
		p.x = mc.x;
		p.y = mc.y;
		p.root.scaleX = mc.scaleX;
		p.root.scaleY = mc.scaleY;
		p.timer = 10;
		p.fadeType = 10;
		
		// PARTS
		var max = Std.int(diam * Math.PI * 0.1);
		for( i in 0...max ) {
			var a = i / max * 6.28;
			var ray = diam * 0.5;
			var mcp = new McPart();
			Game.me.dm.add(mcp, 5);
			var p = new mt.bumdum9.Phys(mcp);
			p.vx = Math.cos(a);
			p.vy = Math.sin(a);
			p.x = mc.x +  p.vx*ray;
			p.y = mc.y +  p.vy*ray;
			p.frict = 0.95;
			p.timer = 20;
			p.updatePos();
			Filt.glow(mcp, 4, 1);
			mcp.blendMode = flash.display.BlendMode.ADD;
		
		}
		
		//
		kill();
	}
	
	public function kill() {
		mc.parent.removeChild(mc);
		Game.me.bub.remove(this);
	}
	
//{
}