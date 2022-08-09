import mt.bumdum.Lib;
import mt.bumdum.Trick;

class Card {//}

	var px:Int;
	var py:Int;
	var vx:Float;
	var vy:Float;

	public var tween:Tween;
	public var type:Int;
	public var power:Int;
	public var color:Int;
	public var root:flash.MovieClip;
	public var shade:flash.MovieClip;

	public function new(type,color,power){
		root = Game.me.dm.attach("mcCard",Game.DP_CARDS);

		this.type = type;
		this.power = power;
		this.color = color;


		cast(root)._power = power+1;

		applySkin();


		Filt.glow(root,2,1,0);

	}

	public function insertInGrid(x,y){
		px = x;
		py = y;
		Game.me.grid[px][py] = this;
		Game.me.removeBut(px,py);
		if(shade==null){
			root._x = Cs.getX(px);
			root._y = Cs.getY(py);
		}
	}

	// MOVE
	public function gotoHandPos(x){
		tween = new Tween( root._x, Cs.HAND_Y, x, Cs.HAND_Y );
	}
	public function goto(px,py){
		tween = new Tween( root._x, root._y, Cs.getX(px), Cs.getY(py) );
		shade = Game.me.dm.attach("mcCardShade",Game.DP_CARDS);
		shade._x = root._x;
		shade._y = root._y;
		Game.me.dm.over(root);
	}
	public function updatePos(c:Float){
		var ox = root._x;
		var oy = shade._y;
		root._x = tween.sx*(1-c) + tween.ex*c;
		root._y = tween.sy*(1-c) + tween.ey*c;




		if( shade!=null ){
			shade._x = root._x;
			shade._y = root._y;
			root._y -= Math.sin(c*3.14)*50;
			for( i in 0...3 )fxSpark();
			if(c==1){
				shade.removeMovieClip();
				shade = null;
				fxLand();

			}
			vx = root._x - ox;
			vy = shade._y - oy;

		}

	}

	// CONVERT
	public function convert(){
		for( d in Cs.DIR ){
			var x = px+d[0];
			var y = py+d[1];
			var card  = Game.me.grid[x][y];
			if( card!=null && card.color!= color ){
				if( type == (card.type+1)%3 )			card.colorize(color);
				if( type == card.type && power > card.power )	card.colorize(color);
			}
		}
	}
	public function colorize(c){
		fxFlash();
		color = c;
		root.gotoAndStop(color+1);
	}

	// ACTION
	public function active(){
		Trick.butAction(root,select,rover,rout);
	}
	public function unactive(){
		Trick.butKill(root);
	}

	public function rover(){
		Filt.glow(root,4,4,0xFFFFFF);
		Filt.glow(root,10,1,0xFFFFFF);
		Game.me.dm.over(root);
	}
	public function rout(){
		root.filters = [];
		for( c in Game.me.hand )Game.me.dm.over(c.root);
	}
	public function select(){
		Game.me.selectCard(this);

	}

	//
	public function applySkin(){
		root.gotoAndStop(color+1);
		root.smc.gotoAndStop(type+1);
	}
	public function hide(){
		root.gotoAndStop(4);
	}

	// FX
	public function fxSpark(){

		var p = new mt.bumdum.Phys(Game.me.dm.attach("mcSpark",Game.DP_PARTS));
		p.x = root._x + Math.random()*Cs.CARD_WIDTH;
		p.y = root._y + Math.random()*Cs.CARD_HEIGHT;
		p.weight = -(0.1+Math.random()*0.1);
		p.timer = 10+Math.random()*12;
		p.fadeType = 0;
		p.root.blendMode = "add";
		p.root.gotoAndPlay( Std.random(p.root._totalframes)+1 );
		p.frict = 0.97;
		p.vy = -Math.random();
		p.root._rotation = Math.random()*360;
		p.vr = (Math.random()*2-1)*15;
		return p;
	}
	public function fxLand(){

		fxFlash();



		//
		var max = 32;
		var cr = 5;
		var cx = root._x + Cs.CARD_WIDTH*0.5;
		var cy = root._y + Cs.CARD_HEIGHT*0.5;
		for( i in 0...max ){
			var p = new Line();
			p.x = root._x + Math.random()*Cs.CARD_WIDTH;
			p.y = root._y + Math.random()*Cs.CARD_HEIGHT;
			var dx = p.x - cx;
			var dy = p.y - cy;
			var a = Math.atan2(dy,dx);
			var speed = Math.sqrt(dx*dx+dy*dy);
			p.vx = Math.cos(a)*speed;
			p.vy = Math.sin(a)*speed;
			p.frict = 0.8;
			p.timer = 10+Math.random()*20;
			p.updatePos();
		}




	}

	function fxFlash(){
		var mc = Game.me.dm.attach("fxFlash",Game.DP_PARTS);
		mc._x  = root._x;
		mc._y  = root._y;
		mc.blendMode = "add";
	}



//{
}
