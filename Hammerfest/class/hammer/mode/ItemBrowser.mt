class mode.ItemBrowser extends Mode
{

	static var ITEM_WIDTH	= 65;
	static var ITEM_HEIGHT	= 60;
	static var PAGE_LENGTH	= Math.floor(Data.DOC_WIDTH/ITEM_WIDTH) * Math.floor(Data.DOC_HEIGHT/ITEM_HEIGHT)

	var max_pages	: int;

	var page		: int;
	var mcList		: Array<MovieClip>;
	var fl_score	: bool;
	var fl_names	: bool;

	var klock		: int;

	var header		: { >MovieClip, field:TextField };
	var footer		: { >MovieClip, field:TextField };
	var ffilter		: int;

	var fullRandList: Array<int>;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		super(m);
		_name = "$itemBrowser";

		page		= 0;
		mcList		= new Array();
		fl_score	= true;
		fl_names	= false;

		header		= downcast(  depthMan.attach("hammer_editor_footer", Data.DP_TOP)  );
		header._x	= Data.DOC_WIDTH*0.5;
		header._y	= 7;
		header.field.text	= "--";

		footer		= downcast(  depthMan.attach("hammer_editor_footer", Data.DP_TOP)  );
		footer._x	= Data.DOC_WIDTH*0.5;
		footer._y	= Data.DOC_HEIGHT-7;

		ffilter		= -1;

		fullRandList	= new Array();
		for (var fid=0;fid<Data.SCORE_ITEM_FAMILIES.length;fid++) {
			var f = Data.SCORE_ITEM_FAMILIES[fid];
			for (var i=0;i<f.length;i++) {
				fullRandList[ f[i].id ] = f[i].r;
			}
		}
		for (var fid=0;fid<Data.SPECIAL_ITEM_FAMILIES.length;fid++) {
			var f = Data.SPECIAL_ITEM_FAMILIES[fid];
			for (var i=0;i<f.length;i++) {
				fullRandList[ f[i].id ] = f[i].r;
			}
		}


		refresh();
	}


	/*------------------------------------------------------------------------
	RENVOIE LE CODE COULEUR ASSOCIÉ À UN INDICE DE RARETÉ
	------------------------------------------------------------------------*/
	function getRandColor(proba) {
		var col=0x555555;
		switch (proba) {
			case Data.__NA: col=0xaaaaaa; break;
			case Data.COMM: col=0x00ff00; break;
			case Data.UNCO: col=0xffff00; break;
			case Data.RARE: col=0xff9900; break;
			case Data.UNIQ: col=0xff0000; break;
			case Data.MYTH: col=0x4444ff; break;
			case Data.CANE: col=0x35ece2; break;
			case Data.LEGEND: col=0xff44ff; break;
		}
		return col;
	}


	/*------------------------------------------------------------------------
	MISE À JOUR PAGE EN COURS
	------------------------------------------------------------------------*/
	function refresh() {
		var base;

		// Destruction
		for (var i=0;i<mcList.length;i++) {
			mcList[i].removeMovieClip();
		}
		mcList = new Array();

		// Sélection du set d'items
		var set_link;
		if ( fl_score ) {
			set_link	= "hammer_item_score";
			base		= 1000;
		}
		else {
			base		= 0;
			set_link	= "hammer_item_special";
		}
		max_pages = Math.ceil(Data.MAX_ITEMS/PAGE_LENGTH);

		// Affichage
		var x = 0;
		var y = 0;
		var i : int = Math.floor(page*PAGE_LENGTH);

		while ( i<Data.MAX_ITEMS && i<(page+1)*PAGE_LENGTH ) {
			var mc = depthMan.attach(set_link,Data.DP_ITEMS);
			mc.blendMode = BlendMode.LAYER;
			mc._x = x + ITEM_WIDTH*0.5;
			mc._y = y + ITEM_HEIGHT-7;
			mc.gotoAndStop( ""+(i+1) );
			mc.onRollOver = callback(this,onOver,i+base);
			downcast(mc).sub.stop();
			if ( i+1 > mc._totalframes ) {
				mc._visible = false;
			}
			mcList.push(mc);
			if ( fl_names ) {
				if ( !(fl_score && Data.ITEM_VALUES[i+base]==null) && !(!fl_score && Data.FAMILY_CACHE[i+base]==null) ) {
					var name = Lang.getItemName(i+base);
					if ( name!=null || name=="" ) {
						var t = Std.createTextField(mc,manager.uniq++);
						t.border			= true;
						t.background		= true;
						if ( name==null ) {
							t.borderColor		= 0xff0000;
							t.backgroundColor	= 0x770000;
						}
						else {
							t.borderColor		= 0xaaaaaa;
							t.backgroundColor	= 0x0;
						}
						t._x		= -20;
						t._y		= -35;
						t._width	= 60;
						t._height	= 40;
						t.textColor	= 0xffffff;
						t.text		= name
						t.wordWrap	= true;
						t.selectable= false;
						t._xscale	= 90;
						t._yscale	= t._xscale;
					}
				}
			}
			else {
				if ( ffilter<0 ) {
					if ( fullRandList[i+base]==null ) {
						mc._alpha = 75;
					}
				}
				else {
					if ( ffilter+base != Data.FAMILY_CACHE[i+base] ) {
						var f = new flash.filters.BlurFilter();
						f.blurX		= 8;
						f.blurY		= f.blurX;
						mc.filters	= [f];
						mc._alpha	= 40;
					}
				}
			}

			var label = depthMan.attach("hammer_editor_simple_label",Data.DP_INTERF);
			label._x = x+ITEM_WIDTH*0.5;
			label._y = y+ITEM_HEIGHT;


			// Text content
			var field = downcast(label).field;
			if ( fl_score ) {
				if ( Data.ITEM_VALUES[i+base]==null ) {
					field.text = "("+(i+base)+")[--]\n--";
				}
				else {
					field.text = "("+(i+base)+")["+(Data.FAMILY_CACHE[i+base])+"]\n"+Data.ITEM_VALUES[i+base];
				}
			}
			else {
				if ( Data.FAMILY_CACHE[i+base]==null ) {
					field.text = "("+(i+base)+")[--]\n--";
				}
				else {
					field.text = "("+(i+base)+")["+(Data.FAMILY_CACHE[i+base])+"]";
				}
			}


			// Text color
			if ( ffilter<0 ) {
				field.textColor = getRandColor( fullRandList[i+base] );
			}
			else {
				if ( ffilter+base==Data.FAMILY_CACHE[i+base] ) {
					field.textColor = getRandColor( fullRandList[i+base] );
				}
				else {
					field.textColor = 0x555555;
				}
			}
			if ( Data.FAMILY_CACHE[i+base]==null ) {
				field.textColor = 0xffffff;
			}


			mcList.push(label);
			x+=ITEM_WIDTH;
			if ( x >= Data.DOC_WIDTH-ITEM_WIDTH ) {
				x=0;
				y+=ITEM_HEIGHT;
			}
			i++;
		}


		// Indicateur de page
		footer.field.text = "";
		if ( fl_score ) {
			footer.field.text += "Score items, ";
		}
		else {
			footer.field.text += "Special items, ";
		}
		if ( ffilter>=0 ) {
			footer.field.text += " | Filter: "+Lang.getFamilyName(ffilter+base)+" ("+(ffilter+base)+") | ";
		}
		footer.field.text += "PAGE "+(page+1)+"/"+max_pages;
	}


	function onOver(id:int) {
		header.field.text = Lang.getItemName(id);
	}

	/*------------------------------------------------------------------------
	FIN DE MODE
	------------------------------------------------------------------------*/
	function endMode() {
		if ( fl_runAsChild ) {
			manager.stopChild(null);
		}
	}


	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function main() {
		super.main();


		if ( klock!=null && !Key.isDown(klock) ) {
			klock = null;
		}

		if ( Key.isDown(Key.LEFT) && page>0 && klock!=Key.LEFT ) {
			page--;
			refresh();
			klock = Key.LEFT;
		}

		if ( Key.isDown(Key.RIGHT) && page<max_pages-1 && klock!=Key.RIGHT ) {
			page++;
			refresh();
			klock = Key.RIGHT;
		}

		if ( Key.isDown(Key.SPACE) && klock!=Key.SPACE ) {
			fl_score	= !fl_score;
			ffilter		= -1;
			page		= 0;
			klock		= Key.SPACE;
			refresh();
		}

		if ( fl_names != Key.isDown(78) ) { // N
			fl_names = Key.isDown(78);
			refresh();
		}

		if ( Key.isDown(Key.PGUP) && ffilter>-1 && klock!=Key.PGUP ) {
			ffilter--;
			refresh();
			klock = Key.PGUP;
		}
		if ( Key.isDown(Key.PGDN) && klock!=Key.PGDN ) {
			ffilter++;
			refresh();
			klock = Key.PGDN;
		}

		if ( Key.isDown(Key.ESCAPE) ) {
			endMode();
		}

		Log.print(fl_names);
	}

}

