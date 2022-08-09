package inter.pan;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;
import Constructable;

typedef SlotConstruct = {
	>flash.MovieClip,
	rid:Int,
	id:Int,
	n:Int,
	ico:flash.MovieClip,
	bar:flash.MovieClip,
	bar2:flash.MovieClip,
	cost:flash.MovieClip,
	cross:flash.MovieClip,
	bg:flash.MovieClip,
	counter:Counter,
	time:flash.MovieClip,
};

class Yard extends inter.Panel {//}

	static public var ECY = 55;

	var desc:String;
	var totalTime:Float;
	var pl:Planet;
	var first:SlotConstruct;
	var fieldTime:flash.TextField;
	var cslots:Array<SlotConstruct>;

	public function new(pl){
		this.pl = pl;
		super();
		Inter.me.board.setSkin(0,2);
		display();
	}

	override function display(){
		super.display();
		cy+= inter.Board.TAB_LINE;

		var flStack = 		Param.is(PAR_STACK_SHIP);
		var flTotalTime = 	Param.is(PAR_DISPLAY_YARD_TOTAL_TIME);

		// LISTE DES BUILDING ( pour verifier dépendances )
		var bld = new List();
		for( b in pl.bld )if( b._progress == 1)bld.push(b._type);

		if( pl.yard.length == 0){
			genText("Aucun bâtiment en construction, pour constuire un bâtiment sélectionnez un emplacement vide sur l'île.");
		}
		if( !Inter.me.isle.flOwn){
			var field = genText("Attention ! Vous ne possédez pas encore cet îlot, la construction des bâtiments ne sera lancée qu'une fois l'îlot colonisé");
			field.textColor = 0xCC0000;
		}

		if( pl.yard.length == 0)return;


		var hh = height - cy;
		if( flTotalTime )hh -= 18;

		genSlider(hh);
		first = null;

		var a:Array<{con:DataConstruct,n:Int,id:Int}> = [];
		var last:DataConstruct = null;
		var id = 0;

		for( con in pl.yard ){

			var flAdd = false;
			switch(con._type){
				case Ship(type): flAdd = true ;
				default:
			}

			if( flStack && flAdd && Type.enumEq(last._type,con._type) && last._progress == null && con._progress == null && last._counter ==null ){
				a[a.length-1].n++;
			}else{
				a.push({con:con,n:1,id:id});
			}

			last = con;
			id++;
		}

		totalTime = 0.0;
		cslots = [];

		//var rid = 0;
		var eid = 0;
		for( o in a ){

			var mc:SlotConstruct = cast slider.dm.attach( Cs.gil("slotConstruct"),0);
			mc.gotoAndStop(Game.me.raceId+1);
			cslots.push(mc);
			mc._x = 2;
			mc._y = ECY*eid;
			mc.bar._xscale = 0;
			mc.id = eid;
			mc.rid = o.id;

			// TIME
			var sdm = new mt.DepthManager(mc);
			mc.time = sdm.empty(0);
			mc.time._x = 95;
			mc.time._y = 27;
			Filt.glow(mc.time, 2, 4, 0x060606);

			// ACTION
			mc.bg.onPress = callback(dragBox,mc);
			mc.bg.onRelease = callback(releaseBox,mc);
			mc.bg.onReleaseOutside = callback(releaseBox,mc);
			mc.ico.onPress = mc.bg.onPress;
			mc.ico.onRelease = mc.bg.onRelease;
			mc.ico.onReleaseOutside = mc.bg.onReleaseOutside;

			// ICO
			desc = "";
			var timer = 0;
			var blist = new List();
			for( b in pl.bld ) blist.push(b._type);
			var tlist = new List();
			for( t in Game.me.tec ) tlist.push(t);

			var bldLack = [];
			var name = "";
			switch(o.con._type){
				case Building(type) :
					var bat = new mt.DepthManager(mc.ico.smc).attach("mcBuilding",0);
					var id = Type.enumIndex(type);
					bat._x = 38;
					bat._y = 58;
					if(Cs.isBig(type))bat._y += 10;
					bat.gotoAndStop( id+2 );
					//
					name = Lang.BUILDING[id];
					desc = "<b>"+name+"</b><br>";
					//
					var bat = BuildingLogic.get(type);

					var time = bat.getIsleBuildTime( bld, tlist )*GamePlay.getPopulationBuildBonus(pl.pop)*o.n;

					if( o.con._progress!=null ){
						time *= 1-o.con._progress;
						mc.bar._xscale = o.con._progress*100;
					}

					if(first!=null)totalTime += time;
					Cs.genTime(mc.time,time, true, false);

					// COST
					costDesc(bat.cost);

					// AVAILABLE
					bldLack = bat.buildingReqMet(bld);
					bld.push(type);

				case Ship(type) :
					var bat = new mt.DepthManager(mc.ico).attach("mcShipVig",0);
					bat._x = 32;
					var id = Type.enumIndex(type);
					bat.gotoAndStop( id+1 );
					name = Lang.SHIP[id];
					desc = "<b>"+name+"</b>"+(if (o.n>1) " (x"+o.n+")" else "")+"<br>";
					var shp = ShipLogic.get(type);

					var time = shp.getIsleBuildTime(bld,tlist)*GamePlay.getPopulationBuildBonus(pl.pop)*o.n;

					if( o.con._progress!=null ){
						time *= 1-o.con._progress;
						mc.bar._xscale = o.con._progress*100;
					}


					if(first!=null)totalTime += time;
					Cs.genTime(mc.time,time,true, false  );

					// COST
					costDesc(shp.cost);

					// AVAILABLE
					var player = Game.me.getPlayer(Game.me.playerId);
					bldLack = shp.buildingReqMet(bld,Lambda.list(player._tec));

			}
			//
			mc.bar2._visible = o.con._progress!=null || o.con._counter!= null ;
			mc.time._alpha = mc.bar2._visible?100:50;
			//
			if(o.n>1){
				var mmc = sdm.attach("mcConstuctNum",1);
				cast(mmc)._val = Math.min(99, o.n);
				mmc._x = 11;
			}


			// FIRST
			if(first==null){
				first = mc;
				mc.counter = o.con._counter;
				var mcText = sdm.empty(0);
				if(mc.counter==null){

					if( Inter.me.flWaitPlayer ){

						Cs.genText(mcText,Lang.CONSTRUCT_PAUSE,0xFF0000);

					}else{

						Cs.genText(mcText,Lang.CONSTRUCT_NOT_OK,0xFF0000);

						var bl = new List();
						var pl = Inter.me.isle.pl;
						for( bg in pl.bld )bl.push(bg._type);

						//desc+="<br>";

						switch(o.con._type){
							case Building(type):
								var b = BuildingLogic.get( type );
								var a = b.requirementsMet( bl , Lambda.list( Game.me.tec ), pl.getRes(), true );
								desc = addLack(desc,a);

							case Ship(type):
								var sh = ShipLogic.get( type );
								var a = sh.requirementsMet( bl , Lambda.list( Game.me.tec ), pl.getRes() );
								if( sh.cost.population+Game.me.units > Game.me.unitMax )a.push(_LackPopLimit);

								desc = addLack(desc,a);

						}

					}




				}else{
					Cs.genText(mcText,Lang.CONSTRUCT_OK);
				}



				mcText._x = 66;
				mcText._y = 4;
			}


			if( bldLack.length > 0 ){
				desc += "<font color='#CC0000'><b>";
				var flFirst = true;
				for( lack in bldLack ){
					switch(lack){
						case _LackBld(b) :
							if(!flFirst)desc+=", ";
							desc+=Lang.BUILDING[Type.enumIndex(b)];

						case _LackTec(t) :
							if(!flFirst)desc+=", ";
							desc+=Lang.RESEARCH[Type.enumIndex(t)];

						default :
					}
					flFirst = false;
				}
				desc+="</b> ";
				if(bldLack.length==1)	desc += Lang.MUST_BE_BUILD_BEFORE;
				else		desc += Lang.MUST_BE_BUILD_BEFORE2;
				desc+=" <b>"+name+"</b> !</font>";
				Col.setPercentColor(mc.ico,50,0xFF0000);
			}

			// CROSS
			//			Trick.butAction( mc.cross, callback(killConstruct,o.id+o.n-1) );
			Trick.butAction( mc.cross, callback(killConstruct,o.id) );
			var str = "<b>"+Lang.DELETE_YARD_SLOT+"</b>";
			if(mc.bar2._visible)str+="<br/><i>"+Lang.GET_BACK_RESSOURCES+"</i>";
			if( o.n > 1 )str+="<br/><i>"+Lang.SHIFT_DELETE_ALL+"</i>";
			Inter.me.makeHint( mc.cross, str );

			// HINT
			Inter.me.makeHint( mc.ico, desc );

			//
			eid++;

		}

		// TOTAL
		if( flTotalTime ){
			fieldTime = genText( getTimeLeft(totalTime) );
		}

		//
		updateSliderMin();


	}

	function addLack(desc,a:Array<_Lack>){
		for( lack in a ){
			switch(lack){
				case _LackBld(type):
					var str = "- "+Lang.BUILDING[Type.enumIndex(type)]+" "+Lang.NECESSARY+"<br>";
					desc += "<font color='#CC0000'>"+str+"</font>";

				case _LackTec(type):
					var str = "- "+Lang.RESEARCH[Type.enumIndex(type)]+" "+Lang.NECESSARY+"<br>";
					desc += "<font color='#CC0000'>"+str+"</font>";

				case _LackCost(cost):
					var list = [cost._material,cost._cloth,cost._ether,cost._pop];
					var id = 0;
					var str = "";
					for( el in list ){
						if(el>0){

							str += "- "+Lang.YOU_NEED_RESSOURCES+el+" "+Lang.RESSOURCES[id]+"<br>";

						}
						id++;
					}
					if(str.length>0)desc += "<font color='#CC0000'>"+str+"</font>";

				case _LackUnique(type):
					var str = "- "+Lang.ALREADY_BUILT+"<br>";
					desc += "<font color='#CC0000'>"+str+"</font>";

				case _LackPopLimit:
					var str = "- "+Lang.POP_LIMIT+"<br>";
					desc += "<font color='#CC0000'>"+str+"</font>";
			}
		}
		return desc;
	}

	// DRAG
	var dbox:{>flash.MovieClip,bmp:flash.display.BitmapData,dx:Float,dy:Float,sy:Float,sid:Int,cid:Int};
	var dboxLine:flash.MovieClip;
	function dragBox(mc:SlotConstruct){
		Inter.me.flDrag = true;

		// LINE
		dboxLine = dm.attach("mcDropTarget",10);
		Filt.glow(dboxLine,8,1,0xFFFFFF);
		dboxLine.blendMode = "add";

		//
		dbox = cast dm.empty(10);
		dbox.bmp = new flash.display.BitmapData(220,56,true,0);
		var ct = new flash.geom.ColorTransform(1,1,1,0.5,0,0,0,0);
		dbox.bmp.draw(mc,new flash.geom.Matrix(),ct,"layer");
		dbox.startDrag(true);

		var mmc = new mt.DepthManager(dbox).empty(0);
		mmc.attachBitmap(dbox.bmp,0);

		mmc._x = -mc._xmouse;
		mmc._y = -mc._ymouse;
		dbox.sy = root._ymouse;
		dbox.sid = mc.id;
		dbox.cid = mc.id;

		dbox._y = -1000;
		dboxLine._y = -1000;

	}
	function releaseBox(mc:SlotConstruct){
		Inter.me.flDrag = false;
		//
		var id = cslots[dbox.cid].rid;
		if( dbox.cid >=  cslots.length ){
			var sl = cslots[cslots.length-1];
			id = sl.rid + sl.n;
		}

		//trace("Swap "+mc.rid+" --> "+id);
		//trace("dbox.cid "+dbox.cid);

		if(id>mc.rid)id--;

		var me = this;
		Api.swapConstruct(Inter.me.isle.pl.id, mc.rid, id, function(){ Inter.me.isle.maj(); me.display(); });

		// DESTROY
		dbox.bmp.dispose();
		dbox.stopDrag();
		dbox.removeMovieClip();
		dboxLine.removeMovieClip();


	}
	function updateDBox(){
		var dy = Math.ceil((root._ymouse-dbox.sy)/55);
		dbox.cid = dbox.sid + dy;

		if( dbox.cid>cslots.length )dbox.cid = cslots.length;
		dboxLine._y = slider._y + dbox.cid*ECY;


	}


	override function update(){

		super.update();
		updateDBox();
		if( first.counter == null ){

			return;
		}

		var o = Game.me.getCounterInfo(first.counter);
		Cs.genTime(first.time, o.run,true, false  );


		//
		fieldTime.htmlText = getTimeLeft(totalTime+o.run);		
		Game.fixTextField(fieldTime);


		//
		first.time._x  = 140-first.time._width*0.5;
		first.bar._xscale = o.c*100;

		//
	}

	public function getTimeLeft(n){
		if (n > 5000000000.0)
			return "";
		return Lang.END_CONSTRUCT+"<b>"+Cs.getTime(n,true)+"</b>";
	}

	public function killConstruct(id){
		var me = this;
		Api.abortConstruct(pl.id, id, flash.Key.isDown(flash.Key.SHIFT), function(){ Inter.me.isle.maj(); me.display(); });
	}

	function costDesc(cost:Cost){
		for( i in 0...4 ){
			var n = [cost.material,cost.cloth,cost.ether,cost.population][i];
			if(n>0) desc += Lang.RESSOURCES[i]+ " : <b>"+n+"</b><br/>";
		}
	}
//{
}