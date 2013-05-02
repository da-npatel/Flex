package com.digitalaisle.desktop.utils
{
	import com.digitalaisle.desktop.popups.HTMLPopup;
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.desktop.components.ApplicationContent;
	import com.digitalaisle.desktop.popups.SearchPad;
	import com.digitalaisle.utils.ScreenResoultionUtil;
	
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import org.casalib.util.LocationUtil;

	public class DesktopApplicationUtil
	{
		public static var appContentView:ApplicationContent;
		
		private static var _selectedModuleId:int;
		
		public function DesktopApplicationUtil()
		{
			
		}
		
		public static function launchURL(url:String):void
		{
			if(!LocationUtil.isAirApplication()) {
				throw new Error("DesktopApplicationUtil is meant to be used on a desktop based project");
			}
			
			var htmlPopup:HTMLPopup = new HTMLPopup();
			htmlPopup.location = url;
			htmlPopup.height = ScreenResoultionUtil.screenResolution.y * .8;
			htmlPopup.width = ScreenResoultionUtil.screenResolution.x * .8;
			
			PopUpManager.addPopUp(htmlPopup, ApplicationUtil.topLevel, true);
			PopUpManager.centerPopUp(htmlPopup);
		}
		
		
		public static function loadContent(type:String, source:Object):void
		{
			if(DesktopApplicationUtil.appContentView){	
				var contentSource:Object = {};
				switch(type)
				{
					case ApplicationContent.MODULE:
						ApplicationUtil.selectedModuleId = int(source);
						contentSource = DataManager.getInstance().fetchModuleSwfByModuleId(ApplicationUtil.selectedModuleId);
						break;
					case ApplicationContent.PRODUCT:
						contentSource = DataManager.getInstance().fetchProjectContentItemById(int(source));
						break;
					default:
						contentSource = source;
						break;
				}
				
				DesktopApplicationUtil.appContentView.loadContent(contentSource, type);
			}else{
				// throw error
			}
		}
		
		
		public static function search(targetTemplateItemId:int = -1):void
		{
			var searchPad:SearchPad = new SearchPad();
			
			if(targetTemplateItemId != -1)
				searchPad.targetTemplateItemId = targetTemplateItemId;
			
			if(ScreenResoultionUtil.screenResolution.equals(ScreenResoultionUtil.HD_720)) {
				searchPad.width = 870;
				searchPad.height = 600;
				searchPad.styleName = "hd720";
			}else {
				searchPad.width = 870;
				searchPad.height = 600;
				searchPad.styleName = "hd720";
			}
			
			PopUpManager.addPopUp(searchPad, ApplicationUtil.topLevel, true);
			PopUpManager.centerPopUp(searchPad);
		}
		
		/*public static function get selectedModuleId():int
		{
			return DesktopApplicationUtil._selectedModuleId;
		}
		
		public static function set selectedModuleId(value:int):void
		{
			DesktopApplicationUtil._selectedModuleId = value;
			ApplicationUtil.updateSession(value, ActionType.CLICK, new Point(FlexGlobals.topLevelApplication.mouseX, FlexGlobals.topLevelApplication.mouseY));
		}*/
	}
}