import snake3.Const;
import snake3.Manager;
import snake3.Encyclo;
import snake3.Level;
import snake3.SnakeClient;
import snake3.bonus.Coffre;
import snake3.bonus.Canne;
import snake3.bonus.Molecule;
import snake3.bonus.Oeil;
import snake3.bonus.Pile;
import snake3.bonus.Sabre;
import snake3.bonus.Cloche;
import snake3.bonus.Aureole;
import snake3.bonus.Sonnette;
import snake3.bonus.CoffreOptions;

class snake3.Game {//}

	public var mc;
	public var updates : asml.UpdateList;
	var mc_color;
	var fbarre_mc;
	var score_mc : asml.NumberMC;
	var game_over_text : snake3.Text;
	var pause_mc;

	var pause;
	var pause_flag;
	var slots;
	var unique_slots;
	var space_flag;
	var fcounter;
	var bonus_time;
	public var pieu;
	
	var leftRelease_flag;
	var rightRelease_flag;
	
	var bonus_cheat_id;
	var bonus_cheat_key;

	var fruit_flags;

	public var fbarre;
	public var enable_snake_keys;
	public var loose_frutibar;
	public var fruit_time_factor;
	public var score_factor;
	public var score;
	public var level;
	public var snake;
	public var dmanager;
	public var speed_up,speed_normal;
	public var do_call_on_eat;

	var game_over_flag;
	var bonus_probabilities;
	var trou;

	function Game( mc : MovieClip ) {
		dmanager = new asml.DepthManager(mc);
		updates = new asml.UpdateList();
		score = 0;
		fcounter = 0;
		bonus_time = 0;
		speed_normal = 1;
		speed_up = Const.CHALLENGE_SPEED_COEF;
		pause = false;
		score_factor = 1;
		fruit_time_factor = 1;
		loose_frutibar = true;
		game_over_flag = false;
	
		var barre_mc = dmanager.attach("barreScore",Const.PLAN_INTERFACE);
		barre_mc._x = Const.WIDTH;

		score_mc = Std.cast(dmanager.attach("snake3_mcNumb",Const.PLAN_INTERFACE));
		score_mc.init("police");
		score_mc._x = Const.WIDTH - Level.BORDER;
		score_mc._y = 30;		
		Manager.smanager.setVolume(Const.CHANNEL_MUSIC_2,0);
		Manager.smanager.fade(Const.CHANNEL_MUSIC_1,Const.CHANNEL_MUSIC_2,Const.MUSIC_FADE_LENGTH);
		Manager.smanager.loop(Const.SOUND_GAME_LOOP,Const.CHANNEL_MUSIC_2);

		fbarre = 0;
		fbarre_mc = dmanager.attach("fbarre",Const.PLAN_INTERFACE);
		fbarre_mc._x = Level.BORDER;
		fbarre_mc._y = Const.HEIGHT-Level.BARRE_DOWN;

		bonus_cheat_id = 0;
		Pile.counter = 0;
		Sonnette.activated = false;

		slots = new Array();
		unique_slots = new Array();
		space_flag = false;
		enable_snake_keys = true;
		do_call_on_eat = true;

		level = new snake3.Level(dmanager);
		var p = level.corner;
		p = { x : p.x, y : p.y };
		p.x += 50;
		p.y += 50;
		snake = new snake3.Snake(dmanager,p);
		var trou_mc = dmanager.attach("trou",Const.PLAN_FRUITSHADE);
		trou_mc._x = p.x;
		trou_mc._y = p.y;
		trou = new asml.PopupFX(trou_mc,100,0,0,3,1,0,0,0);
		
		bonus_probabilities = new Array();
		var i;
		for(i=0;i<Const.PROBABILITIES.length;i++)
			bonus_probabilities[i] = Const.PROBABILITIES[i];

		fruit_flags = new Array();
		for(var k in Encyclo.fruits)
			fruit_flags[k] = (Encyclo.fruits[k] >= Const.FRUIT_DEBLOK);
		
		snake.ang = Math.PI/4;
		this.mc = mc;
		mc_color = new Color(mc);
	}

	function call_on_eat(f) {
		if( do_call_on_eat )
			f.on_eat(snake);
	}

	function close() {
		dmanager.destroy();
		mc_color.setTransform( { ra : 100, rb : 0, ba : 100, bb : 0, ga : 100, gb : 0, aa : 100, ab : 0 } );
	}

	function game_over() {
		snake.eat = -1;
		slots[0].activate(false);
		var i;
		for(i=0;i<slots.length;i++)
			slots[i].close();
		for(i=0;i<unique_slots.length;i++)
			unique_slots[i].close();

		game_over_flag = true;
		if( snake.len == 0 )
			snake.tete._visible = false;

		Manager.smanager.setVolume(Const.CHANNEL_MUSIC_1,0);
		Manager.smanager.fade(Const.CHANNEL_MUSIC_2,Const.CHANNEL_MUSIC_1,Const.MUSIC_FADE_LENGTH);
		Manager.smanager.playSound(Const.SOUND_GAME_OVER,Const.CHANNEL_MUSIC_1);
	}

	function endGame() {
		var me = this;
		function f_on_press() {
			me.endGame();
		};
		for(var k in Encyclo.fruits)
			if( Encyclo.fruits[k] > Const.FRUIT_DEBLOK-1 && !fruit_flags[k] ) {
				fruit_flags[k] = true;
				var old_g = game_over_text;
				var mc = dmanager.empty(Const.PLAN_INTERFACE);
				game_over_text = new snake3.Text(mc,Const.SCREEN_FRUIT,Const.TXT_SCORE_WIN_FRUIT(k,Encyclo.fruits[k]));
				game_over_text.setFruit(k);
				game_over_text.setPress(f_on_press);
				old_g.destroy();
				return;
			}
		Manager.restartGame();
	}

	function setScoreText(txt) {
		game_over_text.setScreen(Const.SCREEN_GAMEOVER);
		game_over_text.setText(txt);
		var me = this;
		function f_on_press() {
			me.endGame();
		};
		game_over_text.setPress(f_on_press);
	}

	function on_fruit_timeout(f) {
		if( loose_frutibar && f.points() > 0 ) {
			fbarre += Const.FBARRE_FRUIT_TIMEOUT;
			if( fbarre < 0 )
				fbarre = 0;
		}
	}

	function is_unique_bonus(id) {
		return id == 8 || id == 12 || id == 14 || id == 21 || id == 28 || id == 31 || id == 33;
	}

	function add_slot(s) {
		if( s.activable() ) {
			slots[0].activate(false);
			slots.unshift(s);
			var i;
			for(i=0;i<slots.length;i++)
				slots[i].update_pos(i);
			slots[0].activate(true);
		} else {
			s.update_pos(slots.length);
			slots.push(s);
		}	
	}

	function add_unique_slot(s) {
		unique_slots.unshift(s);
		var i;
		for(i=0;i<unique_slots.length;i++)
			unique_slots[i].update_pos(9.5 - i);
	}

	function remove_slot(s) {
		s.close();
		slots.remove(s);
		var i;
		for(i=0;i<slots.length;i++)
			slots[i].update_pos(i);
		slots[0].activate(true);
	}

	function remove_unique_slot(s) {
		s.close();
		unique_slots.remove(s);
		var i;
		for(i=0;i<unique_slots.length;i++)
			unique_slots[i].update_pos(9.5 - i);
	}

	function get_bonus(b) {

		var sound = Const.SOUND_OPTION_EAT;

		switch( b.id ) {
		case 1: 
		case 2: 
		case 3:	// CISEAUX
			// sound = null;
			add_slot( new snake3.bonus.Ciseaux(this,b.id) );
			break;
		case 4: // LANGUE
			add_slot( new snake3.bonus.Langue(this) );
			break;
		case 5: // COFFRE
			sound = Const.SOUND_COFFRE;
			Coffre.activate(this,b._x,b._y);
			break;
		case 6: // POTION ROUGE
			sound = Const.SOUND_POTION;
			add_slot( new snake3.bonus.PotionRouge(this) );
			break;
		case 7: // STEROID
			add_slot( new snake3.bonus.Steroids(this,b._x,b._y) );
			break;
		case 8: // BAGUE
			add_unique_slot( new snake3.bonus.Bague(this) );
			break;
		case 9: // POTION BLEU
			sound = Const.SOUND_POTION;
			add_slot( new snake3.bonus.PotionBleue(this) );
			break;
		case 10: // POTION ROSE
			sound = Const.SOUND_POTION;
			add_slot( new snake3.bonus.PotionRose(this) );
			break;
		case 11: // POTION VIOLETTE
			sound = Const.SOUND_POTION;
			add_slot( new snake3.bonus.PotionViolette(this) );
			break;
		case 12: // RESSORT
			add_unique_slot( new snake3.bonus.Ressort(this) );
			break;
		case 13: // RONDELLE
			add_slot( new snake3.bonus.Rondelle(this) );
			break;
		case 14: // INVERSEUR
			add_unique_slot( new snake3.bonus.Inverseur(this) );
			break;
		case 15: // POTION NOIRE
			sound = Const.SOUND_POTION;
			add_slot( new snake3.bonus.PotionNoire(this) );
			break;
		case 16: // CANNE
			Canne.activate(this,b._x,b._y);
			break;
		case 17: // MOLECULE
			Molecule.activate(this,false);
			break;
		case 18: // MOLECULE GROSSE
			Molecule.activate(this,true);
			break;
		case 19: // BOMBE
			add_slot( new snake3.bonus.Bombe(this) );
			break;
		case 20: // POTION VERTE
			sound = Const.SOUND_POTION;
			add_slot( new snake3.bonus.PotionVerte(this) );
			break;
		case 21: // PLUME
			add_unique_slot( new snake3.bonus.Plume(this) );
			break;
		case 22: // MAUVAIS OEIL
			Oeil.activate(this);
			break;
		case 23: // FLECHE BLEU
			var _ = new snake3.bonus.FlecheBleue(this,b._rotation,b._x,b._y);
			break;
		case 24: // FLECHE ROUGE
			var _ = new snake3.bonus.FlecheRouge(this,b._x,b._y);
			break;
		case 25: // POTION ORANGE
			sound = Const.SOUND_POTION;
			add_slot( new snake3.bonus.PotionOrange(this) );
			break;
		case 26: // POTION JAUNE
			sound = Const.SOUND_POTION;
			add_slot( new snake3.bonus.PotionJaune(this) );
			break;
		case 27: // DYNAMITE
			sound = Const.SOUND_DYNAMITE;
			Pile.activate(this);
			Manager.smanager.stop(Const.CHANNEL_SOUNDS);
			break;
		case 28: // POUPEE
			add_unique_slot( new snake3.bonus.Poupee(this) );
			break;
		case 29: // AUREOLE
			Aureole.activate(this,b._x,b._y);
			break;
		case 30: // CROIX
			var _ = new snake3.bonus.Croix(this,b._x,b._y);
			break;
		case 31: // SONNETTE
			add_unique_slot( new snake3.bonus.Sonnette(this) );
			break;
		case 32: // CLOCHE
			sound = Const.SOUND_CLOCHE;
			Cloche.activate(this);
			break;
		case 33: // PENTACLE
			add_unique_slot( new snake3.bonus.Pentacle(this) );
			break;
		case 34: // SABRE
			sound = Const.SOUND_SABRE;
			Sabre.activate(this);
			break;
		case 35: // COFFRE OPTION
			sound = Const.SOUND_COFFRE;
			CoffreOptions.activate(this,b._x,b._y);
			break;
		case 36: // PIEU
			add_slot( new snake3.bonus.Pieu(this) );
			break;
		case 37: //POTION JAUNE
			sound = Const.SOUND_POTION;
			add_slot( new snake3.bonus.PotionFuca(this) );
			break;
		}
		b.destroy();
		if( sound != null )
			Manager.smanager.play(sound);
	}

	function gen_fruit_id() {
		return Math.min(1+random(Math.round(Const.FRUIT_BASE+fbarre*1.6)),Const.FRUIT_MAX);
	}

	function popup(x,y,txt) {
		var p : snake3.Popup = Std.cast(dmanager.attach("snake3_pop",Const.PLAN_DUMMIES));
		p.initPopup(this,x,y,txt);
	}

	function gen_fruit() {
		var id = gen_fruit_id();
		if( random(100) == 0 )
			id = int((id - 1) * Const.FRUIT_POURRIS_MAX / Const.FRUIT_MAX) + 321;
		var f = level.generate_fruit(id);
		f.time *= fruit_time_factor;
		var me = this;
		function f_on_timeout(f) {
			me.on_fruit_timeout(f);
		}
		f.on_timeout(f_on_timeout);
		return f;
	}
	
	function gen_bonus() {
		var id = 1+Std.randomProbas(bonus_probabilities);
		var b = level.generate_bonus(id);
		if( is_unique_bonus(id) )
			bonus_probabilities[id-1] = 0;
		return b;
	}

	function eat_fruit(f) {
		call_on_eat(f);
		if( random(2) == 0 )
			Manager.smanager.play(Const.SOUND_FRUIT_EAT_1);
		else
			Manager.smanager.play(Const.SOUND_FRUIT_EAT_2);

		var id = f.get_id();
		if( Encyclo.fruits[id] == undefined )
			Encyclo.fruits[id] = 1;
		else
			Encyclo.fruits[id]++;
		var points = f.points() * score_factor;
		score += points;
		popup(f._x,f._y,points);
		fbarre += Const.FBARRE_EAT_FRUIT;
		f.destroy();
	}

	function main() {
		var tmod = Std.tmod;		

		if( SnakeClient.STANDALONE ) { // CHEATER BEGIN
			var i;
			for(i=0;i<10;i++)
				if( Key.isDown(i+48) || Key.isDown(i+96) ) {
					if( bonus_cheat_key != i ) {
						bonus_cheat_key = i;
						if( bonus_cheat_id == 0 )
							bonus_cheat_id = i+1;
						else {
							var id = (bonus_cheat_id - 1) * 10 + i;
							level.generate_bonus(id);
							bonus_cheat_id = 0;
						}
					}
					break;
				}
			if( i == 10 )
				bonus_cheat_key = -1;	
		} // CHEATER END

		if( pause ) {
			if( !Manager.client.forcePause && Key.isDown(Key.ESCAPE) ) {
				if( !pause_flag ) {
					pause = false;
					pause_flag = true;
					pause_mc.removeMovieClip();
				}
			}
			else
				pause_flag = false;
			return;
		}

		updates.main();

		if( score < 0 )
			score = 0;
		score_mc.setVal(score);

		if( game_over_flag ) {
			if( snake.len > 0 ) {
				var timer = 4;
				if( snake.len > 10 )
					timer = 3;
				if( snake.len > 50 )
					timer = 2;
				if( snake.len > 100 )
					timer = 1;
				if( (fcounter++) % Math.max(1,int(timer/Std.tmod)) == 0 )
					snake.explode(snake.color);
				if( snake.len == 0 )
					snake.tete._visible = false;
				snake.draw();
			}
			else {
				if( game_over_text == null ) {
					game_over_text = new snake3.Text(dmanager.empty(Const.PLAN_INTERFACE),Const.SCREEN_CONNECTING,Const.TXT_SCORE_SAVING);					
					for(var k in Encyclo.fruits)
						if( Encyclo.fruits[k] > Const.FRUIT_DEBLOK-1 && !fruit_flags[k] )
							Manager.client.giveItem("Fruit "+k);
					Manager.saveScore(score);
				}
			}
			game_over_text.main();
			return;
		}

		trou.main();
		if( trou.z < 3 ) {
			trou.destroy();
			trou = null;
		}
		
		fbarre -= Const.FBARRE_PERMANENT_LOOSE * tmod;
		if( fbarre < 0 )
			fbarre = 0;
		else if( fbarre > Const.FBARRE_MAX )
			fbarre = Const.FBARRE_MAX;

		var fb = fbarre / Const.FBARRE_MAX * (Const.WIDTH - 125);
		var mid = Std.getVar(fbarre_mc,"mid");
		if( mid._width != fb ) {
			mid._width = mid._width*0.9 + fb*0.1;			
			Std.getVar(fbarre_mc,"b2")._x = Std.getVar(fbarre_mc,"b1")._x+mid._width;
		}

		if( random(Math.round(100/tmod)) == 0 ) {
			Std.getVar(snake.tete,"o1").play();
			Std.getVar(snake.tete,"o2").play();
		}

		if( random(Math.round(Const.FRUITS_FREQ*level.nfruits()/tmod)) == 0 )
			gen_fruit();


		if( slots.length + unique_slots.length + level.nbonus() < 10 ) {
			var k = Math.round((Const.BONUS_FREQ+score/500)*(level.nbonus()+1)/tmod - bonus_time/6);
			if( random(k) == 0 ) {
				bonus_time = 0;
				gen_bonus();
			} else
				bonus_time += tmod;
		}

		var keys = Manager.keys.config;
		if( enable_snake_keys ) {
			if( Key.isDown(keys[0]) ) {
				snake.ang -= snake.delta_ang*tmod;
				leftRelease_flag = false;
			} else
				leftRelease_flag = true;			
			if( Key.isDown(keys[1]) ) {
				snake.ang += snake.delta_ang*tmod;
				rightRelease_flag = false;
			} else
				rightRelease_flag = true;
		}

		snake.base_speed *= Math.pow(Const.CHALLENGE_FRICTION,tmod);		

		if( Key.isDown(keys[2]) ) {
			if( pieu )
				snake.base_speed = 1;
			else
				snake.base_speed = speed_up;
		}
		if( snake.base_speed < 1 ) {
			if( pieu )
				snake.base_speed = 0;
			else
				snake.base_speed = speed_normal;
		}

		if( Key.isDown(Key.SPACE) ) {
			if( space_flag == false ) {
				space_flag = true;
				if( slots[0].use() )
					remove_slot(slots[0]);
			}
		} else
			space_flag = false;
				
		if( Manager.client.forcePause || Key.isDown(Key.ESCAPE) ) {			
			if( !pause_flag ) {
				pause = true;
				pause_mc = dmanager.attach("screens",Const.PLAN_DUMMIES);
				pause_mc.gotoAndPlay("pause");
				pause_flag = true;
			}
		}
		else
			pause_flag = false;

		var hit = snake.move(level.bounds());
		var c = snake.collision();
		snake.draw();

		slots[0].update();
		var i;
		for(i=0;i<slots.length;i++)
			slots[i].permanent();
		for(i=0;i<unique_slots.length;i++)
			unique_slots[i].permanent();

		if( hit ) {
			game_over();
			return;
		}

		level.update(this);

		var f = level.get_fruit(c);
		if( f != null ) 
			eat_fruit(f);
		
		var b = level.get_bonus(c);
		if( b != null )
			get_bonus(b);
	}

//{
}
