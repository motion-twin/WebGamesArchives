import mb2.Manager;
import mb2.Const;
import mb2.Sound;
import mb2.Interf;
import mb2.TItems;

class mb2.GameOverCourse {

	static var NAMES = ["s1","s2","s3","s4"];

	var score;
	var mode;

	var screen;
	var fx;

	function GameOverCourse( mc : MovieClip, mode, score ) {
		this.mode = mode;
		this.score = score;
		Sound.fadeMix(Sound.MUSIC_GAME_OVER);
		Sound.play(Sound.GAME_OVER);
		screen = mode.dmanager.attach("panGameOver",Const.ICON_PLAN);
		screen._x = Const.LVL_WIDTH / 2;
		screen._y = Const.LVL_HEIGHT / 2;
		screen.gotoAndStop("records");

		saveRecords();

		fx = new asml.PopupFX(screen,0,100,10,3,1.2,0.6,0.5,1);
		fx.main();

		var me = this;
		screen.onPress = function() { 
			me.click();
			delete(me.screen.onPress);
		};
	}

	function saveRecords() {
		var plrecord = { $t : score, $c : false };
		var card = Manager.client.fcard;
		var records = card.$records[Manager.play_mode_param];
		var p = 0;
		var cp = 0;
		var titems = 0;
		while( p < 3 ) {
			if( records[p].$t > score ) {
				var j;				
				for(j=p;j<3;j++)
					if( records[p].$c ) {
						titems += TItems.giveCourse(Manager.play_mode_param,cp);							
						cp++;
					}
				if( !card.$courses[Manager.play_mode_param+1] )
					card.$courses[Manager.play_mode_param+1] = true;
				records.splice(p,0,plrecord);
				break;
			}
			if( records[p].$c )
				cp++;
			p++;
		}

		screen.mainField.text = "";
		if( p == 3 ) {
			if( records.length == 3 )
				records.push(plrecord);
			else {
				screen.mainField.text = "Vous n'etes pas classe.";
			}
		}
		if( titems > 0 )
			screen.mainField.text += titems+" titems gagnes !";

		displayRecords(score,records);
		records.splice(3,records.length - 3);
		Manager.client.saveSlot(0);
	}

	function displayRecords(s,r) {
		var i;
		var cp = 0;
		for(i=0;i<4;i++) {
			var rpan = screen[NAMES[i]];
			rpan.slot.time_text.text = Interf.makeTime(r[i].$t);
			var rtype = 5;
			if( r[i].$c )			
				rtype = ++cp;
			else if( r[i].$t == s )
				rtype = 4;
			rpan.b1.gotoAndStop(rtype);
			rpan.b2.gotoAndStop(rtype);
		}
	}

	function click() {
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
