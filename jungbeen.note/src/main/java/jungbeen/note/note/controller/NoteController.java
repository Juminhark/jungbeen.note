package jungbeen.note.note.controller;

import java.util.List;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;

import jungbeen.note.note.domain.Note;
import jungbeen.note.note.service.NoteService;
import jungbeen.note.page.domain.Page;
import jungbeen.note.page.service.PageService;
import jungbeen.note.user.domain.User;
import jungbeen.note.user.service.UserService;
import jungbeen.note.usernote.domain.UserNote;
import jungbeen.note.usernote.service.UserNoteService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/")
public class NoteController {
	@Autowired private NoteService noteService;
	@Autowired private PageService pageService;
	@Autowired private UserNoteService userNoteService;
	@Autowired private UserService userService;
	
	@RequestMapping("/main")
	public String main(HttpServletRequest request) {		
		User user = (User)request.getSession().getAttribute("corUser");
		String userId = user.getUserId();
		
		if(userId == null)
			return "forward:/";
		
		request.setAttribute("userId", userId);
		
		List<Note> notes = noteService.getNotes(userId);
		request.setAttribute("notes", notes);
		
		UserNote userNote = new UserNote();
		userNote.setUserId(userId);
		List<UserNote> userNotes = userNoteService.getUserNotes(userNote);
		request.setAttribute("userNotes", userNotes);
		
		return "main";
	}
	
	@RequestMapping("/add")
	@ResponseBody
	public boolean addNote(HttpServletRequest request) {
		int noteId = noteService.NEXTVAL();
		int noteIdx = Integer.parseInt(request.getParameter("idx").trim());
		
		Note note = new Note();
		note.setId(noteId);
		note.setName("");
		note.setColor("#000000");
		note.setShareCnt(0);
		noteService.addNote(note);
		
		for(int i = 0; i < 50; i++) {
			Page page = new Page();
			
			page.setNoteId(noteId);
			page.setIdx(i);
			page.setContent1("");
			page.setContent2("");
			page.setContent3("");
			page.setContent4("");
			page.setContent5("");
			
			pageService.addPage(page);
		}
		
		UserNote userNote = new UserNote();
		
		userNote.setUserId(request.getParameter("userId"));
		userNote.setNoteId(noteId);
		userNote.setNoteIdx(noteIdx);
		userNote.setIsOwner(1);
		
		return userNoteService.addUserNote(userNote);
	}
	
	@RequestMapping("/edit")
	@ResponseBody
	public boolean reName(HttpServletRequest request) {
		int noteId = Integer.parseInt(request.getParameter("noteId"));
		String noteName = request.getParameter("noteName");
		String noteColor = request.getParameter("noteColor");
		boolean success = false;
		
		/*
		 * 노트를 수정
		 */
		Note note = new Note();
		note.setId(noteId);
		note.setName(noteName);
		note.setColor(noteColor);
		success = noteService.editNote(note);
		
		
		return success;
	}
	
	@RequestMapping("/delete")
	@ResponseBody
	public boolean delete(HttpServletRequest request) {
		String userId= request.getParameter("userId");
		int noteId = Integer.parseInt(request.getParameter("noteId"));
		int noteIdx = Integer.parseInt(request.getParameter("noteIdx"));
		boolean success = false;
		
		/*
		 * 본인이 소유주가 아니라면 노트를 삭제하지 않는다.
		 */
		UserNote param = new UserNote();
		param.setNoteId(noteId);
		List<UserNote> check = userNoteService.getUserNotes(param);
		
		boolean isOwner = false;
		
		param = new UserNote();
		param.setUserId(userId);
		param.setNoteId(noteId);
		List<UserNote> userNotes = userNoteService.getUserNotes(param);
		
		for(UserNote userNote : userNotes)
			if(userNote.getIsOwner() == 1)
				isOwner = true;
		
		/*
		 * 소유주가 노트를 삭제하면, 공유 받은 사람에게서도 노트가 사라진다.
		 * 그러면 공유 받은 사람의 노트들의 인덱스에 오차가 생긴다.
		 */
		if(isOwner) {
			UserNote search = new UserNote();
			search.setNoteId(noteId);
			List<UserNote> uNotes = userNoteService.getUserNotes(search);
			
			for(UserNote un : uNotes) {
				/*
				 * 삭제된 노트보다 큰 인덱스를 가진 노트들의 인덱스를 재 정렬
				 */
				search = new UserNote();
				search.setUserId(un.getUserId());
				System.out.println(un.getUserId());
				List<UserNote> userN = userNoteService.getUserNotes(search);
				for(UserNote userNote : userN) {
					System.out.println(userNote);
					if(userNote.getNoteIdx() > noteIdx) {
						UserNote alter = new UserNote();
						alter.setUserId(un.getUserId());
						alter.setNoteId(userNote.getNoteId());
						alter.setNoteIdx(userNote.getNoteIdx()-1);
						success = userNoteService.editUserNote(alter);
					}
				}
			}
		} else {
			/*
			 * 삭제된 노트보다 큰 인덱스를 가진 노트들의 인덱스를 재 정렬
			 */
			UserNote search = new UserNote();
			search.setUserId(userId);
			List<UserNote> userN = userNoteService.getUserNotes(search);
			for(UserNote userNote : userN) {
				if(userNote.getNoteIdx() > noteIdx) {
					UserNote alter = new UserNote();
					alter.setUserId(userId);
					alter.setNoteId(userNote.getNoteId());
					alter.setNoteIdx(userNote.getNoteIdx()-1);
					success = userNoteService.editUserNote(alter);
				}
			}
		}
		
		/*
		 * usernote에서 삭제
		 */
		UserNote delete = new UserNote();
		delete.setNoteId(noteId);
		
		if(!isOwner) //노트의 소유주라면 모든 공유를 해지할 수 있다.
			delete.setUserId(userId);
		
		success = userNoteService.delUserNote(delete);
		
		if(check.size() == 0 || isOwner) {//사용자가 없거나 소유주라면 노트를 완전 삭제할 수 있다.
			
			/*
			 * 노트의 page들 삭제
			 */
			Page page = new Page();
			page.setNoteId(noteId);
			success = pageService.delPage(page);
			
			/*
			 * 노트를 삭제
			 */
			Note note = new Note();
			note.setId(noteId);
			success = noteService.delNote(note);
		} else {//소유주가 아니고, 공유된 사용자가 없으면, share_cnt를 1 감소한다.
			
			/*
			 * 노트의 share_cnt를 감소
			 */
			Note old = noteService.getNote(noteId);
			Note alter = new Note();
			alter.setId(old.getId());
			alter.setShareCnt(old.getShareCnt()-1);
			success = noteService.editNote(alter);
		}
		
		return success;
	}
	
	@RequestMapping("/share")
	@ResponseBody
	public boolean share(HttpServletRequest request) {
		String friendId = request.getParameter("friendId");
		int noteId = Integer.parseInt(request.getParameter("noteId"));
		boolean success = false;
		
		/*
		 * 존재하는 사용자인지 확인
		 */
		boolean isExist = false;
		
		User friend = userService.findUser(friendId);
		if(friend != null)
			isExist = true;
		
		/*
		 * 이미 공유된 노트인지 확인
		 */
		boolean isNested = false;
		
		UserNote search = new UserNote();
		search.setUserId(friendId);
		List<UserNote> friendNotes = userNoteService.getUserNotes(search); 
		for(UserNote un : friendNotes)
			if(un.getNoteId() == noteId)
				isNested = true;
		
		/*
		 * 존재하는 사용자고 첫 공유이면 노트를 공유
		 */
		if(!isNested && isExist) {
			Note friendNote = noteService.getNote(noteId);
			Note newNote = new Note();
			newNote.setId(noteId);
			newNote.setShareCnt(friendNote.getShareCnt() + 1);
			success = noteService.editNote(newNote);

			UserNote userNote = new UserNote();
			userNote.setUserId(friendId);
			userNote.setNoteId(noteId);
			userNote.setNoteIdx(friendNotes.size());
			success = userNoteService.addUserNote(userNote);
		}
		
		return success;
	}
	
	//Note들의 Index를 변경한다.
	@RequestMapping("/reAlign")
	@ResponseBody
	public boolean reAlign(HttpServletRequest request) {
		int originIdx = Integer.parseInt(request.getParameter("originIdx"));
		int changeIdx = Integer.parseInt(request.getParameter("changeIdx"));
		int noteId = Integer.parseInt(request.getParameter("noteId"));
		String userId = request.getParameter("userId");
		boolean isLast = request.getParameter("isLast").equals("true") ? true : false;
		boolean success = false;
		
		/*
		 * 옮겨진 노트의 인덱스를 수정
		 */
		UserNote alter = new UserNote();
		alter.setUserId(userId);
		alter.setNoteId(noteId);
		alter.setNoteIdx(originIdx < changeIdx || isLast ? changeIdx : changeIdx+1);
		userNoteService.editUserNote(alter);
		
		System.out.println("reAlign noteId: " + noteId);
		System.out.println("reAlign changeIdx: " + changeIdx);
		
		/*
		 * 해당 사용자의 노트들의 인덱스를 재 정렬
		 */
		UserNote search = new UserNote();
		search.setUserId(userId);
		
		List<UserNote> userNotes = userNoteService.getUserNotes(search);
		
		for(UserNote userNote : userNotes) {
			alter = new UserNote();
			System.out.println("fds");
			if(userNote.getNoteId() != noteId) {
				if(isLast) {
					if(changeIdx <= userNote.getNoteIdx() && userNote.getNoteIdx() <= originIdx-1) {
						alter.setUserId(userNote.getUserId());
						alter.setNoteId(userNote.getNoteId());
						alter.setNoteIdx(userNote.getNoteIdx() + 1);
						success = userNoteService.editUserNote(alter);
					}
				} else if(originIdx < changeIdx) {
					if(originIdx+1 <= userNote.getNoteIdx() && userNote.getNoteIdx() <= changeIdx) {
						alter.setUserId(userNote.getUserId());
						alter.setNoteId(userNote.getNoteId());
						alter.setNoteIdx(userNote.getNoteIdx() - 1);
						success = userNoteService.editUserNote(alter);
					}
				} else if(originIdx > changeIdx) {
					if(changeIdx+1 <= userNote.getNoteIdx() && userNote.getNoteIdx() <= originIdx-1) {
						alter.setUserId(userNote.getUserId());
						alter.setNoteId(userNote.getNoteId());
						alter.setNoteIdx(userNote.getNoteIdx() + 1);
						success = userNoteService.editUserNote(alter);
					}
				}
			}
		}
		
		return success;
	}
	
	@RequestMapping("/note")
	public String note(HttpServletRequest request) {
		int noteId = Integer.parseInt(request.getParameter("noteId").trim());
		request.setAttribute("noteId", noteId);
		
		List<Page> pages = pageService.getPages(noteId);
		request.setAttribute("pages", pages);
		
		System.out.println(pages.get(0).getNoteId());
		
		String noteIdx = request.getParameter("noteIdx");
		request.setAttribute("noteIdx", noteIdx);
		return "note/note";
	}
}
