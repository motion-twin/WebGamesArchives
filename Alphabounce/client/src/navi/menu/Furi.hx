package navi.menu;
import mt.bumdum.Lib;
import mt.bumdum.Bouille;

import lander.House;
import Protocol;


class Furi extends navi.menu.People{//}


	var rewardMin: mt.flash.VarSecure;
	var rewardCaps: mt.flash.VarSecure;

	var seed:mt.OldRandom;

	override function init(){
		super.init();


		switch( Cs.pi.items[MissionInfo.EVASION] ){
			case 0:


		}

		seed = new mt.OldRandom(Cs.pi.x*10000+Cs.pi.y);
		var str = "";

		// INTRO
		var a = Text.get.FURI_HELLO;
		str += a[seed.random(a.length)];

		// BASE
		var a = Text.get.FURI_ARGUE;
		str += a[seed.random(a.length)];

		// PROPOSITION FURI
		if( Cs.pi.gotItem(MissionInfo.EVASION) ){

			if(seed.random(2)==0){
				rewardMin = new mt.flash.VarSecure( 20+seed.random(180) );
				str += Text.get.FURI_REWARD_MIN;

			}else{
				rewardCaps = new mt.flash.VarSecure( 2+seed.random(6) );
				str += Text.get.FURI_REWARD_CAPS;
			}
			addBut(0,accept);

		}else{

			var a = Text.get.FURI_END_1;
			str +=  Text.get.FURI_END_0 + a[seed.random(a.length)];
		}

		setText(  str );

		addBut(2,quit);
		if( Cs.pi.missions[35]==0 )addBut(3,betray);

	}

	public function betray(){

		lander.Game.me.hero.currentHouse.mark();
		lander.Game.me.incCaps(new mt.flash.VarSecure(5));

		//
		endTimer = 70;
		removeAllButs();

		var a =  Text.get.FURI_BETRAY;
		setText(a[seed.random(a.length)]);



		//quit();
	}

	public function accept(){

		lander.Game.me.hero.currentHouse.mark();
		if( rewardMin != null )		lander.Game.me.incMinerai( rewardMin );
		if( rewardCaps != null )	lander.Game.me.incCaps( rewardCaps );

		endTimer = 70;
		removeAllButs();
		var a =  Text.get.FURI_LUCK;
		setText(a[seed.random(a.length)]);

		//quit();
	}




//{
}








