package navi.menu;
import mt.bumdum.Lib;
import mt.bumdum.Bouille;
import lander.House;
import Protocol;


class Info extends navi.menu.People{//}


	var rewardMin: mt.flash.VarSecure;
	var rewardCaps: mt.flash.VarSecure;

	var seed:mt.OldRandom;

	override function init(){
		super.init();
		seed = new mt.OldRandom(Cs.pi.x*10000+Cs.pi.y);

		//


		initText();


		addBut(2,quit);
	}


	function initText(){

		var lvl = lander.Game.me.level;
		var dst = lvl.dst;


		// CRYSTAUX
		if( seed.random(24)==0 ){
			var n = MissionInfo.CRYSTAL_0+seed.random(5) ;
			var o = MissionInfo.ITEMS[n];
			var str = Str.searchAndReplace(Text.get.GOSSIP_CRYSTAL,"::coord::","["+o.x+"]["+o.y+"]");
			setText(str);
			return;
		}

		// NOYAUX
		if( seed.random(16)==0 ){
			var n = MissionInfo.ANTIMAT_0 + seed.random(4) ;
			var o = MissionInfo.ITEMS[n];
			var str = "";
			var a = Text.get.GOSSIP_NOYAUX_0;
			str += a[seed.random(a.length)];
			str += Text.get.GOSSIP_NOYAUX_1;
			var str = Str.searchAndReplace(str,"::coord::","["+o.x+"]["+o.y+"]");
			setText(str);
			return;
		}

		// TABLETTES
		if( seed.random(14)==0 ){
			var n = MissionInfo.SCROLL_0+seed.random(8) ;
			var o = MissionInfo.ITEMS[n];
			var str = Str.searchAndReplace(Text.get.GOSSIP_TABLET,"::coord::","["+o.x+"]["+o.y+"]");
			setText(str);
			return;
		}

		// ASPHALT
		if( seed.random(100)==0 ){
			setText(Text.get.GOSSIP_ASPHALT);
			return;
		}

		// BLABLA
		if( seed.random(7)==0 ){
			var a = Text.get.GOSSIP_DEFAULT;
			setText(a[seed.random(a.length)]);
			return;
		}


		// MISSILE
		var n = MissionInfo.MISSILE+ seed.random(MissionInfo.MISSILE_MAX);
		var o = MissionInfo.ITEMS[n];
		var str = Str.searchAndReplace(Text.get.GOSSIP_MISSILE_0,"::coord::","["+o.x+"]["+o.y+"]");
		var a = Text.get.GOSSIP_MISSILE_1;
		str += a[seed.random(a.length)];
		setText(str);


		//

	}




//{
}








