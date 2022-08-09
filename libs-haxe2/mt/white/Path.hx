package mt.white;
import flash.geom.Point;

/*
* Cette classe permet de définir un trajet grâce à un système de balises de points
* elle permet également de déterminer suivant une direction quel est le prochain point ainsi que le dernier
*/

class Path {
	
	public var anchors : Array<Point<Float>>;
	
	public function new( a : Array<Point<Float>> = null ) {
		if( a != null )
			anchors = a;
		else
			anchors = new Array();
	}
	
	public function addCheck( x : Float, y : Float ) {
		anchors.push( new Point( x , y ) );
	}
	
	/*
	* Permet de récupérer l'ancre suivante d'un point en fonction de sa direction
	*/
	public function getNextAnchor( cur : Float, dx : Float = 1.0, horizontal : Bool ) {
		if( horizontal ) {
			dx = if( dx >= 0 ) 1 else -1;
			var next : Point<Float> = null;
			for( i in 0...anchors.length ) {
				var a = anchors[i];
				if( dx > 0 ) {
					if( a.x >= cur ) {
						return a;
					}
				}
				else {
					if( a.x <= cur ) {
						next = a;
					}				
				}
			}
			return next;
		}
		return null;
	}

	/*
	* Permet de récupérer l'ancre précédente d'un point en fonction de sa direction
	*/
	public function getPreviousAnchor( cur : Float, dx : Float = 1.0, horizontal : Bool ) {
		if( horizontal ) {
			dx = if( dx >= 0 ) 1 else -1;
			var last : Point<Float> = anchors[0];
			for( i in 0...anchors.length ) {
				var a = anchors[i];
				if( dx > 0 ) {
					if( a.x <= cur ) {
						last = a;
						continue;
					}
					return last;
				} else {
					if( a.x >= cur ) {
						return a;
					}
					last = a;				
				}
			}
			return null;
		}
		return null;
	}

	/*
	* Permet de connaître la coordonnée Y d'un point B situé entre un point A et un point C
	* à partir de sa coordonnées en X et de sa direction
	*/
	public function getPositionFromX( x : Float, y : Float, dx : Float ) : { y : Float, angle : Float } {
		var next = getNextAnchor( x, dx, true );
		if( next == null ) return null; 
		var last = getPreviousAnchor( x, dx, true );
		var cur = new Point( x, y );
		var ay = next.y - last.y;			
		var lx = next.x - last.x;
		var dify = ( ay / lx );
		var dy = next.y - cur.y ;
		var ypos = last.y + dify * ( cur.x - last.x );
		var angle = getAngle( last, next, dx );
		return { y : ypos, angle : angle };
	}
	
	/* 
	* Permet de déterminer l'angle en degrés de la ligne entre un point A et un point C
	* en fonction de la direction d'un objet
	*/
	public function getAngle( a1 : Point<Float>, a2 : Point<Float>, d : Float ) {
		d = if( d >= 0 ) 1 else -1;
		if( d > 0 ) return Geom.degrees( Math.atan2( a2.y - a1.y, a2.x - a1.x ) ); // / Math.PI * 180;
		return Geom.degrees( Math.atan2( a1.y - a2.y, a1.x - a2.x ) ); /// Math.PI * 180;
	}
	
}