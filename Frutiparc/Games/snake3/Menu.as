import snake3.Const;
import snake3.Manager;

class snake3.Menu /*extends snake3.BackgroundFX*/ {//}

	var mc;
	var title, aleft, aright, background;
	var menus;
	var nmenus, menu_ids, run_menu_func;
	var title_ds,title_dr,cur_ang,target_ang,delta_ang,menu_ts;

	function on_press( mc ) {
		if( Manager.mode != this )
			return;
		if( mc == aleft ) {
			Manager.smanager.play(Const.SOUND_ROTATION_MENU);
			target_ang += - 2 * Math.PI / nmenus;
		}
		if( mc == aright ) {
			Manager.smanager.play(Const.SOUND_ROTATION_MENU);
			target_ang += 2 * Math.PI / nmenus;
		}
		var i;
		for(i=0;i<nmenus;i++)
			if( mc == menus[i].mc ) {
				mc.onPress = null;
				Manager.smanager.play(Const.SOUND_SELECT_MENU);
				run_menu_func(menus[i].id);
				return;
			}
	}

	function close() {
		//super.close();
		background.removeMovieClip();
		title.removeMovieClip();
		aleft.removeMovieClip();
		aright.removeMovieClip();
		var i;
		for(i=0;i<nmenus;i++)
			menus[i].mc.removeMovieClip();
	}

	function Menu( mc, ids, run_menu ) {
		//super(mc,3);
		this.mc = mc;
		run_menu_func = run_menu;
		nmenus = ids.length;
		menu_ids = ids;
		background = Std.attachMC(mc,"menuBackground",0);
		title = Std.attachMC(mc,"title",100);
		aleft = Std.attachMC(mc,"fleche",101);
		aright = Std.attachMC(mc,"fleche",102);

		if( !Manager.smanager.isPlaying(Const.SOUND_MENU_LOOP,Const.CHANNEL_MUSIC_1) ) {
			Manager.smanager.setVolume(Const.CHANNEL_MUSIC_1,0);
			Manager.smanager.fade(Const.CHANNEL_MUSIC_2,Const.CHANNEL_MUSIC_1,Const.MUSIC_FADE_LENGTH);
			Manager.smanager.loop(Const.SOUND_MENU_LOOP,Const.CHANNEL_MUSIC_1);
		}

		var me = this;
		function menu_on_press() { me.on_press(Std.cast(this)); }
		aleft.onPress = menu_on_press;
		aright.onPress = menu_on_press;

		menus = new Array();
		var i;
		for(i=0;i<nmenus;i++) {
			var m = Std.attachMC(mc,"menu",1+i);
			var id = Math.abs(ids[i]);
			var disabled = (ids[i] < 0);
			m.gotoAndStop(string(id));
			if( !disabled )
				m.onPress = menu_on_press;
			m.useHandCursor = false;
			menus[i] = { mc : m, id : id, a : i/nmenus * Math.PI * 2, x : 0, y : 0, c : new Color(m), dr : random(20)/100, disabled : disabled };
		}

		title._x = Const.WIDTH / 2;
		title._y = 80;
		aright._x = Const.WIDTH * 1.0;
		aright._y = Const.HEIGHT / 2;
		aleft._y = Const.HEIGHT / 2;
		aleft._x = 0;
		aleft._rotation = 180;

		menu_ts = 0;
		title_ds = 2;
		title_dr = 0.3;
		delta_ang = 0.1;
		cur_ang = Math.PI/2;
		target_ang = cur_ang;
		main();
	}

	function main() {
		//super.main();
		
		title._xscale += title_ds;
		title._yscale += title_ds;
		title._rotation += title_dr;
		if( title._xscale > 110 || title._yscale < 90 )
			title_ds *= -1;
		if( title._rotation > 2 || title._rotation < -2 )
			title_dr *= -1;

		if( cur_ang != target_ang ) {
			if( Math.sin(cur_ang-target_ang) < 0 ) {
				cur_ang += delta_ang;
				if( Math.sin(cur_ang-target_ang) > 0 )
					cur_ang = target_ang;
			} else {
				cur_ang -= delta_ang;
				if( Math.sin(cur_ang-target_ang) < 0 )
					cur_ang = target_ang;
			}
		}

		var i;		
		for(i=0;i<nmenus;i++) {
			var m = menus[i];
			var a = m.a + cur_ang;
			m.x = Math.cos(a) * Const.WIDTH / 3;
			m.y = Math.sin(a) * 100 + m.id / 100;
		}
		menu_ts += 0.1;
		menus.sortOn("y");
		for(i=0;i<nmenus;i++) {
			var m = menus[i];
			var mc = m.mc;
			mc.swapDepths(i+5);
			mc._x = m.x + Const.WIDTH / 2;
			mc._y = m.y + Const.HEIGHT / 2 - 50;
			var p = (m.y + 100) / 200;
			var s = 30 + p * 50 + Math.sin(menu_ts+i) * 3;
			mc._xscale = s;
			mc._yscale = s;
			if( m.disabled )
				m.c.setTransform( { ra : p*100, rb : 0, ga : p*60+40, gb : 0, ba : p*100, bb : 0, aa : 50, ab : 0 } );
			else
				m.c.setTransform( { ra : p*100, rb : 0, ga : p*60+40, gb : 0, ba : p*100, bb : 0, aa : 100, ab : 0 } );
		}
	}
//{
}