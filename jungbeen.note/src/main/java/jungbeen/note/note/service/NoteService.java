package jungbeen.note.note.service;

import java.util.List;

import jungbeen.note.note.domain.Note;

public interface NoteService {
	List<Note> getNotes(String userId);
	Note getNote(int noteId);
	boolean addNote(Note note);
	boolean editNote(Note note);
	boolean delNote(Note note);
	int NEXTVAL();
}
