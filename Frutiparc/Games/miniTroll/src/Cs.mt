class Cs{//}

	static var mcw = 	240;
	static var mch = 	240;
	
	static var caracMax = 	8;
	
	static var FAERIE_LEVEL_MAX = 50
	
	// ELEMENT
	static var E_TOKEN = 		0
	static var E_ITEM = 		1
	static var E_STONE = 		2
	static var E_CELL = 		3
	static var E_BOMB = 		4
	static var E_FIREBALL = 	5
	static var E_EYE = 		6
	
	// CARAC
	static var POWER = 		0
	static var SPEED = 		1
	static var LIFE = 		2
	static var INTEL = 		3
	static var WISDOM = 		4
	static var MANA = 		5
	
	// BEHAVIOUR
	static var PSYCHOANALYST =	0
	static var CANNIBALISM = 	1
	static var CLEPTOMAN =		2
	static var APATHY =		3
	static var SCHYZO =		4
	static var HYPOCONDREAC =	5
	
	// MOOD
	static var M_NUMB =		0
	static var M_DISEASE =		1
	
	// STATUS
	static var SILENCE =		0
	static var POISON = 		1
	static var NEED_MORAL =		10
	static var NEED_HEAL =		11
	static var NUMB =		12
	static var DISEASE =		13

	// SPECIAL POWER
	static var POW_INVISIBILITY =		0
	static var POW_FEAR =			1
	static var POW_REGENERATE_LIFE =	2
	static var POW_REGENERATE_MANA =	3
	static var POW_EXP =			4
	static var POW_BERSERK =		5
	static var POW_TOTOCHE =		6
	
	// HELP
	static var HELP_FIRST_FAERIE =		0
	static var HELP_ORNEGON =		1
	static var HELP_GROMELIN =		2
	
	
	static var base:Base;
	static var game:Game;
	static var aventure:base.Aventure;
	
	static var spell:Array<Spell> = []
	
	static var frict:float;
	
	static var impColorList:Array<Array<int>> = [
		[ 0xE2EB3F, 0xA3D51E ],
		[ 0xFF9900, 0xD87C0E ],
		[ 0x9F0B0B, 0xE21010 ],
		[ 0x540505, 0x9F0B0B ],
		[ 0x000000, 0xF9E266 ]
	]
	
	static var colorList = [
		0xFF3300,
		0xFFCC00,
		0x33DD00,
		0x00DDFF,
		0x0088FF,
		0x9900DD,
		0xFF44DD,
		0xFF8800
	]	
	
	static var bagLimit = [0,4,6,8,9]
	static var treeLimit = [500,1000,2000,4000,8000]
	
	
	static var shootBase = 180
	static var dashBase = 260
	static var impSpellRate = 400
	static var itemRate = 2
	static var ambientRate = 500


	static var sDay = 86400000
	
	
	// Get SPECIFIC
	static function getLevelMax(n){
		return Math.pow( n+1, 1.8 )*1000
	}
	
	static function getKeyCoef(){
		var c = 0
		for( var i=0; i<10; i++ ){
			if( Key.isDown(96+i) ){
				c = i
			}
		}
		for( var i=0; i<10; i++ ){
			if( Key.isDown(48+i) ){
				c += i*10
			}
		}
		if( c == 0 ) c = 1;
		return c;
	}
	
	// GENERAL
	static function mm(min,n,max){
		return Math.min(Math.max(min,n),max)
	}
	
	static function round(n,lim){
		while(n>lim) n -=lim*2
		while(n<-lim)n +=lim*2
		return n
	}
	
	static function indexOf(list,n):int{
		for(var i=0; i<list.length; i++ ){
			if(list[i]==n)return i;
		}
		return null;
	}
	

	
//{
}
















