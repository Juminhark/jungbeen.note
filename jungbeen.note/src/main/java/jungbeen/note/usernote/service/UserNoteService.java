package jungbeen.note.usernote.service;

import java.util.List;

import jungbeen.note.usernote.domain.UserNote;

public interface UserNoteService {
	List<UserNote> getUserNotes(UserNote userNote);
	boolean addUserNote(UserNote userNote);
	boolean editUserNote(UserNote userNote);
	boolean delUserNote(UserNote userNote);
}
