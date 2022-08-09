package ui.side;

import Data;
import mt.MLib;
import mt.data.GetText;
import com.*;
import com.Protocol;

class PremiumShop extends ui.SideMenu {
	public static var CURRENT : PremiumShop;
	var isize			: Int;
	var fx				: Fx;

	public function new() {
		CURRENT = this;

		super();

		name = "PremiumShop";
		bhei = isSmall() ? 100 : 130;
		isize = 90;

		fx = new Fx(this, wrapper, 50,50);

		Game.ME.unselect();

		onResize();
	}


	override function open() {
		super.open();

		ui.HudMenuTip.clear("premium");
	}


	override function refresh() {
		super.refresh();

		clearContent();

		addTitle(Lang.t._("Permanent upgrades"));
		addText(Lang.t._("Every upgrade purchased from this panel will be available permanently on your hotel."), Const.TEXT_GRAY);
		addSpecialButton("moneyGem", Lang.t._("Get more gems!"), Game.ME.openBuyGems.bind());

		var allPremiums = Data.Premium.all.toArrayCopy();

		var all = allPremiums.filter( function(e) return !shotel.hasPremiumUpgrade(e.id) && ( e.require==null || shotel.hasPremiumUpgrade(e.requireId) ) );
		//all.sort( function(a,b) return -Reflect.compare(a.id, b.id) );

		for( e in all )
			addUpgrade( e );

		var all = allPremiums.filter( function(e) return shotel.hasPremiumUpgrade(e.id) );
		if( all.length>0 ) {
			addTitle( Lang.t._("Active upgrades") );
			all.sort( function(a,b) return Reflect.compare(a.id, b.id) );
			for( e in all )
				addBoughtUpgrade( e );
		}
	}


	override function canDrag(value:Dynamic) {
		return false;
	}


	function addUpgrade(e:Data.Premium) {
		var inf = Lang.getPremium(e.id);
		var locked = e.featureReq!=null && !shotel.featureUnlocked(e.featureReq);

		var canBuy = !locked && !shotel.hasPremiumUpgrade(e.id);
		var b = createButton(function() {
			if( !canBuy ) {
				var q = new ui.Question();
				q.addText(inf.name, Assets.tiles.exists(e.iconId)?e.iconId:null, Const.TEXT_GEM, false, 1.4);
				q.addSeparator();
				q.addText( inf.desc, false );
				q.addSeparator();
				q.addText( Lang.t._("Sorry, you cannot buy this upgrade yet: your hotel need more STARS."), 0xC62031 );
				q.addButton(Lang.t._("Unlock permanently"), false, function() {});
				q.addCancel();
				return;
			}

			if( Game.ME.tuto.isRunning("premium") ) {
				Game.ME.runSolverCommand( DoBuyPremium(e.id.toString()) );
			}
			else {
				var q = new ui.Question();
				q.addText(inf.name, Assets.tiles.exists(e.iconId)?e.iconId:null, Const.TEXT_GEM, false, 1.4);
				q.addSeparator();
				q.addText( inf.desc );
				var label = e.price>1 ? Lang.t._("Unlock permanently (::n:: GEMS)", {n:e.price}) : Lang.t._("Unlock permanently (1 GEM)");
				q.addButton(label, "moneyGem", function() {
					Game.ME.runSolverCommand( DoBuyPremium(e.id.toString()) );
					close();
				});
				q.addCancel();
			}
		}, e.id.toString());

		b.enableRollover();

		// Icon bg
		var ibg = b.addElement("iconBg", "white", 0.5,0.5);
		ibg.constraintSize(isize);
		ibg.setPos(10+isize*0.5, bhei*0.5);
		ibg.colorize(0x49053E);

		// Icon
		var icon = b.addElement("icon", !Assets.tiles.exists(e.iconId) ? "iconTodoRed" : e.iconId,0, 0.5,0.5);
		icon.constraintSize(isize * (e.bigIcon?0.75:0.55));
		icon.setPos(10+isize*0.5, canBuy ? bhei*0.43 : bhei*0.5);
		icon.alpha = canBuy ? 1 : 0.3;

		// Icon circle
		var circle = b.addElement("circle", canBuy ? "sideIconPrice":"sideIconOff", 0.5,0.5);
		circle.width = circle.height = isize;
		circle.setPos(icon.x, bhei*0.5);


		// Name
		var name = b.addText("name",  inf.name, 28);
		name.x = icon.x + isize*0.5+10;
		name.textColor = canBuy ? Const.TEXT_GEM : Const.TEXT_GRAY;

		// Price
		if( canBuy ) {
			var iw = 20;
			var price = b.addText("price", cast Game.ME.prettyNumber(e.price), 25);
			price.textColor = Const.TEXT_GEM;
			price.x = iw*0.5 + icon.x - price.textWidth*price.scaleX*0.5;
			price.y = bhei*0.5 + isize*0.14;
			price.dropShadow = { color:0x0, alpha:0.7, dx:0, dy:1 }
			var picon = b.addElement("picon", "moneyGem",0, 0.5,0.5);
			picon.constraintSize(iw);
			picon.setPos(price.x-iw*0.5, price.y + price.textHeight*price.scaleY*0.5);
		}

		// Desc
		var desc : h2d.TextBatchElement = null;
		if( !isSmall() ) {
			desc = b.addText("desc", !canBuy ? Lang.t._("You need more hotel stars to unlock this upgrade!") : inf.desc, 17);
			desc.x = name.x;
			desc.maxWidth = (wid-desc.x-10)/desc.scaleX;
			desc.textColor = canBuy ? Const.TEXT_GOLD : Const.TEXT_GRAY;
			desc.alpha = canBuy ? 1 : 0.7;
		}

		// Text vertical align
		var th = name.textHeight*name.scaleY + (desc!=null?desc.textHeight*desc.scaleY:0);
		name.y = bhei*0.5 - th*0.5;
		if( desc!=null )
			desc.y = name.y + 32;


		createChildProcess(function(p) {
			if( destroyed || b.destroyed )
				p.destroy();
			else if( isOpen && !isMoving() && !Game.ME.hasAnyPopUp() && itime%7==0 ) {
				fx.shineSquare("yellowShine", 10, b.getY()+bhei*0.5-isize*0.5, isize, isize, 1);
			}
		}, true);

		// New label
		//var isNew = false;
		//if( isNew ) {
			//var bg = b.addElement("newBg", "newBanner");
			//bg.width = isize;
			//bg.height = 20;
			//bg.x = icon.x;
			//bg.y = bhei*0.5 + icon.height - bg.height -5;
//
			//var n = b.addText("newTxt", Lang.t._("NEW!"), 14);
			//n.x = bg.x + isize*0.5 - n.textWidth*n.scaleX*0.5;
			//n.y = bg.y+1;
			//n.textColor = 0x003A82;
		//}

		b.position();
	}



	function addBoughtUpgrade(e:Data.Premium) {
		var inf = Lang.getPremium(e.id);

		var b = createButton( function() {
			var q = new ui.Question();
			q.addText(inf.name, Const.TEXT_GEM);
			q.addText(inf.desc);
			q.addOk();
		}, e.id.toString());
		b.enableRollover();

		// Icon
		var icon = b.addElement("icon", !Assets.tiles.exists(e.iconId) ? "iconTodoRed" : e.iconId,0, 0.5,0.5);
		icon.constraintSize(isize * (e.bigIcon?0.8:0.55));
		icon.setPos(10+isize*0.5, bhei*0.5);

		// Icon circle
		var circle = b.addElement("circle", "sideIcon", 0.5,0.5);
		circle.width = circle.height = isize;
		circle.setPos(icon.x, bhei*0.5);

		// Name
		var name = b.addText("name",  inf.name, 28);
		name.x = icon.x + isize*0.5+10;
		name.textColor = Const.TEXT_GEM;
		name.y = bhei*0.5 - name.textHeight*name.scaleY*0.5;

		b.position();
	}


	function addSpecialButton(icon:String, label:LocaleString, cb:Void->Void) {
		var col = Const.TEXT_GEM;

		var b = createButton(function() {
			Assets.SBANK.click1(1);
			if( !Game.ME.tuto.commandLocked("side") )
				cb();
		});
		b.enableRollover();
		b.autoHide = false;

		var isize = 64;

		var p = 4;
		var bg = b.addElement("bg", "white");
		bg.color = h3d.Vector.fromColor(alpha(0x074B96));
		bg.y = p;
		bg.width = wid;
		bg.height = bhei-p*2;
		var e = b.addElement("top", "popUpTop");
		e.y = p;
		e.width = wid;
		var e = b.addElement("bottom", "popUpBottom");
		e.width = wid;
		e.y = bhei-e.height-p;
		createChildProcess(function(p) {
			if( destroyed || b.destroyed )
				p.destroy();
			else if( isOpen && !isMoving() && !Game.ME.hasAnyPopUp() ) {
				bg.alpha = 0.7 + 0.3*Math.cos(ftime*0.2);
				if( itime%2==0 )
					fx.shineSquare("blueShine", 10, b.getY()+bhei*0.5-isize*0.5, isize, isize, 1);
			}
		}, true);

		var icon = b.addElement("icon", icon);
		icon.setScale( isize/icon.height );
		icon.tile.setCenterRatio(0.5,0.5);
		icon.x = 10 + isize*0.5;
		icon.y = bhei*0.5;

		var th = 0.;

		// Label
		var label = b.addText("name", label, 28);
		label.x = icon.x + isize*0.5 + 10;
		label.maxWidth = (wid - label.x - 10 ) / label.scaleX;
		label.textColor = col;
		th += label.textHeight*label.scaleY;

		label.y += bhei*0.5 - th*0.5;

		b.position();
	}


	override function onResize() {
		super.onResize();
	}


	override function onDispose() {
		fx.destroy();
		fx = null;

		super.onDispose();

		if( CURRENT==this )
			CURRENT = null;
	}
}