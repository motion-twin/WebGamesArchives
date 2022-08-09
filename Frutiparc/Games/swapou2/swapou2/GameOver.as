import swapou2.Manager;
import swapou2.Data;

class swapou2.GameOver {

	var box;
	var root_mc;
	var lock;
	var mode;
	var win_flag;
	var tbox;
	var lock_time;

	function GameOver(mc,mode) {
		root_mc = mc;
		lock = false;
		this.mode = mode;
		var me = this;
		function f_on_mdown() {
			me.onClick();
		}
		box = Std.cast( Std.attachMC(root_mc,"box",9999) );
		root_mc.onPress = f_on_mdown;
		root_mc.useHandCursor = true;		
		box._x = Data.DOCWIDTH / 2 + Data.CHALLENGE_X ;
		box._y = Data.DOCHEIGHT / 2 + 40;
		win_flag = false;
		lock_time = 2;
	}

	function connecting() {
		box.gotoAndStop(2);
	}

	function unlockCharacter(cid) {
		wins(true);		
		box.gotoAndStop(4);
		box.face.fake._visible = false;
		box.face.sub.gotoAndStop(cid+1);
		box.face.sub.char.gotoAndStop(4);
		box.face.sub.bg.gotoAndStop(3);
	}

	function wins(cond) {
		box._x = Data.DOCWIDTH / 2 ;		
		win_flag = cond;
		box.gotoAndStop(3);		
		if( cond )
			box.title.gotoAndStop(2);
		else
			box.title.gotoAndStop(1);
	}

	function winTitem(n) {
		if( n == 0 )
			return;		

		tbox = Std.cast( Std.attachMC(root_mc,"titemBox",9998) );
		tbox.field.text = "Vous avez gagné "+((n==1)?"un nouveau titem":(n+" nouveaux titems"))+" Frutiparc !";
		box._y = (Data.DOCHEIGHT - (box._height + (tbox._height - 40))) / 2 + box._height / 2;
		tbox._x = box._x;
		tbox._y = box._y + box._height/2 + tbox._height/2 - 25;
	}

	function setText(txt) {
		box.gotoAndStop(1);
		box.title.gotoAndStop(1);
		box.field.text = txt;
		box.field._y = - box.field.textHeight / 2;
	}

	function onClick() {
		if( lock || lock_time > 0 )
			return;
		delete(root_mc.onPress);
		Manager.endGame(win_flag);
	}

	function netLock() {
		lock = true;
		root_mc.useHandCursor = false;
	}

	function netUnlock() {
		lock = false;
		root_mc.useHandCursor = true;
	}

	function scoreSaved(score,old_score,old_rank,new_rank) {
		netUnlock();

		var text;
		text = Data.TXT_VOTRE_SCORE(score) + "\n";
		if( score > old_score && (old_rank > 0 || Manager.client.isWhite()) )
			text += Data.TXT_SCORE_BATTU+"\n";
		if( new_rank < old_rank && old_rank > 0 )
			text += Data.TXT_PLACE_GAGNEES(old_rank-new_rank)+"\n";
		if( Manager.client.isWhite() )
			text += Data.TXT_VOTRE_RECORD(Math.max(score,old_score))+"\n";
		else
			text += Data.TXT_VOTRE_PLACE(new_rank)+"\n";
		setText(text);
	}

	function main() {
		lock_time -= Std.deltaT;
		mode.main();
	}

	function destroy() {
		tbox.removeMovieClip();
		box.removeMovieClip();
		mode.destroy();
	}

}