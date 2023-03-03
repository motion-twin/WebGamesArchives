import snake3.Const;
import snake3.Manager;

class snake3.Encyclo {

	public static var fruits = null;

	static var BOOK_X = 53;
	static var BOOK_Y = 20;
	static var PAGE_WIDTH = 297;
	static var PAGE_HEIGHT = 443 ;
	static var BOOK_WIDTH = PAGE_WIDTH*2 ;
	static var BOOK_HEIGHT = PAGE_HEIGHT ;
	static var LINE_LENGTH = 1000 ;

	static var FLIP_SPEED = 1 ;
	static var FRICTION = 0.98 ;

	static var AUTOFALL_LIMIT = 20 ;

	static var LEFT = 0 ;
	static var RIGHT = 1 ;

	var mc;
	var hole : MovieClip;
	var book : MovieClip;
	var bookLeft : MovieClip;
	var bookRight : MovieClip;
	var rightPage : MovieClip;
	var leftPage : MovieClip;
	var dropCorner : MovieClip;
	var dropLarge : MovieClip;
	var leftMask : MovieClip;
	var rightMask : MovieClip;
	var cornerMask : MovieClip;
	var largeMask : MovieClip;

	var speed;
	var currentPage;

	var nfruits;
	var nnames;
	var totfruits;
	var maxpoints;

	var mouse_is_down;

	function Encyclo( root_mc : MovieClip ) {
		mc = Std.attachMC(root_mc,"encyclo",0);

		var fback = Std.getVar(mc,"fback");
		var me = this;
		function func_back() {
			me.on_back();
		}
		fback.onPress = func_back;
		mouse_is_down = false;
		init_book();
	}

	function init_book() {
		var dp = 0;

		book = Std.attachMC(mc,"bookBase",dp++);
		book._x = BOOK_X;
		book._y = BOOK_Y;

		bookLeft = Std.attachMC(mc,"page",dp++);
		bookLeft._x = BOOK_X + PAGE_WIDTH;
		bookLeft._y = BOOK_Y + PAGE_HEIGHT + PAGE_WIDTH;
		bookLeft._rotation = 0;

		bookRight = Std.attachMC(mc,"page",dp++);
		bookRight._x = BOOK_X + PAGE_WIDTH*2 + 1.5;
		bookRight._y = BOOK_Y + PAGE_HEIGHT + PAGE_WIDTH;
		bookRight._rotation = 0;

		hole = Std.attachMC(mc,"bookHole",dp++);
		hole._x = BOOK_X;
		hole._y = BOOK_Y;

		rightPage = Std.attachMC(mc,"page",1000);
		rightPage._x = BOOK_X + PAGE_WIDTH*2 + 1.5;
		rightPage._y = BOOK_Y + PAGE_HEIGHT + PAGE_WIDTH;
		rightPage._rotation = 0;

		leftPage = Std.attachMC(mc,"page",1001);
		leftPage._x = BOOK_X + PAGE_WIDTH;
		leftPage._y = BOOK_Y + PAGE_HEIGHT + PAGE_WIDTH;
		leftPage._rotation = 0;

		dropCorner = Std.attachMC(mc,"dropCorner",dp++);
		dropCorner._x = leftPage._x;
		dropCorner._y = leftPage._y;
		dropCorner._rotation = 0;
		dropCorner._alpha = 0;

		dropLarge = Std.attachMC(mc,"dropLarge",dp++);
		dropLarge._x = leftPage._x;
		dropLarge._y = leftPage._y;
		dropLarge._rotation = 0;
		dropLarge._alpha = 0;

		leftMask = Std.createEmptyMC(mc,dp++);
		rightMask = Std.createEmptyMC(mc,dp++);

		cornerMask = Std.attachMC(mc,"bookMask",dp++);
		cornerMask._x = BOOK_X;
		cornerMask._y = BOOK_Y;
		dropCorner.setMask(cornerMask);

		largeMask = Std.attachMC(mc,"bookMask",dp++);
		largeMask._x = BOOK_X;
		largeMask._y = BOOK_Y;
		dropLarge.setMask(largeMask);

		// inits additionnels
		var me = this;
		function f_on_down() {
			me.mouse_is_down = true;
		}
		function f_on_up() {
			me.mouse_is_down = false;
		}
		
		book.onPress = f_on_down;
		book.onRelease = f_on_up;

		nfruits = 0;
		nnames = 0;
		totfruits = 0;
		maxpoints = 0;
		for(var i in fruits)
			if( fruits[i] > 0 ) {
				totfruits += fruits[i];
				nfruits++;
				if( fruits[i] > Const.FRUIT_NAME_LEARN - 1 )
					nnames++;
				var s = Const.fruit_points(i);
				if( s > maxpoints )
					maxpoints = s;
			}

		// Données de parcours du livre
		speed = 0;
		currentPage = 0;
		leftPage._rotation = 90;
		updatePages();
		update();
	}

	private function update() {

		// Masque de page
		var ratio = leftPage._rotation/90;
		var angRad = Math.PI/180 * (ratio*45);
		var dx = LINE_LENGTH * Math.sin(angRad);
		var dy = LINE_LENGTH * Math.cos(angRad);

		leftMask.clear();
		leftMask.lineStyle(undefined,undefined,undefined);
		leftMask.beginFill(0xff0000,100);
		leftMask.moveTo( BOOK_X, BOOK_Y-BOOK_HEIGHT*0.5 );
		leftMask.lineTo( BOOK_X, BOOK_Y+BOOK_HEIGHT );
		leftMask.lineTo( BOOK_X+PAGE_WIDTH, BOOK_Y+BOOK_HEIGHT + PAGE_WIDTH );
		leftMask.lineTo( BOOK_X+PAGE_WIDTH+dx, BOOK_Y+BOOK_HEIGHT + PAGE_WIDTH-dy );
		leftMask.endFill();

		rightMask.clear();
		rightMask.lineStyle(undefined,undefined,undefined);
		rightMask.beginFill(0xff0000,100);
		rightMask.moveTo( BOOK_X, BOOK_Y-BOOK_HEIGHT*0.5 );
		rightMask.lineTo( BOOK_X, BOOK_Y+BOOK_HEIGHT );
		rightMask.lineTo( BOOK_X+PAGE_WIDTH, BOOK_Y+BOOK_HEIGHT + PAGE_WIDTH );
		rightMask.lineTo( BOOK_X+PAGE_WIDTH+dx, BOOK_Y+BOOK_HEIGHT + PAGE_WIDTH-dy );
		rightMask.endFill();

		leftPage.setMask(leftMask);
		rightPage.setMask(rightMask);

		// Ombre de la page
		Std.cast(leftPage).grad._alpha = ratio * 100;

		// Ombre portée sous le coin
		dropCorner._rotation = 45 * ratio;
		dropCorner._alpha = ratio * 85;

		// Ombre portée sous la page large
		dropLarge._rotation = 45 * ratio;
		if ( currentPage>=2 )
			dropLarge._alpha = (1-ratio*1.5) * 90;
		else
			dropLarge._alpha = 0;

	}

	private function updatePage(p,cur,side) {
		switch( cur ) {
		case 0:
			p.gotoAndStop("3");			
			break;
		case 1:
			p.gotoAndStop("5");
			break;
		case 2:
			p.gotoAndStop("4");
			var txt = "Vous avez rammassé "+totfruits+" fruits.\n\n";
			txt += "Vous avez "+nfruits+" fruits sur une collection\nde "+(Const.FRUIT_MAX+Const.FRUIT_POURRIS_MAX)+" au total.\n\n";
			txt += "Vous avez découvert le nom\nde "+nnames+" fruits ("+int(nnames*100/(Const.FRUIT_MAX+Const.FRUIT_POURRIS_MAX))+"% découverts).\n\n";
			txt += "Votre plus gros fruit vous a\nrapporté "+maxpoints+" points.";
			Std.getVar(p,"sommaire").text = txt;
			break;
		default:
			if( side == LEFT )
				p.gotoAndStop("1");
			else
				p.gotoAndStop("2");
			updateTemplate(Std.getVar(p,"tpl"), cur-3, side);
			break;
		}
	}

	private function updatePages() {
		updatePage(bookLeft,currentPage-1,LEFT);
		updatePage(rightPage,currentPage,RIGHT);
		updatePage(leftPage,currentPage+1,LEFT);
		updatePage(bookRight,currentPage+2, RIGHT);
		Std.getVar(bookRight,"grad")._visible = false;
		Std.getVar(bookLeft,"grad")._visible = false;
		Std.getVar(rightPage,"grad")._visible = false;
	}

	private function updateTemplate(mc, id, side) {
		var fid = id+1;
		if( id >= 300 )
			fid += 20;

		var total = fruits[fid];

		// Skin
		mc.skin.gotoAndStop(fid);
		var col = new Color(mc.skin);
		if( total > 0 ) {
			col.reset();
		} else
			col.setTransform({
				ra : 0,
				rb : 0x7F,
				ga : 0,
				gb: 0xB4,
				ba : 0,
				bb : 0x38,
				aa : 1000,
				ab : 1000
			});

		// Pagination
		if ( side==LEFT ) {
			mc.pageLeft.text = id+1;
			mc.pageRight.text = "";
		}
		else {
			mc.pageLeft.text = "";
			mc.pageRight.text = id+1;
		}

		// Noms
		if( total > Const.FRUIT_NAME_LEARN-1 )
			mc.name.text = Const.FRUIT_NAMES[id];
		else if( total > 0 )
			mc.name.text = Const.TXT_FRUIT_NAME_EN_COURS;
		else
			mc.name.text = Const.TXT_FRUIT_NAME_UNKNOWN;


		// Compte
		if ( total > 0 ) {
			mc.count.text = string(total);
			mc.value.text = Const.fruit_points(fid);
		} else {
			mc.count.text = Const.TXT_ENCYCLO_ZEROFRUITS;
			if( random(1000) == 0 )
				mc.value.text = Const.TXT_ENCYCLO_VALUEUNK_SPECIAL;
			else
				mc.value.text = Const.TXT_ENCYCLO_VALUEUNK;
		}
	}

	function on_back() {
		Manager.returnMenu();
	}

	function main() {
		var move = false;

		// Touches
		if ( Key.isDown(Key.RIGHT) || (mouse_is_down && Std.xmouse() > Const.WIDTH/2) ) {
			if( currentPage != 322 && Math.abs(speed) < 0.1 )
				Manager.smanager.play(Const.SOUND_PAGE);
			speed -= FLIP_SPEED;
			move = true;
		}
		if ( Key.isDown(Key.LEFT) || (mouse_is_down && Std.xmouse() < Const.WIDTH/2) ) {
			if( currentPage != 0 && Math.abs(speed) < 0.1 )
				Manager.smanager.play(Const.SOUND_PAGE);
			speed += FLIP_SPEED;
			move = true;
		}

		// Chute auto de la page
		if ( !move ) {
			if ( leftPage._rotation>=AUTOFALL_LIMIT )
				speed += FLIP_SPEED*0.5;
			if ( leftPage._rotation<AUTOFALL_LIMIT )
				speed -= FLIP_SPEED*0.5;
		}

		// Déplacement
		speed *= Math.pow(FRICTION,Std.tmod);
		leftPage._rotation += speed * Std.tmod;

		// Tourne vers la droite
		if( speed > 0 && leftPage._rotation > 90 ) {
			if( move ) {
				if ( currentPage > 0 ) {
					leftPage._rotation -= 90;
					previousPage();
				}
				else {
					speed = 0;
					leftPage._rotation = 90;
				}
			}
			else {
				leftPage._rotation = 90;
				speed = 0;
			}
		}


		// Tourne vers la gauche
		if ( speed < 0 && leftPage._rotation < 0 ) {
			if( move ) {
				if( currentPage < Const.FRUIT_MAX+Const.FRUIT_POURRIS_MAX ) {
					leftPage._rotation += 90;
					nextPage();
				}
				else {
					speed = 0;
					leftPage._rotation = 0;
				}
			}
			else {
				leftPage._rotation = 0;
				speed = 0;
			}
		}

		// Mise à jour graphique
		update();

		// Couverture
		if ( currentPage == 0 && leftPage._rotation > 0 )
			hole._visible = true;
		else
			hole._visible = false;
	}

	function previousPage() {
		currentPage -= 2 ;
		updatePages() ;
	}

	function nextPage() {
		currentPage+=2 ;
		updatePages() ;
	}

	function close() {
		mc.removeMovieClip();
	}

}