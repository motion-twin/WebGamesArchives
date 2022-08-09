package mt.deepnight;

import mt.MLib;

class Bresenham {

	// Renvoie la liste des points entre x0,y0 et x1,y1

	public static function getThinLine(x0:Int, y0:Int, x1:Int, y1:Int, ?respectOrder=false) : Array<{x:Int, y:Int}> {
		var pts = [];
		var swapXY = MLib.iabs( y1 - y0 ) > MLib.iabs( x1 - x0 );
		var swapped = false;
        var tmp : Int;
        if ( swapXY ) {
            // swap x and y
            tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
            tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
        }
        if ( x0 > x1 ) {
            // make sure x0 < x1
            tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
            tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
			swapped = true;
        }
        var deltax = x1 - x0;
        var deltay = MLib.floor( MLib.iabs( y1 - y0 ) );
        var error = MLib.floor( deltax / 2 );
        var y = y0;
        var ystep = if ( y0 < y1 ) 1 else -1;
		if( swapXY )
			// Y / X
			for ( x in x0 ... x1+1 ) {
				pts.push({x:y, y:x});
				error -= deltay;
				if ( error < 0 ) {
					y+=ystep;
					error = error + deltax;
				}
			}
		else
			// X / Y
			for ( x in x0 ... x1+1 ) {
				pts.push({x:x, y:y});
				error -= deltay;
				if ( error < 0 ) {
					y+=ystep;
					error = error + deltax;
				}
			}

		if( swapped && respectOrder )
			pts.reverse();

		return pts;
	}



	// Cette version "Fat" fonctionne comme la précédente, mais la ligne renvoyée est
	// légèrement plus "épaisse" au niveau des brisures de lignes.
	// Utile pour les collisions en diagonal (demander à Seb si besoin de précisions).

	public static function getFatLine(x0:Int, y0:Int, x1:Int, y1:Int, ?respectOrder=false) {
		var pts = [];
		var swapXY = MLib.iabs( y1 - y0 ) > MLib.iabs( x1 - x0 );
		var swapped = false;
        var tmp : Int;
        if ( swapXY ) {
            // swap x and y
            tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
            tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
        }
        if ( x0 > x1 ) {
			swapped = true;
            // make sure x0 < x1
            tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
            tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
        }
        var deltax = x1 - x0;
        var deltay = MLib.floor( MLib.iabs( y1 - y0 ) );
        var error = MLib.floor( deltax / 2 );
        var y = y0;
        var ystep = if ( y0 < y1 ) 1 else -1;

		if( swapXY )
			// Y / X
			for ( x in x0 ... x1+1 ) {
				pts.push({x:y, y:x});

				error -= deltay;
				if ( error < 0 ) {
					if( x<x1 ) {
						pts.push({x:y+ystep, y:x});
						pts.push({x:y, y:x+1});
					}
					y+=ystep;
					error = error + deltax;
				}
			}
		else
			// X / Y
			for ( x in x0 ... x1+1 ) {
				pts.push({x:x, y:y});

				error -= deltay;
				if ( error < 0 ) {
					if( x<x1 ) {
						pts.push({x:x, y:y+ystep});
						pts.push({x:x+1, y:y});
					}
					y+=ystep;
					error = error + deltax;
				}
			}

		if( swapped && respectOrder )
			pts.reverse();

		return pts;
	}


	// Donne la liste des points situés sur un cercle donné
	// Source : http://en.wikipedia.org/wiki/Midpoint_circle_algorithm

	public static function getCircle(x0,y0,radius) {
		var pts = [];
		var x = radius;
		var y = 0;
		var radiusError = 1-x;
		while( x>=y ) {
			pts.push({ x : x+x0, y : y+y0 });
			pts.push({ x : -x+x0, y : y+y0 });

			pts.push({ x : y+x0, y : x+y0 });
			pts.push({ x : -y+x0, y : x+y0 });

			pts.push({ x : x+x0, y : -y+y0 });
			pts.push({ x : -x+x0, y : -y+y0 });

			pts.push({ x : y+x0, y : -x+y0 });
			pts.push({ x : -y+x0, y : -x+y0 });

			y++;
			if( radiusError<0 )
				radiusError += 2*y+1;
			else {
				x--;
				radiusError += 2*(y-x+1);
			}
		}
		return pts;
	}



	// Donne la liste des points situés SUR et DANS un cercle donné
	// Source : http://stackoverflow.com/questions/1201200/fast-algorithm-for-drawing-filled-circles

	static inline function addLine(pts, fx,fy, tx) {
		for(x in fx...tx+1)
			pts.push({x:x, y:fy});
	}
	public static function getDisc(x0,y0,radius) {
		var pts = [];
		var x = radius;
		var y = 0;
		var radiusError = 1-x;
		while( x>=y ) {
			addLine(pts, -x+x0, y+y0, x+x0);
			addLine(pts, -y+x0, x+y0, y+x0);
			addLine(pts, -x+x0, -y+y0, x+x0);
			addLine(pts, -y+x0, -x+y0, y+x0);
			y++;
			if( radiusError<0 )
				radiusError += 2*y+1;
			else {
				x--;
				radiusError += 2*(y-x+1);
			}
		}
		return pts;
	}




	// Vérifie que tous les points d'une ligne sont valides: si rayCanPass(x,y) renvoie FALSE sur
	// un point (ie. obstacle), toute la méthode renvoie FALSE

	public static function checkThinLine(x0:Int,y0:Int, x1:Int,y1:Int, rayCanPass:Int->Int->Bool) {
		if( !rayCanPass(x0,y0) )
			return false;

		if( !rayCanPass(x1,y1) )
			return false;

		var swapXY = MLib.iabs( y1 - y0 ) > MLib.iabs( x1 - x0 );
        var tmp : Int;
        if ( swapXY ) {
            // swap x and y
            tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
            tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
        }
        if ( x0 > x1 ) {
            // make sure x0 < x1
            tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
            tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
        }
        var deltax = x1 - x0;
        var deltay = Math.floor( MLib.iabs( y1 - y0 ) );
        var error = Math.floor( deltax / 2 );
        var y = y0;
        var ystep = if ( y0 < y1 ) 1 else -1;

		if( swapXY )
			// Y / X
			for ( x in x0 ... x1+1 ) {
				if( !rayCanPass(y,x) )
					return false;
				error -= deltay;
				if ( error < 0 ) {
					y+=ystep;
					error = error + deltax;
				}
			}
		else
			// X / Y
			for ( x in x0 ... x1+1 ) {
				if( !rayCanPass(x,y) )
					return false;
				error -= deltay;
				if ( error < 0 ) {
					y+=ystep;
					error = error + deltax;
				}
			}
		return true;
	}


	public static function checkFatLine(x0:Int,y0:Int, x1:Int,y1:Int, rayCanPass:Int->Int->Bool) {
		if( !rayCanPass(x0,y0) )
			return false;

		if( !rayCanPass(x1,y1) )
			return false;

		var swapXY = MLib.iabs( y1 - y0 ) > MLib.iabs( x1 - x0 );
        var tmp : Int;
        if ( swapXY ) {
            // swap x and y
            tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
            tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
        }
        if ( x0 > x1 ) {
            // make sure x0 < x1
            tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
            tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
        }
        var deltax = x1 - x0;
        var deltay = MLib.floor( MLib.iabs( y1 - y0 ) );
        var error = MLib.floor( deltax / 2 );
        var y = y0;
        var ystep = if ( y0 < y1 ) 1 else -1;

		if( swapXY )
			// Y / X
			for ( x in x0 ... x1+1 ) {
				if( !rayCanPass(y,x) )
					return false;

				error -= deltay;
				if ( error < 0 ) {
					if( x<x1 ) {
						if( !rayCanPass(y+ystep, x) )
							return false;
						if( !rayCanPass(y, x+1) )
							return false;
					}
					y+=ystep;
					error = error + deltax;
				}
			}
		else
			// X / Y
			for ( x in x0 ... x1+1 ) {
				if( !rayCanPass(x,y) )
					return false;

				error -= deltay;
				if ( error < 0 ) {
					if( x<x1 ) {
						if( !rayCanPass(x, y+ystep) )
							return false;
						if( !rayCanPass(x+1, y) )
							return false;
					}
					y+=ystep;
					error = error + deltax;
				}
			}
		return true;
	}
}

