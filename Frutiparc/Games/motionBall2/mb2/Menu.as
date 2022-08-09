import mb2.Prefs;
import mb2.Const;
import mb2.Manager;
import mb2.Sound;

class mb2.Menu {

	static var GOTO_AIDE = -1;

	static var MENU_IDS = [
		[1,2,3,4,5,6], // MAIN MENU
		[40,41,42,43,44,45,46,47], // MENU COURSE
		[60,61,62,63,64,65], // MENU AVENTURE
		[20,22,24] // MENU OPTIONS
	];

	var mc;
	var dmanager;
	var bg;

	var cur_ray;
	var cur_ang;
	var ray_speed;
	var ray_acc;
	var ang_speed;
	var ang_acc;
	var cos_ray;
	var cos_speed;
	var menu_phase;
	var menu_time;
	var go_hole;
	var balls;
	var infos;

	var next_menu_id;
	var next_mode;
	var next_mode_param;
	
	function Menu( mc : MovieClip ) {
		this.mc = mc;
		dmanager = new asml.DepthManager(mc);
		bg = dmanager.attach("fondMenu",0);
		Sound.play(Sound.MENU_ENTER);
		show(0);
		cur_ray = 450;
		cur_ang = 0;
		ray_speed = -1.0;
		ray_acc = 1.05;
		ang_speed = 0.05;
		ang_acc = 1.01;
		cos_ray = 0;
		cos_speed = 0;
		menu_phase = 0;
		menu_time = 0;		
		go_hole = false;
		Sound.playMusic(Sound.MUSIC_MENU);
	}

	private function has_true_flag(a) {
		var i;
		for(i=0;i<a.length;i++)
			if( a[i] )
				return true;
		return false;
	}

	private function show(n) {
		var i;
		for(i=0;i<balls.length;i++)
			balls[i].removeMovieClip();
		balls = new Array();
		var m = MENU_IDS[n];
		for(i=0;i<m.length;i++) {
			var b = dmanager.attach("menu balls",0);
			var id = m[i];
			b.state = 1;
			switch(id) {
			case 1: if( !Prefs.challenge_mode_enabled ) b.state = 0; break;
			case 2: if( !has_true_flag(Prefs.courses) || Manager.client.isChallengeDisc() ) b.state = 0; break;
			case 3: if( !has_true_flag(Prefs.dungeons) || Manager.client.isChallengeDisc() ) b.state = 0; break;
			case 4: if( !Prefs.classic_mode_enabled || Manager.client.isChallengeDisc() ) b.state = 0; break;	
			case 20: if( !Prefs.music_enabled ) id += 1; break;
			case 22: if( !Prefs.sound_enabled ) id += 1; break;
			}
			if( id == 1 && Manager.client.isWhite() )
				id = 7;
			if( id >= 40 && id <= 46 && !Prefs.courses[id-40] )
				b.state = 0;
			if( id >= 60 && id <= 64 ) {
				if( !Prefs.dungeons[id-60] )
					b.state = 0;
			}

			b.useHandCursor = false;

			var me = this;
			b.onRollOver = function() { me.select(this) };
			b.onRollOut = function() { me.unselect(this) };
			b.onPress = function() { me.enter(this) };			
			b.gotoAndStop(b.state?"normal":"disable");
			b.title.gotoAndStop(id);
			b.ball.gotoAndStop(id);

			if( id >= 60 && id <= 63 ) {
				if( Manager.client.fcard.$dungeons_done[id-60] )
					b.ball.mask.gotoAndStop(2);
				else
					b.ball.mask.stop();
			}
			if( id == 64 && b.state == 0 )
				b.ball.logo.stop();

			switch( id ) {
			case 1: 
			case 7: b.infos = 1; break;
			case 2: b.infos = 3; break;
			case 3: b.infos = 2; break;
			case 4: b.infos = 4; break;			
			}

			b.ang = i * 2 * Math.PI / m.length;
			b.id = id;
			balls.push(b);
		}
	}

	private function showInfos(i) {
		if( i == undefined ) {
			infos.dy = 10;
			return;
		}
		if( infos == null ) {
			infos = dmanager.attach("cadreInfo",1);
			infos.gotoAndStop(i);
			infos._x = Const.LVL_WIDTH / 2;
			infos._y = Const.LVL_HEIGHT + 50;
			infos.dy = -10;
		} else {
			infos.dy = -10;
			infos.gotoAndStop(i);
		}
	}

	private function select(b) {
		if( b.state == 1 ) {
			Sound.play(Sound.MENU_SELECT);
			b.state = 2;
			b.gotoAndStop("selected");
			showInfos(b.infos);
		}
	}

	private function unselect(b) {
		if( b.state == 2 ) {
			b.state = 1;
			b.gotoAndStop("normal");
			showInfos(undefined);
		}
	}

	private function enter(b) {
		if( menu_phase == 1 && b.state == 2 ) {
			Sound.play(Sound.MENU_ENTER);
			start(b.id);
		}
	}

	private function run_menu(n) {
		menu_phase = 3;
		next_menu_id = n;
		ray_speed = -5.0;
		ray_acc = 1.1;
		ang_speed = 0.2;
		ang_acc = 1.02;
		cos_speed = 0;
		cos_ray = 0;
		delete(mc.onMouseMove);
	}

	private function run_mode(mname,mparam) {
		menu_phase = 2;
		next_mode = mname;
		next_mode_param = mparam;
		ray_speed = 7.0;
		ray_acc = 1.05;
		ang_speed = 0.1;
		ang_acc = 1.05;
		cos_speed = 0;
		cos_ray = 0;
		go_hole = true
		delete(mc.onMouseMove);
	}

	private function start(id) {
		switch(id) {
		case 1:
		case 7:
			run_mode(Const.MODE_CHALLENGE,undefined);
			break;
		case 2:
			run_menu(1);
			break;
		case 3:
			run_menu(2);
			break;
		case 4:
			run_mode(Const.MODE_CLASSIC,undefined);
			break;
		case 5:
			run_menu(3);
			break;
		case 6:
			run_mode(Const.MODE_AIDE,undefined);
			break;
		case 40:
		case 41:
		case 42:
		case 43:
		case 44:
		case 45:
		case 46:
			run_mode(Const.MODE_COURSE,id-40);
			break;
		case 60:
		case 61:
		case 62:
		case 63:
		case 64:
			run_mode(Const.MODE_AVENTURE,id-60);
			break;
		case 47:
		case 65:
			run_menu(0);
			break;
		case 20:
		case 21:
			Prefs.toggleMusic();
			run_menu(3);
			break;
		case 22:
		case 23:
			Prefs.toggleSounds();
			run_menu(3);
			break;
		case 24:
			Manager.client.savePrefs();
			run_menu(0);
			break;
		}
	}

	private function change() {
		var xm = Std.xmouse();
		var delta = Math.min(200,Math.abs(305-xm));
		if( xm > 305 )
			ang_speed = delta * 0.05 / 100;
		else
			ang_speed = -delta * 0.05 / 100;
	}

	function main() {
		var tmod = Std.tmod;
		menu_time += tmod / 30;
		ray_speed *= Math.pow(ray_acc,tmod);

		infos._y += infos.dy * tmod;
		if( infos._y > Const.LVL_HEIGHT + 50 ) {
			infos.removeMovieClip();
			infos = null;
		} else if( infos._y < Const.LVL_HEIGHT - 40 )
			infos._y = Const.LVL_HEIGHT - 40;

		// corrigé bug en cas d'explode du tmod (passage bureau fp2)
		if( menu_phase > 1 && Math.abs(ray_speed ) < 3 ) {
			if( ray_speed < 0 )
				ray_speed = -3;
			else
				ray_speed = 3;
		}

		ang_speed *= Math.pow(ang_acc,tmod);
		cos_ray += cos_speed;
		cur_ray += ray_speed;
		cur_ang += ang_speed;
		if( cur_ang > Math.PI ) {
			var pi2 = Math.PI*2;
			cur_ang -= int(cur_ang/pi2)*pi2;
		}
		var i;
		for(i=0;i<balls.length;i++) {
			var b = balls[i];
			var a = b.ang+cur_ang;
			var r = Math.cos(b.ang+menu_time)*cos_ray;
			b._x = Math.cos(a)*(cur_ray+r)+305;
			b._y = Math.sin(a)*(cur_ray+r)+205;
		}

		switch( menu_phase ) {
		case 0:
			if( cur_ray <= 136 ) {
				cur_ray = 136;
				ray_speed = 0.0;
				ang_acc = 0.99;
				cos_speed = 0.1;
				var me = this;
				mc.onMouseMove = function () { me.change() };
				menu_phase++;
			}
			break;
		case 1:
			if( Math.abs(cos_ray) > 10 )
				cos_speed *= -1;
			break;
		case 2:
			if( cur_ray > 450 ) {
				show(-1);
				delete(mc.onMouseMove);
				if( next_mode == GOTO_AIDE )
					Manager.gotoAide();
				else
					Manager.startGame(next_mode,next_mode_param);
			}
			break;
		case 3:
			if( cur_ray < ray_speed ) {
				show(next_menu_id);
				ang_speed *= -1;
				ray_speed *= -1;
				ray_acc = 1 / ray_acc;
				ang_acc = 0.97;
				menu_phase++;
				main();
			}
			break;
		case 4:
			if( cur_ray >= 130 ) {
				ray_speed = 0;
				cur_ray = 135;
				menu_phase = 0;
			}
			break;
		}
		if( go_hole ) {
			bg.hole._xscale *= Math.pow(1.1,tmod)
			bg.hole._yscale = bg.hole._xscale
		}
	}

	function destroy() {
		delete (mc.onMouseMove);
		dmanager.destroy();
	}

}
