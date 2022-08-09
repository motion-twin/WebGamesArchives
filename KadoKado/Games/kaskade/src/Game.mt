class Game {

	var level : Level;
	var particules : Particules;
	var dmanager : DepthManager;
	var nlevels : int;
	var stats : {
		$l : int,
		$t : Array<int>,
		$g : Array<int>
	};

	function new(mc) {
		dmanager = new DepthManager(mc);
		particules = new Particules(dmanager);
		stats = {
			$l : 0,
			$t : [],
			$g : []
		};
		nlevels = 0;
		level = new Level(this);
	}

	function main() {
		particules.main();
		level.main();
	}

	function gameOver() {
		KKApi.gameOver(stats);
	}

	function destroy() {
	}

}