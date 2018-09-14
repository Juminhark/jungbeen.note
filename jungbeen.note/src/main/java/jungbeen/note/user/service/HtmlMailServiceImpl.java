package jungbeen.note.user.service;

import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMessage.RecipientType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import jungbeen.note.user.domain.Message;

@Service
public class HtmlMailServiceImpl implements HtmlMailService{
	@Autowired private JavaMailSender mailSender;
	
	@Override
	public void send(Message msg){
		MimeMessage message = mailSender.createMimeMessage();
		try{
			message.addRecipient(RecipientType.TO, new InternetAddress(msg.getTo()));
			message.setSubject(msg.getSubject());
			message.setText(msg.getTxt(), "utf-8", "html");
		}catch(Exception e){}
		mailSender.send(message);
	}

}
