package com.digitalaisle.uilibrary.components.panels
{
	import com.digitalaisle.uilibrary.data.PanelObject;
	import com.digitalaisle.uilibrary.skins.imageListSkin;
	import com.digitalaisle.uilibrary.supportClasses.PanelBase;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import mx.core.mx_internal;
	
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.events.ElementExistenceEvent;
	
	public class ImageList extends PanelBase
	{
		[SkinPart(required="true")]
		public var largeImage:Image= new Image();
		public var richText1:RichText= new RichText();
		
		
		private var _thumbnailAsset:String;
		public function ImageList()
		{
			super();
			setStyle("skinClass", imageListSkin);
			addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, onElementRemoved, false, 0, true);
			
			//addEventListener(Event.REMOVED_FROM_STAGE,onElementRemoved,false,0,true);
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName,instance);
			if(instance is Image && instance != null) {
				if((instance as Image).bitmapData!=null) {
				(instance as Image).bitmapData.dispose();	
				}
				instance = null;
			}
				
		}
		
		public function onElementRemoved(event:Event):void{
			detachSkin();
		}
		override protected function applySettings(settingsObj:PanelObject):void
		{
			super.applySettings(settingsObj);
			
			largeImage.source = settingsObj.imageurl;
			richText1.text= settingsObj.labelText;
			//labelDisplay.text=settingsObj.labelText;
		}

	}
}