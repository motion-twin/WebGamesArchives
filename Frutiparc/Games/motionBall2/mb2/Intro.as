import mb2.Sound;

class mb2.Intro {

	var dmanager;
	var letters;

	var root_mc;

	var tot_time;
	var menu_time;
	var menu_phase;
	var scale_factor;
	var scale_factor_way;

	var deux;
	var deux_speed;
	var deux_color;
	var shade_deux;
	var menu_trembl;
	var menu_trembl_way;

	var fade_time;
	var press_start

	function Intro( mc : MovieClip ) {
		var i;
		root_mc = mc;
		dmanager = new asml.DepthManager(mc);
		letters = new Array();
		dmanager.attach("intro_bg",0);
		for(i=0;i<10;i++) {
			var t = dmanager.attach("title",3);
			letters[i] = t;
			if( i < 6 ) {
				t._x = i * 80 + 110;
				t._y = 100+random(10);
				t.base_y = t._y;
				t._xscale = 0;
				t._yscale = 0;
			} else {
				t.dx = (i - 6) * 70 + 200;
				t.dy = 280+random(10);
				t.base_y = t.dy;
				t.sx = (t.dx - 305) * 10 + 305;
				t.sy = 400+random(100);
				t._x = t.sx;
				t._y = t.sy;
			}
			t.gotoAndStop(i+1);
		}
		tot_time = 0;
		menu_time = 0;
		menu_phase = 0;
		scale_factor = 10;
		scale_factor_way = true;

		var me = this;
		mc.onMouseDown = function() {
			me.onMouseDown();
			delete(mc.onMouseDown);
		};
		mc.useHandCursor = false;
		Sound.playMusic(Sound.MUSIC_INTRO);
	}

	function onMouseDown() {
		mb2.Manager.gotoMenu();
	}

	function main() {
		var tmod = Std.tmod;
		var i;
		tot_time += tmod;
		menu_time += tmod / 30;
		if( menu_time > 1 )
			menu_time = 1;
		switch( menu_phase ) {
		case 0:
			for(i=0;i<6;i++) {
				var t = letters[i];
				var s = menu_time * 100 + scale_factor * Math.cos(i+tot_time/20);
				t._y = t.base_y + (s - 100)/2;
				t._xscale = s;
				t._yscale = s;		
			}
			for(i=6;i<10;i++) {
				var t = letters[i];
				t._x = (t.dx - t.sx)*menu_time+t.sx;
				t._y = (t.dy - t.sy)*menu_time+t.sy;
				t._rotation += 10*tmod+random(3);
				t.retrot = true;
				t.rotspeed = 1;
				t.rotfactor = 2;
			}
			if( menu_time == 1 )
				menu_phase++;
			break;
		case 1:
			for(i=0;i<10;i++) {
				var t = letters[i];
				var s = 100+scale_factor * Math.cos(i+tot_time/20);
				t._y = t.base_y + (s - 100)/2;
				t._xscale = s;
				t._yscale = s;
				if( t.retrot ) {
					t._rotation += tmod*t.rotfactor*t.rotspeed;
					if( Math.abs(t._rotation) < 5 )
						t.retrot = false;
				}
			}
			shade_deux._alpha += tmod/2;
			if( tot_time > 80 && !shade_deux ) {
				shade_deux = dmanager.attach("deux",0);
				shade_deux.color = new Color(shade_deux);
				shade_deux.color.setRGB(0x9241C2);
				shade_deux.time = 1;
				shade_deux._x = 305;
				shade_deux._y = 205;
				shade_deux._xscale = 300;
				shade_deux._yscale = 300;
			}
			if( tot_time > 100 ) {
				for(i=0;i<10;i++) {
					var t = letters[i];
					t.sx = t._x;
					t.sy = t._y;
					t.dx = t.sx - 305;
					t.dy = t.sy - 205;
					t.sy /= 2;
					var l = Math.sqrt(t.dx*t.dx+t.dy*t.dy);
					t.dx /= l;
					t.dy /= l;
				}
				menu_phase++;
			}
			break;
		case 2:
			shade_deux._xscale += tmod;
			shade_deux._yscale += tmod;
			shade_deux.time -= Std.tmod / 70;
			var rgb = (int(0x92*shade_deux.time)<<16) | (int(0x41*shade_deux.time) << 8) | int(0xC2*shade_deux.time);
			shade_deux.color.setRGB(rgb);

			var b = true;
			for(i=0;i<10;i++) {
				var t = letters[i];
				t._x += t.dx*10;
				t._y += t.dy*10;
				t.dx *= Math.pow(1.2,tmod);
				t.dy *= Math.pow(1.2,tmod);
				if( t._x > -50 && t._x < 660 )
					b = false;
			}
			if( b ) {
				deux = dmanager.attach("deux",1);
				deux._x = 305;
				deux._y = 800;
				deux._xscale = 800;
				deux._yscale = 800;
				deux_speed = 3;
				menu_phase++;
			}
			break;
		case 3:
			deux_speed *= Math.pow(1.06,tmod);
			if( deux._y >= shade_deux._y ) {
				deux._y -= tmod*deux_speed;
				if( deux._y < shade_deux._y )
					deux._y = shade_deux._y;
			}
			if( deux._xscale >= shade_deux._xscale ) {
				deux._xscale -= tmod*deux_speed/1.2;
				deux._yscale -= tmod*deux_speed/1.2;
			} else {
				shade_deux.removeMovieClip();
				deux.sy = deux._y;
				deux.ox = deux._x;
				deux.oy = deux._y;
				menu_phase++;
				menu_trembl = 5;
				menu_trembl_way = 1;

				for(i=0;i<20;i++) {
					var f = dmanager.attach("fissure",0);
					f.gotoAndStop(random(f._totalframes)+1);
					f._rotation = 360 * i / 20;
					f._xscale = 100+random(50);
					f._yscale = 100+random(50);
					f._x = deux._x;
					f._y = deux._y;
					letters.push(f);
				}
				
			}
			break;
		case 4:
			deux.oy = deux._y;
			deux._y = deux.sy;
			root_mc._y = menu_trembl*menu_trembl_way;
			menu_trembl-=0.3;
			if( menu_trembl <= 0 )
				menu_phase++;
			menu_trembl_way *= -1;
			break;
		case 5:
			root_mc._y = 0;
			var b = true;
			for(i=0;i<10;i++) {
				var t = letters[i];
				var s = 100+scale_factor * Math.cos(i+tot_time/20);
				t._x += (t.sx - t._x)/10;
				t._y += (t.sy - t._y)/10;
				t._xscale = s;
				t._yscale = s;
				if( Math.abs(t._x-t.sx)+Math.abs(t._y-t.sy) > 3 )
					b = false;
			}
			if( b ) {
				menu_phase++;
				fade_time = 0;
				deux_color = new Color(deux);
				press_start = dmanager.attach("press start",1);
			}
			break;
		case 6:
			fade_time+=tmod * 10;
			if( fade_time > 255 )
				fade_time = 255;
			var alpha = 100 - fade_time / 2.55;
			var ct = {
				ra : alpha ,
				rb : fade_time * 0.8 * 0.5,
				ga : alpha,
				gb : 0,
				ba : alpha,
				bb : fade_time * 0.5,
				aa : 100,
				ab : 0
			};
			deux_color.setTransform(ct);

			for(i=0;i<10;i++) {
				var t = letters[i];
				var s = 100+scale_factor * Math.cos(i+tot_time/20);
				t._y = (t.base_y / 2) + (s - 100)/2;
				t._xscale = s;
				t._yscale = s;
				if( !t.hasrot && !t.retrot && random(1000) == 0 ) {
					t.rotfactor = 5+random(2);
					t.rotspeed = 1;
					t.hasrot = true;
				}
				if( t.hasrot ) {
					t.rotspeed *= Math.pow(1.03,tmod);
					t._rotation += tmod*t.rotfactor*t.rotspeed;
					if( t.rotspeed > 3 )
						t.rotfactor *= Math.pow(0.95,tmod);
					if( t.rotspeed * t.rotfactor < 4 ) {
						t.hasrot = false;
						t.retrot = true;
					}
				}
				if( t.retrot ) {
					t._rotation += tmod*t.rotfactor*t.rotspeed;
					if( Math.abs(t._rotation) < 5 )
						t.retrot = false;
				}
			}
			if( random(30) == 0 || scale_factor < 5 || scale_factor > 15 )
				scale_factor_way = !scale_factor_way;
			if( scale_factor_way )
				scale_factor+=0.1;
			else
				scale_factor-=0.1;
			break;
		}
	}

	function destroy() {
		delete(root_mc.onMouseDown);
		dmanager.destroy();
		root_mc._y = 0;
		var i;
		for(i=0;i<letters.length;i++)
			letters[i].removeMovieClip();
	}
}
