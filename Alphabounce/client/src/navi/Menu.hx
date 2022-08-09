package navi;
import mt.bumdum.Lib;


class Menu{//}

	public static var MARGIN = 10;

	var step:Int;
	var sens:Int;
	var coef:Float;
	var fieldLog:flash.TextField;
	var fieldLog2:flash.TextField;
	var root:flash.MovieClip;
	var map:navi.Map;
	//var mcIcon:flash.MovieClip;
	var mcDraw:flash.MovieClip;

	var icx:Float;
	var icy:Float;
	var dm:mt.DepthManager;

	var bs:mt.OldRandom;


	public function new(x,y,?baseSeed){
		map = navi.Map.me;
		icx = x;
		icy = y;
		bs = baseSeed;
		//this.mcIcon = mcIcon;

		root = map.dm.empty(navi.Map.DP_INTER);
		dm = new mt.DepthManager(root);



		initSquare(0);

		map.game.switchView(false);
		map.switchView(false);



	}
	function init(){
		step = 1;
		mcDraw.removeMovieClip();
	}

	public function updateMenu(){

		switch(step){
			case 0:	updateSquare();
			case 1: update();
		}

	}
	public function update(){

	}

	// HINTS
	function setHint(mc:flash.MovieClip,str){

		mc.onRollOver = callback(displayHint,str);
		mc.onRollOut = removeHint;
		mc.onDragOver = mc.onRollOver;
		mc.onDragOut = mc.onRollOut;

	}
	function displayHint(str){
		fieldLog.text = str;
	}
	function removeHint(){
		fieldLog.text = "";
	}

	// SQUARE
	function initSquare(c){
		step = 0;
		sens = -(c*2-1);
		coef = c;
		mcDraw = dm.empty(0);
	}
	function updateSquare(){
		coef = Num.mm(0,coef+0.07*sens*mt.Timer.tmod, 1);

		mcDraw.clear();
		mcDraw.lineStyle(1,0xFFFFFF,100);

		var sx = icx+16;
		var sy = icy+16;
		var sr = 16;

		var ex = Cs.mcw*0.5;
		var ey = Cs.mch*0.5;
		var er = Cs.mcw*0.5-MARGIN;

		var x = sx*(1-coef) + ex*coef;
		var y = sy*(1-coef) + ey*coef;

		var c = Math.pow(coef,3);
		var r = sr*(1-c) + er*c;

		var rx = r;
		var ry = r*Cs.mch/Cs.mcw;

		mcDraw.moveTo( x-rx, y-ry );
		mcDraw.lineTo( x+rx, y-ry );
		mcDraw.lineTo( x+rx, y+ry );
		mcDraw.lineTo( x-rx, y+ry );
		mcDraw.lineTo( x-rx, y-ry );


		/*
		mcDraw.lineStyle(1,0xFFFFFF,50);
		mcDraw.moveTo( 0,  0 );
		mcDraw.lineTo( x-rx, y-ry );

		mcDraw.moveTo( Cs.mcw,  0 );
		mcDraw.lineTo( x+rx, y-ry );

		mcDraw.moveTo( Cs.mcw,  Cs.mch );
		mcDraw.lineTo( x+rx, y+ry );

		mcDraw.moveTo( 0,  Cs.mch);
		mcDraw.lineTo( x-rx, y+ry );
		*/


		//mcDraw.endFill();


		if(coef==1)init();
		if(coef==0)kill();


	}

	function kill(){
		map.menu = null;
		root.removeMovieClip();
		map.switchView(true);
		map.game.switchView(true);
	}

	// ACTION
	function quit(){
		dm.destroy();
		initSquare(1);
	}






//{
}
