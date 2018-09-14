package jungbeen.note.note.service;

import java.util.List;

import jungbeen.note.note.dao.NoteDao;
import jungbeen.note.note.domain.Note;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NoteServiceImpl implements NoteService {
	@Autowired private NoteDao noteDao;
	
	@Override
	public List<Note> getNotes(String userId) {
		return noteDao.selectNotes(userId);
	}
	
	@Override
	public Note getNote(int noteId) {
		return noteDao.selectNote(noteId);
	}
	
	@Override
	public boolean addNote(Note note) {
		return noteDao.insertNote(note) > 0;
	}
	
	@Override
	public boolean editNote(Note note) {
		return noteDao.updateNote(note) > 0;
	}
	
	@Override
	public boolean delNote(Note note) {
		return noteDao.deleteNote(note) > 0;
	}
	
	@Override
	public int NEXTVAL() {
		return noteDao.NEXTVAL();
	}
}
