//
// Copyright (c) 2004 Motion-Twin
//
// $Id: Sprite.as,v 1.32 2004/03/21 12:28:18  Exp $
//
import frutibandas.Direction;
import frutibandas.Coordinate;
import frutibandas.Main;
import frutibandas.gui.Animable;

/**
 * Visual sprite manager.
 *
 * This class is bound to 'BandasX' movie clips.
 */
class frutibandas.gui.Sprite extends MovieClip implements Animable {

    /** Sprite identifier. */

    // CONSTANTES
    private var decal:Number = 8;


    // VARIABLES
    public var flCompleted:Boolean;

    public var id   : Number;
    public var team : Number;
    public var skin : Number;
    public var x    : Number;
    public var y    : Number;
    
    public var danceIndex : Number;

    public var danceList : Array;
    public var moveList  : Array;

    public var killed    : Boolean;

    private var currentMove;

    // MOVIECLIPS
    public var fruit : MovieClip;

    public static function New( parent:MovieClip ) : Sprite
    {
        var depth : Number = parent.getNextHighestDepth();
        return Sprite( parent.attachMovie("mcBandas", "Bandas"+depth, depth) );
    }
    
    private function Sprite()
    {
        super();
        id = undefined;
        killed = false;
        currentMove = null;
    }

    public function init()
    {
        this.fruit.beret.gotoAndStop(team+1);
        this.gotoAndStop(this.skin+1);
        this.moveList = new Array();


        /* DEFAULT DANCE
           if( this.danceList == undefined ){
           this.danceList = [2,2,2,2,4,8,12,13,14];
           }
        //*/
        this.danceIndex = -1;
        //this.gotoNext();
        this.fruit.stop();
    }

    public function setTeam(team:Number) : Void 
    {
        this.team = team;
        this.fruit.beret.gotoAndStop(team+1);
    }

    public function updatePos()
    {
        this._x = this.x;
        this._y = this.y;
    }

    public function petrify(c:Coordinate)
    {
        this.fruit.gotoAndPlay("stone");
    }

    public function onMove(origin:Coordinate, aDirection:Direction): Void
    {
        this.playDirAnim(origin, aDirection, "jump" )
    }

    public function onPushed(origin:Coordinate, aDirection:Direction) : Void
    {
        this.playDirAnim(origin, aDirection, "push" )
    }

    public function playDirAnim(origin:Coordinate, aDirection:Direction, anim:String) : Void
    {
        var target : Coordinate = origin.copy();
        target.move(aDirection);
        var realCoordinate : Coordinate = Main.gameUI.board.getBandasRealCoordinate(target);
        var d = aDirection.toNumber();
        if ( d == 3 ){
            this._xscale = -100;
            d = 1;
        }
        else {
            this._xscale = 100;
        }
        this.flCompleted = false;
        // Main.pushAnimation(this);
        this.moveList.push( { anim:anim+d, wait:random(3), afterWait:20 } );
        this.x = realCoordinate.x;
        this.y = realCoordinate.y;
    }    

    public function gotoNext()
    {
        if ( this.moveList.length>0 ) {
            //Main.debug("this.fruit.gotoAndPlay(this.moveList.shift())"+this.moveList[0]+")")
            //this.fruit.gotoAndPlay(this.moveList.shift())
        }
        else if ( this.danceList.length>0 ) {
            this.danceIndex = (this.danceIndex+1)%this.danceList.length;
            var d = this.danceList[this.danceIndex];
            if ( Math.round(d/2) == d/2 ) {
                this._xscale = 100;
            } 
            else {
                this._xscale = -100;
                d++;
            }	
            this.fruit.gotoAndPlay("danse"+d)
        }
        this.fruit.gotoAndStop("base")
    }   

    public function update() : Boolean
    {
        this.flCompleted = false;
        if (this.currentMove != null) {
            this.currentMove.afterWait--;
            if (this.currentMove.afterWait <= 0) {
                this.currentMove = null;
            }
        }
        else if (this.moveList.length > 0) {
            var move = this.moveList[0];
            if (move.wait<0){
                this.fruit.gotoAndPlay(move.anim);
                this.moveList.shift();
                if (killed) this.currentMove = move;
            }
            else {
                move.wait--;
            }
        }
        else if (this.killed) {
            this.flCompleted = true;
            this.fruit.gotoAndPlay("fall");
        }
        else {
            this.flCompleted = true;
        }
        return !this.flCompleted;
    }

    public function onStoned(origin:Coordinate, aDirection:Direction) : Void
    {
        this.playDirAnim(origin, aDirection, "stone");
    }
    
    public function onDestroyed(origin:Coordinate, aDirection:Direction) : Void
    {
        // TODO: create destroyed (fall) animation
        this.killed = true;
        this.flCompleted = false;
    }

    public function onHitByVachette(origin:Coordinate, aDirection:Direction) : Void
    {
        // TODO: create fly animation
        this.killed = true;
        this.flCompleted = false;
    }

    public function playFly(d:Direction)
    {
        if (d == Direction.Left) this._xscale = -100;
        this.fruit.gotoAndPlay("push1");
    }

    public function kill() : Void
    {
        this.removeMovieClip();
    }

    public function toString() : String
    {
        return "Sprite";
    }

    /*
    public function onRelease() : Void
    {
        trace("depth of the sprite is "+getDepth());
    }
    */
}

