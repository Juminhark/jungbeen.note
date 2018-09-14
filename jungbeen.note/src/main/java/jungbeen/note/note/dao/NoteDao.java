package jungbeen.note.note.dao;

import java.util.List;

import jungbeen.note.note.domain.Note;

public interface NoteDao {
	List<Note> selectNotes(String userId);
	Note selectNote(int noteId);
	int insertNote(Note note);
	int updateNote(Note note);
	int deleteNote(Note note);
	int NEXTVAL();
}
