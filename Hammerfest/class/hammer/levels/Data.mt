class levels.Data
{
	var $map			: Array<Array<int>>;
	var $badList		: Array< levels.BadData >;

	var $playerX		: int;
	var $playerY		: int;

	var $skinTiles		: int;
	var $skinBg			: int;

	var $specialSlots	: Array< {$x:int,$y:int} >;
	var $scoreSlots		: Array< {$x:int,$y:int} >;

	var $script			: String;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		$map = new Array();
		for (var x=0;x<Data.LEVEL_WIDTH;x++) {
			$map[x] = new Array();
			for (var y=0;y<Data.LEVEL_HEIGHT;y++) {
				$map[x][y] = 0;
			}
		}

		$playerX		= 0;
		$playerY		= 0;
		$skinBg			= 1;
		$skinTiles		= 1;
		$badList		= new Array();

		$specialSlots	= new Array();
		$scoreSlots		= new Array();

		$script			= "";
	}
}

