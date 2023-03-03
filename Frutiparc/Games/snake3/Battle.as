import snake3.Const;
import snake3.Manager;

class snake3.Battle {

	var dmanager;
	var level;
	var snakes;
	var powers;
	var destroys;
	var fcounter;
	var key_flags;
	var q_time;
	var barres;
	var winner;	
	var game_over_txt;	
	var mc_color;

	static var scores = new Array();

	function Battle( mc : MovieClip, nplayers ) {
		dmanager = new asml.DepthManager(mc);
		level = new snake3.Level(dmanager);
		snakes = new Array();
		destroys = new Array();
		key_flags = new Array();
		powers = new Array();
		mc_color = new Color(mc);
		fcounter = 0;
		q_time = 0;		

		var s;
		var i;
		
		for(i=0;i<10;i++)
			if( scores[i] == undefined )
				scores[i] = 0;

		s = new snake3.Snake(dmanager,level.corner);
		s.ang = Math.PI/4 + 0.1;
		snakes.push(s);
		
		s = new snake3.Snake(dmanager,level.corner_down);
		s.ang = - 3 * Math.PI/4;
		snakes.push(s);

		if( nplayers > 2 ) {
			s = new snake3.Snake(dmanager,{ x : level.corner.x, y : level.corner_down.y });
			s.ang = - Math.PI/4 + 0.1;
			snakes.push(s);
		}

		if( nplayers > 3 ) {
			s = new snake3.Snake(dmanager,{ x : level.corner_down.x, y : level.corner.y });
			s.ang = 3 * Math.PI/4;
			snakes.push(s);
		}

		barres = new Array();
		for(i=0;i<nplayers;i++) {
			powers[i] = Const.BATTLE_POWER_MAX;
			snakes[i].color = Const.BATTLE_COLORS[i];
			snakes[i].border_color = Const.BATTLE_BORDER_COLORS[i];
			if( i > 0 )
				snakes[i].tete.gotoAndStop(10+i);

			var b = {
				bbegin : dmanager.attach("battleBarSide",Const.PLAN_INTERFACE),
				bend : dmanager.attach("battleBarSide",Const.PLAN_INTERFACE),
				bmid : dmanager.attach("battleBarMid",Const.PLAN_INTERFACE)
			};
			b.bend._xscale = -100;
			b.bbegin.gotoAndStop(string(i+1));
			b.bend.gotoAndStop(string(i+1));
			b.bmid.gotoAndStop(string(i+1));
			barres.push(b);
		}

		Manager.smanager.setVolume(Const.CHANNEL_MUSIC_2,0);
		Manager.smanager.fade(Const.CHANNEL_MUSIC_1,Const.CHANNEL_MUSIC_2,Const.MUSIC_FADE_LENGTH);
		Manager.smanager.loop(Const.SOUND_GAME_LOOP,Const.CHANNEL_MUSIC_2);
	}

	function draw_power_barre(x,y,v,i) {
		var c = Const.BATTLE_COLORS[i];
		var cb = Const.BATTLE_BORDER_COLORS[i];
		var b = barres[i];

		b.bbegin._x = x;
		b.bbegin._y = y;
		b.bend._x = x+v;
		b.bend._y = y;
		b.bmid._x = x;
		b.bmid._y = y;
		b.bmid._width = v;
	}	

	function gameOver(winner) {
		this.winner = winner;
		var txt;
		if( winner == -1 )
			txt = Const.TXT_BATTLE_DRAW;
		else {
			scores[winner]++;
			txt = Const.TXT_BATTLE_WIN(winner);
		}
		game_over_txt = new snake3.Text(dmanager.empty(Const.PLAN_INTERFACE),Const.SCREEN_RESULT,txt);
		if( winner != -1 )
			game_over_txt.setBgColor(winner+1);
		function f_on_press() {
			Manager.restartGame();
		}
		game_over_txt.setPress(f_on_press);		
		Manager.smanager.setVolume(Const.CHANNEL_MUSIC_1,0);
		Manager.smanager.fade(Const.CHANNEL_MUSIC_2,Const.CHANNEL_MUSIC_1,Const.MUSIC_FADE_LENGTH);
		Manager.smanager.playSound(Const.SOUND_GAME_OVER,Const.CHANNEL_MUSIC_1);
	}

	function main() {
		var i,j;
		fcounter++;

		if( game_over_txt != null ) {
			game_over_txt.main();
			return;
		}

		q_time += Std.deltaT;
		if( q_time > 3 ) {
			q_time -= 3;
			for(i=0;i<snakes.length;i++) {
				var s = snakes[i];
				s.add_queue(-1);
				Manager.smanager.stopSound(Const.SOUND_FRUIT_EAT_1,Const.CHANNEL_SOUNDS);
				Manager.smanager.stopSound(Const.SOUND_FRUIT_EAT_2,Const.CHANNEL_SOUNDS);
				s.eat = -1;
			}
		}

		for(i=0;i<destroys.length;i++) {
			var s = destroys[i];
			if( fcounter%4 == 0 ) {
				s.explode(s.color);
				s.draw();
				if( s.len <= 0 ) {
					destroys.remove(s);
					i--;
					s.destroy();
				}
			}
		}

		var hits = new Array();
		var bounds = level.bounds();
		for(i=0;i<snakes.length;i++) {
			var s : snake3.Snake = snakes[i];
			if( s == null )
				continue;

			powers[i] += Const.BATTLE_POWER_RECUP * Std.tmod;
			if( powers[i] > Const.BATTLE_POWER_MAX )
				powers[i] = Const.BATTLE_POWER_MAX;
			var p = powers[i] * 5;
			switch(i) {
			case 0:
				draw_power_barre(20,20,p,i);
				break;
			case 1:
				draw_power_barre(Const.WIDTH-p-20,20,p,i);
				break;
			case 2:
				draw_power_barre(20,40,p,i);
				break;
			case 3:
				draw_power_barre(Const.WIDTH-p-20,40,p,i);
				break;
			}
			s.speed *= Math.pow(Const.BATTLE_FRICTION,Std.tmod);
			if( s.speed < Const.SNAKE_DEFAULT_SPEED )
				s.speed = Const.SNAKE_DEFAULT_SPEED;
			hits[i] = s.move(bounds);
			s.draw();
		}
		for(i=0;i<snakes.length;i++) {
			var c = snakes[i].collision_pt();
			for(j=0;j<snakes.length;j++)
				if( i != j && snakes[j].hit(c) )
					hits[i] = true;
		}

		for(i=0;i<snakes.length;i++)
			if( snakes[i] != null && !hits[i] )
				break;
		if( i == snakes.length ) {
			gameOver(-1);
			return;
		}

		for(i=0;i<snakes.length;i++)
			if( hits[i] ) {
				var s = snakes[i];
				snakes[i] = null;
				destroys.push(s);
			}

		winner = -1;
		for(i=0;i<snakes.length;i++)
			if( snakes[i] != null ) {
				if( winner == -1 )
					winner = i;
				else {
					winner = -1;
					break;
				}
			}
		if( winner != -1 ) {
			gameOver(winner);
			return;
		}

		for(i=0;i<snakes.length;i++) {
			var keys = Manager.keys.config;
			if( Key.isDown(keys[i*3]) )
				snakes[i].ang -= snakes[i].delta_ang * Std.tmod;
			if( Key.isDown(keys[i*3+1]) )
				snakes[i].ang += snakes[i].delta_ang * Std.tmod;
			if( Key.isDown(keys[i*3+2]) && powers[i] > Std.tmod ) {
				powers[i] -= Std.tmod;
				snakes[i].speed = Const.BATTLE_ACCEL;
			}
		}

	}

	function close() {
		dmanager.destroy();
		mc_color.setTransform( { ra : 100, rb : 0, ba : 100, bb : 0, ga : 100, gb : 0, aa : 100, ab : 0 } );
	}


}