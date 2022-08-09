import mb2.Const;
import mb2.Manager;

class mb2.Pause {

	var game : mb2.Game;
	var carte;
	var cmanager;
	var pause_mc;

	var last_map_item;

	static var OBJFRAMES = [19,22,23,24];
	static var BONUSFRAMES = [21,20,28,0,27,29,30];

	function Pause(game : mb2.Game) {
		this.game = game;

		if( game.options.has_map || game.options.has_radar )
			show_map();

		var ct = {
			ra : 50,
			rb : 30,
			ga : 70,
			gb : 0,
			ba : 50,
			bb : 30,
			aa : 100,
			ab : 0
		};		
		game.main_color.setTransform(ct);		
		game.root_mc._parent.attachMovie("pause","pause_mc",0);
		pause_mc = game.root_mc._parent["pause_mc"];
	}

	function endPause() {
		carte.removeMovieClip();
		pause_mc.removeMovieClip();		
		game.main_color.reset();
		game.boss_update.onPause(false);
		game.pause = null;
	}

	function destroy() {
		endPause();
	}

	function main() {
		if( Key.isDown(Key.ESCAPE) && !Manager.client.forcePause ) {
			if( !game.pause_key_flag ) {
				game.pause_key_flag = true;
				endPause();
			}
		} else
			game.pause_key_flag = false;
	}

// ---------------------------------------------------------------------------

	function gen_map_item(px,py,frame) {
		if( frame == 0 )
			return;
		var mc2 = cmanager.attach("room",(frame > 14)?0:1);
		mc2._x = px;
		mc2._y = py;
		mc2.gotoAndStop(frame);
		if( frame > 14 )
			last_map_item = mc2;
		return mc2;
	}

// ---------------------------------------------------------------------------

	function path_open(x,y,n) {
		var p = game.level.dungeon[x][y].paths[n].ptype;
		return p != 1 && p != 2;
	}

// ---------------------------------------------------------------------------

	function show_map() {
		game.root_mc._parent.attachMovie("carte","carte_mc",1);
		carte = game.root_mc._parent["carte_mc"];
		cmanager = new asml.DepthManager(carte);
		carte._x = 95;
		carte._y = 55;
		var x,y;
		for(x=0;x<8;x++)
			for(y=0;y<8;y++) {
				var room = game.level.dungeon[x][y];
				var px = 18+48*x;
				var py = 16+36*y;
				if( room.rtype != 0 ) {
					var t = 0;
					if( x == game.level.pos_x && y == game.level.pos_y ) {
						gen_map_item(px,py,34);
						t = 8;
					} else if( room.visited && game.options.has_map ) {
						gen_map_item(px,py,33);
						t = 4;
					}
					if( game.options.has_map ) {
						var st = t;
						if( path_open(x,y,0) && path_open(x-1,y,1) ) {
							if( x-1 == game.level.pos_x && y == game.level.pos_y )
								t = 8;
							else if( t != 8 && game.level.dungeon[x-1][y].visited )
								t = 4;
							gen_map_item(px,py,1+t);
						}
						t = st;
						if( path_open(x,y,2) && path_open(x,y-1,3) ) {
							if( x == game.level.pos_x && y-1 == game.level.pos_y )
								t = 8;
							else if( t != 8 && game.level.dungeon[x][y-1].visited )
								t = 4;
							gen_map_item(px,py,2+t);
						}
					}
				}
				switch( room.rtype ) {
				case 0:
					if( game.options.has_map )
						gen_map_item(px,py,14+random(4));
					break;
				case 1: // NORMAL
				case 5: // OBJNEED
					if( game.options.has_radar && x == game.level.start_x && y == game.level.start_y ) 
						gen_map_item(px,py,26);
					break;
				case 2: // EXIT
					if( game.options.has_radar )
						gen_map_item(px,py,31);
					break;
				case 3: // OBJFOUND
					if( game.options.has_radar && room.rdata != -1 )
						gen_map_item(px,py,OBJFRAMES[room.rdata]);
					break;
				case 4: // BONUSFOUND
					if( game.options.has_radar && room.rdata != -1 )
						gen_map_item(px,py,BONUSFRAMES[room.rdata]);
					break;
				}
			}
		carte.grille.swapDepths(last_map_item);
	}

}