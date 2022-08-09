
typedef Artefact = {
	var id : ArtefactId ;
	var freq : Int ;
}


typedef GameData = {
	var mode : String ;
	var chain : mt.flash.PArray<ArtefactId> ;
	var chWeight : mt.flash.PArray<Int> ;
	var artefacts : mt.flash.PArray<Artefact> ;
	var helps : Array<{id : ArtefactId, help : String}> ;
	
}


enum ArtefactId {	
	//éléments simples
	Elt(e : mt.flash.Volatile<Int>) ;
	//groupe d'éléments à jouer
	Elts(nb : Int, p : ArtefactId) ; //p parasit
	
	// artefacts 
	Alchimoth ;
	Destroyer(e : Int) ;
	Dynamit(v : Int) ;
	Protoplop(level : Int) ;
	PearGrain(level : Int) ;
	Dalton ;
	Wombat ;
	MentorHand ;
	Jeseleet(level : Int) ;
	Delorean(level : Int) ;
	Dollyxir(level : Int) ;
	RazKroll ;
	Detartrage ;
	Grenade(level : Int) ;
	Teleport ;
	Tejerkatum ;
	PolarBomb ;
	Pistonide ;
	Patchinko ;
	
	
	//auto falls 
	Block(level : Int) ;
	Neutral ;
	
	//utils
	Pa ; //potion de vigueur
	Stamp ; //chouette timbres
	Joker ; //joker pour les recettes : n'importe quel élément accepté dans le chaudron
	

}


