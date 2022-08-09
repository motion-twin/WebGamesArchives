import mt.bumdum9.Lib;

typedef SSnail = {>Phys,crunch:Float,trg:Array<{x:Float,y:Float}>,path:Float};

class Snail extends Game{//}



	var leafSize:Float;
	var size:Float;
	var speed:Float;

	var crunch:flash.display.MovieClip;
	var snails:Array<SSnail>;
	var selection:SSnail;
	var leaf:{>flash.display.MovieClip,bmp:flash.display.BitmapData};

	//var plasma:mt.bumdum.Plasma;



	override function init(dif:Float){
		gameTime =  600-100*dif;
		super.init(dif);
		leafSize = Math.min(0.4+dif*0.45,0.9);
		size = 40;
		speed = 1.2;
		attachElements();

	}

	function attachElements(){
		bg = dm.attach("snail_bg",0);

		// LEAF
		leaf = cast dm.empty(0);
		leaf.bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0);
		var mc = dm.attach("snail_leaf",0);
		var m = new flash.geom.Matrix();
		m.scale(leafSize,leafSize);
		m.translate(Cs.mcw*0.5,Cs.mch*0.5);
		leaf.bmp.draw(mc,m);
		leaf.attachBitmap(leaf.bmp,0);
		mc.removeMovieClip();
		Filt.glow(leaf,2,2,0x267604);
		var fl = new flash.filters.DropShadowFilter();
		fl.color = 0;
		fl.strength = 0.2;
		fl.distance = 2;
		var a = leaf.filters;
		a.push(fl);
		leaf.filters = a;


		// SNAILS
		snails = new Array();
		var ma = 20;
		var max = 5;
		var ray = 170;
		for( i in 0...max ){
			var a = i/5*6.28;
			var sp:SSnail = cast new Phys(dm.attach("snail_snail",1));
			sp.x = Cs.mcw*0.5 + Math.cos(a)*ray - 12;
			sp.y = Cs.mch*0.5 + Math.sin(a)*ray;
			sp.crunch = 0;
			sp.setScale(size);
			sp.trg = [];

			snails.push(sp);
			sp.root.onPress = callback(select,sp);

		}

		// CRUNCH
		crunch = dm.attach("snail_crunch",0);
		crunch.visible = false;

		// PLASMA
		/*
		plasma = new mt.bumdum.Plasma( dm.empty(1), Cs.mcw, Cs.mch );
		plasma.ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-2);
		plasma.root.blendMode = flash.display.blendMode.ADD;
		Filt.glow(plasma.root, 10, 0., 0xFFFFFF);
		*/



	}

	//
	override function update(){
		updateSnails();
		updateSelection();
		checkEnd();
			plasma.update();
		super.update();
	}

	// SNAILS
	var top:flash.display.MovieClip;
	function updateSnails(){

		var f = function(a:SSnail,b:SSnail){
			if(a.y<b.y)return-1;
			return 1;
		}
		snails.sort(f);

		for( sp in snails ){



			// TRG
			if( sp == selection ) {
				var mp = getMousePos();
				var x = mp.x;
				var y = mp.y;
				var last = sp.trg[sp.trg.length-1];
				var dx =  last.x - x;
				var dy =  last.y - y;
				var dist = Math.sqrt(dx*dx+dy*dy);
				if( dist>10 ){

					if( top== null )top = dm.attach("snail_arrow_top",1);

					var mc2 = dm.attach("snail_point",0);
					mc2.x = x;
					mc2.y = y;
					var mc = dm.attach("snail_arrow",0);
					mc.x = x;
					mc.y = y;
					mc.rotation = Math.atan2(dy,dx)/0.0174;
					mc.scaleX = dist;
					plasma.drawMc(mc);
					plasma.drawMc(mc2);


					top.x = x;
					top.y = y;
					top.rotation = mc.rotation+180;

					mc.removeMovieClip();
					mc2.removeMovieClip();

					//
					sp.trg.push({x:x,y:y});
					sp.path -= dist;
					if( sp.path <= 0)endPath(sp);
				}


			}else{
				if( sp.trg.length>0 ){
					sp.root.play();
					var first = sp.trg[0];
					var dx = first.x - sp.x;
					var dy = first.y - sp.y;
					//trace(first.x + " : " + first.y);
					var a = Math.atan2(dy,dx);
					var dr = a/0.0174 - sp.root.rotation;
					var lim = 20;
					sp.root.rotation += Num.mm(-lim,Num.hMod(dr,180)*0.2,lim);


					sp.vx = Math.cos(a)*speed;
					sp.vy = Math.sin(a)*speed;
					if( Math.sqrt(dx*dx+dy*dy)< 5 ){
						sp.trg.shift();
					}

				}else{
					sp.vx = 0;
					sp.vy = 0;
					sp.root.stop();
				}



			}



			// CRUNCH
			if( sp.crunch--<0 ){
				sp.crunch = size*0.4;
				var sc = size*0.01*(0.7+Math.random()*0.5);
				var m = new flash.geom.Matrix();
				m.rotate(Math.random()*6.28);
				m.scale(sc,sc);
				m.translate(sp.x,sp.y);
				leaf.bmp.draw(crunch,m,null,"erase");

			}



			// DEPTH
			dm.over(sp.root);

		}


	}
	override function click(){
		endPath(selection);
	}

	function endPath(sp:SSnail){
		//plasma.drawMc(top);
		top.parent.removeChild(top);
		top = null;
		deselect();
	}


	// SELECTION
	function deselect(){
		selection.root.filters  =[];
		selection = null;
	}
	function select(sp:SSnail){
		deselect();
		selection = sp;
		selection.trg = [{x:sp.x,y:sp.y}] ;
		selection.vx = 0;
		selection.vy = 0;
		selection.path = 300;
	}
	function updateSelection(){
		var sp = selection;

		// GLOW
		var c = 0.5+Math.cos(udec*6.28)*0.5;
		sp.root.filters = [];
		Filt.glow(sp.root,2,2+c*2,0xFFFFFF);
		Filt.glow(sp.root,c*10,c,0xFFFFFF);


	}

	// END
	function checkEnd(){
		var ma = 20;
		for( i in 0...120 ){
			var x = ma+Math.random()*Cs.mcw;
			var y = ma+Math.random()*Cs.mch;
			if( isLeaf(x,y) )return;
		}
		setWin(true);
	}


	function isLeaf(x:Float,y:Float){
		var col = Col.colToObj32( leaf.bmp.getPixel32(Std.int(x),Std.int(y)) );
		return  col.a == 255;

	}


	override function kill(){
		leaf.bmp.dispose();
		super.kill();
	}



//{
}

