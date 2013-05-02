package com.digitalaisle.frontend.core
{
	import com.digitalaisle.frontend.drawing.DynamicShape;
	import com.digitalaisle.frontend.events.PanelEvent;
	import com.lowke.utils.RegularButton;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.core.UIComponentGlobals;
	
	import spark.core.ISharedDisplayObject;

	public class Panel extends Sprite
	{
		private var _overlayLayer:RegularButton;
		private var _middleLayerRef:DisplayObject;
		private var _overlayIdleRef:Bitmap;
		private var _overlayDownRef:Bitmap;
		private var _clickSound:Sound;						// Sound triggered when panel clicked
		//private var _bkgdLayerRef:DisplayObject;
		
		
		private var _assetData:Dictionary;
		private var _assetsLoaded:int = 0;
		private var _middleLayerType:String  = "default";
		private var _totalAssets:int;
		public var panelWidth:int = 300;
		public var panelHeight:int = 180;
		public var id:int;
		public var doublePressed:Boolean;
		
		// NEEDS local janitor support and upon setting up it can do a quick cleanup
		// destrot() will trigger a complete wipe
		
		public function Panel()
		{
			super();
			//width = 300;
			//height = 180;
			var tempShape:DynamicShape = new DynamicShape();
			tempShape.doDrawRect(width, height);
			addChild(tempShape);
			_assetData = new Dictionary(true);
			_overlayLayer = new RegularButton();
			
		}
		
			
		public function init(overIdle:String, overDown:String, midLayer:String, bkgdLayer:String):void
		{
			
			// Mid layer when dynamic will be "dynamic" passed through
			
			// LOAD the OVERLAY IDLE asset
			loadImage("idle", overIdle);
			// LOAD the OVERLAY IDLE asset
			loadImage("down", overDown);
			
			
			if(midLayer == "dynamic")
			{
				// DISPATCH event
			}else
			{
				// LOAD the MIDDLE IDLE asset
				createMiddleContent("middle", midLayer);
				_totalAssets = 3;
			}
			
			// DETERMINE whether or not a BKGD layer object is needed
			/*if(bkgdLayer != "none")
			{
				loadImage("bkgd", bkgdLayer, _bkgdLayerRef);
			}else
			{
				// NO BKGD object will be created
			}*/
			
		}
		
		public function move(posX:Number, posY:Number):void
		{
			x = posX;
			y = posY;
		}
		
		
		public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			width = newWidth;
			height = newHeight;
		}
		
		public function destroy(parent:DisplayObjectContainer):void
		{
			parent.removeChild(this);
		}
		
		
		private function loadImage(label:String, source:String):void
		{
			
			if(source != "none")
			{
				var loader:Loader = new Loader();
				loader.load(new URLRequest(source));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAssetLoaded); 
				
			}else if(source == "none")
			{
				
				var panelShape:DynamicShape = new DynamicShape();
				panelShape.doDrawRect(panelWidth, panelHeight, 0x333333, 0);
				panelShape.cacheAsBitmap;
				
				_assetData[label] = panelShape;
				
				updateAssetsLoaded();
				
			}
			
			
			function onAssetLoaded(e:Event):void
			{
				_assetData[label] = e.target.content as Bitmap;
				_assetData[label].smoothing = true;
				// UPDATES the count of assets loaded
				updateAssetsLoaded();
				
				// Removing loader reference  
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onAssetLoaded); 
				loader = null;
				
			}
		}
		
		private function assignDisplayObjects():void
		{
			
		}
		
		private function updateAssetsLoaded():void
		{
			_assetsLoaded++;
			
			if(_assetsLoaded == _totalAssets)
			{
				createOverlayButton();
				
				addChild(_assetData["middle"]);
				addChild(_overlayLayer);
				dispatchEvent(new PanelEvent(PanelEvent.IS_READY));
				// POSSIBLE DISPATCH OF an event that signals that is is ready
			}
		}
		
		
		// CREATES a new overlay regular button instance
		private function createOverlayButton():void
		{
			_overlayLayer = new RegularButton();
			_overlayLayer.upGraphic = _assetData["idle"];
			_overlayLayer.downGraphic = _assetData["down"];
			_overlayLayer.overGraphic = _assetData["idle"];
			_overlayLayer.hitTestGraphic = _assetData["idle"];
			
		}
		
		
		private function createMiddleContent(label:String, source:String):void
		{
			
			switch(extractFileType(source))
			{
				case "png":
					loadImage(label, source);
					
					break;
				case "video":
					//ref = e.target.content as;
					break;
				case "swf":
					
					break;
			}
		}
		
		
		// DETERMINES the file type of the file and returns its extension
		private function extractFileType(file:String):String 
		{
			var extensionIndex:Number=file.lastIndexOf(".");
			if (extensionIndex==-1) {
				//No extension
				return "";
			} else {
				return file.substr(extensionIndex + 1,file.length);
			}
		}
		
		

		// EXECUTES a quick clean up of unneeded resources
		private function cleanUp():void
		{
			
		}

		public function get middleLayerType():String
		{
			return _middleLayerType;
		}

		public function set middleLayerType(value:String):void
		{
			
			// POSSIBLY NEEDS VALUE CHECKING FOR ERROR PROOFING
			_middleLayerType = value;
		}

		public function get overlayLayer():RegularButton
		{
			return _overlayLayer;
		}

		public function set overlayLayer(value:RegularButton):void
		{
			_overlayLayer = value;
		}

		public function get clickSound():Sound
		{
			return _clickSound;
		}

		public function set clickSound(value:Sound):void
		{
			_clickSound = value;
		}

		
	}
}