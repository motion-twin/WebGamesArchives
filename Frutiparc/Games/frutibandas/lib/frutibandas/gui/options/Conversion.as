// 
// $Id: Conversion.as,v 1.2 2004/02/10 18:26:52  Exp $
//

import frutibandas.Main;
import frutibandas.Coordinate;

import frutibandas.gui.Animable;
import frutibandas.gui.Board;

class frutibandas.gui.options.Conversion implements Animable
{
    private static var ANIM_LENGTH =  19;
    private static var MIN_RADIUS  =  10;
    private static var MAX_RADIUS  = 100;
    private static var SPEED       =  11;
    
    private var running   : Boolean;
   
    private var color     : Number;
    private var center    : Coordinate;
    private var steps     : Number;
    private var radius    : Number;
    private var speed     : Number;

    private var movie     : MovieClip;

    public function Conversion( c:Coordinate, newTeam:Number )
    {
        if (newTeam == 0) 
            this.color   = 0xFF9999;
        else
            this.color   = 0x99FF99;
        this.center  = Main.gameUI.board.getBandasRealCoordinate(c);
        this.steps   = ANIM_LENGTH;
        this.running = false;
        this.speed     = 4;
        this.radius    = MIN_RADIUS;
    }

    public function start() : Void
    {
        this.running = true;

        var board : Board  = Main.gameUI.board;
        var depth : Number = board.getNextHighestDepth();
        this.movie = board.createEmptyMovieClip("High_1", depth);
        this.movie._x = this.center.x;
        this.movie._y = this.center.y;
    }

    public function update() : Boolean
    {
        if (!this.running) {
            this.start();
        }
        this.steps--;
        this.redraw();

        if (this.steps <= 0) {
            this.tearDown();
            return false;
        }
        return true;
    }

    private function redraw() : Void
    {
        var alpha = 100 - this.radius;
        var r     = this.radius;
        var x     = 0;
        var y     = r;
        this.movie.clear();
        this.movie.lineStyle( r, color, alpha );
        this.movie.moveTo( x, y );
        this.movie.curveTo( x+r, y,     x+r, y-r   );
        this.movie.curveTo( x+r, y-r-r, x,   y-r-r );
        this.movie.curveTo( x-r, y-r-r, x-r, y-r   );
        this.movie.curveTo( x-r, y,     x,   y     );
        
        this.radius += SPEED;
        if (this.radius >= MAX_RADIUS) 
            this.radius  = MIN_RADIUS;
    }

    private function tearDown() : Void
    {
        this.movie.removeMovieClip();
    }
}

//EOF
