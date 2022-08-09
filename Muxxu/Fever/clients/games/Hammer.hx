import Protocole;

typedef Bad = {hole:flash.display.MovieClip,t:Null<Float>,frame:Int};

class Hammer extends Game{//}

	// CONSTANTES
	var cSpeed:Float;

	// VARIABLES
	var flReady:Bool;
	var bList:Array<Bad>;
	var hList:Array<flash.display.MovieClip>;
	var clicked : Int;
	var blastTimer:Null<Int>;
	// MOVIECLIPS
	var hammer:Sprite;

	override function init(dif){
		gameTime = 320;
		super.init(dif);
		clicked = 0;
		cSpeed = 0.3;
		flReady = true;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("hammer_bg",0);
		Reflect.setField(bg,"_obj",this);

		// HOLE
		hList = [];
		for( i in 0...18 ){
			var mc:flash.display.MovieClip = Reflect.field(bg,"$t"+i);
			//var mc:flash.display.MovieClip = getMc(bg, "$t" + i);
			
			getMc(mc, "h").visible = false;
			
			var b = getMc(mc, "b");
			var me = this;
			b.visible = false;
			b.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.catchBad(b);} );
			
			hList.push(mc);
		}

		// BADS
		bList = [];
		var max = 1 + Std.int(dif*8);
		for( i in 0...max ){
			var b:Bad = {hole:null,t:null,frame:Std.random(8)+1};
			findHole(b);
			bList.push(b);
			
		}

		// HAMMER
		hammer = newSprite("mcHammer");
		hammer.x = Cs.mcw*0.5;
		hammer.y = Cs.mch*0.5;
		hammer.updatePos();


	}

	override function update(){
		
		switch(step){
			case 1:
				if(flReady) {
					var mp = getMousePos();
					hammer.toward({x:mp.x,y:mp.y},0.5,null);
				}


				// BADS
				for( b in bList ) {
					if( b.hole == null ) continue;
					var bad:flash.display.MovieClip = cast(b.hole).b;
					if( bad!=null && b.t!=null ){
						if( bad.y > 0 ){
							bad.y *= cSpeed;
							if( bad.y < 1 ) bad.y = 0 ;
						}else{
							if( b.t > 0 ){
								b.t--;
							}else{
								b.t = null;
								bad.mouseEnabled = false;
							}
						}
					}else{
						bad.y += (20+dif*20);
						if( bad.y > 100 ){
							freeHole(b);
							findHole(b);
						}
					}
				}

		}
		//
		if( blastTimer != null && blastTimer-- < 0) {
			blastTimer = null;
			readyToBlast();
		}
		super.update();
	}

	function findHole(b:Bad){

		var n = Std.random(hList.length);
		var hole = hList[n];
		hList.splice(n,1);
		var bad:flash.display.MovieClip  =cast(hole).b;
		bad.visible = true;
		bad.y = 100;
		bad.gotoAndStop(b.frame);

		var me = this;
		bad.mouseEnabled = true;
		//bad.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.catchBad(b);} );
		//bad.onPress = callback(catchBad,b);


		b.hole = hole;
		b.t = Std.random( Math.round(15+(80*(1-dif))) );



	}

	override function onClick() {
		clicked++;
	}

	function freeHole(b:Bad){
		var bad  = getMc(b.hole,"b");
		bad.visible = false;
		hList.push(b.hole);
		bad.mouseEnabled = false;
		b.hole = null;
		

	}

	function catchBad(bmc:flash.display.MovieClip) {
	
		var b:Bad = null;
		for( bb in bList ) {
			if( bb.hole != null && getMc(bb.hole, "b") == bmc ) {
				b = bb;
				break;
			}
		}
		/*
		if( b.hole == null ) {
			return;
		}*/
		
		if(flReady){
			// HAMMER
			flReady = false;
			hammer.x = b.hole.x;
			hammer.y = b.hole.y;
			hammer.root.visible = false;
				
			getMc(b.hole,"h").gotoAndPlay("2");
			getMc(b.hole,"h").visible = true;

			//

			var bad = cast(b.hole).b;
			freeHole(b);

			//if( clicked != bList.length )
			bList.remove(b);
			if(bList.length == 0){
				setWin(true,10);
			}
			
			blastTimer = 8;
		}


	}

	function readyToBlast() {
		if( win != null ) return;
		flReady = true;
		hammer.root.visible = true;
		hammer.root.gotoAndPlay("2");
	}


//{
}






