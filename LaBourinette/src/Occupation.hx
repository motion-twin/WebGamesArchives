import Competence;
import db.Player;

class Occupation {
	var start : Date;
	var end : Date;
	var cost : Int;

	public function new( s:Date, e:Date, c:Int ){
		start = s;
		end = e;
		cost = c;
	}

	public function getRefund() : Int {
		var hours = getTotalHours();
		return Math.floor( (cost / hours) * (hours - getElapsedHours()) );
	}

	public function getCost() : Int {
		return cost;
	}

	public function getTotalHours() : Float {
		return (end.getTime() - start.getTime()) / DateTools.hours(1);
	}

	public function getElapsedHours() : Int {
		var done = Math.min(end.getTime(), Date.now().getTime()) - start.getTime();
		return Math.floor(done / DateTools.hours(1));
	}

	public function getCompletion() : Float {
		var now = Date.now().getTime();
		var done = now - start.getTime();
		return Math.min(1.0, done / (end.getTime()-start.getTime()));
	}

	public function getRemainingSeconds() : Float {
		return Math.max(0.0, (end.getTime() - Date.now().getTime()) / 1000.0);
	}
}

class Healing extends Occupation {
	var hp : Int;
	public function new( hp, s, e, p ){
		super(s,e,p);
		this.hp = hp;
	}

	public function getCurrentHp() : Int {
		return getElapsedHours();
	}
}

class Training extends Occupation {
	var carac : Carac;

	public function new( c, s, e, p ){
		super(s, e, p);
		this.carac = c;
	}

	public function getKind() : String {
		return Std.string(carac);
	}

	public function getCompName() : String {
		return Text.getText(Std.string(carac));
	}
}

class Surgery extends Occupation {
	var kind : BodyPart;
	public function new( k, s, e, p ){
		super(s,e,p);
		kind = k;
	}
}