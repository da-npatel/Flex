
package com.digitalaisle.frontend.components {
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.events.UserTouchEvent;
	import com.digitalaisle.frontend.interfaces.IDaComponent;
	import com.digitalaisle.frontend.utils.LoadQueue;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayerState;
	
	import spark.components.VideoDisplay;
	
	public class DAVideoDisplay extends VideoDisplay implements IDaComponent {
		private var _guid:Number;			
		private var _playLoader:Loader;				// loader for play button png
		private var _playButton:String = "app:/data/images/Home/play.png";								// path to play button png
		private var _pauseButton:String = "app:/data/images/Home/pause.png";
		private var _pauseLoader:Loader;
		private var _replayLoader:Loader;							// loader for replay button png
		private var _muteLoader:Loader;								// This is an awful way to do things
		private var _muteButton:String = "app:/data/images/Home/mute.png";;								// Path to Mute button image
		private var _replayButton:String = "app:/data/images/Home/replay.png";;							// path to replay button png		
		private var _isPlaying:Boolean;								// tracks if video is playing		
		private var _videoRef:DisplayObject;						// reference to video player internally		
		private var _buttonPadding:Number = 15;						// padding between buttons		
		private var _hasControls:Boolean = true;					// boolean to set if controls are visible or not: default is true
		private var _uid:String;
		private var controls:Sprite;
		private var autohidetimer:Timer;
		private var lq:LoadQueue;	
		private var assets:Dictionary;		
		
		public function DAVideoDisplay() {			
			super();
			lq = new LoadQueue();
			controls = new Sprite();			
			controls.visible = false;
			autoRewind = true;
			autohidetimer = new Timer(3000);
			autohidetimer.addEventListener(TimerEvent.TIMER, autoHideControls);			
			addEventListener(Event.ADDED_TO_STAGE, onStage, false, 0, true);		
		}
		
		protected function onStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			_videoRef = getChildAt(0);			
			addEventListener("sourceChanged", onSourceChanged, false, 0, true);
			stage.addEventListener("pauseallvideo", pauseVideo, true, 0, true);			
			addEventListener("playvideo", playVideo, false, 0, true);		
		}
				
		protected function onSourceChanged(e:Event):void {
			trace("video source changed!");
			trace("video state: "+mediaPlayerState);
			trace("video object: "+videoObject);
			if(mediaPlayerState == MediaPlayerState.READY || mediaPlayerState == MediaPlayerState.PLAYING){
				dispatchEvent(new Event("templateitemready"));
			}
		}

		public function init():void	{		
			lq.add(_replayButton);
			lq.add(_playButton);
			lq.add(_pauseButton);
			lq.add(_muteButton);
			lq.addEventListener("assetsloaded", assetsLoaded, false, 0, true);	
			lq.load();
		}
		
		protected function assetsLoaded(e:Event):void {
			lq.removeEventListener("assetsloaded", assetsLoaded);
			try {_replayLoader = lq.ldrs[0].ldr; } catch (e:Error) { _replayLoader = new Loader(); }
			try { _playLoader = lq.ldrs[1].ldr; } catch (e:Error) { _playLoader = new Loader(); }
			try { _pauseLoader = lq.ldrs[2].ldr; } catch (e:Error) { _pauseLoader = new Loader(); }
			try { _muteLoader = lq.ldrs[3].ldr; } catch (e:Error) { _muteLoader = new Loader(); }			
			_playLoader.scaleX = _replayLoader.scaleX = _pauseLoader.scaleX = _muteLoader.scaleX = .75;
			_playLoader.scaleY = _replayLoader.scaleY = _pauseLoader.scaleY = _muteLoader.scaleY = .75;
			
			_replayLoader.x = 0;
			_playLoader.x = (_playLoader.width) + 10;
			_pauseLoader.x = _playLoader.x;
			_muteLoader.x = (_muteLoader.width + 10) * 2;		

			controls.addChild(_replayLoader);
			controls.addChild(_playLoader);	
			controls.addChild(_pauseLoader);
			controls.addChild(_muteLoader);
			
			controls.x = width/2 - controls.width/2;
			controls.y = height/2 - controls.height/2;
			addChild(controls);
									
			_isPlaying = true;
			if(autoPlay){
				_playLoader.visible = false;
				_pauseLoader.visible = true;
			} else {			
				_playLoader.visible = true;
				_pauseLoader.visible = false;
			}
			
			if (_hasControls) {				
				_videoRef.addEventListener(MouseEvent.CLICK, clickHandler, true, 0, true);			
				_pauseLoader.addEventListener(MouseEvent.CLICK, togglePlay, false, 0, true);
				_playLoader.addEventListener(MouseEvent.CLICK, playHandler, false, 0, true);
				_replayLoader.addEventListener(MouseEvent.CLICK, replayHandler, false, 0, true);
				_muteLoader.addEventListener(MouseEvent.CLICK, muteHandler, false, 0, true);
			}			
		}
		
		protected function playVideo(e:Event):void { 
			play();		
			_pauseLoader.visible = true;
			_playLoader.visible = false;
			controls.visible = false;
			play();
			_isPlaying = true;	
			
		}
		
		protected function muteHandler(e:MouseEvent):void {
			volume = volume == 0 ? 100 : 0;
			dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.CLICK, localToGlobal(new Point(mouseX, mouseY))));
		}
		
		protected function pauseVideo(e:Event):void {	
			try {
				_pauseLoader.visible = false;
				_playLoader.visible = true;
				controls.visible = true;			
				pause();
				_isPlaying = false;
			} catch(e:Error) { trace("PauseVideo Warning: "+e); }
		}
		
		protected function onStateChange(e:MediaPlayerStateChangeEvent):void {
			trace("video state: "+e.state);
			switch(e.state){
				case MediaPlayerState.READY:
					trace("DAVideoPlayer ready");
					dispatchEvent(new Event("templateitemready"));
				break;
			}
		}
		
		public function fetchData():void {
			
		}
		
		public function disable():void {
			
		}		
		
		public function update():void {
			// public method to update the component
		}
		
		public function destroy():void {			
			lq.removeEventListener("assetsloaded", assetsLoaded);
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			_videoRef.removeEventListener(MouseEvent.CLICK, togglePlay);			
			removeEventListener("sourceChanged", onSourceChanged);
			_pauseLoader.removeEventListener(MouseEvent.CLICK, togglePlay);
			_playLoader.removeEventListener(MouseEvent.CLICK, playHandler);
			_replayLoader.removeEventListener(MouseEvent.CLICK, replayHandler);
			_muteLoader.removeEventListener(MouseEvent.CLICK, muteHandler);
			try { stage.removeEventListener("pauseallvideo", pauseVideo); } catch(e:Error) { }			
			removeEventListener("playvideo", playVideo);
			autohidetimer.stop();
			autohidetimer.removeEventListener(TimerEvent.TIMER, autoHideControls);
		}
				
		protected function replayHandler(e:MouseEvent):void	{
			dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.CLICK, localToGlobal(new Point(mouseX, mouseY))));			
			stop();			
			play();
			controls.visible = false;
		}
		
		protected function playHandler(e:MouseEvent):void {
			dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.CLICK, localToGlobal(new Point(mouseX, mouseY))));			
			play();
			togglePlay(e);
			dispatchEvent(new Event("pauseAvatar"));
		}
		
		protected function clickHandler(e:MouseEvent):void {
			dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.CLICK, localToGlobal(new Point(mouseX, mouseY))));
			autohidetimer.start();
			showControls();
		}
		
		public function showControls():void {			
			controls.visible = true;			
		}
		
		protected function autoHideControls(e:TimerEvent):void {
			hideControls();
			autohidetimer.reset();
		}
		public function hideControls():void {
			controls.visible = false;			
		}
		
		protected function togglePlay(e:MouseEvent):void {
			dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.CLICK, localToGlobal(new Point(mouseX, mouseY))));
			if (_isPlaying) { // stop video and display paused graphic
				_pauseLoader.visible = false;
				_playLoader.visible = true;
				controls.visible = true;				
				pause();
				_isPlaying = false;				
			} else { // play video and remove controls
				_pauseLoader.visible = true;
				_playLoader.visible = false;
				autohidetimer.reset();
				autohidetimer.start();				
				//seek(currentTime);
				play();
				_isPlaying = true;				
			}			
		}
		
		// GETTERS AND SETTERS

		public function get guid():Number
		{
			return _guid;
		}

		public function set guid(value:Number):void
		{
			_guid = value;
		}

		public function get playButton():String
		{
			return _playButton;
		}

		public function set playButton(value:String):void
		{
			_playButton = value;
		}

		public function get replayButton():String
		{
			return _replayButton;
		}

		public function set replayButton(value:String):void
		{
			_replayButton = value;
		}
		
		public function get muteButton():String
		{
			return _muteButton;
		}
		
		public function set muteButton(value:String):void
		{
			_muteButton = value;
		}

		public function get hasControls():Boolean
		{
			return _hasControls;
		}

		public function set hasControls(value:Boolean):void
		{
			_hasControls = value;
		}

		public function get pauseButton():String
		{
			return _pauseButton;
		}

		public function set pauseButton(value:String):void
		{
			_pauseButton = value;
		}
	}
}