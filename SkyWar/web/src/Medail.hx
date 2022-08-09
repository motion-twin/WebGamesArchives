enum Reward {
	WonMedail(k:MedailKind);
}

enum MedailKind {
	// le joueur a eu les 7 frags de sa partie, disparait au bout de 30 jours
	Solo(dt:Date);
	// a été premier au moins une fois au classement général (distribué toutes les semaines)
	First;
	// 0 dégâts dans une partie (voir pallier minimum bestPower), disparait au bout de 30 jours
	Bisou(dt:Date);
	BouletPoints;
	BouletBig;
	// voter pour ce joueur
	Cordial;
	Ether1;
	Ether2;
	Ether3;
	Gaia1;
	Gaia2;
	Gaia3;
	Isle1;
	Isle2;
	Isle3;
	Prod1;
	Prod2;
	Prod3;
	Frag1;
	Frag2;
	Frag3;
	Damage1;
	Damage2;
	Damage3;
	Victories1;
	Victories2;
	Victories3;
	Shblov;
}

class Medail {
	public var kind : MedailKind;
	public var url : String;
	public var upgradable : Bool;

	private function new( k:MedailKind, img:String, upgradable:Bool=false ){
		this.kind = k;
		this.url = "/gfx/medailles/"+img;
		this.upgradable = upgradable;
	}

	public function getDesc() : String {
		var key = switch (kind){
			case Solo(dt):"solo";
			case Bisou(dt):"bisou";
			default: Std.string(kind).toLowerCase();
		}
		return Text._get("med_"+key);
	}

	public static function get( k:MedailKind ) : Medail {
		return switch (k){
			case Solo(d): new Medail(k, "med_solo.jpg");
			case First: new Medail(k, "med_1er.jpg");
			case Bisou(d): new Medail(k, "med_bisou.jpg");
			case BouletPoints: new Medail(k, "med_bouletpt.jpg");
			case BouletBig: new Medail(k, "med_bouletgd.jpg");
			case Cordial: new Medail(k, "med_cordial.jpg");
			case Ether1: new Medail(k, "med_ether_niv1.jpg", true);
			case Ether2: new Medail(k, "med_ether_niv2.jpg", true);
			case Ether3: new Medail(k, "med_ether_niv3.jpg", true);
			case Gaia1: new Medail(k, "med_gaia_niv1.jpg", true);
			case Gaia2: new Medail(k, "med_gaia_niv2.jpg", true);
			case Gaia3: new Medail(k, "med_gaia_niv3.jpg", true);
			case Isle1: new Medail(k, "med_ilots_niv1.jpg", true);
			case Isle2: new Medail(k, "med_ilots_niv2.jpg", true);
			case Isle3: new Medail(k, "med_ilots_niv3.jpg", true);
			case Prod1: new Medail(k, "med_prod_niv1.jpg", true);
			case Prod2: new Medail(k, "med_prod_niv2.jpg", true);
			case Prod3: new Medail(k, "med_prod_niv3.jpg", true);
			case Frag1: new Medail(k, "med_speed_niv1.jpg", true);
			case Frag2: new Medail(k, "med_speed_niv2.jpg", true);
			case Frag3: new Medail(k, "med_speed_niv3.jpg", true);
			case Damage1: new Medail(k, "med_kill_niv1.jpg", true);
			case Damage2: new Medail(k, "med_kill_niv2.jpg", true);
			case Damage3: new Medail(k, "med_kill_niv3.jpg", true);
			case Victories1: new Medail(k, "med_victoires_niv1.jpg", true);
			case Victories2: new Medail(k, "med_victoires_niv2.jpg", true);
			case Victories3: new Medail(k, "med_victoires_niv3.jpg", true);
			case Shblov: new Medail(k, "med_glouton_niv2.jpg");
		}
	}

	public static function split( medails:List<MedailKind> ) : { regular:List<Medail>, extra:List<Medail> } {
		var medails : List<Medail> = Lambda.map(medails, function(m) return Medail.get(m));
		var medails : Array<Medail> = Lambda.array(medails);
		medails.sort(
			function(a,b)
			return Reflect.compare(
				tools.EnumTools.getIndex(a.kind),
				tools.EnumTools.getIndex(b.kind)
			)
		);
		var medails = Lambda.list(medails);
		return {
			regular:medails.filter(function(m) return m.upgradable),
			extra:medails.filter(function(m) return !m.upgradable)
		};
	}

	public static function computeRewards( medails:List<MedailKind>, counters:MedailCounters ) : List<Reward> {
		var result = new List();

		// Médailles boulet
		if (counters.loose >= 10) addMedail(BouletBig, medails, result, [BouletPoints]);
		else if (counters.loose >= 5) addMedail(BouletPoints, medails, result);
		else if (counters.loose == 0) delMedails(medails, [BouletPoints,BouletBig]);
		// Médailles victoires
		if (counters.victo >= 100) addMedail(Victories3, medails, result, [Victories2,Victories1]);
		else if (counters.victo >= 20) addMedail(Victories2, medails, result, [Victories3,Victories1]);
		else if (counters.victo >= 1) addMedail(Victories1, medails, result, [Victories3,Victories2]);
		else delMedails(medails, [Victories1,Victories2,Victories3]);
		// Médailles ether
		if (counters.ether >= 500000) addMedail(Ether3, medails, result, [Ether2,Ether1]);
		else if (counters.ether >= 50000) addMedail(Ether2, medails, result, [Ether3,Ether1]);
		else if (counters.ether >= 5000) addMedail(Ether1, medails, result, [Ether3,Ether2]);
		else delMedails(medails, [Ether1,Ether2,Ether3]);
		// Médailles gaîas
		if (counters.gaias >= 1000) addMedail(Gaia3, medails, result, [Gaia2,Gaia1]);
		else if (counters.gaias >= 50) addMedail(Gaia2, medails, result, [Gaia3,Gaia1]);
		else if (counters.gaias >= 1) addMedail(Gaia1, medails, result, [Gaia3,Gaia2]);
		else delMedails(medails, [Gaia1,Gaia2,Gaia3]);
		// Médailles Isles
		if (counters.isles >= 1000) addMedail(Isle3, medails, result, [Isle2,Isle1]);
		else if (counters.isles >= 100) addMedail(Isle2, medails, result, [Isle3,Isle1]);
		else if (counters.isles >= 3) addMedail(Isle1, medails, result, [Isle3,Isle2]);
		else delMedails(medails, [Isle1,Isle2,Isle3]);
		// Médailles production
		if (counters.prods >= 1000000) addMedail(Prod3, medails, result, [Prod2,Prod1]);
		else if (counters.prods >= 100000) addMedail(Prod2, medails, result, [Prod3,Prod1]);
		else if (counters.prods >= 10000) addMedail(Prod1, medails, result, [Prod3,Prod2]);
		else delMedails(medails, [Prod1,Prod2,Prod3]);
		// Médailles frags
		if (counters.frags >= 400) addMedail(Frag3, medails, result, [Frag2,Frag1]);
		else if (counters.frags >= 50) addMedail(Frag2, medails, result, [Frag3,Frag1]);
		else if (counters.frags >= 1) addMedail(Frag1, medails, result, [Frag3,Frag2]);
		else delMedails(medails, [Frag1,Frag2,Frag3]);
		// Médailles damage
		if (counters.kills >= 1000000) addMedail(Damage3, medails, result, [Damage2,Damage1]);
		else if (counters.kills >= 100000) addMedail(Damage2, medails, result, [Damage3,Damage1]);
		else if (counters.kills >= 10000) addMedail(Damage1, medails, result, [Damage3,Damage2]);
		else delMedails(medails, [Damage1,Damage2,Damage3]);

		return result;
	}

	static function delMedails( medails:List<MedailKind>, toDel:Array<MedailKind> ){
		for (r in toDel){
			var idx = tools.EnumTools.getIndex(r);
			for (m in medails)
				if (tools.EnumTools.getIndex(m) == idx)
					medails.remove(m);
		}
	}

	public static function addMedail( medail:MedailKind, medails:List<MedailKind>, rewards:List<Reward>, ?replace:Array<MedailKind> ){
		if (replace != null)
			delMedails(medails, replace);
		var idx = tools.EnumTools.getIndex(medail);
		for (m in medails)
			if (tools.EnumTools.getIndex(m) == idx)
				return;
		medails.push(medail);
		rewards.push(WonMedail(medail));
	}
}

class MedailCounters {
	public var victo : Int;
	public var loose : Int;
	public var ether : Float;
	public var gaias : Float;
	public var isles : Float;
	public var prods : Float;
	public var frags : Float;
	public var kills : Float;
	//	var votes : Float;

	public function new(){
		cleanup();
	}

	public function cleanup(){
		if (victo == null) victo = 0;
		if (loose == null) loose = 0;
		if (ether == null) ether = 0;
		if (gaias == null) gaias = 0;
		if (isles == null) isles = 0;
		if (prods == null) prods = 0;
		if (frags == null) frags = 0;
		if (kills == null) kills = 0;
	}
}