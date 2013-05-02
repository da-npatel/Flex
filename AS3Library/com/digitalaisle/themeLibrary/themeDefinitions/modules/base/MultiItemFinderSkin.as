package com.digitalaisle.themeLibrary.themeDefinitions.modules.base
{
	import com.digitalaisle.themeLibrary.base.ModuleSkinBase;
	import com.digitalaisle.themeLibrary.types.AssetSkinType;
	import com.digitalaisle.themeLibrary.types.ModuleSkinType;
	
	public class MultiItemFinderSkin extends ModuleSkinBase
	{
		public function MultiItemFinderSkin()
		{
			super();
			
			type = ModuleSkinType.MULTI_ITEM_FINDER;
			supportedAssets = [AssetSkinType.MULTI_BG, AssetSkinType.TITLED_PANEL_OVER, AssetSkinType.PREV_NAV_DOWN, AssetSkinType.PREV_NAV_IDLE, AssetSkinType.NEXT_NAV_DOWN, AssetSkinType.NEXT_NAV_IDLE, AssetSkinType.PRINT_BTN_IDLE,AssetSkinType.PRINT_BTN_DOWN, AssetSkinType.EMAIL_BTN_IDLE, AssetSkinType.EMAIL_BTN_DOWN, AssetSkinType.GO_BACK_BTN_IDLE, AssetSkinType.GO_BACK_BTN_DOWN, AssetSkinType.START_OVER_BTN_IDLE, AssetSkinType.START_OVER_BTN_DOWN, AssetSkinType.LIST_PANEL_IDLE, AssetSkinType.LIST_PANEL_OVER, AssetSkinType.TITLED_PANEL_OVER,AssetSkinType.TITLED_PANEL_IDLE,AssetSkinType.SPINDLE_BG, AssetSkinType.SPINDLE_SELECTION];
		}
	}
}