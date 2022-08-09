package mt.m3d;
import mt.m3d.T;

@:shader({
    var input : {
        pos : Float3,
        uv : Float2
    };
    var tuv : Float2;
    function vertex( mproj : M44 ) {
        out = pos.xyzw * mproj;
        tuv = uv;
    }
    function fragment( tex : Texture ) {
        out = tex.get(tuv);
    }
}) class SkySphere extends Shader {

    var sky : Polygon;

    public function new(c,w=10,h=10) {
        super(c);
        sky = new Sphere(w,h);
        sky.addTCoords();
        sky.alloc(c);
    }

    override function dispose() {
        super.dispose();
        sky.dispose();
    }

    public function show( camera : Camera, tex ) {
        var size = camera.zFar;
        var m = new flash.geom.Matrix3D();
        m.identity();
        m.appendScale(size, size, size);
        m.appendTranslation(camera.pos.x, camera.pos.y, camera.pos.z);
        m.append(camera.m.toMatrix());
        init( { mproj : m }, { tex : tex } );
        c.setCulling(Face.FRONT);
        c.setDepthTest( false, Compare.ALWAYS );
        draw(sky.vbuf,sky.ibuf);
    }

}