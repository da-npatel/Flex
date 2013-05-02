package com.digitalaisle.themeLibrary.themeDefinitions.modules.custom
{
	import com.digitalaisle.themeLibrary.base.ModuleSkinBase;
	import com.digitalaisle.themeLibrary.types.AssetSkinType;
	import com.digitalaisle.themeLibrary.types.ModuleSkinType;
	
	public class AgeGateSkin extends ModuleSkinBase
	{
		public function AgeGateSkin()
		{
			super();
			
			type = ModuleSkinType.AGE_GATE_DEFAULT;
			supportedAssets = [AssetSkinType.AVATAR_AGE_GATE_FAIL, AssetSkinType.AVATAR_AGE_GATE_INITIAL, AssetSkinType.AVATAR_AGE_GATE_SUCCESS, AssetSkinType.SLIDER_BAR_GENDER, AssetSkinType.SLIDER_BAR_MONTH, AssetSkinType.SLIDER_BAR_YEAR, AssetSkinType.SLIDER_HANDLE_MONTH, AssetSkinType.SLIDER_HANDLE_YEAR, AssetSkinType.SLIDER_HANDLE_GENDER,AssetSkinType.ENTER_BTN_DOWN, AssetSkinType.ENTER_BTN_IDLE, AssetSkinType.BACKGROUND_AGE_GATE];
			
		}
	}
}