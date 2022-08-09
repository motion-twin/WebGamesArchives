


// PROTOCOLE

typedef _DataGame = {
	
	_wid:Int,								// ID du monde ( 0 par défaut )
	
	_road:Array<{ _x:Int, _y:Int }>,
	_savePoint:{_x:Int,_y:Int},
	_islands:Array<_IslandStatus>,
	_god:Int,
	
	_hearts:Int,
	
	_items:Array<_Item>,
	_carts:Array<_Cartridge>,
	_inv:_Inventory,
	
	_plays:Int,
	_dailyPlays:Int,					// +3 par jours
	_rainbows:Int,						// +3 par jours
		
}

typedef _Cartridge = {
	_id:Int,
	_lvl:Int,
}

typedef _Inventory = {
	_key:Int,

	_volt:Int,
	_fireball:Int,
	_tornado:Int,
	
	_cheese:Int,
	_knife:Int,
	_leaf:Int,
}

typedef _DataAction = {
	_action:_PlayerAction,
}

typedef _DataConfirm = {
	_done:String,
	_url:String,
}

enum _IslandStatus {
	ISL_UNKNOWN;
	ISL_EXPLORE(a:Array<Int>,reward:_Reward);
	ISL_DONE;
}

enum _PlayerAction  {
	_Play(squareId:Int);							// Le joueur lance une partie sur [squareId] de l'ile		// DEPENSE 1x PLAY
	_GameResult(win:Bool,a:Array<_GameBonus>);		// Le joueur fini une partie								// DEPENSE les Bonus dans [a]	// frag++;
	_Grab( squareId:Int, reward:_Reward );			// Le joueur ramasse un truc sur [squareId] de l'ile		// DEPENSE 1x Key si reward est un chest
	_MoveTo(x:Int, y:Int);							// le joueur se déplace vers l'ile aux coord x,y			// DEPENSE 1x RAINBOW
	_Teleport;									// le joueur se téléporte vers la savepos
	_Burn(squares:Array<Int>, bonus:_IslandBonus);	// Le joueur explose les case [squares]						// DEPENSE 1x [bonus];			// frag+=a.length;
	
	_Prism;											// Le joueur active le prisme								// DEPENSE 1x PLAY 		--> GAGNE 3x rainbow
	_Dice(succes:Bool);								// Le joueur active les dés									// DEPENSE 1x RAINBOW 	--> si success GAGNE 1x PLAY
	
	_FeverXPlay;									// Le joueur lance une partie FeverX						// DEPENSE 1x PLAY
	_MajCartridge(c:_Cartridge);					// Le joueur maj son hiscore sur la cartouche
	_SavePos(id:Int);								// Sauvegarde la position en cours ( premiere pos de road ), enregistre le dieu id
	
	_EndGame(id:Int);								// Fini le jeu : id = 0 > explore id = 1 > next island.
	
}

enum _Reward  {
		
	// CHEST
	Item(item:_Item);
	IBonus(b:_IslandBonus);
	IceBig;						// 20x 	Parties sup;
	Heart;						//
	Cartridge(id:Int);			// 100x
	Portal;						//
	
	// GROUND
	Ice;						// 5x	Parties sup
	Key;						// ouvre un coffre
	GBonus(b:_GameBonus);		// Bonus en jeu
	
}

enum _IslandBonus {
	Volt;			// Détruit un monstre / eclair
	Fireball;		// Détruit tous les monstres / pluie de meteores
	Tornado;		// Fait glisser un monstre ( doit mourir ! );
}

enum _GameBonus {
	Cheese;			// récupère tous les coeurs
	Leaf;			// finit un niveau
	Knife;			// un points de dégats sur le monstre si il a plus d'un coeur
}

enum _Item {
	
	Cocktail;		// descend de 10° la température au début de chaque match
	Book;			// Le joueur peut sélectionner un jeu interdit.
	Shoes;			// marche plus vite
	Mirror;			// Les méduses ne tuent plus en un coups.
	Clover;			// TODO : clignote si une cartouche est a proximité
	Voodoo_Doll;	// Les monstres commencent a -1.
	Voodoo_Mask;	// Vous pouvez passez automatiquement un jeu par combat en appuyant sur la touche "V".
	
	Wand;			// Ouvre les coffres verts
	Google;			// permet de voir la liste des jeux du monstre le plus proche.
	Radar;			// Voir la carte des alentours
	Prisme;			// Convertit un glaçon en 3x rainbow
	FeverX;			// console de jeu ( = mode endurance )
	Umbrella;		// +1 rainbow par jour
	Dice;			// une chance sur 6 de changer un rainbow en glaçon bleu
	
	Windmill;		// lorsque vous perdez un duel, la température ne monte pas.
	IceCream;		// +1 glaçon bleu par jour.
	Hourglass;		// +25% de temps sur les jeux de reflexion.
	ChromaX;		// La FeverX consomme des arc-en-ciel.n
	MagicRing;		// les monstres brutaux n'infligent qu'un seul dégat.
	Fork;			// 10% de chance d'infliger deux dégats
	RainbowString;	// Téléporte sur la dernière statue touchée
	
	Rune_0;
	Rune_1;
	Rune_2;
	Rune_3;
	Rune_4;
	Rune_5;
	Rune_6;


				
}


// GAME
typedef IslandData = {
	geo:IslandGeo,
	dif:Float,
	walls:Array<Bool>,
	rew:_Reward,
	statue:Int,
}
typedef IslandGeo = {
	size:Int,
	wallSum:Int,
	monsters:Array<Int>,
	nativeReward:_Reward,
}

typedef GameData = {
	_id:Int,
	_name:String,
	_desc:String,
	_acc:Int,
	_weight:Int,
	_type:Int,
}
typedef MonsterData = {
	_id:Int,
	_name:String,
	_life:Int,
	_atk:Int,
	_tempStart:Int,
	_tempInc:Int,
	_tempMax:Int,
	_rangeFrom:Int,
	_rangeTo:Int,
	_weight:Int,
	_anim:String,
	_gameFam:String,
	_gameSpecial:String,
	_oy:Int,
}

typedef FeverParams = {
	noEntry:Int,
}

enum EntType {
	EOther;
	EMonster;
	EBonus;
	EJumpStone(di:Int);
	
}

#if flash
typedef IslandElement = { sp:pix.Element, type:Int };
#end

enum PlayerMode {
	PM_Adventure( data:MonsterData, seedNum:Int );
	PM_FeverX( gameId:Int );
}

// RANKING



typedef _RankCall = {
	_s:_DataRankType
}

enum _DataRankType {
	RT_FRIENDS ;
	RT_GROUP(name : String) ;
}

typedef _DataRanking = {
	_me : String,
	_groups:Array<_DataRankType>
}

typedef _DataRank = {
	_name:String,
	_list:Array<_DataRankInfo>
}
typedef _DataRankInfo = {
	_name:String,
	_url:String,
	_avatar:String,
	_wid:Int,
	_hearts:Int,
	_items:Array<_Item>,
	
	_isl_visited:Int,
	_isl_done:Int,
	_frags:Int,
	_carts:Int,
	_statues:Int,
	
	_score:Int,
}

// NOTER STATUES
// NOTER FRAGS


// MODE DE JEU
// >> ARCADE ( jeu infini )
// >> AVENTURE ( 1 partie par jour )


// AVENTURE ITEM :
// marteau vert : enfonce les clous plus vite.
// 50x jeux a débloquer.
// 3x vies supplémentaires.

// AVENTURE ISLAND BONUS
// [perm] obelisque ( + 1 vie sur tous les niveaux de l'ile ).
// [conso] clé : ajoute une clé a la reserve
// [conso] coffre : a ouvrir avec une clé ( contient un item ou des glaçons ).
// [conso] glaçon : +1 un glaçon supplémentaire.
