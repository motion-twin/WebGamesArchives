package game.viewer;

interface GraphicRepresentation {
	public var position : geom.PVector3D;
	public function update():Void;
}

/*
  Since Resolver and Viewer are decoupled we can play both at different speed.

  Sometimes we want the viewer to do slow motion (ball thrown, ball flying, fight, etc).

  During these moments the Resolved do not provide enough positions for the viewer which has to interpolate players' and ball's positions on the field.

  This is the role of the Animator class : feeding the viewer with extra positions not computed by the Resolver.
 */
class Animator {
	var resolverObject : geom.Mover3D;
	var graphicObject : GraphicRepresentation;
	var delta : geom.PVector3D;
	public var autoAnimated : Bool;
	var autoStart : geom.PVector3D;
	var autoDest : geom.PVector3D;
	var frames : Int;

	public function new( m:geom.Mover3D, s:GraphicRepresentation ){
		this.resolverObject = m;
		this.graphicObject = s;
		this.delta = new geom.PVector3D();
		this.autoAnimated = false;
	}

	public function resolverFrame(interpolationFrames:Int){
		frames = interpolationFrames;
		if (interpolationFrames == 0){
			autoAnimated = false;
		}
		else if (Std.is(resolverObject, game.PlayerData)){
			var p : game.PlayerData = cast resolverObject;
			if (p.positionReset){
				p.positionReset = false;
				graphicObject.position.set(resolverObject.oldPosition);
				autoDest = p.position.clone();
				delta = autoDest.clone().sub(graphicObject.position);
				delta.normalize();
				delta.mult(Math.min(2, p.getMaxMoveSpeed()/2));
				delta.div(interpolationFrames);
				autoAnimated = true;
			}
		}
		else if (Std.is(resolverObject, game.Ball)){
			var b : game.Ball = cast resolverObject;
			if (b.positionReset){
				frames = 0;
				b.positionReset = false;
				graphicObject.position.set(resolverObject.position);
				graphicObject.update();
				return;
			}
		}
		if (!autoAnimated){
			// ensure that both object start at the same position
			graphicObject.position.set(resolverObject.oldPosition);
			if (resolverObject.oldPosition.equals(resolverObject.position))
				delta = new geom.PVector3D();
			else if (interpolationFrames > 0){
				delta.set(resolverObject.position);
				delta.sub(resolverObject.oldPosition);
				delta.div(interpolationFrames);
			}
			else {
				graphicObject.position.set(resolverObject.position);
			}
			graphicObject.update();
		}
		resolverObject.oldPosition.set(resolverObject.position);
	}

	public function update(){
		if (autoAnimated){
			autoAnimate();
			return;
		}
		--frames;
		if (frames > 1)
			graphicObject.position.add(delta);
		graphicObject.update();
	}

	function autoAnimate(){
		if (autoDest.distance(graphicObject.position) <= delta.length()*1.1){
			graphicObject.position.set(autoDest);
			autoAnimated = false;
		}
		else {
			graphicObject.position.add(delta);
		}
		graphicObject.update();
	}
}