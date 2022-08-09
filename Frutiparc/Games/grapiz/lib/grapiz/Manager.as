// 
// Copyright (c) 2004 Motion-Twin
//
// $Id: Manager.as,v 1.19 2004/06/24 11:42:39  Exp $
// 
import frusion.client.MultiManager;
import frusion.client.FrusionClient;

import grapiz.Main;
import grapiz.Texts;
import grapiz.Direction;
import grapiz.Coordinate;
import grapiz.GameParameters;
import grapiz.NetworkController;

/**
 * Implementation of the frusion multiplayer manager.
 */
class grapiz.Manager extends frusion.client.MultiManager
{
    private var _debugBox       : box.Debug;
    private var _network        : NetworkController;
    private var _joinRoomCalled : Boolean;

    /** Manager constructor. */
    public function Manager() 
    {
        super(undefined);
        _debugBox          = null;
        _network           = null;
        _joinRoomCalled    = false;
        this.frusionClient = null;
        debug = Main.debug;
    }

    /** Create the _network controller and list rooms. */
    public function onCbkIdentFinished() : Void 
    {   
        _network   = new NetworkController(this, frusionClient);
        Main.userLogin = this.frusionClient.getUserName();
        Main.fruticard = new grapiz.FruticardSlot( this.frusionClient );
        this.listRooms();

        if (Main.userLogin == "yota") {
           this.initDebugBox();
        }
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
        if (this._joinRoomCalled) {
            return;
        }
        this._joinRoomCalled = true;
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
        var parameters : GameParameters = new GameParameters(data);
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

    public function checkTimeout() : Void
    {
        _network.checkTimeout();
    }
  
    public function kickFromGame( id:Number ) : Void
    {
        _network.kick(id);
    }

    
    // ----------------------------------------------------------------------
    // In game commands 
    // ----------------------------------------------------------------------

    public function leaveGame() : Void
    {
        _network.partGame();
    }
    
    public function startGame() : Void 
    {
        _network.startGame();
    }
    
    public function sendGame( msg:String ) : Void
    {
        _network.sendGame(msg);
    }
    
    public function move( c:Coordinate, d:Direction ) : Void
    {
        _network.move(c, d);
    }
    
    public function quit() : Void 
    {
        if (Main.gameMode != 1) {
            _network.partGame();
        }
        Main.reset(false);
        Main.rootMovie.mediator.reloadFrutiConnect();
    }
    
    public function abandon() : Void 
    {
        _network.abandon();
    }
   
    public function _onCbkPlayerLeftGame( xml:XMLNode )
    {
        if (Main.game) {
            if (Main.game.getId() != xml.attributes.g) {
                Main.debug("not our game game="+xml.attributes.g+" our game is "+Main.game.getId());
            }
            else if (!Main.game.isPlaying()) {
                Main.debug("game ended");
            }
        }
        if (Main.game && Main.game.getId() == xml.attributes.g && Main.game.isPlaying()) {
            Main.debug("_onCbkPlayerLeftGame gameId="+xml.attributes.g);
            Main.logMessage( xml.attributes.u + Texts.DISCONNECTED );
        }
        super.onCbkPlayerLeftGame(xml.toString());
    }

    public function _onCbkPlayerJoinedGame( xml:XMLNode )
    {
        if (Main.game && Main.game.getId() == xml.attributes.g && Main.game.isPlaying()) {
            Main.debug("_onCbkPlayerJoinedGame gameId="+xml.attributes.g);
            Main.logMessage( xml.attributes.u + Texts.REJOINED );
        }
        super.onCbkPlayerJoinedGame(xml.toString());
    }
    
    // ----------------------------------------------------------------------
    // Hard mehods
    // ----------------------------------------------------------------------
    
    /** Make the frusion eject its CD and leave the game. */
    public function hardReboot() : Void
    {
        this.frusionClient.closeService();
    }
    
    
    // ----------------------------------------------------------------------
    // Response to room commands 
    // ----------------------------------------------------------------------
    
    public function onCmdJoinRoom(xml:XMLNode) : Void
    {
        Main.gameMode = parseInt(xml.attributes.m);
        if (Main.gameMode == undefined || isNaN(Main.gameMode)) {
            this.errorMessage("Mode de jeu non r�cup�r�");
            return;
        }
        super.peepShow( xml.attributes.rm, Main.gameMode );
        this.listGames();
    }


    // ----------------------------------------------------------------------
    // Room callbacks 
    // ----------------------------------------------------------------------

    public function onGameClosed(gameID : String) : Void 
    {
    }

    
    // ----------------------------------------------------------------------
    // In game callbacks 
    // ----------------------------------------------------------------------

    public function onGameStarted(description:XMLNode) : Void 
    {
        if (description.firstChild != undefined) {
            this.hideUI();      
            try {
                var game : grapiz.Game = new grapiz.Game(description);
                Main.start(game);

                this.frusionClient.registerStartGame();
                super.gameStarted();
            }
            catch (e:Error) {
                Main.debug(e);
            }
        }
        else {
            super.onCbkGameStarted( description.attributes.g );
        }
    }
    
    public function onAbandon() : Void 
    {
        this.quit();
    }
    
    public function onPlayerAbandonned( userID:String ) : Void 
    {
        var playerName : String = Main.game.getNameOf(parseInt(userID));
        Main.logMessage( playerName + Texts.ABANDONED_GAME );
    }

    public function onMove( xml:XMLNode ) : Void
    {
        try {
            var team      : Number = parseInt(xml.attributes.e);
            var x         : Number = parseInt(xml.attributes.x);
            var y         : Number = parseInt(xml.attributes.y);
            var direction : Number = parseInt(xml.attributes.d);
            Main.game.move(x, y, direction);
        }
        catch (e) {
            this.debugMessage("Error: "+e);
        }
    }

    public function onNextTurn( xml:XMLNode ) : Void 
    {
        var team : Number = parseInt(xml.attributes.e);
        Main.game.turn(team);
    }

    public function onGameEnded( xml:XMLNode ) : Void 
    {
        //if (xml.attributes.g == Main.game.getId()) {
            var team : Number = parseInt(xml.attributes.e);
            Main.game.end(team);
        //}
    }
    
    public function onGameMessage( userID:String, msg:String ) : Void 
    {
        Main.game.newMessage(userID, msg);
    }
   
    public function onCbkScoreModif( xml:XMLNode ) : Void
    {
        if (Main.gameMode == Main.LEAGUE_MODE) { 
            Main.fruticard.setLeagueScore( parseInt(xml.attributes.s) );
        }
    }

    public function onPartGame( xml:XMLNode ) : Void
    {
    }
   
    
    // ----------------------------------------------------------------------
    // Frusion events 
    // ----------------------------------------------------------------------
    
    /** Frutiparc frusion pause. */
    public function onEventPause() : Void 
    {
        // Main.pause = frusionClient.pauseStatus;
    }

    /** Frutiparc frusion close. */
    public function onEventClose() : Void 
    {
        frusionClient.closeService();
    }
    
    /** Frutiparc frusion reset. */
    public function onEventReset() : Void 
    {
    }

    
    // ----------------------------------------------------------------------
    // Debug and error methods 
    // ----------------------------------------------------------------------
   
    /** Create debug box. */
    private function initDebugBox() : Void
    {
        _debugBox = new box.Debug();
        _debugBox.setTitle("Grapiz");
        _global.desktop.addBox( _debugBox );
        _debugBox.putInTab(null);
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
        super.displayError(str, null);
        Main.gameUI.writeLog( "ERREUR: " + str );
    }
}
