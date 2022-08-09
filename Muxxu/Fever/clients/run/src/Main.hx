import Protocole;
import mt.bumdum9.Lib;

class Main {//}
	
	public static var root:flash.display.MovieClip;
	
	public static var domain:String;
	public static var noplay:String;
	
	public static var wid:Int;
	public static var worldColor:Int;
	
	static function main() {
		
		Codec.VERSION = Data.CODEC_VERSION ;
		haxe.Serializer.USE_ENUM_INDEX = true;
		root = flash.Lib.current;
		Lang.init();
		Data.init();
		
		
		var data = Codec.getData("data");
		
		Codec.displayError = Main.traceError ;
		// GARBAGE COLLECTOR
		//mt.flash.Gc.init();	o_O
		
		//
		var par = flash.Lib.current.stage.loaderInfo.parameters;
		domain = 	Reflect.field( par, "dom") ;
		noplay = Reflect.field( par, "noplay") ;
		

		wid = 		Std.parseInt( Reflect.field( par, "wid") );
		
		// WORLDCOLOR
		worldColor =  Col.getRainbow((0.3+wid*0.3)%1);
		worldColor = Col.mergeCol(worldColor, 0x888888, 0.5);
		
		//
		Gfx.init();
		
		
		
		
		//var a = [];
		//for( k in 0...8 ) 	a.push( { _id:Std.random(90), _lvl:Std.random(50) } );
		//new player.FeverX( a );
		//var mc = new player.Adventure( Data.DATA._monsters[6], 0);
		//Main.root.addChild(mc);
		
		new World();
	}
	
	
	static public function traceError(str) {
		
		var sp = new SP();
		var ww = Cs.mcw * 0.5;
		var hh = Cs.mcrh * 0.5;
		
		var f = Cs.getField(0xFF0000, 8, -1, "nokia");
		f.width = ww;
		f.height = hh;
		f.multiline = f.wordWrap = true;
		f.selectable = true;
		f.text = str;
		sp.addChild(f);
		sp.graphics.beginFill(0);
		sp.graphics.drawRect(0, 0, ww, hh);
		sp.scaleX = sp.scaleY = 2;
		flash.Lib.current.addChild(sp);
		
		sp.y = Cs.mcrh;
		//
		new mt.fx.Tween(sp, 0, 0).curveInOut();
		
	}
	

	// implementer texte irvie

	// Volatile
	// refaire la  jonction eau
	// sargon boss
	// Refaire anim ping_explode sans sol
	// ne pas pouvoir retomber sur un jeu deux fois d'affilé.
	// bug si couteau arrive apres le début du jeu.
	
	// Tapisserie mouches
	
	// goutte de sueur
	// EVO : coffre rouge : ne s'ouvre que si toutes les iles autour sont nettoyées.
	// OVO : Dieu> retenir l'id de statue courant = icone coloré + avantages inMinigame
	// trouver un moyen de forcer un wideSquare par ile.
	
	// BAGUETTE ?
	// COFFRE ROUGE ET VERT ?

	// Item : +1 Joker gratuit a chaque partie ?
	
	// BUG >> le premier jeu de la liste est sauté (selon les lunettes)
	
	
	// SCORE TABLE : name --- 21x monstre // 453x iles // 22xitems // 6xglyphs // 12x status
	
//{
}