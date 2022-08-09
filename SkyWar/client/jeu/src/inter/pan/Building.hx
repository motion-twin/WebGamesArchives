package inter.pan;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;


class Building extends inter.Panel {//}

	var pic:flash.MovieClip;
	var id:Int;
	var x:Int;
	var y:Int;
	//var yid:Int;
	var counter:Counter;
	var flYard:Bool;
	var bt:_Bld;

	public function new(bld,px,py,?count){
		bt = bld;
		id = Type.enumIndex(bt);
		x = px;
		y = py;
		counter = count;

		super();
		//root.gotoAndStop(2);
		Inter.me.attachBackBut();
		Inter.me.board.setSkin(2);
		display();

	}

	override function display(){
		super.display();


		// IMAGE
		//var pic = dm.attach("mcBatArtwork",1);
		//pic._y = this.cy;
		cy += 244;

		var url = Game.me.data._urlImg+"/img"+id+".jpg";
		Inter.me.board.loadImage(url);


		// TEXT
		var str = "<font size='20'><p align='center'><b>"+Lang.BUILDING[id]+"</b></p></font><font size='10'></font>";
		str += "<b><p align='center'>"+Lang.IGH_BUILDING[id]+"</p></b>";
		str += "<i><p>"+Lang.FLAVOUR_BUILDING[id]+"</p></i>";

		//str += Lang.FLAVOUR_BUILDING[id]+"</br>";
		//if( yid==0 )	str += "<br><font color='#FF0000'>Ce batiment est en cours de construction ("+Std.int(Game.me.getCounterInfo(counter).c*100)+"%)</font>";
		//str += "<br><font color='#FF0000'>Ce batiment n'est pas encore construit</font>";
		var field = genText(str,true);
		switch(Game.me.raceId){
			case 0:
			case 1:
				field._x += 4;
				field._y += 10;
				cy += 10;

		}

		// SUPPRIME
		if( bt!=TOWNHALL )genButton(Lang.DESTROY.toUpperCase(),delete);


	}

	override function remove(){
		super.remove();
		Inter.me.isle.initDalleBuildActions();
		Inter.me.mcBackBut.removeMovieClip();
		Inter.me.isle.loadDefaultPanel();
	}

	function delete(){
		var pl = Inter.me.isle.pl;
		Api.destroyBuilding(pl.id, x, y, bt, Inter.me.isle.maj);
		remove();
	}

//{
}

















