package m;

import com.distriqt.extension.application.Application;

import com.distriqt.extension.inappbilling.InAppBilling;
import com.distriqt.extension.inappbilling.InAppBillingServiceTypes;
import com.distriqt.extension.inappbilling.Product;
import com.distriqt.extension.inappbilling.Purchase;
import com.distriqt.extension.inappbilling.events.InAppBillingEvent;

import flash.errors.Error;

class IapMan extends mt.deepnight.Process {
	public static var ME : IapMan;

	static var DEV_KEY : String = "cf9eace23619ab42c80cfd7cc583e962ddaef45cVpUSXvX9IamdDzDGkn/gaB6+nZib6ne7yUEXaY5fv6zLt3n8OsB8Z1L2vTSbjxKfiKNhf+9Gd7g9DCS4PKBgMf165DJPVMVXKVaCqQybp8rU2I483u0nBlJXHw0IYXwCga1o67qZyYpnXBiYFIf5PIggjc1A0K4fpSV7YMRq+L/GhGhP8pQ1xH8ZlZn87fNjHf3tXFlJhe1ZoQxHPk/WRN5CqRM/rCGilKlQtEziqaaUt8ArPDmL9HFjnSBFGxcVYn/8uVhcD8wxoTB9qGG7m89CCiDrhA/dS9H2eKOAsO21CYeGX0VLyt3dxmhCc/cIJ7TZouCC6P3CnqU4Z5s6AQ==";
	static var GOOGLE_PLAY_INAPP_BILLING_KEY : String = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApYs6s6dNKgzJNd8jQaHUWLEGbmx1xWsYQpDxD1wVeIZcPvMmUZ8xCHopGgBX8gDqUb1q3wmgn5xiBleOUKFU6peraBILOmdmooOAtwk6QioUhMdJtllNLHOh9XAblmMHiFBwhyPt7YIQ+r+ygZqeyZhY7ckDrxpJgWcYBEdenY5mks5MNeMtUb48B9gfNg/M9TjtBeK7J/ZpS7yj6Iqfqj9v7k/E0UBZtKrnw1U0gp3PK1BHcO4O/kDnfn9VUEKY9TVX4C9W0HgFUndIagIEnFMttbZEAxDLWtsCiQSJAIqp3pOtt3KsmyfRg5a9sK9kDtrkAmIdRf1U83IOp28ZIwIDAQAB";
	static var PRODUCT_IDS = ["com.motiontwin.uppercupfootball.unlock"];

	var initDone		: Bool;
	var allProducts		: Array<Product>;
	var onBuyCancel		: Void->Void;
	var onBuySuccess	: String->Void;
	var onBuyFailed		: String->Void;
	var onRestFailed	: Void->Void;
	var onProducts		: Bool->Void;

	public function new() {
		super();
		ME = this;
		initDone = false;
		allProducts = [];

		try{
			InAppBilling.init( DEV_KEY );
			debug( "InAppBilling.isSupported:     " + InAppBilling.isSupported );
			debug( "InAppBilling.service.version: " + InAppBilling.service.version );

			Application.init( DEV_KEY );
			debug( "Application.isSupported:     " + Application.isSupported );
			initDone = true;
			delayer.add( setup, 200 );
		} catch (e:Error){
			debug( e );
		}
	}

	override function unregister() {
		super.unregister();

		InAppBilling.service.removeEventListener( InAppBillingEvent.SETUP_SUCCESS,   			onSetupSuccess );
		InAppBilling.service.removeEventListener( InAppBillingEvent.SETUP_FAILURE,   			onSetupFailed );

		InAppBilling.service.removeEventListener( InAppBillingEvent.PRODUCTS_LOADED, 			onProductsLoaded );
		InAppBilling.service.removeEventListener( InAppBillingEvent.PRODUCTS_FAILED, 			onProductsFailed );
		InAppBilling.service.removeEventListener( InAppBillingEvent.INVALID_PRODUCT,			onInvalidProduct );

		InAppBilling.service.removeEventListener( InAppBillingEvent.PURCHASE_CANCELLED, 		onPurchaseCancelled );
		InAppBilling.service.removeEventListener( InAppBillingEvent.PURCHASE_FAILED, 			onPurchaseFailed);
		InAppBilling.service.removeEventListener( InAppBillingEvent.PURCHASE_SUCCESS, 			onPurchaseSuccess );

		InAppBilling.service.removeEventListener( InAppBillingEvent.RESTORE_PURCHASES_SUCCESS, onRestoreSuccess );
		InAppBilling.service.removeEventListener( InAppBillingEvent.RESTORE_PURCHASES_FAILED, 	onRestoreFailed );

		ME = null;
	}

	inline function debug(str:Dynamic, ?p:haxe.PosInfos) {
		#if debug
		haxe.Log.trace(str,p);
		#end
	}

	function setup() {
		debug("setup...");
		InAppBilling.service.addEventListener( InAppBillingEvent.SETUP_SUCCESS,   			onSetupSuccess, false, 0, true );
		InAppBilling.service.addEventListener( InAppBillingEvent.SETUP_FAILURE,   			onSetupFailed, false, 0, true );

		InAppBilling.service.addEventListener( InAppBillingEvent.PRODUCTS_LOADED, 			onProductsLoaded, false, 0, true );
		InAppBilling.service.addEventListener( InAppBillingEvent.PRODUCTS_FAILED, 			onProductsFailed, false, 0, true );
		InAppBilling.service.addEventListener( InAppBillingEvent.INVALID_PRODUCT,			onInvalidProduct, false, 0, true );

		InAppBilling.service.addEventListener( InAppBillingEvent.PURCHASE_SUCCESS, 			onPurchaseSuccess,   false, 0, true );
		InAppBilling.service.addEventListener( InAppBillingEvent.PURCHASE_FAILED, 			onPurchaseFailed,    false, 0, true );
		InAppBilling.service.addEventListener( InAppBillingEvent.PURCHASE_CANCELLED, 		onPurchaseCancelled, false, 0, true );

		InAppBilling.service.addEventListener( InAppBillingEvent.CONSUME_SUCCESS, 			onConsumeSuccess,  false, 0, true );
		InAppBilling.service.addEventListener( InAppBillingEvent.CONSUME_FAILED, 			onConsumeFailed, false, 0, true );

		InAppBilling.service.addEventListener( InAppBillingEvent.RESTORE_PURCHASES_SUCCESS, onRestoreSuccess, false, 0, true );
		InAppBilling.service.addEventListener( InAppBillingEvent.RESTORE_PURCHASES_FAILED, 	onRestoreFailed,  false, 0, true );

		InAppBilling.service.setup( GOOGLE_PLAY_INAPP_BILLING_KEY );
	}

	function onSetupSuccess(e:InAppBillingEvent) {
		debug("setup ok");
	}

	public function loadProducts( ?onComplete:Bool->Void ) {
		onProducts = onComplete!=null ? onComplete : function(v) {};
		if( initDone )
			InAppBilling.service.getProducts( PRODUCT_IDS );
		else
			onProducts(true);
	}

	public function getLoadedProducts() {
		return allProducts;
	}

	function onSetupFailed(e:InAppBillingEvent) {
		debug("setup failed!");
	}

	function onProductsLoaded(e:InAppBillingEvent) {
		debug("products "+e.data);
		allProducts = e.data;
		onProducts(true);
	}

	function onProductsFailed(e:InAppBillingEvent) {
		debug("products failed ");
		onProducts(false);
	}

	function onInvalidProduct(e:InAppBillingEvent) {
		Ga.event("bank", "purchase", "invalid");
		debug("products invalid");
		onProducts(false);
	}

	function onPurchaseCancelled(e:InAppBillingEvent) {
		Ga.event("bank", "purchase", "cancelled");
		debug("purchase cancelled");
		onBuyCancel();
	}

	function onPurchaseFailed(e:InAppBillingEvent) {
		Ga.event("bank", "purchase", "failed");
		debug("purchase failed "+e.errorCode);
		onBuyFailed(e.errorCode);
	}

	public inline function mkUnlockValue() {
		return haxe.crypto.Sha1.encode( PRODUCT_IDS[0] + Global.ME.playerCookie.deviceId() );
	}

	public inline function unlock() {
		var pc = Global.ME.playerCookie;
		pc.data.unlocked = mkUnlockValue();
		pc.data.shirtColor = 1;
		pc.data.stripeColor = 2;
		pc.data.pantColor = 0;
		pc.save();
	}

	function onPurchaseSuccess(e:InAppBillingEvent) {
		debug("purchase success");

		var p : Purchase = e.data[0];
		debug(p);
		debug(p.productId);

		if ( p.productId == PRODUCT_IDS[0] && (p.transactionState == Purchase.STATE_PURCHASED || p.transactionState == Purchase.STATE_RESTORED) ) {
			unlock();
			onBuySuccess(p.productId);

			if ( p.transactionState == Purchase.STATE_PURCHASED) {
				Ga.event("bank", "purchase", "success" );

				var product = allProducts[0];
				if( product != null)
					Ga.transaction( p.transactionId, product.price,Ga.Affiliation.IAP, [{sku:p.productId,name:"Game Unlocked",price:product.price,quantity:p.quantity}] );

			}
		}
	}



	function onRestoreFailed(e:InAppBillingEvent) {
		debug("restore failed");
		onRestFailed();
	}

	function onRestoreSuccess(e:InAppBillingEvent) {
		debug("restore completed");
	}



	function onConsumeSuccess(e:InAppBillingEvent) {
		debug("consume OK!!");
	}

	function onConsumeFailed(e:InAppBillingEvent) {
		debug("consume failed "+e);
	}



	public function getUnlockPrice() {
		debug(allProducts);
		var p = allProducts.filter( function(p) return p.id==PRODUCT_IDS[0] );
		if( p.length==0 )
			return null;
		else
			return p[0].priceString;

	}

	public function consumeUnlock() {
		var purchase = new Purchase();
		purchase.productId = PRODUCT_IDS[0];
		purchase.quantity = 1;
		debug( InAppBilling.service.consumePurchase(purchase) );
	}

	public function isUnlocked() {
		if ( Global.ME.playerCookie.data.unlocked != "" ) {
			return Global.ME.playerCookie.data.unlocked == mkUnlockValue();
		}
		return false;
	}

	public function buy(success, fail, cancel) {
		onBuySuccess = success;
		onBuyFailed = fail;
		onBuyCancel = cancel;

		var purchase = new Purchase();
		purchase.productId = PRODUCT_IDS[0];
		purchase.quantity = 1;

		debug( Std.string( InAppBilling.service.makePurchase(purchase) ) );
	}


	public function tryToRestore(success) {
		onBuyCancel = function() {};
		onBuyFailed = function(_) {};
		onBuySuccess = success;
		InAppBilling.service.restorePurchases();
	}

}



