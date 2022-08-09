//package mt.white;

typedef Scrollable = {>flash.MovieClip, created : Bool, x : Float, y : Float, ydiff : Float }
typedef Layer = { idx : Int, scroller : Array<Scrollable>, linkage : String, xSpeed : Float, verticalScrollEnabled : Bool, maxVScroll : Bool }

class Scroller {
	
	var dm : mt.DepthManager;
	var scroller : Array<Scrollable>;
	var width : Float;
	var height : Float;
	var depth : Int;
	var margin : Float;
	var gotInfo : Bool;
	var vscroll : Bool;
	var verticalScrollBlocked : Bool;
	var maxVScroll : Bool;
	var layers : IntHash<Layer>;
	var cl : Int;

	public function new( root : flash.MovieClip, width : Int, height : Int ){
		if( root == null ) throw "root is null";

		cl = 0;
		layers = new IntHash();
		this.width = width;
		this.height = height;
		this.dm = new mt.DepthManager(root);
	}

	public function addLayer( linkage : String, xSpeed : Float = 0.0, verticalScrollEnabled : Bool = false, maxVScroll : Bool = true ) {
		if( linkage == null ) throw "linkage needed";		
		var scroller = new Array();
		layers.set( ++cl, { idx : cl, scroller : new Array(), linkage : linkage, xSpeed : xSpeed, verticalScrollEnabled : verticalScrollEnabled, maxVScroll : maxVScroll } );
		add(layers.get( cl) , 0);
	}

	function add( layer : Layer, x : Float ) {
		if( layer == null ) throw "unknown layer";

		var m : Scrollable = cast dm.attach( layer.linkage, layer.idx );
		m.x = m._x = x;

		if( !gotInfo ) {
			if( m._height >= height ) {
				margin = (( m._height - height ) / 2);
			} else {
				margin = (( height - m._height ) / 2);
			}
			gotInfo = true;
		}

		m._y = m.y = -margin;
		m.ydiff = 0;
		layer.scroller.push( m );
	}

	public function update( xSpeed : Float, xMod : Float, ySpeed : Float ) {
		if( xSpeed == 0 && ySpeed == 0 ) return;

		for( l in layers.iterator() ) {
			var scroller = l.scroller;
			for( s in scroller ) {		

				if( xSpeed != 0 ) {
					if( s._x <= 0 && !s.created ) {
						add(l,  s._x + s._width );
						s.created = true;
					}

					if( s._x + s._width <= 0 ) {
						scroller.remove( s);
						s.removeMovieClip();
					}
					s._x -= xSpeed + if( xMod < 0 && Math.abs( xMod ) > xSpeed ) 0 else xMod;
				}

				if( ySpeed == 0 ) continue;

				if( Math.abs( s.ydiff ) < margin ) {
					s._y -= ySpeed;
					s.ydiff += ySpeed;
					continue;
				}

				if( s.ydiff <= 0 && s.ydiff <= margin && ySpeed > 0 ) {			
					if( s._y >= margin ) continue;

					s._y -= ySpeed;
					s.ydiff += ySpeed;
					continue;
				}


				if( s.ydiff >= 0 && s.ydiff >= margin && ySpeed < 0 && s._y <= 0 ) {
					s._y -= ySpeed;
					s.ydiff += ySpeed;				
					continue;
				}			
			}
		}
	}

	public function clean() {
		for( s in scroller ) {
			scroller.remove(s);
			s.removeMovieClip();
		}
		scroller = null;
	}
}
