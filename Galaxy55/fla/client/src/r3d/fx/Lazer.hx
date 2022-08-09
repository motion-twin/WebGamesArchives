package r3d.fx;

import r3d.Shaders;
import r3d.AbstractGame.GameEffects;

import h3d.Vector;
import h3d.Matrix;
import h3d.mat.Data;

typedef Shader = StripShader;
//typedef Shader = Shaders.PolyTexShader;

class Lazer 
{
	static inline var  NB = 3;
	
	var faces : Array<h3d.CustomObject<Shader>>; 
	var rdr : r3d.Render;
	
	public function new( rdr ) 
	{
		this.rdr = rdr;
		
		faces = [];
		var pts = [], uvs = [];
		
		var a = new h3d.prim.UV(0, 0);
		var b = new h3d.prim.UV(1, 0);
		var c = new h3d.prim.UV(0, 1);
		var d = new h3d.prim.UV(1, 1);
		
		for ( i in 0...NB )
		{
			uvs.push(a);
			uvs.push(b);
			uvs.push(c);
			uvs.push(d);
			
			var sx = 1;
			var sy = 1;
			pts.push(	new h3d.Point( 0, 0, 0) 	);
			pts.push(	new h3d.Point( 0, 0, sy) 	);
			pts.push(	new h3d.Point( sx, 0, 0)		);
			pts.push(	new h3d.Point( sx, 0, sy) 	);
			
			//pts.push( new h3d.Point( -sx*0.5, 0, -sy*0.5) );
			//pts.push( new h3d.Point( -sx*0.5, 0, sy*0.5) );
			//pts.push( new h3d.Point( sx*0.5, 0, -sy*0.5) );
			//pts.push( new h3d.Point( sx*0.5, 0, sy*0.5) );
			
			var q = new h3d.prim.Quads(pts, uvs);
			faces[i] = new h3d.CustomObject(q, new Shader());
			var f = faces[i];
			f.material.blend(SrcAlpha, One);
			f.material.culling = Face.None;
			f.material.depthWrite = false;
			
			f.shader.uvDelta = new h3d.Vector(0, 0);
		}
	}
	
	public function render( fx : GameEffects, data : { from :Vector,to:Vector, mat:Matrix,?type:Int})
	{
		if (data.type == null)
			return;
		var lt = data.type;
		var t = rdr.getLazerTex( 1  + lt );
		var eng = rdr.getEngine();
		
		mt.gx.Debug.assert( t != null );
		mt.gx.Debug.assert( eng != null );
		
		var rspeed = 3.;
		var tspeed = 1.;
		switch( lt ) {
			case 0	: tspeed = 0.8; rspeed = 5;
			case 1	: tspeed = 3; rspeed = 4;
			case 2	: tspeed = 2; rspeed = 5;
			case 3	: tspeed = 2; rspeed = 5;
		}
		
		//var m = new h3d.Matrix();
		//m.initTranslate( data.from.x, data.from.y, data.from.z );
		
		var dir = data.to.sub(data.from);
		var dirLen = dir.length();
		
		var sp = -tspeed * fx.time  / dirLen;
		var i = 0;
		for(f in faces)
		{
			var c = 2.0;
			if ( i == 0)
				f.shader.ratio = c*fx.time;
			else
				f.shader.ratio = c*fx.time + Math.PI / (i+1);
			f.shader.from = data.from;
			f.shader.to = data.to;
			f.shader.tex = t;
			f.shader.mproj = eng.camera.m;
			f.shader.cam = rdr.camPosition;
			f.shader.aOfs = Math.PI / (NB+1);
			
			var tscale = dirLen / 2;
			f.shader.uvScale = new h3d.Vector(tscale, 1);
			f.shader.uvDelta = new h3d.Vector(-tspeed*fx.time / tscale, 0);
			f.render( eng );
			i++;
		}
		//trace(dirLen);
	}
}