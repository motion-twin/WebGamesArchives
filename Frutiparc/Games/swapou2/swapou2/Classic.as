import swapou2.Manager;
import swapou2.Data;
import swapou2.Sounds;

class swapou2.Classic extends swapou2.Challenge {

	var level;
	var lup;

	function gameParams() {
		var me = this;
		function gen_fruit_flags() { return me.genFruitFlags(); }
		function gen_fruit_color() { return me.genFruitColor(); }
		return {
			width : Data.CHALLENGE_LEVEL_WIDTH,
			height : Data.CHALLENGE_LEVEL_HEIGHT,
			min : 2,
			gen_fruit_flags : gen_fruit_flags,
			gen_fruit_color : gen_fruit_color
		}
	}

	function gameInit() {
		// NOTHING
	}

	function Classic( mc ) {
		super(mc);
		ncoups = 1;
		level = 0;
		interf.classicMode();
		player.genLine();
	}

	function genFruitFlags() {
		return 0;
	}

	function genFruitColor() {
		var nfruits = Math.min(level+2,11);
		return random(nfruits);
	}

	function main() {
		if( ncoups > Data.CLASSIC_LEVELS[level] ) {
			ncoups = 0;
			level++;
			lup = Std.cast( depth_manager.attach("levelUp",Data.DP_LAST) );
			lup._x = Data.CHALLENGE_X + Data.DOCWIDTH/2;
			lup._y = Data.DOCHEIGHT ;
			lup._visible = false;
			lup.sub.field.text = "Niveau "+level;
			lup.stop();
		}
		if( lup != null && !lock ) {
			lup._visible = true;
			lup.play();
			lup = null;
		}
		super.main();
	}

}