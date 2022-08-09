import h2d.Drawable;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

class BatchGroup {
	public var elements		: Array<BatchElement>;
	public var texts		: Array<TextBatchElement>;
	public var drawables	: Array<Drawable>;

	public var sb			: SpriteBatch;
	public var tsb			: SpriteBatch;

	public var x(default,set)		: Float;
	public var y(default,set)		: Float;
	public var alpha(default,set)	: Float;
	public var visible(default,set)	: Bool;

	public function new(sb:SpriteBatch, tsb:SpriteBatch) {
		elements = [];
		texts = [];
		drawables = [];
		this.sb = sb;
		this.tsb = tsb;
		x = 0;
		y = 0;
		alpha = 1;
	}

	public static inline function createSceneGroup() : BatchGroup {
		return new BatchGroup(Game.ME.tilesFrontSb, Game.ME.textSbHuge);
	}

	public function dispose() {
		for(e in elements) e.remove();
		elements = null;

		for(e in texts) e.dispose();
		texts = null;

		for(e in drawables) e.dispose();
		drawables = null;

		sb = null;
		tsb = null;
	}

	public function remove(?be:BatchElement, ?t:TextBatchElement, ?d:Drawable) {
		if( be!=null )
			for(e in elements) {
				if( e==be ) {
					e.remove();
					elements.remove(e);
				}
			}

		if( t!=null )
			for(e in texts) {
				if( e==t ) {
					e.dispose();
					texts.remove(e);
				}
			}

		if( d!=null )
			for(e in drawables) {
				if( e==d ) {
					e.dispose();
					drawables.remove(e);
				}
			}
	}

	public function add(?e:BatchElement, ?t:TextBatchElement, ?d:Drawable) {
		if( e!=null ) {
			if( e.batch!=sb )
				throw "Not the same batch: "+e;
			e.x+=x;
			e.y+=y;
			elements.push(e);
		}

		if( t!=null ) {
			if( t.sp!=tsb )
				throw "Not the same batch: "+t;
			t.x+=x;
			t.y+=y;
			texts.push(t);
		}

		if( d!=null ) {
			d.x+=x;
			d.y+=y;
			drawables.push(d);
		}
	}

	inline function set_alpha(v:Float) {
		alpha = v;
		for(e in drawables) e.alpha = v;
		for(e in elements) e.alpha = v;
		for(e in texts) e.alpha = v;
		return v;
	}

	inline function set_visible(v) {
		visible = v;
		for(e in drawables) e.visible = v;
		for(e in elements) e.visible = v;
		for(e in texts) e.visible = v;
		return v;
	}

	public function setPos(x,y) {
		this.x = x;
		this.y = y;
	}

	inline function set_x(v:Float) {
		reposition(v, y);
		this.x = v;
		return v;
	}

	inline function set_y(v:Float) {
		reposition(x, v);
		this.y = v;
		return v;
	}

	function reposition(x:Float, y:Float) {
		if( drawables==null )
			return;

		for(e in elements) {
			e.x-=this.x;
			e.y-=this.y;
			e.x+=x;
			e.y+=y;
		}
		for(e in texts) {
			e.x-=this.x;
			e.y-=this.y;
			e.x+=x;
			e.y+=y;
		}
		for(e in drawables) {
			e.x-=this.x;
			e.y-=this.y;
			e.x+=x;
			e.y+=y;
		}
	}
}
