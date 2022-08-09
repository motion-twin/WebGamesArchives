package game;
import game.PlayerData;
import Item;
import game.InitialData;

typedef P = {
	public var skillPowerThrow : Int;
	public var skillSpeedThrow : Int;
	public var skillCurveThrow : Int;
	public var skillPowerReception : Int;
	public var skillSpeedReception : Int;
	public var skillCurveReception : Int;
	public var allSkillModifier : Float;
	private var bonusHideFault : Int;
	public var skillAttractPicoron : Float;
	public var skillKillBall : Int;
	public var skillCatchBall : Int;
	public var skillThrowPrecision : Int;
	public var skillBatterPrecision : Int;
	public var skillBatterPower : Int;
	public var skillPassBall : Int;
	public var skillInitiative : Int;
	public var skillAttack : Int;
	public var skillPush : Int;
	public var skillEsquive : Int;
	public var skillSpeed : Int;
	public var maxLife : Int;
	public var hurtBonus : Int;
};

class PlayerSkills {
	static inline function skill( v:Float, allSkillModifier:Float, life:Int ) : Int {
		var v = Math.round(allSkillModifier * Math.max(0, v) * (life > 0 ? 1 : 0.5));
		return Std.int(Math.min(100, v));
	}

	public static function getMaxLife( p:PlayerData ){
		var v = 20 + (10 * p.endurance);
		if (p.hasCompetence(Competence.get.Vitality))
			v += 50;
		return v;
	}

	public static function applyItemCarac( p:P, c:_ItemCarac, malusFactor=1.0 ){
		var value = function(v){
			if (v < 0)
				return Math.round(v * malusFactor);
			return v;
		}
		switch (c){
			case _None:
			case _AllThrows(v):
				p.skillSpeedThrow += value(v);
				p.skillCurveThrow += value(v);
				p.skillPowerThrow += value(v);
			case _AllReceptions(v):
				p.skillSpeedReception += value(v);
				p.skillCurveReception += value(v);
				p.skillPowerReception += value(v);
			case _SpeedReception(v): p.skillSpeedReception += value(v);
			case _CurveReception(v): p.skillCurveReception += value(v);
			case _PowerReception(v): p.skillPowerReception += value(v);
			case _SpeedThrow(v): 	 p.skillSpeedThrow += value(v);
			case _CurveThrow(v): 	 p.skillCurveThrow += value(v);
			case _PowerThrow(v): 	 p.skillPowerThrow += value(v);
			case _ThrowPrecision(v): p.skillThrowPrecision += value(v);
			case _Push(v): 			 p.skillPush += value(v);
			case _Attack(v): 		 p.skillAttack += value(v);
			case _KillBall(v):       p.skillKillBall += value(v);
			case _Initiative(v):     p.skillInitiative += value(v);
			case _HideFault(v):      p.bonusHideFault += value(v);
			case _Esquive(v):        p.skillEsquive += value(v);
			case _PassBall(v):       p.skillPassBall += value(v);
			case _CatchBall(v):      p.skillCatchBall += value(v);
			case _BatPrecision(v):   p.skillBatterPrecision += value(v);
			case _BatPower(v):       p.skillBatterPower += value(v);
			case _Speed(v):          p.skillSpeed += value(v);
			case _AttractPico(v):    p.skillAttractPicoron += value(v);
			case _Hurt(v):           p.hurtBonus += value(v);
		}
	}

	/*
	  This method was previously in PlayerData.

	  We extracted it here so the WEBSITE can also use it on a regular db.Player / IPlayer to present the skills to users.

	  TODO: cleanup the arguments mess :)
	 */
	public static function compute(
		p:PlayerData,
		defTeam:game.Team,
		referee:IReferee,
		allSkillModifier=1.0,
		life=100,
		team:game.Team,
		items:List<IItem>,
		activeDrugs:List<{drug:Drug, time:Int}>,
		pains:Array<Null<OrganId>>
	){
		p.hurtBonus = 0;
		p.headHurt = p.primaryArmHurt = p.secondaryArmHurt = p.chestHurt = p.legsHurt = false;
		untyped p.bonusHideFault = Math.round(
			(team == null ? 0.0 : team.corruptBonus)
			+ (p.charisma * 5)
			+ (referee == null ? 0.0 : ((p.hasCompetence(Competence.get.Intimidate) && referee.power    < p.power)    ? 15 : 0))
			+ (referee == null ? 0.0 : ((p.hasCompetence(Competence.get.Innocent)   && referee.charisma < p.charisma) ? 15 : 0))
			+ (referee == null ? 0.0 : ((p.hasCompetence(Competence.get.QuickPunch) && referee.agility  < p.agility)  ? 15 : 0))
			+ (referee == null ? 0.0 : ((p.hasCompetence(Competence.get.StealPunch) && referee.accuracy < p.accuracy) ? 15 : 0))
		);
		p.maxLife = getMaxLife(p);
		p.skillKillBall = Math.round(
			20
			+ (p.power * 4 + p.charisma * 3)
			+ (p.hasCompetence(Competence.get.Crusher) ? 15 : 0)
		);
		p.skillPassBall = Math.round(
			20
			+ (p.accuracy * 6)
			+ (p.hasCompetence(Competence.get.Passer) ? 15 : 0)
		);
		p.skillCatchBall = Math.round(
			20
			+ (p.agility * 3 + p.charisma * 3)
		);
		p.skillThrowPrecision = (
			25
			+ (p.accuracy * 6)
		);
		p.skillPowerThrow = (
			30
			+ (p.power * 5)
			+ (p.hasCompetence(Competence.get.PowerThrow) ? 15 : 0)
		);
		p.skillSpeedThrow = (
			30
			+ (p.agility * 5)
			+ (p.hasCompetence(Competence.get.SpeedThrow) ? 15 : 0)
		);
		p.skillCurveThrow = (
			30
			+ (p.accuracy * 5)
			+ (p.hasCompetence(Competence.get.CurveThrow) ? 15 : 0)
		);
		p.skillPowerReception = (
			30
			+ (p.agility * 5)
		);
		p.skillSpeedReception = (
			30
			+ (p.accuracy * 5)
		);
		p.skillCurveReception = (
			30
			+ (p.power * 5)
		);
		p.skillBatterPrecision = (
			30
			+ (p.accuracy * 5)
			+ (p.hasCompetence(Competence.get.Batter) ? 15 : 0)
		);
		p.skillBatterPower = (
			20
			+ (p.power * 5)
		);
		p.skillInitiative = (
			20
			+ (p.agility * 5)
		);
		p.skillAttack = (
			20
			+ (p.power * 5)
		);
		p.skillPush = (
			30
			+ (p.endurance * 4)
		);
		p.skillEsquive = (
			0
			+ (p.agility * 5)
			+ (p.hasCompetence(Competence.get.Esquive) ? 20 : 0)
		);
		p.skillSpeed = (
			20
			+ (p.agility * 6)
			+ (p.hasCompetence(Competence.get.Fast) ? 20 : 0)
		);
		p.skillAttractPicoron = (
			0
			+ (p.charisma * 5)
			+ (p.hasCompetence(Competence.get.Melody) ? 50 : 0)
			+ (p.hasVice(Vice.get.SWEAT) ? -50 : 0)
		);
		for (i in items){
			var item = ItemDb.getById(i.itemId);
			if (item == null)
				throw "Item "+i.itemId+" not found...";
			// do not apply hammers' caracs to defenders
			if (defTeam == team && Std.is(item, Hammer))
				continue;
			if (!Std.is(item, Drug) && item.caracs != null && i.life > 0)
				for (carac in item.caracs)
					applyItemCarac(p, carac, Std.is(item,Armor) && p.hasCompetence(Competence.get.Hefty) ? 0.5 : 1.0);
		}
		for (ad in activeDrugs)
			if (ad.time <= 0)
				activeDrugs.remove(ad);
			else
				for (effect in ad.drug.effects)
					switch (effect){
						case _IncSkill(c):
							applyItemCarac(p, c);
						default:
							// other drug effects do not modify skills
					}
		for (i in 0...pains.length){
			if (pains[i] != null){
				var part : BodyPart = tools.EnumTools.fromIndex(BodyPart, i);
				switch (part){
					case _HEAD:
						p.headHurt = true;
					case _ARM0:
						p.primaryArmHurt = true;
					case _ARM1:
						p.secondaryArmHurt = true;
					case _CHEST:
						// -1 souffle par tentative
						p.chestHurt = true;
					case _LEGS:
						p.legsHurt = true;
				}
			}
		}
		// Do not forget to modify help.mtt accordingly
		untyped p.bonusHideFault = skill(p.bonusHideFault, allSkillModifier, life);
		p.skillKillBall = skill(p.skillKillBall * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0) +
			(p.secondaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillPassBall = skill(p.skillPassBall * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillCatchBall = skill(p.skillCatchBall * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillThrowPrecision = skill(p.skillThrowPrecision * (1 - (
			(p.headHurt ? 0.5 : 0.0))), allSkillModifier, life);
		p.skillPowerThrow = skill(p.skillPowerThrow * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillSpeedThrow = skill(p.skillSpeedThrow * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillCurveThrow = skill(p.skillCurveThrow * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillPowerReception = skill(p.skillPowerReception * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0) +
			(p.secondaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillSpeedReception = skill(p.skillSpeedReception * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0) +
			(p.secondaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillCurveReception = skill(p.skillCurveReception * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0) +
			(p.secondaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillBatterPrecision = skill(p.skillBatterPrecision, allSkillModifier, life);
		p.skillBatterPower = skill(p.skillBatterPower * (1 - (
			(p.primaryArmHurt ? 0.3 : 0.0))), allSkillModifier, life);
		p.skillInitiative = skill(p.skillInitiative * (1 - (
			(p.headHurt ? 0.5 : 0.0))), allSkillModifier, life);
		p.skillAttack = skill(p.skillAttack, allSkillModifier, life);
		p.skillPush = skill(p.skillPush, allSkillModifier, life);
		p.skillEsquive = skill(p.skillEsquive * (1 - (
			(p.legsHurt ? 0.85 : 0.0))), allSkillModifier, life);
		p.skillSpeed = skill(p.skillSpeed * (1 - (
			(p.legsHurt ? 0.85 : 0.0))), allSkillModifier, life);
		p.skillAttractPicoron = skill(p.skillAttractPicoron, allSkillModifier, life);
	}
}
