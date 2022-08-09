import swapou2.Manager;
import swapou2.Data;
import swapou2.Sounds;
import swapou2.TItem;

class swapou2.Challenge {

	var interf;


	var mc_color;
	var mc;
	var lock;
	var depth_manager;
	var player;
	var ncoups;
	var special_power;
	var star_counter;
	var pause : swapou2.Pause;

	function gameParams() {
		var me = this;
		function gen_fruit_flags() { return me.genFruitFlags(); }
		function gen_fruit_color() { return me.genFruitColor(); }
		return {
			width : Data.CHALLENGE_LEVEL_WIDTH,
			height : Data.CHALLENGE_LEVEL_HEIGHT,
			min : Data.CHALLENGE_MIN_COMBO,
			gen_fruit_flags : gen_fruit_flags,
			gen_fruit_color : gen_fruit_color
		}
	}

	function gameInit() {
		var i;
		for(i=0;i<3;i++)
			player.genLine();
	}

	function Challenge( mc ) {

		Sounds.playMusic(Sounds.MUSIC_CHALLENGE);
		TItem.combo_nitems = 0;

		ncoups = 5;
		star_counter = Data.CHALLENGE_STAR_COUNTER;
		depth_manager = new asml.DepthManager(mc);

		player = new swapou2.Player(this,Data.players[0],gameParams(),Data.GAMEX,Data.GAMEY, true);
		interf = new swapou2.InterfChallenge(this,depth_manager);
		pause = new swapou2.Pause(depth_manager, [],Data.CHALLENGE_X);

		var me = this;
		function game_press() {
			me.gameClick();
		}

		this.mc = mc;
		mc.onMouseDown = game_press;
		mc.useHandCursor = false;
		special_power = false;
		setLock(false);

		gameInit();
	}

	function send(from,fruit) {
		// NOT IN CHALLENGE !
	}

	function getPool(playfor) {
		return [];
	}

	function setLock(flag) {
		lock = flag
		interf.setLock(flag);
	}

	function depthManager() : asml.DepthManager {
		return depth_manager;
	}

	function getPower(context,mc) {
		interf.addPower(0,mc);
	}

	function getPlayer() {
		return player ;
	}

	function genFruitFlags() {
		var is_armure = ( random(130) < random(ncoups) );
		var is_noswap = !is_armure && ( random(250) < random(ncoups) );
		var is_star = !is_armure && !is_noswap && ((--star_counter) == 0);
		if( is_star )
			star_counter = Data.CHALLENGE_STAR_COUNTER;
		//if( !is_armure && !is_noswap && random(10) == 0 )
		//	is_star = true;
		//if( ncoups > 30 && random(200) == 0 )
		//	return Data.FLAG_SET_COLOR | (3 << 8);
		return (is_armure?Data.FLAG_ARMURE:0) | (is_star?Data.FLAG_STAR:0) | (is_noswap?Data.FLAG_NOSWAP:0);
	}

	function genFruitColor() {
		return random(Data.CHALLENGE_MAX_COLORS);
	}

	function destroy() {
		mc.onMouseDown = undefined;
		interf.destroy();
		player.destroy();
	}

	function turnDone(p,combo) {
		interf.updateScore(player.score);
		if( special_power && player.noMoreLine() )
			special_power = false;
		if( special_power == false && !player.genLine() ) {
			interf.gameOver(true);
			interf.pl[0].face.setDead(0xFFFFF);
			player.gameOver(false);
			var g = Manager.gameOver(player.score);
			if( Data.gameMode == Data.CLASSIC )
				g.winTitem(TItem.classicItems(Std.cast(this).level));
			else
				g.winTitem(TItem.combo_nitems);
		} else {
			player.updateSudden();
			special_power = false;
			setLock(false);
			if( player.panic() )
				interf.pl[0].face.panic();
			else
				interf.pl[0].face.normal();
			if( player.combo_score > Data.CHALLENGE_HAPPY_SCORE )
				interf.pl[0].face.setHappy(Data.CHALLENGE_HAPPY_TIME);
		}
	}

	function gameClick() {
		if( lock || pause.activated() )
			return;
		var fpair = player.getPair(Std.xmouse(),Std.ymouse() );

		if( player.swapPair(fpair) ) {
			Manager.client.nswaps++;
			ncoups++;
			setLock(true) ;
		}
	}


	function defend() {
		if( !lock && player.canDefend() ) {
			setLock(true) ;
			special_power = true;
			player.defend();
		}
	}

	function iaAttack() {
		// ONLY FOR DUEL
	}

	function iaDefend() {
		// ONLY FOR DUEL
	}

	function main() {

		if( pause.main() )
			return;

		var fpair = null;
		if( !lock )
			fpair = player.getPair(Std.xmouse(),Std.ymouse());

		interf.displayPair(fpair);
		player.main();
		interf.main();
	}

}