package game.viewer;
import game.Geom;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextFieldAutoSize;

/*
 * That is the game field.
 *
 * This sprite contains all game's entities and is scaled by the viewer to fit available screen size.
 */
class Field extends Sprite {
	public var fieldLayer : Sprite;
	public var aboveFxLayer : Sprite;
	public var belowFxLayer : Sprite;
	var shadowLayer : Sprite;
	var playerLayer : Sprite;
	public var anims : List<{ update:Void->Bool, stop:Void->Void }>;

	public function new(){
		super();
		rotation = -90;
		anims = new List();
		fieldLayer = new Sprite();
		fieldLayer.alpha = 0.8;
		if (Viewer.DRAW_FIELD)
			addChild(fieldLayer);
		drawPizzaPart(110, 0xDD0000); // red zone
		for (i in 0...11)
			drawPizzaPart(100-(i*10), if (i%2 == 0) 0x44CC00 else 0x55EE33); // green zone
		drawPizzaPart(30,  0xEEEEAA); // safe zone
		// field curves
		fieldLayer.graphics.lineStyle(1, 0x000000, 0.5);
		for (i in 2...12)
			drawCurveLine(i * 10);
		// field lines
		var point = new Point(110, 0).rotate(Math.PI/4);
		for (i in 0...5){
			fieldLayer.graphics.lineStyle(1, 0x000000, 0.5);
			fieldLayer.graphics.moveTo(0,0);
			fieldLayer.graphics.lineTo(point.x, point.y);
			point.rotate(-Math.PI/8);
		}
		var point = new Point(109, 0).rotate(Math.PI/4).rotate(-Math.PI/16);
		for (i in 0...4){
			fieldLayer.graphics.lineStyle(1, 0x887777, 0.3);
			fieldLayer.graphics.moveTo(0,0);
			fieldLayer.graphics.lineTo(point.x, point.y);
			point.rotate(-Math.PI/8);
		}
		// red receiver zone (behind battler)
		fieldLayer.graphics.lineStyle(0, 0xDD0000);
		fieldLayer.graphics.beginFill(0xDD0000);
		var r = game.Field.getReceptionRect();
		fieldLayer.graphics.drawRect(r.x, r.y, r.w, r.h);
		// fieldLayer.graphics.drawRect(-5, -5, 5, 10);
		fieldLayer.graphics.endFill();
		fieldLayer.graphics.lineStyle(0.5, 0xFFFFFF);
		fieldLayer.graphics.moveTo(game.Field.RECEPTION_ZONE[0].x, game.Field.RECEPTION_ZONE[0].y);
		fieldLayer.graphics.lineTo(game.Field.RECEPTION_ZONE[1].x, game.Field.RECEPTION_ZONE[1].y);
		fieldLayer.graphics.beginFill(0xFFFFFF);
		fieldLayer.graphics.drawCircle(r.x+r.w, r.y, 0.5);
		fieldLayer.graphics.drawCircle(r.x+r.w, r.y+r.h, 0.5);
		fieldLayer.graphics.endFill();
		// field curves' distance texts (10 meters, 20 meters, etc.)
		var tfmt = new TextFormat();
		tfmt.align = TextFormatAlign.CENTER;
		tfmt.color = 0xCCFFCC;
		tfmt.bold = true;
		tfmt.font = "Arial";
		tfmt.size = 4;
		for (i in 2...11){
			var text = new TextField();
			text.alpha = 0.7;
			text.y = 0;
			text.x = i*10 ;
			text.selectable = false;
			text.autoSize = TextFieldAutoSize.NONE;
			text.defaultTextFormat = tfmt;
			var point = new Point(i*10, 0);
			text.x = point.x;
			text.y = point.y;
			text.text = Std.string(i*10);
			text.width = 12;
			text.height = 12;
			text.setTextFormat(tfmt);
			text.backgroundColor = 0xFF0000;
			text.filters = [
				new flash.filters.GlowFilter(0x000000, 0.5, 2, 2, 100)
			];
			// This is really interesting but doesn't work for this purpose (zoom bug)
			// text.rotationZ = (-Math.PI/4)* 180 / Math.PI;
			fieldLayer.addChild(text);
		}
		shadowLayer = new Sprite(); addChild(shadowLayer);
		belowFxLayer = new Sprite(); addChild(belowFxLayer);
		playerLayer = new Sprite(); addChild(playerLayer);
		aboveFxLayer = new Sprite(); addChild(aboveFxLayer);
	}

	public function update(){
		for (anim in anims)
			if (!anim.update())
				anims.remove(anim);
	}

	public function clearAnims(){
		for (anim in anims)
			anim.stop();
		anims = new List();
	}

	public function addPunchAnim( p:{x:Float, y:Float}, ?c:Null<UInt>=0xFFFFFF, ?withParticules=false ){
		if (p == null)
			return;
		var anim = new PunchAnim(p.x, p.y, c, withParticules);
		shadowLayer.addChild(anim);
		anims.push(cast anim);
	}

	public function addPlayer( p:FieldPlayer ){
		p.rotation = -rotation;
		shadowLayer.addChild(p.shadow);
		playerLayer.addChild(p);
	}

	public function addBall( p:FieldBall ){
		shadowLayer.addChild(p.shadow);
		playerLayer.addChild(p);
	}

	public function addTarget( t:FieldTarget ){
		playerLayer.addChild(t);
	}

	function drawPizzaPart( dist:Float, color:UInt ){
		var point = new Point(dist, 0).rotate(Math.PI/4);
		fieldLayer.graphics.beginFill(color);
		fieldLayer.graphics.moveTo(0,0);
		fieldLayer.graphics.lineTo(point.x, point.y);
		point.rotate(-Math.PI/2);
		fieldLayer.graphics.curveTo(quadraticBezierControlX(dist), 0, point.x, point.y);
		fieldLayer.graphics.lineTo(0,0);
		fieldLayer.graphics.endFill();
	}

	function curveTo( dist:Float, target:geom.Pt ){
		fieldLayer.graphics.curveTo(quadraticBezierControlX(dist), 0, target.x, target.y);
	}

	function quadraticBezierControlX( dist:Float ) : Float {
		return dist / Math.cos(Math.PI*3/8) / 2;
	}

	function drawCurveLine( dist:Float ){
		var pointA = new Point(dist, 0).rotate(-Math.PI/4);
		var pointB = new Point(dist, 0).rotate( Math.PI/4);
		fieldLayer.graphics.moveTo(pointA.x, pointA.y);
		fieldLayer.graphics.curveTo(quadraticBezierControlX(dist), 0, pointB.x, pointB.y);
	}
}