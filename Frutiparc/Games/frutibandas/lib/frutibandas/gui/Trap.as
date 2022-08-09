// 
// $Id: Trap.as,v 1.1 2004/03/21 12:12:58  Exp $
//

import frutibandas.gui.Board;
import frutibandas.Coordinate;

class frutibandas.gui.Trap extends MovieClip
{
    private var coordinate : Coordinate;
    
    public static function New( b:Board, c:Coordinate, depth:Number ) : Trap
    {//{{{
        if (depth == undefined) depth = b.getNextHighestDepth();
        var trap = Trap( b.attachMovie("mcTrap", "Trap"+depth, depth) );
        trap.coordinate = c;
        var guic = b.getBandasRealCoordinate(c);
        trap._x = guic.x;
        trap._y = guic.y;
        trap.stop();
        return trap;
    }//}}}

    public function getCoordinate() : Coordinate 
    {
        return coordinate;
    }
}
// EOF
