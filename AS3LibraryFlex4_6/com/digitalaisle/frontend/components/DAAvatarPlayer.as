package com.digitalaisle.frontend.components
{
	import com.digitalaisle.frontend.drawing.DynamicShape;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.controls.VideoDisplay;
	import mx.controls.videoClasses.CuePointManager;
	import mx.core.mx_internal;
	import mx.events.CuePointEvent;
	import mx.events.MetadataEvent;
	import mx.events.VideoEvent;
	
	import org.casalib.util.ObjectUtil;
	
	public class DAAvatarPlayer extends VideoDisplay
	{
		private static const VIDEO_FRAMERATE:int = 30;
		private static const CHANGE_DIRECTION_THRESHOLD:Number = .985;
		private static const TARGET_CUEPOINT:String = "BeginIdle";
		private static const MIN_FRAMERATE:int = 20;
		private static const MAX_FRAMERATE:int = VIDEO_FRAMERATE;
		private static const BEGIN_IDLE:String = "BeginIdle";
		private static const END_IDLE:String = "EndIdle";
		private static const GOTO_AVATAR:String = "gotoAvatar";
		private static const GOTO_CUEPOINT:String = "gotoCuePoint";
		
		[Embed(source="icons/play.png")]
		protected var PlayBtnClass:Class;
		[Embed(source="icons/replay.png")]
		protected var ReplayBtnClass:Class;
		[Embed(source="icons/pause.png")]
		protected var PauseBtnClass:Class;
		[Embed(source="icons/mute.png")]
		protected var MuteBtnClass:Class;
		
		protected var controls:Sprite;
		protected var playBtn:Sprite;
		protected var replayBtn:Sprite;
		protected var pauseBtn:Sprite;
		protected var muteBtn:Sprite;
		protected var videoPlayer:Object
		
		protected var touchSurface:DynamicShape;
		protected var idleContainer:Sprite;
		private var _idleTimer:Timer;
		private var _animationSequenceTimer:Timer;				// Sequence animation interval
		private var _frameRateTimer:Timer;						// Plays the animation like a flipbook
		private var _sourceChanged:Boolean = false;
		private var _videoSource:String;
		private var _playerValues:Dictionary = new Dictionary(true);
		
		private var _currentFrameDisplayed:int = 0;
		private var _totalFrames:int = 0;
		private var _isVideoError:Boolean = false;
		private var _isIdling:Boolean = false;
		private var _isPlayingFoward:Boolean;
		private var _isAnimationCreated:Boolean = false;
		private var _lastCuePoint:Object = null;
		private var _isMetadataReceived:Boolean = false;
		//private var _randomFPSValue:int;
		//private var _randomSecondsValue:int;
		
		
		private var _btnSpacing:int = 4;
		private var _isControlsActive:Boolean;		
		private var _autohidetimer:Timer;
		private var _hasCuePoints:Boolean = false;
		private var _cuePointsReceived:Boolean = false;
		private var _isCuePointInQue:Boolean = false;
		private var _isPlaybackOverridden:Boolean = false;
		
		// READ/WRITE
		private var _hasControls:Boolean = true;
		private var _autoHideControls:Boolean = true;
		private var _controlsPosition:int = 5;
		private var _enableIdleAnimation:Boolean = false;
		private var _cuePoints:Array = new Array();
		
		public function DAAvatarPlayer()
		{
			super();
			autoPlay = true;
			setStyle("contentBackgroundAlpha", 0);
			//this.styleManager.setStyleDeclaration(
			var caputreFrameRate:Number=Math.round(1000/VIDEO_FRAMERATE);
			
			_autohidetimer = new Timer(3000);
			_animationSequenceTimer = new Timer(1);
			_frameRateTimer = new Timer(1);
			_idleTimer = new Timer(caputreFrameRate);
			cuePointManagerClass = CuePointManager;
			
			//if(isUsingIdleAnimation) then add these listeners
			
			// Possibly add this to play() override
			addEventListener(CuePointEvent.CUE_POINT, onCuePointsReceived, false, 0, true);
			addEventListener(VideoEvent.COMPLETE, onVideoComplete);
			addEventListener(VideoEvent.READY, onVideoReady, false, 0, true);
			addEventListener(VideoEvent.STATE_CHANGE, onVideoStateChange, false, 0, true);
			addEventListener(Event.REMOVED, removedHandler);
			
			_animationSequenceTimer.addEventListener(TimerEvent.TIMER, onAnimationSequenceReset, false, 0, true);
			_frameRateTimer.addEventListener(TimerEvent.TIMER, onFrameRateProcess, false, 0, true);
		}
		
		private function onMetaReceived(e:MetadataEvent):void
		{
			trace(e.target)
			
			if(ObjectUtil.contains(e.info, e.info.cuePoints)) 
			{ 
				_cuePoints = e.info.cuePoints; 
			}
			
			trace("points 2 = " + _cuePoints);
			_isMetadataReceived = true;
			removeEventListener(MetadataEvent.METADATA_RECEIVED, onMetaReceived);
			
			if(_isCuePointInQue)
			{
				switch(_playerValues["NextQueAction"])
				{
					case "Play":
						gotoAndPlayCuePoint(_playerValues["NextCuePoint"]);
						break;
					case "Pause":
						gotoAndPauseCuePoint(_playerValues["NextCuePoint"]);
						break;
				}
			}
			
		}
		
		override public function play():void
		{
			
			if(_isAnimationCreated)
			{
				emptyIdleContainer();
				
				if(!ObjectUtil.isNull(_lastCuePoint))
				{
					gotoAndPlayCuePoint(_lastCuePoint.name);
				}else
				{
					playheadTime = 0;
					super.play();
				}
				
			}else
			{
				super.play();
			}
			
			togglePlay(false);
			if(videoPlayer.alpha == 0) { videoPlayer.alpha = 1; }
			
		}
		
		
		override public function pause():void
		{
			super.pause();
			
			togglePlay(true);
			//enableControls(true);
		}
		
		
		override public function stop():void
		{
			super.stop();
			
			emptyIdleContainer();
		}
		
		
		override public function set source(value:String):void
		{
			
			/*if(enableIdleAnimation && _isAnimationCreated)
			{
				_playerValues["AutoPlay"] = autoPlay;
				autoPlay = false;
				playIdleAnimationTillEnd();
			}*/
			
			if(value == _videoSource)
			{
				_sourceChanged = false;
			}else
			{	
				_cuePoints = [];
				_isMetadataReceived = false;
				addEventListener(MetadataEvent.METADATA_RECEIVED, onMetaReceived, false, 0, true);
				
				if(_isVideoError)
				{
					visible = true;
					_isVideoError = false;
				}
				
				_videoSource = value;
				_sourceChanged = true;
				
				// Reset in values
				_lastCuePoint = null;
				_isCuePointInQue = false;
				
				// Delete instance of idle animtion
				emptyIdleContainer();
			}
			
			enableControls(false);
			super.source = value;
		}
		
		public function seekToEnd():void
		{
			if(metadata) {
				if(videoPlayer) {
					
					playheadTime = Math.floor(metadata.duration - .3);
					pause();
				}
			}
		}
		
		public function rewind():void
		{
			pause();
			playheadTime = 0;
		}
		
		
		public function gotoAndPlayCuePoint(cuePoint:String):void
		{
			if(_isMetadataReceived)
			{
				var hasCuePoint:Boolean = false;
				for(var i:int = 0; i < _cuePoints.length; i ++)
				{
					if(_cuePoints[i].name == cuePoint)
					{
						playheadTime = _cuePoints[i].time - 1;
						_lastCuePoint = _cuePoints[i].name;
						hasCuePoint = true;
						
						togglePlay(false);
						super.play();
						break;
					}
				}

				if(!hasCuePoint)
				{
					play();
				}
			}else
			{
				_isCuePointInQue = true;
				_playerValues["NextQueAction"] = "Play";
				_playerValues["NextCuePoint"] = cuePoint;
			}
		}
		
		
		public function gotoAndPauseCuePoint(cuePoint:String):void
		{
			var hasCuePoint:Boolean = false;
			if(_isMetadataReceived)
			{
				for(var i:int = 0; i < cuePoints.length; i ++)
				{
					if(cuePoints[i].name == cuePoint)
					{
						playheadTime = cuePoints[i].time;
						_lastCuePoint = cuePoints[i].name;
						hasCuePoint = true;
						
						pause();
						
						break;
					}
				}
				
				if(!hasCuePoint)
				{
					pause();
				}
			}else
			{
				_isCuePointInQue = true;
				_playerValues["NextQueAction"] = "Pause";
				_playerValues["NextCuePoint"] = cuePoint;
			}
		}
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			videoPlayer = getChildAt(1);
			
			idleContainer = new Sprite();
			addChild(idleContainer);
			
			controls = new Sprite();
			controls.mouseChildren = true;
			playBtn = new Sprite();
			replayBtn = new Sprite();
			pauseBtn = new Sprite();
			muteBtn = new Sprite();
			
			touchSurface = new DynamicShape();
			
			touchSurface.doDrawRect(10, 10, 0x333333, 0);
			touchSurface.addEventListener(MouseEvent.MOUSE_DOWN, onVideoTap, false, 0, true);
			addChild(touchSurface);
			
			// Add Display Objects to the Display List
			playBtn.addChild(createButtonBitmap(PlayBtnClass));
			replayBtn.addChild(createButtonBitmap(ReplayBtnClass));
			pauseBtn.addChild(createButtonBitmap(PauseBtnClass));
			muteBtn.addChild(createButtonBitmap(MuteBtnClass));
			
			addChild(controls);
			controls.addChild(playBtn);
			controls.addChild(replayBtn);
			controls.addChild(pauseBtn);
			controls.addChild(muteBtn);
			
			// Position Control Buttons
			positionControlButtons();
			
			// Disable Visiblity of Controls
			enableControls(false);
			//_isControlsActive = false;
			
		}
		

		// Only if in idle mode
		private function playIdleAnimationTillEnd():void
		{
			_isPlaybackOverridden = true;
			_isPlayingFoward = true;
			_frameRateTimer.reset();
			_frameRateTimer.delay = randomizeFrameRate();
			_frameRateTimer.start();
			
			
		}
		
		
		private function createButtonBitmap(BtnClass:Class):Bitmap
		{
			var btnBitmap:Bitmap = new BtnClass();
			btnBitmap.smoothing = true;
			return btnBitmap;
		}
		
		
		private function emptyIdleContainer():void
		{
			//cleanUp();
			_animationSequenceTimer.reset();
			_frameRateTimer.reset();
			_idleTimer.reset();
			_isAnimationCreated = false;
			
			if(idleContainer)
			{
				idleContainer.visible = false;
				
				// Clean up idle container
				while(idleContainer.numChildren > 0)
				{
					idleContainer.removeChildAt(0);
				}
					
				idleContainer.visible = true;
				_totalFrames = _currentFrameDisplayed = 0;
			}
			
			
		}
		
		
		private function createBitmapSequence():void
		{
			
			// CHECK TO SEE IF IT IS STILL CAPTURING THEN WHEN VIDEO IS REPLACED I BELIEVE IT CAUSES THIS ERROR;;NOT GOOD
			try{
				var redrawBitmapData:BitmapData = new BitmapData(this.width, this.height, true, 0xffffff);
				var redrawBitmap:Bitmap = new Bitmap(redrawBitmapData);
				redrawBitmap.name = "sequence" + _currentFrameDisplayed;
				redrawBitmapData.draw(this);
				redrawBitmap.visible = false;
				idleContainer.addChild(redrawBitmap);
			}catch(errObject:Error){
				
			}
		}
		
		
		private function cleanUp():void
		{
			if(_idleTimer.running) { _idleTimer.reset(); }
			if(_animationSequenceTimer.running) { _animationSequenceTimer.reset(); }
			if(_frameRateTimer.running) { _frameRateTimer.reset(); }
			
			if(_idleTimer.hasEventListener(TimerEvent.TIMER)){ _idleTimer.removeEventListener(TimerEvent.TIMER, onVideoCaptureProcess); }
			if(_animationSequenceTimer.hasEventListener(TimerEvent.TIMER)){ _animationSequenceTimer.removeEventListener(TimerEvent.TIMER, onAnimationSequenceReset); }
			
		}
		
		
		private function updateSequenceTimers():void
		{
			_animationSequenceTimer.reset();
			_frameRateTimer.reset();
			
			var randomFramerate:Number = randomizeFrameRate();
			var randomSequenceInterval:Number = randomizeAnimationInterval();
			
			// Begin Timers
			_animationSequenceTimer.delay = (randomSequenceInterval * 1000);
			_frameRateTimer.delay = 1000/randomFramerate;
			
			_animationSequenceTimer.start();
			_frameRateTimer.start();
		}

		
		private function playIdleBackward():void
		{
			// CHECK TO SEE IF IT IS EVER 0 so that it does not go negative
			
			if(_currentFrameDisplayed > 1)
			{
				var currentFrame:Bitmap = idleContainer.getChildByName("sequence" + _currentFrameDisplayed) as Bitmap;
				currentFrame.visible = false;
				
				_currentFrameDisplayed--;
				var prevFrame:Bitmap = idleContainer.getChildByName("sequence" + _currentFrameDisplayed) as Bitmap;
				prevFrame.visible = true;
			}else
			{
				_isPlayingFoward = true;
			}
			//trace("sequence" + _currentFrameDisplayed);
		}
		
		
		private function playIdleForward():void
		{
			if(_currentFrameDisplayed  < _totalFrames)
			{
				// if current frame is greater than totalFrames then now going backword
				var currentFrame:Bitmap = idleContainer.getChildByName("sequence" + _currentFrameDisplayed) as Bitmap;
				currentFrame.visible = false;
				_currentFrameDisplayed++;
				//trace("CURRENT FOWARD = " + _currentFrameDisplayed);
				var nextFrame:Bitmap = idleContainer.getChildByName("sequence" + _currentFrameDisplayed) as Bitmap;
				nextFrame.visible = true;
			}else
			{
				/*if(_isPlaybackOverridden)
				{
					_frameRateTimer.reset();
					_isPlaybackOverridden = false;
					emptyIdleContainer();
					
					autoPlay = _playerValues["AutoPlay"];
					if(_playerValues["AutoPlay"]) { play(); }
					else { pause(); }
				}else
				{
					_isPlayingFoward = false;
				}*/
				
				_isPlayingFoward = false;
			}
			//trace("sequence" + _currentFrameDisplayed);
		}
		
		
		private function beginIdleLoop():void
		{
			togglePlay(true);
			videoPlayer.alpha = 0;
			
			_currentFrameDisplayed = _totalFrames = idleContainer.numChildren;
			
			// Reset Animation Frames
			idleContainer.getChildByName("sequence" + _totalFrames).visible = true;
			idleContainer.visible = true;
			
			_isPlayingFoward = false;
			
			//playIdleBackward();
			updateSequenceTimers();
		}
		
		private function addButtonEventListeners():void
		{
			playBtn.addEventListener(MouseEvent.MOUSE_DOWN, onControlButtonPress, false, 0, true);
			replayBtn.addEventListener(MouseEvent.MOUSE_DOWN, onControlButtonPress, false, 0, true);
			pauseBtn.addEventListener(MouseEvent.MOUSE_DOWN, onControlButtonPress, false, 0, true);
			muteBtn.addEventListener(MouseEvent.MOUSE_DOWN, onControlButtonPress, false, 0, true);
			_autohidetimer.addEventListener(TimerEvent.TIMER, onAutoHideControls, false, 0, true);
		}
		
		
		private function removeButtonEventListeners():void
		{
			playBtn.removeEventListener(MouseEvent.MOUSE_DOWN, onControlButtonPress);
			replayBtn.removeEventListener(MouseEvent.MOUSE_DOWN, onControlButtonPress);
			pauseBtn.removeEventListener(MouseEvent.MOUSE_DOWN, onControlButtonPress);
			muteBtn.removeEventListener(MouseEvent.MOUSE_DOWN, onControlButtonPress);
			_autohidetimer.removeEventListener(TimerEvent.TIMER, onAutoHideControls);
		}
		
		
		private function togglePlay(enable:Boolean):void
		{
			playBtn.visible = enable;
			pauseBtn.visible = !enable;
		}
		
		
		private function enableControls(enable:Boolean):void
		{
			if(controls)
			{
				_isControlsActive = controls.visible = enable;
				
				if(enable)
				{
					addButtonEventListeners();
					if(_autoHideControls){
						_autohidetimer.start();
					}
				} else {
					if(_autoHideControls){
						removeButtonEventListeners();
						_autohidetimer.reset();						
					} else {
						controls.visible = true;
					}					
				}				
			}
		}
		
		private function positionControlButtons():void
		{
			replayBtn.x = 0;
			playBtn.x = replayBtn.width + _btnSpacing;
			pauseBtn.x = replayBtn.width + _btnSpacing;
			muteBtn.x = pauseBtn.x + pauseBtn.width + _btnSpacing;
			
			// Default the pause button's visibility
			pauseBtn.visible = false
		}
		
		
		private function randomizeFrameRate():Number
		{
			var randomValue:Number = MIN_FRAMERATE + (MAX_FRAMERATE - MIN_FRAMERATE) * Math.random();
			//trace("RANDOM FRAMERATE = " + randomValue);
			return Math.round(randomValue);
		}
		
		
		private function randomizeAnimationInterval():Number
		{
			var randomValue:Number = 1 + (3 - 1) * Math.random();
			return randomValue;
		}
		
		//TODO: Expand this functionality
		private function handleVideoError(hasError:Boolean):void
		{
			if(hasError)
			{
				this.visible = false;
			}else
			{
				
			}
		}
		
		private function onCuePointsReceived(e:CuePointEvent):void
		{
			if(_enableIdleAnimation)
			{
				trace(e.cuePointName);
				switch(e.cuePointName)
				{
					case BEGIN_IDLE:
						
						if(_isAnimationCreated)
						{
							emptyIdleContainer();	
						}	
						
						
						// Begin idle animation creation
						_idleTimer.addEventListener(TimerEvent.TIMER, onVideoCaptureProcess, false, 0, true);
						_idleTimer.start();
						
						break;
					case END_IDLE:
						
						pause();
						
						if(idleContainer.numChildren > 0) {
							// End idle animation creation
							_idleTimer.reset();
							_idleTimer.removeEventListener(TimerEvent.TIMER, onVideoCaptureProcess);
							_isAnimationCreated = true;
							
							// Reset
							_sourceChanged = false;		// STILL NEEDED??? This was previously in the onVideoComplete handler
							
							// Begin Playing Idle Animation
							beginIdleLoop();
						}
						
						break;
				}
			}
		}
		
		
		
		private function onVideoComplete(e:VideoEvent):void
		{
			if(!_enableIdleAnimation)
			{
				
				togglePlay(true);
				
				
				/*if(_sourceChanged || !_isAnimationCreated)
				{
					_isAnimationCreated = true;
					
					if(_idleTimer.hasEventListener(TimerEvent.TIMER)){ _idleTimer.removeEventListener(TimerEvent.TIMER, onVideoCaptureProcess) };
					_idleTimer.stop();
				}
			
				if(_hasCuePoint && _enableIdleAnimation)
				{
					// Begin Playing Idle Animation
					beginIdleLoop();
					
					videoPlayer.alpha = 0;
				}*/
			}
			
			// Reset
			//_sourceChanged = false;
		
		}
		
		
		private function onVideoReady(e:VideoEvent):void
		{
			touchSurface.width = videoWidth;
			touchSurface.height = videoHeight;
			//trace("VIDEO READY");
			trace("points = " + _cuePoints);
			// Position/Size Controls Bar
			if(controls.width > width)
			{
				var percentage:Number = 1 - width/controls.width;
				var scaleValue:Number = percentage;
				
				controls.scaleX = 1 - scaleValue;
				controls.scaleY = 1 - scaleValue;
			}
			switch(_controlsPosition){
				case 5:
					controls.x = (videoWidth * .5) - (controls.width * .5);
					controls.y = (videoHeight * .5)- (controls.height * .5);	
					break;
				
				case 8:
					controls.x = (videoWidth * .5) - (controls.width * .5);
					controls.y = (videoHeight - 15) - controls.height;
					break;
			}
			
			enableControls(!_autoHideControls);
		}
		
		
		private function onVideoTap(e:MouseEvent):void
		{
			if(!_isControlsActive){ enableControls(true);}
		}
		
		private function onVideoCaptureProcess(e:TimerEvent):void
		{
			_currentFrameDisplayed++;
			createBitmapSequence();
		}
		
		
		private function onAnimationSequenceReset(e:TimerEvent):void
		{
			// Reset Timer
			updateSequenceTimers();
		}
		
		
		private function onFrameRateProcess(e:TimerEvent):void
		{
			if(_isPlayingFoward){ playIdleForward(); }
			else{ playIdleBackward();}
		}
		
		
		private function onControlButtonPress(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case playBtn:
					play();
					enableControls(false);
					break;
				case replayBtn:
					stop();			
					play();
					enableControls(false);
					break;
				case pauseBtn:
					pause();		// TODO: What happens if Idle Container is still being created
					enableControls(false);
					break;
				case muteBtn:
					volume = volume == 0 ? 100 : 0;
					break;
			}
		}
		
		
		private function onVideoStateChange(e:VideoEvent):void
		{
			switch(e.state)
			{
				case VideoEvent.CONNECTION_ERROR:
					trace("VIDEO ERROR = " + source);
					_isVideoError = true;
					visible = false;
					break;
			}
		}
		
		private function removedHandler(e:Event):void
		{
			trace("removes");
		}
		
		
		//private 
		
		private function onAutoHideControls(e:TimerEvent):void
		{
			enableControls(false);
		}

		public function get autoHideControls():Boolean
		{
			return _autoHideControls;
		}

		public function set autoHideControls(value:Boolean):void
		{
			_autoHideControls = value;
		}

		public function get enableIdleAnimation():Boolean
		{
			return _enableIdleAnimation;
		}

		public function set enableIdleAnimation(value:Boolean):void
		{
			_enableIdleAnimation = value;
		}

		public function get controlsPosition():int
		{
			return _controlsPosition;
		}

		public function set controlsPosition(value:int):void
		{
			if(value < 1){
				value = 1;
			} else if(value > 9){
				value = 9;
			}
			_controlsPosition = value;
		}


	}
}