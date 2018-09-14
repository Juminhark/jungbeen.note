package jungbeen.note.user.domain;

public class User {
	private String userId;
	private String userPw;
	private String userName;
	private String userEmail;
	private String userImg;
	
	public User(){}
	
	public User(String userId,String userPw,String userName,String userEmail){
		this.userId = userId;
		this.userPw = userPw;
		this.userName = userName;
		this.userEmail = userEmail;
	}
	
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getUserPw() {
		return userPw;
	}
	public void setUserPw(String userPw) {
		this.userPw = userPw;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getUserEmail() {
		return userEmail;
	}
	public void setUserEmail(String userEmail) {
		this.userEmail = userEmail;
	}

	public String getUserImg() {
		return userImg;
	}

	public void setUserImg(String userImg) {
		this.userImg = userImg;
	}
	
	public String toString(){
		return String.format("%s %s %s %s",userId,userPw,userName,userEmail);
	}
}
