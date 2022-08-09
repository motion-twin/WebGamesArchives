// 
// $Id: Card.as,v 1.8 2004/03/11 11:35:19  Exp $
//

import frutibandas.*;
import frutibandas.card.*;

class frutibandas.Card
{
    public static var ENCLUME       : Number =  0;
    public static var CELERITE      : Number =  1;
    public static var CONFISCATION  : Number =  2;
    public static var RENFORT       : Number =  3;
    public static var DESORDRE      : Number =  4;
    public static var PETRIFICATION : Number =  5;
    public static var VACHETTE      : Number =  6;
    public static var CONVERSION    : Number =  7;
    public static var CHARGE        : Number =  8;
    public static var ENTRACTE      : Number =  9;
    public static var SOLO          : Number = 10;
    public static var PIEGE         : Number = 11;
    
    public var id             : Number;
    public var name           : String;
    public var requiresTarget : Boolean;
    public var targetFreeSlot : Boolean;
    public var targetSprite   : Boolean;
    public var targetTeam     : Boolean;
    public var targetOponent  : Boolean;

    public var hiden          : Boolean;

    /** Static factory. */
    public static function New( id:Number ) : Card
    { //{{{
        switch (id) {
            case ENCLUME:       return new Enclume();
            case CELERITE:      return new Celerite();
            case CONFISCATION:  return new Confiscation();
            case RENFORT:       return new Renfort();
            case DESORDRE:      return new Desordre();
            case PETRIFICATION: return new Petrification();
            case VACHETTE:      return new Vachette();
            case CONVERSION:    return new Conversion();
            case CHARGE:        return new Charge();
            case ENTRACTE:      return new Entracte();
            case SOLO:          return new Solo();
            case PIEGE:         return new Piege();
            default:            throw new Error("Unknown card "+id);
        }
    } //}}}
    
    public function isValidTarget( c:Coordinate ) : Boolean
    { //{{{
        if (!this.requiresTarget) { 
            return true; 
        }

        if (!c.isValid()) {
            Main.logMessage(Texts.OUT_OF_BOARD);
            return false;
        }

        if (!Main.game.getBoard().isValid(c)) {
            Main.logMessage(Texts.INVALID_TARGET);
            return false;
        }
        
        var element : Number = Main.game.getBoard().getElement(c);

        if (this.targetFreeSlot) {
            if (element == Board.FREE) return true;
            Main.logMessage(Texts.REQUIRES_FREE_SLOT);
            return false;
        }
        
        if (this.targetSprite) {
            if (element <= Board.FREE) {
                Main.logMessage(Texts.REQUIRES_SPRITE);
                return false;
            }
            if (this.targetTeam && element != Main.game.team) {
                Main.logMessage(Texts.REQUIRES_OWN_SPRITE);
                return false;
            }
            if (this.targetOponent && element != 1 - Main.game.team) {
                Main.logMessage(Texts.REQUIRES_OPONENT_SP);
                return false;
            }
        }

        return true;
    } //}}}
    
    /** Each card must implement an execute method. */
    public function execute( game:Game, team:Number, c:Coordinate, d:Direction ) : Void
    { //{{{
        throw new Error("Card.execute() not implemented for card "+this.name);
    } //}}}

    private function Card()
    { //{{{
        this.id = -1;
        this.name = undefined;
        this.requiresTarget = false;
        this.targetSprite   = false;
        this.targetFreeSlot = false;
        this.targetTeam     = false;
        this.targetOponent  = false;
        this.hiden          = false;
    } //}}}
}

//EOF
