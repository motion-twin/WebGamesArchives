class Level {

	static var NRAILS = 3;
	static var XMIN = 60;
	static var BASE_Y = 80;

	var game : Game;

	var rails : Array<MovieClip>;
	var words : Array<Word>;
	var no_more_words : bool;
	var multi_probas : float;

	function new(g) {
		game = g;
		words = new Array();
		multi_probas = 10;
		no_more_words = false;
		initLevel();
	}

	function initLevel() {
		rails = new Array();
		var i;
		for(i=0;i<NRAILS;i++) {
			var b = game.dmanager.attach("etagere",1);
			b.gotoAndStop(string(3-i));
			b._x = 300;
			b._y = BASE_Y + i * 60;
			rails.push(b);
		}
	}

	function killWord(w) {
		var i;
		for(i=0;i<NRAILS;i++)
			if( words[i] == w ) {
				words[i] = null;
				multi_probas *= Math.pow(0.05,1 / game.words.nwords);
				return;
			}
	}

	function addWord() {
		var p = Std.random(NRAILS);
		if( words[p] != null )
			return;
		var w = game.words.get();
		if( w == null ) {
			no_more_words = true;
			return;
		}
		words[p] = new Word(game,w,BASE_Y - 15 + p*60);
	}

	function keyEqual(k1,k2) {
		if( k1 == k2 )
			return true;
		switch( k2 ) {
		case 65: return (k1 == 81); // A
		case 81: return (k1 == 65); // Q
		case 90: return (k1 == 87); // Z
		case 87: return (k1 == 90); // W
		default:
			return false;
		}
	}

	function activateKey(k) {
		var i;
		var n = 0;
		for(i=0;i<NRAILS;i++) {
			var w = words[i];
			var x = w.posX();
			if( x != null && keyEqual(k,w.currentLetter().charCodeAt(0)) ) {
				game.score.validKey(x - XMIN,w.speed);
				w.nextLetter();
				n++;
			}
		}
		if( n == 0 )
			game.score.invalidKey();
		else if( n > 1 )
			game.score.mixKey(n);
	}

	function main() {

		var i;
		var nr = 0;
		for(i=0;i<NRAILS;i++)
			if( words[i] != null )
				nr++;

		var r = int(100 * (nr * multi_probas + 0.1) / Timer.tmod);
		if( Std.random(r) < 3 )
			addWord();

		var flag = false;
		for(i=0;i<NRAILS;i++) {
			var w = words[i];
			w.main();
			if( w != null )
				flag = true;
		}
		if( !flag && no_more_words )
			return false;
		return true;
	}

}