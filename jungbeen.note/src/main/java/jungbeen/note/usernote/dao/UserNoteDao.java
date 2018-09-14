package jungbeen.note.usernote.dao;

import java.util.List;

import jungbeen.note.usernote.domain.UserNote;

public interface UserNoteDao {
	List<UserNote> selectUserNotes(UserNote userNote);
	int insertUserNote(UserNote userNote);
	int updateUserNote(UserNote userNote);
	int deleteUserNote(UserNote userNote);
}
