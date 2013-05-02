package com.digitalaisle.uilibrary.supportClasses
{
	import com.digitalaisle.uilibrary.skins.ExternalPortalSkin;
	
	import mx.controls.HTML;
	import mx.events.FlexEvent;

	public class ExternalPortalBase extends ModuleBase
	{
		[SkinPart(required="true")]
		public var htmlControl:HTML;
		
		private var _htmlLocation:String;
		
		public function ExternalPortalBase()
		{
			super();
			
			setStyle("skinClass", ExternalPortalSkin);
		}
		
		override protected function  onPreInitialize(e:FlexEvent):void
		{
			super.onPreInitialize(e);
			
			_htmlLocation = projectContentItem.externalLink;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance){
				case htmlControl:
					htmlControl.location = _htmlLocation;
					break;
			}
		}
	}
}