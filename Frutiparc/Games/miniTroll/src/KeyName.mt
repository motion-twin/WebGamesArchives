class KeyName{

	static var LIST:Array<String>
	
	static function init(){
		LIST = new Array() ;
		var i=0;
		// Premier passage pour remplir de "?"
		for (i=0;i<256;i++)
			LIST[i] = "?";

		// Les lettres normales
		for (i=65;i<=90;i++)
			LIST[i] = String.fromCharCode(i);

		// Les chiffres
		for (i=48;i<=57;i++)
			LIST[i] = String.fromCharCode(i);

		// Les chiffres du pavé numérique
		for (i=96;i<=105;i++)
			LIST[i] = "PavNum "+(i-96);

		// Touches spéciales du pavé
		LIST[106] = "PavNum *" ;
		LIST[107] = "PavNum +" ;
		LIST[108] = "PavNum Entrée" ;
		LIST[109] = "PavNum -" ;
		LIST[110] = "PavNum Suppr" ;
		LIST[111] = "PavNum /" ;

		// Touches de fonction
		for (i=112;i<=123;i++)
			LIST[i]= "$F" + (i-111) ;

		// La partie lourde: tout le reste !
		LIST[8] = "$Retour";
		LIST[9] = "$TAB";
		LIST[13] = "$Entrée";
		LIST[16] = "$Majuscule";
		LIST[17] = "$Controle";
		LIST[18] = "$Alt";
		LIST[20] = "Verr.Maj.";
		LIST[27] = "$Echappe";
		LIST[32] = "$Espace";
		LIST[33] = "Page préc.";
		LIST[34] = "Page suiv.";
		LIST[35] = "$Fin";
		LIST[36] = "$Début";
		LIST[37] = "$Gauche";
		LIST[38] = "$Haut";
		LIST[39] = "$Droite";
		LIST[40] = "$Bas";
		LIST[45] = "$Insérer";
		LIST[46] = "$Supprimer";
		LIST[47] = "$Aide";
		LIST[144] = "$VerrNum";
		LIST[186] = "$$ £";
		LIST[187] = " =  +";
		LIST[189] = "- _";
		LIST[191] = ": /";
		LIST[192] = "ù %";
		LIST[219] = "° )";
		LIST[220] = "* µ";
		LIST[221] = "^ ¨";
		LIST[222] = "²";
		
		
		for( i=0; i<LIST.length; i++ ){
			if( LIST[i].substr(0,1)=="$" ){
				LIST[i] = LIST[i].substring(1)
			}
			
		}
		
	}
}