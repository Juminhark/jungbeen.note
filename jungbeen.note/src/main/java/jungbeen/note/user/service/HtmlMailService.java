package jungbeen.note.user.service;

import jungbeen.note.user.domain.Message;

public interface HtmlMailService {
	void send(Message msg);
}
