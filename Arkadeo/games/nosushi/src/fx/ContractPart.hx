package fx;
import api.AKProtocol;

class ContractPart extends mt.fx.Fx {

	static var CENTER = new PT(525,164);
	static var RAY = 53;
	static var P = 0.8;
	
	var root : SP;
	var speed : Float;

	var fp : PT;
	var ep : PT;

	public function new( root, ep ){
		super();
		this.root = root;
		this.ep = ep;
		speed = 0.025;
		pos(0);
	}

	override function update(){
		coef += speed;
		var c = curve(coef);
		
		if( c <= P ){
			pos(c/P);
		}else{
			if( fp == null )
				fp = new PT(root.x,root.y);

			c = (c-P)/(1-P);
			
			root.x = fp.x + (ep.x-fp.x) * c;
			root.y = fp.y + (ep.y-fp.y) * c;
		}
			

		if( coef >= 1 )
			kill();
	}

	function pos( c : Float ){
		var a = c * Math.PI * 2 - Math.PI/2;

		var r = RAY*0.25 + RAY * c * 0.75;
		root.x = CENTER.x + Math.cos(a) * r;
		root.y = CENTER.y + Math.sin(a) * r;
	}

	override function kill(){
		super.kill();
		root.parent.removeChild(root);
	}
}
