package jungbeen.note.usernote.service;

import java.util.List;

import jungbeen.note.usernote.dao.UserNoteDao;
import jungbeen.note.usernote.domain.UserNote;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserNoteServiceImpl implements UserNoteService {
	@Autowired private UserNoteDao userNoteDao;
	
	@Override
	public List<UserNote> getUserNotes(UserNote userNote) {
		return userNoteDao.selectUserNotes(userNote);
	}
	
	@Override
	public boolean addUserNote(UserNote userNote) {
		return userNoteDao.insertUserNote(userNote) > 0;
	}
	
	@Override
	public boolean editUserNote(UserNote userNote) {
		return userNoteDao.updateUserNote(userNote) > 0;
	}
	
	@Override
	public boolean delUserNote(UserNote userNote) {
		return userNoteDao.deleteUserNote(userNote) > 0;
	}
}
