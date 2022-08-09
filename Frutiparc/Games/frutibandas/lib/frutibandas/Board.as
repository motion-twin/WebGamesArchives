// 
// $Id: Board.as,v 1.22 2004/03/11 11:35:19  Exp $
//

import frutibandas.*;

class frutibandas.Board
{
    public static var TRAPPED   : Number = -4;
    public static var DESTROYED : Number = -3;
    public static var ROCK      : Number = -2;
    public static var FREE      : Number = -1;
    public static var TEAM_0    : Number =  0;
    public static var TEAM_1    : Number =  1;
    
    private static var numberOfPlayers : Number = 2;
    
    private var size : Number;
    private var minX : Number;
    private var maxX : Number;
    private var minY : Number;
    private var maxY : Number;
    private var slots        : Array;
    private var teamCounters : Array;

    private var listener : BoardListener;
    
    public function Board( size:Number ) 
    { // {{{
        this.size  = size;
        this.teamCounters = new Array();
        this.slots = new Array();
        this.minX = 0;
        this.minY = 0;
        this.maxX = size - 1;
        this.maxY = size - 1;
    } // }}}

    public function setListener( bl:BoardListener )
    { // {{{
        this.listener = bl;
    } // }}}
    
    public function getSize() : Number
    { // {{{
        return this.size;
    } // }}}
    
    public function move( team:Number, d:Direction ) : Void     
    { // {{{
        var corner : Coordinate = this.getCorner(d);
        var lineInc : Direction = this.getPerpendicular(d);
       
        while (this.isValid(corner)) {
            var cursor : Coordinate = corner.copy();
            while (this.isValid(cursor)) {
                if (this.getElement(cursor) == team) {
                    this.moveSprite(cursor, d);
                }
                cursor.move(d.oposite());
            }
            corner.move(lineInc);
        }
    } // }}}
    
    public function moveSprite( c:Coordinate, d:Direction, pushed:Boolean ) : Void 
    { // {{{
        if (!this.canMoveSprite(c, d)) return;
        if (pushed == undefined) {
            pushed = false;
        }

        var startIndex : Number = this.toIndex(c);
        var element    : Number = this.getElementAt(startIndex);
        
        this.setElementAt(startIndex, FREE);
        
        var destination : Coordinate = c.copy();
        destination.move(d);

        var target : Number = this.getElement(destination);


        // push
        if (target > FREE) {
            this.moveSprite(destination, d, true);
            this.setElement(destination, element);
            this.listener.onSpriteMove(c, d, pushed);
            return;
        }

        // free slot
        if (target == FREE) {
            this.setElement(destination, element);
            this.listener.onSpriteMove(c, d, pushed);
            return;
        }

        // destroy sprite
        if (target == DESTROYED || target == TRAPPED) {
            this.teamCounters[element]--;
            this.listener.onSpriteMove(c, d, pushed);
            return;
        }
    } // }}}

    public function getElement( c:Coordinate ) : Number 
    { // {{{
        if (!this.isValid(c)) {
            return DESTROYED;
        }
        return this.slots[ this.toIndex(c) ];
    } // }}}
    
    public function getElementAt( i:Number ) : Number 
    { // {{{
        return this.slots[ i ];
    } // }}}
    
    public function setElement( c:Coordinate, element:Number ) : Void 
    { // {{{
        this.slots[ this.toIndex(c) ] = element;
    } // }}}
    
    public function setElementAt( i:Number, element:Number ) : Void
    { // {{{
        this.slots[ i ] = element;
    } // }}}

    public function getMinY() : Number
    {//{{{
        return this.minY;
    }//}}}
    
    public function getMaxY() : Number
    { // {{{
        return this.maxY;
    } // }}}
    
    public function destroy( c:Coordinate ) : Void 
    {//{{{
        var index : Number = this.toIndex(c);
        var element : Number = this.getElementAt(index);
        this.setElement(c, DESTROYED);

        if (element == TRAPPED) {
            this.listener.onTrapDiscovered(c);
            return;
        }
        if (element != DESTROYED) {
            this.listener.onSlotDestroyed(c);
        }
        
        if (element > FREE) {
            this.teamCounters[element] --;
        }
        if (element == ROCK) {
        }
    }//}}}
    
    public function setTrapped( c:Coordinate ) : Void
    {//{{{
        var index : Number = this.toIndex(c);
        var element : Number = this.getElementAt(index);
        this.listener.onSlotTrapped(c);
        this.setElement(c, TRAPPED);
    }//}}}
    
    public function isValid( c:Coordinate ) : Boolean 
    { // {{{
        return (c.x >= this.minX && c.x <= this.maxX && c.y >= this.minY && c.y <= this.maxY);
    } // }}}
    
    public function isEmptyBorder( border:Direction ) : Boolean     
    { // {{{
        var c : Coordinate = this.getCorner(border);
        var d : Direction  = this.getPerpendicular(border);
        while (this.isValid(c)) {
            if (getElement(c) > FREE) {
                return false;
            }
            c.move(d);
        }
        return true;
    } // }}}
    
    public function countSpritesOf( team:Number ) : Number 
    { // {{{
        return this.teamCounters[team];
    } // }}}
    
    public function toCoordinate( index:Number ) : Coordinate 
    { // {{{
        var y : Number = Math.round(index / this.size);
        var x : Number = index - (y * this.size);
        return new Coordinate(x,y);
    } // }}}
    
    public function toIndex( c:Coordinate ) : Number 
    { // {{{
        return c.x + (c.y * this.size);
    } // }}}

    public function getMoveOrder( c:Coordinate, d:Direction ) : Number    
    { // {{{
        switch (d) {
            case Direction.Up:
                return maxY - c.y;
            case Direction.Down:
                return c.y - minY;
            case Direction.Right:
                return c.x - minX;
            case Direction.Left:
                return maxX - c.x;
            default:
                return 0;
        }
    } // }}}
   
    public function removeEmptyBorders() : Void
    { // {{{
        while (this.isEmptyBorder(Direction.Up) && (minY <= maxY)) 
            this.removeBorder(Direction.Up);
        while (this.isEmptyBorder(Direction.Down) && (minY <= maxY)) 
            this.removeBorder(Direction.Down);
        while (this.isEmptyBorder(Direction.Left) && (minX <= maxX)) 
            this.removeBorder(Direction.Left);
        while (this.isEmptyBorder(Direction.Right) && (minX <= maxX)) 
            this.removeBorder(Direction.Right);
    } // }}}
    
    private function removeBorder( border:Direction ) : Void 
    { // {{{
        var c : Coordinate = this.getCorner(border);
        var d : Direction  = this.getPerpendicular(border);
        while (this.isValid(c)) {
            if (this.getElement(c) != DESTROYED) {
                this.destroy(c);
            }
            c.move(d);
        }
        if (border == Direction.Up) minY++;
        if (border == Direction.Down) maxY--;
        if (border == Direction.Left) minX++;
        if (border == Direction.Right) maxX--;
    } // }}}
    
    private function getCorner( border:Direction ) : Coordinate 
    { // {{{
        if (border == Direction.Up)    return new Coordinate(minX, minY);
        if (border == Direction.Down)  return new Coordinate(minX, maxY);
        if (border == Direction.Left)  return new Coordinate(minX, minY);
        if (border == Direction.Right) return new Coordinate(maxX, minY);
        return new Coordinate();
    } // }}}
    
    private function getPerpendicular( d:Direction) : Direction 
    { // {{{
        if (d == Direction.Up)    return Direction.Right;
        if (d == Direction.Down)  return Direction.Right;
        if (d == Direction.Left)  return Direction.Down;
        if (d == Direction.Right) return Direction.Down;
        return Direction.BadDirection;
    } // }}}
    
    private function canMoveSprite( c:Coordinate, d:Direction ) : Boolean 
    { // {{{
        var cursor : Coordinate = c.copy();
        cursor.move(d);
        while (this.isValid(cursor)) {
            var element : Number = this.getElement(cursor);
            if (element <= FREE) {
                if (element == ROCK) return false;
                return true;
            }
            cursor.move(d);
        }
        return true;
    } // }}}

    public static function newBoardFromXml( xml:XMLNode )
    { // {{{
        var board : Board;
        var boardSize : Number = parseInt( xml.attributes.size );
        board = new Board( boardSize );
        
        var content : String;
        content = xml.firstChild.nodeValue;

        for (var i = 0; i < content.length; i++) {
            if (content.charAt(i) != '.') {
                var value : Number = parseInt( content.charAt(i) );
                var type  : Number = value - 7;
                board.setElementAt( i, type );
                if (type > FREE) {
                    if (board.teamCounters[type] == undefined) {
                        board.teamCounters[type] = 0;
                    }
                    board.teamCounters[type]++;
                }
            }
        }
        return board;
    } // }}}

    public function incTeamCounter(team:Number) : Number 
    { // {{{
        this.teamCounters[team]++;
        return this.teamCounters[team];
    } // }}}

    public function decTeamCounter(team:Number) : Number 
    { // {{{
        this.teamCounters[team]--;
        return this.teamCounters[team];
    } // }}}
    
    public function toString() : String
    { // {{{
        var result : String = "";
        for (var y=0; y < size; y++) {
            for (var x=0; x < size; x++) {
                var element = this.slots[ y*size + x ];
                switch (element) {
                    case DESTROYED:
                        result += " X";
                        break;
                    case FREE:
                        result += " .";
                        break;
                    case TEAM_0:
                        result += " 0";
                        break;
                    case TEAM_1:
                        result += " 1";
                        break;
                    case ROCK:
                        result += " #";
                        break;
                    default:
                        result += element;
                        break;
                }
            }
            result += "\n";
        }
        return result;
    } // }}}
}

//EOF
