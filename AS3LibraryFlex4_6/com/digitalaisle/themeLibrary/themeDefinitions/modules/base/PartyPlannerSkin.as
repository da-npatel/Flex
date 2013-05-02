package com.digitalaisle.themeLibrary.themeDefinitions.modules.base
{
	import com.digitalaisle.themeLibrary.base.ModuleSkinBase;
	import com.digitalaisle.themeLibrary.types.AssetSkinType;
	import com.digitalaisle.themeLibrary.types.ModuleSkinType;
	
	public class PartyPlannerSkin extends ModuleSkinBase
	{
		public function PartyPlannerSkin()
		{
			super();
			
			type = ModuleSkinType.CALENDAR_DEFUALT;
			supportedAssets = [AssetSkinType.PREV_NAV_DOWN, AssetSkinType.PREV_NAV_IDLE, AssetSkinType.NEXT_NAV_DOWN, AssetSkinType.NEXT_NAV_IDLE, AssetSkinType.CALENDAR_GRID, AssetSkinType.PRINT_BTN_IDLE,AssetSkinType.PRINT_BTN_DOWN, AssetSkinType.EMAIL_BTN_IDLE, AssetSkinType.EMAIL_BTN_DOWN, AssetSkinType.GO_BACK_BTN_IDLE, AssetSkinType.GO_BACK_BTN_DOWN, AssetSkinType.LIST_PANEL_IDLE, AssetSkinType.LIST_PANEL_OVER, AssetSkinType.DEFAULT_EVENT_IMAGE, AssetSkinType.DEFAULT_EVENT_THUMBNAIL, AssetSkinType.DEFAULT_MODULE_BKGD];
		}
	}
}