package jungbeen.note.usernote.dao;

import java.util.List;

import jungbeen.note.usernote.dao.mapper.UserNoteMapper;
import jungbeen.note.usernote.domain.UserNote;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class UserNoteDaoImpl implements UserNoteDao {
	@Autowired private UserNoteMapper userNoteMapper;
	
	@Override
	public List<UserNote> selectUserNotes(UserNote userNote) {
		return userNoteMapper.selectUserNotes(userNote);
	}
	
	@Override
	public int insertUserNote(UserNote userNote) {
		return userNoteMapper.insertUserNote(userNote);
	}
	
	@Override
	public int updateUserNote(UserNote userNote) {
		return userNoteMapper.updateUserNote(userNote);
	}
	
	@Override
	public int deleteUserNote(UserNote userNote) {
		return userNoteMapper.deleteUserNote(userNote);
	}
}
