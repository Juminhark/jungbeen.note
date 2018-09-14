package jungbeen.note.user.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jungbeen.note.user.domain.Message;
import jungbeen.note.user.domain.User;
import jungbeen.note.user.service.HtmlMailService;
import jungbeen.note.user.service.UserService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

@Controller
@RequestMapping("/")
public class UserController {
	@Autowired private UserService userService;
	@Autowired private HtmlMailService mailService;
	
	
	@RequestMapping("test")
	public String test(){
		return "user/test";
	}
	
	
	////////////////////////////// login.jsp에서 사용 //////////////////////////////
	@RequestMapping(method = RequestMethod.GET)
	public String login(){
		return "user/logIn";
	}
	
	@RequestMapping(method = RequestMethod.POST)
	@ResponseBody
	public boolean loginId(HttpServletRequest request){
		boolean result = false;
		String userId = request.getParameter("userId");
		
		if(userId != null && !userId.equals("")){
			User corUser = userService.findUser(userId);
			if(corUser != null){
				request.getSession().setAttribute("corUser", corUser);	
				result = true;	
			}else{
				result = false;
			}
		}else{
			result = false;
		}
		return result;
	}
	
	@RequestMapping(value="passCheck", method = RequestMethod.POST)
	@ResponseBody
	public boolean checkPw(HttpServletRequest request, HttpServletResponse response){
		boolean result = false;
		String userPw = request.getParameter("userPw");		
		if(userPw != null && !userPw.equals("")){	
			User corUser = (User)request.getSession().getAttribute("corUser");
			if(userPw.equals(corUser.getUserPw())){

				String userId = corUser.getUserId();
				Cookie cookieId = new Cookie("userId", userId);
				cookieId.setMaxAge(60*60*24);
				response.addCookie(cookieId);
				result = true;
			}else{
				result = false;
			}
		}else{
			result = false;
		}
		return result;
	}
	///////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////// addUser.jsp에서 사용 //////////////////////////////
	@RequestMapping(value="/addUser",method = RequestMethod.GET)
	public String addUser(){
		return "user/addUser";
	}
	
	@ResponseBody
	@RequestMapping(value="/addUser",method = RequestMethod.POST)
	public boolean addUser(HttpServletRequest request){
		String userName = request.getParameter("userName");
		String userId = request.getParameter("userId");
		String userPw = request.getParameter("userPw");
		String userEmail = request.getParameter("userEmail");	
		User newUser = new User(userId, userPw, userName, userEmail);
		
		boolean result = false;
		
		if(userName != null && !userName.equals(""))
			if(userId != null && !userId.equals(""))
				if(userPw != null && !userPw.equals(""))
					if(userEmail != null && !userEmail.equals("")) {
						userService.join(newUser);
						result = true;
					}
		
		if(result){
			request.getSession().setAttribute("corUser", newUser);
		}
		
		return result;
	}
	
	@RequestMapping(value="idCheck", method = RequestMethod.POST)
	@ResponseBody
	public boolean checkId(HttpServletRequest request){
		boolean result = false;
		String userId = request.getParameter("userId");		
		User corUser = userService.findUser(userId);
		if(corUser == null){
			result = true;
		}else{
			result = false;
		}
		return result;
	}
	
	///////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////// findId.jsp에서 사용 /////////////////////////////////
	@RequestMapping(value="/findId",method = RequestMethod.GET)
	public String findId(){
		return "user/findId";
	}
	
	@RequestMapping(value="/findId",method = RequestMethod.POST)
	@ResponseBody
	public boolean findId(HttpServletRequest request){
		boolean result = false;
		String userName = request.getParameter("userName");
		List<User> corUsers = userService.findIds(userName);
		// userName을 갖는 list를 가져왔으니 session에 저장해놓고 나중에 입력된 이메일을 가지고 있는 1명을 찾아낸다
		if(!corUsers.isEmpty()){		
			request.getSession().setAttribute("corUsers", corUsers);		
			result = true;	
		}else{
			result = false;
		}
	return result;
	}
	
	@RequestMapping(value="emailCheck", method = RequestMethod.POST)
	@ResponseBody
	public User checkEmail(HttpServletRequest request){
		String userEmail = request.getParameter("userEmail");		
		List<User> corUsers = (List<User>)request.getSession().getAttribute("corUsers");
		User seleteUser = null;
		for(User corUser : corUsers){
			if(userEmail.equals(corUser.getUserEmail())){
					seleteUser = corUser;
			}
		}
		return seleteUser;
	}
	

	@RequestMapping(value="/intoId")
	public String intoId(HttpServletRequest request){
		
		String userId = request.getParameter("userId");
		request.getSession().setAttribute("userId", userId);
		
		User corUser = userService.findUser(userId);
		request.getSession().setAttribute("corUser", corUser);
		return "redirect:/";
	}
	
	/////////////////////////////////////////////////////////////////////////////
	
	//////////////////////////////findPw.jsp에서 사용 /////////////////////////////////
	
	@RequestMapping(value="/findPw",method = RequestMethod.GET)
	public String findPw(){
		return "user/findPw";
	}
	
	@RequestMapping(value="/findPw",method = RequestMethod.POST)
	@ResponseBody
	public boolean findPw(HttpServletRequest request){
		boolean result = false;
		String userName = request.getParameter("userName");
		List<User> corUsers = userService.findIds(userName);
		// userName을 갖는 list를 가져왔으니 session에 저장해놓고 나중에 입력된 이메일을 가지고 있는 1명을 찾아낸다
		if(!corUsers.isEmpty()){		
			request.getSession().setAttribute("corUsers", corUsers);		
			result = true;	
		}else{
			result = false;
		}
	return result;
	}
	
	@RequestMapping(value="emailSend", method = RequestMethod.POST)
	@ResponseBody
	public boolean SendEmail(HttpServletRequest request){
		boolean result = false;
		String userEmail = request.getParameter("userEmail");		
		List<User> corUsers = (List<User>)request.getSession().getAttribute("corUsers");
		for(User corUser : corUsers){

			if(userEmail.equals(corUser.getUserEmail())){
				
				request.getSession().setAttribute("corUser", corUser);
				
				String toEmail = corUser.getUserEmail();
				String subject = "note 비밀번호입니다.";
				String txt = corUser.getUserId() + "님의 비밀번호는 " + corUser.getUserPw() + " 입니다.";

				Message msg = new Message(toEmail, subject, txt);
				mailService.send(msg);
				result = true; break;
			}else{
				result = false;
			}
		}
		return result;
	}
	
	@RequestMapping(value="/intoPw")
	public String intoPw(HttpServletRequest request){
	
		User corUser = (User)request.getSession().getAttribute("corUser");
		String userId = corUser.getUserId();
		
		request.getSession().setAttribute("userId", userId);
		return "redirect:/";
	}
	/////////////////////////////////////////////////////////////////////////////
	
	///////////////////////////////main.jsp 에서 사용 //////////////////////////////
	
	@RequestMapping(value="nameChange", method = RequestMethod.POST)
	@ResponseBody
	public User nameChange(HttpServletRequest request){
		String userName = request.getParameter("userName");
		
		String userId = null;
		Cookie[] cookies = request.getCookies();
		for(Cookie cookie:cookies){
			if(cookie.getName().equals("userId")){
				userId = cookie.getValue();
			}
		}
		
		User changeUser = new User();
		changeUser.setUserId(userId);
		changeUser.setUserName(userName);
		
		userService.updateName(changeUser);
		
		User corUser = userService.findUser(userId);
		request.getSession().setAttribute("corUser", corUser);	
		return corUser;
	}
	
	@RequestMapping(value="pwChange", method = RequestMethod.POST)
	@ResponseBody
	public User pwChange(HttpServletRequest request){
		String changePw = request.getParameter("userPw");
		
		String userId = null;
		Cookie[] cookies = request.getCookies();
		for(Cookie cookie:cookies){
			if(cookie.getName().equals("userId")){
				userId = cookie.getValue();
			}
		}
		
		User changeUser = new User();
		changeUser.setUserId(userId);
		changeUser.setUserPw(changePw);

		userService.updatePw(changeUser);
		
		User corUser = userService.findUser(userId);
		request.getSession().setAttribute("corUser", corUser);	
		return corUser;
	}
	
	@RequestMapping(value="emailChange", method = RequestMethod.POST)
	@ResponseBody
	public User emailChange(HttpServletRequest request){
		String changeEmail = request.getParameter("userEmail");

		String userId = null;
		Cookie[] cookies = request.getCookies();
		for(Cookie cookie:cookies){
			if(cookie.getName().equals("userId")){
				userId = cookie.getValue();
			}
		}
		
		User changeUser = new User();
		changeUser.setUserId(userId);
		changeUser.setUserEmail(changeEmail);

		userService.updateEmail(changeUser);
		
		User corUser = userService.findUser(userId);
		request.getSession().setAttribute("corUser", corUser);	
		return corUser;
	}
	
	@RequestMapping(value="/delUser",method = RequestMethod.GET)
	public String delUser(HttpServletRequest request){
		
		String userId = null;
		Cookie[] cookies = request.getCookies();
		for(Cookie cookie:cookies){
			if(cookie.getName().equals("userId")){
				userId = cookie.getValue();
			}
		}
		
		User delUser = new User();
		delUser.setUserId(userId);
		
		userService.delUser(delUser);
		
		return "user/logIn";
	}

	/////////////////////////////////////////////////////////////////////////////
	
	
	@RequestMapping("/logout")
	public String logout(HttpServletRequest request, HttpServletResponse response){
		request.getSession().invalidate();
		
		Cookie[] cookies = request.getCookies();
		if(cookies != null){
			for(int i=0; i< cookies.length; i++){
				cookies[i].setMaxAge(0); // 유효시간을 0으로 설정
				response.addCookie(cookies[i]); // 응답 헤더에 추가
			}
		}
		
		return "redirect:/";
	}
	
	
	
	@RequestMapping("/img")
	public void image(){}
	
	@RequestMapping("/css")
	public void css(){}
	
	@RequestMapping("/js")
	public void js(){}
}
