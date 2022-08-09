import Text;

class TextDe {

	public static var EXTRA_LIFES = " Extraleben";
	public static var EXTRA_LIFE  = " Extraleben";
	public static var EXPLORING = "Der Planet wird gerade erkundet.";

	//
	public static function getText( i:Int ) : Tip {
		var text = [
		[ "Bohrkugel RCD-20", "Diese Kugel kann Eisenansammlungen zerstören."								],
		[ "OX-Soldat Kugel", "Diese Kugel kann parasitäre Moleküle zerstören."									],
		[ "OX-Delta Kugel", "Die Durchschlagskraft dieser Kugel ist doppelt so stark."									],
		[ "Geheime Kugel:\nAsphalt-Projekt", "Kugel mit unbekanntem Effekt."									],

		[ "Standard-Rakete", "Halte die Leertaste gedrückt, um eine zerstörerische Rakete zu verschießen."					],
		[ "AR-57-Rakete", "Dank ihrer enormen Sprengkraft ist diese Rakete in der Lage bis zu 9 Steine mit einem Treffer zu zerstören."					],
		[ "MAS-Z-Rakete", "Diese Rakete kann jede Ansammlung zerstören."										],
		[ "AR-SRX-Rakete", "Diese Rakete hat einen erheblich verbesserten Explosionsradius. Sie kann bis zu 25 Ansammlungssteine zerstören."			],

		[ "Bohrungswerkzeuge", 	"Erleichtert deinen Drohnen die Zerlegung von Wachposten."			],
		[ "Unterstützungsreaktor", 		"Deine Drohnen bewegen sich schneller."					],
		[ "Konverter", 		"Deine Drohnen sind in der Lage, Wachposten in Mineralien zu verwandeln."				],
		[ "Sammler", 		"Deine Drohnen sammeln für dich Mineralien ein."			],

		[ "Händlerkarte", 	"Hier findest du alle Adressen, um dein Raumschiff für ein paar Mineralien aufbessern zu können."	],
		[ "Raketenkarte", 	"Du bist imstande alle Raketenwracks zu finden, um deine Ladekapazität für Raketen zu erhöhen."],
		[ "Karte der Schwarzen Löcher", 	"Schwarze Löcher ermöglichen dir blitzschnell von einem Ende des Universums ans andere zu gelangen."],

		[ "Alpha-Akkreditierung", 	"Einer der drei Pässe, die dir erlauben deine Bohrkugel in diesem System zu verwenden."],
		[ "Beta-Akkreditierung", 	"Einer der drei Pässe, die dir erlauben deine Bohrkugel in diesem System zu verwenden."],
		[ "Ceta-Akkreditierung", 	"Einer der drei Pässe, die dir erlauben deine Bohrkugel in diesem System zu verwenden."],

		[ "Seitendüsen", 		"Dein Raumschiff ist imstande sich schneller zu drehen, um Raketen zu verschießen."],
		[ "Flüssigkühlung", 		"Dein Raumschiff ist imstande schneller Raketen zu verschießen."],
		[ "Permanente Synthese ", 	"Dein Raumschiff baut in jedem neuen Sektor eine neue Rakete."],

		[ "Sonnenbrille", 		"Reduziert die Wirkung von Blitzmolekülen und verbessert die allgemeine Sichtbarkeit in bestimmten, grell leuchtenden Nebeln." ],
		[ "Zonkerianisches Medaillon", 	"Dank der unglaublichen Energie, die es ausstrahlt, verbessert dieses Medaillon die Stabilität und Geschwindigkeit deines Raumschiffs." ],
		[ "Ki-Wi-Antenne", 		"Außerirdisches Radar, das mit vitaminisierter Energie (C und E) betrieben wird. Verstärkt alle in der Nähe ausgestrahlten Radiosignale." ],
		[ "Antimaterie", 		"Antimaterie" ],
		[ "Ambro-X", 			"Erhöht die Reichweite deines Radars um einen Punkt." ],
		[ "Syntrogenetischer Beschleuniger",	"Ermöglicht dir pro Tag eine Wasserstoffkapsel herzustellen." ],
		[ "Lithium-Raumfusionator", 	"Du wirst innerhalb eines Sekundenbruchteils an deine ursprüngliche Position gebeamt." ],
		[ "Raumanzug", 		"Mit diesem Anzug kannst du dein Raumschiff verlassen und dich auf lebensfeindlichen Planeten bewegen." ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "Genemill", 			"Ein Antrieb, der auf Grundlage der Kernspaltung funktioniert. Es handelt sich um die vierte Generation. Er wurde der ESCorp gesendet." ],
		[ "", 				"" ],
		[ "Saumirs Kugelverdoppler", 	"Bei der Herstellung einer Bohrkugel wird eine zweite Kugel mitproduziert." ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "Medaillonstück", 	"Es handelt sich um ein kleines zonkerianisches Medaillon. Es scheint nicht vollständig zu sein." ],
		[ "", 				"" ],


		];
		return { title:text[i][0], desc:text[i][1] };
	}

	public static function getPlanet(i:Int) : String {
		var texts = [
		"Ein felsiger Planet mit starker parasitärer molekularer Aktivität. Diese alte zonkerianische Kolonie beherbergt eine große Anzahl an Ruinen, die sich hauptsächlich in der südlichen Hemisphäre befinden.",

		"Dieser Planet ähnelt sehr der Erde. Die ESCorp hat vor kurzem einen standartisierten Terraforming-Prozess auf Soupaline begonnen. Damit sollen neue Minen angelegt werden.",

		"Dieser gigantische vulkanische Planet weist eine hohe Dichte an explosiven Steinen auf. Seine Erforschung ist außerordentlich gefährlich.",

		"Dies ist der größte Planet im zonkerianischen System. Seine unglaubliche Dichte und seine außergewöhnliche Gravitationskraft sorgen dafür, dass Bohrungsarbeiten zu einer wahren Sisyphusarbeit werden.",

		"Ein kleiner Wüstenplanet, der wenig abbaubare Rohstoffe enthält.",

		"Dies ist der Heimatplanet einer technologisch hoch entwickelten außerirdischen Rasse: die Balixtiner. Da die Balixtiner relativ fremdenfeindlich sind, haben sie ihren Sektor mit zahlreichen Drohnen übersät. Sie sorgen dafür, dass niemand in ihr System eindringt.",

		"Der Hauptreaktor einer riesigen Mine war für die Destabilisierung und später für die Implosion von Karbonis verantwortlich. Als Resultat hat sich ein Asteroidengürtel rund um das zonkerianische System gebildet, der sogenannte 'Karbonisgürtel'.",

		"Die Oberflächentemperatur auf Spignysos steigt nie über -50°. Darüber hinaus beeinflussen die eisigen Oberflächenwinde die Bewegungsmatrix deines Raumschiffs. All dies erschwert deine Arbeit erheblich. Das oben benannte Phänomen wird auch die 'Spignysische Stauung' genannt.",

		"Dank seiner Wasservorkommen und der milden Temperaturen konnten auf Pofiak tropische Urwälder entstehen. Sie bedecken gegenwärtig die gesamte Oberfläche des Planeten. Psionische Insekten können allerdings die Bewegungsmatrix deines Raumschiffs negativ beeinflussen.",

		"Es handelt sich um einen stark gashaltigen Planeten. Die Anwesenheit gesättigter Stickstoff-Frugis macht ihn zu einen äußerst fruchtbaren Planeten, der insbesondere für molekulare Parasiten anziehend ist. Diese breiten sich hier wesentlich schneller aus als anderswo.",

		"Ein stark mineralienhaltiger Planet, dessen Oberfläche zu 75% in kristalliner Form vorliegt oder gerade dabei ist einen Kristallisationsprozess zu durchlaufen. Dieser Planet ist ein gefundenes Fressen für alle Weltraumminenarbeiter, wären da nicht die psionischen Insekten... Diese haben insbesonders die ertragreichen Regionen Dourivs besiedelt.",

		"Dies ist ein kalkhaltiger Planet, wie man ihn in allen Systemen in großer Anzahl findet. Der Boden ist karg und die Anwesenheit von metallischen Ansammlungssteinen erschwert den intensiven Minenbetrieb.",

		"Ein Müllhaldenplanet, auf dem gefürchtete Monster leben. Diese haben eine Gemeinschaft gebildet und leben von der Ausbeutung eines anderen Planeten, der sich in einer anderen Galaxie befindet. Kein Mensch weiß, wie es diesen Monstern gelingt, derart große Entfernungen zu überwinden.",

		"Die Asteroidenkette von Karbonis: Der ehemalige Planet ist inzwischen einem weit ausgedehntem Asteroidfeld gewichen...",

		"Dieser trockene Planet verfügt über eine ätherisierte Vegetation und ist zudem ein Sammelbecken für Anarchisten aus dem ganzen Universum geworden. Die FURI ist mit mehr als 242 Mitgliedern der stärkste Verband in diesem Sektor.",

		"Holovan ist ein uralter Planet. Die darauf lebende Zivilisation existiert seit über 120.000 Jahren. Da sind nicht gestört werden wollen, haben die Kemilianer ihre Planetenatmosphäre mit Kashuat-Drohnen gespickt.",

		"Khorlan ist ein saftiggrüner, hügeliger und sympathischer Planet. Ein Ort, an dem es sich sehr gut leben lässt. Aus diesem Grund haben sich hier viele Siedler niedergelassen. Sie sind vor den politischen Problemen ihrer Galaxie geflüchet und haben hier eine neue Heimat gefunden. Der einzige Wermutstropfen sind die ständig herunterfallenden Orbital-Nüsse.",

		"Auf Cilorile gibt es Wasser und eine sauerstoffreiche Atmosphäre. Dennoch wird der Planet von so gut wie allen Minenarbeitern aufgrund seiner Wächteransammlungssteine vermieden. Eine Berührung mit ihnen verursacht die sofortige Explosion des Raumschiffs.",

		"Ein kalkhaltiger Planet, der vor mehreren Jahren durch einen Meteoritenregen zerstört wurde.",

		"Ein kalkhaltiger Planet, der schon seit Tausenden von Jahren tot ist. Sein Zustand fortgeschrittener Kristallisation, sowie seine entlegene Position, machen ihn für Minenarbeiter äußerst wertvoll.",

		"Volcer ist ein sehr großer Planet, der über reichlich Wasser verfügt und der die Heimat verschiedenster Lebewesen ist. Trotz der schwierigen Anreise kommen jedes Jahr tausende Touristen aus den benachbarten Systemen.",

		"Ein mit Kalkstacheln übersäter Planet der Voceronen-Art. Die vermehrte Präsenz von Stärkemolekülen in seiner Atmosphäre hat für die rasante Ausbreitung von Orbital-Nüssen gesorgt. Aufgrund der hohen Kollisionsgefahr wagen sich nur noch erfahrene Piloten nach Balmanch.", 

		"Folket ist ein gashaltiger Planet. Die Implosion seines Planetenkerns vor über zwanzigtausend Jahren hat eine schleichende Verdampfung von chlorierten Tonelementen ausgelöst. Stark ätzende Nebelschwaden verhindern, dass nicht genügend gepanzerte Raumschiffe sich dem Planetenzentrum nähern können.",

		];
		return texts[i];
	}

	public static function getStar( i:Int ){
		return ["Roter","Orangener","Gelber","Grüner","Türkisfarbener","Blauer","Violetter"][i]+" Stern";
	}

	public static function getTip( k:TKind ){
		return switch (k){
			case TGenerator: {title:"Haupttriebwerk", desc:"Ermöglicht pro Wasserstoffkapsel $0 Felder zu durchfliegen."};
			case TDrone:  {title:"Hilfsdrohne", desc:"Mit ihr können in manchen Steinansammlungen Wachposten ausgeschaltet werden."};
			case TKarbonite: {title:"Karbonit-Tafel", desc:"Unbekannte Wirkung"};
			case TAntimater: {title:"Antimateriekern", desc:"Er besitzt eine unglaubliche Zerstörungskraft. Aktueller Vorrat: $0/4."};
			case TCrystal:   {title:"Rosa Kristalle", desc:"Das Innere des Kristalls scheint zu pulsieren. Aktueller Vorrat: $0/5."};
			case TLycans:	 {title:"Lycans-Felsen", desc:"Seitdem er in das Raumschiff geladen wurde ist seine Temperatur nicht gestiegen."};
			case TSpignysos: {title:"Spignysos-Felsen", desc:"Auf seiner Oberfläche bildet sich ständig eine hauchdünne Raureifschicht."};
			case TAR57:	 {title:"Fusion" , desc:"Die Verbindung zweier Steine löst eine chemische Reaktion aus, die es ermöglicht AR57 Raketen herzustellen."};
			case TMine:	 {title:"Mine FORA 7R-Z" , desc:"Bohrungsminen, die automatisch synthetisiert werden. Aktueller Vorrat: $0/4."};
			case TReactor:	 {title:"Atmosphärentriebwerk" , desc:"Ermöglicht das Eintreten in die Atmosphäre eines Planeten. Seine Stärke beträgt $0 Einheit(en)."};
			case TPods:	 {title:"Landestützen", desc:"Diese einfahrbaren Beine sind $0 Meter lang und ermöglichen es auf einer ausreichend ebenen Oberfläche zu landen."};
			case TRadar:	 {title:"Radar", desc:"Dank des Radarsignals können unbekannte Koordinatenpositionen erreicht werden, die bis zu $0 Felder von der bereits erforschten Position entfernt sind."};
			case TEarthMap:	 {title:"PID-Karte", desc:"Eine Karte unbekannten Ursprungs. Sobald alle ihre Einzelteile eingesammelt wurden, können die Koordinaten des dargestellten Planeten bestimmt werden. Es fehlen noch $0 Stück(e)."};
			case TEarthMapComplete:	 {title:"Vollständige PID-Karte", desc:"Eine Karte unbekannten Ursprungs. Der auf der Karte dargestellte Planet sieht bekannt aus. In der Mitte der Karte stehen seine Koordinaten."};
		}
	}
}

















