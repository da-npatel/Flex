package com.digitalaisle.uilibrary.supportClasses
{
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.managers.AvatarManager;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	
	import mx.controls.Image;
	import mx.events.FlexEvent;
	
	import spark.components.SkinnableContainer;
	
	public class ModuleBase extends SkinnableContainer
	{
		/** Skin Parts **/
		[SkinPart(required="true")]
		public var backgroundImage:Image;
		
		public var type:String;
		public var layoutType:String;
		public var projectContentItem:ProjectContentItem;
		public var autoPlayAvatar:Boolean = true;
		
		public function ModuleBase()
		{
			super();
			addEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			addEventListener(FlexEvent.REMOVE, onRemoved);
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case backgroundImage:
					backgroundImage.source = projectContentItem.fetchBinaryContentByType(BinaryType.BACKGROUND_IMAGE);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
		}
		
		protected function onCreationComplete(e:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			if(AvatarManager.getInstance().defaultAvatarPlayer && autoPlayAvatar){
				AvatarManager.getInstance().defaultAvatarPlayer.source = projectContentItem.fetchBinaryContentByType(BinaryType.AVATAR_VIDEO);
			}
		}
		
		protected function onPreInitialize(e:FlexEvent):void
		{
			projectContentItem = DataManager.getInstance().fetchProjectContentItemById(ApplicationUtil.selectedModuleId);
			removeEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);	
		}
		
		protected function onRemoved(e:FlexEvent):void
		{
			removeEventListener(FlexEvent.REMOVE, onRemoved);
		}
		
	}
}