// 

import frutibandas.Coordinate;
import frutibandas.Main;

import frutibandas.gui.Animable;

/**
 * Animation of the Enclume option.
 *
 *    1 . enclum fall vertically above the target with a velocity
 *    2 . enclum is replaced by smoke anim
 *    3 . sprite at destination is removed
 *    4 . smoke anim play
 * 
 */
class frutibandas.gui.options.Enclume implements Animable
{
    private static var NAME             : String = "Enclume";
    private static var SYMBOL           : String = "mcAnvil";
    
    private static var ANIMATION_HEIGHT : Number = 200;
    private static var VELOCITY         : Number = 1.5;
    private static var MAX_SPEED        : Number = 20;

    private static var STATE_FALL       : Number = 1;
    private static var STATE_SMOKE      : Number = 2;

    private static var SMOKE_ANIM_LENGTH : Number = 11;
    
    public  var flCompleted   : Boolean;
    private var running       : Boolean;

    private var logicCoord    : Coordinate;
    private var sprite        : MovieClip;
    private var speed         : Number;
    private var destination   : Coordinate;
    private var startGuiCoord : Coordinate;
    private var movie         : MovieClip;
    private var state         : Number;
    
    private var smokeAnimStep : Number;


    public function Enclume(logicCoord:Coordinate, sprite:MovieClip)
    {
        this.sprite           = sprite;
        this.logicCoord       = logicCoord;
        this.destination      = Main.gameUI.board.getBandasRealCoordinate(logicCoord);
        this.startGuiCoord    = this.destination.copy();
        this.startGuiCoord.y -= ANIMATION_HEIGHT;
        this.running          = false;
        this.flCompleted      = false;
        this.speed            = 1;
        this.createMovie();
    }

    public function start() : Void
    {
        this.running          = true;
        this.flCompleted      = false;
        this.state            = STATE_FALL;
        // Main.pushAnimation(this, Main.ANIM_PRIO_CARD);
    }

    public function update() : Boolean
    {
        if (!running) start();
        
        if (state == STATE_FALL) 
            updateFall();
        else if (state == STATE_SMOKE) 
            updateSmoke();

        return !this.flCompleted;
    }

    private function updateFall() : Void
    {
        if (this.movie._y >= this.destination.y) {
            var depth = this.movie.getDepth();
            this.movie.removeMovieClip();
            this.movie = Main.gameUI.board.attachMovie("mcSmokeAnvil", "Smoke_1", depth);
            this.sprite.kill();
            this.movie._y = this.destination.y;
            this.movie._x = this.destination.x;
            this.smokeAnimStep = SMOKE_ANIM_LENGTH;
            this.state = STATE_SMOKE;
        }
        else {
            this.movie._y += this.speed;
            this.speed *= VELOCITY;
            if (this.speed > MAX_SPEED) 
                this.speed = MAX_SPEED;
        }
    }

    private function updateSmoke() : Void
    {
        this.smokeAnimStep--;
        if (this.smokeAnimStep <= 0) {
            this.flCompleted = true;
        }
    }

    private function createMovie() : Void
    {
        var board : MovieClip = Main.gameUI.board;
        var depth : Number = board.getNextHighestDepth();
        this.movie = board.attachMovie(SYMBOL, SYMBOL+depth, depth);
        this.movie._x = this.startGuiCoord.x;
        this.movie._y = this.startGuiCoord.y;
    }

    public function toString() : String
    {
        return "Anim 'Enclume' completed="+flCompleted;
    }
}

//EOF

