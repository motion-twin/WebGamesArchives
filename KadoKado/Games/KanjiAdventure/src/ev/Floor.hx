package ev;

typedef Pos = {x:Int,y:Int,t:Float};

class Floor extends Event {//}

	static var EC = 40;

	var bstep:Int;
	var endAnimCounter:Int;

	var lvl:Int;
	var mcFader:flash.MovieClip;
	var mcBmp:flash.MovieClip;
	var mcBlack:flash.MovieClip;
	var dm:mt.DepthManager;
	var dm2:mt.DepthManager;
	var bmp:flash.display.BitmapData;
	var list:Array<Pos>;

	public function new(inc){
		super();



		this.lvl = Game.me.cfl.id+inc;

		var etage = lvl+"ème étage";
		if( lvl==0 )etage = "rez-de-chaussée";
		if( lvl==1 )etage = "1er sous-sol";
		if( lvl==2 )etage = "2d sous-sol";
		Game.me.log("Vous "+["grimpez","descendez"][inc<0?0:1]+" les escaliers vers le "+etage );



		//step = 1;
		bstep= 0;
		spc = 0.035;


		mcFader = Game.me.dm.empty(Game.DP_FADER);
		dm = new mt.DepthManager(mcFader);
		bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0);
		mcBmp = dm.empty(1);

		dm2 = new mt.DepthManager(mcBmp);
		dm2.empty(0).attachBitmap(bmp,0);

		buildList();


	}

	public function buildList(){
		var xmax = Math.ceil(Cs.mcw/EC);
		var ymax = Math.ceil(Cs.mch/EC);

		list = [];
		for( x in 0...xmax ){
			for( y in 0...ymax ){
				list.push( {x:x,y:y,t:(x+y)*1.0} );
			}
		}

	}

	override function update(){
		super.update();



		switch(step){
			case 0 : // FADE BLACK
				var a = list.copy();
				for( p in a  ){
					p.t -= 1;
					if( p.t < 0 ){
						var mc = dm2.attach("mcFadeRound",0);
						mc._x = (p.x+0.5)*EC;
						mc._y = (p.y+0.5)*EC;
						Reflect.setField(mc,"_drawMe", callback(draw,mc) );
						list.remove(p);
					}

				}
				if(a.length==0 ){
					if( endAnimCounter==null )endAnimCounter = 12;
					if( endAnimCounter--==0 ){
						endAnimCounter=null;
						switch(bstep){
							case 0:
								bstep++;
								coef = 0;
								bmp.fillRect( new flash.geom.Rectangle(0,0,Cs.mcw,Cs.mch), 0 );
								mcBlack = dm.attach("mcBlack",0);
								mcBmp.blendMode = "erase";
								mcFader.blendMode = "layer";
								buildList();

								Game.me.allies = [];
								for( ent in Game.me.cfl.ents ){
									if(ent.flGood && Game.me.hero!=ent)Game.me.allies.push(ent);
								}
								Game.me.loadFloor(lvl);



							case 1:
								kill();
						}
					}

				}


		}
	}

	public function draw(mc){
		var m = new flash.geom.Matrix();
		m.translate( mc._x, mc._y );
		bmp.draw(mc,m);
		mc.removeMovieClip();
	}

	override function kill(){
		mcFader.removeMovieClip();
		bmp.dispose();
		super.kill();
	}



//{
}







