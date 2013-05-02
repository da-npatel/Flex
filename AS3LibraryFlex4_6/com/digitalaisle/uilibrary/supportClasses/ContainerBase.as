package com.digitalaisle.uilibrary.supportClasses
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	//Change MX Image to Spark Image - Start
	//import mx.controls.Image;
	import spark.components.Image;
	//End
	import mx.events.FlexEvent;
	import mx.states.State;
	
	import spark.components.SkinnableContainer;
	import spark.primitives.BitmapImage;
	
	[Style(name="backgroundImageBitmap", type="flash.dispaly.Bitmap", inherit="yes")]
	
	public class ContainerBase extends SkinnableContainer
	{
		private var _type:String;
		public var layoutType:String;
		
		/** Skin Parts **/
		[SkinPart(required="false")]
		public var backgroundImage:BitmapImage;
		
		private var _backgroundSource:String;
		
		public function ContainerBase()
		{
			super();
			
			addEventListener(FlexEvent.ADD, onAdded);
			addEventListener(FlexEvent.REMOVE, onRemoved);
			addEventListener(FlexEvent.PREINITIALIZE, onPreinitializeComplete, true);
			
			
		}
		
		override public function initialize():void
		{
			super.initialize();
			
		}
		
		protected function onPreinitializeComplete(e:FlexEvent):void
		{
			// MOVED FROM INITIALIZE() DUE TO NOT BEING HIT
			states.push(new State({name:"normal"}));
			states.push(new State({name:"disabled"}));
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(backgroundImage)
			{
				if(getStyle("backgroundImageBitmap"))
				{
					if(getStyle("backgroundImageBitmap") is Class)
						backgroundImage.source = createBitmapFromClass(getStyle("backgroundImageBitmap"));
					else if(getStyle("backgroundImageBitmap") is Bitmap)
						backgroundImage.source = (getStyle("backgroundImageBitmap") as Bitmap);
				}
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case backgroundImage:
					//backgroundImage.source = _backgroundSource;
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
		}
		
		
		
		
		private function loadAsset(asset:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAssetLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadError);
			loader.load(new URLRequest(asset));
			
			function onAssetLoaded(e:Event):void
			{
				setStyle("backgroundImageBitmap", (e.target.content as Bitmap));
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageLoadError);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onAssetLoaded);
				loader = null;
			}
		}
		
		private function createBitmapFromClass(BtnClass:Class):Bitmap
		{
			var btnBitmap:Bitmap = new BtnClass();
			btnBitmap.smoothing = true;
			return btnBitmap;
		}
		
		
		protected function onAdded(e:FlexEvent):void {}
		
		protected function onRemoved(e:FlexEvent):void {}
		
		private function onImageLoadError(e:IOErrorEvent):void
		{
			// log error	
		}
		
		public function set backgroundSource(value:String):void
		{
			_backgroundSource = value;
			loadAsset(value);
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

	}
}