package ;
import api.AKApi;
import api.AKProtocol;
import Level;
import mt.kiroukou.math.MLib;
/**
 * ...
 */

class LevelGenerator
{
	
	//public static var EMPTY = 7;
	//public static var STONE = 6;

	public static var me:LevelGenerator;
	public var cColor:Int; //compulsory color
	public var colorSet:Array<Int>;
	var level : Int;
	public var linesNum:Int;
	
	var items:Matrix;
	
	//pk
	public static var  igpk:Array<SecureInGamePrizeTokens>;
	public var totalpk:Int;
	public var emittedpk:Int;
	
	public function new(_level:Int,_round:Int)
	{
		me = this;
		
		if(AKApi.getGameMode()==GM_PROGRESSION){
			level = _level - (8 -_round); //warmup sur 7 premieres etapes
			level = MLib.clamp(level, 1, _level);
			trace("warmup : Level " + _level + " + round " + _round + " = " + level);
		}else {
			level = _level;
		}
		
		/*init matrix*/
		items = [];
		for(c in 0...4) {
			items.push([]);
			for(i in 0...12) {
				var x = new Item();
				x.init(Item.TYPE_EMPTY, 0, i, c);
				items[c].push(x);
			}
		}
		
		/* ingame pk - inited only one time*/
		if(igpk ==null){
			igpk = AKApi.getInGamePrizeTokens();
			emittedpk = 0;
			for(pk in igpk) {
				totalpk += pk.amount.get();
			}
		}

	}
	
	
	public function randomColor() {
		return colorSet[Game.random(colorSet.length)];
	}
	
	/**
	 * generate level
	 */
	public function generate():Array<Array<Item>> {
	
		/*
		 Difficulty mgmt :
		 - more colors along levels
		 - timer is shortening along levels
		 - less empty blocs along levels ( -> more noise )
		 - stone if level>10
		 - different color mixup in lines if level > 12
		 - never same color in lines if level > 15
		 - variation : if partyId%3==0, there is no more 6 lines pattern after level 18.
		 */
		
		//testing color set
		//apply(function(item:Item) {
				//item.init(Item.TYPE_NORMAL, item.id%6 , item.id, item.cycle,getPk(),true);
		//});
		//return items;
		

		colorSet = getColorSet();
		cColor = colorSet[0];
		
		var pat = getBoolPattern();

		/* draw lines with DIFFERENT COLORS */
		var range = 0;
		if(level >= 15) {
			range = Game.random(colorSet.length);
		}else if(level >= 12) {
			range = 3;
		}else {
			range = 2;
		}

		apply(function(item:Item) {
				if(pat[item.cycle][item.id]) {
					
					item.init(Item.TYPE_NORMAL, colorSet[item.id%range] , item.id, item.cycle,getPk(),true);
				}
			});
		
		/* fill empties with random */
		var set = getColorSetExcluding(cColor);
		applyOnEmpties( function(item:Item) {
			
			var itemNum = item.cycle * 12 + item.id;
			
			var x = 0;
			if(level < 5) {
				x = 2;
			}else if(level < 10) {
				x = 3;
			}else if(level < 15) {
				x = 4;
			}else {
				x = 5;
			}
			
			//plus x est grand, moins il y aura de vide.
			if(itemNum % x == 0) {
				item.init(Item.TYPE_EMPTY, 0, item.id, item.cycle);
			}else {
				if (set.length == 1 && itemNum%3%2 == 1) {
					//cas spécial : trop peu de couleur , donc on rajoute du vide
					item.init(Item.TYPE_EMPTY, 0, item.id, item.cycle);
				}else {
					item.init(Item.TYPE_NORMAL, set[Game.random(set.length)], item.id, item.cycle,getPk());
				}
			}
			
		});
		
		/* STONE after level 10 */
		if(level > 10 && Game.random(10)%2==0) {
			var i = 0;
			while(i < 12 * 4) {
				var cycle = Game.me.seed.random(4);
				var id = Game.me.seed.random(12);
				//if(items[cycle][id].color != cColor) {
				if( !items[cycle][id].protected ) {
					var i = items[cycle][id];
					i.init(Item.TYPE_STONE, i.color, i.id, i.cycle);
					break;
				}
				i++;
			}
		}
		return items;
	}
	
	
	/**
	 * get a cycle pattern
	 */
	/*function getCyclePattern(cols:Array<Int>): Array<Int> {
		
		var out = [];
		
		//init : empty
		for(i in 0...12) out.push(EMPTY);
			
	
		//optionnel : coul 3 4 5
		if(cols.length > 1) {
			var x = 1;
			while(x < cols.length) {
				
				var type = getBoolCyclePattern(cols[x]);
				for(i in 0...12) {
					if(type[i] == true) {
						out[i]=cols[x];
					}
				}
				trace("+ passage couleur " + x + " : " + Level.COLORS_NAME[cols[x]]);
				x++;
			}
			
			
		}
		
		
		//troisieme passe (couleur obligatoire)
		var type = getBoolCyclePattern(cols[0]);
		for(i in 0...12) {
			if(type[i] == true) {
				out[i]=cols[0];
			}
		}
		trace("couleur obligatoire : "+Level.COLORS_NAME[cols[0]]);
		

		return out;
	}*/
	
	/**
	 * Color set
	 */
	function getColorSet():Array<Int> {
		var compulsoryColor = Game.me.seed.random(Level.COLORS_NUM) + 1;
		var cols = [compulsoryColor];
		
		/*
		* var lenght = Math.floor((level / 20) * 3);
		lenght = Game.random(lenght) +2; //amplitude sur 5 couleurs max
		*/
				
		var lenght = 2 + Math.floor(((level + 2.5) / 20) * 3);
		//trace("levle : "+level);
		//trace("xxxx "+((level + 2) / 20)+" colors");
		lenght = MLib.clamp(lenght, 2, Level.COLORS_NUM);
		
		//some cataclismo candy sometimes
		if(Game.random(5) == 0 && level > 15) {
			lenght = 2;
			trace("CATACLISMO CANDY!");
		}
		
		
		trace("needs "+lenght+" colors");
		/*find 3 different colors*/
		while(cols.length < lenght) {
			var c = Game.me.seed.random(Level.COLORS_NUM) + 1;
			if(!Lambda.has(cols, c)) {
				cols.push(c);
			}
		}
		trace("colorSet : "+cols);
		return cols;
	}
	
	public function getColorSetExcluding(c:Int) {
		var out = [];
		for(color in colorSet) {
			if(color != c) {
				out.push(color);
			}
		}
		return out;
	}
	
	/**
	 * generate bool pattern for a cycle
	 */
	function getBoolCyclePattern(col:Int):Array<Bool> {
		var type = [];
		
		/*type*/
		var r = Game.me.seed.random(12);
		for( x in 0...12 ) type.push(x % r == 0);
		
		//switch (r) {
			//case 0:
				///* tous les 3*/
				//for(x in 0...12) {
					//type.push(x % 3 == 0);
				//}
			//case 1:
				///* tous les 4*/
				//for(x in 0...12) {
					//type.push(x % 4 == 0);
				//}
			//case 2:
				///* tous les 2*/
				//for(x in 0...12) {
					//type.push(x % 2 == 0);
				//}
			//case 3:
				///* tous les 6*/
				//for(x in 0...12) {
					//type.push(x % 6 == 0);
				//}
			//case 4:
				///*tous*/
				//for(x in 0...12) {
					//type.push(x % 5 == 0);
				//}
			//case 5:
				///*1seul*/
				//for(x in 0...12) {
					//type.push(x == 0);
				//}
		//}
		
		//decalage
		r = Game.me.seed.random(12);
		
		var x = type.splice(type.length - r, r);
		type = type.concat( x );
		
		
		return type;
	}
	
	
	/**
	 * generate bool pattern for a whole level
	 */
	function getBoolPattern():Array<Array<Bool>> {
		
		//init matrix
		var out = [];
		for(c in 0...4) {
			var row = [];
			for(i in 0...12) {
				row.push(false);
			}
			out.push(row);
		}
		
		var r = Game.me.seed.random(4)+1;
		var type = [];
		switch (r) {
			case 1:
				if(level >= 18 && AKApi.getSeed() % 3 == 0) {
					/*pour créer variation de score, on supprime le pattern 6 lignes par un 3*/
					for(x in 0...12) {
						type.push(x % 4 == 0);
					}
					linesNum = 3;
					trace("PARTIE SANS PATTERN 6");
				}else {
					/* tous les 2 : 6 lignes*/
					for(x in 0...12) {
						type.push(x % 2 == 0);
					}
					linesNum = 6;
				}
				
			case 2:
				/* tous les 3 : 4 lignes*/
				for(x in 0...12) {
					type.push(x % 3 == 0);
				}
				linesNum = 4;
			case 3:
				/* tous les 4 : 3 lignes */
				for(x in 0...12) {
					type.push(x % 4 == 0);
				}
				linesNum = 3;
			case 4:
				/* tous les 6 : 2 lignes*/
				for(x in 0...12) {
					type.push(x % 6 == 0);
				}
				linesNum = 2;
		}
		
		out  = [type.copy(),type.copy(),type.copy(),type.copy()];
		return out;
	}
	
	
	function applyOnEmpties(cb: Item->Void) {
		for( c in 0...4) {
			for(i in 0...12) {
				var item = items[c][i];
				if(item.type == Item.TYPE_EMPTY) {
					cb(item);
				}
			}
		}
	}
	
	function applyOnCycle(cycle:Int,cb: Item->Void) {
		for(i in 0...12) {
			cb(items[cycle][i]);
		}
	}
	
	function applyOnId(id:Int,cb: Item->Void) {
		for(c in 0...4) {
			cb(items[c][id]);
		}
	}
	
	function apply(cb: Item->Void) {
		for( c in 0...4) {
			for(i in 0...12) {
				cb(items[c][i]);
			}
		}
	}
	
	function getPk():SecureInGamePrizeTokens {
		//init PK
		var pk = null;
		if(igpk.length > 0 && Game.random(4)==0) {
			
			if(AKApi.getGameMode() == GM_PROGRESSION && (emittedpk / totalpk) < Level.me.getProgression()) {
				pk = igpk.shift();
			}
			
			if(AKApi.getGameMode() == GM_LEAGUE && AKApi.getScore() > igpk[0].score.get()) {
				pk = igpk.shift();
			}
			if(pk != null) {
				emittedpk += pk.amount.get();
				trace("put " + pk.amount.get() + "PK in game");
				trace(Lambda.map(igpk,function(i) return i.amount.get() ));
			}
			
		}
		return pk;
	}
	
}