class Game {

	var dmanager : DepthManager;
	var bg : MovieClip;
	var teddy : Teddy;
	var score : Score;
	var level : Level;
	var words : Words;
	var particules : Particules;

	var kflags : Array<bool>;

	function new(mc,wtbl) {
		dmanager = new DepthManager(mc);
		bg = dmanager.attach("bg",0);
		teddy = new Teddy(dmanager);
		score = new Score(dmanager);
		particules = new Particules(dmanager);
		level = new Level(this);
		words = new Words(wtbl);
		kflags = new Array();
	}

	function isDown(k) {
		if( k == 77 )
			return Key.isDown(77) || Key.isDown(188) || Key.isDown(186); // M
		return Key.isDown(k);
	}

	function main() {
		var i;
		var code_A = "$A".charCodeAt(1);

		for(i=0;i<26;i++)
			if( isDown(code_A+i) ) {
				if( !kflags[i] ) {
					kflags[i] = true;
					level.activateKey(code_A+i);
				}
			} else
				kflags[i] = false;

		if( !level.main() ) {
			score.finishCombo();
			KKApi.gameOver(score.stats);
		}

		teddy.main();
		score.main();
		particules.main();
	}

	function destroy() {
		dmanager.destroy();
	}

}