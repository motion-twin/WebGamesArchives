interface Card {//}
	
	
	var $time:{$t:int,$d:int,$s:int}
	
	var $frog:bool;
	
	var $vs:float;			// NUMERO VERSION DE LA CARTE
	var $bag:int;			// TAILLE DU SAC A DOS
	
	var $key:int;
	var $star:int;
	var $diam:int;
	var $checkpoint:int;
	var $current:int;

	
	var $wind:float
	
	var $god:Array<bool>
	var $help:Array<bool>
	
	var $inv:Array<int>
	var $faerie:Array<FaerieSeed>
	
	var $pond:{$fs:FaerieSeed,$d:int,$q:int};
	var $dungeon:{$lvl:int,$f:bool, $day:int, $loop:int };
	var $rainbow:{$f:bool, $day:int, $it:int };
	
	var $mission:Array<Array<int>>	// DIF, TYPE , DUREE, GIFT, SEED
	
	var $mis:Array<{$d:int,$gift:int,$type:int,$string:String}>	// DUREE, GIFT, TYPE, SEED
	
	var $stat:{ 
		$run:int, 
		$game:Array<int>, 	// FOREST / POND / CASTLE / RAINBOW / TREE
		$item:Array<bool>, 
		$eat:Array<int>, 
		$kill:Array<int>,
		$forestMax:int,
		$treeMax:int,
		$misNum:int
	}		
	
	
//{	
}