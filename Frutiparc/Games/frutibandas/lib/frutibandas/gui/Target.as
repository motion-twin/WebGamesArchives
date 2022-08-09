// 
// $Id: Target.as,v 1.3 2004/05/06 11:10:42  Exp $
//

/**
 * This movie is used to select a board coordinate.
 */
class frutibandas.gui.Target extends MovieClip
{
    private var validationCallback : frutibandas.Callback;
    private var invocationCard     : frutibandas.Card;
    private var hidenButton        : Button;    

    /** Static constructor. */
    public static function New( game:frutibandas.gui.Game ) : Target
    { //{{{
        var depth  : Number = game.getNextHighestDepth();
        var target : Target = Target( game.attachMovie("mcTarget", "Target_"+depth, depth) );
        return target;
    } //}}}

    public function setCard( card:frutibandas.Card ) : Void 
    { //{{{
        this.invocationCard = card;
    } //}}}

    public function getCard() : frutibandas.Card
    { //{{{
        return this.invocationCard;
    } //}}}

    public function getCoordinate() : frutibandas.Coordinate
    { //{{{
        return new frutibandas.Coordinate(this._x, this._y);
    } //}}}

    public function getDirection() : frutibandas.Direction
    { //{{{
        return frutibandas.Direction.BadDirection;
    } //}}}

    public function setValidationCallback( cb:frutibandas.Callback ) : Void
    { //{{{
        this.validationCallback = cb;
    } //}}}

    public function destroy() : Void
    {
        Mouse.show();
        this.removeMovieClip();
    }

    public function onButtonRelease() : Void
    { //{{{
        this.stopDrag();
        Mouse.show();
        this.validationCallback.execute_1(this);
        this.destroy();
    } //}}}


    // ----------------------------------------------------------------------
    // Private methods.
    // ----------------------------------------------------------------------
    
    private function Target() 
    { //{{{
        this.startDrag(true);
        this.hidenButton.onRelease = function() { _parent.onButtonRelease(); }
        Mouse.hide();
    } //}}}
}
//EOF
