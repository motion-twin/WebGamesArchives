//
// $Id: NetworkController.as,v 1.15 2004/06/24 11:42:39  Exp $
// 
import frusion.client.FrusionClient;
import ext.util.Pair;

import grapiz.*;

/**
 * This class manages xml messages.
 */
class grapiz.NetworkController 
{
    private var _manager : Manager;
    private var _frusion : FrusionClient;
    private var _errors;
    private var _callbacks;
    private var _commands;

    /**
     * Constructor.
     */
    public function NetworkController( manager:Manager, frusion:FrusionClient)
    {
        _manager = manager;
        _frusion = frusion;
        _frusion.addListener(this);
        initializeProtocol();
    }


    // ----------------------------------------------------------------------
    // Commands 
    // ----------------------------------------------------------------------

    /**
     * Request to list existing room games.
     */
    public function listGames() : Void 
    {
        _frusion.sendCommand( _commands.listGames, null );
    }

    /**
     * Request to list existing rooms.
     */
    public function listRooms(discID:String) : Void
    {
        var params : Array = [ new Pair("d", discID) ];
        _frusion.sendCommand( _commands.listRooms, params );
    }

    /**
     * Request to list room players.
     */
    public function listPlayers() : Void
    {
        _frusion.sendCommand( _commands.listPlayers, null );
    }

    /**
     * Request to join a room.
     */
    public function joinRoom( id:String, discID:String ) : Void
    {
        var params : Array = new Array();
        params.push( new Pair("rm", id) );
        params.push( new Pair("d", discID) );
        _frusion.sendCommand( _commands.joinRoom, params );
    }

    /**
     * Request to send a message to current room.
     */
    public function sendRoom( str:String ) : Void
    {
        _frusion.sendCommandWithText( _commands.sendRoom, null, str );
    }

    /**
     * Request to send a message to current game.
     */
    public function sendGame( str:String ) : Void
    {
        this.debugMessage("NetworkController.sendGame() "+str);
        _frusion.sendCommandWithText( _commands.sendGame, null, str );
    }

    /**
     * Request to join specified game.
     */
    public function joinGame( id:String ) : Void
    {
        var params : Array = new Array();
        params.push( new Pair("g", id) );
        _frusion.sendCommand( _commands.joinGame, params );
    }

    /**
     * Leave current game.
     */
    public function partGame( ) : Void
    {
        _frusion.sendCommand(_commands.partGame, null);
    }

    /**
     * Request to create a new game with specified parameters.
     */
    public function createGame( gameParams:GameParameters ) : Void
    {
        var xmlParams : Array = new Array();
        xmlParams.push( new Pair("ps", gameParams.nbrPlayers) );
        xmlParams.push( new Pair("i",  gameParams.time) );
        xmlParams.push( new Pair("ty", gameParams.boardSize) );
        _frusion.sendCommand(_commands.createGame, xmlParams);
    }

    public function checkTimeout() : Void
    {
        _frusion.sendCommand(_commands.checkTimeout, null);
    }

    /**
     * Challenge a player.
     */
    public function challengePlayer( player:String ) : Void
    {
        var xmlP : Array = [new Pair("u", player)];
        _frusion.sendCommand(_commands.createGame, xmlP);
    }

    public function getChallengerInfo( pid:String ) : Void
    {
        var param : Array = [ new Pair("u", pid) ];
        _frusion.sendCommand(_commands.challengerInfo, param);
    }

    /**
     * Request to start current game.
     */
    public function startGame() : Void 
    {
        _frusion.sendCommand( _commands.startGame, null );
    }

    /**
     * Request to play a move in specified direction.
     */
    public function move( c:Coordinate, d:Direction ) : Void 
    {
        var params  : Array = new Array();
        params.push( new Pair("x", c.x) );
        params.push( new Pair("y", c.y) );
        params.push( new Pair("d", d.toNumber()) );
        _frusion.sendCommand( _commands.move, params );
    }

    /**
     * Request to abandon current game.
     */
    public function abandon() : Void 
    {
        _frusion.sendCommand( _commands.abandon, null );
    }

    /** Kick a user from current game. */
    public function kick( id:Number ) : Void
    {
        var params : Array = [ new Pair("si", string(id)) ];
        _frusion.sendCommand( _commands.kick, params );
    }

    // ----------------------------------------------------------------------
    // Command callbacks 
    // ----------------------------------------------------------------------

    /**
     * Return of room list.
     */
    public function onCmdListRooms( node:String ) : Void
    {
        this.debugMessage("List rooms response : " + node);

        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onCmdListRooms(node);
    }

    /**
     * Return of join room.
     */
    public function onCmdJoinRoom( node:String ) : Void
    {
        this.debugMessage("Join room response : " + node);

        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onCmdJoinRoom(xml);
    }

    /**
     * Return of list games.
     */
    public function onCmdListGames( node:String ) : Void 
    {
        this.debugMessage("List games response : " + node);

        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onCmdListGames(node);
    }

    /**
     * Return of list players.
     */
    public function onCmdListPlayers( node:String ) : Void
    {
        this.debugMessage("List players response : "+node);
        _manager.onCmdListPlayers(node);
    }

    /** 
     * Return of challenger information request. 
     */
    public function onCmdChallengerInfo( node:String ) : Void
    {
        var xml:XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onCmdChallengerInfo(node);
    }

    /**
     * Return of join game.
     */
    public function onCmdJoinGame( node:String ) : Void 
    {
        this.debugMessage("Join response : " + node);

        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onCmdJoinGame( node );
    }

    /**
     * Return of create game.
     */
    public function onCmdCreateGame( node:String ) : Void 
    {
        this.debugMessage("Create response : "+node);
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onCmdCreateGame( node, 2 );
    }

    /**
     * Return of start game.
     */
    public function onCmdStart( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        this.debugMessage("Start response : "+node);
    }

    /**
     * Return of card choose.
     */
    public function onCmdChooseCard( node:String ) : Void
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;
    }

    /**
     * Return of play move.
     */
    public function onCmdMove( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        this.debugMessage("Move response : "+node);
    }

    /**
     * Return of play card.
     */
    public function onCmdPlayCard( node:String ) : Void
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        this.debugMessage("PlayCard response : "+node);
    }

    /**
     * Return of abandon game.
     */
    public function onCmdAbandon( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        this.debugMessage("Abandon response : "+node);
        _manager.onAbandon();
    }


    // ----------------------------------------------------------------------
    // Regular callbacks ----------------------------------------------------
    // ----------------------------------------------------------------------

    /**
     * A message was post in the room.
     */
    public function onCbkRoomMessage( node:String ) : Void
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;
        _manager.onCbkReceiveMessage( node ); // xml.attributes.u, xml.firstChild.nodeValue );
    }

    public function onCbkPlayerJoinedRoom( node:String ) : Void
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;
        _manager.onCbkPlayerJoinedRoom(node);
    }

    public function onCbkPlayerLeftRoom( node:String ) : Void
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;
        _manager.onCbkPlayerLeftRoom(node);
    }

    public function onCbkResume( node:String ) : Void
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;
        _manager.onGameStarted( xml );
    }

    /**
     * A new game was created.
     */
    public function onCbkGameCreated( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onCbkGameCreated( xml.toString() );
    }

    /**
     * A game was started.
     */
    public function onCbkGameStarted( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onGameStarted( xml );
    }

    /**
     * A game was ended.
     */
    public function onCbkGameEnded( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onGameEnded( xml );
    }

    /**
     * A game was closed.
     */
    public function onCbkGameClosed( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onGameClosed( xml.attributes.g );
    }

    /**
     * A player joined current room.
     */
    public function onCbkPlayerJoinedGame( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        // _manager.onCbkPlayerJoinedGame(node);
        _manager._onCbkPlayerJoinedGame(xml);
    }

    /**
     * A player leaved current room.
     */
    public function onCbkPlayerLeftGame( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        // _manager.onCbkPlayerLeftGame(node);
        _manager._onCbkPlayerLeftGame(xml);
    }

    /**
     * New challenge launched.
     */
    public function onCbkNewChallenge( node:String ) : Void
    {
        // var xml : XMLNode = parseMessage(node);
        // if (hasError(xml)) return;
        _manager.onCbkNewChallenge(node);
    }

    public function onCbkNewRecord( node:String ) : Void
    {
        // var xml : XMLNode = parseMessage(node);
        // if (hasError(xml)) return;
        // _manager.onCbkNewRecord(node);
    }

    public function onCbkScoreModif( node:String ) : Void
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;
        _manager.onCbkScoreModif(xml);
    }

    // ----------------------------------------------------------------------
    // In game callbacks ----------------------------------------------------
    // ----------------------------------------------------------------------

    /**
     * A message was post in the game.
     */
    public function onCbkGameMessage( node:String ) : Void
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;
        _manager.onGameMessage(xml.attributes.u, xml.firstChild.nodeValue);
    }

    /**
     * A player abandonned current game.
     */
    public function onCbkPlayerAbandon( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onPlayerAbandonned( xml.attributes.e );
    }

    /**
     * A game move was played.
     */
    public function onCbkMove( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onMove(xml);
    }

    /**
     * Turn change for current game.
     */
    public function onCbkTurn( node:String ) : Void 
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;

        _manager.onNextTurn(xml);
    }

    /**
     * The user left the game with a part.
     */
    public function onCmdPart( node:String ) : Void
    {
        var xml : XMLNode = parseMessage(node);
        if (hasError(xml)) return;
        _manager.onPartGame();
    }

    // ----------------------------------------------------------------------
    // Utility methods ------------------------------------------------------
    // ----------------------------------------------------------------------

    /**
     * Parse xml string and return a clean xml node.
     */
    private function parseMessage( node:String ) : XMLNode
    {
        var xmlDoc : XML = new XML(node);
        return xmlDoc.firstChild;
    }

    /**
     * Returns true if xml node contains an error code, false otherwise.
     *
     * This method send the error message to manager.
     */
    private function hasError( node:XMLNode ) : Boolean
    {
        if (node.attributes.k != undefined) {
            this.debugMessage("Erreur "+node.attributes.k+" : " + getErrorMessage(node.attributes.k) );
            _manager.errorMessage( getErrorMessage(node.attributes.k) );
            return true;
        }
        return false;
    }

    /**
     * Retrieve error message bound to specified error code.
     */
    private function getErrorMessage( code:String ) : String
    {
        if (_errors[parseInt(code)] != undefined) {
            return _errors[parseInt(code)];
        }
        else {
            return "Erreur "+code;
        }
    }

    /**
     * Debug method.
     */
    private function debugMessage( str:String ) : Void
    {
        _manager.debugMessage(str);
    }


    private function initializeProtocol() : Void
    {
        // Callback list
        _callbacks = new Object(); // .newHash();
        _callbacks.fa = "onCmdListRooms";
        _callbacks.fb = "onCmdJoinRoom";
        _callbacks.ff = "onCmdListGames";
        _callbacks.fg = "onCmdListPlayers";
        _callbacks.fj = "onCmdJoinGame";
        _callbacks.fi = "onCmdCreateGame";
        _callbacks.fl = "onCmdStart";
        _callbacks.fz = "onCmdAbandon";
        _callbacks.gb = "onCmdChallengerInfo";
        _callbacks.fk = "onCmdPart";
        _callbacks.fd = "onCbkRoomMessage";
        _callbacks.fe = "onCbkGameMessage";
        _callbacks.ga = "onCbkGameCreated";
        _callbacks.fo = "onCbkGameStarted";
        _callbacks.fw = "onCbkGameEnded";
        _callbacks.fy = "onCbkGameClosed";
        _callbacks.fp = "onCbkPlayerJoinedGame";
        _callbacks.fq = "onCbkPlayerLeftGame"   ;
        _callbacks.fr = "onCbkPlayerJoinedRoom" ;
        _callbacks.fs = "onCbkPlayerLeftRoom";
        _callbacks.fu = "onCbkPlayerAbandon";
        _callbacks.fc = "onCbkMove";
        _callbacks.fv = "onCbkTurn";
        _callbacks.fx = "onCbkNewRecord";
        _callbacks.gc = "onCbkNewChallenge";
        _callbacks["ge"] = "onCbkKick";
        _callbacks.m = "onCbkScoreModif";
        _callbacks.r = "onCbkResume"; 

        _frusion.registerCallbackList( _callbacks );


        // Command list
        _commands = new Object(); // .newHash();
        _commands.listRooms      = "fa";
        _commands.joinRoom       = "fb";
        _commands.listGames      = "ff";
        _commands.listPlayers    = "fg";
        _commands.joinGame       = "fj";
        _commands.createGame     = "fi";
        _commands.startGame      = "fl";
        _commands.move           = "fc";
        _commands.abandon        = "fz";
        _commands.sendRoom       = "fd";
        _commands.sendGame       = "fe";
        _commands.partGame       = "fk";
        _commands.challengerInfo = "gb";
        _commands.checkTimeout   = "gd";
        _commands.kick           = "ge";


        // Error messages
        _errors = new Array();
        _errors[2000] = "Erreur d'identification";
        _errors[2001] = "Mauvais disque";
        _errors[2002] = "Disque non trouv�";
        _errors[2003] = "Le disque ne peu activer le mode de jeu choisi";
        _errors[2004] = "Vous n'�tes pas le possesseur de ce disque";
        _errors[2005] = "Salon de jeu inconnu";
        _errors[2006] = "Vous n'�tes pas sur un salon";
        _errors[2007] = "Vous n'�tes pas sur un salon ou la commande est inconnue";
        _errors[2008] = "Vous �tes d�j� sur un salon";
        _errors[2009] = "La partie n'existe plus";
        _errors[2010] = "Vous n'�tes pas sur une partie";
        _errors[2011] = "Vous n'�tes pas sur une partie ou la commande est inconnue";
        _errors[2012] = "Vous devez d'abord quitter la partie en cours";
        _errors[2013] = "Coordonn�es invalides";
        _errors[2014] = "Destination invalide";
        _errors[2015] = "Pas de jeton aux coordonn�es sp�cifi�es";
        _errors[2016] = "Le jeton choisi ne vous appartient pas";
        _errors[2017] = "Le jeton ne peut sauter par dessus de jetons adverses";
        _errors[2018] = "Le jeton ne peut �craser un jeton alli�";
        _errors[2019] = "Utilisateur inconnu ou d�connect�";
        _errors[2020] = "Vous d�fiez d�j� quelqu'un";
        _errors[2021] = "Quelqu'un vous a d�fi�";
        _errors[2022] = "L'adversaire vous a d�j� d�fi�";
        _errors[2023] = "Vous avez d�j� perdu contre cet adversaire";
        _errors[2024] = "Vous �tes d�j� dans la liste d'attente de l'aversaire";
        _errors[2025] = "Vous ne pouvez vous d�fier";
        _errors[2026] = "La partie a d�marr�";
        _errors[2027] = "La partie ne peut contenir plus de joueurs";
        _errors[2028] = "Il n'y a pas assez de joueurs pour d�marrer la partie";
        _errors[2029] = "Vous n'�tes pas le cr�ateur de la partie";
        _errors[2030] = "Erreur interne, slot-out-of-bound";
        _errors[2031] = "Le slot du cr�ateur ne peut �tre ferm�";
        _errors[2032] = "Une partie doit avoir au moins deux joueurs";
        _errors[2033] = "Vous ne jouez pas dans cette partie";
        _errors[2034] = "Les observateurs ne sont pas authoris�s dans cette partie";
        _errors[2035] = "Les observateurs ne peuvent parler dans cette partie";
        _errors[2036] = "Ce n'est pas votre tour";
        _errors[2037] = "Temps de jeu trop bas";
        _errors[2038] = "La partie new joue pas";
        _errors[2039] = "Taille de plateau trop grande";
        _errors[2040] = "Impossible de trouver un plateau de jeu pour ces param�tres";
        _errors[2041] = "Le challenge de la journ�e est termin�";
        _errors[2042] = "Salon de jeu non trouv�";
        _errors[2043] = "Votre frutidisc ne permet pas de rentrer sur ce salon";
        _errors[2044] = "Le salon de jeu est ferm�";
        _errors[2045] = "Gros mot d�tect�, vous �tes �ject� du jeu";
    }
}
