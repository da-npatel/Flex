package com.digitalaisle.frontend.core
{
	import com.digitalaisle.frontend.drawing.DynamicShape;
	import com.lowke.utils.RegularButton;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;

	// TODO: Convert this to a base class of UIComponent
	public class DAPanel extends Group
	{
		//NEW
		protected var assetData:Dictionary = new Dictionary(true);
		//protected var background:DynamicShape;
		protected var background:SpriteVisualElement;
		protected var buttonElement:SpriteVisualElement;
		protected var overlayButton:RegularButton;
		//protected var totalAssets:int;
		protected var dataChanged:Boolean = false;
		protected var isInitialCreation:Boolean = true;
		
		protected var contentContainer:SpriteVisualElement;
		protected var totalAssets:int;
		protected var assetsLoaded:int;
		protected var isAssetsLoaded:Boolean = false;
		protected var panelWidth:int;
		protected var panelHeight:int;
		//protected var assetLoader:Loader;
		
		public var index:int = 0;
		public var doublePressed:Boolean;
		//public var id:int;
		
		
		private var _clickSound:Sound;					// Sound triggered when panel clicked
		private var _panelWidth:int;
		private var _panelHeight:int;					// these should be protected not private as they cannot be changed via runtime
		private var _selected:Boolean;
		
		private var _bkgdLoader:Loader;
		

		
		// NEEDS local janitor support and upon setting up it can do a quick cleanup
		// destrot() will trigger a complete wipe
		
		public function DAPanel(pWidth:int, pHeight:int)		// NOTE: Initial height/width needed to create background.  This should probably be set to invisible and used as a container shape for each panel
		{
			super();
			
			// Bug Fix dealing with Flex SDK 4.1
			layoutDirection = "ltr";
			
			panelWidth = pWidth;
			panelHeight = pHeight;
			
			// Note this might need to be placed after creating children	
			width = panelWidth;
			height = panelHeight;

		}
		
		override protected function createChildren():void
		{
			super.createChildren();

			
			
			background = new SpriteVisualElement();
			
			var backgroundShape:DynamicShape = new DynamicShape();
			backgroundShape.name = "background";
			backgroundShape.doDrawRect(panelWidth, panelHeight, 0x333333, 0);
			//addElement(contentContainer);
			addElement(background);
			overlayButton = new RegularButton();
			overlayButton.name = "overlayButton";
			
			buttonElement = new SpriteVisualElement();
			buttonElement.addChild(overlayButton);
			addElement(buttonElement);
			
			background.addChild(backgroundShape);		// TODO: THIS CAN PROBABLY BE REPLACED WITH A RECTANGLE

			
		}
		
		override protected function measure():void
		{
			super.measure();
			measuredMinHeight = panelHeight;
			measuredMinWidth = panelWidth;
		}
		
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
		}
		
		
		public function destroy(parent:DisplayObjectContainer):void
		{
			//removeAllElements();
			parent.removeChild(this);			// TODO
			//remove background
			//remove dictionary objects  // TODO: Figure out how to do this
		}
		
		protected function loadBackground(bkgd:String, viewWidth:Number = 0, viewHeight:Number = 0):void
		{


				_bkgdLoader = new Loader();
				trace("SOURCE = " + bkgd);
				_bkgdLoader.load(new URLRequest(bkgd));
				_bkgdLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onBkgdIOError, false, 0, true);
				_bkgdLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onBkgdSecurityError, false, 0, true);
				_bkgdLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBkgdLoaded, false, 0, true);
				
				function onBkgdIOError(e:IOErrorEvent):void {
					var panelShape:DynamicShape = new DynamicShape();
					panelShape.doDrawRect(viewWidth, viewHeight, 0x666666, 1, "No asset available")
					background.addChild(panelShape);
					_bkgdLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBkgdIOError);
				}
		}
		
		/**
		 * EVENT HANDLERS ----------------------------
		 */
		
		private function onBkgdSecurityError(e:SecurityErrorEvent):void {
			trace("bkdg SecurityError "+e);
		}
		
		
		
		private function onBkgdLoaded(e:Event):void
		{
			// REMOVE BKGD SHAPE INTERNAL
			
			//assetData["background"] = new Bitmap((e.target.content as Bitmap).bitmapData, "auto", true);
			var backgroundAsset:Bitmap = new Bitmap(Bitmap(e.target.content as Bitmap).bitmapData, "auto", true); 

			background.addChild(backgroundAsset);
			//_bkgdLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBkgdIOError);
			_bkgdLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onBkgdSecurityError);
			_bkgdLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBkgdLoaded);
			_bkgdLoader.unload();
			_bkgdLoader = null;

		}
		
		
		protected function toggleSelected(value:Boolean):void
		{
			
		}
		
		
		// EXECUTES a quick clean up of unneeded resources
		protected function cleanUp():void
		{
			// maybe this cleans up loos references upon completion
		}

		

		public function get clickSound():Sound
		{
			return _clickSound;
		}

		public function set clickSound(value:Sound):void
		{
			_clickSound = value;
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			_selected = value;
			trace("Over;ay = " + overlayButton);
			toggleSelected(value);
			//overlayButton.selected = value;
			//(contentContainer.getChildByName("overlayButton") as RegularButton).selected = value;
		}
		
		
		
	}
}