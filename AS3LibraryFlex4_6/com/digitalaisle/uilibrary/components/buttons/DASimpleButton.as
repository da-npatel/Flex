package com.digitalaisle.uilibrary.components.buttons
{
	import com.digitalaisle.uilibrary.skins.ImageButtonSkin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import spark.primitives.BitmapImage;
	
	[Style(name="upStateBitmap", type="flash.display.Bitmap", inherit="yes")]
	[Style(name="downStateBitmap", type="flash.display.Bitmap", inherit="yes")]
	[Style(name="disabledStateBitmap", type="flash.display.Bitmap", inherit="yes")]
	
	public class DASimpleButton extends DAButton
	{
		[SkinPart(required="true")]
		public var buttonImage:BitmapImage;
		
		private var _downStateBitmapData:BitmapData;
		private var _upStateBitmapData:BitmapData;
		private var _disabledStateBitmapData:BitmapData;
		
		private var _downStateAsset:String;
		private var _upStateAsset:String;
		private var _disabledStateAsset:String;
		
		private static var DOWN_STATE:String = "downState";
		private static var UP_STATE:String = "upState";
		private static var DISABLED_STATE:String = "disabledState";
		
		
		
		public function DASimpleButton()
		{
			super();
			setStyle("skinClass", ImageButtonSkin);
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			switch(instance)
			{
				case buttonImage:
					
					break;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (getStyle("upStateBitmap"))
			{
				if(getStyle("upStateBitmap") is Class)
					upStateBitmapData = createButtonStateBitmap(getStyle("upStateBitmap")).bitmapData;
				else if(getStyle("upStateBitmap") is Bitmap)
					upStateBitmapData = (getStyle("upStateBitmap") as Bitmap).bitmapData;
			}
				
			if (getStyle("downStateBitmap"))
			{
				if(getStyle("downStateBitmap") is Class)
					downStateBitmapData = createButtonStateBitmap(getStyle("downStateBitmap")).bitmapData;
				else if(getStyle("downStateBitmap") is Bitmap)
					downStateBitmapData = (getStyle("downStateBitmap") as Bitmap).bitmapData;
				overStateBitmapData = downStateBitmapData.clone();
			}
			if (getStyle("disabledStateBitmap"))
			{
				if(getStyle("disabledStateBitmap") is Class)
					disabledStateBitmapData = createButtonStateBitmap(getStyle("disabledStateBitmap")).bitmapData;
				else if(getStyle("disabledStateBitmap") is Bitmap)
					disabledStateBitmapData = (getStyle("disabledStateBitmap") as Bitmap).bitmapData;

			}
				
		}
		
		private function loadAsset(asset:String, state:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAssetLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadError);
			loader.load(new URLRequest(asset));
			
			function onAssetLoaded(e:Event):void
			{
				switch(state)
				{
					case UP_STATE:
						setStyle("upStateBitmap", (e.target.content as Bitmap));
						break;
					case DOWN_STATE:
						setStyle("downStateBitmap", (e.target.content as Bitmap));
						break;
					case DISABLED_STATE:
						setStyle("disabledStateBitmap", (e.target.content as Bitmap));
						break;
				}
				
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onAssetLoaded);
				loader = null;
			}
		}
		
		private function onImageLoadError(e:IOErrorEvent):void
		{
			// log error	
		}
		
		private function createButtonStateBitmap(BtnClass:Class):Bitmap
		{
			var btnBitmap:Bitmap = new BtnClass();
			btnBitmap.smoothing = true;
			return btnBitmap;
		}
		
		public function get downStateAsset():String
		{
			return _downStateAsset;
		}
		
		public function set downStateAsset(value:String):void
		{
			if(_downStateAsset == value)
				return;
			
			_downStateAsset = value;
			loadAsset(value, DOWN_STATE);
		}
		
		public function get upStateAsset():String
		{
			return _upStateAsset;
		}
		
		public function set upStateAsset(value:String):void
		{
			if(_upStateAsset == value)
				return;
			
			_upStateAsset = value;
			loadAsset(value, UP_STATE);
		}
		
		public function get disabledStateAsset():String
		{
			return _disabledStateAsset;
		}
		
		public function set disabledStateAsset(value:String):void
		{
			if(_disabledStateAsset == value)
				return;
			
			_disabledStateAsset = value;
			loadAsset(value, DISABLED_STATE);
		}
		
		[Bindable]
		public function get downStateBitmapData():BitmapData
		{
			return _downStateBitmapData;
		}
		
		public function set downStateBitmapData(value:BitmapData):void
		{
			_downStateBitmapData = value;
		}
		
		[Bindable]
		public function get overStateBitmapData():BitmapData
		{
			return _downStateBitmapData.clone();
		}
		
		public function set overStateBitmapData(value:BitmapData):void
		{
			_downStateBitmapData = value;
		}
		
		[Bindable]
		public function get upStateBitmapData():BitmapData
		{
			return _upStateBitmapData;
		}
		
		public function set upStateBitmapData(value:BitmapData):void
		{
			_upStateBitmapData = value;
		}
		
		[Bindable]
		public function get disabledStateBitmapData():BitmapData
		{
			return _disabledStateBitmapData;
		}
		
		public function set disabledStateBitmapData(value:BitmapData):void
		{
			_disabledStateBitmapData = value;
		}
	}
}