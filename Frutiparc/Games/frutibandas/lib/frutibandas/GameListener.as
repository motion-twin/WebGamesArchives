// 
// $Id: GameListener.as,v 1.5 2004/02/26 19:52:57  Exp $
//
import frutibandas.Coordinate;
import frutibandas.Direction;

interface frutibandas.GameListener 
{
    function onMove( team:Number, d:Direction )          : Void;
    function onMessage( userName:String, msg:String )    : Void;
}
//EOF
