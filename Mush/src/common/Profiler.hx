
using Ex;

import HashEx;
import IntHashEx;

class Profiler
{
	//begin singleton
	static var inst : Profiler;
	
	public static var min_limit = 0.001;
	
	public static inline function get()
	{
		if (null==inst)
			inst = new Profiler();
		return inst;
	}
	//end singleton
	
	public function new()
	{
		h = new Hash();
		
		#if !master
		enable = true;
		#else
		enable = false;
		#end
	}
	
	public var enable : Bool;
	var h : Hash< { start:Null<Float>, total:Float, hit : Int}>;
	
	public inline function begin( tag )
	{
		if ( enable )
		{
			var t = StdEx.time();
			
			var ent = h.get( tag );
			if (null==ent)
			{
				ent = { start:null, total:0.0, hit:0 };
				h.set( tag,ent );
			}

			ent.start = t;
			ent.hit++;
		}
	}
	
	public inline function end( tag )
	{
		if ( enable )
		{
			var t = StdEx.time();
			var ent = h.get( tag );
			
			if (null!=ent)
				if ( ent.start != null )
					ent.total += (t ) - ent.start;
		}
	}
	
	public inline function clear( tag )
	{
		if ( enable )
		{
			h.remove( tag);
		}
	}
	
	public inline function clean()
	{
		if ( enable )
		{
			h = new Hash();
		}
	}
	
	public function spent( tag )
	{
		if ( !enable ) return 0.0;
		return h.get( tag ).total;
	}
	
	public function hit( tag )
	{
		if ( !enable ) return 0.0;
		return h.get( tag ).hit;
	}
	
	public function dump() : String
	{
		var s = "";
		var trunk = function(v:Float) return Std.int( v * 1000.0 ) * 0.001;
		var a = [];
		for(k in h.keys())
		{
			var sp = spent(k);
			var ht = hit(k);
			
			if (sp <= min_limit ) continue;
			
			a.pushBack(k);
		}
		
		a.sort( function(k0, k1)  return Std.int( (spent( k1 ) - spent( k0 )) * 1000 ) );
		
		for( k in a )
		{
			var sp = spent(k);
			var ht = hit(k);
			s+=("tag: "+k+" spent: " + trunk(sp))+" hit:"+ht+" avg time: "+ trunk(sp/ht) +"<br/>";
		}
		return s;
	}
}