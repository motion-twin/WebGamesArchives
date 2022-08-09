import mt.bumdum9.Lib;


typedef PairCard = {>Sprite,card:flash.display.MovieClip,timer:Float,id:Int,flFace:Bool};

class Pair extends Game{//}

	//
	static var POS_LIST = [
		[3,2],
		[4,2],
		[5,2],
		[4,3],
		[4,4],
		[6,3],
	];

	static var CW = 48;
	static var CH = 72;

	// CONSTANTES
	var xMax:Int;
	var yMax:Int;
	var waitTimer:Float;

	// VARIABLES
	var index:Int;
	var winPoints:Int;
	var cList:Array<PairCard>;
	var tc:PairCard;
	var tc2:PairCard;
	var freezeTimer:Null<Float>;

	override function init(dif:Float){

		gameTime = 600 - dif * 200;
		index = Std.int(dif * 0.8 * POS_LIST.length);
		if( index >= POS_LIST.length ) index = POS_LIST.length - 1;
		gameTime += index * 50;
		super.init(dif);
		waitTimer = 80;
		winPoints = 0;
		attachElements();
	}

	function attachElements(){

		bg = dm.attach("pair_bg",0);
		
		var xMax = POS_LIST[index][0];
		var yMax = POS_LIST[index][1];

		var ec = 5;
		var mx = (Cs.mcw-( xMax*CW   + (xMax-1)*ec ))*0.5;
		var my = (Cs.mch-( yMax*CH   + (yMax-1)*ec ))*0.5;

		var max = xMax*yMax;
		var dispo = new Array();
		for( i in 0...max )dispo.push(Math.floor(i/2));

		dispo = shuffle(dispo);

		cList = new Array();
		for( x in 0...xMax ){
			for( y in 0...yMax ){
				var card:PairCard = cast newSprite("mcPairCard");
				card.x = mx + x*(ec+CW);
				card.y = my + y*(ec+CH);
				card.id = dispo.pop();
				card.root.tabIndex = card.id;
				card.timer = 8 + (x + y) * 8;
				card.chrono = true;
				card.flFace=false;
				card.updatePos();
				cList.push(card);
			}
		}



	}

	override function update(){
		switch(step){
			case 1:
				var flNext = true;
				for(card in cList ) {
					if( card.chrono ){
						//Log.prInt(">"+card.id)
						flNext = false;
						card.timer--;
						if( card.timer <= 0 ){
							if(!card.flFace){
								card.timer = waitTimer;
								card.root.gotoAndPlay("face");
								card.flFace = true;
							}else{
								card.chrono = false;
								card.root.gotoAndPlay("back");
								card.flFace = false;
							}
						}
					}else{
						if( card.root.currentFrame > 1 )flNext = false;
					}
				}

				if(flNext){
					for(card in cList )initCardAction(card);
					step = 2;
				}

			case 2:
				if(freezeTimer!=null){
					freezeTimer--;
					if( freezeTimer < 0 ){
						freezeTimer = null;
						tc.root.gotoAndPlay("back");
						tc2.root.gotoAndPlay("back");
						initCardAction(tc);
						initCardAction(tc2);
						tc = null;
						tc2 = null;
					}
				}

				if( Std.int(cList.length*0.5) == winPoints ){
					setWin(true,20);
					step = 3;
				}

			case 3:

		}

		super.update();
	}

	function initCardAction(card:PairCard) {
		var me = this;
		card.f = function(e) { me.turn(card); };
		card.root.addEventListener( flash.events.MouseEvent.CLICK, card.f );
		//card.root.onClick = function() { };
		//card.root.onPress = callback(turn, card);
		
	}

	function turn(card:PairCard){
		if(tc2 != null) return;
		
		card.root.removeEventListener( flash.events.MouseEvent.CLICK, card.f );
		
		card.root.gotoAndPlay("face");
		if(tc==null){
			tc = card;
		}else{
			if( card.id == tc.id ){

				var a = [tc, card];
				for( sp in a ) {
					haxe.Timer.delay( function() {
						var fx = new mt.fx.Flash(sp.root);
						fx.glow(3, 6);
					}, 280 );
				}
				
				winPoints += 1;
				tc = null;
				
			}else{
	
				tc2 = card;
				freezeTimer = 18;
			}
		}
	}


	function shuffle(a:Array<Dynamic>):Dynamic{
		var b = [];
		while(a.length>0){
			var index = Std.random(a.length);
			b.push(a[index]);
			a.splice(index,1);
		}
		return b;
		//for( el in b )a.push(el);
	}

//{
}













