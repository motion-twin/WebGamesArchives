package game.viewer;

class BallTrailPart extends flash.display.Sprite {
	var size : Float;
	public function new(b:FieldBall){
		super();
		x = b.position.x;
		y = b.position.y;
		size = 1.5;
		scaleX = 1 + 3*b.position.z/30;
		scaleY = 1 + 3*b.position.z/30;
		b.parent.addChild(this);
	}
	public function stop(){
		size = 0;
		parent.removeChild(this);
	}
	public function update() : Bool {
		size -= 0.1;
		graphics.clear();
		if (size <= 0){
			stop();
			return false;
		}
		blendMode = flash.display.BlendMode.OVERLAY;
		graphics.beginFill(0xFFFF55, 0.3);
		graphics.drawCircle(0, 0, size);
		return true;
	}
}

/*
 * Represents the picoron.
 */
class FieldBall extends flash.display.Sprite, implements game.viewer.Animator.GraphicRepresentation {
	public var shadow : Shadow;
	public var ball : game.Ball;
	public var info : flash.display.Shape;
	public var position : geom.PVector3D;

	public function new(b:game.Ball){
		super();
		mouseEnabled = false;
		shadow = new Shadow(0.5, 1.5);
		ball = b;
		draw();
		info = new flash.display.Shape();
		info.visible = game.viewer.Viewer.DRAW_EXTRA;
		addChild(info);
		addEventListener(flash.events.MouseEvent.CLICK, onclick);
		position = new geom.PVector3D();
	}

	public function respawn(){
		draw();
	}

	public function kill(){
		draw(0xFF0000);
	}

	function draw( ?c=0xFFFF00 ){
		graphics.clear();
		graphics.lineStyle(0.5, 0x000000);
		graphics.beginFill(c);
		graphics.drawCircle(0, 0, 1.5);
		graphics.endFill();
	}

	function onclick(_){
		trace("BALL at "+ball.position);
	}

	public function update(){
		this.x = position.x;
		this.y = position.y;
		this.shadow.x = x;
		this.shadow.y = y;
		if (ball.resolver.state == game.GameState.THROW)
			Viewer.instance.field.anims.push(cast new BallTrailPart(this));
		info.graphics.clear();
		if (ball.isFlying){
			var v = ball.velocity;
			info.graphics.lineStyle(0.5, 0x000000);
			info.graphics.moveTo(0,0);
			info.graphics.lineTo(v.x, v.y);
		}
		info.graphics.lineStyle(0.5, 0xFF0000);
		info.graphics.moveTo(0,0);
		info.graphics.lineTo(ball.oldPosition.x-x, ball.oldPosition.y-y);
		scaleX = 1 + 3*position.z/30;
		scaleY = 1 + 3*position.z/30;
	}
}