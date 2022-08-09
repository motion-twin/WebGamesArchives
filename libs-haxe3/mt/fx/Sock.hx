package mt.fx;
import flash.display.Sprite;

private typedef SPos = { x:Float, y:Float, vx:Float, vy:Float, ray:Float, mom:Float };

class Sock extends Fx 
{
	public var trg:{ x:Float, y:Float, vx:Float, vy:Float };
	public var canvas:Sprite;
	
	public var ray:Float;
	public var interval:Int;
	public var fadeSpeed:Float;
	public var color:Int;
	public var drawMode:Int;
	
	public var frict:Float;
	public var dirCoef:Float;
	public var rndCoef:Float;
	
	var pos:Array<SPos>;
	public var timer:Int;
	
	var fadeOutCoef:Null<Float>;
	var fadeOutSpeed:Float;
	
	// DIF ANGLE
	var difAngle:Float;
	public var rndIncAngle:Float;
	
	public var getFrontColor:Int->Int;
	public var getBackColor:Int->Int;
	
	public var autoDiv:Null<Float>;						// Divise automatiquement si la ligne est trop longue
	public var forces:Array<{vx:Float,vy:Float}>;		// applique des forces supplémentaires au points. ( gravité etc )
	
	
	public function new(trg, ray = 10.0, interval = 2, fadeSpeed = 0.2, color = 0 ) {
		super();
		this.trg = trg;
		canvas = new flash.display.Sprite();
		
		this.ray = ray;
		this.interval = interval;
		this.fadeSpeed = fadeSpeed;
		this.color = color;
	
		frict = 0.96;
		fadeOutSpeed = 0.1;
		
		dirCoef = 0.0;
		rndCoef = 0.0;
		pos = [];
		forces = [];
		timer = 0;
		drawMode = 0;
		
		difAngle = 0;
		rndIncAngle = 3.14;
		
	}
	
		
	override function update() {
		
	
		
		super.update();
		timer++;

		
		// MAJ POS
		for ( p in pos.copy() ) {
			p.ray -= fadeSpeed;
			p.x += p.vx;
			p.y += p.vy;
			for ( f in forces ) {
				p.vx += f.vx*p.mom;
				p.vy += f.vy*p.mom;
			}
			p.vx *= frict;
			p.vy *= frict;
			if ( p.ray <= 0 )
				pos.remove(p);
				
				
				
		}
		
		
		// DRAW
		var g = canvas.graphics;
		g.clear();
		//g.lineStyle(2, 0xFFFFFF);
		var a = pos.copy();
		a.push({x:trg.x,y:trg.y,vx:0.0,vy:0.0,ray:ray,mom:0.0});
		g.moveTo(a[0].x, a[0].y);
		
		var angle = 0.0;
		var line = [];
		for ( i in 0...a.length ) {
			var p = a[i];
			var next = a[i + 1];
			if ( next != null ) {
				var dx = next.x - p.x;
				var dy = next.y - p.y;
				angle = Math.atan2(dy, dx);
			}
			var ray = p.ray;
			if ( fadeOutCoef != null ) ray *= (1-fadeOutCoef);
			
			var a = angle + 1.57;
			var ex = Math.cos(a)*ray;
			var ey = Math.sin(a)*ray;
			
			line.push( { x:p.x + ex, y:p.y + ey } );
			line.unshift( { x:p.x - ex, y:p.y - ey } );
			
			//g.lineTo(p.x,p.y);
			
		}
		
		switch(drawMode) {
			case 0 :
				g.beginFill(0);
				g.moveTo(line[0].x, line[0].y);
				for ( p in line )
					g.lineTo(p.x, p.y);
			
				g.endFill();
				
			case 1 :
				var id = 0;
				while (line.length >= 4) {
					//g.beginFill(Std.random(0xFFFFFF));
					var col = color;
					if ( getFrontColor != null ) col = getFrontColor(id);
					g.beginFill(col);
					var a = line.pop();
					var b = line.shift();
					var c = line[0];
					var d = line[line.length-1];
					
					g.moveTo(a.x, a.y);
					g.lineTo(b.x, b.y);
					g.lineTo(c.x, c.y);
					g.lineTo(d.x, d.y);
					id++;
				}
				
			
		}

		
		
		
		// NEW POS
		if ( timer%interval==0 ) {
	
			//var speed = Math.sqrt(trg.vx * trg.vx + trg.vy * trg.vy);
			var speed = 1;

			difAngle += (Math.random() * 2 - 1) * rndIncAngle;
			var vx = trg.vx * dirCoef + Math.cos(difAngle) * speed * rndCoef;
			var vy = trg.vy * dirCoef + Math.sin(difAngle) * speed * rndCoef;
			pos.push( {x:trg.x,y:trg.y,vx:vx,vy:vy, ray:ray,mom:0.5+Math.random()}  );
		}
		
		// AUTO DIV
		if ( autoDiv != null )
			autoDivLine();
		
		
		// FADE OUT
		if ( fadeOutCoef != null ) {
			fadeOutCoef = Math.min(fadeOutCoef + fadeOutSpeed, 1);
			if ( fadeOutCoef == 1 )
				kill();
		}
		
		
		
		
	}
	
	function autoDivLine() {
		var a = pos.copy();
		var k = 1;
		for ( i in 0...a.length ){
			var p = a[i];
			var next = a[i + 1];
			if ( next == null ) continue;
			var dx = p.x - next.x;
			var dy = p.y - next.y;
			var lim = 100;
			if ( Math.sqrt(dx * dx + dy * dy ) < lim ) continue;
			
			var speed = Math.sqrt(p.vx * p.vx + p.vy * p.vy) + Math.sqrt(next.vx * next.vx + next.vy * next.vy);
			var a = Math.atan2(p.vy, p.vx);
			var b = Math.atan2(p.vy, p.vx);
			var da = mt.MLib.wrapToPi(a - b);// Num.hMod(a - b, 3.14);
			var an = a + da * 0.5;
			
			var p = {
				x : (p.x + next.x) * 0.5,
				y : (p.y + next.y) * 0.5,
				//vx : (p.vx + next.vx) * 0.5,
				//vy : (p.vy + next.vy) * 0.5,
				vx:Math.cos(an) * speed*0.5,
				vy:Math.sin(an) * speed*0.5,
				ray: (p.ray + next.ray) * 0.5,
				mom: (p.mom + next.mom) * 0.5,
			}
			pos.insert(i+k++, p);
			
		}
	}
	
	public function fadeOut(c) {
		if ( fadeOutCoef != null ) return;
		fadeOutCoef = 0;
		fadeOutSpeed = c;
	}
	
	public function setGrav(n) {
		forces.push({vx:0.0,vy:n});
	}
	
	override function kill() {
		super.kill();
		canvas.graphics.clear();
		if ( canvas.parent != null )
			canvas.parent.removeChild(canvas);
	}
	
//{
}