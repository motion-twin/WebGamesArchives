import swapou2.Manager;
import swapou2.Data;
import swapou2.Sounds;

class swapou2.HistoMap {

	var dmanager : asml.DepthManager;
	var bg;
	var map;
	var mask ; // MCs
	var lock;
	var target_scale;
	var lastframe;
	var zooming;
	var mask_played;

	var dialog_pos;
	var movie;


	function startEtape() {
		switch( Data.histoPhase ) {
		case 0:
			return 0;
		case 1:
		case 2:
			return 1;
		default:
			return Data.histoPhase - 1;
		}
		return -1;
	}

	function endEtape() {
		switch( Data.histoPhase ) {
		case 0:
		case 1:
			return 1;
		default:
			return Data.histoPhase;
		}
		return -1;
	}

	function playerPhase() {
		switch( Data.histoPhase ) {
		case 0:
		case 1:
		case 7:
			return 3;
		default:
			return 1 + Data.players[0];
		}
		return -1;
	}

	function HistoMap(mc) {
		dmanager = new asml.DepthManager(mc);
		bg = dmanager.attach("bg",0);
		bg.stop() ;
		map = Std.cast( dmanager.attach("worldMap",0) );
		map._xscale = 0;
		map._yscale = 0;
		target_scale = 100;
		mask_played = false;
		zooming = true;
		map._x = Data.DOCWIDTH / 2;
		map._y = Data.DOCHEIGHT / 2 - 30;
		map.stop() ;
		mask = Std.getVar(map.world,"mask");
		mask.stop();
		map.world.altChar.stop();
		map.world.altChar._visible = false;
		map.world.hero.stop();
		map.world.hero.hero.gotoAndStop(playerPhase());

		lastframe = -1;
		lock = true;
		var me = this;
		function on_press() {
			me.onClick();
		};
		map.onPress = on_press;
		map.useHandCursor = false;

		// Adversaire
		var opponent;
		if( Data.histoPhase == 0 )
			opponent = 2;
		else if( Data.histoPhase == 1 )
			opponent = 1 - Data.players[0];
		else if( Data.histoPhase == 6 )
			opponent = 6;
		else
			opponent = Data.histoPhase + 1;
		Data.players[1] = opponent;
		// Etapes de la map
		for(var i=0;i<7;i++) {
			var emc = Std.getVar(map.world,"etape_"+i);
			if (i <= startEtape())
				emc.stop();
			else
				emc._visible = false ;
		}
		map.dial._visible = false ;
		dialog_pos = -1;
		display(undefined,"",0,0,0);

		var frame = "etape_"+startEtape();
		mask.gotoAndStop(frame);
		map.world.hero.gotoAndStop(frame);

		nextDialog();
	}



	function nextDialog() {
		dialog_pos++;

		// hack pour wasabii
		if( dialog_pos == 6 && Data.histoPhase == 6 )
			map.world.altChar._visible = false;

		var d = Data.SCENARIO[Data.histoPhase][dialog_pos];
		if( d == Data.SCENARIO_WALK ) {
			mask.play();
			map.world.hero.play();
			mask_played = true;
			lastframe = -1;
			lock = true;
			return true;
		}
		if( d == Data.POIVRE_WALK ) {
			map.world.altChar.gotoAndPlay("etape_1");
			map.world.altChar.hero.gotoAndStop(4);
			map.world.altChar._visible = true;
			return nextDialog();
		}
		if( d == Data.WASABII_WALK ) {
			map.world.altChar.gotoAndPlay("etape_5");
			map.world.altChar.hero.gotoAndStop(5);
			map.world.altChar._visible = true;
			return nextDialog();
		}
		if( d == Data.STOPLOOP ) {
			Sounds.stopMusic();
			return nextDialog();
		}
		if( d == undefined )
			return false;
		if( Std.cast(d).sound != undefined ) {
			Sounds.playMusic(Std.cast(d).sound);
			return nextDialog();
		}
		if( d.movie != undefined ) {
			var mid = d.movie;
			movie.removeMovieClip();
			movie = Std.attachMC(map.movie,"cinematique",0);
			movie.gotoAndStop(string(mid+1));
		}
		if( d.txt == undefined )
			return nextDialog();
		display(d.left,d.txt,d.face,d.state,d.bg);
		return true;
	}


	function onClick() {
		if( lock )
			return;
		if( !nextDialog() ) {
			zooming = true;
			target_scale = 0;
		}
	}


	function display( left, txt, face, state, bg ) {

		var pname = Data.CHAR_NAMES[Data.players[0]];
		pname = pname.substr(0,pname.length-1);
		txt = Std.replace(txt,"$#",pname);

		pname = Data.CHAR_NAMES[1-Data.players[0]];
		pname = pname.substr(0,pname.length-1);
		txt = Std.replace(txt,"$*",pname);

		switch( face ) {
		case -1: face = Data.players[0]; left = true; break;
		case -2: face = 1 - Data.players[0]; break;
		case -3: face = Data.players[1]; break;
		}

		map.dial._visible = true ;
		if( left == undefined )
			map.dial.gotoAndStop(3);
		else
			map.dial.gotoAndStop(left?1:2);
		map.dial.field.text = txt ;
		map.dial.field._y = - map.dial.field.textHeight / 2;

		var fmc = map.dial.face;
		fmc.fake._visible = false;
		fmc.sub.gotoAndStop(string(face+1));
		fmc.sub.char.gotoAndStop(string(state+1));
		fmc.sub.bg.gotoAndStop(string(bg+1));
	}



	function main() {

		if( zooming ) {			
			var s = map._xscale + (target_scale - map._xscale) * Math.pow(0.3,1/Std.tmod);
			if( Math.abs(map._xscale - target_scale) < 2 ) {
				s = target_scale;
				zooming = false;
				lock = false;
				map.useHandCursor = true;
				if( s == 0 ) {
					if( Data.histoPhase == 7 ) {
						Manager.startMenu();
						return;
					}
					Manager.startDuel();
//					Data.histoPhase++; // HACK
//					Manager.startHistoryMap(); // HACK
				}
			}
			map._xscale = s;
			map._yscale = s;
			return;
		}

		if( mask_played ) {
			if( mask._currentframe != lastframe )
				lastframe = mask._currentframe;
			else {
				var et = Std.getVar(map.world,"etape_"+endEtape());
				et._visible = true;
				et.play();
				mask_played = false;
				lock = false;
				nextDialog();
			}
		}
	}


	function destroy() {
		dmanager.destroy();
	}
}