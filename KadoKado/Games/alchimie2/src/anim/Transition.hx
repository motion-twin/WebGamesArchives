package anim ;

enum Transition {
	Linear;
	Quad(p : Int);	// Quadratic
	Cubic(p:Int);	// Cubicular
	Quart(p:Int);	// Quartetic
	Quint(p:Int);	// Quintetic
	Pow(p : Int);
	Expo(p:Int);
	Circ(p:Int);
	Sine(p:Int);
	Back(p:Int, pa:Float);
	Bounce(p:Int);
	Elastic(p:Int, pa:Float);
}
