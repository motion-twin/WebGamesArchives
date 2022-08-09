/*
	gfx perso
	anim flotte
	anim réussite
	anim fin
*/

typedef SectionM = {>flash.display.MovieClip, px : Float};
typedef TrainM = {>flash.display.MovieClip,  up : Bool, dist : Float, sector : Int, rad : Float};

class Train extends Game{//}


	var rail1 : flash.display.MovieClip;
	var rail2 : flash.display.MovieClip;
	var rail3 : flash.display.MovieClip;
	var replace : SectionM;
	var trains  : Array<TrainM>;
	var timer : Float;
	var speed : Float;
	var rad : Float;
	var won : Bool;

	static var M1 = 70.0;
	static var M2 = 200.0;
	static var M3 = 330.0;
	static var Y = 150;
	static var BASE = 30;
	static var UP = 420;
	static var DOWN = 0;
	static var ATIMER = 4.0;
	static var BASE_SPEED = 3.0;


	override function init(dif){
		gameTime = 400;
		super.init(dif);
		trains = new Array( );
		attachElements();
		timer = 10;

		step = 1;
		speed = BASE_SPEED  + dif * 10;
		rad = 0.0;
	}

	function attachElements(){
		bg = dm.attach("mcTrainBg",0);
		rail1 = dm.attach("mcTrainRail",1);
		rail1.x = 70;
		rail2 = dm.attach("mcTrainRail",1);
		rail2.x = 200;
		rail3 = dm.attach("mcTrainRail",1);
		rail3.x = 330;
		replace = cast dm.attach("mcTrainSection",2);
		replace.x = replace.x = M2;
		replace.y = Y;
	}

	override function update(){
		rad += 3;

		switch(step){
			case 1:

				moveSection();
				for( t in trains ){
					hit(t);
					t.scaleX = 1 + Math.sin( ( rad + t.rad)  * Math.PI / 180 ) * 0.05;
					if( t.up ) {
						t.y -= speed;
						if( t.y + t.height < DOWN ) {
							trains.remove(t);
							t.parent.removeChild(t);
						}
					} else {
						t.y += speed;

						if( t.y - t.height > UP ) {
							trains.remove(t);
							t.parent.removeChild(t);
						}
					}
				}

				if( timer-- < 0 && !won) {
					initTimer();
					var pos = getPos();
					if( pos != null ) {
						var train : TrainM = cast dm.attach("mcTrainTrain", 3 );
						switch( pos.pos ) {
							case 0 :
								train.x = M1;
							case 1 :
								train.x = M2;
							case 2 :
								train.x = M3;
							case 3 :
								train.x = M1;
							case 4 :
								train.x = M2;
							case 5 :
								train.x = M3;
						}
						train.sector = pos.pos;
						if( pos.up ) {
							train.y = UP;
							train.y = train.y;
							train.up = true;
						} else {
							train.rotation = 180;
							train.y = DOWN;
							train.y = train.y;
							train.up = false;
						}
						train.rad = Std.random( 270 );
						trains.push( train );
					}
				}
			case 2 :
				for( t in trains ) {
					

					if( ( t.dist -= speed ) > -60 ) {
						if( t.up ) 		t.y -= speed*0.25;
						else 			t.y += speed*0.25;
						continue;
					}
					t.scaleX -= speed * 0.005;
					t.scaleY = t.scaleX;
					
					if( t.scaleX < 0.5 ) {
						var f = dm.attach("mcTrainBlood", 10 );
						f.x = t.x;
						f.y = t.y;
						var p = new Phys( f );
						//p.timer = 10;
						//p.vsc = 1.02;
						t.parent.removeChild(t);
						setWin( false, 10 );
						step = 3;
					}
				}
			case 3 :
				for( t in trains ) t.scaleX = t.scaleY = 1;
		}
		super.update();
	}

	function initTimer() {
		timer = (BASE + Std.random(BASE))*(2.5-dif*1.5);
	}

	function moveSection() {
		if( won ) return;

		var x = getMousePos().x;
		var lim = 130;
		if( x <= lim ) {
			replace.x = M1;
			return;
		}
		if( x > lim && x <= Cs.mcw-lim ) {
			replace.x = M2;
			return;
		}

		replace.x = M3;
	}

	function getPos() : { pos : Int, up : Bool } {
		var available = [true,true,true,true,true,true]; // 1UP, 2UP, 3UP, 1DOWN, 2DOWN, 3DOWN

		for( t in trains ) {
			available[t.sector] = false;
			if( t.up ) {
				available[t.sector + 3] = false;
			} else {
				available[t.sector - 3] = false;
			}
		}

		var idx : Array<Int>= new Array();
		for( i in 0...available.length ) {
			var r = available[i];
			if( !r ) continue;
			idx.push( i );
		}

		var id = idx[ Std.random( idx.length ) ];
		if( idx.length <= 0 ) {
			return null;
		}

		var up = if( id < 3 ) true else false;
		return { pos : id, up : up };
	}

	function hit( t : TrainM ) {
		if( t.up ) {
			if( t.y > Y && t.y < Y + replace.height ) {
				var d = ( t.y - ( Y + replace.height  ) );
				switch( t.sector ) {
					case 0 :
						if( replace.x != M1 ) { step = 2; t.dist = d; }
					case 1 :
						if( replace.x != M2 ) { step = 2; t.dist = d; }
					case 2 :
						if( replace.x != M3 ) { step = 2; t.dist = d; }
				}
			}
			return;
		}

		if( t.y > Y && t.y < Y + replace.height ) {
			var d = ( t.y - ( Y + replace.height  ) );
			switch( t.sector ) {
				case 3 :
					if( replace.x != M1 ) { step = 2; t.dist = d; }
				case 4 :
					if( replace.x != M2 ) { step = 2; t.dist = d; }
				case 5 :
					if( replace.x != M3 ) { step = 2; t.dist = d; }
			}
		}
	}

	override function outOfTime(){
		replace.parent.removeChild(replace);
		won = true;
		setWin(true);
	}

}
