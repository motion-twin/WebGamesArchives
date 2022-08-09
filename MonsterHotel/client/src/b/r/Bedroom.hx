package b.r;

import com.Protocol;
import com.SRoom;
import com.GameData;
import mt.MLib;
import mt.deepnight.Color;
import b.Room;
import h2d.SpriteBatch;
import h2d.Bitmap;
import Data;

class Bedroom extends b.Room {
	var godLights			: Array<BatchElement>;
	var wallPaint			: Null<BatchElement>;
	var colorDiffuse		: Null<BatchElement>;
	var wallTex				: Null<TiledTexture>;

	public function new(x,y) {
		godLights = [];

		super(x,y);
	}


	override function finalize() {
		super.finalize();

		var c = getClientInside();
		if( c!=null )
			c.xx = globalLeft + wid * rnd(0.3, 0.7);

		updateLight();
	}

	function updateLight() {
		//light.set( countClients()>=1 && !getClientInside().isDone() );
	}


	override function clearContent() {
		super.clearContent();

		colorDiffuse = null;

		if( wallPaint!=null ) {
			wallPaint.remove();
			wallPaint = null;
		}

		if( wallTex!=null ) {
			wallTex.dispose();
			wallTex = null;
		}

		for(e in godLights)
			e.remove();
		godLights = [];
	}


	override function renderWall() {
		super.renderWall();

		if( sroom.custom.color=="raw" && sroom.custom.texture==-1 ) {
			// Raw painting
			wall.tile = Assets.rooms.getTile("roomNew");
		}
		else {
			// Paint
			wall.visible = false;
			var cid = sroom.custom.color;
			var c = DataTools.getWallColorCode(cid, true);
			wallPaint = Assets.tiles.addBatchElement(Game.ME.tilesSb, 99, "white", 0);
			wallPaint.color = h3d.Vector.fromColor(c);
			wallPaint.x = globalLeft;
			wallPaint.y = globalTop;
			wallPaint.width = wid;
			wallPaint.height = hei;

			// Paper
			if( sroom.custom.texture>=0 ) {
				wallTex = new TiledTexture(Game.ME.customsSb, Assets.custo0, globalLeft,globalTop, wid,hei);
				wallTex.fill( "wallPaper", sroom.custom.texture, 0.8, 0.35 );
			}
		}

		var e = addBE("wallGradient");
		e.alpha = 0.5;
		e.width = wid-170;
		e.height = hei;
	}

	override function renderContent() {
		super.renderContent();

		// Luxury
		if( sroom.level>0 ) {
			var e = addBE(-10, "roomLuxe", sroom.level-1);
			if( e!=null ) {
				//e.width = wid*0.5;

				// Right part (mirror)
				var e = addBE(-10, "roomLuxe", sroom.level-1);
				e.x = globalRight;
				e.y = globalTop;
				e.scaleX = -1;
				//e.width = -wid*0.5;
			}
		}


		// God lights
		if( sroom.getSunlight()>0 ) {
			if( !shotel.hasRoomExceptFiller(rx-1, ry) ) {
				var e = addAdditiveBE("godLightDay");
				godLights.push(e);
				e.alpha = 0.9;
				e.scaleX = 0.6;
				e.scaleY = 1.2;
				e.x = globalLeft-10;
				e.y = globalBottom - padding - e.height +35;
			}
			if( !shotel.hasRoomExceptFiller(rx+1, ry) ) {
				var e = addAdditiveBE("godLightDay");
				godLights.push(e);
				e.alpha = 0.9;
				e.scaleX = -0.6;
				e.scaleY = 1.2;
				e.x = globalRight+10;
				e.y = globalBottom - padding - e.height +35;
			}
		}

		// Bath
		if( sroom.custom.bath>=0 ) {
			var e = addCustomBE(-2, "bath", sroom.custom.bath);
			e.tile.setCenterRatio(0,1);
			e.x = globalLeft + padding;
			e.y = globalBottom-padding;
			e.scale(0.85);
		}

		// Bed
		if( sroom.custom.bed>=0 ) {
			var e = addCustomBE(-2, "bed", sroom.custom.bed );
			e.tile.setCenterRatio(1,1);
			e.x = globalRight - padding - 2;
			e.y = globalBottom-padding;
		}
		else {
			// Default bed
			//var e = addCustomBE(-2, "bedDefault" );
			//e.tile.setCenterRatio(1,1);
			//e.x = globalRight - padding - 2;
			//e.y = globalBottom-padding;
		}

		// Ceil
		if( sroom.custom.ceil>=0 ) {
			var e = addCustomBE(-3, "ceil", sroom.custom.ceil );
			e.tile.setCenterRatio(0.5,0);
			e.x = globalCenterX;
			e.y = globalTop+padding;
			var e = addAdditiveBE("glowRoom", 0.5, 0);
			e.x = globalCenterX;
			e.y = globalTop;
			e.scaleX = 3;
			e.scaleY = 2;
			e.alpha = 0.9;
		}

		// Furn
		if( sroom.custom.furn>=0 ) {
			var e = addCustomBE(-1, "furn", sroom.custom.furn );
			e.tile.setCenterRatio(0.5,1);
			e.x = globalCenterX-40;
			e.y = globalBottom-padding;
			e.scale(0.85);
		}

		// Paintings
		if( sroom.custom.wall>=0 ) {
			var e = addCustomBE(0, "wall", sroom.custom.wall );
			e.tile.setCenterRatio(0.5,0.5);
			e.x = globalRight-padding-85;
			e.y = globalTop+padding+75;

			if( Data.WallFurn.all[sroom.custom.wall].hasGlow ) {
				var e = addAdditiveBE("glowRoom", 0.5, 0);
				e.x = globalRight-padding;
				e.y = globalTop + hei*0.35;
				e.scaleX = 4;
				e.scaleY = 4;
				e.rotation = MLib.PIHALF;
				e.alpha = 0.8;
			}
		}

		// Diffuse layer
		var wc = Data.DataTools.getWallColorCode(sroom.custom.color);
		var e = addCustomBE(-10, "white");
		colorDiffuse = e;
		e.color = h3d.Vector.fromColor(alpha(wc, 1));
		e.setPos(globalLeft, globalTop);
		e.width = wid;
		e.height = hei;
		e.alpha = 0.3;

		updateLight();
	}

	override function updateHud() {
		super.updateHud();

		for(c in getAllClientsInside())
			if( !c.destroyAsked && c.sclient!=null && !c.isDone() && c.isInRealRoom() ) {
				var m = 20;

				var bg = Assets.tiles.hbe_get(g.tilesFrontSb, "squareBlue");
				hudElements.push(bg);

				var corner = Assets.tiles.hbe_get(g.tilesFrontSb, "blueCorner");
				hudElements.push(corner);

				// Icon size
				var n = 0;
				var isize = 50.;
				var count = c.sclient.likes.length + c.sclient.dislikes.length + (c.sclient.money>0 ? 1 : 0);
				if( count>=6 )
					isize*=0.6;
				else if( count>=4 )
					isize*=0.85;

				// Likes
				for(a in c.sclient.likes) {
					var icon = Assets.tiles.hbe_get(g.tilesFrontSb, Assets.getAffectIcon(a), 0);
					icon.constraintSize(isize);
					icon.setPos(globalLeft + m, globalTop + m + n*isize);
					hudElements.push(icon);

					var be = Assets.tiles.hbe_get(g.tilesFrontSb, "moneyLove", 0, 0.5, 0.5);
					be.constraintSize(isize*0.6);
					be.x = icon.x + 5;
					be.y = icon.y + icon.height*0.5;
					hudElements.push(be);

					n++;
				}

				// Dislikes
				for(a in c.sclient.dislikes) {
					var icon = Assets.tiles.hbe_get(g.tilesFrontSb, Assets.getAffectIcon(a), 0);
					icon.constraintSize(isize);
					icon.setPos(globalLeft + m, globalTop + m + n*isize);
					hudElements.push(icon);

					var be = Assets.tiles.hbe_get(g.tilesFrontSb, "iconRemove", 0, 0.5, 0.5);
					be.constraintSize(isize*0.6);
					be.x = icon.x + 5;
					be.y = icon.y + icon.height*0.5;
					hudElements.push(be);

					n++;
				}

				// Cash
				if( shotel.hasRoomType(R_Bar) ) {
					if( shotel.featureUnlocked("savings") && c.sclient.money>0 ) {
						var money = c.sclient.money;
						var x = 0;
						var w = isize*0.7;
						var mw = MLib.max(2, 15 - (money-2)*2);
						for(i in 0...money) {
							var icon = Assets.tiles.hbe_get(g.tilesFrontSb, "moneyBill", 0, 0.5,0);
							icon.constraintSize(w);
							icon.setPos(globalLeft + m + 5 + isize*0.5 - money*mw*0.5 + x*mw, globalTop + m + n*isize + i*2);
							hudElements.push(icon);
							x++;
						}
						n++;
					}
				}
				bg.x = globalLeft;
				bg.y = globalTop;
				bg.width = m + isize;
				bg.height = m + n*isize - 10;
				//bg.alpha = 0.85;

				corner.setSize(isize+m, 20);
				corner.setPos(bg.x, bg.y+bg.height);
				corner.alpha = bg.alpha;
			}
	}

	override function onClientInstalled(c) {
		super.onClientInstalled(c);

		c.xx = globalLeft + wid*rnd(0.35, 0.65);
		c.yy = globalBottom;
		//c.postUpdate();
	}

	override function onClientLeave(c) {
		super.onClientLeave(c);
	}

	override function onDispose() {
		super.onDispose();
	}

	public function onTheft() {
		var d = Const.seconds(1);
		cd.set("theft", d);
		cd.set("theftArrive", d*0.5);
		cd.onComplete("theftArrive",  function() {
			openDoor(false);
		});
		requireGrooms(1, false);
		for(e in getGroomsInside())
			e.setPos(globalLeft+50, globalBottom);
		openDoor(true);
	}

	function onClickValidate() {
		Game.ME.runSolverCommand( DoValidateClient(getClientInside().id) );
		return true;
	}

	function onClickSkipClient() {
		var c = getClientInside();
		Game.ME.runSolverCommand( DoSkipClient(c.id) );
		//Game.ME.chainCommands([
			//DoSkipClient(c.id),
			//DoValidateClient(c.id),
		//]);
		return true;
	}


	//override function getProblem() {
		//if( sroom.isDamaged() && !shotel.hasRoomType(R_StockSoap,true) && countClients()==0 )
			//return {
				//icon	: Assets.getStockIconId(R_StockSoap),
				//desc	: Lang.t._("This bedroom is dirty: you need a Soap Storage to wash it!"),
			//}
		//else
			//return super.getProblem();
	//}


	override function update() {
		super.update();

		var c = getClientInside();

		if( !Game.ME.tuto.isRunning() )
			colorDiffuse.alpha = c!=null ? ( shotel.level>=8 ? 0.5 : 0.35 ) : 0.15;

		var task = getTaskTimer();
		//timer.visible = !Game.ME.isVisitMode() && !Game.ME.hideUI && task!=null && (
		timer.visible = timer.visible && task!=null && (
			isSelected() ||
			isWorking() ||
			isUnderConstruction() ||
			task.end-Game.ME.serverTime<=DateTools.minutes(1)
		);
		if( timer.visible ) {
			var h = timer.textHeight*timer.scaleY * Game.ME.totalScale;
			if( h<15 )
				timer.visible = false;
		}

		// Hide long duration bars
		if( task!=null && shotel.level==1 && task.end-Game.ME.serverTime>=DateTools.days(3)  ) {
			if( bar!=null )
				bar.hide();
			timer.visible = false;
		}

		if( c==null ) {
			if( isWorking() && task!=null )
				setBarDuration(task.start, task.end);
			else
				clearBar();
		}

		// Validate
		updateRoomButton(
			"validate",
			"iconLeave",
			c!=null && c.isDone() && !cd.has("clientLeaving"),
			onClickValidate
		);

		// Skip button (gem)
		updateRoomButton(
			"skipClientGem",
			"moneyGem",
			shotel.featureUnlocked("gems") && c!=null && !c.isDone() && !c.sclient.happinessMaxed() && c.sclient.canBeSkipped(Game.ME.serverTime),
			onClickSkipClient,
			Main.ME.settings.confirmGems ? Lang.t._("Make this client happy and get paid immediatly?") : null
		);

		if( itime%30==0 )
			updateLight();

		// Groom
		requireGrooms( cd.has("theft") || isWorking() ? 1 : 0, false );
		for( e in getGroomsInside() ) {
			if( cd.has("theft") && c!=null ) {
				if( cd.has("theftArrive") )
					e.iaGoto(c.centerX-70-globalLeft, true);
				else
					e.iaGoto(60, true);
			}
			else {
				e.activity = G_Clean;
				e.iaWander();
			}
		}

		// Godlights hidden
		for(e in godLights)
			e.visible = !isUnderConstruction();

		// Client
		if( c!=null ) {
			if( c.isDone() ) {
				clearBar();
				if( c.cd.has("doorAnim") )
					c.iaGoto(80, -1, true);
				else
					c.iaGoto(120, -1);
			}
			else {
				if( !c.isSleeping() )
					c.iaWander();

				if( task!=null )
					setBarDuration(task.start, task.end);
			}
		}

		// God lights
		//if( time%10==0 && ry>=0 ) {
			//if( !shotel.hasRoom(rx-1, ry) )
				//Game.ME.fx.godLight(this, 1);
//
			//if( !shotel.hasRoom(rx+1, ry) )
				//Game.ME.fx.godLight(this, -1);
		//}
	}
}

