package jungbeen.note.note.dao.mapper;

import java.util.List;

import jungbeen.note.note.domain.Note;

public interface NoteMapper {
	List<Note> selectNotes(String userId);
	Note selectNote(int noteId);
	int insertNote(Note note);
	int deleteNote(Note note);
	int updateNote(Note note);
	
	int NEXTVAL();
}
