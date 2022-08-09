// 
// Copyright (c) 2004 Motion-Twin
//
// $Id: Game.as,v 1.36 2004/05/17 16:12:42  Exp $
// 

import frutibandas.*;

/**
 * Game controller.
 *
 * This object makes the glue between gui actions, xml manager and board.
 */
class frutibandas.Game 
{   
    public static var PHASE_CARD_SELECTION = 1;
    public static var PHASE_MOVE           = 2;

    public static var END_VICTORY = 0;
    public static var END_ABANDON = 1;
    public static var END_TIMEOUT = 2;
    public static var END_DISCO   = 3;
    public static var END_DRAW    = -2;
    
    // PUBLIC VARS
    // ----------------------------------------------------------------------
    
    /** The game identifier. */
    public var id : String;
    
    /** Player team id. */
    public var team : Number;
    
    /** Game players' names. */
    public var players : Array;

    /** Players frutibouilles. */
    public var frutibouilles : Array;

    /** Remaining times per team. */
    public var times : Array;

    public var skins : Array;
    
    /** Current team which have to play. */
    public var currentTeam : Number;
    
    /** Board object. */
    public var board : frutibandas.Board;
    
    /** Allowed play time per team. */
    public var time : Number;
  
    /** Game phase. */
    public var phase : Number;
        
    // PRIVATE VARS
    // ----------------------------------------------------------------------
    
    /** List of cards in the pool. */
    private var cardPool : frutibandas.CardPool;
    public  var cards : Array;

    /** Last update time */
    private var lastTime : Number;
   
    private var timeoutDetected : Boolean;
    
    /** Ended flag. */
    private var ended  : Boolean;

    /** End reason. */
    private var endReason : Number;
    
    /** Winner name. */
    private var winner : String;
    private var winnerTeam : Number;

    // PRIVATE FOR CARDS
    // ----------------------------------------------------------------------
    
    /** next solo activate */
    private var nextSolo : Coordinate;
    private var celeritePlayed : Boolean;
    private var lastHidenCard  : Number;
    private var lastHidenTurn  : Number;
    
    // ----------------------------------------------------------------------
    // METHODS
    // ----------------------------------------------------------------------
    
    /** Constructor. */
    public function Game( description:XMLNode ) 
    { 
        this.id          = null;
        this.time        = undefined;
        this.team        = undefined;
        this.board       = null;
        this.winner      = null;
        this.ended       = false;
        this.endReason   = END_VICTORY;
        this.currentTeam = undefined;
        this.lastTime    = getTimer();
        this.timeoutDetected = false;
        this.players       = new Array();
        this.frutibouilles = new Array();
        this.times         = new Array();
        this.skins         = new Array();
        this.nextSolo    = null;
        this.cardPool    = null;
        this.celeritePlayed = false;
        this.phase       = PHASE_CARD_SELECTION;
        this.cards       = new Array();
        this.cards[0]    = new Array();
        this.cards[1]    = new Array();
        this.initializeWithXml(description);
        this.lastHidenCard = -1;
        this.lastHidenTurn = -1;
    } 
    
    public function isRunning() : Boolean 
    { 
        return !this.ended;
    } 
    
    public function getBoard() : frutibandas.Board 
    { 
        return this.board; 
    } 

    /** Retrieve the team number of specified player. */
    public function getTeamOf( player:String ) : Number
    { 
        for (var i=0; i<players.length; ++i) {
            if (players[i] == player) 
                return i;
        }
        return -1;
    } 

    /** Retrieve team player name. */
    public function getNameOf( team:Number ) : String 
    { 
        return this.players[team];
    } 
    
    public function getWinnerTeam() : Number
    { 
        return this.winnerTeam;
    } 
    
    public function getWinner() : String
    { 
        return this.winner;
    } 

    public function getPool() : frutibandas.CardPool
    { 
        return this.cardPool;
    } 
    
    public function processTime() : Void
    { 
        var currentTime : Number = getTimer();
        var elapsed     : Number = currentTime - this.lastTime;
        if (elapsed <= 0) return;
        this.times[ this.currentTeam ] -= elapsed;
        if (this.times[ this.currentTeam ] <= 0 && !timeoutDetected) {
            this.times[ this.currentTeam ] = 0;
            this.timeoutDetected = true;
            Main.manager.checkTimeout();
        }
        this.lastTime = currentTime;
    } 
    
    public function toString() : String
    { 
        var result : String = "";
        result += "----- Game n�" + id + " ----- \n";
        result += "team        = " + team        + "\n";
        result += "time        = " + time        + "\n";
        result += "currentTeam = " + currentTeam + "\n";
        for (var i =0; i<times.length; i++) {
            result += "player "+i+" is "+players[i]+"\n";
        }
        for (var i =0; i<times.length; i++) {
            result += "time of "+i+" is "+times[i]+"\n";
        }
        result += "board -------- \n" + board.toString() + "\n";
        result += "----- EOGame ---------------- \n";
        return result;
    } 
    
    
    // ----------------------------------------------------------------------
    // METHODS RESERVED TO MANAGER
    // ----------------------------------------------------------------------

    /** Write a new message in the chat interface. */
    public function newMessage( src:String, msg:String ) : Void
    { 
        Main.gameUI.newMessage(src, msg);
    } 

    public function end( winnerTeam:Number, reason:Number ) : Void
    { 
        this.winnerTeam = winnerTeam;
        if (reason == undefined) {
            this.endReason = END_VICTORY;
        }
        if (winnerTeam < 0 || winnerTeam > 1) {
            this.winner = "La Vachette"; 
            Main.fruticard.newDraw( Main.gameMode );
        } else {
            this.winner = this.players[winnerTeam];
            if (winnerTeam == Main.game.team) {
                Main.fruticard.newVictory( Main.gameMode );
            }
            else {
                Main.fruticard.newDefeat( Main.gameMode );
            }
        }
        this.ended  = true;
        Main.gameUI.onEnded();
    } 

    public function cardSelected( teamNumber:Number, 
                                  cardID:Number, 
                                  enterMovePhase:Boolean) : Void
    { 
        // Main.logMessage( getNameOf(teamNumber) + Texts.CHOSE_A_CARD, teamNumber);

        this.cardPool.remove(cardID);
        this.cards[teamNumber].push(cardID);

        if (enterMovePhase) {
            this.phase = PHASE_MOVE;
            Main.gameUI.hideDraftCards();
            Main.gameUI.showPlayersCards( this.cards );
        }
    } 
    
    public function move( teamNumber:Number, direction:Direction ) : Void
    { 
        Main.gameUI.board.onMoveBegin();
        if (this.nextSolo != null) {
            board.moveSprite(this.nextSolo, direction);
            this.nextSolo = null;
        }
        else {
            board.move(teamNumber, direction);
        }
        board.removeEmptyBorders();
        // frutibandas.Main.debug(board.toString());
        // Main.logMessage( players[teamNumber] 
        //                + Texts.MOVED_BANDAS 
        //                + direction.toLogString()
        //                , teamNumber );
        Main.gameUI.board.onMoveDone();
    } 
    
    public function playCard( teamNumber:Number, 
                              id:Number, 
                              coord:Coordinate,
                              direction:Direction, 
                              param:Number, 
                              hiden:Boolean ) : Void
    { 
        Main.debug("Card played "+id+" coord="+coord);

        if (id == frutibandas.Card.CELERITE) { 
            this.celeritePlayed = true; 
        }
        
        var card : frutibandas.Card = frutibandas.Card.New(id);
        card.hiden = hiden;
     
        
        // specific case for piege card (uggly uggly)
        if ((id == Card.PIEGE) && (board.getElement(coord) == Board.TRAPPED)) {
            Main.gameUI.board.onTrapDiscovered(coord);
            return;
        }
        
        // no special case if it is the oponent who played the card
        if (teamNumber != team) {
            Main.gameUI.board.onMoveBegin();
            Main.gameUI.onCardPlayed(teamNumber, id, false);
            card.execute(this, teamNumber, coord, direction, param);
            Main.gameUI.board.onMoveDone();
            return;
        }
        
        var alreadyDestroyed : Boolean = false;
        // That is our special hidden case
        if (id == frutibandas.Card.PIEGE ||
            id == frutibandas.Card.DESORDRE ||
            id == frutibandas.Card.CONFISCATION) {
            alreadyDestroyed = (!hiden);
        }
        
        Main.gameUI.board.onMoveBegin();
        Main.gameUI.onCardPlayed(teamNumber, id, alreadyDestroyed); // lastHidenCard == id));
        card.execute(this, teamNumber, coord, direction, param);
        Main.gameUI.board.onMoveDone();

        /*
        if (hiden) {
            lastHidenCard = id;
            lastHidenTurn = currentTeam;
        }
        else {
            lastHidenCard = -1;
            lastHidenTurn = -1;
        }
        */
    } 

    public function turn( turnNumber:Number ) : Void
    { 
        if (lastHidenTurn == turnNumber) { 
            lastHidenCard = -1; 
            lastHidenTurn = -1;
        }
        
        this.currentTeam = turnNumber;

        Main.gameUI.onTurnChanged( turnNumber );
        
        var ourTurn : Boolean = (this.team == this.currentTeam);

        if (this.phase == PHASE_CARD_SELECTION) {    
            Main.gameUI.showDraftCards( this.cardPool, ourTurn);
        }
        else if (ourTurn) {
            if (celeritePlayed)
                Main.logMessage(Texts.CELERITE_YOUR_T);
            // else
            //    Main.logMessage(Texts.YOUR_TURN);
            celeritePlayed = false;
        }
        else if (celeritePlayed) {
            Main.logMessage(Texts.CELERITE_OPON_T);
            celeritePlayed = false;
        }
            
    } 

    
    // ----------------------------------------------------------------------
    // METHODS RESERVED TO CARDS
    // ----------------------------------------------------------------------
    
    public function setNextSolo( team:Number, c:Coordinate ) : Void
    { 
        this.nextSolo = c;
    } 
    
    
    // ----------------------------------------------------------------------
    // METHODS RESERVED TO GUI
    //----------------------------------------------------------------------
    
    public function requestChooseCard( id:Number ) : Void
    { 
        Main.manager.chooseCard(id);
    } 
    
    public function requestMove( d:Direction ) : Void
    { 
        if (ended) {
            return;
        }
        if (currentTeam == team) {
			Main.manager.move(d);
        }
        else {
            Main.debug("Game.requestMove() called but not our turn, "
                      +"turn is : "+currentTeam);
        }
    } 
    
    public function requestPlayCard( id:Number, coord:Coordinate ) : Void    
    { 
        Main.manager.playCard(id, coord, Direction.BadDirection);
    } 
    
    // ----------------------------------------------------------------------
    // PRIVATE METHODS
    // ----------------------------------------------------------------------
    
    private function initializeWithXml( description:XMLNode ) : Void
    { 
        this.cardPool = new frutibandas.CardPool( description.attributes.c );
        this.id            = description.attributes.g;
        this.currentTeam   = parseInt(description.attributes.t);
        this.time          = parseInt(description.attributes.i);
       
        // parse players node until board one
        var node : XMLNode = description.firstChild;
        while (node.nodeName != "b") {
            this.addPlayerFromXml(node);
            node = node.nextSibling;
        }        

        this.board  = Board.newBoardFromXml(node);

        if (description.attributes.p != undefined) {
            this.phase = parseInt(description.attributes.p);
        }

        this.cardPool = new frutibandas.CardPool( description.attributes.c );
    } 

    private function addPlayerFromXml( node:XMLNode ) : Void
    { 
        this.skins.push( this.players.length ); // TODO
        this.players.push( node.attributes.u );
        this.times.push( node.attributes.i );
        // this.times.push( this.time );
        if (node.attributes.u == Main.userLogin) {
            this.team = (this.players.length -1);
        }

        // on resume, the list of selected cards for each player is provided
        if (node.attributes.c != undefined) {
            var playerCards : Array = node.attributes.c.split(":");
            for (var i=0; i<playerCards.length; i++) {
                cardSelected( this.players.length - 1, parseInt(playerCards[i]), false );
            }
        }

        this.frutibouilles.push( node.attributes.fb );
    } 
}
//EOF
