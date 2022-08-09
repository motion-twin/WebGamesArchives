import mb2.Const;
import mb2.Sound;
import mb2.Collide;
import mb2.TItems;

class mb2.Manager {

	public static var play_mode;
	public static var play_mode_param;

	static var mc;
	static var mode;
	static var next_mode;
	static var client : mb2.Client;
	static var updates : asml.UpdateList;

	static function init( mc : MovieClip ) {
		mode.destroy();
		updates = new asml.UpdateList();
		Sound.init(mc);
		client = new mb2.Client();
		mb2.Manager.mc = mc;
		next_mode = -1;
		mode = new mb2.Text(mc,"Connexion en cours...");
		client.serviceConnect();
		// HACK
		// startGame(Const.MODE_AVENTURE,4);
	}

	static function main() {
		Const.POS_X = 0;
		Const.POS_Y = 0;
		var p = mc;
		while( p._parent != null ) {
			Const.POS_X += p._x;
			Const.POS_Y += p._y;
			p = p._parent;
		}

		updates.main();
		Collide.frame_nb++;
		Sound.main();
		mode.main();
	}

	static function do_start_game() {
		client.startGame();
		updates.remove(mb2.Manager,do_start_game);
	}

	static function nextMode() {
		switch( next_mode ) {
		case 0:
			return new mb2.Menu(mc);
		case 2:
			return new mb2.Text(mc," ERREUR ");
		case 3:
			return new mb2.Game(mc);
		default:
			return null;
		}
	}

	static function setNextMode(i) {
		if( next_mode == -1 ) {
			mode = new mb2.Transition(mc,mode);
			next_mode = i;
		}
	}

	static function forceNextMode(i) {
		if( next_mode == -1 )
			setNextMode(i);
		else {
			var trans : mb2.Transition = Std.cast(mode);
			if( trans.reversed == undefined ) {
				next_mode = -1;
				setNextMode(i);
				return;
			}
			trans.reversed = false;
			next_mode = i;
		}
	}

	static function switchMode(m) {
		mode.destroy();
		next_mode = -1;
		mode = m;
	}

	static function gotoAide() {
		mode.destroy();
		mode = new mb2.Aide(mc);
	}

	static function startGame(gameMode,modeParam) {
		play_mode = gameMode;
		play_mode_param = modeParam;

		mode.destroy();
		switch( gameMode ) {
		case Const.MODE_CHALLENGE:
			mode = new mb2.Loader(mc,Const.CHALLENGE_DATA);
			break;
		case Const.MODE_CLASSIC:
			mode = new mb2.Loader(mc,Const.CLASSIC_DATA);
			break;
		case Const.MODE_AIDE:
			mode = new mb2.Loader(mc,Const.TUTO_DATA);
			break;
		case Const.MODE_AVENTURE:
			mode = new mb2.Loader(mc,Const.AVENTURE_DATA(modeParam));
			break;
		case Const.MODE_COURSE:
			mode = new mb2.Loader(mc,Const.COURSE_DATA(modeParam));
			break;
		default:
			// TODO
			mode = null;
			break;
		}
	}

	static function connected() {
		mode.destroy();
		next_mode = -1;
		mode = new mb2.Intro(mc);
	}

	static function started() {
		forceNextMode(3);
	}

	static function scoreSaved(score,old,old_pos,new_pos) {
		mode.onScore(score,old,old_pos,new_pos,false);
	}

	static function error() {
		setNextMode(2);
	}

	static function loadDone() {
		switch( play_mode ) {
		case Const.MODE_CHALLENGE:
			mode.setText("Connexion en cours...");
			updates.push(mb2.Manager,do_start_game);
			break;
		case Const.MODE_AVENTURE:
		case Const.MODE_AIDE:
		case Const.MODE_CLASSIC:
		case Const.MODE_COURSE:
			forceNextMode(3);
			break;
		}
	}

	static function gotoMenu() {
		setNextMode(0); 
	}

	static function gameFinished() {
		if( client.isWhite() ) {
			Sound.stopMix();
			Sound.playMusic(Sound.MUSIC_MENU);
			forceNextMode(0);
		} else {
			Sound.destroy();
			client.closeService();
		}
	}

	static function gameOver(cause) {
		var score = mode.calcScore(cause);
		switch( play_mode ) {
		case Const.MODE_CHALLENGE:
			mode = new mb2.GameOver(mc,mode,cause);
			client.saveScore(score);
			break;
		case Const.MODE_AVENTURE:
			if( cause == Const.CAUSE_WINS && !client.fcard.$dungeons_done[play_mode_param] ) {
				client.fcard.$dungeons_done[play_mode_param] = true;
				var i;
				for(i=0;i<4;i++)
					if( !client.fcard.$dungeons_done[i] )
						break;
				if( i == 4 )
					client.fcard.$dungeons[4] = true;
				client.saveSlot(0);
			}
			var ti = false;
			if( cause == Const.CAUSE_WINS )
				ti = TItems.giveAventure(play_mode_param);
			mode = new mb2.GameOver(mc,mode,cause);
			mode.onScore(score,mb2.Card.scoreDonjon(client.fcard,score),0,0,ti);
			break;
		case Const.MODE_AIDE:
			forceNextMode(0);
			break;
		case Const.MODE_COURSE:
			mode = new mb2.GameOverCourse(mc,mode,score);
			break;
		case Const.MODE_CLASSIC:
			var record = client.saveClassicScore(score);
			mode = new mb2.GameOver(mc,mode,cause);
			mode.onClassicScore(score,record,TItems.giveClassic(score));
			break;
		}
	}
}
