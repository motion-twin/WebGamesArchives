// 
// Copyright (c) 2004 Motion-Twin
//
// $Id: Manager.as,v 1.53 2004/06/24 11:43:43  Exp $
// 
import frusion.client.MultiManager;
import frusion.client.FrusionClient;

import frutibandas.Main;
import frutibandas.Texts;
import frutibandas.Direction;
import frutibandas.Coordinate;
import frutibandas.CreateParameters;
import frutibandas.NetworkController;

/**
 * Implementation of the frusion multiplayer manager.
 */
class frutibandas.Manager extends frusion.client.MultiManager
{
    private var _rootMovie      : MovieClip;
    private var _debugBox       : box.Debug;
    private var _network        : NetworkController;

    /* The joinRoom() method sparadra */
    private var joinRoomCalled : Boolean;
    
    /** Manager constructor. */
    public function Manager( rootMovie : MovieClip ) 
    {
        super(undefined);
        _debugBox       = null;
        _network        = null;
        _rootMovie      = rootMovie;
        this.frusionClient  = null;
        this.joinRoomCalled = false;

        // this.initDebugBox();
        
        this.debug = Main.debug;
    }

    /** Create the _network controller and list rooms. */
    public function onCbkIdentFinished() : Void 
    {
        _network = new NetworkController(this, frusionClient);
        Main.userLogin = this.frusionClient.getUserName();
        
        if (Main.userLogin == "yota") {
            this.initDebugBox();
        }

        Main.fruticard = new frutibandas.FruticardSlot( this.frusionClient );
        this.listRooms();
    }


    // ----------------------------------------------------------------------
    // Room commands 
    // ----------------------------------------------------------------------
    
    public function listRooms() : Void 
    {
        _network.listRooms( this.getDiscID() );
    }
    
    public function listGames() : Void 
    {
        _network.listGames();
    }
    
    public function listPlayers() : Void 
    {
        _network.listPlayers();
    }
    
    public function joinRoom( id : String ) : Void 
    {
        if (this.joinRoomCalled) {
            return;
        }
        this.joinRoomCalled = true;
        _network.joinRoom(id, this.getDiscID());
    }
    
    public function sendMessage( msg : String ) : Void 
    {
        _network.sendRoom(msg);
    }

    public function joinGame( gameID : String ) : Void
    {
        _network.joinGame(gameID);
    }

    public function createGame( data ) : Void 
    {

        var parameters : CreateParameters = new CreateParameters();
        parameters.init( data.time.value, data.size.value, data.card.value );
        
        _network.createGame(parameters);
    }

    public function challengePlayer( playerID:String ) : Void 
    {
        _network.challengePlayer(playerID);
    }
    
    public function getChallengerInfo( playerID:String ) : Void 
    {
        _network.getChallengerInfo(playerID);
    }
    
    public function leaveGame() : Void
    {
        _network.partGame();
    }
    
    
    // ----------------------------------------------------------------------
    // In game commands 
    // ----------------------------------------------------------------------

    public function startGame() : Void 
    {
        _network.startGame();
    }
    
    public function sendGame( msg:String ) : Void
    {
        _network.sendGame(msg);
    }

    public function chooseCard(id:Number) : Void
    {
        _network.chooseCard(id);
    }
    
    public function move(d:Direction) : Void
    {
        _network.move(d);
    }

    public function playCard(id:Number, c:Coordinate, d:Direction) : Void
    {
        _network.playCard(id, c, d);
    }
    
    public function quit() : Void 
    {
        if (Main.gameMode != Main.CHALLENGE_MODE) {
            _network.partGame();
        }
        Main.reset();
        _rootMovie.mediator.reloadFrutiConnect();
    }
    
    public function abandon() : Void 
    {
        _network.abandon();
        if (Main.gameMode == Main.CHALLENGE_MODE) {
            hardReboot();
        }
    }
   
    public function checkTimeout() : Void
    { 
        _network.checkTimeout();
    } 

    public function kickFromGame( slotId:Number ) : Void
    {
        _network.kick(slotId);
    }
    
    
    // ----------------------------------------------------------------------
    // Response to room commands 
    // ----------------------------------------------------------------------
   
    public function onCmdJoinRoom(xml:XMLNode) : Void
    {
        this.joinRoomCalled = false;
        if (_network.hasError(xml)) { return; }

        Main.gameMode = parseInt(xml.attributes.m);
        super.peepShow( xml.attributes.rm, Main.gameMode );
        this.listGames();
    }
   

    // ----------------------------------------------------------------------
    // In game callbacks 
    // ----------------------------------------------------------------------

    public function onGameStarted(description:XMLNode) : Void 
    {
        if (description.firstChild != undefined) {
            this.hideUI();
        
            var game : frutibandas.Game = new frutibandas.Game(description);
            Main.start(game);

            this.frusionClient.registerStartGame();
            super.gameStarted();
        }
        else {
            super.onCbkGameStarted( description.attributes.g );
        }
    }
    
    public function onAbandon() : Void 
    {
        this.quit();
    }
    
    public function onPlayerAbandonned(userID:String) : Void 
    {
        // Main.logMessage( userID + Texts.ABANDONED_GAME );
    }

    public function onCardChosen(xml:XMLNode) : Void
    {
        var team    : Number  = parseInt(xml.attributes.e);
        var id      : Number  = parseInt(xml.attributes.c);
        var eophase : Boolean = (xml.attributes.mp == "1");
        Main.game.cardSelected(team, id, eophase);
    }
    
    public function onMove(xml:XMLNode) : Void
    {
        var team      : Number = parseInt(xml.attributes.e);
        var direction : Number = parseInt(xml.attributes.d);
        Main.game.move(team, Direction.valueOf(direction));
    }

    public function onCardPlayed(xml:XMLNode) : Void
    {
        var team : Number = parseInt(xml.attributes.e);       // team
        var type : Number = parseInt(xml.attributes.c);       // card id
        var x    : Number = parseInt(xml.attributes.x);       // x coord
        var y    : Number = parseInt(xml.attributes.y);       // y coord
        var d    : Number = parseInt(xml.attributes.d);       // direction
        var p    : Number = parseInt(xml.attributes.p);       // parameter
        var h    : Boolean = (xml.attributes.h != undefined); // hiden notification
        Main.game.playCard(team, type, new Coordinate(x,y), Direction.valueOf(d), p, h);
    }
    
    public function onNextTurn(xml:XMLNode) : Void 
    {
        Main.game.turn(parseInt(xml.attributes.t));
    }

    public function onGameEnded(xml:XMLNode) : Void 
    {
        //if (xml.attributes.g == Main.game.id){
            Main.game.end(parseInt(xml.attributes.e));
        //}
    }
    
    public function onGameMessage(userID:String, msg:String) : Void 
    {
        Main.game.newMessage(userID, msg);
    }
   
    public function onCbkScoreModif( xml:XMLNode ) : Void
    {
        if (Main.gameMode == 2){ // league mode only
            Main.fruticard.setLeagueScore( parseInt(xml.attributes.s) );
        }
    }

    public function _onCbkPlayerLeftGame( xml:XMLNode ) : Void
    {
        if (Main.game && Main.game.id == xml.attributes.g && Main.game.isRunning()) {
            Main.debug("_onCbkPlayerLeftGame gameId="+xml.attributes.g);
            Main.logMessage( xml.attributes.u + Texts.DISCONNECTED );
        }
        super.onCbkPlayerLeftGame( xml.toString() );
    }

    public function _onCbkPlayerJoinedGame( xml:XMLNode ) : Void
    {
        if (Main.game && Main.game.id == xml.attributes.g && Main.game.isRunning()) {
            Main.debug("_onCbkPlayerJoinedGame gameId="+xml.attributes.g);
            Main.logMessage( xml.attributes.u + Texts.REJOINED );
        }
        super.onCbkPlayerJoinedGame(xml.toString());
    }
    
    // ----------------------------------------------------------------------
    // Frusion events 
    // ----------------------------------------------------------------------
    
    /** Frutiparc frusion pause. */
    public function onEventPause() : Void 
    {
        Main.pause = frusionClient.pauseStatus;
    }

    /** Frutiparc frusion close. */
    public function onEventClose() : Void 
    {
        this.frusionClient.closeService();
    }
    
    /** Frutiparc frusion reset. */
    public function onEventReset() : Void 
    {
    }
    
    // ----------------------------------------------------------------------
    // Big shot methods
    // ----------------------------------------------------------------------
    
    public function hardReboot() : Void
    { 
        this.frusionClient.closeService();
    } 

    // ----------------------------------------------------------------------
    // Debug and error methods 
    // ----------------------------------------------------------------------
    
    private function initDebugBox() : Void
    {
        _debugBox = new box.Debug();
        _debugBox.setTitle("FrutiBandas");
        _global.desktop.addBox(_debugBox);
        _debugBox.putInTab(null);
        this.debugMessage("---- debug box for frutibandas manager ----");
    }

    /** Trace a debug message. */
    public function debugMessage(msg : String)
    {
        trace(msg);
        _debugBox.addText( FEString.unHTML(msg) );
    }

    /** An error occured, write the specified user information message. */
    public function errorMessage(str:String) : Void 
    {
        debugMessage("ERROR MESSAGE : "+str);
        this.displayError(str, null);
        Main.gameUI.writeLog( "ERREUR: "+str );
    }
}

//EOF

