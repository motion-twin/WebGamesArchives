package ent;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;
import Protocol;

class Part extends Ent 
{
	
	public var timer:Null<Int>;
	public var vx:Float;
	public var vy:Float;
	public var vz:Float;
	
	public var frict:Float;
	public var bounceXY:Float;
	public var bounceZ:Float;
	public var weight:Float;
	public var vr:Float;
	public var scale:Float;
	public var vfr:Float;
	
	public var fadeLimit:Int;
	public var onGroundBounce:Void->Void;
	
	public function new(?skin)
	{
		super();
		if( skin != null ) root.addChild(skin);
		vx  = vy = vz = vr = weight = 0;
		frict = vfr = scale = 1.0;
		bounceZ = bounceXY = 0.5;
		fadeLimit = 10;
		gy = 0;
	}
	
	override function update() 
	{
		super.update();
		
		vx *= frict;
		vy *= frict;
		vz *= frict;
		
		vz += weight;
		x += vx;
		y += vy;
		z += vz;
		
		// ROT
		vr *= vfr;
		root.rotation += vr;
		
		// RECAL
		if ( z > 0 )
		{
			z = 0;
			vz *= -bounceZ;
			vx *= bounceXY;
			vy *= bounceXY;
			vr = -vr;
			if( onGroundBounce != null ) onGroundBounce();
		}
		
		if ( y < 53 ) 
		{
			y = 53;
			vy *= -0.75;
		}
		//
		updatePos();
		
		if ( timer != null ) 
		{
			if ( timer-- < 10 ) 
			{
				var c = timer / 10;
				root.scaleX = root.scaleY = c*scale;
				if ( shade != null )
				{
					shade.scaleX = shade.scaleY = c;
				}
			}
			
			if( timer == 0 ) kill();
		}
	}
	
	public function twist(rot, fr)
	{
		root.rotation = Math.random() * 360;
		vr += (Math.random() * 2 - 1) * rot;
		vfr = fr;
	}
	
	public function setScale(sc)
	{
		root.scaleX = root.scaleY = scale = sc;
	}
}
