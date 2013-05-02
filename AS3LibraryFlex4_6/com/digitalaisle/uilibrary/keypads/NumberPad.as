package com.digitalaisle.uilibrary.keypads
{
	import com.digitalaisle.uilibrary.skins.NumberPadSkin;
	import com.digitalaisle.uilibrary.supportClasses.KeyboardBase;
	
	public class NumberPad extends KeyboardBase
	{
		public function NumberPad()
		{
			super();
			type = "numberPad";
			setStyle("skinClass", NumberPadSkin);
		}
	}
}