// 
// $Id: Token.as,v 1.1.1.1 2004/01/26 15:09:48  Exp $
//

import grapiz.TokenListener;
import grapiz.Coordinate;
import grapiz.Direction;

class grapiz.Token
{
    private var team       : Number;
    private var coordinate : Coordinate;
    private var listener   : TokenListener;

    public function Token( team : Number ) 
    {
        this.team = team;
    }

    public function move( d:Direction, n:Number ) 
    {
        this.listener.onMove(this, d, n);
        this.coordinate.move(d, n);
    }

    public function destroyed() 
    {
        this.listener.onDestroyed();
    }
    
    public function setCoordinate( c:Coordinate ) 
    {
        this.coordinate = c; 
    }
    
    public function getCoordinate() : Coordinate  
    { 
        return this.coordinate; 
    }
    
    public function getTeam() : Number 
    { 
        return this.team; 
    }
    
    public function setListener( l:TokenListener ) : Void 
    { 
        this.listener = l; 
    }
}

//EOF

