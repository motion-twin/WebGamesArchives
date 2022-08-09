package inter.pan;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;


typedef SlotWar = {
	>flash.MovieClip,
	fieldTitle:flash.TextField,
	fieldDesc:flash.TextField,
	fieldDate:flash.TextField,
	top:flash.MovieClip,
	bande:flash.MovieClip,
	mid:flash.MovieClip,
	bot:flash.MovieClip,
};

class War extends inter.Panel {//}

	var pl:Planet;
	var first:SlotWar;

	public function new(pl){
		this.pl = pl;
		super();

		Inter.me.board.setSkin(0,0);
		display();
	}

	override function display(){
		super.display();

		//if(Inter.me.isle.pl.owner==Game.me.playerId)	cy += inter.Board.TAB_LINE;
		if( Inter.me.isle.flConstruct )			cy += inter.Board.TAB_LINE;
		else						cy += 62;



		genSlider(height-cy);

		var y = 0;
		first = null;
		var id = 0;
		var a = [];
		for( news in pl.news )a.unshift(news);

		for( news in a ){

			var mc:SlotWar = cast slider.dm.attach("slotAttack",0);
			mc.gotoAndStop(Game.me.raceId+1);
			var sdm = new mt.DepthManager(mc);
			mc._x = 12;
			mc._y = y;

			var desc = "";
			var bh = 27;

					// DATE
					var date = Date.fromTime(news._date);
					//mc.fieldDate.text = DateTools.format(date,"%H:%M - %d/%m");
					mc.fieldDate.text = DateTools.format(date,"%H:%M [%d]");

			switch(news._type){

				case _Archimortar(atk):
					setTitleColor( mc, atk._from );
					var playerName = Game.me.getPlayerName(atk._from);
					var ownerName = Game.me.getPlayerName(atk._to);
					var isleName = Game.me.getPlayerName(Inter.me.isle.pl.id);
					mc.fieldTitle.text = playerName+" attaque !";
					if( atk._damageBld>0 || atk._casualtyPop>0 ){
						desc += "<font color='#ACAE95'>Archimortier</font><br>";
						if( atk._damageTwr != null && atk._damageTwr > 0) desc += Lang.rep(Lang.ATTACK_TOWER, atk._damageTwr);
						if( atk._damageBld>0 )desc+= Lang.rep(Lang.ATTACK_BUILDING, atk._damageBld );
						if( atk._casualtyBld.length>0 )		desc+= Lang.rep(Lang.ATTACK_CASUALTY, ownerName, getCasualty(cast atk._casualtyBld,Lang.BUILDING) );
						if( atk._casualtyPop>0 )		desc+= Lang.rep(Lang.ATTACK_CASUALTY_POP, ownerName, atk._casualtyPop, atk._casualtyPop>1?"s":"" );
					}


				case _Attack(atk):
					setTitleColor(  mc, atk._from  );

					var playerName = Game.me.getPlayerName(atk._from);
					var ownerName = Game.me.getPlayerName(atk._to);
					var isleName = Game.me.getPlanetName(Inter.me.isle.pl.id);

					mc.fieldTitle.text = playerName+" attaque !";

					// DESC
					if( atk._damageAtt>0 || atk._damageDef>0 || atk._casualtyDef.length>0 || atk._casualtyAtt.length>0 ){
						desc += "<font color='#ACAE95'>phase aerienne</font><br>";
						if( atk._damageAtt>0 )			desc+= Lang.rep(Lang.ATTACK_DAMAGE, playerName, atk._damageAtt );
						if( atk._damageDef>0 )			desc+= Lang.rep(Lang.ATTACK_DAMAGE, ownerName, atk._damageDef );
						if( atk._casualtyDef.length>0 )		desc+= Lang.rep(Lang.ATTACK_CASUALTY, ownerName, getCasualty(atk._casualtyDef,Lang.SHIP) );
						if( atk._casualtyAtt.length>0 )		desc+= Lang.rep(Lang.ATTACK_CASUALTY, playerName, getCasualty(atk._casualtyAtt,Lang.SHIP) );
					}

					if( atk._damageBld > 0 || atk._casualtyPop > 0 || atk._damageTwr > 0){
						desc += "<font color='#ACAE95'>phase terrestre</font><br>";
						if (atk._damageTwr > 0) desc += Lang.rep(Lang.ATTACK_TOWER, atk._damageTwr);
						if (atk._damageBld > 0) desc += Lang.rep(Lang.ATTACK_BUILDING, atk._damageBld);
						if (atk._casualtyBld.length > 0) desc += Lang.rep(Lang.ATTACK_CASUALTY, ownerName, getCasualty(cast atk._casualtyBld,Lang.BUILDING));
						if (atk._casualtyPop > 0 && atk._damagePop > 0) desc += Lang.rep(Lang.ATTACK_CASUALTY_POP2, ownerName, atk._casualtyPop, atk._casualtyPop>1?"s":"", atk._damagePop);
						else if( atk._casualtyPop>0) desc += Lang.rep(Lang.ATTACK_CASUALTY_POP, ownerName, atk._casualtyPop, atk._casualtyPop>1?"s":"" );
					}
					mc.onPress = callback(Inter.me.isle.askFight,atk._fightId);

				case _Colonize(pid):
					setTitleColor(  mc, pid  );
					mc.fieldTitle.text = "Colonisation";
					desc += Lang.rep( Lang.COLONIZE, Game.me.getPlayerName(pid) );

				case _Defeat(pid):
					setTitleColor(  mc, pid  );
					mc.fieldTitle.text = "Défaite";
					desc += Lang.rep( Lang.DEFEAT, Game.me.getPlayerName(pid) );

				case _Trace(txt):
					desc += txt;

				case _Starvation:
					mc.fieldTitle.text = "Famine";
					desc += "Un habitant est mort de faim.";

				case _NewShip(k):
					//setTitleColor(  mc, Inter.me.isle.pl.owner  );
					mc.fieldTitle.text = "Vaisseau terminé";
					desc += Lang.getShipInfo(k).name+" est prêt.";

				case _NewBuilding(k):
					//setTitleColor(  mc, Inter.me.isle.pl.owner  );
					mc.fieldTitle.text = "Bâtiment terminé";
					desc += "Le bâtiment "+Lang.getBuildingInfo(k).name+" est opérationnel.";
			}
			if (desc == "")
				desc = Lang.NOTHING_HAPPEN;
			mc.fieldDesc.htmlText = desc;
			Game.fixTextField(mc.fieldTitle);
			Game.fixTextField(mc.fieldDesc);
			mc.fieldDesc._height = mc.fieldDesc.textHeight+4;
			var hh = Std.int(mc.fieldDesc._height+bh);
			// BORDER
			mc.mid._yscale = hh-28;
			mc.bot._y = hh-14;



			y += hh+2;
			id++;
		}

		updateSliderMin();

	}

	function setTitleColor(mc:SlotWar, pid){

		var color = Cs.COLORS[ Game.me.getPlayer(pid)._color ];
		Col.setColor(mc.bande,color);

		mc.fieldTitle.textColor = color;


	}

	function getCasualty(a:Array<_Shp>,names:Array<String>){
		var str="";
		var scores = [];
		for( shp in a ){
			var id = Type.enumIndex(shp);
			if( scores[id] == null )scores[id] = 0;
			scores[id]++;
		}

		var id = 0;
		for( n in scores ){
			if( n != null ){
				if(str.length>0)str+=", ";
				str += n+"x"+names[id];
			}
			id++;
		}
		return str;

	}

	override function update(){

		super.update();



	}






//{
}















