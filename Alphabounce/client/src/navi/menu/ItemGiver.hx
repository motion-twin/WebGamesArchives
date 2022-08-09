package navi.menu;
import mt.bumdum.Lib;
import mt.bumdum.Bouille;
import lander.House;
import Protocol;
import lander.House;

class ItemGiver extends navi.menu.People{//}

	var itemId:Int;
	var price:mt.flash.VarSecure;

	public function new(x,y,seed,id){
		itemId = id;
		super(x,y,seed);
	}

	override function init(){
		super.init();


		var flOk = Cs.pi.items[itemId] == MissionInfo.GROUND;

		switch(itemId){
			case MissionInfo.SALMEEN_COUSIN :		setText( Text.get.ITEM_GIVER_SALMEEN_COUSIN		);
			case MissionInfo.BADGE_FURI :			setText( Text.get.ITEM_GIVER_BADGE_FURI		);
			case MissionInfo.BALL_DOUBLE :			setText( Text.get.ITEM_GIVER_SAUMIR			);
			case MissionInfo.RETROFUSER :			setText( Text.get.ITEM_GIVER_SACTUS			);
			case MissionInfo.KARBONITE :			setText( flOk?Text.get.ITEM_GIVER_SAFORI_1:Text.get.ITEM_GIVER_SAFORI_0 );
			case MissionInfo.COMBINAISON:			setText( Text.get.ITEM_GIVER_COMBINAISON		);

			default:
				if( itemId>=MissionInfo.TBL_0 && itemId<=MissionInfo.TBL_11 ){
					var a = Text.get.ITEM_GIVER_TABLET_KARBONIS_1;
					var str = Text.get.ITEM_GIVER_TABLET_KARBONIS_0 + a[itemId-MissionInfo.TBL_0] + Text.get.ITEM_GIVER_TABLET_KARBONIS_2;
					setText(str);

				}else if(  itemId>=MissionInfo.EMAP_0 && itemId<=MissionInfo.EMAP_41 ){
					var seed = new mt.Rand(itemId);
					price = new mt.flash.VarSecure( 500+seed.random(4000) );
					var str = Text.get.ITEM_GIVER_EMAP_0;
					str = Str.searchAndReplace(str,"::price::",""+price.get());
					setText(str);
					if(flash.Key.isDown(flash.Key.ENTER))lander.Game.me.min.addValue(5000);

				}else{
					flOk = false;
					setText(Text.get.ITEM_GIVER_TABLET_KARBONIS_3);
				}


		}

		if(price!=null){
			if(price.get()<=Cs.pi.minerai)addBut(0,accept);
			addBut(2,quit);
			return;
		}

		if(flOk)addBut(0,accept); else addBut(2,quit);


	}

	public function accept(){

		lander.Game.me.item = new mt.flash.VarSecure( itemId );
		if(price!=null)lander.Game.me.debit.add(price);

		var h = lander.Game.me.hero.currentHouse;
		h.scn = Empty;
		navi.Map.me.removeMenu(0);
		quit();
	}


	static public function getScn(n){
		switch(Cs.pi.items[n]){
			case null :
				if( n == MissionInfo.KARBONITE )						return ItemGiver(n);
				if( n>= MissionInfo.EMAP_0 && n<= MissionInfo.EMAP_41 )	return ItemGiver(n);

				return Locked;
			case MissionInfo.GROUND:	return ItemGiver(n);
			case MissionInfo.COLLECTED:	return Empty;

		}

		return Empty;
	}





//{
}








