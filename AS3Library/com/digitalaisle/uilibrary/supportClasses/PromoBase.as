package com.digitalaisle.uilibrary.supportClasses
{
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.uilibrary.components.buttons.DAButton;
	import com.digitalaisle.uilibrary.skins.PromoSkin;
	
	import mx.controls.Image;
	
	import spark.components.supportClasses.SkinnableComponent;

	public class PromoBase extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var promoImage:Image;
		[SkinPart(required="false")]
		public var printButton:DAButton;
		[SkinPart(required="false")]
		public var emailButton:DAButton;
		
		private var _projectContentItem:ProjectContentItem;
		private var _dataChanged:Boolean = false;
		
		public function PromoBase()
		{
			super();
			setStyle("skinClass", PromoSkin);
		}	
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(_dataChanged){
				promoImage.source = projectContentItem.fetchBinaryContentByType(BinaryType.BACKGROUND_IMAGE);
				_dataChanged = false;
			}		
		}
		
		public function get projectContentItem():ProjectContentItem
		{
			return _projectContentItem;
		}
		
		public function set projectContentItem(value:ProjectContentItem):void
		{
			if(_projectContentItem)
			{
				if(_projectContentItem === value)
					return;
			}
			
			_projectContentItem = value;
			_dataChanged = true;
			invalidateDisplayList();
		}
		
	}
}