#if js
JS MUST NOT REACH THIS POINT
#end
package game;
import Vice;
import Item;
import Stat;
import game.Geom;
import game.Event;
import game.InitialData;
import game.Resolver;
import game.Team;
import GameParameters;
import game.CircleList;
import geom.PVector3D;

/*
  When a team leader is declared,
  His friends can choose to support him going
  to a specified support point placed around the leader.
*/
class SupportPoint extends PVector3D {
	public var score : Float;
	public var name : String;
	public var reservation : PlayerData;
	public function getNearest( a:Array<PlayerData> ) : PlayerData {
		var sqDist = 9999999999.9;
		var player = null;
		for (p in a){
			var d = p.position.distanceSquared(this);
			if (d < sqDist){
				sqDist = d;
				player = p;
			}
		}
		return player;
	}
}

class PlayerData extends geom.Mover3D {
	// common stuff
	public var id : Int;
	public var name : String;
	public var label : String;
	public var power : Int;
	public var agility : Int;
	public var charisma : Int;
	public var accuracy : Int;
	public var endurance : Int;
	public var age : Int;
	public var maxLife : Int;
	public var life : Int;
	public var vices : IVices;
	public var usedVices : IVices;
	public var items : List<IItem>;
	public var competences : ICompetences;
	public var competencesCooldown : Hash<Int>;
	public var activeDrugs : List<{drug:Drug, time:Int}>;
	// resolution stuff
	public inline static var MAX_SPEED = 8;
	public inline static var FAR_DIST = 60;
	public inline static var MEDIUM_DIST = 30;
	public inline static var FIGHT_DIST = 6;
	public inline static var PLAYER_SIZE = 4;
	public inline static var CATCH_DISTANCE = FIGHT_DIST/2;
	inline static var SPRINTS_PER_ATTEMPT = 2; // max number of sprints per attempt
	inline static var SPRINT_COST = 3; // life cost of a sprint
	inline static var SPRINT_TICKS = 5; // duration of a sprint
	inline static var SAFE_LIFE = 25; // won't sprint if life's at this level
	inline static var WARN_LIFE = 15; // life warning, this is hard
	inline static var CRITIC_LIFE = 10; // serious danger here
	public var idx : Int;
	public var team : Team;
	public var pos : Pos;
	public var defPos : DefPos;
	public var attPos : AttPos;
	public var previousMoveVector : PVector3D;
	public var resolver : game.Resolver;
	public var reservedSupport : SupportPoint;
	public var supportValue : Float;
	public var aggr : Int;
	public var pains : Array<Null<OrganId>>;
	public var injure : BodyPart;
	public var injureLoc : OrganId;
	public var knockedOut(default,null) : Int;
	public var morale : Float;
	public var moraleAttemptBonus : Int;
	public var secondThrower : Bool;
	public var competencesList : List<Competence>;
	public var vicesList : List<Vice>;
	public var activeVices : List<Vice>;
	// temporary deactivated items
	public var tmpItems : List<IItem>;
	// list of vices which must be triggered during the game
	public var ingameVices : List<{vice:Vice, cond:PlayerData->Bool, chances:Int}>;
	public var waitingVice : {vice:Vice, cond:PlayerData->Bool, chances:Int};
	// computed skills
	public var allSkillModifier : Float;
	private var bonusHideFault : Int;
	public var skillAttractPicoron : Float;
	public var skillKillBall : Int;
	public var skillCatchBall : Int;
	public var skillThrowPrecision : Int;
	public var skillPassBall : Int;
	public var skillPowerThrow : Int;
	public var skillSpeedThrow : Int;
	public var skillCurveThrow : Int;
	public var skillPowerReception : Int;
	public var skillSpeedReception : Int;
	public var skillCurveReception : Int;
	public var skillBatterPrecision : Int;
	public var skillBatterPower : Int;
	public var skillInitiative : Int;
	public var skillAttack : Int;
	public var skillPush : Int;
	public var skillEsquive : Int;
	public var skillSpeed : Int;
	// public var skillSpeed : Int;
	public var attemptSprints : Int;
	public var sprintPower : Int;
	public var hurtBonus : Int; // hurt bonus (usually given by a hammer)
	// some vice flags
	public var isSelfish : Bool;
	public var isParano : Bool;
	public var isHallucinating : Bool;
	public var isAway : Bool;
	public var isAngry : Bool;
	public var ticks : Int;
	// used by viewer
	public var positionReset : Bool;
	// used to limit the player in pain
	public var headHurt : Bool;
	public var primaryArmHurt : Bool;
	public var secondaryArmHurt : Bool;
	public var chestHurt : Bool;
	public var legsHurt : Bool;
	// states data
	public var currentState : game.ai.PlayerState;
	public var targetPlayer : PlayerData;
	public var target : PVector3D;
	public var stuntTurns : Int;
	// support points
	var supportPoints : Array<SupportPoint>;
	var bestSupportPoints : Array<SupportPoint>;
	var bestSupportPointsLastUpdate : Int;
	// statistics
	public var stats : Stat;

	public function new( p:BasePlayer ){
		super(5.0, 2.0, 1.0);
		stats = new Stat();
		stuntTurns = 0;
		positionReset = false;
		isAway = false;
		isSelfish = false;
		isParano = false;
		isHallucinating = false;
		headHurt = primaryArmHurt = secondaryArmHurt = chestHurt = legsHurt = false;
		frictionFactor = Ball.GROUND_FRICTION * 1.1;
		id = p.id;
		pains = p.pains.copy();
		name = p.name;
		label = p.label;
		power = p.power;
		agility = p.agility;
		charisma = p.charisma;
		accuracy = p.accuracy;
		endurance = p.endurance;
		age = p.age;
		vices = p.vices;
		vicesList = Vice.list(vices);
		competences = p.competences;
		competencesList = Competence.list(competences);
		usedVices = p.usedVices;
		items = p.items;
		idx = 1;
		aggr = 30;
		morale = 0;
		moraleAttemptBonus = 0;
		maxLife = PlayerSkills.getMaxLife(this);
		life = maxLife;
		activeDrugs = new List();
		knockedOut = 0;
		allSkillModifier = 1;
		sprintPower = 0;
		isAngry = false;
		tmpItems = new List();
		competencesCooldown = new Hash();
	}

	public function getInventory() : { hammer:Item, head:Item, legs:Item, chest:Item, arm0:Item, belt:Array<Item> }{
		var result = {
			hammer:null,
			head:null,
			legs:null,
			chest:null,
			arm0:null,
			belt:[]
		};
		for (inventoryItem in items){
			if (inventoryItem.life <= 0)
				continue;
			var item = ItemDb.getById(inventoryItem.itemId);
			switch (item.family){
				case HAMMER:
					result.hammer = item;
				case ARMOR(part):
					switch (part){
						case _HEAD:
							result.head = item;
						case _LEGS:
							result.legs = item;
						case _CHEST:
							result.chest = item;
						case _ARM0,_ARM1:
							result.arm0 = item;
					}
				case DRUG:
					result.belt.push(item);
				case ORGAN(part):
					result.belt.push(item);
			}
		}
		return result;
	}

	public function getFullFace() : String {
		var VERSION = 1;
		var inventory = getInventory();
		return encodeSkinArray([
			VERSION,
			0,
			(inventory.hammer != null) ? inventory.hammer.faceId : 0,
			(inventory.legs   != null) ? inventory.legs.faceId   : 0,
			(inventory.arm0   != null) ? inventory.arm0.faceId   : 0,
			(inventory.head   != null) ? inventory.head.faceId   : 0,
			(inventory.chest  != null) ? inventory.chest.faceId  : 0,
		]);
	}

	static function encodeSkinArray( n:Array<Int> ) : String {
		var chk = 0;
		for (i in n)
			chk += i;
		var chkk = (chk & 0xFF) ^ (n[n.length-1] & n[1] ^ (n[2] & n[0]));
		var bytes = new haxe.io.BytesBuffer();
		for (i in 0...n.length){
			n[i] = n[i] ^ chkk;
			bytes.addByte(n[i]);
		}
		bytes.addByte(chkk);
		var bytes = bytes.getBytes();
		return tools.Base64.encodeBytes(bytes);
	}

	function decreaseCompetencesCooldown(){
		for (k in competencesCooldown.keys()){
			var v = competencesCooldown.get(k) - 1;
			if (v <= 0)
				competencesCooldown.remove(k);
			else
				competencesCooldown.set(k, v);
		}
	}

	/*
	  Knock the player out for the specified amount of attempts.
	 */
	public function knockOut( attempts:Int, ?forced=false ){
		// not forced, Unstuntable may prevent the KO
		if (!forced && triggerCompetence(Competence.get.Unstuntable)){
			resolver.event(CompetenceActive(this, Competence.get.Unstuntable));
			return;
		}
		if (knockedOut < 0)
			knockedOut = attempts;
		else
			knockedOut += attempts;
		// forced => another specific event should handle the KO information since it is not a regular fight
		if (!forced)
			resolver.event(Ko(this));
	}

	public function onNewAttempt(){
		decreaseCompetencesCooldown();
		attemptSprints = 0;
		moraleAttemptBonus = 0;
		if (tmpItems.length > 0){
			for (item in tmpItems)
				items.push(item);
			tmpItems = new List();
			computeSkills();
		}
		if (isAngry)
			isAngry = false;
		if (ingameVices != null && ingameVices.length > 0){
			for (v in ingameVices){
				if (v.cond(this)){
					v.chances = Std.int(Math.max(1, v.chances-1));
					if (waitingVice == null && resolver.randomInt(v.chances) == 0){
						waitingVice = v;
						ingameVices.remove(v);
					}
				}
			}
		}
		if (life < (maxLife-5) && triggerCompetence(Competence.get.Tireless)){
			updateLife(5);
			resolver.event(CompetenceActive(this, Competence.get.Tireless));
		}
		if (chestHurt && isOnField())
			updateLife(-1);
	}

	public function onPreThrow(){
		if (triggerCompetence(Competence.get.Chief)){
			for (p in team.players)
				p.moraleAttemptBonus += 1;
			resolver.event(CompetenceActive(this, Competence.get.Chief));
		}
		if (triggerCompetence(Competence.get.Insult)){
			var others = Lambda.array(others().players.filter(function(p) return p.isOnField()));
			var target = others[resolver.randomInt(others.length)];
			target.updateSpirit(-2);
			resolver.event(CompetenceActive2(this, target, Competence.get.Insult));
		}
		if (triggerCompetence(Competence.get.Fart)){
			var others = Lambda.array(others().players.filter(function(p) return p.isOnField()));
			var target = others[resolver.randomInt(others.length)];
			target.isAway = true;
			// TODO: a random might give more interesting results
			target.ticks = 5;
			resolver.event(CompetenceActive2(this, target, Competence.get.Fart));
		}
		if (triggerCompetence(Competence.get.Rascal)){
			var others = others().players.filter(
				function(p){
					return p.isOnField()
					&& (p.items.length > 0)
					&& Lambda.exists(p.items, function(i) return i.life > 0);
				}
			);
			var others = Lambda.array(others);
			var target = others[resolver.randomInt(others.length)];
			if (target != null){
				var item = target.getRandomItem();
				target.items.remove(item);
				target.tmpItems.push(item);
				target.computeSkills();
				resolver.event(CompetenceActive2(this, target, Competence.get.Rascal));
				competencesCooldown.set(Competence.get.Rascal.dbid, 9+resolver.randomInt(200));
			}
		}
		if (triggerCompetence(Competence.get.Saboter)){
			var others = others().players.filter(
				function(p){
					return p.isOnField()
					&& (p.items.length > 0)
					&& Lambda.exists(p.items, function(i) return i.life > 0);
				}
			);
			var others = Lambda.array(others);
			var target = others[resolver.randomInt(others.length)];
			if (target != null){
				var item = target.getRandomItem();
				item.life = Std.int(Math.max(0, item.life - 1));
				if (item.life <= 0)
					target.computeSkills();
				resolver.event(CompetenceActive2(this, target, Competence.get.Saboter));
				competencesCooldown.set(Competence.get.Saboter.dbid, 20+resolver.randomInt(600));
			}
		}
		if (resolver.prevAttemptDominators == team && triggerCompetence(Competence.get.Smile)){
			for (p in others().players)
				p.moraleAttemptBonus -= 1;
			resolver.event(CompetenceActive(this, Competence.get.Smile));
		}
	}

	public function onHalfTime(){
		if (triggerCompetence(Competence.get.Nap)){
			life = maxLife;
			resolver.event(CompetenceActive(this, Competence.get.Nap));
		}
		if (triggerCompetence(Competence.get.Bawdy)){
			for (p in team.players)
				p.updateSpirit(2);
			resolver.event(CompetenceActive(this, Competence.get.Bawdy));
		}
		if (triggerCompetence(Competence.get.Robber)){
			var avail = [];
			for (p in (resolver.teamA == team ? resolver.teamB : resolver.teamA).players)
				for (inv in p.items)
					if (inv.life > 0)
						avail.push({item:inv, owner:p});
			if (avail.length > 0){
				var i = avail[resolver.randomInt(avail.length)];
				i.owner.items.remove(i.item);
				team.stolenItems.push(i.item);
				resolver.event(CompetenceActive2(this, i.owner, Competence.get.Robber));
			}
		}
	}

	public function onRoundEnd(){
		if (triggerCompetence(Competence.get.Recovery)){
			var avail = [];
			for (i in 0...pains.length){
				var part : BodyPart = tools.EnumTools.fromIndex(BodyPart, i);
				if (pains[i] != null && injure != part)
					avail.push(part);
			}
			if (avail.length > 0){
				var p = avail[resolver.randomInt(avail.length)];
				pains[tools.EnumTools.indexOf(p)] = null;
				resolver.event(CompetenceActive(this, Competence.get.Recovery));
			}
		}
	}

	public function onGameOver(){
		if (injure != null && triggerCompetence(Competence.get.Recovery) && resolver.randomInt(100) < 50){
			var idx = tools.EnumTools.indexOf(injure);
			pains[idx] = injureLoc;
			injure = null;
			injureLoc = null;
			// TODO: we need a second message there
			resolver.event(CompetenceActive(this, Competence.get.Recovery));
		}
	}

	public inline function others() : Team {
		return (team != resolver.teamA ? resolver.teamA : resolver.teamB);
	}

	public function isRunningToBase() : Bool {
		return currentState == game.ai.RunToBase;
	}

	public function isOnField(){
		return canPlay() && Field.posToPoint(pos) != null;
	}

	public function getHammer() : IItem {
		var list = Lambda.filter(items, function(i) return i.life > 0);
		var list = Lambda.filter(list, function(i) return Std.is(Hammer,ItemDb.getById(i.itemId)));
		return list.first();
	}

	function getRandomItem() : IItem {
		var list = Lambda.filter(items, function(i) return i.life > 0);
		var list = Lambda.array(list);
		if (list.length == 0)
			return null;
		return list[resolver.randomInt(list.length)];
	}

	function findNotPainfulZone() : BodyPart {
		var avail = [];
		for (i in 0...pains.length){
			var part : BodyPart = tools.EnumTools.fromIndex(BodyPart, i);
			if (pains[i] == null && injure != part)
				avail.push(part);
		}
		return avail[resolver.randomInt(avail.length)];
	}

	// Called :
	// - before the game start,
	// - after the game is over,
	// - after each team fault
	// - after the pause
	// !this should not be called during the game!
	public function runVices(when:ViceWhen){
		if (activeVices == null)
			activeVices = new List();
		var opVices = Vice.list(usedVices);
		for (vice in Vice.list(vices)){
			if (vice.when == when){
				var pcent = vice.pcent;
				if (pcent == null)
					pcent = 100;
				if (vice.act != null && Lambda.has(opVices, vice))
					pcent += vice.act.pcent;
				if (resolver.roll() < pcent)
					if (!triggerVice(vice))
						break;
			}
		}
	}

	public function preselectInGameVices(){
		var result = new List();
		var opVices = Vice.list(usedVices);
		for (vice in Vice.list(vices)){
			if (vice.when == _InGame){
				var pcent = vice.pcent;
				if (pcent == null)
					pcent = 100;
				if (vice.act != null && Lambda.has(opVices, vice))
					pcent += vice.act.pcent;
				if (resolver.roll() < pcent){
					switch (vice){
						case Vice.get.CLAMMY:
							// only for hammer (attackers)
							// only 45 or 27 attack attempts
							result.push({ vice:vice, cond:function(p:PlayerData) return p.team == p.resolver.attTeam, chances:resolver.totalRounds*9 });

						case Vice.get.SOILING:
							result.push({ vice:vice, cond:function(p:PlayerData) return true, chances:90 });

						default:
							result.push({ vice:vice, cond:function(p:PlayerData) return true, chances:90 });
					}
				}
			}
		}
		ingameVices = result;
	}

	public function triggerCompetence( c:Competence ) : Bool {
		if (!c.canBetrigeredAtPos(pos))
			return false;
		if (!hasCompetence(c))
			return false;
		if (competencesCooldown.exists(c.dbid))
			return false;
		return (resolver.randomInt(100) < c.pcent);
	}

	public function triggerVice( vice:Vice ) : Bool {
		switch (vice){
			// AFTER GAME

			case Vice.get.CLEPTO: // activate here but resolve in db.Game

			case Vice.get.SORE_LOSER: // activate here but resolve in db.Game
				if (resolver.winner == team)
					return false;

			case Vice.get.COMPUL_SHOP: // activate here but resolve in db.Game

			case Vice.get.HYPOCON:
				hurt(false, true); // no armor

			case Vice.get.STAR:
				if (resolver.winner != team){
					return false;
				}
				var item = getRandomItem();
				if (item == null){
					return false;
				}
				item.life = 0;

			// BEFORE GAME

			case Vice.get.SCATTERBRAIN:
				var item = getRandomItem();
				if (item == null)
					return false;
				items.remove(item);

			case Vice.get.ELITIST:
				for (p in team.players)
					if (p.power < power)
						p.updateSpirit(-2);

			case Vice.get.ALCOOLIC:
				allSkillModifier *= 0.5;
				computeSkills();

			case Vice.get.CORRUPTIBLE:
				allSkillModifier *= 0.6;
				computeSkills();

			// DURING PAUSE

			case Vice.get.TEASER:
				var zone = findNotPainfulZone();
				if (zone == null)
					return false;
				hurt(zone);

			case Vice.get.JUNKY:
				for (i in items){
					var item = ItemDb.getById(i.itemId);
					if (Std.is(item, Drug) && i.life > 0){
						useDrug(i);
						return false;
					}
				}
				allSkillModifier *= 0.7;
				computeSkills();

			// AFTER OWN TEAM FAULT

			case Vice.get.REBEL:
				var kick = resolver.referee.power * 5;
				life = Std.int(Math.max(0, life-kick));
				resolver.event(ViceActive(this, vice));
				// referee hits with a hammer
				if (resolver.randomInt(100) < 2){
					knockOut(4);
				}
				return false;

			// DURING THE GAME

			case Vice.get.CLAMMY:
				// lost his hammer
				changeState(game.ai.ViceClammy);

			case Vice.get.SOILING:
				// fuite urinaire
				changeState(game.ai.ViceSoiling);

			case Vice.get.ABRA_SWEAT:
				var item = getRandomItem();
				if (item == null)
					return false;
				item.life--;

			case Vice.get.PARANO:
				isParano = true;

			case Vice.get.HALLUCINATE:
				isHallucinating = true;

			case Vice.get.AWAY:
				isAway = true;
				ticks = 30 + resolver.randomInt(50);

			default:
		}
		activeVices.push(vice);
		resolver.event(ViceActive(this, vice));
		return true;
	}

	public function isInjured() : Bool {
		return injure != null;
	}

	public function updateAway() : Bool {
		if (!isAway)
			return false;
		if (--ticks <= 0)
			isAway = false;
		return isAway;
	}

	public function getLifeFactor() : Float {
		if (life <= 0)
			return 0.5;
		return 1.0;
	}

	public function isAttacker() : Bool {
		return resolver.attTeam == team;
	}

	public function updateLife( modifier:Int, drug:Bool=false ){
		if (chestHurt && modifier > 0){
			if (!drug)
				return;
			modifier = Math.round(modifier / 2);
		}
		var old = life;
		life = Std.int(Math.min(maxLife, Math.max(0, life + modifier)));
		if ((old <= 0 && life > 0) || (old > 0 && life <= 0))
			computeSkills();
	}

	public function updateSpirit( modifier:Float, ?proba:Int=100 ){
		if (proba >= 100 || resolver.randomInt(100) < proba){
			if (modifier < 0 && hasVice(Vice.get.DEPRESSIVE))
				modifier *= 2;
			morale += modifier;
		}
	}

	public function getMoraleFactor() : Float {
		// the factor varies between 0.7 and 1.3 depending of the morale carac
		return 1.0 + Math.max(-3, Math.min((morale + moraleAttemptBonus), 3))*0.1;
	}

	public function getAttractPicoronFactor() : Float {
		return 4 * (skillAttractPicoron / 100) - 2;
	}

	public function drugTime(){
		for (i in items){
			if (i.life <= 0)
				continue;
			var item = ItemDb.getById(i.itemId);
			if (!Std.is(item, Drug))
				continue;
			else if (item == ItemDb.get.HP){
				if (life/maxLife <= 0.50)
					return useDrug(i);
			}
			else if (item == ItemDb.get.PATEE){
				if (life/maxLife <= 0.20)
					return useDrug(i);
			}
			else if (item == ItemDb.get.MORALE){
				if (morale < 0 || (morale == 0 && resolver.randomInt(100) < 10))
					return useDrug(i);
			}
			else if (item == ItemDb.get.AGGR){
				if (aggr < 20 && resolver.randomInt(100) < 10)
					return useDrug(i);
			}
		}
		return null;
	}

	public function useDrug( i:IItem ){
		var drug : Drug = cast ItemDb.getById(i.itemId);
		if (i.life <= 0)
			throw "No more shot";
		if (Lambda.exists(activeDrugs, function(ad) return ad.drug == drug))
			throw "Already active";
		i.life--;
		resolver.event(UseDrug(this, drug));
		for (e in drug.effects){
			switch (e){
				case _IncSkill(c):
					activeDrugs.push({ drug:drug, time:drug.duration });
					PlayerSkills.applyItemCarac(this, c);
				case _IncLife(v):
					updateLife(v, true);
				case _IncMorale(v):
					updateSpirit(v);
				case _IncAggr(v):
					addAggr(v);
				case _None:
			}
		}
		if (resolver.state != GameState.NEW_ATTEMPT){
		}
		else if (resolver.fault != null){
		}
		else if (triggerCompetence(Competence.get.QuickDrug)){
			resolver.event(CompetenceActive(this, Competence.get.QuickDrug));
		}
		else {
			stats.count(GenFault);
			var notSeen = resolver.rollAndComment(bonusHideFault * getMoraleFactor()).success;
			if (notSeen){
				resolver.event(DrugFault(false, this, drug));
			}
			else {
				stats.success(GenFault);
				resolver.fault = { team:team.id, player:this.id };
				resolver.event(DrugFault(true, this, drug));
			}
		}
	}

	public function getInjureFactor() : Float {
		return if (life <= CRITIC_LIFE) 2 else if (life <= WARN_LIFE) 1.5 else 1.0;
	}

	// When you have 50% of fault chances, multiply theses chances with getHideFaultFactor()
	// to apply the player factor to the result.
	public function getHideFaultFactor() : Float {
		return (100 - (bonusHideFault * getMoraleFactor())) / 100;
	}

	public function computeSkills(){
		game.PlayerSkills.compute(
			this,
			resolver.defTeam,
			resolver.referee,
			allSkillModifier,
			life,
			team,
			items,
			activeDrugs,
			pains
		);
	}

	public function getArmor( part:BodyPart ) : IItem {
		for (i in items){
			var item = ItemDb.getById(i.itemId);
			if (Std.is(item, Armor) && (cast item).bodyPart == part)
				return i;
		}
		return null;
	}

	public function reset(){
		isSelfish = false;
		currentState = null;
		supportPoints = null;
		bestSupportPoints = null;
		stop();
	}

	public function isAggressive() : Bool {
		return resolver.roll() < aggr;
	}

	public function delAggr( v:Int ){
		aggr = Std.int(Math.max(0, aggr - v));
	}

	public function addAggr( v:Int ){
		aggr = Std.int(Math.min(100, aggr+v));
	}

	public function setPos( p:Point ){
		positionReset = true;
		if (p == null){
			x = team.x;
			y = team.y;
		}
		else {
			x = p.x;
			y = p.y;
		}
	}

	public function hasVice( vice:Vice ) : Bool {
		if (vices == null)
			return false;
		return Lambda.has(vicesList, vice);
	}

	public function hasCompetence( comp:Competence ) : Bool {
		if (competences == null)
			return false;
		return Lambda.has(competencesList, comp);
	}

	public function getPassLengthEstimation() : Float {
		return 2.5 * power * 4;
	}

	public function hurt( ?where:BodyPart, ?forceInjure:Bool=false, ?ignoreArmor:Bool=false ){
		var loc = where;
		var realLoc = loc;
		var preventInjure = triggerCompetence(Competence.get.FlexiBones);
		if (loc == null){
			var locs = [ BodyPart._HEAD, BodyPart._ARM0, BodyPart._CHEST, BodyPart._LEGS ];
			if (triggerCompetence(Competence.get.Defensive)){
				var armors = [
					getArmor(BodyPart._HEAD),
					getArmor(BodyPart._ARM0),
					getArmor(BodyPart._CHEST),
					getArmor(BodyPart._LEGS)
				];
				if (tools.LambdaTools.count(armors, function(i) return (i != null && i.life > 0)) > 0){
					for (i in 0...armors.length){
						if (armors[i] == null || armors[i].life == 0){
							locs.splice(i,1);
						}
					}
				}
			}
			loc = locs[resolver.randomInt(locs.length)];
			realLoc = loc;
			if (loc == BodyPart._ARM0 && resolver.randomInt(2) == 0)
				realLoc = BodyPart._ARM1;
		}
		// X
		var idx = tools.EnumTools.indexOf(realLoc);
		var pain = pains[idx];
		if (pain == null && forceInjure && !preventInjure)
			pain = Organ.random(realLoc, resolver.randomizer).dbid;
		// armor protection
		var armor = ignoreArmor ? null : getArmor(loc);
		if (armor != null && armor.life > 0){
			if (pain != null || resolver.roll() < 50) // 50% structure lost for small pains
				armor.life--;
			if (armor.life <= 0){
				computeSkills();
				resolver.event(ItemDestroyed(this));
			}
			else {
				resolver.event(ItemDamaged(this));
			}
			return;
		}
		if (pain == null){
			var o = Organ.random(realLoc, resolver.randomizer);
			if (o == null)
				throw "Unable to get a random organ at "+realLoc;
			pains[idx] = o.dbid;
			computeSkills();
			resolver.event(Bobo(this, o));
		}
		else if (!preventInjure){
			injure = realLoc;
			injureLoc = pain;
			resolver.event(Injure(this, cast ItemDb.getById(pain)));
		}
		else {
			resolver.event(CompetenceActive(this, Competence.get.FlexiBones));
		}
	}

	public function getDangerCircle() {
		var circle = new CircleList({danger:0.0, player:null});
		var foes = foesByDistance();
		var list = new List();
		for (foe in foes)
			list.push(foe);
		foes = Lambda.array(list);
		for (foe in foes){
			var dist = position.distance(foe.position);
			if (dist > 60)
				continue;
			var len = Math.PI/(0.3*dist);
			var angle = new CircleItem(angle(foe)-len/2, len, {danger:(60-dist)/60, player:foe} );
			circle.insert(angle);
		}
		return circle;
	}

	public function getMaxMoveSpeed() : Float {
		return
			MAX_SPEED
			* (skillSpeed / 100)
			* ((resolver.ball.owner == this) ? 0.75 : 1)
			;
	}

	override public function seek(p:geom.Pt3D, ?m:Float=1.0){
		if (!resolver.throwerMoved && resolver.thrower == this)
			resolver.throwerMoved = true;
		super.seek(p,m);
	}

	override public function update(){
		if (resolver.isOutField(resolver.ball.position))
			return;
		if (currentState == null)
			changeState(game.ai.IdleState);
		if (sprintPower == 0 && SPRINTS_PER_ATTEMPT > attemptSprints && life > SPRINT_COST && life > SAFE_LIFE && steering.lengthSquared() > 1){
			attemptSprints++;
			life -= SPRINT_COST;
			sprintPower = SPRINT_TICKS;
			if (hasCompetence(Competence.get.Runner))
				sprintPower = Math.round(sprintPower * 1.5);
			if (hasCompetence(Competence.get.Sprinter))
				maxSpeed = getMaxMoveSpeed() * 1.5;
			else
				maxSpeed = getMaxMoveSpeed() * 1.25;
		}
		else if (sprintPower > 0){
			sprintPower--;
		}
		else if (life < WARN_LIFE){
			maxSpeed = getMaxMoveSpeed() * 0.75;
		}
		else {
			maxSpeed = getMaxMoveSpeed();
		}
		paranoia();
		currentState.update(this);
		super.update();
	}

	function paranoia(){
		if (!isParano)
			return;
		var friends = friends();
		resolver.field.sortDistances(idx, friends);
		var leaveParanoia = 0.5;
		var nearest = friends[1]; // 0 should be me
		if (nearest != null && nearest.distanceToPlayer(this) <= PlayerData.FIGHT_DIST){
			switch (pos){
				case Def(p):
					targetPlayer = nearest;
					changeState(game.ai.AttackPlayer);
					if (resolver.random() > leaveParanoia)
						isParano = false;

				case Att(p):
					targetPlayer = nearest;
					changeState(game.ai.AttackPlayer);
					if (resolver.random() > leaveParanoia)
						isParano = false;

				case Bat:
			}
		}
	}

	public function loseBall() : Bool {
		if (resolver.ball.owner != this)
			return false;
		resolver.ball.owner = null;
		if (team.leader == this)
			team.leader = null;
		return true;
	}

	function hallucinate(){
		if (!isHallucinating)
			return;
		/*
		  TODO:
		  Problem with this kind of implementation, hallucinate will be called on each frame and will reset state.
		  We need to find another way to do that.
		*/
		/*
		  var players = friends();
		  players.contact(foes());
		  players.remove(this);
		  resolver.field.sortDistances(idx, players);
		  var ball = resolver.ball;
		  var ballDist = ball.position.distance(position);
		  if (ballDist <= FIGHT_DIST){
		  changeState(game.ai.AttackBall);
		  }
		  else if (players[0].distanceToPlayer(this) <= FIGHT_DIST){
		  targetPlayer = players[0];
		  changeState(game.ai.AttackPlayer);
		  }
		  else if (players[0].distanceToPlayer(this) <= 3*FIGHT_DIST){
		  targetPlayer = players[0];
		  changeState(game.ai.ChasePl
		  }
		*/
	}

	public function canPlay() : Bool {
		return !isInjured() && knockedOut <= 0;
	}

	function canInterceptPass(to:PVector3D, foe:PlayerData, ?receiver:PlayerData){
		var meToTarget = to.clone().distance(this.position);
		var foeToTarget = to.clone().distance(foe.position);
		if (foe.insideRectangle(this.position, to))
			return true;
		if (foeToTarget / foe.agility < meToTarget / power)
			return true;
		var mid = to.clone().add(position).div(2);
		if (mid.distance(foe.position)/foe.agility <= mid.distance(this.position)/power)
			return true;
		if (receiver == null)
			return false;
		if (mid.distance(foe.position)/foe.agility <= mid.distance(receiver.position)/receiver.agility)
			return true;
		return false;
		// TODO test foe behind me relatively to the target
		// return (himToTarget.magnitude() < meToTarget.magnitude());
	}

	function isPassSafeFromAllOpponents(p, ?receiver:PlayerData){
		for (foe in foes())
			if (canInterceptPass(p, foe, receiver))
				return false;
		return true;
	}

	function canSavePicoron(p:PVector3D){
		return p.length() <= 30;
	}

	function getSupportPositions() : Array<SupportPoint> {
		// [ N NO O SO S SE E NE ]
		var passD = Math.min(20, getPassLengthEstimation());
		var south = new PVector3D(0, passD);
		var southWest = south.clone().rotateZ(-Math.PI/4);
		var west = southWest.clone().rotateZ(-Math.PI/4);
		var northWest = west.clone().rotateZ(-Math.PI/4);
		var north = new PVector3D(0, -passD);
		var northEast = north.clone().rotateZ(-Math.PI/4);
		var east = northEast.clone().rotateZ(-Math.PI/4);
		var southEast = east.clone().rotateZ(-Math.PI/4);
		var pos = [
			north.add(this.position),
			northWest.add(this.position),
			west.add(this.position),
			southWest.add(this.position),
			south.add(this.position),
			southEast.add(this.position),
			east.add(this.position),
			northEast.add(this.position),
		];
		if (supportPoints != null)
			for (i in 0...pos.length)
				supportPoints[i].set(pos[i]);
		else {
			supportPoints = amap(pos, function(p) return new SupportPoint(p.x, p.y));
			supportPoints[0].name = "N";
			supportPoints[1].name = "NW";
			supportPoints[2].name = "W";
			supportPoints[3].name = "SW";
			supportPoints[4].name = "S";
			supportPoints[5].name = "SE";
			supportPoints[6].name = "E";
			supportPoints[7].name = "NE";
		}
		return supportPoints;
	}

	public function getBestSupportPoints() : Array<SupportPoint> {
		if (bestSupportPoints != null && bestSupportPointsLastUpdate == resolver.time)
			return bestSupportPoints;
		var points = getSupportPositions().copy();
		for (p in points){
			p.score = 0;
			if (resolver.isOutField(p) || p.length() >= 100){
				continue;
			}
			if (isPassSafeFromAllOpponents(p)){
				p.score += 2;
			}
			else {
				p.score -= 1;
			}
			if (canSavePicoron(p)){
				p.score += 1;
			}
			// the nearest to origin the better
			p.score += (1 - (p.length()/100));
		}
		points.sort(function(a,b){
			var cmp = -Reflect.compare(a.score, b.score);
			if (cmp != 0)
				return cmp;
			cmp = Reflect.compare(a.x, b.x);
			if (cmp != 0)
				return cmp;
			cmp = Reflect.compare(a.y, b.y);
			if (cmp != 0)
				return cmp;
			return Reflect.compare(a.name, b.name);
		});
		bestSupportPoints = points;
		bestSupportPointsLastUpdate = resolver.time;
		return points;
	}

	public function getNearestFriend(?p:PVector3D) : PlayerData {
		if (p == null)
			p = position;
		var friends = friends();
		friends.remove(this);
		var bestFriend = null;
		var bestDist = 99999.0;
		for (f in friends){
			var dist = f.position.distance(p);
			if (dist < bestDist){
				bestDist = dist;
				bestFriend = f;
			}
		}
		return bestFriend;
	}

	public function findPass(){
		var minPassDistance = 5; // too near is not interesting
		var result : { player:PlayerData, dest:PVector3D } = null;
		var bestDistanceToGoal = 99999999.9;
		for (p in friends()){
			if (p == this)
				continue;
			if (this.position.distance(p.position) < minPassDistance)
				continue;
			var target = findBestPass(p);
			if (target != null){
				var distToGoal = target.length();
				if (distToGoal < bestDistanceToGoal){
					result = {
						player: p,
						dest: target
					};
					var passRoll = (resolver.roll() - skillPassBall);
					// passRoll = 0;
					if (passRoll > 0){
						var noise = new PVector3D(passRoll / 4, 0, 0);
						var angle = Math.PI*2*resolver.random();
						noise.rotateZ(angle);
						result.dest.add(noise);
					}
					bestDistanceToGoal = distToGoal;
				}
			}
		}
		return result;
	}

	public function findBestPass( p ) : PVector3D {
		var time = 3;
		// will the player be able to receive the ball ?
		// we assume that the player will be able to move 3 times
		if (distanceToPlayer(p) - p.agility*time > getPassLengthEstimation())
			return null;
		var range = p.agility * time * 0.3;
		var tangents = PVector3D.getTangents(p.position, range, this.position);
		tangents.push(p.position.clone());
		var bestDist = 9999999.9;
		var bestPoint = null;
		for (point in tangents){
			var dist = point.lengthSquared();
			if (dist < bestDist && dist < 100*100 && !resolver.isOutField(point)){
				if (isPassSafeFromAllOpponents(point, p)){
					bestDist = dist;
					bestPoint = point;
				}
			}
		}
		return bestPoint;
	}

	static function amap<T,A>( array:Array<T>, f:T->A ) : Array<A> {
		var res = new Array();
		for (a in array)
			res.push(f(a));
		return res;
	}

	static function filter<T>( array:Array<T>, f:T->Bool ) : Array<T> {
		var res = new Array();
		for (a in array)
			if (f(a))
				res.push(a);
		return res;
	}

	public function distanceToNearestFoe() : Float {
		return resolver.field.distance(idx, foesByDistance()[0].idx);
	}

	public function friends() : Array<PlayerData> {
		var result = switch (pos){
			case Bat:    [ resolver.field.batt, resolver.field.attL, resolver.field.attR ];
			case Att(p): [ resolver.field.batt, resolver.field.attL, resolver.field.attR ];
			case Def(p): [ resolver.field.thro, resolver.field.defF, resolver.field.defL, resolver.field.defM, resolver.field.defR ];
			default: [];
		}
		while (result.remove(null)){}
		return Lambda.array(Lambda.filter(result, function(p) return p.canPlay()));
	}

	public function foes() : Array<PlayerData> {
		var result = switch (pos){
			case Bat:    [ resolver.field.thro, resolver.field.defF, resolver.field.defL, resolver.field.defM, resolver.field.defR ];
			case Att(p): [ resolver.field.thro, resolver.field.defF, resolver.field.defL, resolver.field.defM, resolver.field.defR ];
			case Def(p): [ resolver.field.batt, resolver.field.attL, resolver.field.attR ];
			default: [];
		}
		while (result.remove(null)){}
		return Lambda.array(Lambda.filter(result, function(p) return p.canPlay()));
	}

	public function foesByDistance() : Array<PlayerData> {
		var foes = foes();
		resolver.field.sortDistances(idx, foes);
		return foes;
	}

	public function isBallInDanger() : Bool {
		var d = distanceToBall();
		var foes = foes();
		for (foe in foes)
			if (foe.distanceToBall()/agility < 0.8 * d/agility)
				return true;
		return false;
	}

	public function changeState(sm:game.ai.PlayerState){
		if (currentState != null)
			currentState.leave(this);
		currentState = sm;
		if (currentState != null)
			currentState.enter(this);
	}

	public function getState() : String {
		if (currentState == null)
			return null;
		return currentState.toString(this);
	}

	public function passToPlayer( player:PlayerData, ?target:PVector3D ) : Bool {
		if (isSelfish || hasVice(Vice.get.SELFISH) && resolver.randomInt(100) < Vice.get.SELFISH.pcent){
			isSelfish = true;
			resolver.event(ViceActive(this, Vice.get.SELFISH));
			return false;
		}
		this.target = target;
		this.targetPlayer = player;
		this.changeState(game.ai.PassToPlayer);
		return true;
	}

	public function ballContactState() : game.ai.PlayerState {
		switch (pos){
			case Att(p): return game.ai.AttackBall;
			case Def(p): return game.ai.TakeBall;
			case Bat:    return game.ai.AttackBall;
			default: return null;
		}
	}

	public function contactPlayer( p:PlayerData, ?extraAggressive=false ){
		targetPlayer = p;
		if (p.power < power && p.triggerCompetence(Competence.get.Pitify)){
			resolver.event(CompetenceActive2(p, this, Competence.get.Pitify));
			changeState(game.ai.PushPlayer);
			return;
		}
		if (isAggressive() || (extraAggressive && p.power * 0.7 <= power))
			changeState(game.ai.AttackPlayer);
		else
			changeState(game.ai.PushPlayer);
	}

	function canSupport() : Bool {
		return (currentState == game.ai.SupportRun) || (currentState == game.ai.IdleState);
	}

	public function selectSupportPoint( player:PlayerData ){
		if (player == null)
			return false;
		var possibilities = [];
		var friends = friends();
		friends.remove(player);
		for (f in friends)
			if (f != this && !f.canSupport())
				friends.remove(f);
		var points = player.getBestSupportPoints();
		for (p in points)
			if (p.reservation == null && p.getNearest(friends) == this && p.score > 0)
				possibilities.push(p);
		var nearest = possibilities[0];
		if (nearest == null){
			for (p in points)
				if (p.reservation == null && p.score > 0){
					nearest = p;
					break;
				}
		}
		if (nearest == null){
			for (p in points)
				if (p.reservation == null){
					nearest = p;
					break;
				}
		}
		if (nearest != null){
			targetPlayer = player;
			reservedSupport = nearest;
			changeState(game.ai.MoveToSupportPoint);
			return true;
		}
		return false;
	}

	// Some PVector like methods

	inline public function moveAngle(angle:Float, power:Float){
		var p = position.clone();
		p.x += power/2;
		p.rotateZ(angle);
		p.sub(position);
		velocity.add(p);
	}

	inline public function moveToward(pt, speed:Float){
		moveAngle(position.angleZ(pt), speed);
	}

	inline public function angle( p ) : Float {
		return position.angleZ(p.position);
	}

	inline public function insideRectangle(a, b) : Bool {
		return position.insideRectangle(a, b);
	}

	// Blah blah blah methods

	inline public function hasBall() : Bool {
		return resolver.ball.owner == this;
	}

	inline public function isThrower() : Bool {
		return resolver.field.thro == this;
	}

	inline public function distanceToBall() : Float {
		return resolver.field.distance(1, idx);
	}

	inline public function distanceToPlayer( p:PlayerData ) : Float {
		return resolver.field.distance(idx, p.idx);
	}

	inline public function distanceToOrigin() : Float {
		return resolver.field.distance(0, idx);
	}

	override public function toString() : String {
		return "#"+id+"@"+pos+" '"+(label != null ? label : name)+"' "+super.toString();
	}
}