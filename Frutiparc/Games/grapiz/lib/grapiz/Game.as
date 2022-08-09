//
// $Id: Game.as,v 1.12 2004/05/06 11:10:53  Exp $
//

import grapiz.Coordinate;
import grapiz.Direction;
import grapiz.Main;

class grapiz.Game 
{
    private var id          : String;
    private var time        : Number;
    private var team        : Number;
    private var board       : grapiz.Board;
    private var currentTurn : Number;
    private var winner      : Number;

    private var times         : Array;
    private var players       : Array;
    private var frutibouilles : Array;
    private var scores        : Array;

    private var ended         : Boolean;

    private var listener      : grapiz.GameListener;

    private var timeoutDetected : Boolean;

    private var lastTimerUpdate : Number;

    public function Game( description : XMLNode )
    {
        this.times = new Array();
        this.scores = new Array();
        this.players = new Array();
        this.frutibouilles = new Array();
        this.timeoutDetected = false;

        this.ended           = false;
        this.id              = description.attributes.g;
        this.time            = parseInt( description.attributes.i );
        this.currentTurn     = parseInt( description.attributes.t );
        this.lastTimerUpdate = getTimer();

        if (this.time == undefined) {
            throw new Error("grapiz.Game() Unable to create game from xml, malformed xml : \n"+description);
        }

        for (var i=0; i<description.childNodes.length; i++) {
            var node : XMLNode = description.childNodes[i];
            switch (node.nodeName) {
                case "b":
                {
                    this.board = new grapiz.Board(node);
                    break;
                }

                case "u":
                {
                    Main.debug( "Player: " + node.toString() );
                    var name = node.attributes.u;
                    if (name == Main.userLogin) {
                        this.team = parseInt(node.attributes.e);
                    }
                    this.times.push( parseInt(node.attributes.i ) );
                    var score : Number = 0;
                    if (node.attributes.s != undefined) {
                        score = parseInt(node.attributes.s);
                    }
                    this.scores.push( score );
                    this.players.push( name );
                    this.frutibouilles.push( node.attributes.fb );
                    break;
                }
            }
        }
    }

    public function getId() : String
    {
        return id;
    }
    
    public function getGameTime() : Number
    {
        return time;
    }

    public function getCurrentTurn() : Number
    {
        return this.currentTurn;
    }

    public function getNumberOfTeams() : Number
    {
        return this.players.length;
    }

    public function setTeam( t:Number ) : Void
    {
        this.team = t;
    }

    public function getTeam() : Number
    {
        return this.team;
    }

    public function getFrutibouille( team:Number ) : String
    {
        return this.frutibouilles[team];
    }

    public function getScore( team:Number ) : Number
    {
        return this.scores[team];
    }

    public function getNameOf( team:Number ) : String
    {
        return this.players[team];
    }

    public function getRemainingTimeOf( team:Number ) : Number
    {
        return times[team];
    }

    public function setListener( l:grapiz.GameListener ) : Void
    {
        this.listener = l;
    }

    public function getBoard() : grapiz.Board 
    {
        return this.board; 
    }

    public function moveRequest( c:grapiz.Coordinate, d:grapiz.Direction ) : Void
    {
        grapiz.Main.manager.move(c, d);
    }

    public function isPlaying() : Boolean
    {
        return this.winner == undefined;
    }

    public function toString() : String
    {
        var r : String = "";
        r += " grapiz.Game n� "+id+"\n";
        r += "  -- time = "+time+"\n";
        r += "  -- team = "+team+"\n";
        r += "  -- turn = "+currentTurn+"\n";
        return r;
    }

    public function updateTimers() : Void
    {
        if (this.ended) return;
        var currentTime : Number = getTimer();
        var elapsed     : Number = currentTime - this.lastTimerUpdate;
        if (elapsed <= 0) return;

        this.times[ this.currentTurn ] -= elapsed;
        if (this.times[ this.currentTurn ] <= 0 && !timeoutDetected) {
            this.times[ this.currentTurn ] = 0; 
            this.timeoutDetected = true;
            Main.manager.checkTimeout();
        }
        this.lastTimerUpdate = currentTime;
    }

    // ------------------------------------------------------------------------
    // Methods reserved to manager.
    // ------------------------------------------------------------------------

    public function move( x:Number, y:Number, d:Number ) : Void
    {
        var c : Coordinate = new Coordinate(x, y);
        var di : Direction  = Direction.valueOf(d);
        this.board.move(c, di);
    }

    public function turn( t:Number ) : Void
    {
        this.currentTurn = t;
        Main.gameUI.onTurn(t);
    }

    public function end( winner:Number ) : Void
    {
        if (this.ended) return;
        this.ended = true;
        this.winner = winner;
        this.listener.onEnd( this.players[winner] );

        if (winner == team) {
            Main.fruticard.newVictory( Main.gameMode );
        }
        else {
            Main.fruticard.newDefeat( Main.gameMode );
        }
    }

    public function newMessage( userID : String, message:String ) : Void
    {
        this.listener.onMessage(userID, message);
    }
}
