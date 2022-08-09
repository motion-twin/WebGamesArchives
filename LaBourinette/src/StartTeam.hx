import GameParameters;

typedef PDef = {
	player:db.Player,
	att:AttPos,
	def:DefPos,
	thro2:Bool,
};

class StartTeam {
	public static function generate() : List<PDef> {
		var result = new List();
		var p = new db.Player();
		p.name = "Vigor Grulny";
		p.label = "Batteur rapide";
		p.power = 1;
		p.agility = 2;
		p.accuracy = 2;
		p.endurance = 1;
		p.charisma = 1;
		p.maxAge = 20;
		p.addCompetence(Competence.get.Fast);
		p.addCompetence(Competence.get.SureSwing);
		p.basePrice = 1500;
		p.face = "88Dk0O7z4P7iwfXy";
		result.push({ player:p, att:Bat1, def:DefL, thro2:false });

		var p = new db.Player();
		p.name = "Kikù Goredak";
		p.label = "Défenseur";
		p.power = 1;
		p.agility = 2;
		p.accuracy = 2;
		p.endurance = 2;
		p.charisma = 1;
		p.maxAge = 19;
		p.basePrice = 1500;
		p.face = "1sHR09Ph-sfxxt/X";
		p.addCompetence(Competence.get.PicoTackle);
		// p.addCompetence(Competence.get.Trainer);
		result.push({ player:p, att:Bat3, def:DefM, thro2:false });

		var p = new db.Player();
		p.name = "Prötz Benaskief";
		p.label = "Capitaine";
		p.power = 1;
		p.agility = 1;
		p.accuracy = 1;
		p.endurance = 2;
		p.charisma = 2;
		p.maxAge = 18;
		p.basePrice = 1500;
		p.face = "CjMOHRMjBTIKIg4L";
		p.addCompetence(Competence.get.Chief);
		p.addCompetence(Competence.get.Simulate);
		result.push({ player:p, att:AttR, def:DSub, thro2:true });

		var p = new db.Player();
		p.name = "Krass Grolska";
		p.label = "Médecin rapide";
		p.power = 1;
		p.agility = 2;
		p.accuracy = 2;
		p.endurance = 1;
		p.charisma = 1;
		p.maxAge = 17;
		p.basePrice = 1500;
		p.face = "OScVBDojHRUpKB44";
		p.addCompetence(Competence.get.Doctor);
		p.addCompetence(Competence.get.Sprinter);
		result.push({ player:p, att:AttL, def:DefF, thro2:false });

		var p = new db.Player();
		p.name = "Vigor Soleslav";
		p.label = "Batteur passeur";
		p.power = 1;
		p.agility = 1;
		p.accuracy = 2;
		p.endurance = 2;
		p.charisma = 1;
		p.maxAge = 15;
		p.basePrice = 1500;
		p.face = "XFt/QFJmZE51ZEFd";
		p.addCompetence(Competence.get.Passer);
		p.addCompetence(Competence.get.WhirlSwing);
		result.push({ player:p, att:Bat2, def:DefR, thro2:false });

		var p = new db.Player();
		p.name = "Gründ Gorevolod";
		p.label = "Lanceur";
		p.power = 2;
		p.agility = 1;
		p.accuracy = 1;
		p.endurance = 1;
		p.charisma = 1;
		p.maxAge = 20;
		p.basePrice = 1500;
		p.face = "BjcNOSkbABoMDisH";
		p.addCompetence(Competence.get.Pitify);
		p.addCompetence(Competence.get.PowerThrow);
		result.push({ player:p, att:ASub, def:Thro, thro2:false });

		return result;
	}
}