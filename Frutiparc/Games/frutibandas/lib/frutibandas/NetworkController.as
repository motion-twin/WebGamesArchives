// 
// Copyright (c) 2004 Motion-Twin
//
// $Id: NetworkController.as,v 1.32 2004/06/24 11:43:43  Exp $
// 
import frusion.client.FrusionClient;
import ext.util.Pair;

import frutibandas.*;

/**
 * This class manages xml messages.
 */
class frutibandas.NetworkController 
{
   private var _frusion : FrusionClient;
   private var _errors;
   private var _callbacks;
   private var _commands;
   private var _manager : Manager;

   /** Constructor. */
   public function NetworkController( manager:Manager, frusion:FrusionClient )
   {
      _manager = manager;
      _frusion = frusion;
      _frusion.addListener(this);
      initProtocol();
      _manager.debugMessage("here");
   }


   // ----------------------------------------------------------------------
   // Commands 
   // ----------------------------------------------------------------------

   /** Request to list existing room games. */
   public function listGames() : Void 
   {
      _frusion.sendCommand( _commands.listGames, null );
   }

   /** Request to list existing rooms. */
   public function listRooms(discID:String) : Void
   {
      var params : Array = [ new Pair("d", discID) ];
      _frusion.sendCommand( _commands.listRooms, params );
   }

   /** Request to list room players. */
   public function listPlayers() : Void
   {
      _frusion.sendCommand( _commands.listPlayers, null );
   }

   /** Request to join a room. */
   public function joinRoom( id:String, discID:String ) : Void
   {
      var params : Array = new Array();
      params.push( new Pair("rm", id) );
      params.push( new Pair("d", discID) );
      _frusion.sendCommand( _commands.joinRoom, params );
   }

   /** Request to send a message to current room. */
   public function sendRoom( str:String ) : Void
   {
      _frusion.sendCommandWithText( _commands.sendRoom, null, str );
   }

   /** Request to send a message to current game. */
   public function sendGame( str:String ) : Void
   {
      _frusion.sendCommandWithText( _commands.sendGame, null, str );
   }

   /** Request to join specified game. */
   public function joinGame( id:String ) : Void
   {
      var params : Array = new Array();
      params.push( new Pair("g", id) );
      _frusion.sendCommand( _commands.joinGame, params );
   }

   /** Leave current game. */
   public function partGame( ) : Void
   {
      _frusion.sendCommand(_commands.partGame, null);
   }

   /** Request to create a new game with specified parameters. */
   public function createGame( parms:CreateParameters ) : Void
   {
      var xmlParams : Array = new Array();
      xmlParams.push( new Pair("i", string(parms.time)) );
      xmlParams.push( new Pair("s", string(parms.size)) );
      xmlParams.push( new Pair("c", string(parms.card)) );
      _frusion.sendCommand(_commands.createGame, xmlParams);
   }

   /** Challenge specified player. */
   public function challengePlayer( pid:String ) : Void
   {
      var params : Array = [ new Pair("u", pid) ];
      _frusion.sendCommand(_commands.createGame, params);
   }

   /** Retrieve challenge information about specified player. */
   public function getChallengerInfo( pid:String ) : Void
   {
      var params : Array = [ new Pair("u", pid) ];
      _frusion.sendCommand(_commands.challengerInfos, params);
   }


   /** Request to start current game. */
   public function startGame() : Void 
   {
      _frusion.sendCommand( _commands.startGame, null );
   }

   /** 
    * Kick a user from current game. 
    *
    * @param id The user slot id
    */
   public function kick( id:Number ) : Void
   {
      var params : Array = [ new Pair("s", string(id)) ];
      _frusion.sendCommand(_commands.kick, params);
   }

   /** Choose card in draft mode. */
   public function chooseCard( id:Number ) : Void
   {
      var params : Array = [ new Pair("c", string(id)) ];
      _frusion.sendCommand( _commands.chooseCard, params );
   }

   /** Request to play a move in specified direction. */
   public function move( d:Direction ) : Void 
   {
      var params  : Array = [ new Pair("d", string(d.toNumber())) ];
      _frusion.sendCommand( _commands.move, params );
   }

   /** Request to play a card with specified parameters. */
   public function playCard( id:Number, c:Coordinate, d:Direction ) : Void
   {
      var params : Array = new Array();
      params.push( new Pair("c", id) );
      if (c != undefined) params.push( new Pair("x", c.x) );
      if (c != undefined) params.push( new Pair("y", c.y) );
      if (d != undefined) params.push( new Pair("d", d.toNumber()) );
      _frusion.sendCommand( _commands.playCard, params );
   }

   /** Request to abandon current game. */
   public function abandon() : Void 
   {
      _frusion.sendCommand( _commands.abandon, null );
   }

   /** Asks the server to check timeouts. */
   public function checkTimeout() : Void
   { 
      _frusion.sendCommand( _commands.checkTimeout, null );
   } 


   // ----------------------------------------------------------------------
   // Command callbacks 
   // ----------------------------------------------------------------------

   /** Return of room list. */
   public function onCmdListRooms( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
      _manager.onCmdListRooms(node);
   }

   /** Return of join room. */
   public function onCmdJoinRoom( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
      _manager.onCmdJoinRoom(xml);
   }

   /** Return of list games. */
   public function onCmdListGames( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
      _manager.onCmdListGames(node);
   }

   /** Return of list players. */
   public function onCmdListPlayers( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
      _manager.onCmdListPlayers(node);
   }

   /** Return of join game. */
   public function onCmdJoinGame( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
      _manager.onCmdJoinGame( node );
   }

   /** Return of create game. */
   public function onCmdCreateGame( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
      _manager.onCmdCreateGame( node, 2 );
   }

   /** Return of challengerInfos. */
   public function onCmdChallengerInfo( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
      _manager.onCmdChallengerInfo(node);
   }

   /** Return of start game. */
   public function onCmdStart( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
   }

   /** Return of card choose. */
   public function onCmdChooseCard( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
   }

   /** Return of play move. */
   public function onCmdMove( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
   }

   /** Return of play card. */
   public function onCmdPlayCard( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
   }

   /** Return of abandon game. */
   public function onCmdAbandon( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;
      _manager.onAbandon();
   }


   // ----------------------------------------------------------------------
   // Regular callbacks 
   // ----------------------------------------------------------------------

   /** A message was post in the room. */
   public function onCbkRoomMessage( node:String ) : Void
   {
      var xml = parseMessage(node);
      if (hasError(xml)) {
         _manager.debugMessage("onCbkRoomMessage:: error detected");
         return;
      }
      else {
         _manager.debugMessage("onCbkRoomMessage:: no error");
      } 

      _manager.onCbkReceiveMessage( node ); // xml.attributes.u, xml.firstChild.nodeValue );
   }

   /** A player joined the room. */
   public function onCbkPlayerJoinedRoom( node:String ) : Void
   {
      _manager.onCbkPlayerJoinedRoom( node );
   }

   /** A player left the room. */
   public function onCbkPlayerLeftRoom( node:String ) : Void
   {
      _manager.onCbkPlayerLeftRoom(node);
   }

   /** A new game was created. */
   public function onCbkGameCreated( node:String ) : Void 
   {
      _manager.onCbkGameCreated(node);
   }

   /** A game was started. */
   public function onCbkGameStarted( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      _manager.onGameStarted( xml );
   }

   /** A game was ended. */
   public function onCbkGameEnded( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      _manager.onGameEnded( xml );
   }

   /** A game was closed. */
   public function onCbkGameClosed( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      _manager.onCbkGameClosed( xml.attributes.g );
   }

   /** A player joined current room. */
   public function onCbkPlayerJoinedGame( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      _manager._onCbkPlayerJoinedGame( xml );
   }

   /** A player leaved current room. */
   public function onCbkPlayerLeftGame( node:String ) : Void 
   {
      var xml:XMLNode = parseMessage(node);
      if (hasError(xml)) return;

      _manager._onCbkPlayerLeftGame(xml);
   }

   /** New challenge record. */
   public function onCbkNewRecord( node:String ) : Void
   {
      // _manager.onCbkNewRector(node);
   }

   /** New challege created. */
   public function onCbkNewChallenge( node:String ) : Void
   {
      _manager.onCbkNewChallenge(node);
   }

   /** Rejoined a game after disconnection. */
   public function onCbkResume( node:String ) : Void
   {
      var xml:XMLNode = parseMessage(node);
      if (hasError(xml)) return;
      _manager.onGameStarted( xml );
   }


   // ----------------------------------------------------------------------
   // In game callbacks
   // ----------------------------------------------------------------------

   /** A message was post in the game. */
   public function onCbkGameMessage( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      if (hasError(xml)) return;

      _manager.onGameMessage(xml.attributes.u, xml.firstChild.nodeValue);
   }

   /** A player abandonned current game. */
   public function onCbkPlayerAbandon( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      _manager.onPlayerAbandonned( xml.attributes.e );
   }

   /** A player choosed a card. */
   public function onCbkCardChosen( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      _manager.onCardChosen(xml);
   }

   /** A game move was played. */
   public function onCbkMove( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      _manager.onMove(xml);
   }

   /** Turn change for current game. */
   public function onCbkTurn( node:String ) : Void 
   {
      var xml : XMLNode = parseMessage(node);
      _manager.onNextTurn(xml);
   }

   /** A card was played. */
   public function onCbkCardPlayed( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      _manager.onCardPlayed(xml);
   }

   /** Player timedout. */
   public function onCbkTimedOut( node:String ) : Void
   { 
   } 

   /** Score modified. */
   public function onCbkScoreModif( node:String ) : Void
   {
      var xml : XMLNode = parseMessage(node);
      _manager.onCbkScoreModif(xml);
   }

   // ----------------------------------------------------------------------
   // Utility methods 
   // ----------------------------------------------------------------------

   /** Parse xml string and return a clean xml node. */
   private function parseMessage( node:String ) : XMLNode
   {
      var xmlDoc : XML = new XML(node);
      var xml = xmlDoc.firstChild;
      return xml;
   }

   /** Returns true if xml node contains an error code */
   public function hasError( node:XMLNode ) : Boolean
   {
      if (node.attributes.k != undefined) {
         _manager.errorMessage( getErrorMessage(node.attributes.k) );
         return true;
      }
      return false;
   }

   /** Retrieve error message bound to specified error code. */
   private function getErrorMessage( code:String ) : String
   {
      if (_errors[parseInt(code)] != undefined) {
         return _errors[parseInt(code)];
      }
      else {
         return "Erreur "+code;
      }
   }

   /** Debug method. */
   private function debugMessage( str:String ) : Void
   {
      _manager.debugMessage(str);
   }

   /** Initialize game protocol. */
   private function initProtocol() : Void
   {   
      // Callback list
      _callbacks = new Object();
      _callbacks.onCmdListRooms   = "ga";
      _callbacks.onCmdJoinRoom    = "gb";
      _callbacks.onCmdListGames   = "gc";
      _callbacks.onCmdListPlayers = "gd";
      _callbacks.onCmdJoinGame    = "ge";
      _callbacks.onCmdCreateGame  = "gf";
      _callbacks.onCmdStart       = "gg";
      _callbacks.onCmdMove        = "gh";
      _callbacks.onCmdAbandon     = "gi";
      _callbacks.onCmdPlayCard    = "gw";
      _callbacks.onCmdChooseCard  = "fa";
      _callbacks.onCmdChallengerInfo = "fd";
      _callbacks.onCbkRoomMessage   = "gj";
      _callbacks.onCbkGameMessage   = "gk";
      _callbacks.onCbkGameCreated   = "gl";
      _callbacks.onCbkGameStarted   = "gm";
      _callbacks.onCbkGameEnded     = "gn";
      _callbacks.onCbkGameClosed    = "go";
      _callbacks.onCbkPlayerJoinedGame = "gp";
      _callbacks.onCbkPlayerLeftGame   = "gq";
      _callbacks.onCbkPlayerJoinedRoom = "gy";
      _callbacks.onCbkPlayerLeftRoom   = "gz";
      _callbacks.onCbkPlayerAbandon = "gr";
      _callbacks.onCbkMove          = "gs";
      _callbacks.onCbkCardPlayed    = "gx";
      _callbacks.onCbkTurn          = "gt";
      _callbacks.onCbkCardChosen    = "fb";
      _callbacks.onCbkNewRecord     = "ff";
      _callbacks.onCbkNewChallenge  = "fe";
      _callbacks.onCbkTimedOut      = "gv";
      _callbacks.onCbkKick          = "fh";
      _callbacks.onCbkScoreModif    = "m";
      _callbacks.onCbkResume        = "r";

      var inv = new Object();
      for (var i in _callbacks) {
         inv[ _callbacks[i] ] = i;
      }
      _frusion.registerCallbackList( inv );

      // Command list
      _commands = new Object();
      _commands.listRooms       = "ga";
      _commands.joinRoom        = "gb";
      _commands.listGames       = "gc";
      _commands.listPlayers     = "gd";
      _commands.joinGame        = "ge";
      _commands.createGame      = "gf";
      _commands.startGame       = "gg";
      _commands.move            = "gh";
      _commands.abandon         = "gi";
      _commands.sendRoom        = "gj";
      _commands.sendGame        = "gk";
      _commands.playCard        = "gw";
      _commands.chooseCard      = "fa";
      _commands.partGame        = "fc";
      _commands.challengerInfos = "fd";
      _commands.checkTimeout    = "fg";
      _commands.kick            = "fh";

      // Error messages
      _errors = new Array();
      _errors[1500] = "La partie n'est plus valide";
      _errors[1501] = "Vous n'�tes pas sur une partie";
      _errors[1502] = "Cette fonction est r�serv�e au cr�ateur de la partie";
      _errors[1503] = "La partie ne joue pas";
      _errors[1504] = "Vous ne jouez plus sur cette partie";
      _errors[1505] = "Il n'y a pas assez de joueurs pour commencer";
      _errors[1506] = "La partie a d�j� commenc�e";
      _errors[1507] = "La partie est en cours";
      _errors[1508] = "Vous �tes encore sur une partie";
      _errors[1509] = "La partie est pleine";
      _errors[1510] = "Ce n'est pas votre tour";
      _errors[1511] = "Impossible de rejoindre un salon de jeu inexistant";
      _errors[1512] = "Vous �tes d�j� sur un salon de jeu";
      _errors[1513] = "Vous avez rejoint la partie trop tard";
      _errors[1514] = "Le disque n'est pas trouv�";
      _errors[1515] = "Le disque ne vous appartient pas";
      _errors[1516] = "Le disque n'est pas valable pour ce jeu";
      _errors[1517] = "Vous ne pouvez jouer qu'une carte par tour";
      _errors[1518] = "La carte est mauvaise";
      _errors[1519] = "Phase de s�lection de carte pass�e";
      _errors[1520] = "Ce n'est pas encore la phase de mouvement";
      _errors[1521] = "Temps d�pass�";
      _errors[1522] = "Temps de partie invalide";
      _errors[1523] = "Taille de plateau invalide";
      _errors[1524] = "Utilisateur d�connect�";
      _errors[1525] = "Le challenge est termin�";
      _errors[1526] = "Vous ne pouvez vous d�fier";
      _errors[1527] = "Vous d�fiez d�j� un autre joueur";
      _errors[1528] = "Quelqu'un vous a d�fi�";
      _errors[1529] = "Ce joueur a d�j� gagn� contre vous et n'a pas perdu depuis";
      _errors[1530] = "Ce joueur viens juste de vous d�fier";
      _errors[1531] = "Votre FD ne permet pas d'acc�der � ce salon de jeu";
      _errors[1532] = "Le salon de jeu est ferm�";
      _errors[1536] = "Gros mot d�tect�, vous �tes �ject� du jeu";
   }
}
// EOF
