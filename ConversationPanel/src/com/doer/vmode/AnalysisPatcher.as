package com.doer.vmode
{
	import com.doer.config.ModeTypes;
	import com.doer.manager.MetaManager;
	import com.doer.net.login.LoginController;
	import com.doer.vmode.filter.AnalysisFilter;
	import com.doer.vmode.filter.FilterChain;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class AnalysisPatcher
	{
		private var metaManager:MetaManager = null;
		
		private var dataMode:AnalysisMode = null;
		
		private var analysis:VideoAnalysis = null;
		
		private var timer:Timer = null;
		
		private var time:Number = 0;
		
		private var filterChain:FilterChain = null;
		
		public function AnalysisPatcher(metaManager:MetaManager,dataMode:AnalysisMode,analysis:VideoAnalysis)
		{
			this.metaManager = metaManager;
			this.dataMode = dataMode;
			this.analysis = analysis;
			
			this.filterChain = new FilterChain();
			
			timer = new Timer(1000/ 24);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			
		}
		
		private function onTimer(e:TimerEvent):void
		{
			var nTime:Number = time + timer.delay;
			
			startAction(getActionMessages(time,nTime));
			
			time = nTime;
			
			if(time >= dataMode.datas[dataMode.datas.length - 1].time)
			{
				pause();
				
				analysis.onComplete();
				
			}else
			{
				analysis.onTime(time);
			}
			
			
		}
	
		/**
		 * 获取要被执行的数据
		 * **/
		private function getActionMessages(startTime:Number,endTime:Number):Array
		{
			var msgs:Array = new Array();
			
			for(var i:int = 0; i < dataMode.datas.length; i ++)
			{
				if(dataMode.datas[i].time > startTime && dataMode.datas[i].time <= endTime)
				{
					msgs.push(dataMode.datas[i]);
				}
				
				if(dataMode.datas[i].time > endTime)
					break;
				
			}
			
			return msgs;
		}
		
		/**
		 * 执行消息
		 * **/
		private function startAction(messages:Array):void
		{
			
			if(messages.length > 1 )
			{
				messages = filterChain.filt(messages);
			}
				
			
			for(var i:int = 0; i < messages.length; i ++)
			{
				metaManager.onRcv(messages[i].data,messages[i].type,null);
			}
			
		}
		
		/**
		 * 快进快退
		 * **/
		public function seek(time:Number):void
		{
			metaManager.reset();
			
			(metaManager.getControllerById(ModeTypes.MODE_LOGIN_ID) as LoginController).onLoginConversationReplay(JsonUtils.convertJsonToClass(dataMode.datas[0].data,ServerComplexEnterResp));
			
			startAction(getActionMessages(0,time));
			
			this.time = time;
			
		}
		
		/**
		 * 开始播放数据
		 * **/
		public function play():void
		{
			timer.start();
		}
		
		/**
		 * 暂停开始播放数据
		 * **/
		public function pause():void
		{
			metaManager.reset();
			
			time = 0;
			
			timer.stop();
			
			analysis.onTime(time);
		}
		
	}
}