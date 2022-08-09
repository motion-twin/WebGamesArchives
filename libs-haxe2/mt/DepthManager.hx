package mt;

#if(flash9 || nme)
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;

class DepthManager {

	var root : flash.display.DisplayObjectContainer;
	var plans : Array<flash.display.DisplayObject>;
	var baseChildren : Int;

	public function new(r) {
		root = r;
		baseChildren = root.numChildren;
		plans = new Array();
	}

	public function getMC() {
		return root;
	}
	
	/**
	 * get the whole plan displayobject
	 */
	public function getPlan( n ) {
		var pmc = plans[n];
		if( pmc != null )
			return pmc;
		pmc = new flash.display.Shape();
		pmc.visible = false;
		pmc.name = "Plan#"+n;
		root.addChildAt(pmc,getBottom(n));
		plans[n] = pmc;
		return pmc;
	}
	
	/**
	 * Get index of the lowest element in the plan
	 * @param	p	A plan id
	 */
	function getBottom( plan:Int ) : Int {
		var n = plan;
		while( --n >= 0 ) {
			var mc = plans[n];
			if( mc != null )
				return root.getChildIndex(mc)+1;
		}
		// we can't use numChildren since we don't want to insert
		// after the plans that have already been created
		// but we can't use 0 either since there might be library
		// objects that have been added to the clip
		return baseChildren;
	}

	function getMCPlan( mc : flash.display.DisplayObject ) {
		var idx = root.getChildIndex(mc);
		for( p in 0...plans.length ) {
			var mc = plans[p];
			if( mc != null && root.getChildIndex(mc) > idx )
				return p;
		}
		return 0;
	}

	#if !nme
	#if dm_obfu
	
	/**
	 * @deprecated
	 */
	public inline function attach( inst : String, plan : Int ) {
		return attachObfu(untyped __unprotect__(inst),plan);
	}
	
	/**
	 * @deprecated
	 */
	public function attachObfu( inst : String, plan : Int ) {
		var mc = flash.Lib.attach(inst);
		root.addChildAt(mc,root.getChildIndex(getPlan(plan)));
		return mc;
	}

	#else
	
	/**
	 * Old school attach movie clip to plan
	 * @deprecated
	 */
	public function attach( inst : String, plan : Int ) {
		var mc = flash.Lib.attach(inst);
		root.addChildAt(mc,root.getChildIndex(getPlan(plan)));
		return mc;
	}

	#end
	#end
	
	/**
	 * Adds an empty movieclip in this plan
	 */
	public function empty( plan : Int ) {
		var mc = new flash.display.MovieClip();
		root.addChildAt(mc,root.getChildIndex(getPlan(plan)));
		return mc;
	}
	
	/**
	 * Add a movieclip to the plan's display list
	 */
	public function add<T>( _mc : T, plan : Int ) : T {
		var mc = cast (_mc,flash.display.DisplayObject);
		if( mc.parent != null ) mc.parent.removeChild(mc);
		root.addChildAt(mc,root.getChildIndex(getPlan(plan)));
		return _mc;
	}

	/**
	 * Put the clip at the highest depth
	 * @param	mc
	 */
	public function over( mc : flash.display.DisplayObject ) {
		var plan = getMCPlan(mc);
		// minus-one because it's removed before
		root.addChildAt(mc,root.getChildIndex(getPlan(plan))-1);
	}

	/**
	 * Put the clip at the lowest depth
	 * @param	mc
	 */
	public function under( mc : flash.display.DisplayObject ) {
		var plan = getMCPlan(mc);
		root.addChildAt(mc,getBottom(plan));
	}

	/**
	 * Y-Sorting of movieclips in a plan
	 */
	public function ysort( plan : Int ) {
		var y : Float = -99999999;
		var start = getBottom(plan);
		var last = root.getChildIndex(getPlan(plan));
		for( i in start...last ) {
			var mc = root.getChildAt(i);
			var mcy = mc.y;
			if( mcy >= y )
				y = mcy;
			else {
				var j = i - 1;
				while( j >= start ) {
					var mc2 = root.getChildAt(j);
					if( mc2.y <= mcy )
						break;
					j--;
				}
				root.addChildAt(mc,j+1);
			}
		}
	}
	
	/**
	 * Removes all clips in the plan
	 */
	public function clear( plan : Int ) {
		var pmc = getPlan(plan);
		var pos = getBottom(plan);
		var count = root.getChildIndex(pmc) - pos;
		while( count > 0 ) {
			root.removeChildAt(pos);
			count--;
		}
	}

	public function destroy( ) {

		while( root.numChildren > baseChildren ) {
			var mc = root.getChildAt(baseChildren);
			mc.parent.removeChild(mc);
		}
		plans = [];

	}
	
	public function iterPlan( plan,f : DisplayObject->Void )
	{
		var start = getBottom(plan);
		var last = root.getChildIndex(getPlan(plan));
		for ( i in start...last)
			f(root.getChildAt( i ));
	}
	
}

#else 
class DepthManager {
	
	static var INST_COUNTER = 0;
	
	var root_mc : flash.MovieClip;
	var plans : Array<{ tbl : Array<flash.MovieClip>, cur : Int }>;
	
	public function new( mc : flash.MovieClip ) {
		root_mc = mc;
		plans = new Array();
	}
	
	public function getMC() {
		return root_mc;
	}
	
	function getPlan( pnb ) {
		var plan_data = plans[pnb];
		if( plan_data == null ) {
			plan_data = { tbl : new Array(), cur : 0 };
			plans[pnb] = plan_data;
		}
		return plan_data;
	}
	
	public function compact( plan : Int ) {
		var plan_data = plans[plan];
		var p = plan_data.tbl;
		var cur = 0;
		var base = plan * 1000;
		for( i in 0...plan_data.cur )
			if( p[i]._name != null ) {
				p[i].swapDepths(base+cur);
				p[cur] = p[i];
				cur++;
			}
		plan_data.cur = cur;
	}

	public function attach( inst : String, plan : Int ) : flash.MovieClip {
		var plan_data = getPlan(plan);
		var p = plan_data.tbl;
		var d = plan_data.cur;
		if( d == 1000 ) {
			compact(plan);
			return attach(inst,plan);
		}
		var iname = inst+"@"+(INST_COUNTER++);
		var mc = root_mc.attachMovie(inst,iname,d+plan*1000,null);
		p[d] = mc;
		plan_data.cur = d + 1;
		return mc;
	}

	#if flash8
	public function attachBitmap( bmp : flash.display.BitmapData, plan : Int ) {
		var plan_data = getPlan(plan);
		var p = plan_data.tbl;
		var d = plan_data.cur;
		if( d == 1000 ) {
			compact(plan);
			attachBitmap(bmp,plan);
			return;
		}
		root_mc.attachBitmap(bmp,d+plan*1000);
		p[d] = null;
		plan_data.cur = d + 1;
	}
	#end

	public function empty( plan : Int ) : flash.MovieClip {
		var plan_data = getPlan(plan);
		var p = plan_data.tbl;
		var d = plan_data.cur;
		if( d == 1000 ) {
			compact(plan);
			return empty(plan);
		}
		var iname = "empty@"+(INST_COUNTER++);
		var mc = root_mc.createEmptyMovieClip(iname,d+plan*1000);
		p[d] = mc;
		plan_data.cur = d + 1;
		return mc;
	}

	public function reserve( mc : flash.MovieClip, plan : Int ) : Int {
		var plan_data = getPlan(plan);
		var p = plan_data.tbl;
		var d = plan_data.cur;
		if( d == 1000 ) {
			compact(plan);
			return reserve(mc,plan);
		}
		p[d] = mc;
		plan_data.cur = d + 1;
		return d + plan * 1000;
	}

	public function swap( mc : flash.MovieClip, plan : Int ) {
		var src_plan = Math.floor(mc.getDepth() / 1000);
		if( src_plan == plan )
			return;
		var plan_data = getPlan(src_plan);
		var p = plan_data.tbl;
		for( i in 0...plan_data.cur )
			if( p[i] == mc ) {
				p[i] = null;
				break;
			}
		mc.swapDepths( reserve(mc,plan) );
	}

	public function under( mc : flash.MovieClip ) {
		var d = mc.getDepth();
		var plan = Math.floor(d / 1000);
		var plan_data = getPlan(plan);
		var p = plan_data.tbl;
		var pd = d%1000;
		if( p[pd] == mc ) {
			p[pd] = null;
			p.unshift(mc);
			plan_data.cur++;
			compact(plan);
		}
	}

	public function over( mc : flash.MovieClip ) {
		var d = mc.getDepth();
		var plan = Math.floor(d / 1000);
		var plan_data = getPlan(plan);
		var p = plan_data.tbl;
		var pd = d%1000;
		if( p[pd] == mc ) {
			p[pd] = null;
			if( plan_data.cur == 1000 )
				compact(plan);
			d = plan_data.cur;
			plan_data.cur++;
			mc.swapDepths(d + plan * 1000);
			p[d] = mc;
		}
	}

	public function clear( plan : Int ) {
		var plan_data = getPlan(plan);
		var p = plan_data.tbl;
		for( i in 0...plan_data.cur )
			p[i].removeMovieClip();
		plan_data.cur = 0;
	}

	public function ysort( plan : Int ) {
		var plan_data = getPlan(plan);
		var p = plan_data.tbl;
		var len = plan_data.cur;
		var y : Float = -99999999;
		for( i in 0...len ) {
			var mc = p[i];
			var mcy = mc._y;
			if( mcy >= y )
				y = mcy;
			else {
				var j = i;
				while( j > 0 ) {
					var mc2 = p[j-1];
					if( mc2._y > mcy ) {
						p[j] = mc2;
						mc.swapDepths(cast mc2);
					} else {
						p[j] = mc;
						break;
					}
					j--;
				}
				if( j == 0 )
					p[0] = mc;
			}
		}
	}

	public function destroy() {
		for( i in 0...plans.length )
			clear(i);
	}

}

#end
