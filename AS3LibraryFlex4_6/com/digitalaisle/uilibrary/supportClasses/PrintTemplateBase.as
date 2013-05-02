package com.digitalaisle.uilibrary.supportClasses
{
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.uilibrary.skins.PrintTemplateSkin;
	
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class PrintTemplateBase extends SkinnableComponent
	{
		/** Skin Parts **/
		[SkinPart(required="true")]
		public var title:Label;
		[SkinPart(required="false")]
		public var subTitle:RichText;
		[SkinPart(required="false")]
		public var description:RichText;
		[SkinPart(required="true")]
		public var footer:RichText;
		[SkinPart]
		public var shortText:Label;
		[SkinPart]
		public var ingredientHeader:Label;
		[SkinPart]
		public var servingIndicator:Label;
		
		[SkinPart]
		public var preparationHeader:Label;
		[SkinPart]
		public var preparation:RichText;
		[SkinPart]
		public var urlHeader:RichText;
		[SkinPart]
		public var url:RichText;
		
		
		private var _projectContentItem:ProjectContentItem;
		
		public function PrintTemplateBase()
		{
			super();
			setStyle("skinClass", PrintTemplateSkin);
			
		}
		
		
		[Bindable]
		public function get projectContentItem():ProjectContentItem
		{
			return _projectContentItem;
		}

		public function set projectContentItem(value:ProjectContentItem):void
		{
			_projectContentItem = value;
		}

	
	}
}