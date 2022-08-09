class Lang{//}



	static var nameSyl0 = [	"$Al" "$Ami" "$Fri" "$Aphro" "$Gili" "$Ho" "$Game" "$Ali" "$Sisi" "$Nami" "$Gi" "$Mali" "$Pi" "$Aso" "$Ni" "$Aho" "$Cyn" "$Mo" "$Dani" "$Ju" "$Sou" "$Li" "$Chomi" "$Kolchi" "$Chi" "$Kumi" "$Yari" "$Za" "$Pi" "$Gami" "$Soli" "$Bama" "$Lumi" "$Api" "$Sumi" "$Dama" "$Jima" "$Magi" "$Tosta" "$Sandi" "$Sulme" "$Go" "$Hi" ]
	static var nameSyl1 = [	"$meria" "$ana" "$kine" "$ne" "$line" "$am" "$yim" "$lia" "$milie" "$lie" "$gine" "$a" "$ka" "$ma" "$dine" "$e" "$ria" "$lyne" "$cie" "$nia" "$dea" "$mone" "$gone" ]


	static var checkpointName = [
		"L'oree de la foret"
		"La clairiere sereine"
		"L'epaisse sommiere"
		"Le coeur de la foret"
		"L'antre sylvaine"
		"Le seuil empirique"
		"Le sentier oublié"
	]

	static var behaviourName = [
		"Psychanaliste "
		"cannibalisme "
		"cleptomanie "
		"apathie "
		"schizophrenie "

	]

	static var caracName = [
		"Force "
		"Rapidité "
		"Vie "
		"Intelligence "
		"Concentration "
		"Mana "
	]

	static var caracResume = [
		"La force de votre fée lui permet de mieux résister aux chocs des démons, ainsi qu'à donner des coups plus puissants."
		"Plus votre fée est rapide mieux elle esquive les tirs ennemis."
		"Votre total de coeur maximum dépend de la caractéristique vie."
		"L'intelligence permet à votre fée de choisir les meilleurs sorts, ainsi que les meilleures options pour ceux-ci."
		"La concentration permet à votre fée de voir les pièces en avance, elle augmente aussi la puissance ou la durée de certains sorts."
		"La mana détermine votre réserve de magie maximum pour une partie."
	]

	static var commandResume = [
		"Déplacer la pièce vers la gauche"
		"Déplacer la pièce vers la droite"
		"Faire pivoter la pièce"
		"Accélérer la chute de la pièce"
		"Demander de l'aide à la fée"
		"Activer/Désactiver la souris"
	]

	//


	static var FLASK_ACTION = [
		[
			"pleure "
			"pleure à chaudes larmes "
			"gémit "
			"déprime "
			"dépérit "
			"se cogne la tête contre les parois "
			"chante un air lugubre "
			"est démoralisée "
			"gratte contre le bord "
			"grave un nouveau trait sur les parois "
			"lit ''comment s'évader d'un bocal'' "

		],
		[
			"s'ennuie "
			"n'a pas le moral "
			"parle toute seule "
			"trouve le temps long "
			"se ronge les ongles "
			"chante un air triste "
			"vous regarde tristement "
			"se tourne les pouces "
			"regarde ailleurs "
			"fixe la paroi du bocal"
			"tourne en rond"
			"bavarde avec la paroi.."
			"parle avec son reflet "

		],
		[
			"vous attend "
			"chante un air de musique "
			"attend votre retour "
			"attend la prochaine aventure "
			"joue aux cartes toute seule "
			"vole tranquillement "
			"nettoie ses ailes "
			"s'étire "
			"dort "
			"fait une bulle de chewing-gum "
			"installe son hamac "
			"fait un pictionary toute seule "
			"se brosse les dents "
			"se vernit les ongles "
			"médite paisiblement "

		],
		[
			"fait des tourbillons "
			"fait un château de cartes "
			"agite ses ailes "
			"vous fait un clin d'oeil "
			"vole joyeusement "
			"se coiffe "
			"lit un roman "
			"se fait un collier de perles "
			"a senti qu'on la regardait "
			"se parfume à la violette "
			"teste ses chapeaux "
			"téléphone à Clochette "
			"sautille dans tous les sens "
			"se fait un bain de pied aux bulles magiques "

		],
		[
			"fait du jokari "
			"chante un air joyeux "
			"joue du micro-banjo "
			"rigole toute seule "
			"danse "
			"écrit un poême "
			"virevolte "
			"fait des pompes "
			"fait des loopings "
			"dessine sur un parchemin "
			"fait des paillettes "
			"grignote un chocapic "
			"joue à sa mini-frusion"
			"fait des biscuits au chocolat"

		]
	]



	// FAERIE TALK

	// 0 Constructive, sympa, positive, coach, altruiste
	// 1 Ahuri, dans la lune, sympa, indecis, superficielle.
	// 2 Grognon, méchante, pessimiste, feignante, cynic
	// 3 Ventarde, pas tres sympa
	// 4 Rigolote, sympa, enjouée, expansif
	// 5 Timide, sympa, pessimiste, polie, humble
	// 6 impatiente, pénible, plus que sure d'elle
	// 7 Boulet, beaucoup de questions, flood, phrases trés longues
	// 8 Peureuse, pas sure d'elle,

	// fidèle,
	// nombriliste, esthete
	// Belliqueuse
	// Curieuse
	// Gourmand

	// $name, $other, $like, $dislike

	static var endCheerList = [
		[ null,"On a fini !", "Bravo !", "En route!", "Voyons voir ce qui nous attend...", "Fini!!", "Un de plus" ],
		[ null,null,"Wow !!", "Déjà !?", "C'est déjà fini ?", "Qu'est-ce qui se passe ?", "On va où?", "Hein? C'est fini?" ],
		[ null,null,null,null,"Pas mal !", "Enfin !", "Génial...", "Je commençais à m'impatienter...", "On a fini par s'en sortir... C'est pas grâce à toi !", "Tu veux vraiment continuer?", "Ah ben ca fait du bien quand c'est fini tiens", "Et voilà, encore un niveau, on dit merci qui?" ],
		[ null,"Héhé, j'ai tout déchiré !", "Heureusement que j'étais là !", "Je m'en suis bien sortie !", "Tu m'as trouvée comment ?", "Avec $other tu l'aurais sûrement pas fini" "$name a encore tout fait", "Et encore une victoire pour moi, je sais je suis trop forte" ],
		[ null,"C'est encore loin Grand-Schtroumpf ?", "Je suis trop youpi-framboise !", "Génial !", "Félicitations, puzzle-man !", "Youhouhou !!!", "Un de plus en moins" ],
		[ null,null,null,null,"On s'en est bien sortis... non ?","J'espère que je ne t'ai pas trop encombré...","Si tu veux continuer sans moi je comprendrais...", "On continue ensemble?" ],
		[ null,"C'est pas trop tôt","T'aurais pas pu aller plus vite ?", "Ah ben quand même", "Le prochain je le fais moi-même", "Go go go go !!!", "Allez, on se dépèche", "J'ai failli m'endormir", "Allez hop hop encore un niveau!!" ],
		[ null,"On fait vraiment une super équipe tous les deux", "Tu crois que ça va être dur plus loin ?", "J'espère qu'il n'y aura pas de démons plus loin", "youpiiii, on a réussi", "Tu veux pas me porter? Je commence à fatiguer", "Y a quoi aprés?" ],
		[ null,"On rentre à la maison maintenant?", " Ouf, on a réussi", "An rentre? Ah non?", "T'es sûr qu'il y a pas de démons plus loin?", "Si tu veux continuer sans moi je comprendrais...", "Tu veux pas appeler $other à ma place?", ]
	]

	static var comboCheerList = [
		[ "Super !","Bien !","Bien joué !","Joli coup !","Combo !"],
		[ "Génial !","Bien vu !","Y'a un truc qui est tombé là, non ?","On y voit plus clair !"],
		[ null,"Pas mal !", "Peut mieux faire...", "Passable...", "Plutôt médiocre.", "Combo primitive..."],
		[ null,"Ouep, pas mal", "Bof, je peux le faire aussi...", "J'aurais pu le faire toute seule", "Pas de quoi se vanter...","Ca, même $other peut le faire !" ],
		[ "Bam!", "Trop la classe !", "Tu peux le refaire ?", "Combooo !!", "Excellent !" ],
		[ null,null,null,"Chouette !", "T'es fort !", "... "],
		[ "Tu peux en faire un autre ?", "Au moins ça débarasse", "Bon, maintenant t'en fais un autre.","Pas mal, on va gagner un peu de temps" ],
		[ "Waw, comment tu fais ?", "Tu me montreras comment tu fais ?", "Joliiiii !!", "Joli coup !" ],
		[ "T'es fort !", "Joliiiiii", "Bien joué !","Joli coup !", "Tu peux le refaire ?" ]
	]
	static var superComboCheerList = [
		[ "Très joli coup !","Fantastique !","Fabuleux !","T'es super doué !", "Epoustouflant !"],
		[ "Comment t'as fait ça ?","Waaah quel combo !","Trop fort !!!","Incroyable !","Y'avait pas un tas de billes, là, avant ?"],
		[ "Enfin un peu d'action", "Ah t'es un peu moins rouillé", "Hé.. Tu te défends...", "Combo acceptable.", "Hola, y'a du mouvement...", "Pas mal pour une fois...", "Ha ben tu vois quand tu veux !!", "Si tu pouvais faire des combos comme ça tout le temps..."],
		[ "Je peux faire mieux au prochain tour !","Impressionnant ! Mais c'est rien comparé à mes pouvoirs", "Super ! C'est presque aussi efficace que mes sorts" ],
		[ "Badaboum !","Yo ! C'est du grand spectacle ça !","C'est top-Fraise ce que tu nous fais là", "T'as mangé du lion ce matin non ?", "C'est super efficace ta combo, comment tu fais ça !?"],
		[ "... ", "C'est toi qui casse tout...", "Quelle combo! Je me sens inutile..." ],
		[ "Avec ça on va gagner du temps", "Ca c'est du combo rapide", "Si avec ça on passe pas au prochain niveau !", "Ouais on va pouvoir partir plus vite!!!", "Tu vois quand tu veux ?" ],
		[ "Géniaaaaal !", "J'suis super youpi-framboise", "Mais comment t'as fait un truc pareil ?", "Crac ! Boum !! Whaoouu !!", "Ouhouuu Combo-folie's !!" ],
		[ "Avec ça on a bientôt fini", "Voilààà on va pouvoir y aller maintenant?", "T'es sûr que ca va pas me tomber dessus?", "T'as pas peur quand ca explose comme ca ?", "*Kiaaahhh*", "Y a un truc qui a explosé", "Toutes ces explosions m'effraient" ]
	]

	static var spellCheerList=[
		[ null,null,null,"A toi de jouer maintenant !", "J'espère que ça suffira !", "C'est mieux comme ça ?" ],
		[ null,null,null,"Mince, c'est pas ce que je voulais faire !", "Ah ? Tiens je pensais que ca ferait autre chose", "Wah ! C'est moi qui ai fait ça ?" ],
		[ null,null,null,"C'est la dernière fois que je me bouge", "Essaie d'assurer un peu maintenant", "Bon je repars me coucher..."],
		[ "T'as vu ça ?", "Et voila le travail !!", "Alors ? Merci qui ?", "Là je me suis surpassée !", "Alors ? C'est autre chose que les petits sortilèges de $other...", "Ca, c'est ce que j'appelle de la magie !" ],
		[ null,null,"Wah ! Il est chouette ce sort!!", "Et hop là !", "Bari bari zoum zoum !", "Abracadabra !" ],
		[ null,null,null,null,null,null,null,"... ", "J'espère que ça peut aider...", "C'est pas grand chose...", "J'ai pas trouvé mieux..." ],
		[ "Hop,hop,hop !", "C'est encore moi qui fait tout", "Avec ça, on va avancer" ],
		[ "A moi de jouer !!", "Regarde, je fais des paillettes !!", "Il est beau mon sort, non ?", "J'aurais dû mettre plus de rose dans ce sort" ],
		[ "Je suis pas trés sûre du résultat", "Je pensais pas être capable de ça", "C'est moi qui ai fait ça?", "Aahhh qu'est-ce-qui se passe?" ]

	]

	static var helpOk = [
		[ "Ok, je m'occupe de tout", "Je m'en occupe!", "Compte sur moi!", "Je suis là, pour t'aider!", "Je prépare un sort pour toi..."],
		[ "Qui ça ? Moi ?", "Euh où ça ?", "Tu as besoin de moi ?", "Heu, qu'est-ce que je vais faire...", "Un sort ? Euuh maintenant ?" ],
		[ "Pffff....", "Encore !?", "Pourquoi tu demandes pas à $other de lancer des sorts ?","Tu peux rien faire sans moi ?", "Comme si j'avais le choix...", "Ca devient systématique avec toi...", "Et voilà...", "Bien sûr, tu peux pas t'en sortir tout seul...", "Je regrette tant de t'avoir accompagné" ],
		[ "Regarde un peu ça", "Laisse moi faire", "Tu vas voir mes sorts sont six fois plus puissants que ceux de $other !","Arrête de pleurer, et regarde l'artiste", "C'est mon tour de briller !", "Regarde un peu de quoi je suis capable!", "Ce sort va t'époustoufler" ],
		[ "Youpi !! ", "Un peu d'action !", "A moi de jouer !", "Je vais faire un truc marrant !", "Attention les yeux !", "Pompulinu! pouvoir magique !", "Kaaa Maa Naaa Maa... NAAAAH !" ],
		[ null,null,null,"Ah ?", "D'accord...", "Pourvu que je sois à la hauteur...", "Ne me mets pas la pression !", "... ", "Je vais essayer", "tu..tu crois que..que je peux le faire ?" ],
		[ "C'est encore moi qui m'y colle ?", "Je dois tout faire ici", "Ok, un sort et on passe au prochain niveau", "Tout de suite", "Et un sort vite fait!!" ],
		[ "Tu veux un coup de main ?", "Tu as besoin de moi ? C'est vrai ?", "Tu peux me faire confiance, j'ai jamais raté un sort", "Ouaaiiss, regarde ça !!", "Je vais te montrer quelque chose !!", "Attention les yeux!!", "j'aaarrrrriiivvveee!!!!" ],
		[ "Je vais essayer", "Tu veux pas que $other le fasse?", "Qui ça? moi?", "Pourvu que ca marche", "Je peux pas me cacher dans le bocal plutôt?"]
	]

	static var helpNoMana = [
		[ "Je n'ai plus de magie !","J'ai besoin de me reposer","Je peux pas t'aider avant d'avoir récupéré","Résiste au mieux pendant que je récupère mes forces magiques !"],
		[ "J'ai plus de force magique !", "Je me sens un peu faible tout à coup...","J'ai besoin de me reposer","Je peux pas t'aider avant d'avoir récupéré"],
		[ "Je peux plus rien faire, fallait m'économiser...", "Réfléchis un peu...", "Si tu avais été plus malin, on serait pas en panne de mana.", "Tu crois que je peux lancer autant de sorts que tu veux ?", "Hoooo, je n'ai plus de mana, trop dommage... *sifflote*" ],
		[ "Sans mana, même moi je peux rien faire !", "Laisse moi le temps de rassembler mes forces magiques...", "Je me repose un peu et ensuite, je casse tout !", "Donne moi juste une minute ou deux, et je nettoie le niveau !" ],
		[ "Pas de mana, pas de chocolat !", "Sans mana, les fées sont moins sympas !", "Sans mana, C'est pas la joie !", "C'est super la mana, sauf quand il y en a pas !","Je viens de me souvenir d'un sort surpuissant, mais j'ai plus assez de mana !!", "Je peux pas là j'ai piscine"],
		[ "Je suis désolée...", "Je n'y arrive pas", "Je suis fatiguée, désolée" ],
		[ "Je peux pas tout faire non plus", "Plus de mana, faut que tu te débrouilles", "Laisse moi un moment, et ensuite je casse tout", "Plus de mana, ça avance pas" ],
		[ "OOOUUIINNN !!! J'ai plus de manaaaa !!", "Faut que je range ma chambre là", "Promis, je t'aide dans un moment", "Dès que j'ai du mana, je te montre un truc génial !!", "Hé attends tu sais pas ce qu'elle m'a dit $other ? Quoi c'est pas le moment?", "Abracadabra je disparais... Mais non je rigole rooh!!" ],
		[ "ben pkoi ca marche pas?", "J'ai besoin de repos", "Peut-être que $other a du mana elle?", "Je vais aller ranger mon bocal", "Et si on appelait Harry Potter?" ]
	]

	static var SENT_GET_FOOD = [
		[	// LIKE
			[ "Chouette ! $food !", "$food, youpiii" ],
			[ "$food ? Ca sent bon !", "$food, hum ça a l'air bon" ],
			[ "$food ? On aura pas perdu la journée !", "$food, je vais enfin manger correctement" ],
			[ "Héhé, voici ma récompense : $food !!", "$food, je vais me régaler" ],
			[ "$food ! C'est super bon !", "$food, ca a l'air bon"],
			[ null, "$food ! Quelle chance !" ],
			[ "Hmm, je vais me régaler!", "$food, j'espérais en trouver"],
			[ "$food, Ouais, je vais me régaler j'adore ça, c'est génial", "Au diable le régime, vive la gourmandise!!" ],
			[ "$food ? Ca sent bon !", "Chouette ! $food !" ]
		],
		[	// DISLIKE
			[ "$food...", "Dommage, $food"  ],
			[ "Beurk c'est quoi ça ?", "Oh noooonn!! Pas $food" ],
			[ "$food !? Tu as interêt à le jeter!", "fais venir un goûteur, je ne touche pas à ça sans être sûre","Pouah et tu penses que je vais manger ca?", "Je préfère encore partir si tu n'as que ça à me donner" ],
			[ "$food !? Compte pas sur moi pour manger ça !", "Je sens que je vais faire un regime moi!"],
			[ "Mon dieu ! Ne me dis pas que tu vas garder ça !", "Je préfère mourir que de cohabiter avec $food !"],
			[ "*soupir*", "Dommage"],
			[ "$food! tout ça pour ça?", "$food, faut jeter ça !!" ],
			[ "$food! Beurkkk, comment on peut manger ça ?", "Soit on le jette, soit on le donne à $other", "J'espère que t'as faim parce que je mange pas ça moi" ],
			[ "Beurk, encore un truc qui va moisir", "Vu que j'en mange pas on peut peut-être le jeter non?" ]
		],
		[	// RARE
			[ "Oh !! $food ! On en voit pas souvent !"],
			[ "Ah, Enfin ! $food ! C'est pas trop tôt !"],
			[ "Oh !! $food ! On en voit pas souvent !"],
			[ "Oh !! $food ! ah, enfin, pas trop tôt, un met digne de moi" ],
			[ "Oh !! $food ! On en voit pas souvent !"],
			[ "Oh !! $food ! On en voit pas souvent !"],
			[ "Oh !! $food ! On est vraiment pas venus pour rien !" ],
			[ "Waw!! $food!! C'est super rare, y a de quoi être super youpi-framboise" ],
			[ "$food!! ça c'est rare!!" ]
		],
		[	// OTHER
			[ "$food !", "Oh, $food", "tiens? $food, on partagera avec $other" ],
			[ "Ho, on dirait $food.", "$food!" "Tiens? $food, ca faisait longtemps!", "tiens? $food, on partagera avec $other" ],
			[ "Encore $food...", "$food...", "$food, hé ben voila le repas de ce soir", "tiens? $food, on partagera avec $other" ],
			[ "$food !", "$food, c'est déjà ca", "$food, Au moins, ça cale l'estomac", "tiens? $food, on partagera avec $other" ],
			[ "$food !", "Au moins, ça cale l'estomac", "tiens? $food, on partagera avec $other" ],
			[ null, "...", "tiens? $food, on partagera avec $other" ],
			[ "On perd notre temps avec ça", "juste $food", "tiens? $food, on partagera avec $other" ],
			[ "$food !", "$food, Tu crois que c'est bon avec du chocolat ?", "$food, C'est pas mauvais pour ma ligne au moins ?", "Ca va être sympa pour décorer le bocal", "tiens je comptais en acheter chez superfée", "tiens? $food, on partagera avec $other" ],
			[ "$food !", "$food, hé ben voila le repas de ce soir", "tiens? $food, on partagera avec $other" ]
		]
	]

	static var SENT_GET_ITEM = [
			[ "Cool ! $item !", "$item, ça c'est cool!"],
			[ "Ah c'est quoi ce truc ?", "Tiens ! Un nouveau machin !", "Houla ! C'est quoi ca ?" ],
			[ "Encore $item !", "$item ? Bof...", "Toujours les mêmes objets...", "Voilà de la nouvelle quincaillerie..."],
			[ "Grâce à moi on a récupéré $item !", "$item !!! Rien que pour moi !", "$item ! Je l'ai bien mérité..." "Maintenant c'est à moi" ],
			[ "$item ? Trop de la balle !!","Avec $item à la main, j'ai peur de rien !","La vie c'est comme une boîte de chocolat..." ],
			[ null,"$item , J'espère que ça te plaît...", "... "],
			[ "Bon, on prend ça et on y va", "$item, ça pourra toujours servir" ],
			[ "Waw,$item, mais qu'est ce qu'on va en faire ?", "Oh, c'est quoi ça ?", "Tu crois que c'est utile ?", "$item, je veux tester ça !!!", "Youki je sais pas ce que c'est mais Youki!!" ],
			[ "Ca a une drôle de forme tu crois que ça se mange?", "Ah c'est quoi ce truc ?", "Et ça va m'aider ca?", "Je pourrais me cacher avec tu crois?" ]
	]

	static var SENT_DAMAGE = [
		[ "ouch !", "Aie !", "Ouille !" ],
		[ "ouch !", "Aie !", "Ouille !" ],
		[ "ouch !", "groumf !", "argh !", "maais...euh !" ],
		[ null,null,"Même pas mal !", "J'ai rien senti !" ],
		[ "ouch !", "Aie !", "Ouille !" ],
		[ null, "..." ],
		[ "Aouch !", "Aie !", "Ouille !" ],
		[ "Aie !", "Ouille !", "Mais eeuuhh !", "Ouch !" ],
		[ "Aouch !", "Aie !", "Ouille !""maais...euh !" ]
	]

	static var SENT_HEART_DAMAGE = [
		[ "Aie ! Aie !","Ca fait mal !","à l'aide !"],
		[ "Aie ! Aie !","Ca fait mal !","à l'aide !","au secours", "là c'est sûr je vais avoir une cicatrice"],
		[ "Aaaargh !","Oouch !","Argh ! Ca fait un mal de chien !!", "là c'est sûr je vais avoir une cicatrice"],
		[ null,null,"arrhh !", "C'est bon tout va bien !", "Ca y est je suis énervée", "Mais c'est qu'il ferait mal en plus ce petit truc qui vole" ],
		[ "Aie ! Aie !","Ca fait mal !","à l'aide !"],
		[ "ouch !","Aie !"],
		[ "Ca va se payer ça !", "Ca fait mal", "C'est pas qu'ils m'ont fait mal, mais j'ai maaallll", "Fée gaffe à toi!!", "C'est la salsa du démon!" ],
		[ "Aiiieeuuhhh, ça fait mal", "Mais je leur ai rien fait moi !", "Au secours !!!!", "Aide moi !!", "Appelle $other pour venir m'aider !!!" ],
		[ "T'as pensé à la trousse de premier soin??", "J'appelle Sos fée battue !", "J'aurais dû rester cachée", "Mais il fait que me jeter des trucs dessus", "Hé mais aide moi!!"]
	]


	static var SENT_GAME_AMBIENT_NORMAL = [
		[ null,null,"Allez encore un effort !","Il nous faut une super combo !","Concentre toi sur le jeu, tu peux sûrement trouver une faille !","Persévère !","Concentre toi","Essaie de repérer les groupes de billes les plus importants !","Ne libère pas plusieurs démons à la fois !"],
		[ null,null,"Tiens ? je suis déjà venue ici...","Tu as vu mon collier ? $other me l'a prêté !","Mince j'ai fait tomber une boucle d'oreille","Ho ! Je crois que j'ai vu un kikooz derrière ce buisson","C'est quoi ce champignon ?!","Tu as déjà entendu parler de l'arc-en-ciel ?","Je suis super mal coiffée aujourd'hui...","J'ai un peu soif...","Il n'y a pas un autre moyen d'explorer cette contrée ?", "Faut que j'aille chez la manucure, à force de me battre j'ai les mains toutes abimées", "Et si je me colorais les ailes pour les assortir à ma tenue?" ],
		[ null,"Ca fait combien de temps qu'on est partis ?","La prochaine fois, demande plutôt à $other de t'accompagner.","Il y aurait pas un autre mode de jeu... où je suis pas obligée de venir?", "Je crois que je préfère encore être enfermée dans un bocal","J'aurais mieux fait de rester dans mon bassin moi...","Si j'avais su, je serais pas venue.","Engagez-vous qu'ils disaient...","J'aurais dû rester couchée ce matin","J'ai pas de bol.", "*soupir*"],
		[ "Je m'ennuie","Tu as pas un truc à faire pour moi ?","Que penses-tu de moi ? Je suis bien meilleure que $other n'est-ce pas ?","Si je récupère assez de magie...","Je prépare un super coup !","Qu'ils viennent les démons !! Je les attends !","J'ai un plan d'attaque infaillible pour le prochain démon","$other ne m'arrive pas à la cheville !","Regarde ce que j'arrive à faire avec mes ailes !!","Il faudra que je parle de mes exploits aux autres en rentrant","Après toutes ces aventures, je vais devenir une fée très populaire !!"],
		[ null,null,"Hier, $other et moi on a pas mal parlé de toi...","C'est qui le malade qui entasse toutes ces billes ?","Ils sont pas serrés, les démons, dans les capsules ?","Ca manque de couleurs par ici!!","Je me demande ce qu'il y a par là !","On devrait monter un cirque !","Tu peux pas voler ?","Mais finalement, c'est quoi l'univers ?","C'est pas vraiment l'endroit où j'aimerais vivre...","On l'a pas déjà vu ce niveau ?","Dis, t'aurais pas vu Nalika par hasard ? Je lui ai prété mes paillettes, et elle ne me les a pas rendues...","Tu sais ce que ça fait, du chocolat dans un champs de blé ? hihi","*chante* A l'aventure Compagnon, je suis partie vers l'horizon...","Il est sympa Gaspard, hein ? Je rigole bien avec lui","Tu crois qu'on pourrait invoquer Ornegon ?","J'aimerais des sandales pour aller avec ma jupe" ],
		[ null,null,null,null,null,"hum...","Tu penses qu'on forme une bonne équipe...?","J'espère que je ne te décevrais jamais !","Je préfère ta compagnie à celle des autres fées... *rougit*", "Je suis mieux avec toi qu'avec $other...*rougis*" ],
		[ "Une super combo et on y va !!", "Dépêche toi, je veux voir plus loin", "Bon, tu entasses des billes ou tu les fais disparaître ?", "Plus rapide c'est possible ?", "Appuie vers en baaaassssss !!!"],
		[ "J'aimerais bien rencontrer une mini-pouss, c'est un peu comme une fée sans ailes", "Je me demande si $other ne s'ennuie pas trop", "*fait une bulle de chewing-gum*", " Mdamirma m'a prédit Une b'nne configurati'n Frutale", "On est pas déjà passés par là ?", "Ca manque de couleurs par ici!", "J'ai un peu soif...", "Tu crois que je devrais réamménager mon bocal ?", "C'est quoi ta couleur préférée ?", "Tu me donnes ton adresse MSN ?", "A.S.V. pour tout le monde !!", "J'ai quand même l'impression qu'on tourne en rond", "On devrait sortir d'ici, je suis sûre qu'on est perdus", "C'est quand que j'apprends un nouveau sort ?", "T'as pas vu passer une tzongre ?", "Dis, tu crois que je serai modératrice, un jour ?", "Je me suis battue avec Gomola hier... il voulait me voler $like!", "Tu t'es déjà fait totocher ? Moi oui, plein de fois !", "Dis, tu me prêtes des kikooz ? J'ai envie de m'acheter un chapeau... Alleeeer, s'il te plaaaiiit..."],
		[ "Argh!! Ah non rien c'est mon ombre", "Dis je peux me cacher derrière toi?", "Aaaaah quelque chose m'a touchée!! ... Ah c'est juste du lierre...", "C'est ca que tu appelles s'amuser?", "Et si on rentrait à la maison", "Tu préfèrerais pas qu'on joue à swapou?", "Il a l'air sympa le coin la bas pour se cacher...", "C'est quand même un peu sombre ici", "C'est quoi ce bruit? T'as entendu?", "On aurait dû amener $other avec nous", "On devrait rentrer tant que le démon n'y est pas"]

	]

	static var SENT_GAME_AMBIENT_BATTLE = [
		[ "Je retiens les démons, profites-en","Il a l'air coriace, mais je peux le vaincre","Concentre-toi sur le jeu, les démons c'est mon boulot !","Je m'occupe du démon, essaie de finir vite !"],
		[ "Argh ! Il est affreux celui-là !","Ces démons sont incroyablement résistants !","Je me demande d'où viennent ces démons", "Je vais essayer de te débarasser de ce monstre","Wah, il a failli me toucher !", "Oups, j'ai failli me froisser une aile", "Ils ont l'air bizarre les trucs qui volent là!" ],
		[ "Ce démon m'a mise en colère !","Je ne peux pas supporter ces démons","Tu nous as mis dans de beaux draps...", "Ca va chauffer pour toi le démon !", "Arrête de libérer des démons s'il te plait!!", "Ca va chauffer", "Mais pourquoi tant de violence, si ça se trouve ils sont gentils" ],
		[ "Ce démon ne tiendra pas longtemps !", "C'est l'affaire d'une seconde", " Tu vas voir je vais l'écraser cette souris ailée", "On t'as jamais dis de ne pas embêter les filles??", "Coup de tête, balayette!!", "Ca va chauffer!!", "Ils sont en baisse de forme les démons là non?", "Je connais un démon qui va se prendre un coup de coiffe bigoudène", "Va y avoir de la ratatouille de démon"],
		[ null,null,null,"Hé ! Je le reconnais celui-là ! C'est le chef de la bande, celui avec la mèche !","Y'a un démon qui a la même façon de voler que $other!"," Beurk! il a une tête de chou-fleur ce démon","Ils sont plutôt lents ces démons...", "Ca va chauffer", "Tremblez démons ! La superbe $name va vous écraser !!","Ils sont pas trés beaux ces démons...","Houla celui-là est vraiment affreux","C'est pas un démon rose que j'ai vu à l'instant ?","Regarde ce coup là, c'est Piwali qui m'a appris ! hé hé"],
		[ null,null,null,null,null,null,"Je vais mettre toutes mes forces dans la bataille","Je vais bloquer ces démons !"],
		[ "Je m'en occupe, concentre toi", "Qu'est ce qu'il est moche celui-là !", "Je le finis, et je reviens t'aider", "Tu penses y arriver tout seul ?", "Je m'en débarasse avant même que tu finisses le niveau", "Il va nous faire perdre notre temps ce démon!" ],
		[ "Houlaaaa, plus ils sont gros plus ils sont moches ces démons", "Il me faudrait une tapette à démon", "Y'a un démon qui a la même façon de voler que $other !", "Je m'en occupe, tu me regardes hein ?", "Super $name Attack, ça sonne bien ?" "Mais ils sont rapides quand même !!", "Attention je vais sortir ma super attaque : fourchette pow@@@", "Kowabungaaa" ],
		[ "J'aurais pas dû venir", "Je me méfierai des balades avec toi la prochaine fois", "Pourquoi ça tombe sur moi?", "Ne jamais suivre quelqu'un dans une forêt ça finit toujours mal je le savais" ]
	]
	static var SENT_GAME_AMBIENT_FINISH = [
		[ null,null,"Persévère! Tu y es presque !","Y'a plus grand chose à faire ! Tiens bon !","Le prochain niveau est bientôt en vue !","Il n'y a plus de danger désormais..."],
		[ null,null,"Y'a plus grand chose de ce niveau...","Pourquoi on s'en va pas ?","Quand est-ce qu'on s'arrache d'ici ?","Ca fait un peu vide maintenant..."],
		[ null,null,null,"Pfff... On se traîne...", "Bon si tu perds maintenant, tu es irrécupérable","Tu en as pour longtemps ?", "ah ben voilà c'est à ton niveau là"],
		[ "Bon, je pense que tu pourras finir sans moi !", "Je te laisse finir le niveau.", "C'est presque fini !" ],
		[ null,null,"Aie, je me suis froissée une aile !", "Ce niveau était vraiment super !", "Oh regarde !... Ah non rien..." ],
		[ null,null,null,null,null,null,"Ce niveau était sympa...", "Tu t'es bien débrouillé sur ce niveau"],
		[ "Bon, là tu peux finir vite", "C'est fini, on va au prochain !!", "Rien qu'un petit effort", "Je pars devant, tu me rejoins", "Tu peux pas jouer plus vite?"  ],
		[ "Hé! Tu t'es bien débrouillé là!", "Bon, ça a l'air calme là maintenant", "Bon, je vais m'asseoir et regarder la fin", "J'espère que le prochain sera aussi simple", "Tu veux pas que je fasse un sort ?" ],
		[ "Mince j'ai plus rien pour me cacher", "c'est pas possible il va nous arriver une tuile", "c'est trop beau pour être vrai", "C'est presque fini !" ]
	]

	static var SENT_GAME_AMBIENT_STRESS = [
		[ "Ne te relâche pas ! Tu peux encore t'en sortir", "Rien n'est perdu, reste bien concentré !", "Tu peux encore y arriver"],
		[ null,null,null,null,"Houla, ça sent le roussi", "Ca va aller ?" ],
		[ null,"Et voilà, on est foutus !","Alors là, je vois pas comment tu vas t'en sortir","Tu joues vraiment mal...","C'est pas comme ça qu'on va avancer...","Ca sent la fin...","Je savais que ça finirait comme ça...", "bon les erreurs c'est fait, les jolis coups tu as ?"],
		[ "Tu veux un coup de main ?", "Avec un peu de mana, je peux nettoyer le plateau !!", "Tu vas t'en sortir tout seul ?", "Tu penses pouvoir t'en sortir sans moi ?"],
		[ null,null,"Hola, je veux pas voir ça !","Houlala c'est la méga catastrophe !","Bon, ben... on se retrouve dehors ?", "T'aurais pas des problèmes avec ton clavier?" ],
		[ null,null,null,"Tiens bon !","Je suis de tout coeur avec toi...","Je ne sais pas quoi faire pour t'aider..."],
		[ "respire, respire", "calme toi, on va pas arrêter maintenant", "bon, là, tu peux prendre ton temps", "comment t'as pu entasser tout ça ?", ],
		[ "Ah, là c'est sûr, c'est dommage le coup de tout à l'heure", "Je suis sûre que si tu te concentres bien, c'est faisable", "Je voudrais vraiment t'aider", "Et en fait quand on est là, il se passe quoi ?", "C'est pas très bon là, non ?" "mais comment t'as fait pour arriver si haut?"],
		[ "Bon, ben, je crois que c'est l'heure de rentrer", "je te l'avais bien dit qu'il fallait rester à la maison", "j'ai pris des coups pour rien ...", "tout ca pour ca?" ]

	]

	// MENU

	static var SENT_NEW_DAY = [
		[ "Bonjour !","Bonjour ! Tu as bien dormi ?","Salut ! Tu vas bien aujourd'hui ?","Salut ! Tu as vu ? Il fait beau aujourdhui !" ],
		[ "Bonjour !","Bonjour ! Tu as bien dormi ?","Salut ! Tu vas bien aujourd'hui ?","Bonjour, on va jouer !?", "Hey! On s'est déjà vus quelque part non?" ],
		[ "J'espère que tu vas me ficher la paix aujourd'hui !","Tiens, le sergent est de retour...", "Je suis là pour personne aujourd'hui.", "Compte pas sur moi pour t'aider aujourdhui !", "Tu connais le mot DORMIR ??", "Ah? T'es de retour? Bon, finies les vacances!", "Ah !!!! C'est de pire en pire tu as pensé à la chirurgie ?" ],
		[ "Bonjour !","Salut !","Bonjour, on va jouer !?","Salut ! Tu reviens me voir ?", "Salut, y'avait un démon qui rôdait cette nuit, je lui ai réglé son compte", "Hello, tu viens chasser les démons avec moi ?" ],
		[ "Coucou !","Coucou ! Alors la vie est belle ?","Salut ! Tu as vu ? Il fait beau aujourdhui !","Bonjour, on va jouer !?","Salut ! Tu reviens me voir ?","Bonjour !","Bonjour ! Tu as bien dormi ?","Salut ! Tu vas bien aujourd'hui ?","Salut machin ! Tu vas bien ?", "Salut ! Ne fais pas trop de bruit, $other dort encore","Salut ! Je viens de terminer de déjeuner"],
		[ null,"... ","Bonjour...","Bonjour, tu as bien dormi...?","Euh... Salut!","Coucou... Tu vas bien ?" ],
		[ "Ah enfin, te voilà !! On va chasser du démon ?", "Bien reposé ? alors on y va ?", "Salut, on va jouer ?", "Salut ! Avec $other, on t'attendait pour jouer" ],
		[ "Ah t'es revenu !! Je t'attendais", "Bonjour ! Tu as vu il fait super beau aujourd'hui !", "Bonjour! Tu as bien dormi ?", "Coucooouuuu !! Ca va bien ? On t'attendait avec $other", "$other m'avait dit que tu viendrais!!" ],
		[ "Salut ! Tu reviens me voir ?", "Bonjour !","Salut !", "Bonjour! Tu as bien dormi ?" ]
	]

	static var SENT_ENTER_MENU_FIRST = [
		[ null, null, "Pendant que tu étais parti, je t'ai cueilli des fleurs !","$other et moi on t'a préparé un bouquet !","Ah te voilà ! Allons dans la forêt !", "Tu étais où ?", "J'ai un peu dormi pendant ton absence."],
		[ null, null, "Je me suis ennuyée sans toi !", "Ahh ! Je t'ai pas vu arriver !", "Ho ? Tu es là depuis longtemps", "J'ai un peu dormi pendant ton absence.", "Tu étais parti où ?", "J'ai eu peur, je t'avais perdu de vue" ],
		[ null, null, "Moi qui pensais que tu étais parti pour de bon...", "Tiens ? Tu as réussi à retrouver ton chemin tout seul ?","Mince, tu m'as retrouvée...","Tu comptes encore aller te perdre dans la forêt ?", "Si tu veux aller te pommer dans la forêt, ça sera sans moi...", "Oups, j'aurais dû aller me planquer dans le bassin !"],
		[ "Je me suis entraînée pendant ton absence !", "Je me suis entraînée contre $other, et je l'ai battue à plate couture !", "Ah te voilà ! Allons dans la forêt !", "Tu es de retour ? Partons à l'aventure !", "J'ai failli partir à la forêt sans toi...", "Je sais pas ce que j'ai, je pète la forme aujourd'hui"],
		[ null, null, "Bon on va récupérer de nouveaux machins magiques dans la forêt ?", "Je ne sais pas si c'est une bonne idée de rester ici...",  "J'ai battu $other au sumo, pendant ton absence !!", "Tu étais parti alors j'en ai profité pour décorer ton sac", "J'ai pas eu le temps de finir mon bouquet, attends encore un peu...", "Tu es parti m'acheter un cadeau ?" ],
		[ null, null, "*soupir*", "Tu m'emmènes faire une promenade ?" ],
		[ "C'est bon, on peut aller jouer ?", "Laisse $other tranquille, et viens jouer", "Je crois que j'ai vu un démon à la lisière de la forêt" ],
		[ "C'est une belle journée pour jouer non ?", "Il est joli ce moulin là bas !!", "J'ai eu peur, je t'avais perdu de vue", "C'est quoi ton adresse? Comme ça je pourrais t'envoyer plein choses !!", "Et si on rasait la forêt? Y aurait plus de démon, non?" ],
		[ "Il y a $other qui m'a dit qu'il y avait des démons dans la forêt, elle blaguait hein?", "Hé tu sais quoi, je suis la plus nulle de tes fées, vaudrait mieux partir avec une autre.", "Dis t'es sûr que c'est avec moi que tu veux jouer?", "Je resterais bien au bocal aujourd'hui pas toi?" ]
	]

	static var SENT_ENTER_MENU = [
		[ null,null,null,null,"Je crois que $other s'ennuie un peu...","Il faudrait faire un peu le tri dans ton sac"],
		[ null,null,null,null,"Si ça se trouve on pourrait devenir amis avec ces démons...","Il me rapelle de mauvais souvenirs ce bassin...","Ils servent à quoi tous ces objets dans ton sac ?","Quand est-ce que je pourrais apprendre de nouveaux sorts ?"],
		[ null,null,"Tu devrais vraiment penser à changer de coupe de cheveux...", "Enfin de retour, je crois que je vais faire une petite sieste","Ca fait cinq minutes qu'on est rentrés et je m'ennuie déjà","Je me demande si ces démons seraient prêts à embaucher une fée desespérée..."],
		[ "On part à l'aventure ! Je vais te montrer ce que je peux faire !","Tu as été long... On peut y aller maintenant ?","Si tu m'emmènes avec toi tu n'auras rien à craindre des démons","Allez ! On se bouge !","Je suis prête pour partir à l'aventure !","Allez !! On y va !","C'est parti !","Tu viens ? "],
		[ null,null,"J'aimerais savoir ce qu'il y a au coeur de cette forêt", "J'ai vu Gromelin rentrer dans le moulin hier soir" ],
		[ null,null,"*soupir*" "Tu voudrais aller jouer?" ],
		[ "Allez ! On se bouge !", "On laisse $other ici, et on va en forêt ?", "T'as tout rangé, on peut y aller ?", "Allez !! On y va !" ],
		[ "On part à l'aventure ! Je vais te montrer ce que je peux faire !", "J'ai beaucoup discuté avec $other", "Et en fait y a quoi au fond de la forêt?", "Allez !! On y va !", "C'est parti !", "Tu viens ? ", "Vive Frutiparc !" ],
		[ "Il fait un peu froid là non? Si on rentrait?", "Tu voudrais pas jouer tout seul pour changer?", "$other voudrait jouer il me semble", "J'aime pas trop la forêt ça me fait peur", " Y a des tucs bizarres dans la forêt on dirait" ]

	]

	static var SENT_MENU_AMBIENT = [
		[ null,null,null,null,"Je me demande ce que $other pense de moi..."," Tu crois que $other m'apprécie ?", "Qu'est ce qu'il peut bien y avoir dans ce vieux moulin ?", "Ca fait longtemps que j'ai pas mangé $like !","Tu penses aller à la forêt aujourdhui ?","Tu as entendu cet oiseau ?","Le ciel est vraiment découvert aujourd'hui !","Tu as vu ce nuage ? il ressemble à $cloud !"],
		[ null,null,null,null,"Quand est ce qu'on mange ?", "Ca fait longtemps que j'ai pas mangé $like !","Tu penses aller à la forêt aujourdhui ?","Le vent m'empèche de voler droit...","Je me demande si je reverrai un jour cet arc-en-ciel","Hihi ! Y'a un nuage qui ressemble à $cloud !"],
		[ null,null,null,null,"Je perds un peu plus chaque jour l'espoir de pouvoir à nouveau manger $like...","Allez va courir dans la forêt... Avec le bol que j'ai tu vas me ramener $dislike...", "Je ne souhaite une vie pareille à personne", "Arrête de bouger dans tous les sens, tu me rends malade !", "Pourquoi tu demandes pas à $other de t'aider plutôt ?","Tu penses aller à la forêt aujourdhui ?", "Dis, t'es sûr que c'est avec moi que tu veux jouer?", "Hé bé manque plus que Laura qui se casse la figure en fond et on se croirait chez les Ingalls." ],
		[ "Il me faut $like !","Je suis bien plus fort que $other","On fait une super équipe tous les deux, pas besoin de $other dans nos pattes...","Grâce à mon entraînement, je vais te débarasser de tous ces démons en un clin d'oeil !","Tu penses aller à la forêt aujourdhui ?","Ho !? Ce nuage on dirait $cloud !"],
		[ null,null,null,null,"Ca fait longtemps que j'ai pas mangé $like !","Il me faut $like ! Je suis accroc!","Tu penses aller à la forêt aujourdhui ?","Tu as entendu cet oiseau ?","Le ciel est vraiment découvert aujourd'hui !","Haha ! Il est marrant ce nuage on dirait $cloud !","j'ai été prendre un bain dans le bassin","*chante* A l'aventure Compagnon, je suis partie vers l'horizon..." ],
		[ null,null,null,null,null,null,null,null,"J'aimerais beaucoup avoir $like...","*soupir*","Ho... Ce nuage... On dirait $cloud...", "J'espère qu'on croise pas des ours dans cette forêt"],
		[ "Hé! y'a un nuage on dirait $cloud", "On va à la chasse au démon ?", "Si on allait chercher $like", "si on trouve $dislike, on l'offre à $other" ],
		[ "Ho!? Ce nuage on dirait $cloud !", "Quand est ce qu'on mange ?", "T'as déjà appuyé sur F5 en pleine partie ?", "Que ceux qui aiment les démons appuyent sur alt-F4", "Je me demande ce que $other pense de moi...", "Tu crois que $other m'apprécie ?", "Tu as entendu cet oiseau ?", "$other m'a confié un secret....Tu veux le savoir ?", "Ca fait longtemps que j'ai pas mangé $like, on va en chercher ?", "Je pourrais pas avoir un bocal vert ou rose? parce que le bleu à force...", "J'ai vu $other jeter toutes ses affaires tout à l'heure. Tu lui dis pas que je te l'ai dit, hein !!", "C'est quoi ton frutisigne?", "Je suis allée voir Mdamirma, elle m'a dit que j'étais poire ascendant banane", "Dis t'as des nouvelles de Mdamirma?", "Tu connais la blague de l'ascenseur? Ah moi non plus..." ],
		[ "Je sais que tu aimes les forêts mais on pourrait pas aller en ville hein?", "On pourrait rester ici et regarder les nuages", "J'aimerais beaucoup avoir $like...", "Tu as entendu cet oiseau ?", "Ho!? Ce nuage on dirait $cloud !"]

	]


	// MISSION

	static var MISSION = [
		{
			type:"Combat "
			test:[0,2]  // FORCE RAPIDITE LIFE INTEL CONCENTRA MANA
			desc:[
				"Liberer $victims du terrible $badName",
				"$badName terrorise $victims $fromLocation depuis $longTime, Volez à leur secours et terrassez cet ignoble bandit. Restez sur vos gardes durant cette mission$dif."
				"mis une bonne raclée à $badName. Grâce à vous $victims ont enfin retrouvé la liberté !"
				"pas réussi à éliminer $badName... $victims $fromLocation attendent toujours leur sauveur..."
			]
		},
		{
			test:[1,3,3,4]
			type:"Recherche "
			desc:[
				"$faerieName a perdu $lostObject $atLocation.",
				"Pauvre $faerieName !! $lostObject lui manque vraiment ! Se rendre $atLocation est$dif, vous devrez partir à l'aube pour avoir une chance de le retrouver avant les $day de cette mission. "
				"réussi la mission ! $faerieName a vraiment l'air youpi-framboise, grâce à vous elle a retrouvé $lostObject!"
				"pas réussi leur mission... $faerieName pleure à chaudes larmes $lostObject. "
			]
		},
		{
			test:[3,3,4]
			type:"Enquête "
			desc:[
				"Disparition mysterieuse de $faerieName.",
				"$faerieName n'est pas rentrée chez elle depuis plus d'une semaine. La dernière fois que nous l'avons vue, elle $actionPastFun autour $fromLocation. Il faut la retrouver à tout prix ! Relevez le défi de cette mission$dif !"
				"retrouvé $faerieName !! Elle s'était perdue près $2fromLocation"
				"pas retrouvé la trace de $faerieName... Cette mission est un échec"
			]
		}
		{
			test:[1,1,1,2]
			type:"Course "
			desc:[
				"Grand marathon$period $fromLocation",
				"Cette course est réputée pour être $dif, si vous arrivez au bout en moins de $day, vous remporterez un prix$super !"
				"gagné le marathon $fromLocation ! Le public applaudit cet exploit !"
				"pas fini le marathon $fromLocation à temps... Adieu la récompense..."
			]
		}
		{
			test:[3,3,3,1]
			type:"Enquête "
			desc:[
				"$faerieName s'est fait voler $lostObject !",
				"Elle se promenait gentiment $atLocation quand soudain, $lostObject lui fut arraché des mains par $thief... Retrouvez-le et récupérez le bien de $faerieName."
				"résolu le problème de $faerieName en retrouvant $lostObject! Félicitations, cette mission est un succès."
				"pas retrouvé $thief à temps. $faerieName ne reverra jamais $lostObject..."
			]
		}
		{
			test:[5,5,4]
			type:"Magie "
			desc:[
				"$kingdom est en danger !",
				"La barrière magique qui protège $kingdom est sur le point de céder sous les assauts $fromInvader... Utilisez vos pouvoirs magiques pour renforcer le sceau des prêtres !"
				"réussi à repousser les attaques $fromInvader, $kingdom est sauvé !! Cette mission est réussie !"
				"pas pu maintenir la barrière magique des prêtres assez longtemps. $kingdom a été envahi cette nuit même, par les troupes $fromInvader. Cette mission est un échec..."
			]
		}
		{
			type:"Concours "
			test:[3,4,4]
			desc:[
			    "Grand concours $funGame.",
			    "$kingdom organise son grand concours $funGame, vous allez devoir affronter de nombreux adversaires, et remporter un prix$super !"
			    "gagné le grand concours $funGame, cette victoire est fêtée dans tout $kingdom!!!"
			    "pas réussi à gagner le concours $funGame, il y avait de trés bons joueurs, tant pis pour la récompense..."
		    ]
        }
		{
			type:"Concours histoires "
			test:[3,3,4]
			desc:[
			    "Grand concours $history"
			    "La grande bibliothèque située dans $kingdom, organise un grand concours $history. Beaucoup de conteurs des contrées alentours vont se déplacer pour cette occasion."
			    "gagné le concours $history. Le public était trés nombreux, et a applaudi la performance"
			    "pas réussi à plaire au public du concours $history, le public a failli s'endormir"
			]
	       }

	]

	static var MISSION_DIF = [
		" très facile"
		" facile"
		" simple"
		" pénible"
		" difficile"
		" très difficile"
		" cauchemardesque"
	]

	static var MISSION_DIF_RANK = [
		"D "
		"C "
		"B "
		"A "
		"A+ "
		"A++ "
		"A+++ "
	]

	static var GROMELIN_OPEN = [
		"Grumph ?"
		"Mmmmh ?"
		"Grrr..."
		"Pfff.."
		"Grumph !"
		"Groumph !"
	]

	static var GROMELIN_HELLO = [
		"Ah c'est toi ?"
		"Tiens, c'est toi ?"
		"Oh... Encore toi ?"
		"Grrr...mmmh..."
		"Ah ! Te v'la..."
	]


	// WORD LIST
	static var TRUC = ["un truc","un machin","un nouveau truc","un nouveau machin","un bidule"]

	static var CLOUD_SHAPE = [
		"une autruche"
		"une bouteille"
		"un oiseau"
		"une aubergine"
		"un ananas"
		"un cheval"
		"un serpent"
		"une paire de ciseaux"
		"une main"
		"un visage"
		"une poule"
		"un trés gros morceau de sucre"
		"un panier"
		"une étoile"
		"un labrador"
		"un château"
		"$other"
		"un pichet"
		"une fourchette"
		"un sablier"
		"un kikooz"
		"une tzongre"
		"la bouille de Gaspard"
		"une totoche"
	]

	static var TOTOCHE_WORD = [
		"mmph!!"
		"mmm..."
		"m.."
		"..."
		"mmpf..."
		"pfmm!"
		"mn..mmm...!"
		"mmf"
		"mmh..mh"
		"...oummph"
		"...mm..."
		"gnmmmf..."
		"mpf!"
	]

	static var WORD_FROM_INVADER = [
		"des ignobles trolls des montagnes"
		"des impitoyables hommes-mangoustes du sud"
		"des affreux hommes-lezards"
		"de Krom le géant malicieux"
		"de Sakurim le dragon des océans"
		"des cruels tournesols des enfers"
	]

	static var WORD_LONG_TIME = [
		"plus de 7 ans"
		"des millénaires"
		"plus d'un siècle"
		"le début de la semaine"
		"plus de milles lunes"
		"des lustres"
	]

	static var WORD_HISTORY = [
		"d'histoires droles"
		"de contes"
		"de poemes"
		"d'enigmes"
		"du plus gros mensonge"
		"de legendes"
		"de fables"
		"d'histoires effrayantes"

	]

	static var WORD_FUN_GAME = [
		"d'echecs"
		"de dames"
		"de fruti belote"
		"de château de cartes"
		"de Pierre Feuille Ciseau"
		"du plus grand chiffre"
		"de charades"
		"de mime"
		"de rebus"
		"de dessins"
	]

	static var WORD_KINGDOM = [
		"le royaume des Euriglides"
		"le royaume de Fort Fort Lointain"
		"le royaume de Pompulinu"
		"le royaume de Timothé le chauve"
		"l'empire biramique"
		"l'empire de Chormi le sâge"
		"l'empire OrnoSimeen"
		"l'empire des fleurs sauvages"
		"Le college de magie de PocheVille"
		"Le fort misérable de Pocheville"
		"Le temple de Yurihle"

	]

	static var WORD_THIEF = [
		"un colibri envouté"
		"un chat très rapide"
		"une mygale farceuse"
		"une grenouille à moitié folle"
		"un lézard désespéré"
		"un singe alcoolique"
		"un écureuil avare"
		"un lutin cleptomane"
		"$2faerieName"
		"$badName"
		"un iguane très véloce"
		"une belette"
		"un lapin acrobate"
	]

	static var WORD_SUPER = [ // MASCULIN
		" super"
		" fabuleux"
		" incroyable"
		" fantastique"
		" génial"
		" vraiment hype"
		" complètement fumé"
		" hallucinant"
		" super tendance"
		" vraiment génial"
	]

	static var WORD_PERIOD = [	// MASCULIN // PAS DE CAR SPECIAUX
		" trimestriel"
		" annuel"
		" journalier"
		" de la semaine"
		" du siecle"
		" mensuel"
	]

	static var WORD_VICTIMS = [	// PAS DE CAR SPECIAUX
		"les nains"
		"les farfadets"
		"les coccinelles"
		"les libellules"
		"les trolls"
		"les poussins"
		"les lapinous"
		"les hommes champignons"
		"les tzongres"
	]

	static var WORD_FROM_LOCATION = [	// PAS DE CAR SPECIAUX
		"du moulin"
		"de la foret enchantee"
		"du cimetierre abandonne"
		"de la source endormie"
		"des champs de mais"
		"de la plaine voisine"
		"du champ de betterave"
		"de la ferme du vieux sam"
		"de la vallée de poro gora"
		"des bois sauvages"
		"du marais tondu"
		"du lac Tsonn"
		"de la cascade"
		"de Pochevile"

	]

	static var WORD_AT_LOCATION = [		// PAS DE CAR SPECIAUX
		"aux grottes d'Hammerfest"
		"a la riviere de Simedia"
		"a la vallée de poro gora "
		"au marais tondu"
		"a la clairiere du bucheron"
		"au mont Pigremel"
		"a la colline des anges"
		"au pic du sud"
		"au bout du monde"
		"derriere la dune de Moorg"
		"dans les bois obscures"
		"au frontière du royaume"
		"sur la route de PocheVille"
		"a l'eglise"
		"en pleine foret"
		"au milieu du rond point"
		"a la fête du village"
		"au restaurant"
		"a l'antre des hippos"
		"a la taverne de PocheVille"
		"a la cascade"
	]

	static var WORD_BAD_NAME = [		// PAS DE CAR SPECIAUX
		"Sorog le rouge"
		"Tourneboule le chetif"
		"Cormerone le sorcier"
		"Goyave le solitaire"
		"Tom tom le piment qui arrache"
		"Morkar le necromancien"
		"Bishamon le pourfendu"
		"Choh rizo le visqueux"
		"Pigrom le dodu"
		"Salum le berger diabolique"
		"Nedy le cavalier du tartare"
		"Goubij le calif menteur"
		"Gabaloom l'homme ours"
		"Birmain de Moquepaille"
		"Tocheto le bossu"
		"Polchoi le sinistre vampelin"
		"Cormocroute le rassi"
		"Shalala le menestrel déchu"
	]

	static var WORD_ACTION_PAST_FUN = [
		"prenait son déjeuner"
		"bronzait paisiblement au soleil"
		"dormait comme une bûche"
		"jouait au tennis avec $2faerieName"
		"détruisait un champignon à coups de masse"
		"peignait un nouveau tableau"
		"faisait du vélo"
		"s'entraînait au lancer de poids"
		"mangeait une cerise"
		"mangeait une frite"
		"faisait de la balançoire"
		"construisait une cabane"
		"déplaçait une grosse pierre"
		"portait un cafard sur son dos"
		"cultivait des carottes"
		"faisait du shopping"
		"discutait avec $2faerieName"
		"sculptait une morille"
		"jouait aux cartes avec $2faerieName"
		"faisait de la balançoire"
		"jouait à la marelle"
	]

	static var WORD_LOST_OBJECT = [		// PAS DE CAR SPECIAUX
		"sa theiere"
		"sa boucle d'oreille"
		"son nounours"
		"son sac"
		"son talisman"
		"sa bague en jade"
		"sa paire de ciseaux"
		"son journal"
		"son portefeuille"
		"une petite boite en forme de coeur"
		"une panier a fruits"
		"son disque vinyl de Dave"
		"sa cassette de Claude François"
		"son DVD des plus belles choregraphies de Tourneboule"
		"sa trousse de maquillage"
		"son telephone portable"
		"sa montre"
		"son epingle a cheveux"
		"son tube de vert à levres"
		"une dent"
		"son sandwich"
		"son sac"
		"sa carte de bus"
		"sa bouee jaune"
		"son livre d'images sur les orang-outans"
		"son epluche legume"
		"son ramasse banane"
		"son tir agrafes"
		"son velo d'appartement"
		"son ticket de tranport oie sauvage"
		"un poulet en caoutchouc avec une poulie au milieu"
		"une quantite incroyable de pin's collector de kaluga"
		"sa broche piwali"
		"sa mini frusion"
	]





	static function getSent(list){
		return list[Std.random(list.length)]
	}

	static function getItemFamily(n){
			if( 0 <= n && n < 30 ){
				return "un objet magique"
			}
			if( 40 <= n && n < 50 ){
				return Lang.TRUC[Std.random(Lang.TRUC.length)]
			}
			if( 50 <= n && n < 60 ){
				return "une orbe"
			}
			if( 60 <= n && n < 70 ){
				return Lang.TRUC[Std.random(Lang.TRUC.length)]+" coloré"
			}
			if( 70 <= n && n < 80 ){
				return "une potion"
			}
			if( 80 <= n && n < 90 ){
				return "un nouveau sac"
			}

			if( 100 <= n && n < 200 ){
				return "un parchemin"
			}

			if( 200 <= n && n < 300 ){
				return "un livre"
			}

			switch(n){
				case 30:
					return "un bocal"
					break;
				case 31:
					return "une clé"
					break;
			}

			return "un Kouglof"
	}


//{
}



















