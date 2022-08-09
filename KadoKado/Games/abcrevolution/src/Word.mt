class Word {

	static var SPEEDS = [1,1,1,1,1.5,2,2,3,4];

	var game : Game;
	
	var mcs : Array<MovieClip>;
	var falling : Array<{ mc : MovieClip, speed : float, grav : float, reb : bool }>;
	var word : String;
	var pos : int;
	var y : float;
	var speed : float;
	var danger_flag : bool;

	function new(game,word,y) {
		this.game = game;
		this.word = word;
		this.y = y;
		this.pos = 0;
		this.speed = selectSpeed();
		danger_flag = false;
		falling = new Array();
		initWord();
	}

	function selectSpeed() {
		var n = Std.random(int(SPEEDS.length * 5 / word.length));
		if( n >= SPEEDS.length )
			n = SPEEDS.length - 1;
		return SPEEDS[n];
	}

	function initWord() {
		mcs = new Array();
		var n = word.length;
		var t = Std.random(10)+1;
		var i;
		for(i=0;i<n;i++) {
			var m = game.dmanager.attach("wordbox",1);
			m.gotoAndStop( string(1+Std.random(m._totalframes)) );
			downcast(m).typos.gotoAndStop(t);
			m._x = 310 + i * 23;
			m._y = y;
			downcast(m).typos.t.text = word.substr(i,1).toUpperCase();
			mcs.push(m);
		}
	}

	function posX() {
		return mcs[0]._x;
	}

	function currentLetter() {		
		if( mcs[0]._x > 290 )
			return null;
		return word.substr(pos,1).toUpperCase();
	}

	function nextLetter() {
		var m = mcs[0];		
		mcs.remove(m);
		pos++;
		var i;
		for(i=0;i<5;i++)
			game.particules.addWordPart(m._x,m._y,m._currentframe);
		m.removeMovieClip();		
	}

	function main() {
		var i;
		var sc = speed;

		if( mcs[mcs.length-1]._x > 290 )
			sc = 10;

		for(i=0;i<mcs.length;i++) {
			var m = mcs[i];
			m._x -= sc * Timer.tmod;
			m._y = y + Std.random(3) - 1;
			if( !danger_flag && m._x < 80 ) {
				danger_flag = true;
				game.score.danger();
			}
			if( m._x < Level.XMIN ) {
				pos++;
				game.score.falling();
				mcs.remove(m);
				i--;
				falling.push({
					mc : m,
					speed : speed,
					grav : speed,
					reb : false
				});
			}
		}
		for(i=0;i<falling.length;i++) {
			var m = falling[i];
			m.grav += Timer.tmod;
			m.speed *= Math.pow(0.97,Timer.tmod);
			m.mc._x -= m.speed * Timer.tmod;
			m.mc._y += m.grav * Timer.tmod;
			m.mc._rotation -= m.grav * 5 * Timer.tmod;
			if( !m.reb && m.mc._y > 230 ) {
				game.teddy.hit(m.mc._x,m.mc._y,m.grav);
				m.grav *= -0.6;
				m.reb = true;
			}
			if( m.reb && m.mc._y > 320 ) {				
				falling.remove(m);
				i--;
				m.mc.removeMovieClip();				
			}
		}
		if( falling.length == 0 && mcs.length == 0 )
			game.level.killWord(this);		
	}

}