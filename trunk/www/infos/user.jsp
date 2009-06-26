<%@ page contentType="text/html;charset=utf-8"%>
<%
	response.setDateHeader("Expires",0);
	response.setHeader("Pragrma","no-cache");
	response.setHeader("Cache-Control","no-cache");

	final int MAX_USER_NAME_LEN = 10;
	
	if(request.getParameter("get") != null){
		if(session.getValue("nickname") != null){
			out.print("{nickname:'" + session.getValue("nickname") + "'}");
		}
		else{
			out.print("");
		}
	}
	else{
		Cookie[] cookies = request.getCookies();
		String nickname = null;
		for(int i=0;i<cookies.length;i++){
			if(cookies[i].getName().equals("nickname")){
				nickname = cookies[i].getValue();
				break;
			}
		}
		if(nickname != null){
			if(nickname.length() > MAX_USER_NAME_LEN){
				session.putValue("nickname",nickname.substring(0,MAX_USER_NAME_LEN));
			}
			else{
				session.putValue("nickname",nickname);
			}
		}
		else{
			session.putValue("nickname",request.getRemoteAddr());
		}
		response.sendRedirect("../play.html");
	}
%>