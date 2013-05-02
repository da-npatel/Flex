package com.digitalaisle.uilibrary.templates
{
	import com.digitalaisle.desktop.components.ApplicationContent;
	import com.digitalaisle.desktop.supportClasses.DesktopTemplateBase;
	import com.digitalaisle.desktop.utils.DesktopApplicationUtil;
	import com.digitalaisle.frontend.components.DAAvatarPlayer;
	import com.digitalaisle.frontend.components.DAPanelSlider;
	import com.digitalaisle.frontend.enums.ControlType;
	import com.digitalaisle.frontend.events.DataManagerEvent;
	import com.digitalaisle.frontend.events.PanelEvent;
	import com.digitalaisle.frontend.managers.AvatarManager;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.uilibrary.components.DASlideshow;
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.containers.Footer;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.events.FlexEvent;
	
	public class AvatarPromo extends DesktopTemplateBase
	{
		
		/** Skin Parts **/
		[SkinPart(required="true")]
		public var contentView:ApplicationContent;
		[SkinPart(required="false")]
		public var avatar:DAAvatarPlayer;
		[SkinPart(required="false")]
		public var mainMenuSlider:DAPanelSlider;
		[SkinPart(required="true")]
		public var logo:Image;
		[SkinPart(required="false")]
		public var sidebarBanner:DASlideshow;
		[SkinPart(required="false")]
		public var footer:Footer;
		[SkinPart(required="false")]
		public var prevNavBtn:DASimpleButton;
		[SkinPart(required="false")]
		public var nextNavBtn:DASimpleButton;
		//FOOTER STILL NEEDED
		
		private var _promoSlideShowItems:ArrayCollection = new ArrayCollection();
		
		public function AvatarPromo()
		{
			super();
			
		}
		
		override protected function onPreinitializeComplete(e:FlexEvent):void
		{
			super.onPreinitializeComplete(e);
			
			
		
		}
		
		override protected function onCreationComplete(e:FlexEvent):void
		{
			super.onCreationComplete(e);
			
			
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			switch(instance)
			{
				case contentView:
					DesktopApplicationUtil.appContentView = contentView;
					//contentView.addEventListener(FlexEvent.CREATION_COMPLETE, onContentViewCreationComplete);
					break;
				case avatar:
					AvatarManager.getInstance().defaultAvatarPlayer = instance as DAAvatarPlayer;
					break;
				case logo:
					logo.addEventListener(MouseEvent.CLICK, onLogoClick, false, 0, true);
					break;
				case prevNavBtn:
					prevNavBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case nextNavBtn:
					nextNavBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
			}
		}
		
		override protected function onDataLoaded(e:DataManagerEvent):void
		{
			super.onDataLoaded(e);
			
			AvatarManager.getInstance().avatarList.addItem({label:"DefaultIntro", source:projectAvatar});
			if(avatar) 
				AvatarManager.getInstance().play("DefaultIntro");
			
			if(sidebarBanner){
				var sidebarWidgetItems:ArrayCollection = DataManager.getInstance().fetchWidgetContentItemsByControlType(ControlType.SIDEBAR_ADVERT);
				if(sidebarWidgetItems.length > 0) {
					sidebarBanner.dataProvider = DataManager.getInstance().fetchProjectContentItemsByOwnerId(sidebarWidgetItems[0].id);
				}
			}
			
			if(logo){
				logo.source = projectLogo;	
			}
			
			if(mainMenuSlider){
				mainMenuSlider.dataProvider = DataManager.getInstance().fetchModules();
				mainMenuSlider.addEventListener(PanelEvent.CLICK, onMainMenuClick);
				mainMenuSlider.clickSound = ApplicationUtil.defaultClick;
			}
			
			if(contentView){
				var promoWidgetItems:ArrayCollection = DataManager.getInstance().fetchWidgetContentItemsByControlType(ControlType.PROMO_ITEM);
				if(promoWidgetItems.length > 0)
					_promoSlideShowItems = DataManager.getInstance().fetchProjectContentItemsByOwnerId(promoWidgetItems[0].id);
				
				DesktopApplicationUtil.loadContent(ApplicationContent.PROMO_SLIDESHOW, _promoSlideShowItems);
			}
			
			buildOn();
		}
		
		private function onContentViewCreationComplete(e:FlexEvent):void
		{
			//_promoSlideShowItems = DataManager.getInstance().fetchPlaylistItemsByType(3, ControlType.SLIDESHOW);
			var promoWidgetItems:ArrayCollection = DataManager.getInstance().fetchWidgetContentItemsByControlType(ControlType.PROMO_ITEM);
			if(promoWidgetItems.length > 0)
				_promoSlideShowItems = DataManager.getInstance().fetchProjectContentItemsByOwnerId(promoWidgetItems[0].id);
	
			DesktopApplicationUtil.loadContent(ApplicationContent.PROMO_SLIDESHOW, _promoSlideShowItems);
		}
		
		
		protected function onMainMenuClick(e:PanelEvent):void
		{
			DesktopApplicationUtil.loadContent(ApplicationContent.MODULE, e.currentTarget.selectedID);
		}
		
		protected function onLogoClick(e:MouseEvent):void
		{
			ApplicationUtil.returnHome();
			DesktopApplicationUtil.loadContent(ApplicationContent.PROMO_SLIDESHOW, _promoSlideShowItems);
		}
		
		private function onButtonClick(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case prevNavBtn:
					mainMenuSlider.prevPanel();
					break;
				case nextNavBtn:
					mainMenuSlider.nextPanel();
					break;
			}
			
		}
	}
}