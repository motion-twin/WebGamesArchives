import Protocole;
import mt.bumdum9.Lib;

class GfxIcons extends BMD{}

class Gfx implements haxe.Public {//}
	
	static var icons:mt.pix.Store;

	static function init() {
		
		var bmp = new GfxIcons(0, 0);
		icons = new mt.pix.Store(bmp);
		icons.makeTransp(0xFFFFFFFF);
		
		icons.addIndex("ball");
		icons.slice(0, 0, 20, 20, 10, 5);
		
		
		icons.addIndex("stock");
		icons.slice(0, 136, 8, 8, 10, 5);
		icons.addIndex("skills");
		icons.slice(80, 136, 8, 8, 10,5);
		
		icons.addIndex("small");
		icons.slice(0, 120, 8, 8, 20);
		icons.addIndex("status");
		icons.slice(160, 136, 8, 8, 5, 5);
		
		icons.addIndex("actions");
		icons.slice(0, 128, 8, 8, 20);
		icons.addIndex("actions_big");
		icons.slice(0, 208, 16, 16, 10,3);
		
		icons.addIndex("grid_test");
		icons.slice(0, 176, 16, 16, 16);
		
		icons.addIndex("text_buts");
		icons.slice(0, 192, 48, 16,3,2 );
		
		//
		mt.pix.Element.DEFAULT_STORE = icons;
		
	}


//{
}