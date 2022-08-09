
typedef TaquinSlot = { id:Int, x:Int, y:Int, mc:Sprite };
class Taquin extends Game{//}

	// CONSTANTES
	var cx:Float;
	var cy:Float;
	var ec:Float;
	var size:Int;

	// VARIABLES
	var side:Int;
	var sList:Array< TaquinSlot >;
	var free:{x:Int,y:Int};

	override function init(dif:Float){
		gameTime = 600-dif*100;
		super.init(dif);

		size = 320;
		side = 3;
		if(dif>1)side++;

		free={x:0,y:0};

		attachElements();
		shuffle();
		for( mc in sList ) mc.mc.updatePos();

	}

	function attachElements(){

		bg = dm.attach("taquin_bg",0);
		cx = (Cs.mcw-size)*0.5;
		cy = (Cs.mch-size)*0.5;

		// CADRE
		var c = dm.attach("mcTaquinCadre",Game.DP_SPRITE);
		c.x = cx;
		c.y = cy;
		c.gotoAndStop(1);

		// SLOTS
		sList = new Array();
		ec  = size/side;
		var id = 0;
		var picFrame = Std.random(3)+1;
		for( x in 0...side ){
			for( y in 0...side ){
				if( free.x != x || free.y != y ){
					var mc = newSprite("mcTaquinSlot");
					mc.x = cx + x*ec;
					mc.y = cy + y*ec;
					mc.root.scaleX = ec*0.01;
					mc.root.scaleY = ec*0.01;
					mc.updatePos();
					var pic  = new mt.DepthManager(cast(mc.root).s).attach("mcTaquinPicture",0); // id
					var c = (100/ec);
					pic.gotoAndStop(picFrame);
					pic.scaleX = c;
					pic.scaleY = c;
					pic.x = -x*ec*c;
					pic.y = -y*ec*c;
					var o:TaquinSlot = { mc:mc, x:x, y:y, id:id };
					sList.push(o);
					initSelect(mc,o);
				}
				id++;
			}
		}

		// CADRE
		var c = dm.attach("mcTaquinCadre",Game.DP_SPRITE+1);
		c.x = cx;
		c.y = cy;
		c.gotoAndStop(2);



		//c.scaleX = size;
		//c.scaleY = size;

	}

	function shuffle(){
		var max = Std.int(2+(dif*30));
		var i = 0;
		while( i<max ){
			var o = sList[Std.random(sList.length)];
			var d = Math.abs(free.x-o.x)+Math.abs(free.y-o.y);
			if( d == 1 ){
				swap(o);
				i++;
			}
		}
		if( checkWin() ){
			shuffle();
			return;
		}

		for( o in sList ){
			o.mc.x = cx + o.x*ec;
			o.mc.y = cy + o.y*ec;
		}

	}

	function initSelect(mc:Sprite, o) {
		var me = this;
		mc.root.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.select(o); } );
		//mc.root.onPress = callback(select,o);
	}

	override function update(){
		switch(step){
			case 1:
				var f = function(a:TaquinSlot,b:TaquinSlot){
					if( a.mc.y < b.mc.y )return -1;
					return 1;
				}
				sList.sort( f);
				for( o in sList ){
					var pos = {
						x:cx + o.x*ec,
						y:cy + o.y*ec
					}
					o.mc.toward(pos,0.5,null);
					dm.over(o.mc.root);
				}




		}
		//
		super.update();
	}

	function select(o:TaquinSlot){
		if ( Math.abs(free.x-o.x)+Math.abs(free.y-o.y) == 1 ){
			swap(o);
			if(free.x == 0 && free.y == 0 && checkWin() ) {
				for( o in sList ) {
					o.mc.root.mouseEnabled = false;
					o.mc.root.mouseChildren = false;
					new mt.fx.Flash(o.mc.root, 0.1);
					
					var ec = 150;
					for( i in 0...3 ) {
						var c = 0.1+Math.random()*0.4;
						var p = newPhys("pixiz_twinkle");
						p.x = 200 + (Math.random()*2-1)*ec;
						p.y = 200 + (Math.random() * 2 - 1) * ec;
						p.vx = 0;
						p.vy = 0;
						p.root.gotoAndPlay(Std.random(10)+1);
						p.weight = 0.05+Math.random()*0.1;
						p.timer = 16 + Std.random(10);
						p.setScale(0.3 + Math.random() * 2);
						p.updatePos();
						dm.add(p.root, Game.DP_PART);
					}
					
				}
				setWin(true,20);
			}
		}


	}

	function swap(o:TaquinSlot){
		var x = o.x;
		var y = o.y;
		o.x = free.x;
		o.y = free.y;
		free.x = x;
		free.y = y;
	}

	function checkWin(){
		for( o in sList ){
			if( o.id != Math.round(o.y + o.x*side) ){
				return false;
			}
		}
		return true;

	}




//{
}

