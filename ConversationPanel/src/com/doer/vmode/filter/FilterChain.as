package com.doer.vmode.filter
{
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;

	public class FilterChain
	{
		private var filters:Vector.<AnalysisFilter> = null;
		
		public function FilterChain()
		{
			invalidate();
		}
		
		/**
		 * 初始化过滤器
		 * **/
		private function invalidate():void
		{
			filters = new Vector.<AnalysisFilter>();
			
			filters.push(new AnalysisFilter(NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_PUBLISH_INFORM)); //视频流
			filters.push(new AnalysisFilter(NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_PUBLISH_INFORM)); //音频流
			filters.push(new AnalysisFilter(NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO2_PUBLISH_INFORM));
			
			filters.push(new AnalysisFilter(NebulaMessageBusinessType.SERVER_COMPLEX_CHANGE_SCREEN_MODE_INFORM)); //切换主界面
			
			filters.push(new IndexAnalysisFilter(NebulaMessageBusinessType.SERVER_COMPLEX_CHANGE_SCREEN_INFORM)); //切换主界面
			
			filters.push(new IndexAnalysisFilter(NebulaMessageBusinessType.SERVER_COMPLEX_MOVE_INFORM)); //课件翻页或者移动黑板
			filters.push(new IndexAnalysisFilter(NebulaMessageBusinessType.SERVER_COMPLEX_MEDIA_CTRL_INFORM)); //控制多媒体
		}
		
		/**
		 * 获取从startTime到endTime的消息数组
		 * **/
		public function filt(messages:Array):Array
		{
			var arr:Array = messages;
			
			
			for(var i:int = 0; i < filters.length; i ++)
			{
				arr = filters[i].filt(arr);
			}
			
			
			return arr;
		}
		
	}
}