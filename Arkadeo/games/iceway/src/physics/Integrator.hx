/**
 *  Integrator.hx
 *
 *  Copyright (c) 2011 Martin Lindelof
 *  @author Martin Lindelof
 *  contact martin.lindelof(at)gmail.com
 *  website www.martinlindelof.com
 */
package physics;

interface Integrator {
	function step(t : Float):Void;
}