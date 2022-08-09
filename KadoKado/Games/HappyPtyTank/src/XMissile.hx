@:bind
class FlyPaper extends flash.display.MovieClip {
	public var vect : { x:Float, y:Float };
	public var speed : Float;
	public var rotationSpeed : Float;
	public var fadeTime : Float;

	public function new(){
		super();
		fadeTime = FlyPaperAnim.FADE_TIME;
		rotationSpeed = 0.0;
	}
}

@:bind
class FlyPaperAnim extends flash.display.Sprite, implements Anim {
	public static var ST_BOOM = 1;
	public static var ST_FADE = 2;
	public static var FADE_TIME = 300;

	var papers : List<FlyPaper>;
	var center : flash.geom.Point;
	public var state : Int;
	var start : Float;
	var time : Float;

	public function new(c:flash.geom.Point){
		super();
		state = ST_BOOM;
		center = c;
		time = 0.0;
		var n = 20 + Std.random(10);
		if (Game.instance.slowLevel == 3)
			n = Math.ceil(n / 4);
		else if (Game.instance.slowLevel == 2)
			n = Math.ceil(n / 3);
		else if (Game.instance.slowLevel == 1)
			n = Math.ceil(n / 2);
		var aPerPaper = Math.PI * 2 / n;
		var angle = 0.0;
		papers = new List();
		var sr = 60/mt.Timer.wantedFPS;
		for (i in 0...n){
			var p = new FlyPaper();
			p.gotoAndStop(Std.random(p.totalFrames)+1);
			p.x = center.x;
			p.y = center.y;
			p.scaleX = 0.3;
			p.scaleY = 0.3;
			p.vect = Geom.radToVector(angle);
			p.speed = (1 + 2 - Math.random() * 1) * sr;
			papers.push(p);
			addChild(p);
			angle += aPerPaper;
			p.rotationSpeed = (2.5 - Math.random() * 5) * sr;
		}
		angle = 0.0;
		var ft = FADE_TIME;
		var n = 15 + Std.random(15);
		if (Game.instance.slowLevel == 3){
			ft = Math.round(ft / 4);
			n = Math.ceil(n / 4);
		}
		else if (Game.instance.slowLevel == 2){
			ft = Math.round(ft / 3);
			n = Math.ceil(n / 3);
		}
		else if (Game.instance.slowLevel == 1){
			ft = Math.round(ft / 2);
			n = Math.ceil(n / 2);
		}
		for (i in 0...n){
			var p = new FlyPaper();
			p.gotoAndStop(Std.random(p.totalFrames)+1);
			p.fadeTime = ft;
			p.x = center.x;
			p.y = center.y;
			p.vect = Geom.radToVector(angle);
			p.speed = (0.5 + 2 - Math.random() * 1) * sr;
			papers.push(p);
			addChild(p);
			angle += aPerPaper;
			p.rotationSpeed = (2.5 - Math.random() * 5) * sr;
		}
	}

	public function destroy(){
		for (p in papers)
			removeChild(p);
		parent.removeChild(this);
	}

	public function update() : Bool {
		switch (state){
			case ST_BOOM:
				for (p in papers){
					p.x += p.vect.x * p.speed * mt.Timer.tmod;
					p.y += p.vect.y * p.speed * mt.Timer.tmod;
					p.scaleX = Math.min(2, p.scaleX + mt.Timer.tmod / 20);
					p.scaleY = Math.min(2, p.scaleY + mt.Timer.tmod / 20);
					p.rotation += p.rotationSpeed;
				}

			case ST_FADE:
				for (p in papers){
					p.x += p.vect.x * 0.5 * p.speed * mt.Timer.tmod;
					p.y += p.vect.y * 0.5 * p.speed * mt.Timer.tmod;
					p.scaleX = Math.max(0.3, p.scaleX - mt.Timer.tmod / 10);
					p.scaleY = Math.max(0.3, p.scaleY - mt.Timer.tmod / 10);
					p.alpha = p.alpha - (mt.Timer.tmod * 1 / p.fadeTime);
					p.rotation += p.rotationSpeed;
					if (p.alpha <= 0)
						papers.remove(p);
				}
				if (papers.length == 0)
					return false;
		}
		return true;
	}
}

@:bind
class XMissileCross extends flash.display.Sprite {
	public function new(){
		super();
	}
}

private enum State {
	Waiting;
	Falling;
	Exploding;
	Smoking;
}

@:bind
class XMissile extends flash.display.MovieClip {
	public static var EXPLODING_TIME = 0.2;
	public static var SMOKING_TIME = 3;
	var cross : XMissileCross;
	public var dangerous : Bool;
	var state : State;
	var speed : Float;
	var time : Float;
	var papers : FlyPaperAnim;

	public function new( targetX:Float, targetY:Float, ?delay:Float=0.0 ){
		super();
		speed = 10;
		var circle = Game.instance.scroll.getCurrentCircle();
		if (circle < 8)
			speed = 5;
		else
			speed = Math.min(10, 5 + circle - 8);
		speed = speed * (60/mt.Timer.wantedFPS);
		state = Falling;
		cross = new XMissileCross();
		cross.x = targetX;
		cross.y = targetY;
		gotoAndStop(1+Std.random(totalFrames));
		Game.instance.groundLayer.addChild(cross);
		x = cross.x;
		y = cross.y - Game.H;
		Game.instance.missiles.push(this);
		Game.instance.gameLayer.addChild(this);
		dangerous = false;
		if (delay > 0)
			setWait(delay);
	}

	public function setWait( t:Float ){
		state = Waiting;
		time = t;
		cross.visible = false;
		visible = false;
	}

	public function isColliding( t:Tank ) : Bool {
		var radius = 16;
		var tankBox = { xMin:t.x - t.width/2, xMax:t.x + t.width/2, yMin:t.y - t.height/2, yMax:t.y + t.height/2 };
		var explBox = { xMin:cross.x - radius, xMax:cross.x + radius, yMin:cross.y - radius, yMax:cross.y + radius }
		if (tankBox.xMin > explBox.xMax)
			return false;
		if (tankBox.xMax < explBox.xMin)
			return false;
		if (tankBox.yMin > explBox.yMax)
			return false;
		if (tankBox.yMax < explBox.yMin)
			return false;
		return true;
	}

	public function update(){
		switch (state){
			case Waiting:
				time -= mt.Timer.deltaT;
				if (time <= 0){
					time = 0;
					cross.visible = true;
					visible = true;
					state = Falling;
				}

			case Falling:
				y += speed * mt.Timer.tmod;
				var elap = 1 - ((cross.y - y) / Game.H);
				var scale = 1 - elap;
				alpha = elap;
				scaleX = 1 + scale;
				scaleY = 1 + scale * 2;
				if (y >= cross.y){
					alpha = 1;
					scaleX = 0.5;
					scaleY = 0.5;
					y = cross.y;
					cross.parent.removeChild(cross);
					state = Exploding;
					papers = new FlyPaperAnim(new flash.geom.Point(cross.x, cross.y));
					Game.instance.gameLayer.addChild(papers);
					Game.instance.gameLayer.swapChildren(this, papers);
					time = 0;
					dangerous = true;
				}

			case Exploding:
				papers.update();
				time += mt.Timer.deltaT;
				alpha = 0.9 - Math.min(1, time / EXPLODING_TIME);
				if (time >= EXPLODING_TIME){
					time = 0;
					state = Smoking;
					papers.state = FlyPaperAnim.ST_FADE;
					Game.instance.addAnimation(papers);
					dangerous = false;
				}

			case Smoking:
				// papers.update();
				time += mt.Timer.deltaT;
				if (time >= SMOKING_TIME){
					// papers.destroy();
					parent.removeChild(this);
					Game.instance.missiles.remove(this);
				}
		}
	}
}