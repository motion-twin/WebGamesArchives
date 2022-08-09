import mb2.Manager;
import mb2.Const;
import mb2.Sound;

class mb2.GameOver {

	var cause;
	var screen;
	var mode;

	var fx;

	function GameOver( mc : MovieClip, mode, cause ) {
		this.mode = mode;
		this.cause = cause;
		Sound.fadeMix(Sound.MUSIC_GAME_OVER);
		Sound.play(Sound.GAME_OVER);
		screen = mode.dmanager.attach("panGameOver",Const.ICON_PLAN);
		screen._x = Const.LVL_WIDTH / 2;
		screen._y = Const.LVL_HEIGHT / 2;
		if( cause == Const.CAUSE_WINS )
			screen.gotoAndStop("victory");
		else
			screen.gotoAndStop("gameOver");
		screen.mainField.text = "Connexion en cours...";
		screen.mainField._y = 30 - screen.mainField.textHeight / 2;

		fx = new asml.PopupFX(screen,0,100,10,3,1.2,0.6,0.5,1);
		fx.main();
	}

	function onClassicScore(score,record,titem) {
		setText("Votre score : niveau "+score+"\nVotre record : niveau "+record+(titem?"\nTItem gagne !!":""));
	}

	function onScore(score,old_score,old_pos,new_pos,ti) {
		var txt = "";
		if( old_score < score && old_score > 0 )
			txt += "Record battu !\n";
		if( old_pos > new_pos && old_pos > 0 )
			txt += "Vous avez gagne "+(old_pos-new_pos)+" places.\n";
		txt += ((score%100)+1)+" pourcent du niveau accomplis\n";
		txt += "Votre score : "+int(score/100)+"\n";
		if( new_pos > 0 )
			txt += "Votre classement : "+new_pos;
		if( ti )
			txt += "Nouveau TItem gagne !";
		setText(txt);
	}

	function setText(txt) {
		screen.mainField.text = txt;
		screen.mainField._y = 30 - screen.mainField.textHeight / 2;
		var me = this;
		screen.onPress = function() {
			me.click();
		};
	}

	function click() {
		screen.onPress = null;
		Manager.gameFinished();
	}
	
	function main() {
		fx.main();
		mode.main();
	}

	function destroy() {
		mode.destroy();
	}

}