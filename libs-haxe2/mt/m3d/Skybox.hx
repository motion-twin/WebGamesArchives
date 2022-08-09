package mt.m3d;
import mt.m3d.T;

@:shader({
    var input : {
        pos : Float3
    };
    var tuv : Float3;
    function vertex( mproj : M44 ) {
        out = pos.xyzw * mproj;
        tuv = pos;
    }
    function fragment( tex : CubeTexture, color : Float4 ) {
        out = tex.get(tuv,nearest) * color;
    }
}) class Skybox extends Shader {

    var sky : Polygon;

    public function new(c) {
        super(c);
        sky = new Cube(2, 2, 2);
        sky.translate( -1, -1, -1);
        sky.alloc(c);
    }

    override function dispose() {
        super.dispose();
        sky.dispose();
    }

    public function show( camera : Camera, tex, pos : flash.geom.Matrix3D = null, color : flash.geom.Vector3D = null ) {
        var size = camera.zFar / Math.sqrt(3);
        var m;
        if( pos == null ) {
        	m = new flash.geom.Matrix3D();
        	m.identity();
        } else
        	m = pos.clone();
		if( color == null )
			color = new flash.geom.Vector3D(1, 1, 1, 1);
        m.appendScale(size, size, size);
        m.appendTranslation(camera.pos.x, camera.pos.y, camera.pos.z);
        m.append(camera.m.toMatrix());
        init( { mproj : m }, { tex : tex, color : color } );
        c.setCulling(Face.FRONT);
        c.setDepthTest( false, Compare.ALWAYS );
        draw(sky.vbuf,sky.ibuf);
    }

}