import mt.bumdum9.Lib;

class Phx extends Sprite {//}

	public var material:phx.Material;
	public var body:phx.Body;
	public var game:Game;
	public var orient:Bool;
	
	public function new(?mc:flash.display.MovieClip){
		super(mc);
		body = new phx.Body(0,0);
		body.onDestroy = kill;
		orient = true;
	}

	override function update(){
		x = body.x;
		y = body.y;
		if(orient) root.rotation = body.a / 0.0174;

		super.update();
	}

	// TRANSFORM
	public function setPos(x,y){
		body.setPos(x, y);
		game.world.sync(body);
	}
	public function setAngle(a){
		body.setAngle(a);
		game.world.sync(body);
	}
	public function setVit(vx,vy){
		body.setSpeed(vx,vy);
		game.world.sync(body);
	}
	public function setStatic(fl){
		game.world.removeBody(body);
		body.isStatic = fl;
		game.world.addBody(body);

	}

	public function setBias(){

	}

	// BODY
	public function setBox(w,?h){
		if( h == null ) h = w;
		var shape = phx.Shape.makeBox(w,h,-w*0.5,-h*0.5) ;
		addShape(shape);
	}
	public function setCirc(ray){
		var shape = new phx.Circle(ray,new phx.Vector(0,0));
		addShape(shape);
	}
	public function setPol(a:Array<Array<Float>>,dx=0.0,dy=0.0){
		var a2 = [];
		for( k in a ){
			var v = new phx.Vector(k[0],k[1]);
			a2.push(v);
		}
		var shape = new phx.Polygon(a2, new phx.Vector(dx,dy));
		addShape(shape);
	}
	function addShape(shape:phx.Shape) {
		game.phxLib.set(Std.string(shape.id),this);
		if(material!=null)shape.material = material;
		game.world.removeBody(body);
		body.addShape( shape );
		body.updatePhysics();
		game.world.addBody(body);
	}

	// KILL
	override function kill() {
		game.world.removeBody(body);
		super.kill();
	}


//{
}

