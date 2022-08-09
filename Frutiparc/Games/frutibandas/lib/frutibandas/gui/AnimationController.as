// 
// $Id: AnimationController.as,v 1.3 2004/02/12 17:59:18  Exp $
//

import frutibandas.gui.Animable;

/**
 * Control animations with priority control.
 *
 * This controller ensure that an animation of lower priority (means 
 * high priority value) won't be played until each higher priority 
 * animations are not completed.
 *
 * @code
 * 
 *  // create a controller with a maximum of 5 priority levels
 *  var control : AnimationController = new AnimationController(5);
 *  control.push( myAnim, 0 );
 *  
 *  // here myOtherAnim1 and myOtherAnim2 will be launched and played > 
 *  // at the same time. The next priority level will be started when
 *  // both animations will are completed.
 *  control.push( myOtherAnim1, 1 );
 *  control.push( myOtherAnim2, 1 );
 *  
 *  // an animation may be pushed more than one time in the controller
 *  // but not in the same priority level
 *  control.push( myAnim, 2 );
 * 
 *  // play next animations steps
 *  if (!control.update()) {
 *     ... no more frames to process ...
 *  }
 * 
 * @endcode
 */
class frutibandas.gui.AnimationController implements Animable
{
    private var animations  : Array;
    private var count       : Number;
    private var currentPrio : Number;
    
    /**
     * @param size The maximum priority index.
     */
    public function AnimationController( size:Number )
    // {{{
    {
        this.count       = 0;
        this.currentPrio = 0;
        this.animations  = new Array();
        this.setPriorityRange( size );
    }
    // }}}

    /** Set new max priority range. */
    public function setPriorityRange( max:Number )
    // {{{
    {
        for (var i=0; i<max; i++) {
            if (this.animations[i] == undefined) {
                this.animations[i] = new Array();
            }
        }
        if (this.animations.length > max+1) {
            this.animations.splice( max );
        }
    }
    // }}}
    
    public function push( animatedObject:Animable, priority:Number) 
    // {{{
    {
        if (priority == undefined) {
            priority = this.animations.length - 1;
        }
        if (this.animations[priority] == undefined) {
            this.animations[priority] = new Array();
        }
        for (var i=0; i<this.animations[priority].length; i++) {
            if (this.animations[priority][i] == animatedObject) {
                return;
            }
        }
        this.animations[ priority ].push( animatedObject );
        this.count++;
    }
    // }}}

    public function pushNextPriority( animatedObject:Animable )
    // {{{
    {
        var prio : Number = this.currentPrio;
        this.push( animatedObject, prio );
        this.currentPrio++;
    }
    // }}}
    
    public function update() : Boolean
    // {{{
    {
        for (var p=0; p<this.animations.length; p++) {
            if (this.animations[p].length > 0) {
                this.updatePriority(p);
                return (this.count > 0);
            }
        }
        return (this.count > 0)
    }
    // }}}

    public function isEmpty()
    // {{{
    {
        return (this.count == 0);
    }
    // }}}

    public function toString() : String
    // {{{
    {
        var result : String = "Animation controller :\n";
        result += " nbr priority arrays : "+this.animations.length+" count="+this.count+"\n";
        for (var i=0; i<this.animations.length; i++) {
            for (var j=0; j<this.animations[i].length; j++) {
                result += "+ ["+i+"]["+j+"] "+this.animations[i][j].toString() + "\n";
            }
        }
        result += "<-AnimationController";
        return result;   
    }
    // }}}

    private function updatePriority( p:Number )
    // {{{
    {
        var array : Array  = this.animations[p];
        for (var i=0; i<array.length; i++) {
            var animation : Animable = Animable( array[i] );
            if (animation.update() == false || animation == undefined) {
                array.splice(i, 1);
                this.count--;
                i--;
            }
        }
        animations[p] = array;
    }
    // }}}
}
//EOF
