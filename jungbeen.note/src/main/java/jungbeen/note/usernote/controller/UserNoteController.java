package jungbeen.note.usernote.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import jungbeen.note.note.domain.Note;
import jungbeen.note.note.service.NoteService;
import jungbeen.note.usernote.domain.UserNote;
import jungbeen.note.usernote.service.UserNoteService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/userNote")
public class UserNoteController {
	@Autowired private UserNoteService userNoteService;
	@Autowired private NoteService noteService;
	
	@RequestMapping("/get")
	@ResponseBody
	public List<UserNote> get(HttpServletRequest request) {
		String userId = request.getParameter("userId");
		String noteId = request.getParameter("noteId");
		
		UserNote search = new UserNote();
		if(userId != null && !userId.equals(""))
			search.setUserId(userId);
		if(noteId != null && !noteId.equals(""))
			search.setNoteId(Integer.parseInt(noteId));
		
		return userNoteService.getUserNotes(search);
	}
	
	@RequestMapping("/delete")
	@ResponseBody
	public boolean delete(HttpServletRequest request) {
		String userId = request.getParameter("userId");
		String noteId = request.getParameter("noteId");
		boolean success = false;
		
		System.out.println(userId);
		
		UserNote target = new UserNote();
		if(userId != null && !userId.equals(""))
			target.setUserId(userId);
		if(noteId != null && !noteId.equals(""))
			target.setNoteId(Integer.parseInt(noteId));
		success = userNoteService.delUserNote(target);
		
		if(noteId != null && !noteId.equals("")) {
			Note note = noteService.getNote(Integer.parseInt(noteId));
			Note alter = new Note();
			alter.setId(note.getId());
			alter.setShareCnt(note.getShareCnt()-1);
			noteService.editNote(alter);
		}
		
		return true;
	}
	
	@RequestMapping("/edit")
	@ResponseBody
	public boolean edit(HttpServletRequest request) {
		String userId = request.getParameter("userId");
		String noteId = request.getParameter("noteId");
		String noteIdx = request.getParameter("noteIdx");
		String isOwner = request.getParameter("isOwner");
		boolean success = false;
		
		UserNote alter = new UserNote();
		if(userId != null && !userId.equals(""))
			alter.setUserId(userId);
		
		if(noteId != null && !noteId.equals(""))
			alter.setNoteId(Integer.parseInt(noteId));
		
		if(noteIdx != null && !noteIdx.equals(""))
			alter.setNoteIdx(Integer.parseInt(noteIdx));
		
		if(isOwner != null && !isOwner.equals(""))
			alter.setIsOwner(Integer.parseInt(isOwner));
		
		success = userNoteService.editUserNote(alter);
		
		return success;
	}
}
