package fx;
import mt.bumdum9.Lib;
using mt.bumdum9.MBut;
import Protocol;

enum MoveFx{
	MFX_MAGNET_LINK(b:ent.Ball);
	MFX_NONE;
}

class MoveBall extends mt.fx.Sequence {
	
	var fxt:MoveFx;
	var ball:ent.Ball;
	var path:Array<Square>;
	var fxLayer:SP;
	var oldPos:{ x:Float, y:Float };

	public function new(ball, path:Array<Square>, ?fxt:MoveFx) {
		super();
		if( fxt == null ) fxt = MFX_NONE;
		this.path = path;
		this.ball = ball;
		this.fxt = fxt;
		
		spc = 0.3 / path.length;
		curveInOut();
		ball.freeSquare();
		
		fxLayer = new SP();
		Game.me.dm.add(fxLayer, Game.DP_FX);
		switch(fxt) {
			case MFX_MAGNET_LINK(b) :
				fxLayer.blendMode = flash.display.BlendMode.ADD;
				Filt.glow(fxLayer, 8, 2, 0xFFFF00);
			default :
		}
		
		oldPos = { x:ball.x, y:ball.y };
	}
	
	override function update() {
		super.update();
		
		var pos = (1-curve(coef)) * (path.length-1);
		var from = path[Math.floor(pos)];
		var to = path[Math.ceil(pos)];
		var p = from.getCenter();
		ball.x = p.x;
		ball.y = p.y;
		
		var c = (pos - Math.floor(pos));
		var start = Game.me.getPos(from.x,from.y);
		var end = Game.me.getPos(to.x,to.y);
		ball.x += (end.x - start.x) * c;
		ball.y += (end.y - start.y) * c;
		ball.updatePos();
		
		switch(fxt) {
			case MFX_MAGNET_LINK(b) :
				var dx = b.x - ball.x;
				var dy = b.y - ball.y;
				var dist = Math.sqrt(dx*dx+dy*dy);
				var max = Std.int(dist / 20);
				var shake = 16;
				fxLayer.graphics.clear();
				
				for( k in 0...3 ){
					fxLayer.graphics.lineStyle(1+k, 0xFFFFFF, 1, false, flash.display.LineScaleMode.NORMAL, flash.display.CapsStyle.SQUARE, flash.display.JointStyle.MITER);
					fxLayer.graphics.moveTo(ball.x, ball.y);
					for( i in 0...max+1 ) {
						var c = i / max;
						var x = ball.x + dx * c + (Math.random() * 2 - 1) * shake;
						var y = ball.y + dy * c + (Math.random() * 2 - 1) * shake;
						if( i == 0 )	fxLayer.graphics.moveTo(x,y);
						else 			fxLayer.graphics.lineTo(x,y);
					}
				}
				//fxLayer.graphics.endFill();
			case MFX_NONE :
				
		}
		// SPARKS
		var p = new mt.fx.Part(new gfx.Spark());
		p.root.gotoAndPlay(Std.random(p.root.totalFrames));
		var a = Math.random() * 6.28;
		var ray = Math.pow(Math.random(), 0.5) * (Cs.SQ >> 1);
		p.setPos(ball.x + Math.cos(a) * ray, ball.y + Math.sin(a) * ray);
		p.timer = 15 + Std.random(15);
		p.fadeType = 1;
		Game.me.dm.add(p.root, Game.DP_FX);
		var dx = ball.x - oldPos.x;
		var dy = ball.y - oldPos.y;
		p.vx = dx * 0.1;
		p.vy = dy * 0.1;
		// OLD POS
		oldPos = { x:ball.x, y:ball.y };
		//
		if( from.kdo != null ) {
			from.kdo.trig();
		}
		//
		if( coef == 1 ) {
			ball.setSquare(from);
			from.trig();
			kill();
		}
	}
	
	override function kill() {
		super.kill();
		fxLayer.parent.removeChild(fxLayer);
	}
}
