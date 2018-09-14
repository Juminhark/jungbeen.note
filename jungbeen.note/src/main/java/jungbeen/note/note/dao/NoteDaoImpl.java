package jungbeen.note.note.dao;

import java.util.List;

import jungbeen.note.note.dao.mapper.NoteMapper;
import jungbeen.note.note.domain.Note;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class NoteDaoImpl implements NoteDao {
	@Autowired private NoteMapper noteMapper;
	
	@Override
	public List<Note> selectNotes(String userId) {
		return noteMapper.selectNotes(userId);
	}
	
	@Override
	public Note selectNote(int noteId) {
		return noteMapper.selectNote(noteId);
	}
	
	@Override
	public int insertNote(Note note) {
		return noteMapper.insertNote(note);
	}
	
	@Override
	public int updateNote(Note note) {
		return noteMapper.updateNote(note);
	}
	
	@Override
	public int deleteNote(Note note) {
		return noteMapper.deleteNote(note);
	}
	
	@Override
	public int NEXTVAL() {
		return noteMapper.NEXTVAL();
	}
}
