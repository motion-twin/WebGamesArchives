package inter;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
using mt.bumdum9.MBut;

class HelpBox extends Box {//}

	public static var SQUARE_SIZE = 20;
	public static var STD_WIDTH = 180;
	public static var STD_HEIGHT = 180;
	
	public static var MARGIN = 4;
	
	public var active:Bool;
	
	var game:Game;
	var hero:Hero;
	var pageBox:SP;
	var page:SP;
	var cross:EL;
	
	
	public function new(gm) {
		game = gm;
		super(SQUARE_SIZE,SQUARE_SIZE);
		
		pageBox = new SP();
		addChild(pageBox);

		cross = new EL();
		addChild(cross);
		cross.makeBut( toggle, over );
		
		displayDefault();
		maj();
		
		setActive(false);
	}
	
	public function maj() {
		cross.x = mcw - 18;
		cross.y = 2;
	}
	

	public function setActive(fl) {
		active = fl;
		if ( active ) {
			page.visible = true;
			cross.goto(4, "grid_test",0,0);
		}else {
			cross.goto(5, "grid_test",0,0);
			
		}
	}
	public function toggle() {
		active = !active;
		page.visible = false;
		new fx.MorphHelp(this,active);
	}

	function over() {
		if( !active ) new mt.fx.Flash(this,0.3);
	}

	// PAGES
	public function displayDefault() {
		newPage();
		setTitle("Aide de jeu");
		desc("Survolez une combo pour obtenir des informations sur son effet");
	}
	public function displayBall(ball:Ball ){//hero:Hero, b:BallType, power:Int ) {
		
		var power = ball.group.list.length;
		var b = ball.type;
		this.hero = ball.board.hero;
		
		newPage();
		var data = Data.BALLS[Type.enumIndex(b)];
		
		// TITLE
		var title = setTitle(data.name);
		title.x += 26;
		
		// ICON
		var icon = new EL();
		icon.x = MARGIN;
		icon.y = MARGIN;
		icon.goto(Type.enumIndex(b), "ball",0,0);
		page.addChild(icon);
		

		// DESC
		var combo = game.uc.getCombo( { hero:hero, type:b, num:power, alt:null } );
		var str = Cs.rep(combo.desc,Std.string(combo.power),Std.string(combo.time),Std.string(combo.data.num),Std.string(combo.data.num*2));
		desc(str);
		
		
		
	}
	
	

	// FORMAT
	var cx:Int;
	var cy:Int;
	function newPage() {
		if ( page != null ) pageBox.removeChild(page);
		page = new SP();
		pageBox.addChild(page);
		page.visible = active;
		cx = MARGIN;
		cy = MARGIN;
	}
	function setTitle(str) {
		var f = Cs.getField(0xFFFFFF);
		page.addChild(f);
		f.x = cx;
		f.y = cy+3;
		f.text = str;
		cy += 20;
		return f;
	}
	function desc(str) {
		var f = Cs.getField(0xFFFFFF);
		f.multiline = f.wordWrap = true;
		page.addChild(f);
		f.width = STD_WIDTH - MARGIN * 2;
		f.x = cx;
		f.y = cy;
		f.htmlText = str;
		f.height = f.textHeight+4;
		cy += Math.ceil(f.height);
		return f;
	}
	


	
//{
}




