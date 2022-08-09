class mode.QuestBrowser extends Mode
{

	static var ITEM_WIDTH	= 40;
	static var ITEM_HEIGHT	= 25;

	var quests		: XmlNode;
	var max_pages	: int;

	var mcList		: Array<MovieClip>;

	var klock		: int;

	var footer		: { >MovieClip, field:TextField };
	var desc		: TextField;
	var qfilter		: int;

	var fullRandList: Array<int>;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		super(m);
		_name = "$questBrowser";

		mcList = new Array();

		footer		= downcast(  depthMan.attach("hammer_editor_footer", Data.DP_TOP)  );
		footer._x	= Data.DOC_WIDTH*0.5;
		footer._y	= Data.DOC_HEIGHT-7;

		qfilter		= 0;

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

		var raw = Std.getVar(manager.root,"xml_quests");
		quests = new Xml(raw).firstChild;

		desc = Std.createTextField(mc,manager.uniq++);
		desc._x			= 0;
		desc._y			= 415;
		desc._width		= Data.DOC_WIDTH;
		desc._height	= 100;
		desc.textColor	= 0x7777cc;
		desc.wordWrap	= true;
		desc.html		= true;
		desc.selectable	= false;

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
		// Destruction
		for (var i=0;i<mcList.length;i++) {
			mcList[i].removeMovieClip();
		}
		mcList = new Array();

		var current = getQuest(qfilter);
		var node = current.firstChild;
		var n = 0;
		while ( node!=null ) {
			var mc=null;
			switch ( node.nodeName ) {
				case "$require".substring(1):
					var id	= Std.parseInt( node.get("$item".substring(1)), 10 );
					var qty	= Std.parseInt( node.get("$qty".substring(1)), 10 );

					var link = (id>=1000) ? "hammer_item_score" : "hammer_item_special" ;
					mc = depthMan.attach(link,Data.DP_ITEMS);
					mc.blendMode = BlendMode.LAYER;
					mc._x = 20;
					mc._y = 30+n*ITEM_HEIGHT;
					mc._xscale = 75;
					mc._yscale = mc._xscale;
					if ( id>=1000 ) {
						mc.gotoAndStop( ""+(id-1000+1) );
					}
					else {
						mc.gotoAndStop( ""+(id+1) );
					}

					var t = Std.createTextField(mc,manager.uniq++);
					t._x		= ITEM_WIDTH;
					t._y		= -30;
					t._width	= 350;
					t._height	= ITEM_HEIGHT;
					t.textColor	= getRandColor( fullRandList[id] );
					t.text		= "\tx "+qty+" \t\t\t"+id+" ("+Lang.getItemName(id)+")";
					t.wordWrap	= false;
					t.selectable= false;
					t._xscale	= 250-mc._xscale;
					t._yscale	= t._xscale;

				break;

				case "$give".substring(1):
				case "$remove".substring(1):
					mc = depthMan.empty(Data.DP_INTERF);
					mc._x = 10;
					mc._y = 30+n*ITEM_HEIGHT;
					var t = Std.createTextField(mc,manager.uniq++);
					t._x	= 0;
					t._y	= -20;
					t._width= 380;
					if ( node.nodeName=="$remove".substring(1) ) {
						t.textColor	= 0xff6666;
					}
					else {
						t.textColor	= 0xffff00;
					}
					var fid = Std.parseInt( node.get("$family".substring(1)), 10 );
					if ( !Std.isNaN(fid) ) {
						var name = Lang.getFamilyName(fid);
						if ( name==null ) {
							name="SYSTEM FAMILY";
						}
						t.text	= node.nodeName.toUpperCase()+" "+fid+" ('"+name+"')";
					}
					else {
						var option = node.get("$option".substring(1));
						if ( option!=null ) {
							t.text	= "option ["+option+"]";
							t.textColor	= 0xffffff;
						}
						var bank = Std.parseInt( node.get("$bank".substring(1)), 10 );
						if ( !Std.isNaN(bank) ) {
							t.text	= "bank upgrade (+"+bank+")";
							t.textColor	= 0xffffff;
						}
						var tokens = Std.parseInt( node.get("$tokens".substring(1)), 10 );
						if ( !Std.isNaN(tokens) ) {
							t.text	= node.nodeName.toUpperCase()+" Tokens +"+tokens;
							t.textColor	= 0x00ffff;
						}
						var modeName = node.get("$mode".substring(1));
						if ( modeName!=null ) {
							t.text = "mode ["+modeName+"]";
							t.textColor = 0xff00ff;
						}
					}
				break;
			}
			node = node.nextSibling;
			n++;
			mcList.push(mc);
		}

		// Indicateur de page
		var id = Std.parseInt( current.get("$id".substring(1)), 10);
		desc.htmlText = "<p align=\"right\">"+Lang.getQuestDesc(id)+"</p>";
		footer.field.text = "Quest #"+id+", "+Lang.getQuestName(id);
	}


	/*------------------------------------------------------------------------
	RENVOIE LA NODE D'UNE QUÊTE DONNÉE
	------------------------------------------------------------------------*/
	function getQuest(id:int) {
		var q = null;
		var node = quests.firstChild;
		while ( node!=null && q==null ) {
			if ( node.get("$id".substring(1))==(id+"") ) {
				q = node;
			}
			node = node.nextSibling;
		}
		return q;
	}


	/*------------------------------------------------------------------------
	FIN DE MODE
	------------------------------------------------------------------------*/
	function endMode() {
		if ( fl_runAsChild ) {
			manager.stopChild(null);
		}
	}


	function destroy() {
		desc.removeTextField();
		super.destroy();
	}


	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function main() {
		super.main();

		if ( klock!=null && !Key.isDown(klock) ) {
			klock = null;
		}

		if ( Key.isDown(Key.LEFT) && qfilter>0 && klock!=Key.LEFT ) {
			qfilter--;
			refresh();
			klock = Key.LEFT;
		}

		if ( Key.isDown(Key.RIGHT) && qfilter<999 && klock!=Key.RIGHT ) {
			qfilter++;
			refresh();
			klock = Key.RIGHT;
		}


		if ( Key.isDown(Key.PGUP) && qfilter>0 && klock!=Key.PGUP ) {
			qfilter-=10;
			if ( qfilter<0 ) { qfilter=0; }
			refresh();
			klock = Key.PGUP;
		}

		if ( Key.isDown(Key.PGDN) && qfilter<999 && klock!=Key.PGDN ) {
			qfilter+=10;
			refresh();
			klock = Key.PGDN;
		}

		if ( Key.isDown(Key.ESCAPE) ) {
			endMode();
		}
	}

}

