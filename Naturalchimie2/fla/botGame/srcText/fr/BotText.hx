typedef PSpeak = {
	var frame : Int ;
	var text : String ;
}


class BotText {
	
	static public var TEXTS = [
	"L'alchimie c'est comme le saucisson, difficile de ne pas en reprendre une petite tranche.", //0
	"Aventure, réflexion, suspense, sales blagues... Tout ça dans un seul jeu ! ", //1
	"Naturalchimie, le jeu de réflexion qui ne donne pas mal à la tête !", //2
	"Faire du sport c'est bon pour la santé, Naturalchimie aussi !", //3
	"Depuis que j'ai essayé Naturalchimie, la vie est belle, le soleil brille et je suis à l'aise en société !", //4
	"Quitte à passer le temps sur internet, autant jouer à Naturalchimie.", //5
	"Naturalchimie, c'est aussi 250 recettes à collectionner pour combiner les éléments du jeu !", //6
	"Assembler les éléments 3 par 3 ? Mmmmh, ça a l'air facile...", //7
	"Elu meilleur jeu web de l'année par ses créateurs ! Oui messieurs dames !", //8
	"Ici, un bel exemple de partie en cours. Avec un magnifique décor dans le fond et des éléments à assembler de toute beauté...", //9
	"On est plus de 40 personnages dans ce jeu ! Mais franchement, c'est moi le plus beau...", //10
	"Répétez après moi : NA - TU - RAL - CHI - MIE ! ", //11
	"Chagrin d'amour ? Stress au travail ? Une petite partie de Naturalchimie et ça repart ! ", //12
	"Joueur occasionnel ou pro des classements, on a de quoi satisfaire tout le monde !", //13
	"En plus, l'inscription est gratuite et super rapide.", //14
	"Ras le bol de sauver des princesses et de tuer des monstres ? Essayez Naturalchimie ! ", //15
//halloween sentences : 
	"Mais ! Qu'est-ce que c'est que toutes ces citrouilles ! ? ", //16
	"Naturalchimie est envahi par des courges ! On a besoin de vous ! ", //17
	"En ce moment dans Naturalchimie, révélez la courge qui est en vous ! ", //18
	"Venez me retrouver en jeu, c'est la fête des Courgesprits ! ", //19
//xmas sentences : 
	"L'hiver est arrivé... C'est pas trop tôt !", //20
	"Joyeux Noël à tous les alchimistes ! ", //21
	"Venez faire le plein de surprises, en ce moment c'est Noël !", //22
	"Envie de balancer des boules de neige ? On a ce qu'il faut !", //23
	"Dites donc... Ca caille par ici, non ? ", //24
	] ;
	

	
#if halloween
	static public var PNJSPEAK : Array<PSpeak> = [
	{frame : 1, text : TEXTS[16]},
	{frame : 1, text : TEXTS[17]},
	{frame : 1, text : TEXTS[15]},
	
	{frame : 2, text : TEXTS[18]},
	{frame : 2, text : TEXTS[19]},
	{frame : 2, text : TEXTS[1]},
	
	{frame : 3, text : TEXTS[0]},
	{frame : 3, text : TEXTS[5]},
	{frame : 3, text : TEXTS[12]},
	
	{frame : 4, text : TEXTS[1]},
	{frame : 4, text : TEXTS[14]},
	{frame : 4, text : TEXTS[3]}
	] ;
#elseif xmas
	static public var PNJSPEAK : Array<PSpeak> = [
	{frame : 1, text : TEXTS[20]},
	{frame : 1, text : TEXTS[21]},
	{frame : 1, text : TEXTS[23]},
	
	{frame : 2, text : TEXTS[22]},
	{frame : 2, text : TEXTS[21]},
	{frame : 2, text : TEXTS[1]},
	
	{frame : 3, text : TEXTS[0]},
	{frame : 3, text : TEXTS[5]},
	{frame : 3, text : TEXTS[24]},
	
	{frame : 4, text : TEXTS[1]},
	{frame : 4, text : TEXTS[14]},
	{frame : 4, text : TEXTS[3]}
	] ;
#else 
	static public var PNJSPEAK : Array<PSpeak> = [
	{frame : 0, text : TEXTS[0]},
	{frame : 0, text : TEXTS[1]},
	{frame : 0, text : TEXTS[2]},
	{frame : 0, text : TEXTS[3]},
	
	{frame : 1, text : TEXTS[4]},
	{frame : 1, text : TEXTS[5]},
	{frame : 1, text : TEXTS[6]},
	
	{frame : 2, text : TEXTS[7]},
	{frame : 2, text : TEXTS[8]},
	{frame : 2, text : TEXTS[9]},
	
	{frame : 3, text : TEXTS[10]},
	{frame : 3, text : TEXTS[11]},
	{frame : 3, text : TEXTS[12]},
	
	{frame : 4, text : TEXTS[13]},
	{frame : 4, text : TEXTS[14]},
	{frame : 4, text : TEXTS[15]}
	] ;
#end
	
	
}