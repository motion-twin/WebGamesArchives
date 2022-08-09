// 
// $Id: Arrow.as,v 1.1 2004/03/21 12:12:58  Exp $
//

import frutibandas.Main;
import frutibandas.Direction;
import frutibandas.gui.*;

class frutibandas.gui.Arrow extends MovieClip {

    public  static var LINK_NAME : String = "mcArrow";

    private static var POSITIONS : Array = [ {x:350, y:25 },  // up
                                             {x:508, y:180},  // right
                                             {x:350, y:345},  // down
                                             {x:190, y:180} ];// left

    private var direction : Direction;

    public static function New( game:Game, direction:Direction ) : Arrow
    {
        var depth : Number = game.getNextHighestDepth();
        var arrow : Arrow  = Arrow( game.attachMovie(LINK_NAME, LINK_NAME+depth, depth ) );
        arrow._visible = false;
        arrow.setDirection( direction );
        arrow.stop();
        return arrow;
    }

    public function hide() : Void
    {
        if (_currentframe <= 2)
        this.gotoAndPlay(3); 
    }
    
    public function show() : Void
    {
        _visible = true;
        this.gotoAndStop(1);
    }

    public function onRollOver() : Void
    {
        if (_currentframe <= 2)
        this.gotoAndStop(2);
    }

    public function onRollOut() : Void
    {
        if (_currentframe == 2)
        this.gotoAndStop(1);
    }
    
    public function onRelease() : Void
    {
        if (_currentframe <= 2)
        Main.game.requestMove(direction);
    }
    
    private function setDirection( d:Direction ) : Void
    {
        _x = POSITIONS[d.toNumber()].x;
        _y = POSITIONS[d.toNumber()].y;

        direction = d;
        switch (direction) {
            case Direction.Up:
                break;
                
            case Direction.Down:
                _yscale = -100;
                break;
                
            case Direction.Left:
                _rotation = -90;
                break;
                
            case Direction.Right:
                _rotation =  90;
                break;
        }
    }
}

//eof
