package browser;
import Protocole;
import mt.bumdum9.Lib;

private typedef PlayerSlot = { base:SP, av:Avatar, data:_DataPlayer, fields:Array<TF>  };

class Build extends Browser {//}
	

	
	public function new(data) {
		super(data);
		

		initNav();
		
		
		action = updateSelection;
		
		var handOk = checkHand();
		if(data._plays < 10 && handOk ) initScroller(Lang.BROWSER_TUTO);
		if( !handOk) 					displayWarning(Lang.BROWSER_NO_CARD);
		
		
		
		
	}

//{
}


















