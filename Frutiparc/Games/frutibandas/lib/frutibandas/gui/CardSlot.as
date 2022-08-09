// 
// $Id: CardSlot.as,v 1.8 2004/02/25 13:03:59  Exp $
// 

import frutibandas.Main;
import frutibandas.Direction;
import frutibandas.Coordinate;

import frutibandas.gui.Target;

class frutibandas.gui.CardSlot extends MovieClip 
{
    // CONSTANTES
    public static var WIDTH  : Number = 62;
    public static var HEIGHT : Number = 82;

    // PARAMETRES
    public var slotId:Number;

    // VARIABLES
    public var flActive:Boolean;
    public var flCard:Boolean;

    public  var cardId:Number;
    private var hiden : Boolean;

    // REFERENCES
    public var interfacePlayer : frutibandas.gui.PlayerInfo;

    // MOVIECLIP
    public var card1:MovieClip;
    public var card2:MovieClip;


    function CardSlot(){
        this.hiden  = false;
        this.cardId = null;
        this.init();
    }

    function init(){
        this.flActive=true;
        this.stop();
    }

    function onPress() 
    {
        if (!hiden && this.cardId != null && !Main.inputLocked) 
            Main.gameUI.initCardPlay(this.cardId);

        // debug mode, use TestManager to choose a card for the oponent
        if (hiden  && Main.StandaloneDebug) {
            if (Main.game.phase == frutibandas.Game.PHASE_CARD_SELECTION) {
                Main.manager.chooseCard(this.cardId);
            }
            else {
                var target : Target = Target.New(Main.gameUI);
                target.setCard( frutibandas.Card.New(this.cardId) );
                target.setValidationCallback( new frutibandas.Callback(this, _testTargetValidated) );
            }
        }
    }

    function _testTargetValidated(target:frutibandas.gui.Target)
    {
        this.interfacePlayer.rollOutCard(this.slotId);	

        var logicCoord : Coordinate = Main.gameUI.board.toLogicCoordinate(target.getCoordinate());

        var xml = XMLNode( new XML() );
        xml.nodeName = "c";
        xml.attributes.e = string( 1- Main.game.team );
        xml.attributes.c = string( this.cardId );
        xml.attributes.x = string( logicCoord.x );
        xml.attributes.y = string( logicCoord.y );
        xml.attributes.d = string( Direction.BadDirection.toNumber() );

        Main.manager.onCardPlayed(xml);
    }

    function onRollOver() 
    {
        if (!hiden && this.cardId != null) 
            this.interfacePlayer.rollOverCard(this.cardId);
    }

    function onRollOut() 
    {
        if (!hiden && this.cardId != null)
            this.interfacePlayer.rollOutCard(this.slotId);	
    }

    function active(){
        this.flActive = true;
    }

    function deActive(){
        this.flActive = false;
    }

    function setCard(cardId){
        if(!this.flActive)this.active();
        this.flCard = true;
        this.cardId = cardId;
        this.gotoAndStop("card");
        this.updateCard();
        this.card1.gotoAndStop(this.cardId+10);
    }

    function hide()
    {
        this.hiden = true;
        this.gotoAndStop(9);
    }

    function removeCard(){
        this.gotoAndStop("empty");
        this.flCard = false;
    }

    function updateCard(){
        this.card1.gotoAndStop(this.cardId+1);
    }

    function played()
    {
    }

    function turned()
    {
        this.gotoAndPlay("turn");
        this.setCard(this.cardId);
    }

    function turnCard(cardId){
        if(!this.flCard){
            this.cardId = 0;
            this.updateCard();
            this.flCard = true;
        }
        this.cardId = cardId;
        this.gotoAndPlay("turn");
    }

    function vanish()
    {
        this.gotoAndPlay("vanish");
    }

    function kill()
    {
        this.removeMovieClip();
    }
}
//EOF
