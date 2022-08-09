import Text;

class TextEn {

	public static var EXTRA_LIFES = " extra lives";
	public static var EXTRA_LIFE  = " extra life";
	public static var EXPLORING = "Planet under exploration.";

	//
	public static function getText( i:Int ) : Tip {
		var text = [
		[ "RCD-20 drilling ball", "You can destroy ferrous conglomerates." ],
		[ "OX-Soldier ball", "You can destroy parasite molecules." ],
		[ "OX-Delta ball", "Its drilling power is doubled."],
		[ "Secret ball:\nAsphalt-project", "Ball with unknown effects."],

		[ "Standard missile", "Press the space bar to send a destructive missile."],
		[ "AR-57 missile", "Its explosive power allows it to destroy up to 9 bricks in only one shot."],
		[ "MAS-Z missile", "Can destroy any kind of conglomerate."],
		[ "AR-SRX missile", "Highly improved damage. This missile can destroy up to 25 conglomerates."],

		[ "Perforation tools", 	"Your drones disassemble the sentinels faster."],
		[ "Reactor Support", 	"Your drones move faster."],
		[ "Converter", 		    "Your drones convert sentinels into minerals."],
		[ "Collector",			"Your drones can collect minerals."],

		[ "Merchants map", "All the best addresses where you can upgrade your envelope for a few minerals."],
		[ "Missiles map", "Find all abandoned missiles traces to increase your missiles synthesis capacity."],
		[ "Black holes map", 	"The black holes will let you to travel quickly from one side of the galaxy to the other."],

		[ "Alpha license", "One of the three passes granting authorization for you to use a drilling ball in this system."],
		[ "Beta license", "One of the three passes granting authorization for you to use a drilling ball in this system."],
		[ "Ceta license", "One of the three passes granting authorization for you to use a drilling ball in this system."],

		[ "Side reactors", "Your envelope revolves faster for missile launching."],
		[ "Liquid cooler", 		"The envelope can launch missiles faster."],
		[ "Perpetual synthesis motor", 	"The envelope generates a missile at each new sector reached."],

		[ "Sunglasses", "Cancels harm from the flash molecules, and improves visibility of luminous stars' clusters."],
		[ "Zonkerian medallion", "The incredible energy it emits improves the stability of your envelope and the speed of its movements."],
		[ "Ki-Wi Antenna", "Extraterrestrial radar with vitamin C and E added. Improves radio signal reception." ],
		[ "Antimatter", "Antimatter" ],
		[ "Ambro-X", "Increases your radar's range by 1 point." ],
		[ "Syntrogenic accelerator",	"Creates one liquid hydrogen capsule per day." ],
		[ "Lithium retrofusor", "Sends you back to your origin position in a wink." ],
		[ "Space suit", "You can get out of your envelope even on planets where the air is not breathable." ],
		[ "","" ],
		[ "","" ],
		[ "Genemill", 			"A fourth-generation fission engine, it has been transferred to the ESCorp." ],
		[ "", 				"" ],
		[ "Saumir's twinner", 	"During the synthesis of your first drilling ball, the twinner is activated and duplicates the ball." ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "Incomplete medallion", 	"It's a small Zonkerian Medallion, it is incomplete." ],
		[ "", 				"" ],


		];
		return { title:text[i][0], desc:text[i][1] };
	}

	public static function getPlanet(i:Int) : String {
		var texts = [
		// Moltear
		"Rocky planet with a high molecular parasite activity. Old Zonkerian colony, many ruins can be seen in the southern hemisphere.",

		// soupaline
		"Planet having similar characteristics to the Earth's. A standard terraformation procedure has recently been launched by ESCorp in order to set up a drilling colony in the near future.",

		// Lycans
		"Giant volcanic planet, the high concentration of poutractive conglomerates makes its exploration dangerous.",

		// Samosa
		"The bulkiest planet of the Zonkerian system. Its incredible density and its exceptional gravity transform any mining operation into an endless race of endurance.",

		// Tiboon
		"Small-sized, desertic planet. Little mining resources are exploitable.",

		// Balixt
		"Home planet of a highly technologically advanced extraterrestrial race. Being quite xenophobic, Balixteans have posted sentinels all through and around their territory, and will not tolerate any intrusions.",

		// Karbonis
		"The explosion of the principal reactor of a gigantic mining industry caused Karbonis' heart to become unstable, and was followed by its implosion. An asteroid belt was created around the Zonkerian system called the \"Karbonis belt\".",

		// Spignysos
		"Spignysos' surface temperature never exceeds -50°C. Icy winds on the surface alter any envelope's orientation matrix and make space mining more difficult. We call this phenomenon \"spignysian stasis\".",

		// Pofiak
		"The presence of water and the temperate climate on Pofiak allowed tropical jungles to grow on its entire surface. Psionic insects can parasite your envelope's orientation matrix.",

		// Senegarde
		"Gaseous planet. The presence of saturated frugi-nitrogen creates an incredibly fertile field for parasite molecules. They develop faster here than anywhere else.",

		// Douriv
		"This planet is extremely rich in minerals, 75% of its surface is crystalized or in the process of crystalization. Naturally, it's the favorite destination of all space miners. Sadly, psionic insects infest the richest regions of Douriv.",

		// Grimorn
		"It is a dead planet, its ground is poor and the presence of metallic conglomerates prevent any intensive mining.",

		// D-Tritus
		"Dump planet where great monsters reside. They are organized in society and live by operating a planet in another galaxy. The technology that allows them to travel so far is still unknown.",

		// Asteroide
		"Karbonis' asteroid belt: the old planet exploded which created a vast asteroid field...",

		// Nalikors
		"A dry planet that has etheral vegetation. This planet is used as a rally point to all the anarchists of the universe. FURI is the represented movement, and it includes over 242 members in this sector.",

		// Holovan
		"An old rocky planet, the Kemilians' home planet, a more than 120,000 year old civilization. In the aim of not being disturbed, the Kemilians filled the sky with Kashuat sentinels.",

		// Khorlan
		"A grassy and comfortable planet. It is a friendly place to live in, several settlers decided to flee their galaxy's political problems and reach Khorlan. Only orbital-nut falls disturb their peaceful lives.",

		// Cilorile
		"A planet with water and breathable atmosphere, Cilorile is avoided by most miners because of its guardian conglomerates. Their contact causes an immediate explosion of the envelope.",

		// Tarciturne
		"This planet was devastated several years ago by a meteorite shower.",

		// Chagarina
		"A limestone planet which died a few milleniums ago. Its advanced crystalization and its location far away in the Zonkerian system make it a premium destination for the miners.",

		// Volcer
		"Planet with large dimensions, having enough water to provide shelter for various life forms. Even with a difficult access, Volcer attracts thousands of tourists coming from all surrounding systems every year.",

		// Balmanch
		"Spiky-limestone planet of the voceronic type. The atmosphere's high starch saturation has caused a proliferation of orbital-nuts. Today, only high-skilled pilots can fly over Balmanch without risking an immediate crash.",

		// Folket
		"Gaseous planet. Folket's core implosion over twenty thousand years ago led to a perpetual chlorine clay vaporization of its ground. The surface slicks' high acidity prevents envelopes lacking strong shields to reach its center.",
		];
		return texts[i];
	}

	public static function getStar( i:Int ){
		return ["Red","Orange","Yellow","Green","Turquoise","Blue","Purple"][i]+" Star";
	}

	public static function getTip( k:TKind ){
		return switch (k){
			case TGenerator: {title:"Envelope's generator", desc:"Allows you to travel $0 slots per hydrogen capsule."};
			case TDrone:  {title:"Supporting drone", desc:"Can defuse traps located in some conglomerates."};
			case TKarbonite: {title:"Karbonite tablet", desc:"Unknown effect."};
			case TAntimater: {title:"Antimatter nuclei", desc:"Humongous destruction powers. You possess $0/4 of them."};
			case TCrystal:   {title:"Pink crystals", desc:"The center of these crystals seems to shudder. You possess $0/5."};
			case TLycans:	 {title:"Lycans sample", desc:"Its temperature hasn't dropped since you picked it up in your envelope."};
			case TSpignysos: {title:"Spignysos sample", desc:"A fine layer of frost surrounds the rock."};
			case TAR57:	 {title:"Fusion" , desc:"The chemical reaction that occurs when you bring the samples together allows you to synthesize AR-57 missiles."};
			case TMine:	 {title:"FORA 7R-Z mine" , desc:"Automatic synthesis drilling mine. You possess $0/4."};
			case TReactor:	 {title:"Surface engine" , desc:"Allows you to fly over planets. This engine has $0 unit(s) of strength."};
			case TPods:	 {title:"Landing pods", desc:"These $0 meter long retracting pods allow you to land on surfaces that are flat enough."};
			case TRadar:	 {title:"Radar", desc:"Your radar allows you to reach unknown areas located $0 spaces away from your explored zone."};
			case TEarthMap:	 {title:"PID Map", desc:"It is a human map. Once filled, it will reveal the coordinates of a new planet. $0 parts of this map are missing."};
			case TEarthMapComplete:	 {title:"Complete PID map", desc:"It is a human map. The planet described there seems intimate. At the center of the map you notice coordinates."};
		}
	}
}
