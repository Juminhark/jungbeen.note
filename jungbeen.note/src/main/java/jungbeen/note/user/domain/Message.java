package jungbeen.note.user.domain;

public class Message {
	private String to;
	private String subject;
	private String txt;
	public String getTo() {
		return to;
	}
	
	public Message(String to, String subject, String txt){
		this.to = to;
		this.subject = subject; 
		this.txt = txt;
	}
	
	public void setTo(String to) {
		this.to = to;
	}
	public String getSubject() {
		return subject;
	}
	public void setSubject(String subject) {
		this.subject = subject;
	}
	public String getTxt() {
		return txt;
	}
	public void setTxt(String txt) {
		this.txt = txt;
	}
}
