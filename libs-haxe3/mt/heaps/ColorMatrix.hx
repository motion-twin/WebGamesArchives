package mt.heaps;

class ColorMatrix {
	public static inline function identity(inOut : h3d.Matrix) {
		
	}
	
	public static inline function greyscale(inOut : h3d.Matrix) {
		inOut.identity();
		inOut.set( 	0.3,	0.59,	0.11,	0,
					0.3, 	0.59, 	0.11, 	0,
					0.3, 	0.59,	0.11, 	0,
					0,		0,		0,		1);
	}
}