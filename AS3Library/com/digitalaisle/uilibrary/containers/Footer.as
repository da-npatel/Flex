package com.digitalaisle.uilibrary.containers
{
	import com.digitalaisle.desktop.utils.DesktopApplicationUtil;
	import com.digitalaisle.frontend.components.DATicker;
	import com.digitalaisle.frontend.components.DAValueSlider;
	import com.digitalaisle.frontend.enums.ControlType;
	import com.digitalaisle.frontend.events.DAValueSliderEvent;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.supportClasses.ContainerBase;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.RichText;
	import spark.effects.Move;
	
	public class Footer extends ContainerBase
	{
		private var _isVolumeVisible:Boolean = false;
		private var _volumeSliderHandle:String;
		private var _volumeSliderBar:String;
		
		private var volumeTimer:Timer = new Timer(2500,1);
		
		/** Skin Parts **/
		[SkinPart(required="false")]
		public var copyright:RichText;
				
		[SkinPart(required="false")]
		public var footerHomeBtn:DASimpleButton;
				
		[SkinPart(required="false")]
		public var footerVolumeBtn:DASimpleButton;
				
		[SkinPart(required="false")]
		public var footerSearchBtn:DASimpleButton;
						
		[SkinPart(required="false")]
		public var ticker:DATicker;
		
		[SkinPart(required="true")]
		public var volumeMoveUp:Move;
		
		[SkinPart(required="true")]
		public var volumeMoveDown:Move;
		
		/*[SkinPart(required="false")]
		public var dateTime:DateTime;*/
		
		[SkinPart(required="false")]
		public var volumeSlider:DAValueSlider;
				
		
		public function Footer()
		{
			super();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case copyright:
					copyright.text = DataManager.getInstance().projectObject.copyrightText;
					break;
				case footerHomeBtn:
					footerHomeBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case footerVolumeBtn:
					footerVolumeBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case footerSearchBtn:
					footerSearchBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case ticker:
					var tickerDataItems:ArrayCollection = DataManager.getInstance().fetchWidgetContentItemsByControlType(ControlType.TICKER);
					if(tickerDataItems.length > 0)
						ticker.source = DataManager.getInstance().fetchProjectContentItemsByOwnerId(tickerDataItems[0].id);
					break;
				case volumeMoveUp:
					if(volumeSlider)
						volumeMoveUp.target = volumeSlider;
					break;
				case volumeMoveDown:
					if(volumeSlider)
						volumeMoveDown.target = volumeSlider;
					break;
				case volumeSlider:
					volumeSlider.addEventListener(DAValueSliderEvent.CHANGED, volumeChanged);
					if(volumeMoveUp)
						volumeMoveUp.target = volumeSlider;
					if(volumeMoveDown)
						volumeMoveDown.target = volumeSlider;
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case copyright:
					break;
				case footerHomeBtn:
					footerHomeBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case footerVolumeBtn:
					footerVolumeBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case footerSearchBtn:
					footerSearchBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case ticker:
					break;
				case volumeSlider:
					volumeSlider.removeEventListener(DAValueSliderEvent.CHANGED, volumeChanged);
					break;
			}
		}
		
		public function get volumeSliderHandle():String { return _volumeSliderHandle; }
		public function set volumeSliderHandle(value:String):void {
			if(volumeSlider)
			{
				volumeSlider.handleImage = value;
			}
		}
		
		public function get volumeSliderBar():String { return _volumeSliderBar; }
		public function set volumeSliderBar(value:String):void {
			if(volumeSlider)
			{
				volumeSlider.sliderBarImage = value;
			}
		}
					
		/*private function home_clickHandler(event:MouseEvent):void
		{
			ApplicationUtil.getInstance().defaultClick.play();
			ApplicationUtil.getInstance().returnHome();
		}*/		
		
		/*private function volume_clickHandler(event:MouseEvent):void
		{
			ApplicationUtil.getInstance().defaultClick.play();
			
			volumeTimer.reset();
			volumeTimer.addEventListener(TimerEvent.TIMER, lowerTimer);
			
			if(_isVolumeVisible)
			{
				volumeMoveUp.play();
				_isVolumeVisible = false;
			}else
			{
				volumeMoveDown.play();
				volumeTimer.start();
				_isVolumeVisible  = true;
			}
		}*/
		
		private function onButtonClick(e:MouseEvent):void
		{
			ApplicationUtil.defaultClick.play();
			
			switch(e.currentTarget)
			{
				case footerSearchBtn:
					DesktopApplicationUtil.search();
					break;
				case footerHomeBtn:
					ApplicationUtil.returnHome();
					break;
				case footerVolumeBtn:
					volumeTimer.reset();
					volumeTimer.addEventListener(TimerEvent.TIMER, lowerTimer);
					
					if(_isVolumeVisible)
					{
						volumeMoveDown.play();
						_isVolumeVisible  = false;
					}else{
						volumeMoveUp.play();
						volumeTimer.start();
						_isVolumeVisible = true;
					}
					break;
			}
			
		}
		
		private function volumeChanged(event:DAValueSliderEvent):void
		{
			volumeTimer.reset();
			volumeTimer.start();
			var volumeTransform:SoundTransform = new SoundTransform();
			volumeTransform.volume = Number(event.target.selectedValue);
			SoundMixer.soundTransform = new SoundTransform(volumeTransform.volume);
		}
		
		private function lowerTimer(event:TimerEvent):void
		{
			volumeTimer.removeEventListener(TimerEvent.TIMER, lowerTimer);
			volumeMoveDown.play();
			
			_isVolumeVisible = false;
		}
		
	}
}