// 
// $Id: TokenAnim.as,v 1.1 2004/05/07 15:10:19  Exp $
//

import grapiz.Main;
import grapiz.gui.Token;
import grapiz.gui.Coordinate;

class grapiz.gui.TokenAnim
{
    // animation steps per slot
    private static var STEPS       : Number = 6;
    // maximum animation length
    private static var MAX_STEPS   : Number = 60;
    // maximum zoom allowed +50%
    private static var MAX_ZOOM    : Number = 100;

    private var zoom   : Number;
    private var zoomFx : Number;
    private var zoomMd : Number;
    private var steps  : Number;
    private var target : Coordinate;
    private var vector : Coordinate;
    private var token  : Token;
    private var shadow : MovieClip;
    private var speed  : Number;
    private var tokenToDestroy : Token;
    
    public function TokenAnim( tok:Token, destination:Coordinate, stp:Number ) 
    {
        Main.debug("Animation from "+tok.getCoordinate()+" to "+destination);
        this.token  = tok;
        this.target = destination;
        this.tokenToDestroy = null;
        
        this.steps  = ((STEPS * stp) < MAX_STEPS) ? (STEPS * stp) : MAX_STEPS;
 
        this.vector   = new Coordinate();
        this.vector.x = (target.x - token._x) / steps;
        this.vector.y = (target.y - token._y) / steps;
        
        this.zoom     = 100;
        this.zoomMd   = (this.steps / 2);
        this.zoomFx   = ((MAX_ZOOM * steps) / MAX_STEPS) / this.zoomMd;

        // create shadow
        var sDepth : Number = this.token._parent.getNextHighestDepth();
        this.shadow = this.token._parent.attachMovie("mcTokenShadow", "Shadow", sDepth);
        this.shadow.gotoAndStop( this.token.getTeam() + 1 );
        this.shadow.swapDepths( this.token.getDepth() );
        this.shadow._x = this.token._x;
        this.shadow._y = this.token._y;
    }
   
    /**
     * Set the destination token which will be destroyed at the end of the
     * animation.
     */
    public function setTokenToDestroy( token:Token ) : Void
    {
        this.tokenToDestroy = token;
    }
    
    public function update() : Boolean
    {
        this.steps--;

        // zoom increase up to the middle of the movement and decrease down to
        // the original size after
        if (this.steps >= (this.zoomMd-1)) {
            zoom += zoomFx;
        }
        else {
            zoom -= zoomFx;
        }
        
        // move shadow on the move line
        this.shadow._x += this.vector.x;
        this.shadow._y += this.vector.y;
        this.shadow._yscale = this.zoom;
        this.shadow._xscale = this.zoom;

        // move the token with using zoom factor as y modifier
        this.token._x = this.shadow._x;
        this.token._y = this.shadow._y - (this.zoom - 100);
        this.token._xscale = this.zoom;
        this.token._yscale = this.zoom;

        if (this.steps < 0) {
            /* 
            if (this.token._xscale != 100) 
                trace("Warning xscale was : "+this.token._xscale);
            if (this.token._x != this.target.x) 
                trace("Warning token.x was not "+target.x+" : "+this.token._x);
            if (this.token._y != this.target.y) 
                trace("Warning token.y was not "+target.y+" : "+this.token._y);
            */

            // ensure token is at the right position and with the right size
            // even if movement wasn't perfect
            this.token.setPosition(this.target);
            this.token._xscale = 100;
            this.token._yscale = 100;
            
            this.shadow.removeMovieClip();
            
            // if there was a token to destroy there, destroy it
            if (this.tokenToDestroy != null) {
                this.tokenToDestroy._visible = false;
                this.tokenToDestroy.removeMovieClip();
                grapiz.Main.gameUI.getBoard().playExplosionAt( target );
            }
            return false;
        }
        return true;
    }
}

//EOF
