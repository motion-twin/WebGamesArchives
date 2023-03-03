import snake3.Const;
import snake3.Fruit;
import snake3.Popup;
import snake3.Bonus;
import asml.NumberMC;

class snake3.Manager {

	static var nplayers = 4;
	static var mc = null;
	public static var mode = null;
	static var next_mode = -1;
	static var score = 0;

	public static var updates : asml.UpdateList = null;
	public static var music = true;
	public static var sounds = true;
	public static var keys = null;
	public static var client : snake3.SnakeClient = null;
	public static var smanager = null;	

	static function init( mc : MovieClip ) {
		keys = new asml.KeyManager();
		updates = new asml.UpdateList();
		registerClass("snake3_fruit",Fruit);
		registerClass("snake3_pop",Popup);
		registerClass("snake3_bonus",Bonus);
		registerClass("snake3_mcNumb",NumberMC);

		Std.setVar(mc,"keymanager",keys);
		keys.config = Const.DEFAULT_KEYS;

		resize();
		// FPS.init(mc);
		mode = null;
		next_mode = -1;
		smanager = new asml.SoundManager(mc,30000);
		smanager.setVolume(Const.CHANNEL_MUSIC_1,50);
		smanager.setVolume(Const.CHANNEL_MUSIC_2,50);
		Manager.mc = mc;
		mode = new snake3.Text(mc,Const.SCREEN_CONNECTING,Const.TXT_CONNECTING_MESSAGE);
		client = new snake3.SnakeClient();
		client.serviceConnect();
		// ******
		// startGame();
	}

	static function resize() {				
		Const.POS_X = 0;
		Const.POS_Y = 0;
		var p = mc;
		while( p._parent != null ) {
			Const.POS_X += p._x;
			Const.POS_Y += p._y;
			p = p._parent;
		}
	}

	static function main() {
		resize();
		updates.main();
		smanager.main();
		mode.main();
	}

	static function make_id(menu_id,mode_id) {
		if( menu_id == 1 && client.isWhite() )
			menu_id = 9;
		if( mode_id == 0 ) // challenge
			return menu_id;		
		return client.isWhite() ? menu_id : - menu_id;
	}

	static function do_start() {
		client.startGame();
		updates.remove(Manager,do_start);
	}

	static function do_end_game() {
		client.saveScore(score,null);
		updates.remove(Manager,do_end_game);
	}

	static function nextMode() {
		var n = next_mode;
		switch(n) {
		case 0:
			return new snake3.Menu(mc,[make_id(1,0),make_id(2,1),3,make_id(4,2)],run_main_menu);
		case 1:
			updates.push(Manager,do_start);
			return new snake3.Text(mc,Const.SCREEN_CONNECTING,Const.TXT_STARTING_GAME_MESSAGE);
		case 2:
			Std.tmod = 1; // reset the tmod because slow menu
			return new snake3.Battle(mc,nplayers);
		case 3: return new snake3.MenuOptions(mc);
		case 4: return new snake3.Encyclo(mc);
		case 5: return new snake3.Menu(mc,[6,7,8,5],run_main_menu);
		case 97:
			Std.tmod = 1; // reset the tmod because slow menu
			return new snake3.Game(mc);
		case 98:
			var m = new snake3.Text(mc,Const.SCREEN_TEXT,"");
			m.setTitleText(Const.TXT_ERROR);
			return m;
		default: return null;
		}
	}

	static function run_main_menu( n ) {
		switch(n) {
		case 1: // CHALLENGE
		case 9: // ENTRAINEMENT
			setNextMode(1);
			break;
		case 2: // BATTLE MENU
			setNextMode(5);
			break;
		case 3: // OPTIONS
			setNextMode(3);
			break;
		case 4: // ENCYCLOPEDIE
			setNextMode(4);
			break;
		case 5: // RETOUR MENU
			setNextMode(0);
			break;
		case 6:
		case 7:
		case 8:
			nplayers = n - 4;
			setNextMode(2);
			break;
		}
	}

	static function setNextMode(i) {
		if( next_mode == -1 ) {
			mode = new snake3.Transition(mc,mode);
			next_mode = i;
		}
	}

	static function forceNextMode(i) {
		if( next_mode == -1 )
			setNextMode(i);
		else {
			var trans : snake3.Transition = Std.cast(mode);
			trans.reversed = false;
			next_mode = i;
		}
	}

	static function startGame() {
		forceNextMode(97);
	}

	static function startBattle() {
		forceNextMode(2);
	}

	static function error() {
		forceNextMode(98);
	}

	static function connected() {
		forceNextMode(0);
	}

	static function saveScore( score ) {
		Manager.score = score;
		updates.push(Manager,do_end_game);
	}

	static function scoreSaved( score, old_score, old_rank, new_rank ) {
		var text;

		text = Const.TXT_VOTRE_SCORE(score) + "\n";
		if( score > old_score && (old_rank > 0 || client.isWhite()) )
			text += Const.TXT_SCORE_BATTU+"\n";
		if( new_rank < old_rank && old_rank > 0 )
			text += Const.TXT_PLACE_GAGNEES(old_rank-new_rank)+"\n";
		if( client.isWhite() )
			text += Const.TXT_VOTRE_RECORD(Math.max(score,old_score))+"\n";
		else
			text += Const.TXT_VOTRE_PLACE(new_rank)+"\n";


		var t : snake3.Game = Std.cast(mode);
		t.setScoreText(text);
	}

	static function restartGame() {
		if( client.isWhite() )
			forceNextMode(0);
		else
			client.closeService();
	}

	static function savePrefs() {
		client.savePrefs();
	}

	static function returnMenu() {
		smanager.play(Const.SOUND_RETURN_MENU);
		setNextMode(0);
	}

	static function switchMode(m) {
		mode.close();
		next_mode = -1;
		mode = m;
	}

	static function toggleMusic() {
		music = !music;
		if( music ) {
			smanager.enable(Const.CHANNEL_MUSIC_1,true);
			smanager.enable(Const.CHANNEL_MUSIC_2,true);
		} else {
			smanager.enable(Const.CHANNEL_MUSIC_1,false);
			smanager.enable(Const.CHANNEL_MUSIC_2,false);
		}
	}

	static function toggleSounds() {
		sounds = !sounds;
		if( sounds )
			smanager.enable(Const.CHANNEL_SOUNDS,true);
		else
			smanager.enable(Const.CHANNEL_SOUNDS,false);
	}

}
