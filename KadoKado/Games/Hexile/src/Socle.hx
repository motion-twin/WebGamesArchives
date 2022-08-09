import Game;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Socle {//}

	public var height:Int;

	public var dataSea:Int;

	public var team:Int;
	public var n:Int;
	public var x:Int;
	public var y:Int;

	public var soldats:Array<flash.MovieClip>;

	public var type:HexType;
	public var root:{>flash.MovieClip,but:flash.MovieClip,base:flash.MovieClip};

	var mcSelection:flash.MovieClip;

	public function new(x,y){



		this.x = x;
		this.y = y;
		team = null;
		n = 0;

		soldats = [];

		root = cast Game.me.gdm.attach("mcHex",0);
		root._x = Cs.getX(x,y);
		root._y = Cs.getY(x,y);
			Reflect.setField(root,"_obj",this);

		Game.me.grid[x][y] = this;
		Game.me.socles.push(this);


		//
		root.enabled = false;
		root.onRollOver = rover;
		root.onDragOver = rover;
		root.onRollOut = rout;
		root.onDragOut = rout;
		root.onRelease = select;
		root.useHandCursor = true;
		KKApi.registerButton(root);

	}


	// DECOR
	public function setType(t){
		type = t;
		root.gotoAndStop(Type.enumIndex(t)+1);

		height = 0;
		switch(type){
			case Dirt:
				var n = Std.random(2);
				height = 3+n*5;
				root.base._y = -height;
				root.base.smc.gotoAndStop(1+n);

			case Mountain:
				height = 12+Std.random(8);
				root.base._y = -height;

			default:

		}

	}
	public function seekSea(){
		var a = getNeighbors();
		dataSea = Cs.DIR.length - a.length;
	}

	// SOLDATS
	/*
	public function addSoldat(sol){
		sol.kill();
		n++;
		root.base.gotoAndStop(n+1);
	}
	public function removeSoldat(){
		sol.kill();
		n++;
		root.base.gotoAndStop(n+1);
	}
	*/
	public function incSoldat(inc){
		n += inc;
		root.base.gotoAndStop(n+1);
		Game.me.incTeamScore(team,inc);
	}
	public function register(mc){
		soldats.push(mc);
		mc.gotoAndStop(team+1);
		mc._x = Math.round(mc._x);
		mc._y = Math.round(mc._y);

	}

	/*
	function updateSoldats(){
		for( i in 0...n ){
			var sol = list[i];
			var dec = getDec(i,max);
			sol.x = root._x + dec.x;
			sol.y = root._y + dec.y;
		}

	}
	function getDec(i,max){
		var lim = 6;
		if(max==1){
			return {x:0.0,y:0.0};
		}else if(max<=lim){
			var cr = 0.3+max*0.04;
			return getRayPos( i, max, Cs.WW*cr );
		}else{
			var dl = max-lim;
				if( i<lim ){
				var cr = 0.5+dl*0.05;
				return getRayPos(i,lim,Cs.WW*cr);
			}else{
				var cr = 0.0;
				var da = 0.0;
				if(dl>1) cr = 0.25;
				if(dl==2)da = 1.57;
				if(dl==2)cr = 0.2;
				if(dl==3)da = 0.5;
				if(dl==4)cr = 0.3;

				return getRayPos(i,max-lim,Cs.WW*cr,da);
			}

		}
	}
	function getRayPos(i,max,ray:Float,?da){
		var a = i/max * 6.28;
		if(da!=null)a+=da;
		var p = {
			x:Math.cos(a)*ray,
			y:Math.sin(a)*ray
		};
		return p;

	}
	*/


	public function swapTeam(){
		Game.me.incTeamScore(team,-n);
		if( team == 0 )Game.me.decScore( Cs.SCORE_HEX[Type.enumIndex(type)] );
		if( team == 1 )KKApi.addScore( Cs.SCORE_HEX[Type.enumIndex(type)] );
		team = 1-team;
		Game.me.incTeamScore(team,n);
		soldats = [];
		root.base.gotoAndStop(1);
		root.base.gotoAndStop(n+1);

	}

	// INTER
	public function active(){
		root.enabled = true;
		KKApi.registerButton(root);
	}
	public function unactive(){
		root.enabled = false;
		KKApi.registerButton(root);
	}
	function rover(){
		Col.setColor(root,0,20);

		var max = Std.int( Math.min( getMax(type), Game.me.count ) );
		var list = getRenfort(max-1);
		var a = getConvert(max);
		for( h in a )list.push(h);
		Game.me.blinks = list;

		mcSelection = new mt.DepthManager(root).attach("mcSelection",0);
		mcSelection._y = -height;



	}
	function rout(){
		Col.setPercentColor(root,0,0);
		for( h in Game.me.blinks ){
			for( sol in h.soldats )Col.setPercentColor(sol,0,0);
		}
		Game.me.blinks = [];

		mcSelection.removeMovieClip();
	}
	function select(){
		rout();
		Game.me.initJump(this);
	}

	// FX
	public function fxPop(){

	}
	public function fxStar(){
		var cr = 0.5;
		var p = new Phys(Game.me.dm.attach("partStar",Game.DP_PARTS));
		p.x = root._x + (Math.random()*2-1)*Cs.WW*cr;
		p.y = root._y + (Math.random()*2-1)*Cs.HH*cr;
		p.weight = -(0.1+Math.random()*0.2);
		p.timer = 20+Math.random()*20;
		p.fadeType = 0;
		p.updatePos();
	}

	public function getRenfort(max){
		var fill = [];
		for( d in Cs.DIR ){
			var nx = x+d[0];
			var ny = y+d[1];
			var h = Game.me.grid[nx][ny];
			if( h.team==Game.me.turn && h.n < Socle.getMax(h.type) )fill.push(h);
		}
		var f = function(a:Socle,b:Socle){
			if(a.n<b.n)return -1;
			return 1;
		}
		fill.sort(f);
		while(fill.length>max)fill.pop();
		return fill;

	}
	public function getConvert(max){
		var list = [];
		for( d in Cs.DIR ){
			var nx = x+d[0];
			var ny = y+d[1];
			var h = Game.me.grid[nx][ny];
			if(h.team != Game.me.turn && h.team!=null ){
				if( h.getAttack(h.n) < getAttack(max) ){
					list.push(h);
				}
			}
		}
		return list;

	}

	// TOOLS
	public function getNeighbors(){
		var list = [];
		for( d in Cs.DIR ){
			var x = x+d[0];
			var y = y+d[1];
			var hex = Game.me.grid[x][y];
			if( hex !=null )list.push(hex);
		}
		return list;
	}
	public function getAttack(att){
		if( type == Mountain )att += 3;
		return att;
	}

	public static function getMax(type){
		switch(type){
			case Beach : 	return 10;
			case Dirt : 	return 8;
			case Mountain :	return 4;
		}
	}



//{
}







