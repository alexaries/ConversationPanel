package com.doer.interfaces
{
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;

	/**
	 * socket消息处理接口
	 * **/
	public interface ISProcessor
	{
		/**
		 * 被踢掉线
		 * **/
		function signOutPassive(refMsg:ServerPassiveOutInform):void
			
		/**
		 * 收到服务端消息
		 * **/
		function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
	}
}