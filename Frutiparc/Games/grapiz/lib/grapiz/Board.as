// 
// $Id: Board.as,v 1.4 2004/04/05 17:24:27  Exp $
//

import grapiz.Coordinate;
import grapiz.Direction;
import grapiz.Token;
import grapiz.Main;

class grapiz.Board 
{
    private var tokens     : Array;
    private var size       : Number;
    private var lineLength : Number;
    
    public function Board( definition:XMLNode )
    { //{{{
        this.tokens = new Array();
        this.initWithXml(definition);
    } //}}}

    public function getSize() : Number 
    { //{{{
        return this.size; 
    } //}}}

    public function getTokens() : Array
    { //{{{
        return this.tokens;
    } //}}}
    
    public function getAt( c:Coordinate ) : Token 
    { //{{{
        var i : Number = this.coordinateToIndex(c);
        return this.tokens[i];
    } //}}}

    public function setAt( c:Coordinate, token:Token ) : Void 
    { //{{{
        var i : Number = this.coordinateToIndex(c);
        this.tokens[i] = token;
    } //}}}

    public function hasAt( c:Coordinate ) : Boolean
    { //{{{
        var i : Number = this.coordinateToIndex(c);
        return (this.tokens[i] != undefined);
    } //}}}

    public function isValid( c:Coordinate ) : Boolean 
    { //{{{
        var max : Number = lineLength - 1;
        if (c.x > max || c.y > max) return false;
        if (c.x < 0 || c.y < 0) return false;
        if (c.x >= size) {
            var minColumn : Number = c.x - size;
            return (c.y >= minColumn);
        }
        else {
            var maxColumn : Number = c.x + size;
            return (c.y <= maxColumn);
        }
    } //}}}

    public function move( start:Coordinate, d:Direction) : Void
    { //{{{
        if (!start) { 
            throw new Error("grapiz.Board.move() : start param undefined"); 
        }
        if (!d) {
            throw new Error("grapiz.Board.move() : direction param undefined");
        }
        if (d == Direction.BadDirection) { 
            throw new Error("grapiz.Board.move() : direction param is a bad direction"); 
        }
        
        var n : Number = this.countTokensOnLine(start, d);
        var t : Token  = this.getAt(start);
        Main.debug("token is : "+t+" moving l="+n);
        t.move( d, n );
        this.setAt( start, undefined );
        start.move(d, n);
        var o : Token  = this.getAt(start);
        if (o) {
            o.destroyed();
        }
        this.setAt( start, t );
    } //}}}
    
    public function canMove( base:Coordinate, d:Direction, n:Number) : Boolean
    { //{{{
        var token : Token = this.getAt(base);
        if (token == undefined) return false;
        
        var c : Coordinate = base.copy();
        for (var i = 0; i < n-1; i++) {
            c.move(d);
            if (!this.isValid(c)) return false;

            var tokUnder : Token = getAt(c);
            // a token cannot jump oponent's tokens
            if (tokUnder != undefined && tokUnder.getTeam() != token.getTeam()) {
                return false;
            }
        }

        c.move(d);
        return this.canEat(c, token.getTeam());
    } //}}}

    public function countTokensOnLine( base:Coordinate, d:Direction) : Number
    { //{{{
        var result  : Number     = 0;
        var oposite : Direction  = d.oposite();
        var cursor  : Coordinate = base.copy();

        // count form base to oposite direction
        while (this.isValid(cursor)) {
            if (this.hasAt(cursor)) {
                result++;
            }
            cursor.move(oposite);
        }

        // count from base+1 to direction
        cursor = base.next(d);
        while (this.isValid(cursor)) {
            if (this.hasAt(cursor)) {
                result++;
            }
            cursor.move(d);
        }

        return result;
    } //}}}

    public function availableMoves( coord:Coordinate ) : Array
    { //{{{
        var result : Array = new Array();
        for (var i=0; i<Direction.list.length; i++) {
            var d = Direction.list[i];
            var n = this.countTokensOnLine(coord, d);
            if (this.canMove(coord, d, n)) {
                var target = coord.copy(); 
                target.move(d, n); 
                result.push( new grapiz.AvailableMove(target, d) );
            }
        }
        return result;
    } //}}}

    public function toString() : String
    { //{{{
        var printer : grapiz.BoardTextPrinter = new grapiz.BoardTextPrinter(this);
        return printer.print();
    } //}}}

    public static function newLambdaBoard() : Board 
    { //{{{
        var xmlSrc : String;
        xmlSrc = '<b size="4">'
                + '<s t="0" x="8" y="8"/>'
                + '<s t="0" x="8" y="5"/>'
                + '<s t="0" x="7" y="3"/>'
                + '<s t="0" x="4" y="0"/>'
                + '<s t="0" x="1" y="0"/>'
                + '<s t="0" x="0" y="1"/>'
                + '<s t="0" x="0" y="4"/>'
                + '<s t="0" x="3" y="7"/>'
                + '<s t="0" x="5" y="8"/>'
                + '<s t="1" x="7" y="8"/>'
                + '<s t="1" x="8" y="7"/>'
                + '<s t="1" x="8" y="4"/>'
                + '<s t="1" x="5" y="1"/>'
                + '<s t="1" x="3" y="0"/>'
                + '<s t="1" x="0" y="0"/>'
                + '<s t="1" x="0" y="3"/>'
                + '<s t="1" x="1" y="5"/>'
                + '<s t="1" x="4" y="8"/>'
               + '</b>';
        var xml : XML;
        xml = new XML(xmlSrc);
        return new Board(xml.firstChild);
    } //}}}

    // ----------------------------------------------------------------------
    // Private methods
    // ----------------------------------------------------------------------

    private function canEat( c:Coordinate, team:Number ) : Boolean
    { //{{{
        if (!this.isValid(c)) 
            return false;
        
        var tokUnder : Token = this.getAt(c);
        // a token cannot eat its own team tokens
        if (tokUnder != undefined && tokUnder.getTeam() == team) {
            return false;
        }
        return true;
    } //}}}

    private function coordinateToIndex( c:Coordinate ) : Number
    { //{{{
        return (this.lineLength * c.x) + c.y;
    } //}}}
    
    private function setSize( size : Number ) : Void
    { //{{{
        this.size = size;
        this.lineLength = (size * 2) + 1;
    } //}}}

    private function initWithXml(xml:XMLNode) : Void
    { //{{{
        this.setSize( parseInt(xml.attributes.size) );
        var xmlToken : XMLNode;
        for (var i=0; i<xml.childNodes.length; i++) {
            xmlToken = xml.childNodes[i];

            var team : Number = parseInt( xmlToken.attributes.t );
            var x    : Number = parseInt( xmlToken.attributes.x );
            var y    : Number = parseInt( xmlToken.attributes.y );

            var token : Token = new Token(team);
            var coord : Coordinate = new Coordinate(x,y);
            token.setCoordinate(coord);
            this.setAt(coord, token);
        }
    } //}}}

}

// EOF

