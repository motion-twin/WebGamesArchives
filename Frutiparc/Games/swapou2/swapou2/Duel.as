import swapou2.Data;
import swapou2.Manager;
import swapou2.Sounds;
import swapou2.TItem;
import swapou2.Client;

class swapou2.Duel {

	var interf : swapou2.Interf2P;
	var depth_manager;
	var player,ia;

	var player_timer;
	var ia_timer;

	var mc : MovieClip;
	var game_over_flag;
	var game_over_screen;

	var pl_lock;
	var ia_lock;
	var player_special_combo;
	var ia_special_combo;
	var ia_star_counter;
	var pl_star_counter;

	var iaface,plface;

	var pause : swapou2.Pause;
	var pool;
	var pool_for_ia;

	function duelParams(is_ia) {
		var me = this;
		function gen_fruit_flags() { return me.genFruitFlags(is_ia); }
		function gen_fruit_color() { return me.genFruitColor(is_ia); }
		return {
			width : Data.DUEL_LEVEL_WIDTH,
			height : Data.DUEL_LEVEL_HEIGHT,
			min : Data.CHALLENGE_MIN_COMBO,
			gen_fruit_flags : gen_fruit_flags,
			gen_fruit_color : gen_fruit_color
		}
	}

	function Duel( mc ) {
		if( Data.gameMode != Data.DUEL ) {
			if( Data.gameMode == Data.HISTORY && Data.histoPhase == 6 )
				Data.difficulty = 3; // Wasabi 2nd
			else
				Data.difficulty = 2;
		}

		Sounds.playMusic(Sounds.MUSIC_DUEL);

		depth_manager = new asml.DepthManager(mc);
		interf = new swapou2.Interf2P(this, depth_manager);
		player = new swapou2.Player(this,Data.players[0],duelParams(false),Data.DUEL_PLX,Data.DUEL_PLY,false);
		ia = new swapou2.IAPlayer(this,Data.players[1],duelParams(true),Data.DUEL_IAX,Data.DUEL_IAY,Data.IA_TIMES[Data.players[1]][1]);
		pause = new swapou2.Pause(depth_manager,[Std.cast(player),Std.cast(ia)],0);

		plface = interf.pl[0].face;
		iaface = interf.pl[1].face;

		pool = new Array();
		ia_star_counter = Data.DUEL_IA_STAR_COUNTER[Data.difficulty];
		pl_star_counter = Data.DUEL_STAR_COUNTER;

		var i;
		for(i=0;i<3;i++) {
			player.genLine();
			ia.genLine();
		}

		var me = this;
		function onGameClick() {
			me.gameClick();
		};
		mc.onMouseDown = onGameClick;
		game_over_flag = false;
		game_over_screen = null;

		pool = new Array();
		pool_for_ia = false;
		player_special_combo = false;
		ia_special_combo = false;

		playerStart();
		iaStart();
	}

	function send(from,fruit) {
		if( from == player ) {
			if( pool_for_ia )
				pool.push(fruit);
			else {
				if( pool.length > 0 )
					pool.splice(pool.length-1,1);
				else {
					pool.push(fruit);
					pool_for_ia = true;
				}
			}
		} else { // from == ia
			if( pool_for_ia ) {
				if( pool.length > 0 )
					pool.splice(pool.length-1,1);
				else {
					pool.push(fruit);
					pool_for_ia = false;
				}
			} else
				pool.push(fruit);
		}
		interf.updatePool(pool,pool_for_ia);
	}

	function sendTo(to,fruit) {
		if( to == player )
			send(ia,fruit);
		else
			send(player,fruit);
	}

	function setPlLock(flag) {
		interf.setLock(flag) ;
		pl_lock = flag ;
	}

	function playerStart() {
		setPlLock(false) ;
		player_timer = Data.DUEL_MAX_TIME[Data.difficulty];
	}

	function iaStart() {
		ia_lock = false;
		ia_timer = Data.IA_TIMES[Data.players[1]][0];
		ia.start();
	}

	function depthManager() {
		return depth_manager;
	}

	function genFruitFlags(is_ia) {
		var is_armure = (random(10) == 0);
		var is_noswap = !is_armure && (random(40) == 0);
		var is_star;

		if( is_ia ) {
			is_star = !is_armure && !is_noswap && ((--ia_star_counter) == 0);
			if( is_star )
				ia_star_counter = Data.DUEL_IA_STAR_COUNTER[Data.difficulty];
		} else {
			is_star = !is_armure && !is_noswap && ((--pl_star_counter) == 0);
			if( is_star )
				pl_star_counter = Data.DUEL_STAR_COUNTER;
		}		
		return (is_armure?Data.FLAG_ARMURE:0) | (is_star?Data.FLAG_STAR:0) | (is_noswap?Data.FLAG_NOSWAP:0);
	}

	function genFruitColor(is_ia) {
		return random(Data.DUEL_MAX_COLORS);
	}

	function getPool(pl : swapou2.Player ) {
		var iapl : swapou2.Player = Std.cast(ia);
		if( (pl == iapl && pool_for_ia) || (pl == player && !pool_for_ia) ) {

			if( pool.length > 0 ) {
				if( pool_for_ia )
					iaface.setHit(30);
				else
					plface.setHit(30);
			}
			var p = pool;
			pool = new Array();
			interf.updatePool(pool,pool_for_ia);
			return p;
		}
		return [];
	}

	function destroy() {
		mc.onMouseDown = undefined;
		player.destroy();
		ia.destroy();
		interf.destroy();
	}

	function sendFruits(pl,c,p) {
		var nsend = Data.sendFruits(pl == ia,c,p);
		while( nsend > 0 ) {
			send(pl,{ col : random(Data.DUEL_MAX_COLORS), flags : Data.FLAG_ARMURE, x : -1 });
			nsend--;
		}
	}

	function turnDone(pl,combo) {
		if( game_over_flag )
			return;

		if( pl == player ) {
			if( player.isGameOver() || (!player_special_combo && !player.genLine()) ) {
				game_over_flag = true;
				interf.gameOver(true);
				player.gameOver(false);
				ia.game_over_flag = false;
				plface.setDead(0xFFFFF);
				iaface.setHappy(0xFFFFF);
				Manager.gameOver(0);
			} else {

				if( player.fallFruits() ) {
					player_special_combo = true;
					return;
				}

				interf.lockAttack(false);
				player.updateSudden();
				player_special_combo = false;
				if( player.panic() )
					plface.panic();
				else
					plface.normal();
				playerStart();
			}
		} else {
			if( ia.isGameOver() || (!ia_special_combo && !ia.genLine()) ) {
				game_over_flag = true;
				interf.gameOver(false);
				plface.setHappy(0xFFFFF);
				iaface.setDead(0xFFFFF);
				ia.gameOver(false);
				player.game_over_flag = false;
				var g = Manager.gameOver(1);
				if( Data.gameMode == Data.HISTORY )		
					g.winTitem( TItem.histoItems() );				
				else if( Data.gameMode == Data.DUEL && Data.difficulty == 4 )
					g.winTitem( TItem.duelItem() );
			} else {

				if( ia.fallFruits() ) {
					ia_special_combo = true;
					return;
				}

				ia.updateSudden();
				ia_special_combo = false;
				if( ia.panic() )
					iaface.panic();
				else
					iaface.normal();
				iaStart();
			}
		}
	}

	function gameClick() {
		if( pl_lock || pause.activated() )
			return;
		var fpair = player.getPair( Std.xmouse(), Std.ymouse() );
		if( player.swapPair(fpair) ) {
			Manager.client.nswaps++;
			setPlLock(true) ;
		}
	}



	function defend() {
		if( pause.activated() )
			return;
		if( !pl_lock && player.canDefend() ) {
			setPlLock(true);
			player_special_combo = true;
			player.defend();
		}
	}


	function attack() {
		if( pause.activated() )
			return;
		if( player.canAttack() ) {			
			interf.lockAttack(true);
			if( ia_lock )
				player.attack(ia,false);
			else {
				if( player.attack(ia,true) ) {
					ia_lock = true;
					ia_special_combo = true;
				}
			}
		}
	}

	function iaAttack() {
		if( ia.canAttack() ) {
			interf.doAttack(1);			
			if( pl_lock )
				ia.attack(player,false);
			else {
				if( ia.attack(player,true) ) {
					setPlLock(true);
					player_special_combo = true;
				}
			}
		}
	}

	function iaDefend() {
		if( !ia_lock && ia.canDefend() ) {
			interf.doDefend(1);
			ia_lock = true;
			ia.reset();
			ia_special_combo = true;
			ia.defend();
		}
	}

	function getPower(context,mc) {
		if ( context == player )
			interf.addPower(0,mc);
		else
			interf.addPower(1,mc);
	}

	function main() {
		if( pause.main() )
			return;

		if( Client.STANDALONE && Key.isDown(Key.SPACE) )
			send(player,{ col : random(Data.DUEL_MAX_COLORS), flags : Data.FLAG_ARMURE, x : -1 });		

		if( !pl_lock ) {
			player_timer -= Std.deltaT;
			if( player_timer <= 0 ) {
				setPlLock(true) ;
				player.skipTurn();
			}
		}

		player.main();
		ia.main();
		interf.main();
		if( !ia_lock ) {
			var ia_pair = ia.getIAPair();
			ia_timer -= Std.deltaT;
			if( ia_pair != null && ia_timer <= 0 ) {
				ia_lock = true;
				ia.swapPair(ia_pair);
			}
		}
		var fpair = null;
		if( !pl_lock )
			fpair = player.getPair( Std.xmouse(), Std.ymouse() );
		interf.displayPair(fpair);		
	}


}