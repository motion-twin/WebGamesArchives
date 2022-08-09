class Gobelet extends Game{//}

	static var NSC = 1.6;

	// VARIABLES
	var flSoluce:Bool;
	var swap:Int;
	var pos:Int;
	var gobMax:Int;
	var gobSize:Float;
	var timer:Float;
	var speed:Float;
	var decal:Float;
	var gobList:Array< { mc:flash.display.MovieClip, shade:flash.display.MovieClip, t:Float, x:Float } >;
	var swapList:Array< { list:Array<Int>, x:Float, d:Float } >;
	var upList:Array<flash.display.MovieClip>;

	// MOVIECLIPS
	var token:flash.display.MovieClip;


	override function init(dif){
		gameTime = 220;
		super.init(dif);
		timer = 20;
		speed = 0.2+dif*0.3;
		gobMax = 4 + Math.round(dif*2);
		gobSize = 30*NSC;
		flSoluce = false;
		pos = Std.random(gobMax);
		attachElements();


	}

	function attachElements(){

		//
		bg = dm.attach("gobelet_bg",0);
		var base = Cs.mch-30;
		var ec = (Cs.mcw - gobMax*gobSize)/(gobMax+1);

		gobList =[];
		for( i in 0...gobMax ){
			var x = ec+gobSize*0.5+i*(ec+gobSize);
			// SHADE
			var shade  = dm.attach( "mcGobShadow", Game.DP_SPRITE);
			shade.scaleX = gobSize*0.01;
			shade.scaleY = gobSize*0.01;
			shade.x = x;
			shade.y = base;

			// TOKEN
			if( pos == i ){
				token = dm.attach( "mcGobToken", Game.DP_SPRITE);
				token.x = x;
				token.y = base;
				token.scaleX = gobSize*0.01;
				token.scaleY = gobSize*0.01;
			}

			// MC
			var mc  = dm.attach( "mcGobelet", Game.DP_SPRITE);
			mc.scaleX = gobSize*0.01;
			mc.scaleY = gobSize*0.01;
			mc.x = x;
			mc.y = Cs.mch*0.5;
			gobList.push( { mc:mc, t:4.0*i, shade:shade, x:x } );
		}
	}

	override function update(){
		switch(step){
			case 1:
				if( timer<0 ){
					step = 2;
				}else{
					timer--;
				}
			case 2:
				var base = Cs.mch-30;
				var flNext = true;
				for( gob in gobList ){
						if( gob.t < 0 ){
							var mc = gob.mc;
							var d = base - mc.y;
							mc.y += Math.min(d*0.2,10);
						if( Math.abs(d) < 0.5 ){
							mc.y = base;
						}else{
							flNext = false;
						}
					}else{
						gob.t --;
						flNext = false;
					}
				}
				if(flNext){
					swap = 4+Math.round(dif*10);
					for( gob in gobList ) 	gob.shade.parent.removeChild(gob.shade);
					token.parent.removeChild(token);
					launchSwap();

				}

			case 3:
				decal = Math.min( decal + speed, 3.14 );

				var base = Cs.mch-30;
				for( s in swapList ){
					for( g in 0...2 ){
						var n = s.list[g];
						var mc = gobList[n].mc;
						var sens = (g*2-1);
						mc.x = s.x + Math.cos(decal)*s.d*sens;
						mc.y = base + Math.sin(decal*sens)*(4+Math.abs(s.d)*0.25);
					}
				}
				if(decal==3.14)launchSwap();
			case 4:
				for( mc in upList ){
					var d = Cs.mch*0.75 - mc.y;
					mc.y += Math.min(d*0.2,10);
				}
				if(win ==false && endTimer<16 && upList.length<2 && !flSoluce ){

					select(pos);
					flSoluce = true;
				}

		}

		super.update();
	}

	function initSelectStep(){
		step = 4;
		upList = [];
		for( i in 0...gobList.length ){
			var me = this;
			gobList[i].mc.addEventListener( flash.events.MouseEvent.CLICK, function(e) { me.select(i); } );
		}

	}

	function select(id){
		var mc = gobList[id].mc;

		// SHADE
		var shade  = dm.attach( "mcGobShadow", Game.DP_SPRITE);
		shade.scaleX = gobSize*0.01;
		shade.scaleY = gobSize*0.01;
		shade.x = mc.x;
		shade.y = mc.y;


		// TOKEN
		if(id==pos){
			genToken(mc.x,mc.y);
			setWin(true,20);
		}else{
			setWin(false,20);
		}

		//
		dm.over(mc);
		upList.push(mc);

		// CLEAN
		for( gob in gobList ){
			 gob.mc.mouseEnabled = false;
		}

	}

	function genToken(x,y){
		token = dm.attach( "mcGobToken", Game.DP_SPRITE);
		token.x = x;
		token.y = y;
		token.scaleX = gobSize*0.01;
		token.scaleY = gobSize*0.01;
	}

	function launchSwap(){

		swap--;
		if( swap == 0 ){
			initSelectStep();
			return;
		}

		step = 3;
		decal = 0;
		swapList = [];
		var max = 1;
		if( Std.random(Math.round(dif*100)) > 20 )max++;
		var list = [];
		for( i in 0...gobList.length )list.push(i);

		for( i in 0...max ){
			var p:Array<Int> = [];
			for( g in 0...2){
				var index = Std.random(list.length);
				var n = list[index];
				list.splice(index,1);
				p.push(n);
			}
			var gob0 = gobList[p[0]];
			var gob1 = gobList[p[1]];

			var d = (gob0.x - gob1.x)*0.5;
			var x = (gob0.x + gob1.x)*0.5;

			swapList.push( {list:p,x:x,d:d} );

			for( g in gobList ) if( g != gob1) dm.over(g.mc);
			dm.over(gob0.mc);

			// OBJ SWAP
			var trans = gob0.mc;
			gob0.mc = gob1.mc;
			gob1.mc = trans;

			if(pos == p[0] ){
				pos = p[1];
			}else	if(pos == p[1] ){
				pos = p[0];
			}
		}




	}



//{
}




