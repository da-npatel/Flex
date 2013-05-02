package com.digitalaisle.themeLibrary.themeDefinitions.modules.base
{
	import com.digitalaisle.themeLibrary.base.ModuleSkinBase;
	import com.digitalaisle.themeLibrary.types.AssetSkinType;
	import com.digitalaisle.themeLibrary.types.ModuleSkinType;
	
	public class ConsultationSkin extends ModuleSkinBase
	{		
		public function ConsultationSkin()
		{
			super();

			type = ModuleSkinType.CONSULTATION_DEFUALT;
			supportedAssets = [AssetSkinType.PREV_NAV_DOWN, AssetSkinType.PREV_NAV_IDLE, AssetSkinType.NEXT_NAV_DOWN, AssetSkinType.NEXT_NAV_IDLE, AssetSkinType.PRINT_BTN_IDLE,AssetSkinType.PRINT_BTN_DOWN, AssetSkinType.EMAIL_BTN_IDLE, AssetSkinType.EMAIL_BTN_DOWN, AssetSkinType.GO_BACK_BTN_IDLE, AssetSkinType.GO_BACK_BTN_DOWN, AssetSkinType.LIST_PANEL_IDLE, AssetSkinType.LIST_PANEL_OVER, AssetSkinType.DEFAULT_MODULE_BKGD, AssetSkinType.SLIDER_BAR, AssetSkinType.SLIDER_HANDLE, AssetSkinType.MULTIPLE_CHOICE_BTN_DOWN, AssetSkinType.MULTIPLE_CHOICE_BTN_IDLE];

		}
	}
}