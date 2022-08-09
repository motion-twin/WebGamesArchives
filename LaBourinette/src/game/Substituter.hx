package game;
import GameParameters;

typedef Replacement = { pos:Pos, oldP:PlayerData, newP:PlayerData };

typedef ARow = { pos:AttPos, p:PlayerData };

class AttackSubstituter {
	public var wanted : Array<ARow>;
	public var actual : Array<ARow>;
	public var replacements : Array<Replacement>;

	public function new(){
		wanted = [];
	}

	static function find<T>( l:Iterable<T>, f:T->Bool ) : T {
		for (v in l)
			if (f(v))
				return v;
		return null;
	}

	function replace( pos:AttPos, a:ARow, b:ARow ){
		actual.push({ pos:pos, p:b.p });
		if (b.p.attPos != pos){
			replacements.push({ pos:Att(pos), oldP:a != null ? a.p : null, newP:b.p });
			b.p.attPos = pos;
		}
		if (a != null && a.p.attPos == pos){
			a.p.attPos = null;
		}
	}

	public function optimize( nextBattler:AttPos, canSubstituteBattler:Bool ) : Bool {
		// should only be called after:
		// - a new pain,
		// - a new injure,
		// - a new ko,
		// - a new (i am not ko anymore),
		actual = [];
		replacements = [];
		var missingPos = new List();
		var available = new List();
		for (row in wanted)
			if (row.p.canPlay())
				available.add({pos:row.pos, p:row.p});
			else
				missingPos.add({pos:row.pos, p:row.p});
		var substitute = find(available, function(row) return row.pos == ASub);
		// no fucking there, We do not want to remove current battler even if he is a temporary substitute at this position.
		if (substitute != null && substitute.p.attPos == nextBattler && !canSubstituteBattler)
			substitute = null;
		var currentBattlerOk = find(available, function(row) return row.pos == nextBattler) != null;
		var battlers = [
			find(available, function(row) return row.pos == Bat1),
			find(available, function(row) return row.pos == Bat2),
			find(available, function(row) return row.pos == Bat3),
		];
		if (canSubstituteBattler && !currentBattlerOk && substitute != null){
			var subIndex = null;
			if (battlers[0] == null)
				subIndex = Bat1;
			else if (battlers[1] == null)
				subIndex = Bat2;
			else if (battlers[2] == null)
				subIndex = Bat3;
			if (nextBattler == subIndex){
				replace(nextBattler, find(missingPos, function(row) return row.pos == nextBattler), substitute);
				available.remove(substitute);
				substitute = null;
			}
		}
		else if (!currentBattlerOk && substitute == null){
			var count = 0;
			for (b in battlers)
				if (b != null)
					count++;
			if (count == 0)
				return false;
		}
		if (substitute != null){
			var missingPos = missingPos.filter(function(row) return (row.pos == AttL || row.pos == AttR));
			if (missingPos.length > 0){
				replace(missingPos.first().pos, missingPos.first(), substitute);
				available.remove(substitute);
				substitute = null;
			}
		}
		if (substitute != null){
			// substitute available, replace one tafiole
			var mostPainful : ARow = null;
			var replaceable = Lambda.filter(available, function(row) return row.pos == AttL || row.pos == AttR || row.pos == nextBattler);
			if (!canSubstituteBattler)
				replaceable = Lambda.filter(replaceable, function(row) return row.pos != nextBattler);
			for (row in replaceable)
				if (row.p.pains.length > 0 && (mostPainful == null || mostPainful.p.pains.length < row.p.pains.length))
					mostPainful = row;
			if (mostPainful != null && mostPainful.p.pains.length > substitute.p.pains.length){
				replace(mostPainful.pos, mostPainful, substitute);
				available.remove(mostPainful);
				available.remove(substitute);
			}
		}
		for (row in available){
			actual.push(row);
			if (row.pos != row.p.attPos)
				row.p.attPos = row.pos;
		}
		actual.sort(function(a,b) return tools.EnumTools.compareIndex(a.pos, b.pos));
		return true;
	}
}

typedef DRow = { pos:DefPos, p:PlayerData };

class DefenseSubstituter {
	public var wanted : Array<DRow>;
	public var actual : Array<DRow>;
	public var replacements : Array<Replacement>;

	public function new(){
		wanted = [];
	}

	static function find<T>( l:Iterable<T>, f:T->Bool ) : T {
		for (v in l)
			if (f(v))
				return v;
		return null;
	}

	function replace( pos:DefPos, a:DRow, b:DRow ){
		actual.push({ pos:pos, p:b.p });
		if (b.p.defPos != pos){
			replacements.push({ pos:Def(pos), oldP:a != null ? a.p : null, newP:b.p });
			//trace("Substitute "+b.p.id+" defPos(old) = "+b.p.defPos+" defPos(new) = "+pos);
			b.p.defPos = pos;
		}
		if (a != null && a.p.defPos == pos){
			//trace("replaced "+a.p.id+" defPos(old) = "+a.p.defPos+" defPos(new) = "+null);
			a.p.defPos = null;
		}
	}

	public function optimize() : Bool {
		// should only be called after:
		// - a new pain,
		// - a new injure,
		// - a new ko,
		// - a new (i am not ko anymore),
		actual = [];
		replacements = [];
		var missingPos = new List();
		var available = new List();

		/*
		for (row in wanted)
			if (row.p.canPlay())
				trace("#"+row.p.id+" OK, wanted at pos "+row.pos+" has pos "+row.p.defPos);
			else
				trace("#"+row.p.id+" KO, missing at pos "+row.pos+" has pos "+row.p.defPos);
		*/

		for (row in wanted)
			if (row.p.canPlay())
				available.add({pos:row.pos, p:row.p});
			else
				missingPos.add({pos:row.pos, p:row.p});

		// first of all, ensure that there is a thrower, it is the only really important
		// player for defense, we lose the match if there's no one there.
		var thrower2 = find(wanted, function(row) return row.p.secondThrower);
		var thrower = find(wanted, function(row) return row.pos == Thro);
		if (thrower == null)
			return false; // throw "No thrower found in wanted positions \n"+wanted.join("\n");
		if (!thrower.p.canPlay()){
			// he cannot play, we have the absolute necessity of replacing him
			if (thrower2 == null || !thrower2.p.canPlay())
				return false;
			//trace("replace thrower");
			replace(thrower.pos, thrower, thrower2);
			available = available.filter(function(row) return row.p != thrower2.p);
			missingPos.push(thrower2);
		}
		else if (thrower2 != null && thrower2.p.canPlay() && thrower.p.pains.length > thrower2.p.pains.length){
			// replace pained thrower with substitute
			//trace("replace thrower (2)");
			replace(thrower.pos, thrower, thrower2);
			available = available.filter(function(row) return row.p != thrower.p);
			available = available.filter(function(row) return row.p != thrower2.p);
			missingPos.push(thrower2);
		}
		var dbg = false;
		var substitute = find(available, function(row) return row.pos == DSub);
		if (substitute != null){
			var missingPos = missingPos.filter(function(row) return row.pos != Thro && row.pos != DSub);
			if (missingPos.length > 0){
				//trace("replace missing pos "+missingPos.first().pos);
				dbg = true;
				replace(missingPos.first().pos, missingPos.first(), substitute);
				available.remove(substitute);
				substitute = null;
			}
		}
		if (substitute != null){
			// substitute available, replace one tafiole
			var mostPainful : DRow = null;
			var replaceable = Lambda.filter(available, function(r) return r.pos != Thro);
			for (row in replaceable)
				if (row.p.pains.length > 0 && (mostPainful == null || mostPainful.p.pains.length < row.p.pains.length))
					mostPainful = row;
			if (mostPainful != null && mostPainful.p.pains.length > substitute.p.pains.length){
				//trace("replace most painful user");
				dbg = true;
				replace(mostPainful.pos, mostPainful, substitute);
				available.remove(mostPainful);
				available.remove(substitute);
			}
		}
		for (row in available){
			actual.push(row);
			if (row.pos != row.p.defPos)
				row.p.defPos = row.pos;
		}
		actual.sort(function(a,b) return tools.EnumTools.compareIndex(a.pos, b.pos));
		// if (dbg) for (row in actual) trace("#"+row.p.id+" will take pos "+row.p.defPos+" and should have pos "+row.pos);
		return true;
	}
}

// -----------------------------------------------------------------------------------------
// Test module
// -----------------------------------------------------------------------------------------

import haxe.PosInfos;

class TestPlayer extends PlayerData {
	public function new(id:Int, injured:Bool, knocked:Bool, pains:Int, ?secondThrower:Bool=false){
		super(cast {
			id:id,
			pains:[],
				endurance:1, agility:1, power:1, charisma:1, accuracy:1
				});
		this.id = id;
		this.injure = if (injured) BodyPart._HEAD else null;
		this.knockedOut = knocked ? 3 : 0;
		this.pains = [];
		for (i in 0...pains)
			this.pains.push("999");
		this.secondThrower = secondThrower;
	}

	override public function toString() : String {
		var status = ""
			+ (isInjured() ? "X" : "")
			+ (knockedOut > 0 ? "K" : "")
			+ (pains.length > 0 ? "."+pains.length : "");
		return "#"+id+status;
	}
}

import game.Team;
import GameParameters;

class Substituter {
	var defense : DefenseSubstituter;
	var attack : AttackSubstituter;
	var team : Team;

	public function new( team:game.Team, params:Parameters ){
		this.team = team;
		defense = new DefenseSubstituter();
		attack = new AttackSubstituter();
		for (p in team.players){
			defense.wanted.push({ pos:params.getDefPos(p.id), p:p });
			attack.wanted.push({ pos:params.getAttPos(p.id), p:p });
		}
	}

	public function optimize( nextBattler:AttPos, canSubstituteBattler:Bool ) : Bool {
		return switch (team.mode){
			case Mode.ATTACK: attack.optimize(nextBattler, canSubstituteBattler);
			case Mode.DEFENSE: defense.optimize();
		}
	}

	public function getReplacements() : Array<Replacement> {
		return switch (team.mode){
			case Mode.ATTACK: attack.replacements;
			case Mode.DEFENSE: defense.replacements;
		}
	}

	public function getActualTeam() : Array<{ pos:Pos, p:PlayerData }> {
		var result = [];
		switch (team.mode){
			case Mode.ATTACK:
				for (row in attack.actual)
					result.push({ pos:Att(row.pos), p:row.p });
			case Mode.DEFENSE:
				for (row in defense.actual)
					result.push({ pos:Def(row.pos), p:row.p });
		}
		return result;
	}

	public static function setupTestCases( r:haxe.unit.TestRunner ) : Void {
		r.add(new TestDefenseSubstituter());
		r.add(new TestAttackSubstituter());
	}

	public static function main() : Void {
		var r = new haxe.unit.TestRunner();
		setupTestCases(r);
		r.run();
	}
}

class TestDefenseSubstituter extends haxe.unit.TestCase {
	function assertPosEquals( expected:Array<{pos:DefPos, p:Int}>, actual:Array<DRow>, ?c:PosInfos ){
		currentTest.done = true;
		if (actual == null){
			currentTest.success = false;
			currentTest.error = "actual is null, forgot to call optimize() ?";
			currentTest.posInfos = c;
			throw currentTest;
		}
		if (actual.length != expected.length){
			currentTest.success = false;
			currentTest.error = "size error, \nexpected=----\n"+expected.join("\n")+"\nbut was=----\n"+actual.join("\n");
			currentTest.posInfos = c;
			throw currentTest;
		}
		for (i in 0...expected.length){
			if (expected[i].pos != actual[i].pos){
				currentTest.success = false;
				currentTest.error = "pos error, \nexpected=----\n"+expected.join("\n")+"\nbut was=----\n"+actual.join("\n");
				currentTest.posInfos = c;
				throw currentTest;
			}
			else if (expected[i].p != actual[i].p.id){
				currentTest.success = false;
				currentTest.error = "player error, \nexpected=----\n"+expected.join("\n")+"\nbut was=----\n"+actual.join("\n");
				currentTest.posInfos = c;
				throw currentTest;
			}
		}
	}

	public function testNoModif() : Void {
		var op = new DefenseSubstituter();
		op.wanted = [
			{ pos:Thro, p:cast new TestPlayer(0, false, false, 0) },
			{ pos:DefL, p:cast new TestPlayer(1, false, false, 0, true) },
			{ pos:DefM, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:DefR, p:cast new TestPlayer(3, false, false, 0) },
			{ pos:DefF, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:DSub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize();
		assertPosEquals([
			{ pos:Thro, p:0 },
			{ pos:DefL, p:1 },
			{ pos:DefM, p:2 },
			{ pos:DefR, p:3 },
			{ pos:DefF, p:4 },
			{ pos:DSub, p:5 }
		], op.actual);
	}

	public function testReplaceInjuredThrower() : Void {
		var op = new DefenseSubstituter();
		op.wanted = [
			{ pos:Thro, p:cast new TestPlayer(0, true, false, 0) },
			{ pos:DefL, p:cast new TestPlayer(1, false, false, 0, true) },
			{ pos:DefM, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:DefR, p:cast new TestPlayer(3, false, false, 0) },
			{ pos:DefF, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:DSub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize();
		assertPosEquals([
			{ pos:Thro, p:1 },
			{ pos:DefL, p:5 },
			{ pos:DefM, p:2 },
			{ pos:DefR, p:3 },
			{ pos:DefF, p:4 },
		], op.actual);
	}

	public function testReplaceKnockedThrower() : Void {
		var op = new DefenseSubstituter();
		op.wanted = [
			{ pos:Thro, p:cast new TestPlayer(0, false, true, 0) },
			{ pos:DefL, p:cast new TestPlayer(1, false, false, 0, true) },
			{ pos:DefM, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:DefR, p:cast new TestPlayer(3, false, false, 0) },
			{ pos:DefF, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:DSub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize();
		assertPosEquals([
			{ pos:Thro, p:1 },
			{ pos:DefL, p:5 },
			{ pos:DefM, p:2 },
			{ pos:DefR, p:3 },
			{ pos:DefF, p:4 },
		], op.actual);
	}

	public function testReplacePainThrower() : Void {
		var op = new DefenseSubstituter();
		op.wanted = [
			{ pos:Thro, p:cast new TestPlayer(0, false, false, 2) },
			{ pos:DefL, p:cast new TestPlayer(1, false, false, 1, true) },
			{ pos:DefM, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:DefR, p:cast new TestPlayer(3, false, false, 0) },
			{ pos:DefF, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:DSub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize();
		assertPosEquals([
			{ pos:Thro, p:1 },
			{ pos:DefL, p:5 },
			{ pos:DefM, p:2 },
			{ pos:DefR, p:3 },
			{ pos:DefF, p:4 },
		], op.actual);
	}

	public function testDoNotReplaceThrower() : Void {
		var op = new DefenseSubstituter();
		op.wanted = [
			{ pos:Thro, p:cast new TestPlayer(0, false, false, 2) },
			{ pos:DefL, p:cast new TestPlayer(1, false, false, 3, true) },
			{ pos:DefM, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:DefR, p:cast new TestPlayer(3, false, false, 0) },
			{ pos:DefF, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:DSub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize();
		assertPosEquals([
			{ pos:Thro, p:0 },
			{ pos:DefL, p:5 },
			{ pos:DefM, p:2 },
			{ pos:DefR, p:3 },
			{ pos:DefF, p:4 },
		], op.actual);
	}

	public function testGameOver() : Void {
		var op = new DefenseSubstituter();
		op.wanted = [
			{ pos:Thro, p:cast new TestPlayer(0, true, false, 2) },
			{ pos:DefL, p:cast new TestPlayer(1, false, true, 3, true) },
			{ pos:DefM, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:DefR, p:cast new TestPlayer(3, false, false, 0) },
			{ pos:DefF, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:DSub, p:cast new TestPlayer(5, false, false, 0) },
		];
		assertFalse(op.optimize());
	}

	public function testReplacePainThrower2() : Void {
		var op = new DefenseSubstituter();
		op.wanted = [
			{ pos:Thro, p:cast new TestPlayer(0, false, true,  0) },
			{ pos:DefL, p:cast new TestPlayer(1, true,  false, 2) },
			{ pos:DefM, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:DefR, p:cast new TestPlayer(3, false, false, 0) },
			{ pos:DefF, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:DSub, p:cast new TestPlayer(5, false, false, 0, true) },
		];
		op.optimize();
		assertPosEquals([
			{ pos:Thro, p:5 },
			{ pos:DefM, p:2 },
			{ pos:DefR, p:3 },
			{ pos:DefF, p:4 },
		], op.actual);
	}
}

class TestAttackSubstituter extends haxe.unit.TestCase {
	function assertPosEquals( expected:Array<{pos:AttPos, p:Int}>, actual:Array<ARow>, ?c:PosInfos ){
		currentTest.done = true;
		if (actual == null){
			currentTest.success = false;
			currentTest.error = "actual is null, forgot to call optimize() ?";
			currentTest.posInfos = c;
			throw currentTest;
		}
		if (actual.length != expected.length){
			currentTest.success = false;
			currentTest.error = "size error, \nexpected=----\n"+expected.join("\n")+"\nbut was=----\n"+actual.join("\n");
			currentTest.posInfos = c;
			throw currentTest;
		}
		for (i in 0...expected.length){
			if (expected[i].pos != actual[i].pos){
				currentTest.success = false;
				currentTest.error = "pos error, \nexpected=----\n"+expected.join("\n")+"\nbut was=----\n"+actual.join("\n");
				currentTest.posInfos = c;
				throw currentTest;
			}
			else if (expected[i].p != actual[i].p.id){
				currentTest.success = false;
				currentTest.error = "player error, \nexpected=----\n"+expected.join("\n")+"\nbut was=----\n"+actual.join("\n");
				currentTest.posInfos = c;
				throw currentTest;
			}
		}
	}

	public function testNoModif() : Void {
		var op = new AttackSubstituter();
		op.wanted = [
			{ pos:AttL, p:cast new TestPlayer(0, false, false, 0) },
			{ pos:AttR, p:cast new TestPlayer(1, false, false, 0) },
			{ pos:Bat1, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:Bat2, p:cast new TestPlayer(3, false, false, 0, true) },
			{ pos:Bat3, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:ASub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize(Bat1,true);
		assertPosEquals([
			{ pos:AttL, p:0 },
			{ pos:AttR, p:1 },
			{ pos:Bat1, p:2 },
			{ pos:Bat2, p:3 },
			{ pos:Bat3, p:4 },
			{ pos:ASub, p:5 }
		], op.actual);
	}

	public function testReplaceAtt() : Void {
		var op = new AttackSubstituter();
		op.wanted = [
			{ pos:AttL, p:cast new TestPlayer(0, true, false, 0) },
			{ pos:AttR, p:cast new TestPlayer(1, false, false, 0) },
			{ pos:Bat1, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:Bat2, p:cast new TestPlayer(3, false, false, 0, true) },
			{ pos:Bat3, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:ASub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize(Bat1,true);
		assertPosEquals([
			{ pos:AttL, p:5 },
			{ pos:AttR, p:1 },
			{ pos:Bat1, p:2 },
			{ pos:Bat2, p:3 },
			{ pos:Bat3, p:4 },
		], op.actual);
	}

	public function testDoNotReplaceBat() : Void {
		var op = new AttackSubstituter();
		op.wanted = [
			{ pos:AttL, p:cast new TestPlayer(0, false, false, 0) },
			{ pos:AttR, p:cast new TestPlayer(1, false, false, 0) },
			{ pos:Bat1, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:Bat2, p:cast new TestPlayer(3, true, false, 0, true) },
			{ pos:Bat3, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:ASub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize(Bat1,true);
		assertPosEquals([
			{ pos:AttL, p:0 },
			{ pos:AttR, p:1 },
			{ pos:Bat1, p:2 },
			// this is not my turn
			{ pos:Bat3, p:4 },
			{ pos:ASub, p:5 },
		], op.actual);
	}

	public function testReplaceAttPriority() : Void {
		var op = new AttackSubstituter();
		op.wanted = [
			{ pos:AttL, p:cast new TestPlayer(0, true, false, 0) },
			{ pos:AttR, p:cast new TestPlayer(1, false, false, 0) },
			{ pos:Bat1, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:Bat2, p:cast new TestPlayer(3, true, false, 0, true) },
			{ pos:Bat3, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:ASub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize(Bat1,true);
		assertPosEquals([
			{ pos:AttL, p:5 },
			{ pos:AttR, p:1 },
			{ pos:Bat1, p:2 },
			{ pos:Bat3, p:4 },
		], op.actual);
	}

	public function testReplaceBatPriority() : Void {
		var op = new AttackSubstituter();
		op.wanted = [
			{ pos:AttL, p:cast new TestPlayer(0, true, false, 0) },
			{ pos:AttR, p:cast new TestPlayer(1, false, false, 0) },
			{ pos:Bat1, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:Bat2, p:cast new TestPlayer(3, true, false, 0, true) },
			{ pos:Bat3, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:ASub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize(Bat2,true);
		assertPosEquals([
			{ pos:AttR, p:1 },
			{ pos:Bat1, p:2 },
			{ pos:Bat2, p:5 },
			{ pos:Bat3, p:4 },
		], op.actual);
	}

	// Two battlers injured, cannot replace the second one since the substitute is
	// occupied with the first place
	public function testCannotReplaceBatPriority() : Void {
		var op = new AttackSubstituter();
		op.wanted = [
			{ pos:AttL, p:cast new TestPlayer(0, true, false, 0) },
			{ pos:AttR, p:cast new TestPlayer(1, false, false, 0) },
			{ pos:Bat1, p:cast new TestPlayer(2, true, false, 0) },
			{ pos:Bat2, p:cast new TestPlayer(3, false, false, 0, true) },
			{ pos:Bat3, p:cast new TestPlayer(4, true, false, 0) },
			{ pos:ASub, p:cast new TestPlayer(5, false, false, 0) },
		];
		op.optimize(Bat3,true);
		assertPosEquals([
			{ pos:AttL, p:5 },
			{ pos:AttR, p:1 },
			{ pos:Bat2, p:3 },
		], op.actual);
	}

	public function testGameOver() : Void {
		var op = new AttackSubstituter();
		op.wanted = [
			{ pos:AttL, p:cast new TestPlayer(0, true, false, 0) },
			{ pos:AttR, p:cast new TestPlayer(1, false, false, 0) },
			{ pos:Bat1, p:cast new TestPlayer(2, true, false, 0) },
			{ pos:Bat2, p:cast new TestPlayer(3, false, true, 0, true) },
			{ pos:Bat3, p:cast new TestPlayer(4, true, false, 0) },
			{ pos:ASub, p:cast new TestPlayer(5, false, true, 0) },
		];
		assertFalse(op.optimize(Bat2,true));
	}

	public function testCannotReplaceBat() : Void {
		var op = new AttackSubstituter();
		op.wanted = [
			{ pos:AttL, p:cast new TestPlayer(0, false, false, 0) },
			{ pos:AttR, p:cast new TestPlayer(1, false, false, 0) },
			{ pos:Bat1, p:cast new TestPlayer(2, false, false, 0) },
			{ pos:Bat2, p:cast new TestPlayer(3, false, true, 0, true) },
			{ pos:Bat3, p:cast new TestPlayer(4, false, false, 0) },
			{ pos:ASub, p:cast new TestPlayer(5, false, true, 0) },
		];
		assertTrue(op.optimize(Bat2,false));
		assertPosEquals([
			{ pos:AttL, p:0 },
			{ pos:AttR, p:1 },
			{ pos:Bat1, p:2 },
			//			{ pos:Bat2, p:3 },
			{ pos:Bat3, p:4 },
		], op.actual);
	}
}