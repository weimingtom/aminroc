<%@ language="javascript" CODEPAGE="65001"%>
<%
	Response.Charset = 'utf-8';
	Response.Expires = 0;
	Response.CacheControl = "no-cache";
	Response.AddHeader("Pragma","no-cache");

	var MAX_USER_NAME_LEN = 10;
	
	if(Request.QueryString('get').Item){
		if(Session('nickname')){
			Response.Write("{nickname:'" + Session('nickname') + "'}");
		}
		else{
			Response.Write('');
		}
	}
	else{
		var nickname = Request.Cookies('nickname').Item;
		if(nickname){
			Session('nickname') = nickname.substr(0,MAX_USER_NAME_LEN);
		}
		else{
			Session('nickname') = Request.ServerVariables("REMOTE_ADDR").Item;
		}
		Response.Redirect('../play.html');
	}
%>