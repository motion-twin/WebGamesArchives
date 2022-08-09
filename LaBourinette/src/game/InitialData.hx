package game;

import GameParameters;

typedef InitialData = {
	var seed : Int;
	var paramA : Parameters;
	var teamA : List<BasePlayer>;
	var teamNameA : String;
	var corruptA : Int;
	var paramB : Parameters;
	var teamB : List<BasePlayer>;
	var teamNameB : String;
	var corruptB : Int;
	var referee : IReferee;
	var hooligansA : List<IHooligan>;
	var hooligansB : List<IHooligan>;
	var totalRounds : Null<Int>;
};

/*
  We serialize the game initial state using the following structures and typedef.
 */

typedef DrugId = String;
typedef OrganId = String;
typedef ViceId = String;
typedef CompetenceId = String;
typedef IVices = String;
typedef ICompetences = String;

typedef IPoint = {
	public var x : Float;
	public var y : Float;
};

typedef IItem = {
	public var id : Int;
	public var itemId : String;
	public var life : Int;
};

typedef IReferee = {
	public var id : Int;
	public var name : String;
	public var power : Int;
	public var agility : Int;
	public var charisma : Int;
	public var accuracy : Int;
	public var endurance : Int;
};

typedef IHooligan = {
	public var id : Int;
	public var name : String;
	public var level : Int;
};

class BasePlayer {
	public var id : Int;
	public var name : String;
	public var label : String;
	public var power : Int;
	public var agility : Int;
	public var charisma : Int;
	public var accuracy : Int;
	public var endurance : Int;
	public var age : Int;
	public var life : Int;
	public var maxLife : Int;
	public var vices : IVices;
	public var usedVices : IVices;
	public var items : List<IItem>;
	public var competences : ICompetences;
	public var pains : Array<OrganId>;
	public var injure : BodyPart;
	public var injureLoc : OrganId;
	#if neko
	public function new(p:db.Player){
		id = p.id;
		name = p.name;
		label = p.label;
		power = p.power + p.getCaracTraining(Carac.Power);
		agility = p.agility + p.getCaracTraining(Carac.Agility);
		charisma = p.charisma + p.getCaracTraining(Carac.Charisma);
		accuracy = p.accuracy + p.getCaracTraining(Carac.Accuracy);
		endurance = p.endurance + p.getCaracTraining(Carac.Endurance);
		age = p.age;
		maxLife = 100;
		life = 100;
		vices = p.vices;
		competences = p.competences;
		usedVices = null;
		items = Lambda.map(db.Inventory.ofPlayer(p), function(i) return { id:i.id, itemId:i.itemId, life:i.life });
		var idx = 0;
		pains = [];
		for (radio in p.getRadio()){
			if (radio.hurt)
				pains[idx] = radio.organ.dbid;
		    else if (radio.injured)
				injure = radio.part;
			++idx;
		}
	}

	public function hasCompetence( comp:Competence ) : Bool {
		if (competences == null)
			return false;
		return competences.indexOf(comp.dbid+",") != -1;
	}

	public function hasVice( vice:Vice ) : Bool {
		if (vices == null)
			return false;
		return vices.indexOf(vice.skey+",") != -1;
	}
	#end
}