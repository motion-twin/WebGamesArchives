import flash.display.BitmapData;

class mode.Browser extends Mode
{
	static var THUMBS	= 9;
	static var LINE		= Math.ceil(Math.sqrt(THUMBS));
	static var PAGE		= LINE*LINE;
	static var SCALE	= 1/LINE;

	var world		: levels.SetManager;
	var dimensionId	: int;
	var buffer		: levels.Data;

	var views		: Array<levels.ViewLight>;
	var fields		: Array<TextField>;
	var first		: int;
	var current		: int;
	var initialId	: int;
	var fl_modified	: Array<bool>;
	var fl_buildCache	: bool;
	var cacheId		: int;

	var menuC		: gui.Container;
	var navC		: gui.Container;
	var draw		: MovieClip;

	var footer		: { >MovieClip, field:TextField, scriptIcon:MovieClip };


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m, w, did, fl_mod) {
		super(m);
		_name = "$levelBrowser";
		current = w.currentId;
		initialId = w.currentId;
		dimensionId = did;

		fl_modified 	= fl_mod;
		fl_buildCache	= false;

		world = w;
		world.goto(current);
		updatePage();

		navC = new gui.Container(this,5,-100, Data.DOC_WIDTH-10);
		gui.SimpleButton.attach( navC," GO ", Key.ENTER, callback(this, onValidate) );
		gui.SimpleButton.attach( navC," cancel ", Key.ESCAPE, callback(this, onCancel) );
		gui.SimpleButton.attach( navC," ^ ", Key.UP, callback(this, onPreviousLine) );
		gui.SimpleButton.attach( navC," v ", Key.DOWN, callback(this, onNextLine) );
		gui.SimpleButton.attach( navC," < ", Key.LEFT, callback(this, onPrevious) );
		gui.SimpleButton.attach( navC," > ", Key.RIGHT, callback(this, onNext) );
		gui.SimpleButton.attach( navC," << ", Key.PGUP, callback(this, onPreviousPage) );
		gui.SimpleButton.attach( navC," >> ", Key.PGDN, callback(this, onNextPage) );
		gui.SimpleButton.attach( navC," FIRST ", Key.HOME, callback(this, onFirst) );
		gui.SimpleButton.attach( navC," LAST ", Key.END, callback(this, onLast) );

		var b;
		menuC = new gui.Container(this,5,0, Data.DOC_WIDTH-10);
		menuC.setScale(0.8);
		b = gui.SimpleButton.attach( menuC," <SWAP ", Key.LEFT, callback(this, onMoveBefore) );
		b.setToggleKey(Key.CONTROL);
		b = gui.SimpleButton.attach( menuC," SWAP> ", Key.RIGHT, callback(this, onMoveAfter) );
		b.setToggleKey(Key.CONTROL);
		gui.SimpleButton.attach( menuC," DEL ", Key.DELETEKEY, callback(this, onDelete) );
		gui.SimpleButton.attach( menuC," INS ", Key.INSERT, callback(this, onInsert) );
		gui.SimpleButton.attach( menuC," INS>", 107, callback(this, onInsertAfter) );
		gui.SimpleButton.attach( menuC," CLEAR ", null, callback(this, onClear ) );
		gui.SimpleButton.attach( menuC," CUT ", 88, callback(this, onCut) );
		gui.SimpleButton.attach( menuC," COPY ", 67, callback(this, onCopy) );
		gui.SimpleButton.attach( menuC," PASTE ", 86, callback(this, onPaste) );
		gui.SimpleButton.attach( menuC," SWAP TO BUFFER ", 87, callback(this, onSwapBuffer ) );

		draw = depthMan.empty(Data.DP_INTERF);

		footer = downcast(  depthMan.attach("hammer_editor_footer", Data.DP_INTERF)  );
		footer._x = Data.DOC_WIDTH*0.5;
		footer._y = Data.DOC_HEIGHT-9;
	}


	/*------------------------------------------------------------------------
	INIALISATION
	------------------------------------------------------------------------*/
	function init() {
		super.init();
	}


	/*------------------------------------------------------------------------
	AFFICHAGE THUMBS
	------------------------------------------------------------------------*/
	function refresh() {
		var timer = Std.getTimer();
		var line = Math.floor(1 / SCALE);
		var wid = Data.DOC_WIDTH * SCALE;
		var hei = Data.DOC_HEIGHT * SCALE*1.01;

		for (var i=0;i<views.length;i++) {
			views[i].destroy();
		}
		views = new Array();


		for (var i=0;i<fields.length;i++) {
			fields[i].removeTextField();
		}
		fields = new Array();

		var x=0;
		var y=0;
		var names = new Array();
		var lastTag = null;
		var inc = 0;
		for (var i=0;i<world.levels.length;i++) {
			var tagName = Data.getTagFromLevel(dimensionId, i);
			if ( tagName!=null ) {
				names[i] = tagName;
				lastTag = tagName;
				inc = 0;
			}
			else {
				if ( lastTag!=null ) {
					names[i] = lastTag+"+"+inc;
				}
			}
			inc++;
		}


		for(var i=0;i<THUMBS;i++) {
			if ( i+first<world.levels.length ) {
				var t = Std.createTextField(mc,50000+manager.uniq++);
				t.border			= true;
				t.backgroundColor	= 0x0;
				t.background		= true;
				t._x				= x*wid+10;
				t._y				= y*hei+145;
				t._width			= 115;
				t._height			= 20;
				if ( names[first+i].indexOf("+")>=0 ) {
					t.textColor			= 0xcc9900;
				}
				else {
					t.textColor			= 0xffff00;
				}
				t.text				= (first+i)+": "+names[first+i];
				t.wordWrap			= true;
				t.selectable		= false;
				fields.push(t);

				world.goto(first+i);
				var v = new levels.ViewLight(world, depthMan, first+i);
				v.scale(SCALE);
				v.attach(x*wid+10, y*hei);
				if ( world.isEmptyLevel(first+i,null) ) {
					v.strike();
					t.removeTextField();
				}
				views.push(v);

				timer = Std.getTimer();
				x++;
				if ( x>=line ) {
					y++;
					x=0;
				}
			}
		}



	}



	/*------------------------------------------------------------------------
	FERMETURE DU MODE
	------------------------------------------------------------------------*/
	function endMode() {
		// can't close without validation!
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		for (var i=0;i<fields.length;i++) {
			fields[i].removeTextField();
		}
		fields = new Array();

		super.destroy();
	}


	/*------------------------------------------------------------------------
	MISE À JOUR CURSEUR DE SELECTION
	------------------------------------------------------------------------*/
	function updateBoxes() {
		var v;

		draw.clear();
		// Curseur
		v = views[current-first];
		highlight(v,4,0xffff00);

		// Modifiés
		for (var i=0;i<views.length;i++) {
			v = views[i];
			if ( fl_modified[first+i] ) {
				highlight(v,1,0xff0000);
			}
		}
	}


	/*------------------------------------------------------------------------
	TRACE UN CADRE AUTOUR D'UN NIVEAU
	------------------------------------------------------------------------*/
	function highlight(view,thickness,color) {
		var x = view.mc._x;
		var y = view.mc._y;
		var wid = Data.DOC_WIDTH * SCALE*0.95;
		var hei = Data.DOC_HEIGHT * SCALE;
		draw.lineStyle(thickness,color,100);
		draw.moveTo(x,		y);
		draw.lineTo(x+wid,	y);
		draw.lineTo(x+wid,	y+hei);
		draw.lineTo(x,		y+hei);
		draw.lineTo(x,		y);
	}


	/*------------------------------------------------------------------------
	MISE À JOUR PAGINATION
	------------------------------------------------------------------------*/
	function updatePage() {
		if ( !( current>=first && current<first+THUMBS) ) {
			first = THUMBS * int( Math.max(0, Math.floor( current/THUMBS )) ) ;
			refresh();
		}
	}


	/*------------------------------------------------------------------------
	DÉPLACE UN LEVEL DANS LE SET
	------------------------------------------------------------------------*/
	function swapLevels(from,to) {
		var buffer : levels.Data;
		if ( to<0 || to>=world.levels.length ) {
			return false;
		}

		if ( !world.fl_read[from] ) {
			world.levels[from] = world.unserialize(from);
		}
		if ( !world.fl_read[to] ) {
			world.levels[to] = world.unserialize(to);
		}
		buffer = Data.duplicate( world.levels[from] );
		world.levels[from] = world.levels[to];
		world.levels[to] = buffer;
		world.fl_read[from] = true;
		world.fl_read[to] = true;
		fl_modified[from] = true;
		fl_modified[to] = true;
		current = to;
		refresh();
		return true;
	}


	// *** EVENTS
	function onPrevious() {
		current = int( Math.max( current-1, 0 ) );
		updatePage();
//		refresh();
	}

	function onNext() {
		current = int( Math.min( current+1, world.levels.length-1 ) );
		updatePage();
//		refresh();
	}

	function onPreviousLine() {
		current = int( Math.max( current-LINE, 0 ) );
		updatePage();
//		refresh();
	}

	function onNextLine() {
		current = int( Math.min( current+LINE, world.levels.length-1 ) );
		updatePage();
//		refresh();
	}

	function onPreviousPage() {
		current = int( Math.max( current-PAGE, 0 ) );
		updatePage();
	}

	function onNextPage() {
		current = int( Math.min( current+PAGE, world.levels.length-1 ) );
		updatePage();
	}

	function onFirst() {
		current = 0;
		updatePage();
		refresh();
	}

	function onLast() {
		current = world.levels.length-1;
		updatePage();
		refresh();
	}

	function onValidate() {
		manager.stopChild(current);
	}

	function onCancel() {
		manager.stopChild(initialId);
	}

	function onMoveAfter() {
		if ( swapLevels(current,current+1) ) {
			updatePage();
			refresh();
		}
	}

	function onMoveBefore() {
		if ( swapLevels(current,current-1) ) {
			updatePage();
			refresh();
		}
	}

	function onDelete() {
		if ( world.levels.length==1 ) {
			return;
		}
		world.delete(current);
		fl_modified.splice(current,1);
		for (var i=current;i<world.levels.length;i++) {
			fl_modified[i] = true;
		}
		if ( current>=world.levels.length ) {
			current--;
		}
		world.goto(current);
		if ( current<first ) {
			updatePage();
			refresh();
		}
		else {
			refresh();
		}
	}

	function onInsert() {
		world.insert( current, new levels.Data() );
		for (var i=current;i<world.levels.length;i++) {
			fl_modified[i] = true;
		}
		refresh();
	}

	function onClear() {
		world.levels[current] = new levels.Data();
		fl_modified[current] = true;
		refresh();
	}

	function onCut() {
		buffer = Data.duplicate( world.levels[current] );
		onClear();
	}

	function onCopy() {
		buffer = Data.duplicate( world.levels[current] );
	}

	function onPaste() {
		if ( buffer==null ) {
			return;
		}
		world.levels[current] = Data.duplicate(buffer);
		fl_modified[current] = true;
		refresh();
	}

	function onSwapBuffer() {
		if ( buffer==null ) {
			onCopy();
			world.levels[current] = new levels.Data();
			fl_modified[current] = true;
			refresh();
		}
		else {
			var tmp = Data.duplicate( world.levels[current] );
			world.levels[current] = Data.duplicate(buffer);
			fl_modified[current] = true;
			buffer = tmp;
			refresh();
		}
	}

	function onInsertAfter() {
		if ( current==world.levels.length-1 ) {
			world.push( new levels.Data() );
		}
		else {
			world.insert( current+1, new levels.Data() );
		}
		for (var i=current+1;i<world.levels.length;i++) {
			fl_modified[i] = true;
		}

		current++;
		updatePage();
		refresh();
	}

	function onBuildCache() {
		cacheId = 0;
		fl_buildCache	= true;
		navC.lock();
		menuC.lock();
	}


	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function main() {
		// Mise en cache globale
		if ( fl_buildCache ) {
			manager.progress(cacheId / world.levels.length);
			if ( !world.fl_read[cacheId] ) {
				world.levels[cacheId] = world.unserialize(cacheId);
			}
			cacheId++;
			if ( cacheId>=world.levels.length ) {
				fl_buildCache = false;
				manager.progress(null);
				navC.unlock();
				menuC.unlock();
			}
			else {
				return;
			}
		}

		super.main();
		navC.update();
		menuC.update();
		updateBoxes();

		footer.field.text = current+" / "+(world.levels.length-1);
		if ( world.levels[current].$script!="" && world.levels[current].$script!=null ) {
			footer.scriptIcon._visible = true;
		}
		else {
			footer.scriptIcon._visible = false;
		}
	}

}
