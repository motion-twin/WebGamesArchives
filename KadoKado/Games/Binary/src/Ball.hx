import mt.bumdum.Lib;
import Protocol;

class Ball {//}

	public var flIce:Bool;
	public var gid:Int;
	public var fall:Int;

	public var color:Int;
	public var px:Int;
	public var py:Int;
	public var save:{x:Int,y:Int};

	public var root:flash.MovieClip;
	public var skin:flash.MovieClip;
	public var dm:mt.DepthManager;

	public var mcArrow:flash.MovieClip;
	public var mcShade:flash.MovieClip;


	public function new(x,y,?col){

		root = Game.me.dm.empty(Game.DP_BALLS);
		dm = new mt.DepthManager(root);
		skin = dm.attach("mcBall2",0);
		
		mcShade = Game.me.sdm.attach("mcShade",0);
		
		Game.me.balls.push(this);
		setPos(x,y);
		setColor(col);

		//root._xscavle = root._yscale = (Cs.CS/30)*100;
		//Filt.glow(root,2,4,0,true);

	}

	public function setPos(x,y){
		px = x;
		py = y;
		insertInGrid();
		display(px,py);
	}
	public function display(x,y){
		root._x = Cs.getX(x);
		root._y = Cs.getY(y);

		mcShade._x = root._x + 5;
		mcShade._y = root._y + 5;
	}

	public function setColor(?col){
		if(col==null)col = Std.random(Cs.COLOR_MAX);
		color = col;
		var fr = color+1;
		skin.gotoAndStop(fr);
		
		skin.smc.gotoAndStop(fr);
	}

	public function select(){
		//mcArrow = dm.attach("mcArrow",1);
		//mcArrow._rotation = rot;
		//root._xscale = 110;
		//root._yscale = 110;
		//Filt.glow(root,2,4,0xFFFFFF);
		//Filt.glow(root,4,2,0xFFFFFF);
		Filt.glow(root,2,4,0xFFFFFF,true);
		Filt.glow(root,4,2,0xFFFFFF,true);
		Col.setColor(root,0,20);
		Game.me.dm.over(root);
	}
	public function unselect(){
		Col.setPercentColor(root,0,0);
		//mcArrow.removeMovieClip();
		//root._xscale = 100;
		//root._yscale = 100;
		root.filters = [];
		//Game.me.select.remove(this);
	}

	public function insertInGrid(){
		Game.me.grid[px][py] = this;
	}
	public function removeFromGrid(){
		Game.me.grid[px][py] = null;
	}

	public function top(){
		removeFromGrid();
		var py = Cs.YMAX;
		while(true){
			if( Game.me.grid[px][py] == null ){
				root.filters = [];
				Filt.glow(root,2,4,0,true);
				Col.setPercentColor(root,0,0);
				setPos(px,py);
				setColor(10);
				break;
			}
			py++;
		}
		setVisible(false);
	}

	//
	public function setVisible(fl){
		root._visible = fl;
		mcShade._visible = fl;
	}

	// BRICOLE
	public function savePos(){
		save = {x:px,y:py}
	}
	public function loadPos(){
		px = save.x;
		py = save.y;
	}

	// KILL
	public function explode(){

		//

		for( x in 0...4 ){for( y in 0...4 ){
			var p = new mt.bumdum.Phys( Game.me.dm.attach("partExplode",Game.DP_FX) );
			var a = Math.random()*6.28;
			var sp = Math.random()*3;
			var cr = Math.random()*20;
			//p.x = root._x + Math.cos(a)*cr;
			//p.y = root._y + Math.sin(a)*cr;
			p.x = root._x + (x-2)*14;
			p.y = root._y + (y-2)*14;
			p.weight = -(0.05+Math.random()*0.05);
			p.vy = 1+Math.random();
			p.timer = 10 + Math.random()*30;
			p.frict = 0.9;
			p.fadeType = 0;
			p.setScale(80-(Math.abs(x-2)+Math.abs(y-2))*15    );
			//p.root.blendMode = "add";
			p.updatePos();
			Filt.glow(p.root,2,4, Cs.COLOR_LIST[color]);
			p.root.gotoAndStop(Std.random(p.root._totalframes)+1);


		}}

		// LIGHT
		var cr = 3;
		for( i in 0...8 ){
			var p = new mt.bumdum.Phys( Game.me.dm.attach("partLight",Game.DP_FX) );
			var a = Math.random()*6.28;
			var sp = Math.random()*4;
			p.vx =  Math.cos(a)*sp;
			p.vy =  Math.sin(a)*sp;
			p.x = root._x + p.vx*cr;
			p.y = root._y + p.vy*cr;
			p.timer = 10 + Math.random()*20;
			p.frict = 0.9;
			p.fadeType = 0;
			p.updatePos();

		}
		top();
	}
	function kill(){
		removeFromGrid();
		Game.me.balls.remove(this);
		root.removeMovieClip();
	}




//{
}











