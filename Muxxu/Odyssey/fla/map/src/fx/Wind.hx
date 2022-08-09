package fx;
import mt.bumdum9.Lib;


private typedef WPart = { pos:Array<{x:Float,y:Float, dx:Float, dy:Float}>, fadeIn:Int, timer:Int, an:Float, sp:Float, va:Float, frict:Float };

class Wind extends mt.fx.Fx{//}

	static var LENGTH = 20;
	
	var layer:SP;
	var angle:Float;
	var parts:Array<WPart>;
	
	public function new() {
		super();
		angle = (Main.DATA.infos.wind + 4) * Math.PI / 4;
		parts = [];
		layer = new SP();
		Map.me.fxTop.addChild(layer);
		
		//Filt.blur(layer, 4, 4);
		layer.blendMode = flash.display.BlendMode.OVERLAY;
		
	}
	
	override function update() {
		super.update();
		
		layer.graphics.clear();
		
		if ( Std.random(16) == 0 ) {
			var pos =  getRandomPos();
			var max = 1 + Std.random(3);
			for ( i in 0...max ) {
				var p = newPart(pos.x, pos.y);
				p.pos[0].x += (Math.random() * 2 - 1) * 8;
				p.pos[0].y += (Math.random() * 2 - 1) * 8;
				p.sp *= 0.8 + i * 0.2;
			}
		}
		
		var a = parts.copy();
		for ( p in a ) {
			var pos = p.pos[0];
			p.va += (Math.random()*2-1) * 0.05;
			p.va *= p.frict;
			
			p.an += p.va;
			
			
			
			var da = Num.hMod(p.an - angle, 3.14);
			var fr = 1 - Math.abs(da) / 3.14;
			var sp = p.sp * (0.1 + 0.9 * fr);
			
			var dx = Math.cos(p.an) * sp;
			var dy = Math.sin(p.an) * sp;
			p.pos.unshift({x:pos.x+dx,y:pos.y+dy,dx:Math.cos(p.an+1.57),dy:Math.sin(p.an+1.57)});
			if ( p.pos.length > LENGTH ) p.pos.pop();
			
			
			// ALPHA & SIZE
			var sizeMax = sp * 0.5;
			var alpha = 1.0;
			p.timer--;
			var lim = 20;
			if ( p.timer < lim ) {
				//alpha = p.timer * 0.1;
				sizeMax *= p.timer /lim;
			}
			if ( p.fadeIn > 0 ) {
				p.fadeIn--;
				alpha = 1 - p.fadeIn / 20;
			}
			
			// DEATH
			if ( p.timer == 0 ) {
				parts.remove(p);
			}
			
			// DRAW
			var a = [];
			var id = 0;
			var rect = new flash.geom.Rectangle();
			

			for ( p in p.pos ) {
				var cc = id / LENGTH;
				var ray = Math.sin(cc * 3.14) * sizeMax;
				
				var ddx = p.dx * ray;
				var ddy = p.dy * ray;
				
				a.push( 	{ x:p.x+ddx, y:p.y+ddy } );
				a.unshift( 	{ x:p.x-ddx, y:p.y-ddy } );
				
				//a.push( 	{ x:p.x+ddx*2, y:p.y+ddy*2 } );
				//a.unshift( 	{ x:p.x, y:p.y } );
				
				//a.push( 	{ x:p.x+ddx*2, y:p.y+ddy*2 } );
				//a.unshift( 	{ x:p.x+ddx*0.25, y:p.y+ddy*0.25  } );
				
				//a.push( 	{ x:p.x+ray*2, y:p.y+ray*2 } );
				//a.unshift( 	{ x:p.x, y:p.y  } );
				
				if ( p.x < rect.left || id==0 ) 	rect.left = p.x;
				if ( p.x > rect.right || id==0  ) 	rect.right = p.x;
				if ( p.y < rect.top || id==0  ) 	rect.top = p.y;
				if ( p.y > rect.bottom || id==0  )	rect.bottom = p.y;
				id++;
			}
			
			var start = a.shift();
			//layer.graphics.beginFill(0xFF0000);
			var box = new flash.geom.Matrix();
			//trace(rect.width + "," + rect.height);
			box.createGradientBox(rect.width,rect.height, p.an+3.14, rect.x, rect.y );
			
			layer.graphics.beginGradientFill( flash.display.GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [alpha,0], [127,255], box );
			layer.graphics.moveTo(start.x, start.y);
			for ( p in a ) {
				layer.graphics.lineTo(p.x, p.y);
			}
			layer.graphics.endFill();
			
			
			/*
			layer.graphics.beginFill(0xFF0000, 0.2);
			layer.graphics.drawRect(rect.x,rect.y,rect.width,rect.height);
			layer.graphics.endFill();
			*/
			
			//lalyer.grap
			
			/*
			var id = 0;
			for ( p in p.pos ) {
				
				if ( id==0 ) {
					layer.graphics.moveTo(p.x, p.y);
				}else {
					var cc = id / LENGTH;
					layer.graphics.lineStyle(1, 0xFFFFFF, (1-cc)*alpha);
					layer.graphics.lineTo(p.x, p.y);
					//var size = Math.sin(cc*3.14)*5;
					//layer.graphics.lineStyle(size, 0xFFFFFF, (1-cc)*alpha, false, flash.display.LineScaleMode.NORMAL, flash.display.CapsStyle.NONE );
					//layer.graphics.lineStyle(size, 0xFFFFFF);				}
				id++;
			}
			*/
			

		}
		
		
	}
	
	function newPart(x,y) {
		var p:WPart = {
			pos:[ {x:x,y:y,dx:0.0,dy:0.0}],
			timer:50+Std.random(20),
			an:angle,
			fadeIn:20,
			frict:0.9,
			sp:4.0+Math.random()*4,
			va:0.0,
		}
		if ( Std.random(10) == 0 ) p.frict = 0.99;
		parts.push(p);
		return p;
	}
	
	function getRandomPos() {
		
		var dist = 100;
		var dx = Math.cos(angle) * dist;
		var dy = Math.sin(angle) * dist;
		
		return {
			x:Map.me.boat.mc.x+(Math.random()-0.5)*Main.WIDTH-dx,
			y:Map.me.boat.mc.y+(Math.random()-0.5)*Main.HEIGHT-dy,
		}
	}
	
	

	//{
}