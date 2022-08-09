class Pastille extends Element{//}


	var type:int;
	var cn:MovieClip;
	
	function new(){
		super();
		ray = 20
		skin = "mcPastille"
		
		type = 0
		if(Std.random(30)==0)type = 1
		if(Std.random(200)==0)type = 2
	}
	
	function update(){
		super.update();
		if( Cs.game.blob.getDist(this) < 70 ){
			flRemove=true;
			var p = new Spark( Cs.game.dm.attach("mcPastille",Game.DP_PART) )
			p.x = x;
			p.y = y;
			downcast(p.root).c.gotoAndStop(string(type+1));
			p.score = Cs.SCORE_PASTILLE[type];
			Cs.game.stats.$b[type]++;
		};
		var sc = 90+Math.random()*20
		cn._xscale = sc;
		cn._yscale = sc;
		
	}

	function attach(){
		super.attach();
		var o = Cs.game.eList[0]
		for( var i=0; i<o.list.length; i++ ){
			var wh = o.list[i]
			if( Cs.getDist(wh,this) < wh.ray+20 ){
				flRemove = true
				root.removeMovieClip();
				root = null;
			}
		}
		cn = downcast(root).c
		cn.gotoAndStop(string(type+1))
	}
		
	
//{
}