package game.viewer;

import game.Geom;
import flash.display.Sprite;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

/*
 * Representation of a player on the field.
 * A colored dot with a shadow, a lifebar and some debug information.
 */
class FieldPlayer extends Sprite, implements game.viewer.Animator.GraphicRepresentation {
	public var player : game.PlayerData;
	public var shadow : Shadow;
	public var life : LifeBar;
	public var status : StatusIndicator;
	public var dangers : List<DangerAngle>;
	public var lines : Shape;
	public var sprintIndicator : Shape;
	public var indicator : Shape;
	public var pname : TextField;
	public var position : geom.PVector3D;

	public function new(team:Int, player:game.PlayerData){
		super();

		pname = new TextField();
		pname.text = game.viewer.GameLog.getPlayerName(player);
		var fmt = new TextFormat();
		fmt.align = TextFormatAlign.CENTER;
		fmt.color = if (player.team.name == game.viewer.GameLog.watcherName) 0xFFFFFF else 0xAAAAAA;
		fmt.font = "Arial";
		fmt.size = 4;
		fmt.bold = true;
		pname.autoSize = flash.text.TextFieldAutoSize.LEFT;
		pname.setTextFormat(fmt);
		addChild(pname);
		pname.x = -pname.width / 2;
		pname.visible = false;

		this.shadow = new Shadow(1, 2);
		this.player = player;
		this.x = player.x;
		this.y = player.y;
		this.life = new LifeBar(player.life, player.maxLife);
		this.status = new StatusIndicator();
		this.position = player.position.clone();
		graphics.lineStyle(1, if (team == 0) 0x8888FF else 0xFF8888);
		graphics.beginFill(if (team == 0) 0x5555AA else 0xAA5555);
		graphics.drawCircle(0, 0, 2);
		graphics.endFill();
		addChild(life);
		addChild(status);
		dangers = new List();
		lines = new Shape();
		addChild(lines);

		sprintIndicator = new Shape();
		sprintIndicator.graphics.beginFill(0xFFFFFF, 0.5);
		sprintIndicator.graphics.drawCircle(0, 0, 2);
		sprintIndicator.graphics.endFill();
		addChild(sprintIndicator);

		indicator = new flash.display.Shape();
		indicator.graphics.beginFill(0xFFFFFF);
		indicator.graphics.moveTo(0,0);
		indicator.graphics.lineTo(-3,-3);
		indicator.graphics.lineTo( 3,-3);
		indicator.graphics.lineTo(0,0);
		indicator.graphics.endFill();
		indicator.y = -3;
		if (Viewer.DRAW_EXTRA)
			addChild(indicator);

		addEventListener(flash.events.MouseEvent.CLICK, onClic);
	}

	function onClic(_){
		Viewer.instance.playerClicked(this);
	}

	public function update() : Void {
		x = position.x;
		y = position.y;
		this.shadow.update(x, y);
		this.life.update(player.life);
		this.sprintIndicator.visible = player.sprintPower > 0;
		this.status.visible = Viewer.instance.showIndicators;
		this.status.id = Std.string(player.pos);
		this.status.text = Std.string(player.getState());
		for (d in dangers){
			removeChild(d);
			dangers.remove(d);
		}
		lines.graphics.clear();
		if (Viewer.instance.showIndicators
		    && Viewer.instance.getState() == game.viewer.State.PLAY
			&& Viewer.instance.resolver.ball != null
			&& Viewer.instance.resolver.ball.owner == player){
			Viewer.instance.resolver.field.updateDistances();
			var circle = player.getDangerCircle();
			lines.graphics.lineStyle(0.5, 0xFFFF00);
			var angle = circle.head;
			while (angle != null){
				var color = if (angle.value.danger == 0) 0x00FF00 else 0xFF0000;
				var target = null;
				if (angle.value.player != null)
					target = new Point(angle.value.player.x-x, angle.value.player.y-y);
				var danger = new DangerAngle( angle.start, angle.len, 10, color, target);
				dangers.push(danger);
				addChild(danger);
				angle = angle.next;
			}
			if (player.previousMoveVector != null){
				lines.graphics.moveTo(0,0);
				lines.graphics.lineTo(player.previousMoveVector.x, player.previousMoveVector.y);
			}
			circle.checkIntegrity();
			var i = 8;
			var colors = [ 0x000000, 0x330000, 0x550000, 0x770000, 0x990000, 0xBB0000, 0xDD0000, 0xFF0000 ];
			for (p in player.getBestSupportPoints()){
				var c = colors[--i];
				if (p.score == 0)
					c = 0x000000;
				lines.graphics.beginFill(c);
				lines.graphics.drawCircle(p.x-x, p.y-y, 2);
				lines.graphics.endFill();
			}
		}
		if (player != null && player.currentState != null && player.currentState == game.ai.PassToPlayer){
			lines.graphics.lineStyle(1, 0xFF0000);
			lines.graphics.moveTo(0,0);
			lines.graphics.lineTo(player.targetPlayer.x - player.x, player.targetPlayer.y - player.y);
		}
		indicator.visible = (player != null && player.team.leader == player);
	}
}

/*
 * A text line linked to players so we can debug things.
 */
class StatusIndicator extends Sprite {
	var idField: TextField;
	var textField : TextField;
	public var text(getText,setText) : String;
	public var id(getId,setId) : String;
	function getText() : String {
		return textField.text;
	}
	function setText(t:String) : String {
		textField.text = t;
		return t;
	}
	function getId() : String {
		return idField.text;
	}
	function setId(t:String) : String {
		idField.text = t;
		return t;
	}
	public function new(){
		super();
		var tfmt = new TextFormat();
		tfmt.align = TextFormatAlign.LEFT;
		tfmt.color = 0xCCFFCC;
		tfmt.bold = true;
		tfmt.font = "Arial";
		tfmt.size = 1.5;
		textField = new TextField();
		textField.width = 100;
		textField.alpha = 1;
		textField.selectable = false;
		textField.defaultTextFormat = tfmt;
		textField.setTextFormat(tfmt);
		textField.y = 2.5;
		textField.x = 0;
		idField = new TextField();
		idField.width = 20;
		idField.alpha = 1;
		idField.selectable = false;
		idField.defaultTextFormat = tfmt;
		idField.setTextFormat(tfmt);
		idField.y = 0;
		idField.x = 0;
		graphics.lineStyle(0.5, 0xCCFFCC, 1);
		graphics.moveTo(0,0);
		graphics.lineTo(0,4);
		graphics.lineTo(10,4);
		addChild(textField);
		addChild(idField);
		idField.filters = [ new flash.filters.GlowFilter(0x000000, 0.5, 2, 2, 100) ];
		textField.filters = idField.filters;
	}
}

/*
 * A piece of cake which represents player's danger angles (red/green, large/small).
 */
class DangerAngle extends Shape {
	var start : Float;
	var end : Float;
	var color : UInt;
	var arcAngle : Float;
	public function new( angleStart:Float, angleLength:Float, radius:Float, c:UInt, tp:Point ){
		super();
		arcAngle = angleLength;
		start = angleStart;
		end = angleStart + angleLength;
		color = c;
		var p1 = new Point(0, radius).rotate(start);
		var p2 = new Point(0, radius).rotate(end);
		graphics.lineStyle(0.5, c);
		graphics.beginFill(c, 0.5);
		graphics.moveTo(0,0);
		graphics.lineTo(p1.x, p1.y);
		var steps = Std.int(Math.abs(Math.round(angleLength*360/(Math.PI*2))));
		for (i in 0...steps){
			p1.rotate(angleLength/steps);
			graphics.lineTo(p1.x, p1.y);
		}
		graphics.lineTo(p2.x, p2.y);
		graphics.lineTo(0,0);
		graphics.endFill();
	}
}

class ShowNameAnim {
	public var time : Int;
	public var duration : Int;
	public var name : TextField;

	public function new( name:TextField, duration:Int ){
		this.time = 0;
		this.name = name;
		this.name.visible = true;
		this.name.alpha = 1;
		this.duration = duration;
	}

	public function stop() : Void {
		time = duration;
		name.alpha = 0;
		name.visible = false;
	}

	public function update() : Bool {
		var ratio = (++time)/duration;
		if (ratio >= 1.0){
			stop();
			return false;
		}
		if (ratio < 0.5)
			name.alpha = 1;
		else
			name.alpha = (ratio*2);
		return true;
	}
}